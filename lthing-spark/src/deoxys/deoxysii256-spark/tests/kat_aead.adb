------------------------------------------------------------------------------
--  kat_aead — gate G3 (and M1 over the oracle): the 8 pinned deoxysii256v141
--  AEAD vectors must encrypt to the exact CT/Tag and decrypt back (Ok=True,
--  Msg equal); additionally every vector is re-tried with a corrupted tag and
--  must be rejected (Ok=False) with Msg zeroized (fail-closed).
--  Prints [PASS]/[FAIL]; exit status Failure on any fail.
--  Run from the crate root: tests/vectors/deoxysii256v141-aead-kat.txt
------------------------------------------------------------------------------

with Ada.Text_IO;                  use Ada.Text_IO;
with Ada.Command_Line;             use Ada.Command_Line;
with Ada.Strings.Fixed;
with Ada.Strings.Unbounded;        use Ada.Strings.Unbounded;
with Deoxysii;                     use Deoxysii;
with Kat_Util;                     use Kat_Util;

procedure Kat_AEAD is
   F       : File_Type;
   Count_S : Unbounded_String := Null_Unbounded_String;
   Key_S, Nonce_S, AD_S, Msg_S, CT_S, Tag_S : Unbounded_String;
   N_Pass  : Natural := 0;
   N_Fail  : Natural := 0;

   function Val (Line : String) return String is
      P : constant Natural := Ada.Strings.Fixed.Index (Line, "=");
   begin
      if P = 0 or else P + 2 > Line'Last then
         return "";
      end if;
      return Line (P + 2 .. Line'Last);
   end Val;

   procedure Run_Vector is
      Key   : constant Key_256   := To_Key_256 (To_String (Key_S));
      Nonce : constant Nonce_120 := To_Nonce_120 (To_String (Nonce_S));
      AD    : constant Byte_Seq  := Hex_To_Bytes (To_String (AD_S));
      Msg   : constant Byte_Seq  := Hex_To_Bytes (To_String (Msg_S));
      CTx   : constant Byte_Seq  := Hex_To_Bytes (To_String (CT_S));
      Tag   : constant Tag_128   := To_Tag_128 (To_String (Tag_S));
      Lbl   : constant String    := " vector " & To_String (Count_S);

      Got_CT  : Byte_Seq (0 .. Msg'Length - 1);
      Got_Tag : Tag_128;
      Back    : Byte_Seq (0 .. Msg'Length - 1);
      Ok      : Boolean;
      Bad_Tag : Tag_128 := Tag;
      Vector_Ok : Boolean := True;
   begin
      --  Encrypt: exact CT and Tag.
      Encrypt (Key, Nonce, AD, Msg, Got_CT, Got_Tag);
      if Got_Tag /= Tag then
         Put_Line ("[FAIL]" & Lbl & ": tag mismatch"); Vector_Ok := False;
      end if;
      if Msg'Length > 0 and then Got_CT /= CTx then
         Put_Line ("[FAIL]" & Lbl & ": ciphertext mismatch"); Vector_Ok := False;
      end if;

      --  Decrypt: accepts and round-trips.
      Decrypt (Key, Nonce, AD, CTx, Tag, Back, Ok);
      if not Ok then
         Put_Line ("[FAIL]" & Lbl & ": decrypt rejected valid input");
         Vector_Ok := False;
      elsif Msg'Length > 0 and then Back /= Msg then
         Put_Line ("[FAIL]" & Lbl & ": decrypt round-trip mismatch");
         Vector_Ok := False;
      end if;

      --  Forgery: corrupted tag must be rejected with zeroized Msg.
      Bad_Tag (15) := Bad_Tag (15) xor 16#01#;
      Decrypt (Key, Nonce, AD, CTx, Bad_Tag, Back, Ok);
      if Ok then
         Put_Line ("[FAIL]" & Lbl & ": forgery accepted"); Vector_Ok := False;
      else
         for B of Back loop
            if B /= 0 then
               Put_Line ("[FAIL]" & Lbl & ": forgery path leaked plaintext");
               Vector_Ok := False;
               exit;
            end if;
         end loop;
      end if;

      if Vector_Ok then
         N_Pass := N_Pass + 1;
         Put_Line ("[PASS]" & Lbl);
      else
         N_Fail := N_Fail + 1;
      end if;
   end Run_Vector;
begin
   Open (F, In_File, "tests/vectors/deoxysii256v141-aead-kat.txt");
   while not End_Of_File (F) loop
      declare
         Line : constant String := Get_Line (F);
      begin
         if Line'Length >= 5 and then Line (1 .. 5) = "COUNT" then
            Count_S := To_Unbounded_String (Val (Line));
         elsif Line'Length >= 4 and then Line (1 .. 4) = "KEY " then
            Key_S := To_Unbounded_String (Val (Line));
         elsif Line'Length >= 5 and then Line (1 .. 5) = "NONCE" then
            Nonce_S := To_Unbounded_String (Val (Line));
         elsif Line'Length >= 3 and then Line (1 .. 3) = "AD " then
            AD_S := To_Unbounded_String (Val (Line));
         elsif Line'Length >= 4 and then Line (1 .. 4) = "MSG " then
            Msg_S := To_Unbounded_String (Val (Line));
         elsif Line'Length >= 3 and then Line (1 .. 3) = "CT " then
            CT_S := To_Unbounded_String (Val (Line));
         elsif Line'Length >= 4 and then Line (1 .. 4) = "TAG " then
            Tag_S := To_Unbounded_String (Val (Line));
            Run_Vector;
         end if;
      end;
   end loop;
   Close (F);

   Put_Line ("aead vectors:" & Natural'Image (N_Pass) & " passed,"
             & Natural'Image (N_Fail) & " failed");
   if N_Fail = 0 and then N_Pass > 0 then
      Put_Line ("[PASS] all AEAD vectors + forgery rejection");
   else
      Put_Line ("[FAIL] AEAD KAT");
      Set_Exit_Status (Ada.Command_Line.Failure);
   end if;
end Kat_AEAD;
