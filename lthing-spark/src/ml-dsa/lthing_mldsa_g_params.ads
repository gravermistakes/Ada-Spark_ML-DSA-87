------------------------------------------------------------------------------
--  LTHING_MLDSA_G_Params — generic ML-DSA parameter package (FIPS 204)
--
--  Parameterized by the six values that vary across ML-DSA security levels:
--    K_Dim, L_Dim, Eta, Tau, Omega, C_Tilde_Bytes.
--  Derives the remaining constants (Beta, PK_Bytes, Sig_Bytes) and declares
--  the per-parameter-set types (Public_Key, Signature, T1_Vec, Z_Vec, H_Vec,
--  Poly, Hint_Poly, C_Tilde_Array).
--
--  Constants shared across all three ML-DSA parameter sets (N, Q, Gamma1,
--  Gamma2, D_Bits) are declared as named numbers.
--
--  Instantiate once per security level; the resulting package provides the
--  type-safe foundation for the generic codec, sampler, and verifier.
--
--  SPARK_Mode (On); no body.
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with Interfaces;   use Interfaces;
with LTHING_Types; use LTHING_Types;

generic
   G_K_Dim         : Positive;
   G_L_Dim         : Positive;
   G_Eta           : Positive;
   G_Tau           : Positive;
   G_Omega         : Positive;
   G_C_Tilde_Bytes : Positive;
package LTHING_MLDSA_G_Params is

   K_Dim         : constant Positive := G_K_Dim;
   L_Dim         : constant Positive := G_L_Dim;
   Eta           : constant Positive := G_Eta;
   Tau           : constant Positive := G_Tau;
   Omega         : constant Positive := G_Omega;
   C_Tilde_Bytes : constant Positive := G_C_Tilde_Bytes;

   N      : constant := 256;
   Q      : constant := 8_380_417;
   Gamma1 : constant := 2 ** 19;
   Gamma2 : constant := (Q - 1) / 32;
   D_Bits : constant := 13;

   Beta      : constant Natural  := Tau * Eta;
   PK_Bytes  : constant Positive := 32 + K_Dim * 320;
   Sig_Bytes : constant Positive :=
     C_Tilde_Bytes + L_Dim * 640 + Omega + K_Dim;

   Max_Message_Bytes : constant := Max_Document_Bytes - 512;

   subtype Public_Key    is Byte_Array (0 .. PK_Bytes - 1);
   subtype Signature     is Byte_Array (0 .. Sig_Bytes - 1);
   subtype C_Tilde_Array is Byte_Array (0 .. C_Tilde_Bytes - 1);
   subtype Rho_Array     is Byte_Array (0 .. 31);

   subtype Coeff is Integer_32;

   type Poly is array (0 .. N - 1) of Coeff;

   type T1_Vec is array (0 .. K_Dim - 1) of Poly;
   type Z_Vec  is array (0 .. L_Dim - 1) of Poly;

   subtype Hint_Bit is Coeff range 0 .. 1;
   type Hint_Poly is array (0 .. N - 1) of Hint_Bit;
   type H_Vec is array (0 .. K_Dim - 1) of Hint_Poly;

end LTHING_MLDSA_G_Params;
