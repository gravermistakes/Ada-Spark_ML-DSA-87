------------------------------------------------------------------------------
--  LTHING_MLDSA_Codec_G65 — ML-DSA-65 codec via generic instantiation
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with LTHING_MLDSA_G_Codec;
with LTHING_MLDSA_Params_65;

package LTHING_MLDSA_Codec_G65 is new LTHING_MLDSA_G_Codec
  (Params => LTHING_MLDSA_Params_65);
