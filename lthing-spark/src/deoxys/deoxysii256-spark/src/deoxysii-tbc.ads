------------------------------------------------------------------------------
--  Deoxysii.TBC — the P/M seam (DEOXY_1_41.md P-9). FROZEN at G0.
--
--  Deoxys-BC-384. TBC_Encrypt_384's signature is immutable after G0
--  (invariant I2); SUBAGENT-M calls it as an opaque oracle and MUST NOT
--  reimplement any of P-2..P-8.
--
--  TBC_Decrypt_384 (REAL-1, added post-G0) is the forward primitive's
--  inverse: full Deoxys-BC-384 decryption (inverse S-box, inverse
--  MixColumns, subtweakeys consumed in reverse order). It does not alter
--  TBC_Encrypt_384's logic or signature.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package Deoxysii.TBC is

   function TBC_Encrypt_384 (Key       : Key_256;      --  32 bytes
                             Tweak     : Block_128;    --  16 bytes
                             Plaintext : Block_128)    --  16 bytes
                             return Block_128          --  16 bytes
     with Global => null;                              --  pure, side-effect free

   function TBC_Decrypt_384 (Key        : Key_256;      --  32 bytes
                             Tweak      : Block_128;    --  16 bytes
                             Ciphertext : Block_128)    --  16 bytes
                             return Block_128           --  16 bytes
     with Global => null;                               --  pure, side-effect free

   --  REAL-2: exposed for tests/sbox_const_time.adb only (exhaustive
   --  256-value check against the pinned SBOX table + inverse
   --  self-consistency). Not called by TBC_Encrypt_384/TBC_Decrypt_384's
   --  callers directly; those go through the internal per-block Sub_Bytes/
   --  Inv_Sub_Bytes already wired into both directions.

   function Sub_Bytes_Byte (X : Byte) return Byte
     with Global => null;

   function Inv_Sub_Bytes_Byte (X : Byte) return Byte
     with Global => null;

end Deoxysii.TBC;
