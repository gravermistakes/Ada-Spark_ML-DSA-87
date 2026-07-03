--  verify_seal65.adb — verify an ML-DSA-65 detached signature over a file.
--  Usage: verify_seal65 <file> <pk_hex> <sig_hex>
pragma SPARK_Mode (Off);

with Ada.Text_IO;        use Ada.Text_IO;
with Ada.Command_Line;   use Ada.Command_Line;
with Ada.Streams.Stream_IO;
with Interfaces;         use Interfaces;
with LTHING_Types;       use LTHING_Types;
with LTHING_MLDSA65;

procedure Verify_Seal65 is

   function Hex_Val (C : Character) return Unsigned_8 is
   begin
      case C is
         when '0' .. '9' => return Character'Pos (C) - Character'Pos ('0');
         when 'a' .. 'f' => return Character'Pos (C) - Character'Pos ('a') + 10;
         when 'A' .. 'F' => return Character'Pos (C) - Character'Pos ('A') + 10;
         when others     => return 0;
      end case;
   end Hex_Val;

   function From_Hex (S : String; Len : Natural) return Byte_Array is
      R : Byte_Array (0 .. Len - 1) := (others => 0);
   begin
      for I in 0 .. Len - 1 loop
         R (I) := Byte (Hex_Val (S (S'First + 2 * I)) * 16
                         + Hex_Val (S (S'First + 2 * I + 1)));
      end loop;
      return R;
   end From_Hex;

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

   Ctx : constant Byte_Array (1 .. 0) := (others => 0);

begin
   if Argument_Count < 3 then
      Put_Line (Standard_Error, "Usage: verify_seal65 <file> <pk_hex> <sig_hex>");
      Set_Exit_Status (Failure);
      return;
   end if;

   declare
      Doc : constant Byte_Array := Read_File (Argument (1));
      PK  : constant LTHING_MLDSA65.Public_Key :=
              LTHING_MLDSA65.Public_Key
                (From_Hex (Argument (2), LTHING_MLDSA65.PK_Bytes));
      Sig : constant LTHING_MLDSA65.Signature :=
              LTHING_MLDSA65.Signature
                (From_Hex (Argument (3), LTHING_MLDSA65.Sig_Bytes));
      Ok  : Boolean;
   begin
      Ok := LTHING_MLDSA65.Verify (PK, Doc, Ctx, Sig);
      if Ok then
         Put_Line ("ACCEPT");
         Set_Exit_Status (Success);
      else
         Put_Line ("REJECT");
         Set_Exit_Status (Failure);
      end if;
   end;
end Verify_Seal65;
