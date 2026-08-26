pragma SPARK_Mode (On);

with LTHING_MLDSA_G_Sign;
with LTHING_MLDSA_Params_87;
with LTHING_MLDSA_Codec_G87;
with LTHING_MLDSA_Sample_G87;

package LTHING_MLDSA_Sign_G87 is new LTHING_MLDSA_G_Sign
  (Params => LTHING_MLDSA_Params_87,
   Codec  => LTHING_MLDSA_Codec_G87,
   Sample => LTHING_MLDSA_Sample_G87);
