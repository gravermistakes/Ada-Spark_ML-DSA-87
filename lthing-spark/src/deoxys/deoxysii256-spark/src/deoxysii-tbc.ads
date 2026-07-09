------------------------------------------------------------------------------
--  Deoxysii.TBC — the P/M seam (DEOXY_1_41.md P-9). FROZEN at G0.
--
--  Deoxys-BC-384 forward encryption only (invariant I1: no inverse anything).
--  SUBAGENT-P owns the body; SUBAGENT-M calls this and MUST NOT reimplement
--  any of P-2..P-8. This spec is immutable after G0.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package Deoxysii.TBC is

   function TBC_Encrypt_384 (Key       : Key_256;      --  32 bytes
                             Tweak     : Block_128;    --  16 bytes
                             Plaintext : Block_128)    --  16 bytes
                             return Block_128          --  16 bytes
     with Global => null;                              --  pure, side-effect free

end Deoxysii.TBC;
