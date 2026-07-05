------------------------------------------------------------------------------
--  kat_aead — gate M1 for Deoxysii.Mode (SCT-2 AEAD mode logic).
--
--  Vectors: tests/vectors/m1_oracle_traces.json. Each vector's tbc_calls is
--  the exact, ordered sequence of (tweak, plaintext) -> ciphertext lookups
--  a genuine Deoxys-BC-384 forward oracle made while a real reference
--  implementation (github.com/oasisprotocol/deoxysii) sealed that specific
--  (key, nonce, AD, msg) -- traced by MAIN from a real Seal() run, not
--  fabricated. This test main pins a lookup-table oracle built from those
--  exact traces and instantiates Deoxysii.Mode with it (Deoxysii.Mode is
--  generic precisely so it can be driven by this test-only oracle here,
--  while production code in Deoxysii.adb instantiates the same generic
--  with the real Deoxysii.TBC.TBC_Encrypt_384).
--
--  This file is test-only scaffolding, not part of the graded SPARK units
--  (deoxysii-mode.adb / deoxysii.adb / deoxysii-ct.adb); it is deliberately
--  ordinary Ada (no SPARK_Mode) since its job is running the mode logic
--  against pinned data, not being proved itself.
--
--  Prints [PASS]/[FAIL] per vector and calls Set_Exit_Status(Failure) on
--  any fail, matching the convention used in lthing-spark/src/test_*.adb
--  and tests/kat_tbc.adb.
------------------------------------------------------------------------------

with Ada.Text_IO;      use Ada.Text_IO;
with Ada.Command_Line; use Ada.Command_Line;
with Deoxysii;         use Deoxysii;
with Deoxysii.Mode;

