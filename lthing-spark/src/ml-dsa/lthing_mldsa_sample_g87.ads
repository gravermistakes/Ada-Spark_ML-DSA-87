------------------------------------------------------------------------------
--  LTHING_MLDSA_Sample_G87 — ML-DSA-87 sampler via generic instantiation
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with LTHING_MLDSA_G_Sample;
with LTHING_MLDSA_Params_87;

package LTHING_MLDSA_Sample_G87 is new LTHING_MLDSA_G_Sample
  (Params => LTHING_MLDSA_Params_87);
