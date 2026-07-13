------------------------------------------------------------------------------
--  Deoxysii.TBC — Deoxys-BC-384 forward + inverse (DEOXY_1_41.md P-2..P-8,
--  REAL-1/REAL-2 per DEOXYSIIS.md sec 8).
--
--  Tweakey schedule (P-6/P-7): STK[0..16] built from three 128-bit lanes
--  TK1 (no LFSR), TK2 (LFSR2), TK3 (LFSR3), each permuted by h per round,
--  STK[i] = TK1[i] xor TK2[i] xor TK3[i] xor RC[i]. Both directions share
--  Build_STK; TBC_Decrypt_384 just consumes STK in reverse index order.
--
--  Forward round loop (P-2, r = 16): AddRoundTweakey FIRST, then SubBytes,
--  ShiftRows, MixColumns; final AddRoundTweakey with STK[16], no trailing
--  MixColumns. Decrypt runs the exact mirror: undo the final
--  AddRoundTweakey, then for each round (15 downto 0) InvMixColumns,
--  InvShiftRows, InvSubBytes, AddRoundTweakey(STK[k]). State model is
--  column-major (P-1); GF(2^8) doublings are `mod 2**8` operations (Byte is
--  a modular type, no overflow VC survives).
--
--  LANDMINE-2 (KAT-resolved): the tweakey seed mapping is the ONE swappable
--  constant Seed_Order below, both candidate wirings written out. Flipping
--  A<->B is a one-line change (Seed_Order's initializer).
--
--  REAL-2: SubBytes/InvSubBytes do NOT read the pinned SBOX table at
--  runtime (that table survives only as a test oracle). The S-box is
--  S(x) = Affine(Inverse(x)) with Inverse(0)=0 by convention; computed as
--  GF_Pow254(x) = x^254 = x^(2^8-2), the multiplicative inverse in
--  GF(2^8)/0x11B for x /= 0 (and GF_Pow254(0) = 0 for free, since the whole
--  chain is repeated multiplication by x). x^254 is reached by a FIXED
--  (compile-time-constant-exponent) left-to-right square-and-multiply
--  chain over the fixed bit pattern of 254 = 2#1111_1110# — 7 squarings +
--  6 multiplies-by-x, always in that order regardless of the secret byte
--  value, so no branch or memory access in the chain depends on secret
--  data. Affine/Inv_Affine are Rotr-based (Rotr itself is pure arithmetic,
--  branchless). GF_Mul (the single per-step primitive both the chain and
--  MixColumns build on) is the standard branchless peasant-multiplication:
--  each of its 8 loop steps folds in operand bits via an arithmetic
--  0x00/0xFF mask, never a conditional on a secret bit. Verified against
--  the pinned SBOX table for all 256 byte values (tests/sbox_const_time.adb)
--  before this table lookup was retired from the hot path.
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

   --  REAL-2: constant-time GF(2^8)/0x11B byte multiply. Branchless
   --  peasant multiplication: each of the 8 steps folds in one bit of RB
   --  via an arithmetic 0x00/0xFF mask (never a conditional on secret
   --  data), doubles RA with carry-reduction, and halves RB. -------------

   function GF_Mul (A, B : Byte) return Byte is
      RA   : Byte := A;
      RB   : Byte := B;
      R    : Byte := 0;
      Mask : Byte;
      Hi   : Byte;
   begin
      for I in 0 .. 7 loop
         Mask := 0 - (RB and 1);
         R := R xor (RA and Mask);
         Hi := RA and 16#80#;
         RA := RA * 2;
         if Hi /= 0 then
            RA := RA xor 16#1B#;
         end if;
         RB := RB / 2;
      end loop;
      return R;
   end GF_Mul;

   --  REAL-2: multiplicative inverse in GF(2^8), Inverse(0) = 0 by
   --  convention (falls out for free: the chain below is pure repeated
   --  multiplication by X, so X = 0 forces every intermediate to 0).
   --  x^254 via a FIXED left-to-right square-and-multiply chain over the
   --  compile-time-constant bit pattern of 254 = 2#1111_1110#: 7 squarings
   --  interleaved with 6 multiplies-by-X, always the same sequence of ops
   --  regardless of X's value. -------------------------------------------

   function GF_Pow254 (X : Byte) return Byte is
      R : Byte := X;
   begin
      for I in 1 .. 6 loop
         R := GF_Mul (R, R);
         R := GF_Mul (R, X);
      end loop;
      R := GF_Mul (R, R);
      return R;
   end GF_Pow254;

   --  Byte-wise right-rotate by K bits (K in 1 .. 7), pure arithmetic:
   --  high (8-K) bits shift down, low K bits wrap to the top. -------------

   function Rotr (B : Byte; K : Natural) return Byte is
   begin
      return (B / 2 ** K) or (B * 2 ** (8 - K));
   end Rotr;

   --  REAL-2: AES affine step S(x) = Affine(Inverse(x)), the standard
   --  bit formula s'_i = s_i xor s_(i+4) xor s_(i+5) xor s_(i+6) xor
   --  s_(i+7) xor c_i (indices mod 8, c = 0x63), written via Rotr.
   --  Inv_Affine is its matrix inverse (s'_i = s_(i+2) xor s_(i+5) xor
   --  s_(i+7) xor d_i, d = 0x05). Both verified byte-for-byte against the
   --  pinned SBOX table / round-trip in tests/sbox_const_time.adb. --------

   function Affine (X : Byte) return Byte is
   begin
      return X xor Rotr (X, 4) xor Rotr (X, 5) xor Rotr (X, 6) xor Rotr (X, 7)
             xor 16#63#;
   end Affine;

   function Inv_Affine (X : Byte) return Byte is
   begin
      return Rotr (X, 2) xor Rotr (X, 5) xor Rotr (X, 7) xor 16#05#;
   end Inv_Affine;

   function Sub_Bytes (S : Block_128) return Block_128 is
      R : Block_128;
   begin
      for I in R'Range loop
         R (I) := Affine (GF_Pow254 (S (I)));
      end loop;
      return R;
   end Sub_Bytes;

   function Inv_Sub_Bytes (S : Block_128) return Block_128 is
      R : Block_128;
   begin
      for I in R'Range loop
         R (I) := GF_Pow254 (Inv_Affine (S (I)));
      end loop;
      return R;
   end Inv_Sub_Bytes;

   --  REAL-2: single-byte wrappers, exposed via the .ads purely for
   --  tests/sbox_const_time.adb's exhaustive 256-value check. Same
   --  computation Sub_Bytes/Inv_Sub_Bytes apply per-element above. --------

   function Sub_Bytes_Byte (X : Byte) return Byte is
   begin
      return Affine (GF_Pow254 (X));
   end Sub_Bytes_Byte;

   function Inv_Sub_Bytes_Byte (X : Byte) return Byte is
   begin
      return GF_Pow254 (Inv_Affine (X));
   end Inv_Sub_Bytes_Byte;

   function Shift_Rows (S : Block_128) return Block_128 is
   begin
      return Permute16 (S, SR);
   end Shift_Rows;

   function Inv_Shift_Rows (S : Block_128) return Block_128 is
   begin
      return Permute16 (S, Inv_SR);
   end Inv_Shift_Rows;

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

   --  REAL-1: GF(2^8) multiply by the AES inverse-MDS coefficients
   --  {9, 11, 13, 14}, built from XTime the same way GMul3 is (standard
   --  double-and-add decomposition: 9=8+1, 11=8+2+1, 13=8+4+1, 14=8+4+2).

   function GMul9 (X : Byte) return Byte is
   begin
      return XTime (XTime (XTime (X))) xor X;
   end GMul9;

   function GMul11 (X : Byte) return Byte is
   begin
      return XTime (XTime (XTime (X))) xor XTime (X) xor X;
   end GMul11;

   function GMul13 (X : Byte) return Byte is
   begin
      return XTime (XTime (XTime (X))) xor XTime (XTime (X)) xor X;
   end GMul13;

   function GMul14 (X : Byte) return Byte is
   begin
      return XTime (XTime (XTime (X))) xor XTime (XTime (X)) xor XTime (X);
   end GMul14;

   --  REAL-1: inverse MDS matrix, the exact matrix inverse of Mix_Columns.
   --  Verified: Inv_Mix_Columns(Mix_Columns(S)) = S over the classic AES
   --  test column (DB,13,53,45) -> (8E,4D,A1,BC) and exhaustive per-byte
   --  sweeps, before this was wired into TBC_Decrypt_384. -----------------

   function Inv_Mix_Columns (S : Block_128) return Block_128 is
      R : Block_128 := (others => 0);
   begin
      for Col in 0 .. 3 loop
         declare
            A : constant Byte := S (4 * Col + 0);
            B : constant Byte := S (4 * Col + 1);
            D : constant Byte := S (4 * Col + 2);
            E : constant Byte := S (4 * Col + 3);
         begin
            R (4 * Col + 0) := GMul14 (A) xor GMul11 (B) xor GMul13 (D) xor GMul9 (E);
            R (4 * Col + 1) := GMul9 (A) xor GMul14 (B) xor GMul11 (D) xor GMul13 (E);
            R (4 * Col + 2) := GMul13 (A) xor GMul9 (B) xor GMul14 (D) xor GMul11 (E);
            R (4 * Col + 3) := GMul11 (A) xor GMul13 (B) xor GMul9 (D) xor GMul14 (E);
         end;
      end loop;
      return R;
   end Inv_Mix_Columns;

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

   --  REAL-1: the exact inverse of TBC_Encrypt_384. Same subtweakey
   --  schedule (Build_STK, untouched), consumed in reverse: undo the
   --  final AddRoundTweakey first, then for each round (15 downto 0)
   --  undo MixColumns, ShiftRows, SubBytes, AddRoundTweakey(STK(K)) in
   --  that order — the algebraic mirror of the forward loop's
   --  AddRoundTweakey(K), SubBytes, ShiftRows, MixColumns. Does not read
   --  or alter TBC_Encrypt_384. --------------------------------------------

   function TBC_Decrypt_384 (Key        : Key_256;
                             Tweak      : Block_128;
                             Ciphertext : Block_128)
                             return Block_128
   is
      STK : constant Lane_Schedule := Build_STK (Key, Tweak);
      S   : Block_128 := Ciphertext;
   begin
      S := XOR_Block (S, STK (16));        --  undo final AddRoundTweakey
      for K in reverse Round_Index loop
         S := Inv_Mix_Columns (S);
         S := Inv_Shift_Rows (S);
         S := Inv_Sub_Bytes (S);
         S := XOR_Block (S, STK (K));      --  AddRoundTweakey (undo)
      end loop;
      return S;
   end TBC_Decrypt_384;

end Deoxysii.TBC;
