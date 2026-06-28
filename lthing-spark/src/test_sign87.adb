--  test_sign87.adb — round-trip test for ML-DSA-87 sign + verify.
--  Tests:
--    1. determinism: same passphrase+message gives same signature
--    2. round-trip: MLDSA87.Verify(pk, msg, ctx, Sign(sk, msg, ctx)) = True
--    3. tamper-reject: flipping sig byte 0 causes Verify to return False
--    4. wrong-key reject: key from different passphrase fails to verify
pragma SPARK_Mode (Off);

with Ada.Text_IO;      use Ada.Text_IO;
with Ada.Command_Line; use Ada.Command_Line;
with Interfaces;       use Interfaces;
with LTHING_Types;     use LTHING_Types;
with LTHING_Keccak;
with LTHING_MLDSA87;
with LTHING_MLDSA87_Sign;

procedure Test_Sign87 is

   Passed : Boolean := True;

   procedure Check (Name : String; Result : Boolean) is
   begin
      if Result then
         Put_Line ("[PASS] " & Name);
      else
         Put_Line ("[FAIL] " & Name);
         Passed := False;
      end if;
   end Check;

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

   Seed1 : constant Byte_Array := Derive_Seed ("needmldsa87encoder");
   Seed2 : constant Byte_Array := Derive_Seed ("differentpassphrase");

   PK1, PK2 : LTHING_MLDSA87.Public_Key;
   SK1, SK2 : LTHING_MLDSA87_Sign.Secret_Key;
   Sig1a, Sig1b : LTHING_MLDSA87.Signature;
   Ok : Boolean;

   Msg : constant Byte_Array (0 .. 6) :=
     (72, 101, 108, 108, 111, 33, 10);  --  "Hello!\n"
   Ctx : constant Byte_Array (1 .. 0) := (others => 0);  --  empty context

begin
   LTHING_MLDSA87_Sign.Key_Gen (Seed1, PK1, SK1);
   LTHING_MLDSA87_Sign.Key_Gen (Seed2, PK2, SK2);

   --  1. Sign twice with same key+message
   LTHING_MLDSA87_Sign.Sign (SK1, Msg, Ctx, Sig1a, Ok);
   Check ("sign-ok-first", Ok);

   LTHING_MLDSA87_Sign.Sign (SK1, Msg, Ctx, Sig1b, Ok);
   Check ("sign-ok-second", Ok);

   --  2. Determinism: same inputs produce same signature
   Check ("determinism", Sig1a = Sig1b);

   --  3. Round-trip
   Check ("verify-round-trip",
          LTHING_MLDSA87.Verify (PK1, Msg, Ctx, Sig1a));

   --  4. Tamper-reject: flip first byte of signature
   declare
      Bad_Sig : LTHING_MLDSA87.Signature := Sig1a;
   begin
      Bad_Sig (0) := Bad_Sig (0) xor 16#FF#;
      Check ("tamper-reject",
             not LTHING_MLDSA87.Verify (PK1, Msg, Ctx, Bad_Sig));
   end;

   --  5. Wrong-key reject
   Check ("wrong-key-reject",
          not LTHING_MLDSA87.Verify (PK2, Msg, Ctx, Sig1a));

   if not Passed then
      Set_Exit_Status (Failure);
   end if;
end Test_Sign87;
