------------------------------------------------------------------------------
--  LTHING_MLDSA_G_Codec — generic ML-DSA (FIPS 204) byte codec
--
--  Generic over LTHING_MLDSA_G_Params; implements the FIPS 204 byte
--  (de)serialization primitives parameterized by (k, l, omega, c_tilde):
--    * Get_Bit          (bit indexing within a byte slice)
--    * SimpleBitUnpack  (Algorithm 19)
--    * SimpleBitPack    (Algorithm 16)
--    * pkDecode         (Algorithm 23)
--    * pkEncode         (Algorithm 22)
--    * sigDecode        (Algorithm 27) + HintBitUnpack (Algorithm 21)
--    * sigEncode        (Algorithm 26) + HintBitPack   (Algorithm 20)
--
--  SPARK_Mode (On); proof target is AoRTE + stated range contracts.
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with Interfaces;          use Interfaces;
with LTHING_Types;        use LTHING_Types;
with LTHING_MLDSA_G_Params;

generic
   with package Params is new LTHING_MLDSA_G_Params (<>);
package LTHING_MLDSA_G_Codec is

   use Params;

   function Get_Bit (V : Byte_Array; N : Natural) return Coeff
     with Global => null,
          Pre    => V'Length > 0 and then N / 8 <= V'Last - V'First,
          Post   => Get_Bit'Result in 0 .. 1;

   function Simple_Bit_Unpack
     (V : Byte_Array; Bit_Len : Positive; Hi : Coeff) return Poly
     with Global => null,
          Pre    => Bit_Len <= 20
                    and then V'Length = (Params.N * Bit_Len) / 8
                    and then Hi in 1 .. 1_048_575,
          Post   => (for all I in Poly'Range =>
                       Simple_Bit_Unpack'Result (I) in 0 .. Hi);

   procedure Pk_Decode
     (PK  : Public_Key;
      Rho : out Rho_Array;
      T1  : out T1_Vec)
     with Global => null,
          Post   => (for all I in T1_Vec'Range =>
                       (for all J in Poly'Range => T1 (I) (J) in 0 .. 1023));

   function Simple_Bit_Pack
     (V : Poly; Bit_Len : Positive; Hi : Coeff) return Byte_Array
     with Global => null,
          Pre    => Bit_Len <= 20
                    and then Hi in 1 .. 1_048_575
                    and then (for all I in Poly'Range => V (I) in 0 .. Hi),
          Post   => Simple_Bit_Pack'Result'First = 0
                    and then Simple_Bit_Pack'Result'Length =
                               (Params.N * Bit_Len) / 8;

   function Pk_Encode (Rho : Rho_Array; T1 : T1_Vec) return Public_Key
     with Global => null,
          Pre    => (for all I in T1_Vec'Range =>
                       (for all J in Poly'Range => T1 (I) (J) in 0 .. 1023));

   function Sig_Encode
     (C_Tilde : C_Tilde_Array; Z : Z_Vec; H : H_Vec) return Signature
     with Global => null,
          Pre    => (for all I in Z_Vec'Range =>
                       (for all J in Poly'Range =>
                          Z (I) (J) in 0 .. Params.Q - 1));

   procedure Sig_Decode
     (Sig     : Signature;
      C_Tilde : out C_Tilde_Array;
      Z       : out Z_Vec;
      H       : out H_Vec;
      Ok      : out Boolean)
     with Global => null,
          Post   => (for all I in Z_Vec'Range =>
                       (for all J in Poly'Range =>
                          Z (I) (J) in 0 .. Params.Q - 1))
                    and then
                    (for all I in H_Vec'Range =>
                       (for all J in Hint_Poly'Range =>
                          H (I) (J) in 0 .. 1));

end LTHING_MLDSA_G_Codec;
