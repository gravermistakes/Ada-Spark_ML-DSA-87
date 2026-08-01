------------------------------------------------------------------------------
--  LTHING_MLDSA_Codec_G87 — ML-DSA-87 codec via generic instantiation
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with LTHING_MLDSA_G_Codec;
with LTHING_MLDSA_Params_87;

package LTHING_MLDSA_Codec_G87 is new LTHING_MLDSA_G_Codec
  (Params => LTHING_MLDSA_Params_87);
