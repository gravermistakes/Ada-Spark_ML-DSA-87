--  rule30_salt.adb — Epoch Rule30 Salt Stream (License §1.12/§5A.3.1)
--  Epoch-milliseconds-only variant (no ambient-temperature input).
--  Usage: rule30_salt <epoch_ms>
pragma SPARK_Mode (Off);

with Ada.Text_IO;        use Ada.Text_IO;
with Ada.Command_Line;   use Ada.Command_Line;
with Interfaces;         use Interfaces;
with LTHING_Types;       use LTHING_Types;
with LTHING_Keccak;      use LTHING_Keccak;

procedure Rule30_Salt is

   Round_Count : constant := 512;
   Cell_Width  : constant := 257;
   Center_Cell : constant := Cell_Width / 2;  -- 128
   Raw_Len     : constant := Round_Count * 8;  -- 4096
   Salt_Len    : constant := 64;

   type Cell_Row is array (0 .. Cell_Width - 1) of Boolean;

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

   function Parse_U64 (S : String) return Unsigned_64 is
      V : Unsigned_64 := 0;
   begin
      for I in S'Range loop
         V := V * 10 + Unsigned_64 (Character'Pos (S (I)) - Character'Pos ('0'));
      end loop;
      return V;
   end Parse_U64;

   function U64_Image (V : Unsigned_64) return String is
      S : constant String := Unsigned_64'Image (V);
   begin
      if S'Length > 0 and then S (S'First) = ' ' then
         return S (S'First + 1 .. S'Last);
      end if;
      return S;
   end U64_Image;

   function Build_Seed (Epoch_MS : Unsigned_64) return Byte_Array is
      Label  : constant String := "epoch_ms=";
      Value  : constant String := U64_Image (Epoch_MS);
      Total  : constant Natural := Label'Length + Value'Length;
      Result : Byte_Array (0 .. Total - 1) := (others => 0);
   begin
      for I in 0 .. Label'Length - 1 loop
         Result (I) := Byte (Character'Pos (Label (Label'First + I)));
      end loop;
      for I in 0 .. Value'Length - 1 loop
         Result (Label'Length + I) :=
           Byte (Character'Pos (Value (Value'First + I)));
      end loop;
      return Result;
   end Build_Seed;

   procedure Evolve
     (Seed_Bytes : Byte_Array;
      Raw        : out Byte_Array)
   is
      Row     : Cell_Row := (others => False);
      New_Row : Cell_Row;
      Has_Any : Boolean := False;
      Bit_Idx : Natural := 0;
   begin
      Raw := (others => 0);

      for S in Seed_Bytes'Range loop
         exit when Bit_Idx >= Cell_Width;
         for I in reverse 0 .. 7 loop
            exit when Bit_Idx >= Cell_Width;
            Row (Bit_Idx) := (Shift_Right (Seed_Bytes (S), I) and 1) = 1;
            Bit_Idx := Bit_Idx + 1;
         end loop;
      end loop;

      for I in Row'Range loop
         if Row (I) then Has_Any := True; exit; end if;
      end loop;
      if not Has_Any then
         Row (Center_Cell) := True;
      end if;

      for R in 0 .. Round_Count - 1 loop
         declare
            Win_Start : constant Natural := Center_Cell - 32;
            Chunk_Off : constant Natural := R * 8;
         begin
            for I in 0 .. 63 loop
               if Row (Win_Start + I) then
                  Raw (Chunk_Off + I / 8) :=
                    Raw (Chunk_Off + I / 8) or
                    Shift_Left (Byte'(1), 7 - (I mod 8));
               end if;
            end loop;
         end;

         for I in Row'Range loop
            declare
               L_Idx : constant Natural :=
                 (if I > 0 then I - 1 else Cell_Width - 1);
               R_Idx : constant Natural :=
                 (if I < Cell_Width - 1 then I + 1 else 0);
               Left  : constant Byte := (if Row (L_Idx) then 1 else 0);
               Ctr   : constant Byte := (if Row (I) then 1 else 0);
               Right : constant Byte := (if Row (R_Idx) then 1 else 0);
               Pat   : constant Natural :=
                 Natural (Shift_Left (Left, 2) or Shift_Left (Ctr, 1) or Right);
            begin
               New_Row (I) := (Shift_Right (Byte'(16#1E#), Pat) and 1) = 1;
            end;
         end loop;
         Row := New_Row;
      end loop;
   end Evolve;

begin
   if Argument_Count < 1 then
      Put_Line (Standard_Error, "Usage: rule30_salt <epoch_ms>");
      Set_Exit_Status (Failure);
      return;
   end if;

   declare
      Epoch_MS : constant Unsigned_64 := Parse_U64 (Argument (1));
      Seed     : constant Byte_Array  := Build_Seed (Epoch_MS);
      Raw_CA   : Byte_Array (0 .. Raw_Len - 1);
      Salt     : Byte_Array (0 .. Salt_Len - 1);
      Epoch_BE : Byte_Array (0 .. 7);
   begin
      Evolve (Seed, Raw_CA);

      Sponge (Input  => Raw_CA,
              Rate   => Rate_SHAKE256,
              Domain => Domain_SHAKE,
              Output => Salt);

      for I in 0 .. 7 loop
         Epoch_BE (I) := Byte (Shift_Right (Epoch_MS, (7 - I) * 8) and 16#FF#);
      end loop;

      Put ("epoch_ms="); Put_Line (U64_Image (Epoch_MS));
      Put ("salt_hex="); Put_Hex (Salt); New_Line;
      Put ("date_epoch_masked_hex=");
      for I in 0 .. 7 loop
         Put (Hex (Epoch_BE (I) xor Salt (I)));
      end loop;
      New_Line;
      Put_Line ("descriptor.algorithm_version=rule30-epoch-v1");
      Put_Line ("descriptor.rule30_round_count=512");
      Put_Line ("descriptor.cell_width=257");
      Put_Line ("descriptor.byte_extraction_rule=center-64-cells-per-round-MSB-first, SHAKE-256-condensed to requested length");
   end;
end Rule30_Salt;
