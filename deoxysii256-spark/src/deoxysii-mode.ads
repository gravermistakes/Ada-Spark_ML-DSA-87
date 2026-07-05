------------------------------------------------------------------------------
--  Deoxysii.Mode — SCT-2 AEAD mode logic (DEOXY_1_41.md M-2/M-3/M-4).
--
--  Generic over the forward tweakable-block-cipher oracle E, so the mode
--  logic can be exercised against a pinned lookup-table oracle for the M1
--  gate while production code (Deoxysii.adb) instantiates it with the real
--  Deoxysii.TBC.TBC_Encrypt_384. This package knows nothing about
--  Deoxys-BC-384 internals (P-2..P-8) -- E is called purely as a black box,
--  matching the frozen P-9 seam signature exactly.
--
--  Deoxys-II decryption uses ONLY forward TBC encryption: auth, tag,
--  keystream and verification all reuse the same E; there is no decryption
--  primitive anywhere in this unit.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

generic
   --  E is the opaque forward TBC oracle. GNAT does not accept a Global
   --  aspect directly on a generic formal subprogram declaration; E has no
   --  parameters referencing any package state (only by-value Block_128 /
   --  Key_256 values), so flow analysis infers Global => null for every
   --  call site in this generic body, matching the actual
   --  Deoxysii.TBC.TBC_Encrypt_384 (which is itself declared Global => null)
   --  used at the production instantiation in Deoxysii.adb.
   with function E (Key : Key_256; Tweak, Plaintext : Block_128) return Block_128;
package Deoxysii.Mode is

   --  M-3: seal (encrypt + authenticate). CT'Length = Msg'Length; Tag is
   --  returned separately (no ciphertext expansion).
   procedure Seal
     (Key   : Key_256;
      Nonce : Nonce_120;
      AD    : Byte_Seq;
      Msg   : Byte_Seq;
      CT    : out Byte_Seq;
      Tag   : out Tag_128)
   with
     Global => null,
     Pre    => CT'Length = Msg'Length;

   --  M-4: recover the message from CT under the received Tag, then verify
   --  by recomputing the tag over the recovered message and AD. Fail-closed:
   --  if verification fails, Ok is False and Msg is fully zeroized.
   procedure Open
     (Key   : Key_256;
      Nonce : Nonce_120;
      AD    : Byte_Seq;
      CT    : Byte_Seq;
      Tag   : Tag_128;
      Msg   : out Byte_Seq;
      Ok    : out Boolean)
   with
     Global => null,
     Pre    => Msg'Length = CT'Length,
     Post   => (if not Ok then (for all B of Msg => B = 0));

end Deoxysii.Mode;
