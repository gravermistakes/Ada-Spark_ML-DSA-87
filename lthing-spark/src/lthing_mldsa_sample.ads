------------------------------------------------------------------------------
--  LTHING.MLDSA.Sample — Part 3: ExpandA + SampleInBall (FIPS 204)
--
--  no it is not using asm.
--
--  SampleInBall self-gate: output polynomial must have exactly tau=49 nonzero
--  coefficients, each +1 or -1. ExpandA self-gate: determinism + range [0,q).
--  
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with Interfaces;          use Interfaces;
with LTHING_MLDSA_NTT;    use LTHING_MLDSA_NTT;
with LTHING_Types;        use LTHING_Types;

package LTHING_MLDSA_Sample is

   Tau : constant := 49;

   --  SampleInBall: derive challenge polynomial c from c_tilde (48 bytes for
   --  ML-DSA-65). Result has exactly tau nonzero coeffs in {-1,+1}.
   procedure Sample_In_Ball
     (C_Tilde : Byte_Array;
      C       : out Poly);

   --  Matrix A is k x l of polynomials in NTT domain.
   type Matrix is array (0 .. 5, 0 .. 4) of Poly;   --  k=6, l=5

   --  ExpandA: expand rho (32 bytes) into the k x l matrix A_hat (NTT domain).
   procedure Expand_A
     (Rho : Byte_Array;
      A   : out Matrix);

   --  count nonzero coeffs (for the self-gate / debugging) <-- NOT ALLOWED
   -- function Count_Nonzero (C : Poly) return Natural;

end LTHING_MLDSA_Sample;
