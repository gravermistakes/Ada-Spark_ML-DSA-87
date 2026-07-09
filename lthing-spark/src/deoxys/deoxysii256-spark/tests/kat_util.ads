------------------------------------------------------------------------------
--  Kat_Util — hex parsing helpers shared by the KAT test mains (not SPARK).
------------------------------------------------------------------------------

with Deoxysii; use Deoxysii;

package Kat_Util is

   --  "0a1b" -> (16#0A#, 16#1B#). S'Length must be even.
   function Hex_To_Bytes (S : String) return Byte_Seq;

   function To_Key_256   (S : String) return Key_256;
   function To_Block_128 (S : String) return Block_128;
   function To_Tag_128   (S : String) return Tag_128;
   --  First 15 bytes of the printed 16-byte nonce (the reference traces print
   --  one byte more than the 120-bit nonce actually consumed by the tweak).
   function To_Nonce_120 (S : String) return Nonce_120;

end Kat_Util;
