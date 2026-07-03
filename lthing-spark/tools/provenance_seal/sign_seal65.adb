--  sign_seal65.adb — ML-DSA-65 detached signature over a file, fresh seed
--  sourced from the OS CSPRNG each run (the private key/seed is never
--  printed or persisted -- only the public key and signature are output).
--  Usage: sign_seal65 <file>
--  Output: hex public key, then hex signature, one per line.
pragma SPARK_Mode (Off);

with Ada.Text_IO;        use Ada.Text_IO;
with Ada.Command_Line;   use Ada.Command_Line;
with Ada.Streams.Stream_IO;
with Interfaces;         use Interfaces;
with LTHING_Types;       use LTHING_Types;
with LTHING_MLDSA65;
with LTHING_MLDSA_Sign;

procedure Sign_Seal65 is

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

   --  Fresh 32-byte seed from the OS CSPRNG (/dev/urandom). Never printed.
   function Random_Seed return Byte_Array is
      package SIO renames Ada.Streams.Stream_IO;
      F    : SIO.File_Type;
      Seed : Byte_Array (0 .. 31) := (others => 0);
      Chunk : Ada.Streams.Stream_Element_Array (1 .. 32);
      Chunk_Last : Ada.Streams.Stream_Element_Offset;
   begin
      SIO.Open (F, SIO.In_File, "/dev/urandom");
      SIO.Read (F, Chunk, Chunk_Last);
      SIO.Close (F);
      for I in 1 .. Chunk_Last loop
         Seed (Natural (I) - 1) := Byte (Chunk (I));
      end loop;
      return Seed;
   end Random_Seed;

   PK  : LTHING_MLDSA65.Public_Key;
   SK  : LTHING_MLDSA_Sign.Secret_Key;
   Sig : LTHING_MLDSA65.Signature;
   Ok  : Boolean;
   Ctx : constant Byte_Array (1 .. 0) := (others => 0);  --  empty context

begin
   if Argument_Count < 1 then
      Put_Line (Standard_Error, "Usage: sign_seal65 <file>");
      Set_Exit_Status (Failure);
      return;
   end if;

   declare
      Seed : constant Byte_Array := Random_Seed;
      Doc  : constant Byte_Array := Read_File (Argument (1));
   begin
      LTHING_MLDSA_Sign.Key_Gen (Seed, PK, SK);
      LTHING_MLDSA_Sign.Sign (SK, Doc, Ctx, Sig, Ok);

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
end Sign_Seal65;
