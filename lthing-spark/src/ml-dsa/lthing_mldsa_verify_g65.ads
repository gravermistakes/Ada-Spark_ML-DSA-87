------------------------------------------------------------------------------
--  LTHING_MLDSA_Verify_G65 — ML-DSA-65 verifier via generic instantiation
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with LTHING_MLDSA_G_Verify;
with LTHING_MLDSA_Params_65;
with LTHING_MLDSA_Codec_G65;
with LTHING_MLDSA_Sample_G65;

package LTHING_MLDSA_Verify_G65 is new LTHING_MLDSA_G_Verify
  (Params => LTHING_MLDSA_Params_65,
   Codec  => LTHING_MLDSA_Codec_G65,
   Sample => LTHING_MLDSA_Sample_G65);
