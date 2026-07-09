package body Kat_Util is

   function Nibble (C : Character) return Byte is
   begin
      case C is
         when '0' .. '9' => return Character'Pos (C) - Character'Pos ('0');
         when 'a' .. 'f' => return Character'Pos (C) - Character'Pos ('a') + 10;
         when 'A' .. 'F' => return Character'Pos (C) - Character'Pos ('A') + 10;
         when others     => raise Constraint_Error with "bad hex digit";
      end case;
   end Nibble;

   function Hex_To_Bytes (S : String) return Byte_Seq is
      R : Byte_Seq (0 .. S'Length / 2 - 1);
   begin
      for I in R'Range loop
         R (I) := Nibble (S (S'First + 2 * I)) * 16
                  or Nibble (S (S'First + 2 * I + 1));
      end loop;
      return R;
   end Hex_To_Bytes;

   function To_Key_256 (S : String) return Key_256 is
      B : constant Byte_Seq := Hex_To_Bytes (S);
      R : Key_256;
   begin
      for I in R'Range loop R (I) := B (I); end loop;
      return R;
   end To_Key_256;

   function To_Block_128 (S : String) return Block_128 is
      B : constant Byte_Seq := Hex_To_Bytes (S);
      R : Block_128;
   begin
      for I in R'Range loop R (I) := B (I); end loop;
      return R;
   end To_Block_128;

   function To_Tag_128 (S : String) return Tag_128 is
      B : constant Byte_Seq := Hex_To_Bytes (S);
      R : Tag_128;
   begin
      for I in R'Range loop R (I) := B (I); end loop;
      return R;
   end To_Tag_128;

   function To_Nonce_120 (S : String) return Nonce_120 is
      B : constant Byte_Seq := Hex_To_Bytes (S);
      R : Nonce_120;
   begin
      for I in R'Range loop R (I) := B (I); end loop;
      return R;
   end To_Nonce_120;

end Kat_Util;
