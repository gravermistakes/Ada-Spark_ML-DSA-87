------------------------------------------------------------------------------
--  Deoxysii.TBC (body) — real Deoxys-BC-384 forward-only 16-round
--  tweakable block cipher (DEOXY_1_41.md P-2..P-8). Replaces the G0
--  identity stub.
--
--  Scope: forward encryption only. Deoxys-II-256-128/SCT-2 never invokes
--  TBC decryption, so inverse S-box, inverse MixColumns and reverse
--  tweakey schedule are intentionally NOT implemented here (out of
--  scope for SUBAGENT-P; extension point only).
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with Deoxysii.TBC.Tables;

package body Deoxysii.TBC is

   --  Deoxysii.TBC.Tables is a private child of this package: within this
   --  body its simple name "Tables" already denotes it directly (no
   --  renaming declaration needed, and one would conflict with it).

   ------------------------------------------------------------------
   --  LANDMINE-2: tweakey word seed ordering (DEOXYSIIS.md sec 6).
   --  KAT-RESOLVED by gate P1 against tests/vectors/p1_tbc_vector.json:
   --  ORD_A was tried first and produced a mismatch (ciphertext
   --  e019974c78cd3e11fcd8143ec70d48a2 vs expected
   --  518c1aa62a44d297012f4917dcb15aee); flipping to ORD_B reproduces
   --  the pinned vector exactly. ORD_B is the winner. This is still the
   --  ONLY line that would need to change to try the other ordering.
   ------------------------------------------------------------------
   type Tweakey_Order is (ORD_A, ORD_B);
   --  ORD_A: (TK1[0], TK2[0], TK3[0]) = (Khi, Klo, T)   -- MSB, mid, LSB
   --  ORD_B: (TK1[0], TK2[0], TK3[0]) = (T,   Klo, Khi) -- LSB, mid, MSB
   Seed_Order : constant Tweakey_Order := ORD_B;   --  KAT-resolved winner

   subtype STK_Index is Natural range 0 .. 16;

   ------------------------------------------------------------------
   --  GF(2^8) arithmetic, poly x^8+x^4+x^3+x+1 (0x11B).           (P-5)
   ------------------------------------------------------------------
   function Xtime (B : Byte) return Byte is
     (if B >= 16#80# then (B * 2) xor 16#1B# else B * 2);

   function Mul2 (B : Byte) return Byte is (Xtime (B));
   function Mul3 (B : Byte) return Byte is (Xtime (B) xor B);

   ------------------------------------------------------------------
   --  P-3 SubBytes, P-4 ShiftRows.
   ------------------------------------------------------------------
   function Sub_Bytes (S : Block_128) return Block_128 is
      Result : Block_128 := (others => 0);
   begin
      for I in S'Range loop
         Result (I) := Tables.SBOX (S (I));
      end loop;
      return Result;
   end Sub_Bytes;

   function Shift_Rows (S : Block_128) return Block_128 is
      Result : Block_128 := (others => 0);
   begin
      for I in S'Range loop
         Result (I) := S (Tables.SR (I));
      end loop;
      return Result;
   end Shift_Rows;

   ------------------------------------------------------------------
   --  P-5 MixColumns (AES MDS / "MixBytes"), one output byte at a time
   --  so the result is a single fully-defined aggregate (no partial
   --  array writes for SPARK flow analysis to worry about).
   ------------------------------------------------------------------
   function MC_Byte (S : Block_128; I : Tables.Index16) return Byte is
      Col : constant Natural := I / 4;
      Row : constant Natural := I mod 4;
      A   : constant Byte := S (4 * Col);
      B   : constant Byte := S (4 * Col + 1);
      D   : constant Byte := S (4 * Col + 2);
      E   : constant Byte := S (4 * Col + 3);
   begin
      case Row is
         when 0      => return Mul2 (A) xor Mul3 (B) xor D xor E;
         when 1      => return A xor Mul2 (B) xor Mul3 (D) xor E;
         when 2      => return A xor B xor Mul2 (D) xor Mul3 (E);
         when others => return Mul3 (A) xor B xor D xor Mul2 (E);
      end case;
   end MC_Byte;

   function Mix_Columns (S : Block_128) return Block_128 is
      Result : Block_128 := (others => 0);
   begin
      for I in S'Range loop
         Result (I) := MC_Byte (S, I);
      end loop;
      return Result;
   end Mix_Columns;

   ------------------------------------------------------------------
   --  P-7 tweakey schedule: h permutation and per-lane LFSRs.
   ------------------------------------------------------------------
   function H_Perm (S : Block_128) return Block_128 is
      Result : Block_128 := (others => 0);
   begin
      for I in S'Range loop
         Result (I) := S (Tables.H (I));
      end loop;
      return Result;
   end H_Perm;

   --  LFSR2: out = ((b<<1) and 0xFF) or (((b>>7) xor (b>>5)) and 1)
   function LFSR2_Byte (B : Byte) return Byte is
      Bit7 : constant Byte := B / 16#80#;
      Bit5 : constant Byte := (B / 16#20#) mod 2;
   begin
      return (B * 2) or (Bit7 xor Bit5);
   end LFSR2_Byte;

   --  LFSR3: out = (b>>1) or ((((b and 1) xor ((b>>6) and 1)) and 1)<<7)
   function LFSR3_Byte (B : Byte) return Byte is
      Bit0 : constant Byte := B mod 2;
      Bit6 : constant Byte := (B / 16#40#) mod 2;
   begin
      return (B / 2) or ((Bit0 xor Bit6) * 16#80#);
   end LFSR3_Byte;

   function LFSR2_Block (S : Block_128) return Block_128 is
      Result : Block_128 := (others => 0);
   begin
      for I in S'Range loop
         Result (I) := LFSR2_Byte (S (I));
      end loop;
      return Result;
   end LFSR2_Block;

   function LFSR3_Block (S : Block_128) return Block_128 is
      Result : Block_128 := (others => 0);
   begin
      for I in S'Range loop
         Result (I) := LFSR3_Byte (S (I));
      end loop;
      return Result;
   end LFSR3_Block;

   ------------------------------------------------------------------
   --  Xor_Block, Make_RC (P-8).
   ------------------------------------------------------------------
   function Xor_Block (A, B : Block_128) return Block_128 is
      Result : Block_128 := (others => 0);
   begin
      for I in A'Range loop
         Result (I) := A (I) xor B (I);
      end loop;
      return Result;
   end Xor_Block;

   --  RC(i) = (1,2,4,8, RCON(i),RCON(i),RCON(i),RCON(i), 0,0,0,0, 0,0,0,0)
   function Make_RC (I : STK_Index) return Block_128 is
     (16#01#, 16#02#, 16#04#, 16#08#,
      Tables.RCON (I), Tables.RCON (I), Tables.RCON (I), Tables.RCON (I),
      0, 0, 0, 0, 0, 0, 0, 0);

   ------------------------------------------------------------------
   --  TBC_Encrypt_384 — P-2 round structure: AddRoundTweakey FIRST,
   --  then SubBytes/ShiftRows/MixColumns, 16 rounds, then one final
   --  AddRoundTweakey (no MixColumns after it). 17 subtweakeys
   --  STK[0..16] consumed.
   ------------------------------------------------------------------
   function TBC_Encrypt_384
     (Key       : Key_256;
      Tweak     : Block_128;
      Plaintext : Block_128) return Block_128
   is
      Khi, Klo           : Block_128  := (others => 0);
      TK1, TK2, TK3, STK : Subtweakeys := (others => (others => 0));
      S                  : Block_128;
   begin
      --  P-6: split the 256-bit key into Khi (MSB 128 bits) and Klo.
      for I in 0 .. 15 loop
         Khi (I) := Key (I);
         Klo (I) := Key (I + 16);
      end loop;

      --  P-6 seed assignment, LANDMINE-2 resolved via Seed_Order.
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

      --  P-7 tweakey schedule recurrences, i = 0 .. 15.
      for I in 0 .. 15 loop
         TK1 (I + 1) := H_Perm (TK1 (I));
         TK2 (I + 1) := H_Perm (LFSR2_Block (TK2 (I)));
         TK3 (I + 1) := H_Perm (LFSR3_Block (TK3 (I)));
      end loop;

      --  Subtweakeys: STK[i] = TK1[i] xor TK2[i] xor TK3[i] xor RC[i].
      for I in 0 .. 16 loop
         STK (I) :=
           Xor_Block (Xor_Block (TK1 (I), TK2 (I)),
                      Xor_Block (TK3 (I), Make_RC (I)));
      end loop;

      --  P-2 round structure.
      S := Plaintext;
      for K in 0 .. 15 loop
         S := Xor_Block (S, STK (K));
         S := Sub_Bytes (S);
         S := Shift_Rows (S);
         S := Mix_Columns (S);
      end loop;
      S := Xor_Block (S, STK (16));

      return S;
   end TBC_Encrypt_384;

end Deoxysii.TBC;
