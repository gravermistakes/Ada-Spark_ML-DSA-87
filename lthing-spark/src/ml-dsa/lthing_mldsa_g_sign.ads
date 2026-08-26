------------------------------------------------------------------------------
--  LTHING_MLDSA_G_Sign — generic ML-DSA (FIPS 204) key generation + signing
--
--  Parameterized by a Params / Codec / Sample triple, instantiate once per
--  security level.  Implements:
--    * Key_Gen — FIPS 204 Algorithm 6 (ML-DSA.KeyGen_internal)
--    * Sign    — FIPS 204 Algorithm 7 (ML-DSA.Sign_internal, deterministic)
--
--  SPARK_Mode (On); proof target is AoRTE + flow.
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with Interfaces;       use Interfaces;
with LTHING_Types;     use LTHING_Types;
with LTHING_MLDSA_NTT;
with LTHING_MLDSA_G_Params;
with LTHING_MLDSA_G_Codec;
with LTHING_MLDSA_G_Sample;

generic
   with package Params is new LTHING_MLDSA_G_Params (<>);
   with package Codec  is new LTHING_MLDSA_G_Codec  (Params => Params);
   with package Sample is new LTHING_MLDSA_G_Sample  (Params => Params);
package LTHING_MLDSA_G_Sign is

   use Params;

   subtype SPoly is LTHING_MLDSA_NTT.Poly;

   type L_Vec is array (0 .. L_Dim - 1) of SPoly;
   type K_Vec is array (0 .. K_Dim - 1) of SPoly;

   type Secret_Key is record
      Rho : Byte_Array (0 .. 31);
      KK  : Byte_Array (0 .. 31);
      Tr  : Byte_Array (0 .. 63);
      S1  : L_Vec;
      S2  : K_Vec;
      T0  : K_Vec;
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

end LTHING_MLDSA_G_Sign;
