------------------------------------------------------------------------------
--  Deoxysii.TBC — G0 STUB body (returns Plaintext).
--
--  SUBAGENT-P replaces this with the real Deoxys-BC-384 forward path
--  (P-2..P-8): tweakey schedule STK[0..16], then the 16-round P-2 loop.
--  The stub exists so the crate builds and proves clean at G0.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package body Deoxysii.TBC is

   function TBC_Encrypt_384 (Key       : Key_256;
                             Tweak     : Block_128;
                             Plaintext : Block_128)
                             return Block_128
   is
      pragma Unreferenced (Key, Tweak);
   begin
      return Plaintext;   --  G0 stub: identity. P1/P2 replace with real TBC.
   end TBC_Encrypt_384;

end Deoxysii.TBC;
