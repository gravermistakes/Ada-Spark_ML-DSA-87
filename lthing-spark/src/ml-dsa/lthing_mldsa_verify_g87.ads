------------------------------------------------------------------------------
--  LTHING_MLDSA_Verify_G87 — ML-DSA-87 verifier via generic instantiation
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with LTHING_MLDSA_G_Verify;
with LTHING_MLDSA_Params_87;
with LTHING_MLDSA_Codec_G87;
with LTHING_MLDSA_Sample_G87;

package LTHING_MLDSA_Verify_G87 is new LTHING_MLDSA_G_Verify
  (Params => LTHING_MLDSA_Params_87,
   Codec  => LTHING_MLDSA_Codec_G87,
   Sample => LTHING_MLDSA_Sample_G87);
