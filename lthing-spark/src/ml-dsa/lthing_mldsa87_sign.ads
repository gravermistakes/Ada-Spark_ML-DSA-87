------------------------------------------------------------------------------
--  LTHING.MLDSA87.Sign — ML-DSA-87 (FIPS 204) key generation + signing
--
--  Level-5 sibling of LTHING_MLDSA_Sign. Implements:
--    * Key_Gen — FIPS 204 Algorithm 6 (ML-DSA.KeyGen_internal): 32-byte seed
--      -> 2592-byte public key and expanded secret key (rho, K, tr, s1, s2, t0).
--    * Sign    — FIPS 204 Algorithm 7 (ML-DSA.Sign_internal): bounded
--      rejection loop producing a 4627-byte signature that Verify accepts.
--
--  ML-DSA-87 differences from ML-DSA-65 that affect signing:
--    eta = 2 (vs 4)   -> RejBoundedPoly accepts nibble < 5, coeff = eta - nibble
--    k = 8, l = 7     -> larger secret-key vectors and matrix
--    c_tilde = 64 B   (vs 48 B)   -> wider challenge hash
--    omega = 75        (vs 55)
--    beta = 120        (vs 196)
--
--  Round-trip identity: LTHING_MLDSA87.Verify(pk, m, ctx, Sign(sk, m, ctx)) = True.
--  That relational gate (plus tamper->reject) is the authoritative test in
--  test_sign87; no self-derived signature vector is embedded anywhere.
--
--  SPARK_Mode (On); AoRTE + flow. Rejection loop is a bounded for-loop
--  (Max_Attempts); exhaustion is fail-closed (Ok=False).
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with Interfaces;       use Interfaces;
with LTHING_Types;     use LTHING_Types;
with LTHING_MLDSA87;   use LTHING_MLDSA87;
with LTHING_MLDSA_NTT;

package LTHING_MLDSA87_Sign is

   subtype SPoly is LTHING_MLDSA_NTT.Poly;          --  array (0..255) of Fq

   type L_Vec is array (0 .. L_Dim - 1) of SPoly;   --  l = 7
   type K_Vec is array (0 .. K_Dim - 1) of SPoly;   --  k = 8

   type Secret_Key is record
      Rho : Byte_Array (0 .. 31);   --  matrix seed
      KK  : Byte_Array (0 .. 31);   --  signing seed K
      Tr  : Byte_Array (0 .. 63);   --  H(pk, 64)
      S1  : L_Vec;                  --  coeffs in [-eta, eta] (canonical)
      S2  : K_Vec;                  --  coeffs in [-eta, eta] (canonical)
      T0  : K_Vec;                  --  low part of t (canonical)
   end record;

   procedure Key_Gen
     (Seed : Byte_Array;
      PK   : out Public_Key;
      SK   : out Secret_Key)
     with Global => null,
          Pre    => Seed'Length = 32;

   procedure Sign
     (SK      : Secret_Key;
      Message : Byte_Array;
      Context : Byte_Array;
      Sig     : out Signature;
      Ok      : out Boolean)
     with Global => null,
          Pre    => Message'Length <= Max_Message_Bytes
                    and then Context'Length <= 255;

end LTHING_MLDSA87_Sign;
