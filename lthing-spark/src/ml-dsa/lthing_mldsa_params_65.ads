------------------------------------------------------------------------------
--  LTHING_MLDSA_Params_65 — ML-DSA-65 (FIPS 204, NIST Security Level 3)
--
--  Instantiation of LTHING_MLDSA_G_Params with the ML-DSA-65 parameter set:
--    (k, l) = (6, 5), eta = 4, tau = 49, omega = 55, c_tilde = 48 bytes.
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with LTHING_MLDSA_G_Params;

package LTHING_MLDSA_Params_65 is new LTHING_MLDSA_G_Params
  (G_K_Dim         => 6,
   G_L_Dim         => 5,
   G_Eta           => 4,
   G_Tau           => 49,
   G_Omega         => 55,
   G_C_Tilde_Bytes => 48);