procedure Kat_Aead is

   Fails : Natural := 0;

   ---------------------------------------------------------------------
   --  Hex <-> bytes helpers
   ---------------------------------------------------------------------

   function Hex_Nibble (C : Character) return Byte is
     (case C is
        when '0' .. '9' => Byte (Character'Pos (C) - Character'Pos ('0')),
        when 'a' .. 'f' => Byte (Character'Pos (C) - Character'Pos ('a') + 10),
        when 'A' .. 'F' => Byte (Character'Pos (C) - Character'Pos ('A') + 10),
        when others     => 0);

   function Hex_To_Bytes (S : String) return Byte_Seq is
      R : Byte_Seq (0 .. S'Length / 2 - 1);
   begin
      for I in R'Range loop
         R (I) := Hex_Nibble (S (S'First + 2 * I)) * 16
                    + Hex_Nibble (S (S'First + 2 * I + 1));
      end loop;
      return R;
   end Hex_To_Bytes;

   function Hex_To_Block (S : String) return Block_128 is
      B : constant Byte_Seq := Hex_To_Bytes (S);
      R : Block_128;
   begin
      for I in R'Range loop
         R (I) := B (I);
      end loop;
      return R;
   end Hex_To_Block;

   function Bytes_To_Hex (B : Byte_Seq) return String is
      Hex_Digits : constant String := "0123456789abcdef";
      S : String (1 .. 2 * B'Length);
   begin
      for I in 0 .. B'Length - 1 loop
         S (2 * I + 1) := Hex_Digits (Natural (B (B'First + I) / 16) + 1);
         S (2 * I + 2) := Hex_Digits (Natural (B (B'First + I) mod 16) + 1);
      end loop;
      return S;
   end Bytes_To_Hex;

   function Is_Zero (B : Byte_Seq) return Boolean is
     (for all E of B => E = 0);

   ---------------------------------------------------------------------
   --  Pinned oracle: exact (tweak, plaintext) -> ciphertext traces from
   --  tests/vectors/m1_oracle_traces.json, flattened across all 4 vectors
   --  (they share one key, so one flat table suffices).
   ---------------------------------------------------------------------

   type Trace_Entry is record
      Tweak, Plaintext, Ciphertext : String (1 .. 32);
   end record;

   Trace_Table : constant array (Positive range <>) of Trace_Entry := (
      1  => (Tweak => "10202122232425262728292a2b2c2d2e", Plaintext => "00000000000000000000000000000000", Ciphertext => "2b97bd77712f0cde975309959dfe1d7c"),
      2  => (Tweak => "20000000000000000000000000000000", Plaintext => "000102030405060708090a0b0c0d0e0f", Ciphertext => "c3c0818d8066d6642dfc4ccc9cc5478a"),
      3  => (Tweak => "00000000000000000000000000000000", Plaintext => "000102030405060708090a0b0c0d0e0f", Ciphertext => "a0122562c6af9b0a3710abee3218fbc6"),
      4  => (Tweak => "00000000000000000000000000000001", Plaintext => "101112131415161718191a1b1c1d1e1f", Ciphertext => "3d6afb9f8f1395ac17f23fb0c1c73bec"),
      5  => (Tweak => "10202122232425262728292a2b2c2d2e", Plaintext => "5eb85f70c9dad8c20d1ed8926f1a87a0", Ciphertext => "6549f9bf10acba0a451dbb2484a60d90"),
      6  => (Tweak => "e549f9bf10acba0a451dbb2484a60d90", Plaintext => "00202122232425262728292a2b2c2d2e", Ciphertext => "109e88158f33d9aae82f22a2ed24db2a"),
      7  => (Tweak => "e549f9bf10acba0a451dbb2484a60d91", Plaintext => "00202122232425262728292a2b2c2d2e", Ciphertext => "6f12de6a06bbec6e6a827daa9abfae90"),
      8  => (Tweak => "00000000000000000000000000000000", Plaintext => "15cd77732f9d0c4c6e581ef400876ad9", Ciphertext => "c3d6b9d111361493ac275bf0ec23d939"),
      9  => (Tweak => "00000000000000000000000000000001", Plaintext => "188c5b8850ebd38224da95d7cdc99f7a", Ciphertext => "1b9e87edf520949af04e08b4e7a08a07"),
      10 => (Tweak => "40000000000000000000000000000002", Plaintext => "cc800000000000000000000000000000", Ciphertext => "0f46dd25a3c7e1c0f9019f9c18d1769d"),
      11 => (Tweak => "10202122232425262728292a2b2c2d2e", Plaintext => "d70ee31947d161c9a568ccd8135225a3", Ciphertext => "5fa78d57308f19d0252072ee39df5ecc"),
      12 => (Tweak => "dfa78d57308f19d0252072ee39df5ecc", Plaintext => "00202122232425262728292a2b2c2d2e", Ciphertext => "f032a5d8ea2955eb583f6b9adae32934"),
      13 => (Tweak => "dfa78d57308f19d0252072ee39df5ecd", Plaintext => "00202122232425262728292a2b2c2d2e", Ciphertext => "f0e0530bacba0ef7f6f1249e5f0f1b1b"),
      14 => (Tweak => "dfa78d57308f19d0252072ee39df5ece", Plaintext => "00202122232425262728292a2b2c2d2e", Ciphertext => "4048ecffc81ede512f43b3a481bc43c0"),
      15 => (Tweak => "20000000000000000000000000000000", Plaintext => "000102030405060708090a0b0c0d0e0f", Ciphertext => "c3c0818d8066d6642dfc4ccc9cc5478a"),
      16 => (Tweak => "60000000000000000000000000000001", Plaintext => "10800000000000000000000000000000", Ciphertext => "26e8504c00956d73a4f6a1b04e6406fb"),
      17 => (Tweak => "00000000000000000000000000000000", Plaintext => "422857fb165af0a35c03199fb895604d", Ciphertext => "96e8e4ca609605e892aeae07538bf056"),
      18 => (Tweak => "00000000000000000000000000000001", Plaintext => "ca9cea6d788954962c419e0d5c225c03", Ciphertext => "73af90bb4f730818ddf0d1e180044abc"),
      19 => (Tweak => "40000000000000000000000000000002", Plaintext => "27800000000000000000000000000000", Ciphertext => "c7bc1cdd48edfdceae1eb2e40cfb3faf"),
      20 => (Tweak => "10202122232425262728292a2b2c2d2e", Plaintext => "c7d3b96de7fb4b29684a207e0dd5c434", Ciphertext => "0b3f10e3933c78190b24b33008bf80e9"),
      21 => (Tweak => "8b3f10e3933c78190b24b33008bf80e9", Plaintext => "00202122232425262728292a2b2c2d2e", Ciphertext => "3f5f75f8ec624e8a318e3947bd83517d"),
      22 => (Tweak => "8b3f10e3933c78190b24b33008bf80e8", Plaintext => "00202122232425262728292a2b2c2d2e", Ciphertext => "0c0650e1c9e78cd3ee68f26cf4d1173a"),
      23 => (Tweak => "8b3f10e3933c78190b24b33008bf80eb", Plaintext => "00202122232425262728292a2b2c2d2e", Ciphertext => "693d4bc78a402e1e1719e756d3bf1864")
   );

   Misses : Natural := 0;

   --  Lookup-table oracle: matches on the exact (tweak, plaintext) pair.
   --  On a miss (e.g. a tweak/plaintext pair produced only by a tampered,
   --  forged input that never occurred in the genuine trace) it returns a
   --  fixed, deterministic non-matching value -- this is exactly the
   --  "oracle lookup miss" case flagged in the task brief: the harness
   --  cannot look up a real ciphertext for inputs the pinned trace never
   --  covers, so it substitutes an arbitrary fixed block. That is provably
   --  *not* the real Deoxys-BC-384 output for that (tweak, plaintext) pair
   --  (this oracle is not the real cipher at all -- it is a finite pinned
   --  table), so any computation routed through a miss cannot reproduce a
   --  genuine tag, and fail-closed verification is exercised faithfully:
   --  Open() still must reject whenever the recomputed tag does not match
   --  the received tag, regardless of *why* the recomputation diverged.
   function Oracle_E (Key : Key_256; Tweak, Plaintext : Block_128) return Block_128 is
      pragma Unreferenced (Key);
      Tw_Hex : constant String := Bytes_To_Hex (Byte_Seq (Tweak));
      Pt_Hex : constant String := Bytes_To_Hex (Byte_Seq (Plaintext));
   begin
      for E of Trace_Table loop
         if E.Tweak = Tw_Hex and then E.Plaintext = Pt_Hex then
            return Hex_To_Block (E.Ciphertext);
         end if;
      end loop;
      Misses := Misses + 1;
      return (others => 16#FF#);
   end Oracle_E;

   package Test_Mode is new Deoxysii.Mode (Oracle_E);

   ---------------------------------------------------------------------
   --  Per-vector KAT: Seal(key,nonce,ad,msg) = sealed_hex, and
   --  Open(key,nonce,ad,ct,tag) recovers msg with Ok = True.
   ---------------------------------------------------------------------
   procedure Check_Vector
     (Name       : String;
      Key_Hex    : String;
      Nonce_Hex  : String;
      AD_Hex     : String;
      Msg_Hex    : String;
      Sealed_Hex : String)
   is
      Key   : constant Key_256   := Key_256 (Hex_To_Bytes (Key_Hex));
      Nonce : constant Nonce_120 := Nonce_120 (Hex_To_Bytes (Nonce_Hex));
      AD    : constant Byte_Seq  := Hex_To_Bytes (AD_Hex);
      Msg   : constant Byte_Seq  := Hex_To_Bytes (Msg_Hex);

      CT  : Byte_Seq (0 .. Msg'Length - 1);
      Tag : Tag_128;
   begin
      Test_Mode.Seal (Key, Nonce, AD, Msg, CT, Tag);

      declare
         Sealed_Got : constant String := Bytes_To_Hex (CT) & Bytes_To_Hex (Byte_Seq (Tag));
      begin
         if Sealed_Got = Sealed_Hex then
            Put_Line ("[PASS] " & Name & ": Seal -> " & Sealed_Got);
         else
            Put_Line ("[FAIL] " & Name & ": Seal mismatch");
            Put_Line ("       expected = " & Sealed_Hex);
            Put_Line ("       got      = " & Sealed_Got);
            Fails := Fails + 1;
         end if;
      end;

      declare
         Recovered : Byte_Seq (0 .. CT'Length - 1);
         Ok        : Boolean;
      begin
         Test_Mode.Open (Key, Nonce, AD, CT, Tag, Recovered, Ok);
         if Ok and then Recovered = Msg then
            Put_Line ("[PASS] " & Name & ": Open -> Ok, Msg recovered");
         else
            Put_Line ("[FAIL] " & Name & ": Open mismatch (Ok="
                      & Ok'Image & ")");
            Fails := Fails + 1;
         end if;
      end;
   end Check_Vector;

   ---------------------------------------------------------------------
   --  Forgery / authentication-failure check: flip byte 0 of a genuine
   --  sealed_hex and confirm Open rejects it (Ok = False, Msg all-zero).
   ---------------------------------------------------------------------
   procedure Check_Forgery
     (Name       : String;
      Key_Hex    : String;
      Nonce_Hex  : String;
      AD_Hex     : String;
      Msg_Len    : Natural;
      Sealed_Hex : String)
   is
      Key   : constant Key_256   := Key_256 (Hex_To_Bytes (Key_Hex));
      Nonce : constant Nonce_120 := Nonce_120 (Hex_To_Bytes (Nonce_Hex));
      AD    : constant Byte_Seq  := Hex_To_Bytes (AD_Hex);

      Sealed        : constant Byte_Seq := Hex_To_Bytes (Sealed_Hex);
      Tampered      : Byte_Seq := Sealed;
      Recovered     : Byte_Seq (0 .. Msg_Len - 1);
      Ok            : Boolean;
   begin
      Tampered (Tampered'First) := Tampered (Tampered'First) xor 16#01#;

      declare
         CT  : constant Byte_Seq := Tampered (Tampered'First .. Tampered'First + Msg_Len - 1);
         Tag : constant Tag_128 :=
           Tag_128 (Tampered (Tampered'First + Msg_Len .. Tampered'Last));
      begin
         Test_Mode.Open (Key, Nonce, AD, CT, Tag, Recovered, Ok);
         if (not Ok) and then Is_Zero (Recovered) then
            Put_Line ("[PASS] " & Name & ": tampered ciphertext rejected"
                      & " (Ok=False, Msg all-zero)");
         else
            Put_Line ("[FAIL] " & Name & ": tampered ciphertext NOT rejected"
                      & " (Ok=" & Ok'Image & ")");
            Fails := Fails + 1;
         end if;
      end;
   end Check_Forgery;

begin
   Check_Vector
     (Name       => "Test vector 1",
      Key_Hex    => "101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f",
      Nonce_Hex  => "202122232425262728292a2b2c2d2e",
      AD_Hex     => "",
      Msg_Hex    => "",
      Sealed_Hex => "2b97bd77712f0cde975309959dfe1d7c");

   Check_Vector
     (Name       => "Test vector 6",
      Key_Hex    => "101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f",
      Nonce_Hex  => "202122232425262728292a2b2c2d2e",
      AD_Hex     => "000102030405060708090a0b0c0d0e0f",
      Msg_Hex    => "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f",
      Sealed_Hex => "109f8a168b36dfade02628a9e129d5257f03cc7912aefa79729b67b186a2b08f6549f9bf10acba0a451dbb2484a60d90");

   Check_Vector
     (Name       => "Test vector 5",
      Key_Hex    => "101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f",
      Nonce_Hex  => "202122232425262728292a2b2c2d2e",
      AD_Hex     => "",
      Msg_Hex    => "15cd77732f9d0c4c6e581ef400876ad9188c5b8850ebd38224da95d7cdc99f7acc",
      Sealed_Hex => "e5ffd2abc5b459a73667756eda6443ede86c0883fc51dd75d22bb14992c684618c5fa78d57308f19d0252072ee39df5ecc");

   Check_Vector
     (Name       => "Test vector 7",
      Key_Hex    => "101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f",
      Nonce_Hex  => "202122232425262728292a2b2c2d2e",
      AD_Hex     => "000102030405060708090a0b0c0d0e0f10",
      Msg_Hex    => "422857fb165af0a35c03199fb895604dca9cea6d788954962c419e0d5c225c0327",
      Sealed_Hex => "7d772203fa38be296d8d20d805163130c69aba8cb16ed845c2296c61a8f34b394e0b3f10e3933c78190b24b33008bf80e9");

   --  Forgery: flip byte 0 of Test vector 7's genuine sealed_hex. The
   --  oracle table has no entries for whatever (tweak, plaintext) pairs
   --  this tampered input produces during recovery/recomputation, so those
   --  lookups miss and fall back to the fixed non-matching block -- Open
   --  must still reject (fail-closed), which is exactly what is checked.
   Check_Forgery
     (Name       => "Test vector 7 (tampered byte 0)",
      Key_Hex    => "101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f",
      Nonce_Hex  => "202122232425262728292a2b2c2d2e",
      AD_Hex     => "000102030405060708090a0b0c0d0e0f10",
      Msg_Len    => 33,
      Sealed_Hex => "7d772203fa38be296d8d20d805163130c69aba8cb16ed845c2296c61a8f34b394e0b3f10e3933c78190b24b33008bf80e9");

   New_Line;
   Put_Line ("Oracle lookup misses observed: " & Misses'Image
             & " (expected: > 0, all from the forgery case)");
   New_Line;

   if Fails = 0 then
      Put_Line ("KAT_AEAD GATE M1 PASSED");
   else
      Put_Line ("KAT_AEAD FAILURES:" & Fails'Image);
      Set_Exit_Status (Failure);
   end if;
end Kat_Aead;
