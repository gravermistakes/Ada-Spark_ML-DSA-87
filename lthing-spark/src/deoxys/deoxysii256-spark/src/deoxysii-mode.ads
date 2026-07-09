------------------------------------------------------------------------------
--  Deoxysii.Mode — M-lane internal SCT-2 helpers (SUBAGENT-M owns).
--
--  Pure, side-effect-free block/tweak builders used by Deoxysii.Encrypt /
--  Deoxysii.Decrypt (DEOXY_1_41.md M-1..M-5): domain-separation tweaks
--  (M-2 table), pad10 (M-1), and the small block-algebra (xor, slice
--  extraction) the two-pass SCT-2 machinery needs. Never opens the TBC body
--  (Deoxysii.TBC is called as an opaque oracle by the parent package body).
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

private package Deoxysii.Mode is

   --  Domain-separation prefixes (M-2 table): occupy the TOP NIBBLE of
   --  tweak byte 0; the remaining 124 bits carry a big-endian counter or
   --  the nonce, per purpose.
   Prefix_AD_Full   : constant Byte := 16#20#;  --  0010 || i(124)
   Prefix_AD_Last   : constant Byte := 16#60#;  --  0110 || la(124)
   Prefix_Msg_Full  : constant Byte := 16#00#;  --  0000 || j(124)
   Prefix_Msg_Last  : constant Byte := 16#40#;  --  0100 || l(124)
   Prefix_Tag_Final : constant Byte := 16#10#;  --  0001 0000 || N(120)

   --  Block xor (encryption/keystream algebra).
   function Xor_Block (A, B : Block_128) return Block_128
     with Global => null,
          Post   => (for all I in Block_128'Range =>
                       Xor_Block'Result (I) = (A (I) xor B (I)));

   --  Tag xor (running-tag accumulation).
   function Xor_Tag (T : Tag_128; B : Block_128) return Tag_128
     with Global => null,
          Post   => (for all I in Tag_128'Range =>
                       Xor_Tag'Result (I) = (T (I) xor B (I)));

   --  Extract a full 16-byte block from a byte sequence slice.
   function To_Block (S : Byte_Seq) return Block_128
     with Global => null,
          Pre    => S'Length = 16,
          Post   => (for all I in 0 .. 15 => To_Block'Result (I) = S (S'First + I));

   --  Counter tweak: Prefix in the top nibble of byte 0, Ctr packed
   --  big-endian into the low 124 bits. Ctr : Natural always fits in the
   --  last 4 bytes; the remaining high-order bits of the 124-bit field are
   --  zero (Natural'Last << 2**60, so no truncation vs the M-1 maxl bound).
   function Counter_Tweak (Prefix : Byte; Ctr : Natural) return Block_128
     with Global => null;

   --  Tag finalization tweak: 0001 || 0000 || N(120) (byte0 = 16#10#,
   --  bytes 1 .. 15 = the 15-byte nonce, byte-aligned since 120 bits = 15
   --  bytes exactly).
   function Finalize_Tweak (N : Nonce_120) return Block_128
     with Global => null,
          Post   => Finalize_Tweak'Result (0) = Prefix_Tag_Final
                    and then (for all I in Nonce_120'Range =>
                                Finalize_Tweak'Result (I + 1) = N (I));

   --  Keystream tweak: tagp xor int_128(Ctr), tagp = Tag with bit 7 of
   --  byte 0 forced to 1 (M-2).
   function Keystream_Tweak (Tag : Tag_128; Ctr : Natural) return Block_128
     with Global => null;

   --  Keystream block input: one zero byte followed by the 15-byte nonce.
   function Keystream_Input (N : Nonce_120) return Block_128
     with Global => null,
          Post   => Keystream_Input'Result (0) = 0
                    and then (for all I in Nonce_120'Range =>
                                Keystream_Input'Result (I + 1) = N (I));

   --  pad10 (M-1): partial block padded with a single 1 bit (byte 0x80)
   --  then zeros. Partial'Length in 1 .. 15 (a zero-length tail skips its
   --  block entirely and never calls Pad10 -- see M-1).
   function Pad10 (Partial : Byte_Seq) return Block_128
     with Global => null,
          Pre    => Partial'Length in 1 .. 15,
          Post   => (for all I in 0 .. Partial'Length - 1 =>
                       Pad10'Result (I) = Partial (Partial'First + I))
                    and then Pad10'Result (Partial'Length) = 16#80#;

end Deoxysii.Mode;
