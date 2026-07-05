------------------------------------------------------------------------------
--  Deoxysii.TBC — the P-9 seam (DEOXY_1_41.md sec P-9).
--
--  FROZEN at G0. This signature is the only shared surface between the P
--  lane (SUBAGENT-P, which fills in the body) and the M lane (SUBAGENT-M,
--  which calls this as an opaque oracle and MUST NOT open P-2..P-8).
--
--  Deoxys-BC-384: forward-only tweakable block cipher, 16 rounds,
--  384-bit tweakey (256-bit key || 128-bit tweak), 128-bit block.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package Deoxysii.TBC is

   function TBC_Encrypt_384
     (Key       : Key_256;
      Tweak     : Block_128;
      Plaintext : Block_128) return Block_128
   with
     Global => null;   --  pure, side-effect free

end Deoxysii.TBC;
