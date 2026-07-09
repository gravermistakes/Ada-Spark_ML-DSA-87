------------------------------------------------------------------------------
--  Deoxysii.Mode — body. Pure block/tweak algebra, no TBC calls here.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

package body Deoxysii.Mode is

   function Xor_Block (A, B : Block_128) return Block_128 is
      R : Block_128 := (others => 0);
   begin
      for I in Block_128'Range loop
         R (I) := A (I) xor B (I);
         pragma Loop_Invariant
           (for all K in 0 .. I => R (K) = (A (K) xor B (K)));
      end loop;
      return R;
   end Xor_Block;

   function Xor_Tag (T : Tag_128; B : Block_128) return Tag_128 is
      R : Tag_128 := (others => 0);
   begin
      for I in Tag_128'Range loop
         R (I) := T (I) xor B (I);
         pragma Loop_Invariant
           (for all K in 0 .. I => R (K) = (T (K) xor B (K)));
      end loop;
      return R;
   end Xor_Tag;

   function To_Block (S : Byte_Seq) return Block_128 is
      R : Block_128 := (others => 0);
   begin
      for I in 0 .. 15 loop
         R (I) := S (S'First + I);
         pragma Loop_Invariant
           (for all K in 0 .. I => R (K) = S (S'First + K));
      end loop;
      return R;
   end To_Block;

   function Counter_Tweak (Prefix : Byte; Ctr : Natural) return Block_128 is
      R : Block_128 := (others => 0);
      C : Natural := Ctr;
   begin
      --  Big-endian pack Ctr into the last 4 bytes (12 .. 15); the higher
      --  bytes of the 124-bit counter field (byte 0's low nibble and bytes
      --  1 .. 11) stay zero because Ctr : Natural <= Natural'Last fits in
      --  32 bits, far below the field's 124-bit width.
      for I in reverse 12 .. 15 loop
         R (I) := Byte (C mod 256);
         C := C / 256;
      end loop;
      R (0) := R (0) or Prefix;
      return R;
   end Counter_Tweak;

   function Finalize_Tweak (N : Nonce_120) return Block_128 is
      R : Block_128 := (others => 0);
   begin
      R (0) := Prefix_Tag_Final;
      for I in Nonce_120'Range loop
         R (I + 1) := N (I);
         pragma Loop_Invariant
           (R (0) = Prefix_Tag_Final
            and then (for all K in 0 .. I => R (K + 1) = N (K)));
      end loop;
      return R;
   end Finalize_Tweak;

   function Keystream_Tweak (Tag : Tag_128; Ctr : Natural) return Block_128 is
      Tagp : Block_128 := (others => 0);
   begin
      for I in Tag_128'Range loop
         Tagp (I) := Tag (I);
         pragma Loop_Invariant (for all K in 0 .. I => Tagp (K) = Tag (K));
      end loop;
      Tagp (0) := Tagp (0) or 16#80#;
      return Xor_Block (Tagp, Counter_Tweak (16#00#, Ctr));
   end Keystream_Tweak;

   function Keystream_Input (N : Nonce_120) return Block_128 is
      R : Block_128 := (others => 0);
   begin
      R (0) := 0;
      for I in Nonce_120'Range loop
         R (I + 1) := N (I);
         pragma Loop_Invariant
           (R (0) = 0 and then (for all K in 0 .. I => R (K + 1) = N (K)));
      end loop;
      return R;
   end Keystream_Input;

   function Pad10 (Partial : Byte_Seq) return Block_128 is
      R : Block_128 := (others => 0);
   begin
      for I in 0 .. Partial'Length - 1 loop
         R (I) := Partial (Partial'First + I);
         pragma Loop_Invariant
           (for all K in 0 .. I => R (K) = Partial (Partial'First + K));
      end loop;
      R (Partial'Length) := 16#80#;
      return R;
   end Pad10;

end Deoxysii.Mode;
