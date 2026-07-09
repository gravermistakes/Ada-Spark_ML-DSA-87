------------------------------------------------------------------------------
--  Deoxysii — G0 STUB body. Fail-closed even as a stub: Encrypt emits zeros,
--  Decrypt refuses everything (Ok = False, Msg zeroized).
--
--  SUBAGENT-M replaces this at M1 with the real SCT-2 mode (M-3/M-4) over
--  Deoxysii.Mode and the frozen Deoxysii.TBC seam.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with Deoxysii.CT;

package body Deoxysii is

   procedure Encrypt (Key   : Key_256;
                      Nonce : Nonce_120;
                      AD    : Byte_Seq;
                      Msg   : Byte_Seq;
                      CT    : out Byte_Seq;
                      Tag   : out Tag_128)
   is
      pragma Unreferenced (Key, Nonce, AD, Msg);
   begin
      Deoxysii.CT.Zeroize (CT);
      Tag := (others => 0);
   end Encrypt;

   procedure Decrypt (Key   : Key_256;
                      Nonce : Nonce_120;
                      AD    : Byte_Seq;
                      CT    : Byte_Seq;
                      Tag   : Tag_128;
                      Msg   : out Byte_Seq;
                      Ok    : out Boolean)
   is
      pragma Unreferenced (Key, Nonce, AD, CT, Tag);
   begin
      Deoxysii.CT.Zeroize (Msg);
      Ok := False;   --  G0 stub: fail-closed. M1 replaces with real D^II.
   end Decrypt;

end Deoxysii;
