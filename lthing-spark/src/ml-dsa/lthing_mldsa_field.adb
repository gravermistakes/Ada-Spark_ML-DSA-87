------------------------------------------------------------------------------
--  LTHING.MLDSA.Field (body) — provable Z_q arithmetic
--
--  Timing posture: To_Centered is branchless (no conditional jump on
--  secret-dependent data). Add/Sub/Mul/Reduce still use mod Q which GNAT
--  compiles to a multiply-shift sequence for the constant Q at -O2; verify
--  the generated assembly after any toolchain change (see patch §4).
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package body LTHING_MLDSA_Field is

   function Add (A, B : Fq) return Fq is
      S : constant Integer_64 := Integer_64 (A) + Integer_64 (B);
   begin
      return Fq (S mod Q);
   end Add;

   function Sub (A, B : Fq) return Fq is
      S : constant Integer_64 := Integer_64 (A) - Integer_64 (B) + Integer_64 (Q);
   begin
      return Fq (S mod Q);
   end Sub;

   function Mul (A, B : Fq) return Fq is
      P : constant Integer_64 := Integer_64 (A) * Integer_64 (B);
   begin
      return Fq (P mod Q);
   end Mul;

   function Reduce (X : Wide) return Fq is
   begin
      return Fq (X mod Q);
   end Reduce;

   function To_Centered (A : Fq) return Integer_32 is
      Val  : constant Unsigned_32 := Unsigned_32 (A);
      Half : constant Unsigned_32 := Unsigned_32 (Q / 2);
      Gt   : constant Unsigned_32 := Shift_Right (Half - Val, 31);
      Corr : constant Unsigned_32 := Gt * Unsigned_32 (Q);
   begin
      return Integer_32 (Val) - Integer_32 (Corr);
   end To_Centered;

end LTHING_MLDSA_Field;
