--  test_judicial87_sign — genuinely signed ML-DSA-87 (suite 0x0002) judicial
--  envelope: end-to-end accept + tamper reject (full relational gate).
--
--  Complements test_judicial87 (T1-T6, seal-level gates) with the T7 gate
--  now that LTHING_MLDSA87_Sign is available:
--
--    T7: Key_Gen + Sign produce a real ML-DSA-87 sig over header‖body‖seal
--        -> Parse_And_Verify returns Verified/Trusted.
--    T8: flip one signature byte in the verified envelope
--        -> Signature_Invalid (fail-closed).
pragma SPARK_Mode (Off);

with LTHING_Types;      use LTHING_Types;
with LTHING_Judicial;   use LTHING_Judicial;
with LTHING_Keccak;
with LTHING_MLDSA87;    use LTHING_MLDSA87;
with LTHING_MLDSA87_Sign; use LTHING_MLDSA87_Sign;
with Interfaces;        use Interfaces;
with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Command_Line;  use Ada.Command_Line;

procedure Test_Judicial87_Sign is

   Sig_Bytes_87 : constant := LTHING_MLDSA87.Sig_Bytes;   --  4627
   PK_Bytes_87  : constant := LTHING_MLDSA87.PK_Bytes;    --  2592

   Fails : Natural := 0;

   procedure Chk (Name : String; Cond : Boolean) is
   begin
      if Cond then Put_Line ("[PASS] " & Name);
      else Put_Line ("[FAIL] " & Name); Fails := Fails + 1; end if;
   end Chk;

   function L512 (Input : Byte_Array) return Digest is
      Buf : Byte_Array (0 .. 63) := (others => 0);
      R   : Digest := (others => 0);
   begin
      LTHING_Keccak.Sponge
        (Input  => Input, Rate => LTHING_Keccak.Rate_SHA3_512,
         Domain => LTHING_Keccak.Domain_SHAKE, Output => Buf);
      for I in Digest_Index loop R (I) := Buf (I); end loop;
      return R;
   end L512;

   procedure Put_U16 (D : in out Byte_Array; Off : Natural; V : Unsigned_16) is
   begin
      D (Off)     := Byte (Shift_Right (V, 8) and 16#FF#);
      D (Off + 1) := Byte (V and 16#FF#);
   end Put_U16;

   procedure Put_U32 (D : in out Byte_Array; Off : Natural; V : Unsigned_32) is
   begin
      D (Off)     := Byte (Shift_Right (V, 24) and 16#FF#);
      D (Off + 1) := Byte (Shift_Right (V, 16) and 16#FF#);
      D (Off + 2) := Byte (Shift_Right (V, 8)  and 16#FF#);
      D (Off + 3) := Byte (V and 16#FF#);
   end Put_U32;

   --  §2/§3 header for suite 0x0002 (ML-DSA-87) into D(0..39).
   procedure Put_Header_87
     (D : in out Byte_Array; Body_Len, Seal_Len : Natural)
   is
      Pre : constant Byte_Array (0 .. 13) :=
        (16#00#, 16#00#, 16#00#, 16#0B#, 16#0D#, 16#EE#, 16#D0#,
         16#00#, 16#00#, 16#00#, 16#04#, 16#A4#, 16#40#, 16#10#);
   begin
      for I in Pre'Range loop D (I) := Pre (I); end loop;
      Put_U16 (D, 14, 16#0002#);
      for I in 16 .. 23 loop D (I) := 0; end loop;
      Put_U32 (D, 24, Unsigned_32 (Body_Len));
      Put_U32 (D, 28, Unsigned_32 (Seal_Len));
      Put_U32 (D, 32, Unsigned_32 (Sig_Bytes_87));
      Put_U32 (D, 36, 0);
   end Put_Header_87;

   --  Build a complete genesis envelope (suite 0x0002) with correct seal hashes.
   --  Sig region is zeroed; caller fills it in.
   procedure Build_Genesis_87
     (Body_Byte : Byte; Env : out Byte_Array; Last : out Natural)
   is
      Body_Len : constant := 8;
      Seal_Len : constant := 196;
      Body_Off : constant := 40;
      Seal_Off : constant := Body_Off + Body_Len;
      Sig_Off  : constant := Seal_Off + Seal_Len;
      Art, Chain, Sid : Digest;
      Prev : constant Byte_Array (0 .. 63) := (others => 0);
   begin
      Env := (others => 0);
      Put_Header_87 (Env, Body_Len, Seal_Len);
      for I in 0 .. Body_Len - 1 loop Env (Body_Off + I) := Body_Byte; end loop;

      Art := L512 (Env (Body_Off .. Body_Off + Body_Len - 1));
      declare
         CBuf : Byte_Array (0 .. 127) := (others => 0);
      begin
         for I in 0 .. 63 loop CBuf (I)      := Prev (I); end loop;
         for I in 0 .. 63 loop CBuf (64 + I) := Art  (I); end loop;
         Chain := L512 (CBuf);
      end;

      Put_U16 (Env, Seal_Off, 0);
      for I in 0 .. 63 loop Env (Seal_Off + 2 + I)   := Art   (I); end loop;
      for I in 0 .. 63 loop Env (Seal_Off + 66 + I)  := Chain (I); end loop;
      Env (Seal_Off + 130) := 16#00#;
      Env (Seal_Off + 131) := 16#00#;

      declare
         SBuf : Byte_Array (0 .. 130) := (others => 0);
      begin
         SBuf (0) := Env (Seal_Off); SBuf (1) := Env (Seal_Off + 1);
         for I in 0 .. 63 loop SBuf (2 + I)  := Art   (I); end loop;
         for I in 0 .. 63 loop SBuf (66 + I) := Chain (I); end loop;
         SBuf (130) := 16#00#;
         Sid := L512 (SBuf);
      end;
      for I in 0 .. 63 loop Env (Seal_Off + 132 + I) := Sid (I); end loop;

      Last := Sig_Off + Sig_Bytes_87 - 1;
   end Build_Genesis_87;

   --  40 + 8 + 196 + 4627 = 4871; round up to 8 KiB.
   Env  : Byte_Array (0 .. 8191) := (others => 0);
   Last : Natural;
   Zero : constant Digest := (others => 0);
   R    : Verified_Record;

begin
   declare
      Seed    : Byte_Array (0 .. 31);
      GPK     : Public_Key;
      SK      : Secret_Key;
      Sg      : Signature;
      Ok      : Boolean;
      Sig_Off : constant := 40 + 8 + 196;          --  header + body + seal = 244
      Empty   : constant Byte_Array (1 .. 0) := (others => 0);
   begin
      for I in Seed'Range loop Seed (I) := Byte (I * 7 + 11); end loop;
      Key_Gen (Seed, GPK, SK);

      Build_Genesis_87 (16#5A#, Env, Last);
      Sign (SK, Env (0 .. Sig_Off - 1), Empty, Sg, Ok);
      for I in 0 .. Sig_Bytes_87 - 1 loop
         Env (Sig_Off + I) := Sg (I);
      end loop;

      --  T7: real ML-DSA-87 signature -> Verified/Trusted.
      Parse_And_Verify (Env (0 .. Last), Zero, GPK, R);
      Chk ("87: genuine signed genesis envelope -> Verified/Trusted",
           Ok and then R.Trusted and then R.Status = Verified);

      --  T8: flip one signature byte -> Signature_Invalid (fail-closed).
      Env (Sig_Off + 50) := Env (Sig_Off + 50) xor 1;
      Parse_And_Verify (Env (0 .. Last), Zero, GPK, R);
      Chk ("87: tampered signature -> Signature_Invalid",
           (not R.Trusted) and then R.Status = Signature_Invalid);
   end;

   New_Line;
   if Fails = 0 then
      Put_Line ("JUDICIAL87-SIGN GATE PASSED (genuine sign + tamper reject)");
   else
      Put_Line ("JUDICIAL87-SIGN FAILURES:" & Fails'Image);
      Set_Exit_Status (Failure);
   end if;
end Test_Judicial87_Sign;
