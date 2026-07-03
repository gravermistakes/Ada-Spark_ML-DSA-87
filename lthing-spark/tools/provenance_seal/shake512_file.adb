--  shake512_file.adb — print the SHAKE512 (LTHING_Hash) digest of a file as hex.
--  Usage: shake512_file <file>
pragma SPARK_Mode (Off);

with Ada.Text_IO;      use Ada.Text_IO;
with Ada.Command_Line; use Ada.Command_Line;
with Ada.Streams.Stream_IO;
with Interfaces;       use Interfaces;
with LTHING_Types;     use LTHING_Types;
with LTHING_Hash;

procedure Shake512_File is

   function Hex (B : Byte) return String is
      H  : constant String := "0123456789abcdef";
      Hi : constant Natural := Natural (Shift_Right (B, 4));
      Lo : constant Natural := Natural (B and 16#0F#);
   begin
      return H (Hi + 1) & H (Lo + 1);
   end Hex;

   function Read_File (Path : String) return Byte_Array is
      package SIO renames Ada.Streams.Stream_IO;
      F    : SIO.File_Type;
      Size : Natural;
   begin
      SIO.Open (F, SIO.In_File, Path);
      Size := Natural (SIO.Size (F));
      declare
         Buf   : Byte_Array (0 .. Size - 1) := (others => 0);
         Chunk : Ada.Streams.Stream_Element_Array
                   (1 .. Ada.Streams.Stream_Element_Offset (Size));
         Chunk_Last : Ada.Streams.Stream_Element_Offset;
      begin
         SIO.Read (F, Chunk, Chunk_Last);
         SIO.Close (F);
         for I in 1 .. Chunk_Last loop
            Buf (Natural (I) - 1) := Byte (Chunk (I));
         end loop;
         return Buf (0 .. Natural (Chunk_Last) - 1);
      end;
   end Read_File;

   Digest_Out : LTHING_Types.Digest;
begin
   if Argument_Count < 1 then
      Put_Line (Standard_Error, "Usage: shake512_file <file>");
      Set_Exit_Status (Failure);
      return;
   end if;

   declare
      Data : constant Byte_Array := Read_File (Argument (1));
   begin
      LTHING_Hash.SHAKE512 (Data, Digest_Out);
      for I in Digest_Out'Range loop
         Put (Hex (Digest_Out (I)));
      end loop;
      New_Line;
   end;
end Shake512_File;
