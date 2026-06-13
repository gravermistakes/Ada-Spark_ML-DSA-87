with LTHING_KAT_FFI;     use LTHING_KAT_FFI;
with LTHING_Types;      use LTHING_Types;
with Interfaces;        use Interfaces;
with Ada.Text_IO;       use Ada.Text_IO;

procedure Test_Keccak is

   function Hex_To_Bytes (Hex : String) return Byte_Array is
      Result : Byte_Array (1 .. Hex'Length / 2);
      Pos : Natural := Hex'First;
      Byte_Pos : Natural := Result'First;
      procedure Hex_Pair (Hi, Lo : Character; Byte_Out : out Unsigned_8) is
         Hi_Val, Lo_Val : Unsigned_8;
      begin
         case Hi is
            when '0' => Hi_Val := 0;
            when '1' => Hi_Val := 1;
            when '2' => Hi_Val := 2;
            when '3' => Hi_Val := 3;
            when '4' => Hi_Val := 4;
            when '5' => Hi_Val := 5;
            when '6' => Hi_Val := 6;
            when '7' => Hi_Val := 7;
            when '8' => Hi_Val := 8;
            when '9' => Hi_Val := 9;
            when 'a' | 'A' => Hi_Val := 10;
            when 'b' | 'B' => Hi_Val := 11;
            when 'c' | 'C' => Hi_Val := 12;
            when 'd' | 'D' => Hi_Val := 13;
            when 'e' | 'E' => Hi_Val := 14;
            when 'f' | 'F' => Hi_Val := 15;
            when others => Hi_Val := 0;
         end case;
         case Lo is
            when '0' => Lo_Val := 0;
            when '1' => Lo_Val := 1;
            when '2' => Lo_Val := 2;
            when '3' => Lo_Val := 3;
            when '4' => Lo_Val := 4;
            when '5' => Lo_Val := 5;
            when '6' => Lo_Val := 6;
            when '7' => Lo_Val := 7;
            when '8' => Lo_Val := 8;
            when '9' => Lo_Val := 9;
            when 'a' | 'A' => Lo_Val := 10;
            when 'b' | 'B' => Lo_Val := 11;
            when 'c' | 'C' => Lo_Val := 12;
            when 'd' | 'D' => Lo_Val := 13;
            when 'e' | 'E' => Lo_Val := 14;
            when 'f' | 'F' => Lo_Val := 15;
            when others => Lo_Val := 0;
         end case;
         Byte_Out := (Hi_Val * 16) + Lo_Val;
      end Hex_Pair;
   begin
      while Pos <= Hex'Last - 1 loop
         Hex_Pair (Hex (Pos), Hex (Pos + 1), Result (Byte_Pos));
         Pos := Pos + 2;
         Byte_Pos := Byte_Pos + 1;
      end loop;
      return Result;
   end Hex_To_Bytes;

   function Bytes_To_Hex (Bytes : Byte_Array) return String is
      Result : String (1 .. Bytes'Length * 2);
      Pos : Natural := Result'First;
      Hex_Chars : constant String := "0123456789abcdef";
   begin
      for B of Bytes loop
         Result (Pos) := Hex_Chars (Natural (B / 16) + 1);
         Result (Pos + 1) := Hex_Chars (Natural (B mod 16) + 1);
         Pos := Pos + 2;
      end loop;
      return Result;
   end Bytes_To_Hex;

   procedure Chk (Name : String; Got, Want : Byte_Array) is
      Match : Boolean := Got'Length = Want'Length;
   begin
      if Match then
         for I in Got'Range loop
            if Got (I) /= Want (I) then
               Match := False;
               exit;
            end if;
         end loop;
      end if;

      if Match then
         Put_Line ("[PASS] " & Name);
      else
         Put_Line ("[FAIL] " & Name);
         if Got'Length /= Want'Length then
            Put_Line ("  Length: got=" & Got'Length'Image & " want=" & Want'Length'Image);
         else
            Put_Line ("  Got:  " & Bytes_To_Hex (Got));
            Put_Line ("  Want: " & Bytes_To_Hex (Want));
         end if;
      end if;
   end Chk;

   Fails : Natural := 0;

   --  Test 1: keccak_f1600(all-zero) lane 0
   procedure Test_Keccak_F1600_Zero is
      State : Keccak_State := (others => 0);
   begin
      Keccak_F1600 (State);
      --  FIPS 202: all-zero input, lane 0 after permutation = 0xf1258f7940e1dde7
      if State (0) = 16#f1258f7940e1dde7# then
         Put_Line ("[PASS] keccak_f1600 (all-zero) lane 0");
      else
         Put_Line ("[FAIL] keccak_f1600 (all-zero) lane 0");
         Put_Line ("  Got:  0x" & Unsigned_64'Image (State (0)));
         Put_Line ("  Want: 0xf1258f7940e1dde7");
         Fails := Fails + 1;
      end if;
   end Test_Keccak_F1600_Zero;

   --  Test 2: SHAKE256("") 64B - FIPS 202 test vector
   procedure Test_SHAKE256_Empty_64B is
      State : Keccak_State := (others => 0);
      Empty : Byte_Array (1 .. 1) := (1 => 0);
      Output : Byte_Array (1 .. 64);
      --  FIPS 202 test vector from Appendix D.1
      Expected : constant Byte_Array := Hex_To_Bytes (
         "46b9dd2b0ba88d13235efc3ff991b247" &
         "cb3e345f8117f2a24ca206cdd0d4b1fa" &
         "3b3b59d4af57dc3f93ff87a6d0f8f447" &
         "fdb52e9f5b46d25f42f0c31fa72e5e87");
   begin
      SHAKE_Absorb (State, Empty, 0, 136);  --  SHAKE256 rate = 136
      SHAKE_Squeeze (State, Output, Output'Length, 136);
      Chk ("SHAKE256 empty 64B", Output, Expected);
      if Output /= Expected then Fails := Fails + 1; end if;
   end Test_SHAKE256_Empty_64B;

   --  Test 3: SHAKE256("abc") 32B
   procedure Test_SHAKE256_ABC_32B is
      State : Keccak_State := (others => 0);
      Input : constant Byte_Array := (Character'Pos ('a'),
                                     Character'Pos ('b'),
                                     Character'Pos ('c'));
      Output : Byte_Array (1 .. 32);
      --  FIPS 202 test vector
      Expected : constant Byte_Array := Hex_To_Bytes (
         "483366601360a8771c6863c99bf61ca0" &
         "1b3d2652d5acb500b58ae8d28aada4b5");
   begin
      SHAKE_Absorb (State, Input, Input'Length, 136);
      SHAKE_Squeeze (State, Output, Output'Length, 136);
      Chk ("SHAKE256 'abc' 32B", Output, Expected);
      if Output /= Expected then Fails := Fails + 1; end if;
   end Test_SHAKE256_ABC_32B;

   --  Test 4: SHAKE128("") 32B
   procedure Test_SHAKE128_Empty_32B is
      State : Keccak_State := (others => 0);
      Empty : Byte_Array (1 .. 1) := (1 => 0);
      Output : Byte_Array (1 .. 32);
      --  FIPS 202 test vector
      Expected : constant Byte_Array := Hex_To_Bytes (
         "7f9c2ba4e88f827d616198507f7d6ff5" &
         "971d57db2b6df269dcf763e44ec8e919");
   begin
      SHAKE_Absorb (State, Empty, 0, 168);  --  SHAKE128 rate = 168
      SHAKE_Squeeze (State, Output, Output'Length, 168);
      Chk ("SHAKE128 empty 32B", Output, Expected);
      if Output /= Expected then Fails := Fails + 1; end if;
   end Test_SHAKE128_Empty_32B;

   --  Test 5: SHAKE128("abc") 32B
   procedure Test_SHAKE128_ABC_32B is
      State : Keccak_State := (others => 0);
      Input : constant Byte_Array := (Character'Pos ('a'),
                                     Character'Pos ('b'),
                                     Character'Pos ('c'));
      Output : Byte_Array (1 .. 32);
      --  FIPS 202 test vector
      Expected : constant Byte_Array := Hex_To_Bytes (
         "5d169c16f57b53f64a88a53a8431659f" &
         "5c8aa75ee8264dcfc3edc17c3d37b6f3");
   begin
      SHAKE_Absorb (State, Input, Input'Length, 168);
      SHAKE_Squeeze (State, Output, Output'Length, 168);
      Chk ("SHAKE128 'abc' 32B", Output, Expected);
      if Output /= Expected then Fails := Fails + 1; end if;
   end Test_SHAKE128_ABC_32B;

begin
   Put_Line ("=== Keccak/SHAKE FIPS 202 KAT ===");
   New_Line;

   Test_Keccak_F1600_Zero;
   New_Line;
   Test_SHAKE256_Empty_64B;
   Test_SHAKE256_ABC_32B;
   New_Line;
   Test_SHAKE128_Empty_32B;
   Test_SHAKE128_ABC_32B;

   New_Line;
   if Fails = 0 then
      Put_Line ("=== ALL KECCAK TESTS PASSED ===");
   else
      Put_Line ("=== FAILURES:" & Fails'Image & " ===");
   end if;
end Test_Keccak;
