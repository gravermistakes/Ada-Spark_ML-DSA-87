------------------------------------------------------------------------------
--  LTHING.Keccak (body) — FIPS 202 Keccak-f[1600] + SHAKE sponge.
--
--  Transcribed directly from a reference validated against FIPS 202 known
--  answers and Python hashlib (see package spec). Structured to be SPARK-clean:
--    * lanes are modular Unsigned_64 (no overflow possible);
--    * chi reads from a separate buffer B (no in-place corruption — the
--      2026-06-08 bug);
--    * rho+pi is a real permutation into B, not a no-op;
--    * byte XOR/extract use checked offsets, never 3-register addressing.
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package body LTHING_Keccak is

   subtype Lane_Range is Natural range 0 .. 24;
   subtype Coord      is Natural range 0 .. 4;
   subtype Rot_Amount is Natural range 0 .. 63;

   --  Round constants RC[0..23] (FIPS 202, Table / Algorithm 5).
   RC : constant array (0 .. 23) of Unsigned_64 :=
     (16#0000000000000001#, 16#0000000000008082#, 16#800000000000808A#,
      16#8000000080008000#, 16#000000000000808B#, 16#0000000080000001#,
      16#8000000080008081#, 16#8000000000008009#, 16#000000000000008A#,
      16#0000000000000088#, 16#0000000080008009#, 16#000000008000000A#,
      16#000000008000808B#, 16#800000000000008B#, 16#8000000000008089#,
      16#8000000000008003#, 16#8000000000008002#, 16#8000000000000080#,
      16#000000000000800A#, 16#800000008000000A#, 16#8000000080008081#,
      16#8000000000008080#, 16#0000000080000001#, 16#8000000080008008#);

   --  Rotation offsets rho[x][y] (FIPS 202).
   Rho : constant array (Coord, Coord) of Rot_Amount :=
     ((0, 36, 3, 41, 18),
      (1, 44, 10, 45, 2),
      (62, 6, 43, 15, 61),
      (28, 55, 25, 21, 56),
      (27, 20, 39, 8, 14));

   ---------------------------------------------------------------------------
   --  Keccak_F1600
   ---------------------------------------------------------------------------
   procedure Keccak_F1600 (A : in out State) is
      C : array (Coord) of Unsigned_64;
      D : array (Coord) of Unsigned_64;
      B : State;
   begin
      for Rnd in 0 .. 23 loop
         --  theta
         for X in Coord loop
            C (X) := A (X) xor A (X + 5) xor A (X + 10)
                       xor A (X + 15) xor A (X + 20);
         end loop;
         for X in Coord loop
            D (X) := C ((X + 4) mod 5)
                       xor Rotate_Left (C ((X + 1) mod 5), 1);
         end loop;
         for Y in Coord loop
            for X in Coord loop
               A (X + 5 * Y) := A (X + 5 * Y) xor D (X);
            end loop;
         end loop;

         --  rho + pi  (write into B; never a no-op)
         for Y in Coord loop
            for X in Coord loop
               B (Y + 5 * ((2 * X + 3 * Y) mod 5)) :=
                 Rotate_Left (A (X + 5 * Y), Rho (X, Y));
            end loop;
         end loop;

         --  chi  (read from B, write A — no in-place corruption)
         for Y in Coord loop
            for X in Coord loop
               A (X + 5 * Y) :=
                 B (X + 5 * Y)
                   xor ((not B (((X + 1) mod 5) + 5 * Y))
                          and B (((X + 2) mod 5) + 5 * Y));
            end loop;
         end loop;

         --  iota
         A (0) := A (0) xor RC (Rnd);
      end loop;
   end Keccak_F1600;

   ---------------------------------------------------------------------------
   --  SHAKE sponge
   ---------------------------------------------------------------------------
   procedure SHAKE
     (Input  : Byte_Array;
      Rate   : Positive;
      Output : out Byte_Array)
   is
      St : State := (others => 0);

      --  XOR one message byte into the sponge state at byte position Pos.
      procedure Xor_Byte (Pos : Natural; Val : Byte)
        with Global => (In_Out => St)
      is
         Lane : constant Lane_Range := Pos / 8;
         Sh   : constant Natural    := (Pos mod 8) * 8;
      begin
         St (Lane) := St (Lane) xor Shift_Left (Unsigned_64 (Val), Sh);
      end Xor_Byte;

      --  Extract one output byte from the sponge state at byte position Pos.
      function Get_Byte (Pos : Natural) return Byte
        with Global => (Input => St)
      is
         Lane : constant Lane_Range := Pos / 8;
         Sh   : constant Natural    := (Pos mod 8) * 8;
      begin
         return Byte (Shift_Right (St (Lane), Sh) and 16#FF#);
      end Get_Byte;

      N    : constant Natural := Input'Length;
      Off  : Natural := 0;       --  bytes of Input consumed
      Rem_ : Natural;
   begin
      --  Absorb full rate-sized blocks.
      while N - Off >= Rate loop
         for I in 0 .. Rate - 1 loop
            Xor_Byte (I, Input (Input'First + Off + I));
         end loop;
         Keccak_F1600 (St);
         Off := Off + Rate;
      end loop;

      --  Final (short) block + SHAKE padding: 0x1F at the message end,
      --  0x80 at byte (rate-1). If those coincide the byte becomes 0x9F.
      Rem_ := N - Off;
      for I in 0 .. Rem_ - 1 loop
         Xor_Byte (I, Input (Input'First + Off + I));
      end loop;
      Xor_Byte (Rem_, 16#1F#);
      Xor_Byte (Rate - 1, 16#80#);
      Keccak_F1600 (St);

      --  Squeeze: emit Rate bytes per permutation until Output is filled.
      declare
         Out_Pos : Natural := 0;
      begin
         loop
            for I in 0 .. Rate - 1 loop
               exit when Out_Pos >= Output'Length;
               Output (Output'First + Out_Pos) := Get_Byte (I);
               Out_Pos := Out_Pos + 1;
            end loop;
            exit when Out_Pos >= Output'Length;
            Keccak_F1600 (St);
         end loop;
      end;
   end SHAKE;

end LTHING_Keccak;
