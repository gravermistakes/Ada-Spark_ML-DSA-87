------------------------------------------------------------------------------
--  LTHING_MLDSA_Params_87 — ML-DSA-87 (FIPS 204, NIST Security Level 5)
--
--  Instantiation of LTHING_MLDSA_G_Params with the ML-DSA-87 parameter set:
--    (k, l) = (8, 7), eta = 2, tau = 60, omega = 75, c_tilde = 64 bytes.
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with LTHING_MLDSA_G_Params;

package LTHING_MLDSA_Params_87 is new LTHING_MLDSA_G_Params
  (G_K_Dim         => 8,
   G_L_Dim         => 7,
   G_Eta           => 2,
   G_Tau           => 60,
   G_Omega         => 75,
   G_C_Tilde_Bytes => 64);
