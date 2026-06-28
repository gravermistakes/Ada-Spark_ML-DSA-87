--  sign_doc87.adb — sign a file with ML-DSA-87, key derived from passphrase.
--  Usage: ./sign_doc87 <file_path> <passphrase>
--  Output: hex public key, then hex signature, one per line.
pragma SPARK_Mode (Off);

with Ada.Text_IO;        use Ada.Text_IO;
with Ada.Command_Line;   use Ada.Command_Line;
with Ada.Streams.Stream_IO;
with Interfaces;         use Interfaces;
with LTHING_Types;       use LTHING_Types;
with LTHING_Keccak;
with LTHING_MLDSA87;
with LTHING_MLDSA87_Sign;

procedure Sign_Doc87 is

   function Hex (B : Byte) return String is
      H  : constant String := "0123456789abcdef";
      Hi : constant Natural := Natural (Shift_Right (B, 4));
      Lo : constant Natural := Natural (B and 16#0F#);
   begin
      return H (Hi + 1) & H (Lo + 1);
   end Hex;

   procedure Put_Hex (A : Byte_Array) is
   begin
      for I in A'Range loop
         Put (Hex (A (I)));
      end loop;
   end Put_Hex;

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

   --  Derive 32-byte seed from passphrase via SHAKE256.
   function Derive_Seed (Passphrase : String) return Byte_Array is
      Input : Byte_Array (0 .. Passphrase'Length - 1);
      Seed  : Byte_Array (0 .. 31) := (others => 0);
   begin
      for I in Passphrase'Range loop
         Input (I - Passphrase'First) := Byte (Character'Pos (Passphrase (I)));
      end loop;
      LTHING_Keccak.Sponge
        (Input  => Input,
         Rate   => LTHING_Keccak.Rate_SHAKE256,
         Domain => LTHING_Keccak.Domain_SHAKE,
         Output => Seed);
      return Seed;
   end Derive_Seed;

   PK  : LTHING_MLDSA87.Public_Key;
   SK  : LTHING_MLDSA87_Sign.Secret_Key;
   Sig : LTHING_MLDSA87.Signature;
   Ok  : Boolean;
   Ctx : constant Byte_Array (1 .. 0) := (others => 0);  --  empty context

begin
   if Argument_Count < 2 then
      Put_Line (Standard_Error, "Usage: sign_doc87 <file> <passphrase>");
      Set_Exit_Status (Failure);
      return;
   end if;

   declare
      Seed : constant Byte_Array := Derive_Seed (Argument (2));
      Doc  : constant Byte_Array := Read_File (Argument (1));
   begin
      LTHING_MLDSA87_Sign.Key_Gen (Seed, PK, SK);
      LTHING_MLDSA87_Sign.Sign (SK, Doc, Ctx, Sig, Ok);

      if not Ok then
         Put_Line (Standard_Error, "SIGN FAILED (rejection loop exhausted)");
         Set_Exit_Status (Failure);
         return;
      end if;

      Put_Hex (Byte_Array (PK));
      New_Line;
      Put_Hex (Byte_Array (Sig));
      New_Line;
   end;
end Sign_Doc87;
