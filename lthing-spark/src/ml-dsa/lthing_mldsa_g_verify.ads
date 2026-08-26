------------------------------------------------------------------------------
--  LTHING_MLDSA_G_Verify — generic ML-DSA (FIPS 204) verifier
--
--  Generic over Params, Codec, and Sample; implements FIPS 204 Algorithm 3
--  (ML-DSA.Verify, external/pure) and Algorithm 8 (ML-DSA.Verify_internal).
--
--  Fail-closed: Verify returns False unless it reaches a genuine FIPS 204
--  acceptance (decode ok, ||z||_inf < gamma1-beta, hint weight <= omega,
--  c_tilde2 = c_tilde).
--
--  SPARK_Mode (On); proof target is AoRTE + flow + stated contracts.
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with Interfaces;          use Interfaces;
with LTHING_Types;        use LTHING_Types;
with LTHING_MLDSA_G_Params;
with LTHING_MLDSA_G_Codec;
with LTHING_MLDSA_G_Sample;

generic
   with package Params is new LTHING_MLDSA_G_Params (<>);
   with package Codec  is new LTHING_MLDSA_G_Codec  (Params => Params);
   with package Sample is new LTHING_MLDSA_G_Sample  (Params => Params);
package LTHING_MLDSA_G_Verify is

   use Params;

   function Verify
     (PK      : Public_Key;
      Message : Byte_Array;
      Context : Byte_Array;
      Sig     : Signature) return Boolean
     with Global => null,
          Pre    => Message'Length <= Max_Message_Bytes
                    and then Context'Length <= 255;

end LTHING_MLDSA_G_Verify;
