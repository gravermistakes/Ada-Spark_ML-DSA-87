------------------------------------------------------------------------------
--  LTHING_MLDSA_G_Sample — generic ML-DSA (FIPS 204) ExpandA + SampleInBall
--
--  Generic over LTHING_MLDSA_G_Params; implements:
--    * Sample_In_Ball   (FIPS 204 Algorithm 29)
--    * Expand_A         (FIPS 204 Algorithm 32)
--
--  Parameterized by (k, l, tau) via the Params formal package.
--  Matrix A is k x l of NTT-domain polynomials (LTHING_MLDSA_NTT.Poly).
--
--  SPARK_Mode (On); proof target is AoRTE + flow.
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with Interfaces;          use Interfaces;
with LTHING_MLDSA_NTT;    use LTHING_MLDSA_NTT;
with LTHING_Types;        use LTHING_Types;
with LTHING_MLDSA_G_Params;

generic
   with package Params is new LTHING_MLDSA_G_Params (<>);
package LTHING_MLDSA_G_Sample is

   use Params;

   --  SampleInBall: derive challenge polynomial c from c_tilde.
   --  Result has exactly Tau nonzero coeffs in {-1,+1} (as Fq values:
   --  +1 -> 1, -1 -> Q-1).
   procedure Sample_In_Ball
     (C_Tilde : Byte_Array;
      C       : out LTHING_MLDSA_NTT.Poly);

   --  Matrix A is k x l of polynomials in NTT domain.
   type Matrix is array (0 .. K_Dim - 1, 0 .. L_Dim - 1)
     of LTHING_MLDSA_NTT.Poly;

   --  ExpandA: expand rho (32 bytes) into the k x l matrix A_hat (NTT domain).
   procedure Expand_A
     (Rho : Byte_Array;
      A   : out Matrix)
     with Pre => Rho'First = 0 and then Rho'Last = 31;

end LTHING_MLDSA_G_Sample;
