------------------------------------------------------------------------------
--  LTHING.MLDSA.Round (body) — ML-DSA-65 rounding / hint layer (FIPS 204)
--
--  All arithmetic is carried in Integer_64; the operand magnitudes are all
--  well under 2^46 so AoRTE holds. Each routine reduces back into Fq / the
--  declared subtype ranges proven in the spec.
--
--  Timing posture:
--    * Mod_Pm: branchless conditional subtract (no branch on centered value).
--    * Decompose: branchless corner-case correction for Rp - Lo = Q - 1.
--    * Inf_Norm_OK: full scan of all 256 coefficients, no early return.
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package body LTHING_MLDSA_Round is

   ---------------------------------------------------------------------------
   --  Mod_Pm — branchless centered remainder
   ---------------------------------------------------------------------------
   function Mod_Pm (R : Integer_64; A : Integer_64) return Integer_64 is
      M    : constant Integer_64 := R mod A;
      Half : constant Integer_64 := A / 2;
      Diff : constant Unsigned_64 := Unsigned_64 (Half) - Unsigned_64 (M);
      Gt   : constant Unsigned_64 := Shift_Right (Diff, 63);
      Corr : constant Integer_64 := Integer_64 (Gt) * A;
   begin
      return M - Corr;
   end Mod_Pm;

   ---------------------------------------------------------------------------
   --  Power2Round (Alg. 35)
   ---------------------------------------------------------------------------
   procedure Power2Round (R : Fq; R1 : out P2R_High; R0 : out P2R_Low) is
      Rr  : constant Integer_64 := Integer_64 (R);
      Low : constant Integer_64 := Mod_Pm (Rr, Two_Pow_D);
      Hi  : constant Integer_64 := (Rr - Low) / Two_Pow_D;
   begin
      pragma Assert (Rr - Low >= 0);
      pragma Assert ((Rr - Low) mod Two_Pow_D = 0);
      pragma Assert (Hi * Two_Pow_D = Rr - Low);
      R0 := Integer_32 (Low);
      R1 := Integer_32 (Hi);
   end Power2Round;

   ---------------------------------------------------------------------------
   --  Decompose (Alg. 36) — branchless corner-case correction
   ---------------------------------------------------------------------------
   procedure Decompose (R : Fq; R1 : out Bins; R0 : out Low_Range) is
      Rp  : constant Integer_64 := Integer_64 (R) mod Q;
      Lo  : Integer_64 := Mod_Pm (Rp, Two_Gamma2);
      Hi  : Integer_64;
      Is_Top : constant Integer_64 :=
        Integer_64 (Boolean'Pos (Rp - Lo = Q - 1));
   begin
      Hi := (Rp - Lo) / Two_Gamma2;
      pragma Assert ((Rp - Lo) mod Two_Gamma2 = 0);
      pragma Assert (Hi * Two_Gamma2 + Lo = Rp);
      Hi := Hi * (1 - Is_Top);
      Lo := Lo - Is_Top;
      pragma Assert ((Hi * Two_Gamma2 + Lo) mod Q = Rp mod Q);
      R1 := Integer_32 (Hi);
      R0 := Integer_32 (Lo);
   end Decompose;

   ---------------------------------------------------------------------------
   --  High_Bits (Alg. 37)
   ---------------------------------------------------------------------------
   function High_Bits (R : Fq) return Bins is
      R1 : Bins;
      R0 : Low_Range;
   begin
      Decompose (R, R1, R0);
      return R1;
   end High_Bits;

   ---------------------------------------------------------------------------
   --  Low_Bits (Alg. 38)
   ---------------------------------------------------------------------------
   function Low_Bits (R : Fq) return Low_Range is
      R1 : Bins;
      R0 : Low_Range;
   begin
      Decompose (R, R1, R0);
      return R0;
   end Low_Bits;

   ---------------------------------------------------------------------------
   --  Use_Hint (Alg. 40)
   ---------------------------------------------------------------------------
   function Use_Hint (H : Integer_32; R : Fq) return Bins is
      R1 : Bins;
      R0 : Low_Range;
   begin
      Decompose (R, R1, R0);
      if H = 1 and then R0 > 0 then
         return Integer_32 ((Integer_64 (R1) + 1) mod M_Bins);
      elsif H = 1 then
         return Integer_32 ((Integer_64 (R1) - 1 + M_Bins) mod M_Bins);
      else
         return R1;
      end if;
   end Use_Hint;

   ---------------------------------------------------------------------------
   --  W1_Encode
   ---------------------------------------------------------------------------
   function W1_Encode (W1 : Poly) return W1_Bytes is
      Out_B : W1_Bytes := (others => 0);
   begin
      for T in 0 .. 127 loop
         Out_B (T) :=
           Byte (Integer_32 (W1 (2 * T)) + 16 * Integer_32 (W1 (2 * T + 1)));
         pragma Loop_Invariant
           (for all K in 0 .. T => Out_B (K) <= 255);
      end loop;
      return Out_B;
   end W1_Encode;

   ---------------------------------------------------------------------------
   --  Inf_Norm_OK — full scan, no early return
   ---------------------------------------------------------------------------
   function Inf_Norm_OK (P : Poly; Bound : Integer_32) return Boolean is
      All_Ok : Boolean := True;
   begin
      for I in P'Range loop
         if abs (To_Centered (P (I))) >= Bound then
            All_Ok := False;
         end if;
         pragma Loop_Invariant
           (All_Ok = (for all K in P'First .. I =>
                        abs (To_Centered (P (K))) < Bound));
      end loop;
      return All_Ok;
   end Inf_Norm_OK;

end LTHING_MLDSA_Round;
