------------------------------------------------------------------------------
--  Deoxysii (body) — M1: real SCT-2 mode logic (Deoxysii.Mode) wired to the
--  public M-6 API, instantiated with the production oracle
--  Deoxysii.TBC.TBC_Encrypt_384. All mode logic (M-2/M-3/M-4) lives in
--  Deoxysii.Mode; this body is pure wiring.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with Deoxysii.TBC;
with Deoxysii.Mode;

package body Deoxysii is

   package Real_Mode is new Deoxysii.Mode (Deoxysii.TBC.TBC_Encrypt_384);

   procedure Encrypt
     (Key   : Key_256;
      Nonce : Nonce_120;
      AD    : Byte_Seq;
      Msg   : Byte_Seq;
      CT    : out Byte_Seq;
      Tag   : out Tag_128)
   is
   begin
      Real_Mode.Seal (Key, Nonce, AD, Msg, CT, Tag);
   end Encrypt;

   procedure Decrypt
     (Key   : Key_256;
      Nonce : Nonce_120;
      AD    : Byte_Seq;
      CT    : Byte_Seq;
      Tag   : Tag_128;
      Msg   : out Byte_Seq;
      Ok    : out Boolean)
   is
   begin
      Real_Mode.Open (Key, Nonce, AD, CT, Tag, Msg, Ok);
   end Decrypt;

end Deoxysii;
