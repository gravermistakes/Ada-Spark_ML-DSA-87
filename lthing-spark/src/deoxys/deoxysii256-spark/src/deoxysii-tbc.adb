------------------------------------------------------------------------------
--  Deoxysii.TBC — Deoxys-BC-384 forward encryption (DEOXY_1_41.md P-2..P-8).
--
--  Tweakey schedule (P-6/P-7): STK[0..16] built from three 128-bit lanes
--  TK1 (no LFSR), TK2 (LFSR2), TK3 (LFSR3), each permuted by h per round,
--  STK[i] = TK1[i] xor TK2[i] xor TK3[i] xor RC[i].
--
--  Round loop (P-2, r = 16): AddRoundTweakey FIRST, then SubBytes,
--  ShiftRows, MixColumns; final AddRoundTweakey with STK[16], no trailing
--  MixColumns. State model is column-major (P-1); GF(2^8) doublings are
--  `mod 2**8` operations (Byte is a modular type, no overflow VC survives).
--
--  LANDMINE-2 (KAT-resolved): the tweakey seed mapping is the ONE swappable
--  constant Seed_Order below, both candidate wirings written out. Flipping
--  A<->B is a one-line change (Seed_Order's initializer).
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with Deoxysii.TBC.Tables; use Deoxysii.TBC.Tables;

package body Deoxysii.TBC is

   --  LANDMINE-2: tweakey word ordering ------------------------------------
   --  ORD_A: TK1 <- Khi (Key bytes 0..15),  TK2 <- Klo (Key bytes 16..31),
   --         TK3 <- Tweak.                          (v1.41 l.584-594 prose)
   --  ORD_B: TK1 <- Tweak,  TK2 <- Klo,  TK3 <- Khi. (JoC l.423-439 prose)
   --  The gate P1 vector decides; start with ORD_A, flip to ORD_B if P1 fails
   --  on ORD_A (DEOXYSIIS.md sec 6, DEOXY_1_41.md LANDMINE-2).

   type Seed_Order_Kind is (ORD_A, ORD_B);

   Seed_Order : constant Seed_Order_Kind := ORD_B;

   --  Local schedule type (17 subtweakeys, mirrors Deoxysii.Subtweakeys). --

   subtype Round_Index  is Natural range 0 .. 15;
   subtype STK_Index    is Natural range 0 .. 16;
   type Lane_Schedule is array (STK_Index) of Block_128;

   --  Block-level primitives -------------------------------------------

   function XOR_Block (A, B : Block_128) return Block_128 is
      R : Block_128;
   begin
      for I in R'Range loop
         R (I) := A (I) xor B (I);
      end loop;
      return R;
   end XOR_Block;

   function Permute16 (S : Block_128; P : Perm16) return Block_128 is
      R : Block_128;
   begin
      for I in R'Range loop
         R (I) := S (P (I));
      end loop;
      return R;
   end Permute16;

   function Sub_Bytes (S : Block_128) return Block_128 is
      R : Block_128;
   begin
      for I in R'Range loop
         R (I) := SBOX (S (I));
      end loop;
      return R;
   end Sub_Bytes;

   function Shift_Rows (S : Block_128) return Block_128 is
   begin
      return Permute16 (S, SR);
   end Shift_Rows;

   --  GF(2^8)/0x11B doubling and triple, on the modular Byte type: all
   --  arithmetic below wraps mod 2**8 by construction (Byte is `mod 2**8`),
   --  so no overflow check can fail. ---------------------------------------

   function XTime (X : Byte) return Byte is
      Doubled : constant Byte := X * 2;
   begin
      if (X and 16#80#) /= 0 then
         return Doubled xor 16#1B#;
      else
         return Doubled;
      end if;
   end XTime;

   function GMul3 (X : Byte) return Byte is
   begin
      return XTime (X) xor X;
   end GMul3;

   function Mix_Columns (S : Block_128) return Block_128 is
      --  Default-initialized: the loop below writes all 16 indices (4 per
      --  Col iteration) but not via a single R'Range sweep, so flow
      --  analysis needs an explicit starting value to prove full init.
      R : Block_128 := (others => 0);
   begin
      for Col in 0 .. 3 loop
         declare
            A : constant Byte := S (4 * Col + 0);
            B : constant Byte := S (4 * Col + 1);
            D : constant Byte := S (4 * Col + 2);
            E : constant Byte := S (4 * Col + 3);
         begin
            R (4 * Col + 0) := XTime (A) xor GMul3 (B) xor D xor E;
            R (4 * Col + 1) := A xor XTime (B) xor GMul3 (D) xor E;
            R (4 * Col + 2) := A xor B xor XTime (D) xor GMul3 (E);
            R (4 * Col + 3) := GMul3 (A) xor B xor D xor XTime (E);
         end;
      end loop;
      return R;
   end Mix_Columns;

   --  Tweakey LFSRs (P-7), applied per byte, then per block. Shifts are
   --  written as multiplication/division by powers of two rather than the
   --  Shift_Left/Shift_Right attributes: Byte is an unsigned `mod 2**8`
   --  type, so for values always in 0 .. 255 these are exact equivalents
   --  (division truncates like a logical right shift; multiplication wraps
   --  mod 256 like a logical left shift with the overflow bits discarded),
   --  and both are ordinary modular operations with no overflow VC. --------

   function LFSR2_Byte (B : Byte) return Byte is
      --  out = (x6 x5 x4 x3 x2 x1 x0, x7 xor x5)
      Bit : constant Byte := ((B / 128) xor (B / 32)) and 1;
   begin
      return ((B * 2) and 16#FF#) or Bit;
   end LFSR2_Byte;

   function LFSR3_Byte (B : Byte) return Byte is
      --  out = (x0 xor x6, x7 x6 x5 x4 x3 x2 x1)
      Bit : constant Byte := ((B and 1) xor (B / 64)) and 1;
   begin
      return (B / 2) or (Bit * 128);
   end LFSR3_Byte;

   function LFSR2_Block (S : Block_128) return Block_128 is
      R : Block_128;
   begin
      for I in R'Range loop
         R (I) := LFSR2_Byte (S (I));
      end loop;
      return R;
   end LFSR2_Block;

   function LFSR3_Block (S : Block_128) return Block_128 is
      R : Block_128;
   begin
      for I in R'Range loop
         R (I) := LFSR3_Byte (S (I));
      end loop;
      return R;
   end LFSR3_Block;

   --  P-8: round-constant block RC[i], column-major bytes
   --  (1,2,4,8, RCON(i),RCON(i),RCON(i),RCON(i), 0,0,0,0, 0,0,0,0). ---------

   function RC_Block (I : STK_Index) return Block_128 is
      R : Block_128 := (others => 0);
   begin
      R (0) := 16#01#;
      R (1) := 16#02#;
      R (2) := 16#04#;
      R (3) := 16#08#;
      R (4) := RCON (I);
      R (5) := RCON (I);
      R (6) := RCON (I);
      R (7) := RCON (I);
      return R;
   end RC_Block;

   --  P-6/P-7: build the 17 subtweakeys STK[0..16] from the 384-bit
   --  tweakey (Key || Tweak), seeded per Seed_Order (LANDMINE-2). ----------

   function Build_STK (Key : Key_256; Tweak : Block_128) return Lane_Schedule is
      Khi, Klo : Block_128;
      --  Default-initialized: index 0 is set by the Seed_Order case
      --  statement and indices 1 .. 16 by the schedule loop below, two
      --  separate constructs flow analysis can't merge into a full-array
      --  init proof without an explicit starting value.
      TK1, TK2, TK3 : Lane_Schedule := (others => (others => 0));
      STK : Lane_Schedule;
   begin
      for I in Khi'Range loop
         Khi (I) := Key (I);
         Klo (I) := Key (16 + I);
      end loop;

      case Seed_Order is
         when ORD_A =>
            TK1 (0) := Khi;
            TK2 (0) := Klo;
            TK3 (0) := Tweak;
         when ORD_B =>
            TK1 (0) := Tweak;
            TK2 (0) := Klo;
            TK3 (0) := Khi;
      end case;

      for I in Round_Index loop
         TK1 (I + 1) := Permute16 (TK1 (I), H);
         TK2 (I + 1) := Permute16 (LFSR2_Block (TK2 (I)), H);
         TK3 (I + 1) := Permute16 (LFSR3_Block (TK3 (I)), H);
      end loop;

      for I in STK_Index loop
         STK (I) := XOR_Block (XOR_Block (TK1 (I), TK2 (I)),
                                XOR_Block (TK3 (I), RC_Block (I)));
      end loop;

      return STK;
   end Build_STK;

   --  P-9 seam: the whole forward primitive. --------------------------------

   function TBC_Encrypt_384 (Key       : Key_256;
                             Tweak     : Block_128;
                             Plaintext : Block_128)
                             return Block_128
   is
      STK : constant Lane_Schedule := Build_STK (Key, Tweak);
      S   : Block_128 := Plaintext;
   begin
      for K in Round_Index loop
         S := XOR_Block (S, STK (K));      --  AddRoundTweakey (first, P-2)
         S := Sub_Bytes (S);
         S := Shift_Rows (S);
         S := Mix_Columns (S);
      end loop;
      S := XOR_Block (S, STK (16));        --  final AddRoundTweakey, no MC
      return S;
   end TBC_Encrypt_384;

end Deoxysii.TBC;
