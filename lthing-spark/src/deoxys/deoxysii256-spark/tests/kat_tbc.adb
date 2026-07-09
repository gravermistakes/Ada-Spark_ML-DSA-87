------------------------------------------------------------------------------
--  kat_tbc — gate P1/P2: every raw Deoxys-BC-384 call lifted from the pinned
--  deoxysii256v141 verbose traces must reproduce through TBC_Encrypt_384.
--  Prints [PASS]/[FAIL] per vector; exit status Failure on any fail.
--  Run from the crate root: tests/vectors/deoxysii256v141-tbc-calls.txt
------------------------------------------------------------------------------

with Ada.Text_IO;         use Ada.Text_IO;
with Ada.Command_Line;    use Ada.Command_Line;
with Ada.Strings.Fixed;
with Deoxysii;            use Deoxysii;
with Deoxysii.TBC;
with Kat_Util;            use Kat_Util;

procedure Kat_TBC is
   F        : File_Type;
   Key_H    : String (1 .. 64);
   Tweak_H  : String (1 .. 32);
   PT_H     : String (1 .. 32);
   Have     : Natural := 0;      --  fields collected for current record
   N_Pass   : Natural := 0;
   N_Fail   : Natural := 0;

   function Val (Line : String) return String is
      P : constant Natural := Ada.Strings.Fixed.Index (Line, "= ");
   begin
      return Line (P + 2 .. Line'Last);
   end Val;
begin
   Open (F, In_File, "tests/vectors/deoxysii256v141-tbc-calls.txt");
   while not End_Of_File (F) loop
      declare
         Line : constant String := Get_Line (F);
      begin
         if Line'Length > 6 and then Line (1 .. 4) = "KEY " then
            Key_H := Val (Line); Have := Have + 1;
         elsif Line'Length > 8 and then Line (1 .. 6) = "TWEAK " then
            Tweak_H := Val (Line); Have := Have + 1;
         elsif Line'Length > 5 and then Line (1 .. 3) = "PT " then
            PT_H := Val (Line); Have := Have + 1;
         elsif Line'Length > 5 and then Line (1 .. 3) = "CT " then
            declare
               Got : constant Block_128 :=
                 Deoxysii.TBC.TBC_Encrypt_384
                   (Key       => To_Key_256 (Key_H),
                    Tweak     => To_Block_128 (Tweak_H),
                    Plaintext => To_Block_128 (PT_H));
               Want : constant Block_128 := To_Block_128 (Val (Line));
            begin
               if Got = Want then
                  N_Pass := N_Pass + 1;
               else
                  N_Fail := N_Fail + 1;
                  Put_Line ("[FAIL] tbc call" & Natural'Image (N_Pass + N_Fail));
               end if;
               Have := 0;
            end;
         end if;
      end;
   end loop;
   Close (F);

   Put_Line ("tbc calls:" & Natural'Image (N_Pass) & " passed,"
             & Natural'Image (N_Fail) & " failed");
   if N_Fail = 0 and then N_Pass > 0 then
      Put_Line ("[PASS] all TBC vectors");
   else
      Put_Line ("[FAIL] TBC KAT");
      Set_Exit_Status (Ada.Command_Line.Failure);
   end if;
end Kat_TBC;
