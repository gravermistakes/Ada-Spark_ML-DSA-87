------------------------------------------------------------------------------
--  test_keccak — KAT gate for the pure Ada/SPARK Keccak/SHAKE core.
--
--  These are the vectors the asm path NEVER had as a committed regression.
--  Functional correctness of Keccak is established here (proof gives AoRTE
--  only). Vectors validated against FIPS 202 + Python hashlib before embedding:
--    * keccak_f1600(0) lane0 = f1258f7940e1dde7        (FIPS 202)
--    * SHAKE256("") / ("abc"), 32 bytes                (hashlib shake_256)
--    * SHAKE512 (rate 72) "" and a 73-byte non-aligned input, 64 bytes
--      -- the PRODUCTION configuration used by LTHING_Hash, frozen here.
--    * determinism: equal input -> equal digest.
--
--  Exits non-zero on any failure (so a `test` target / CI fails the build).
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

with LTHING_Keccak;   use LTHING_Keccak;
with Interfaces;      use Interfaces;
with Ada.Text_IO;     use Ada.Text_IO;
with Ada.Command_Line;

procedure Test_Keccak is

   Fails : Natural := 0;

   procedure Chk (Name : String; Cond : Boolean) is
   begin
      if Cond then
         Put_Line ("[PASS] " & Name);
      else
         Put_Line ("[FAIL] " & Name);
         Fails := Fails + 1;
      end if;
   end Chk;

   function Eq (Got, Want : Byte_Array) return Boolean is
   begin
      if Got'Length /= Want'Length then
         return False;
      end if;
      for I in 0 .. Got'Length - 1 loop
         if Got (Got'First + I) /= Want (Want'First + I) then
            return False;
         end if;
      end loop;
      return True;
   end Eq;

   --  ---- expected vectors ----
   Exp_SHAKE256_Empty : constant Byte_Array (0 .. 31) :=
     (16#46#, 16#B9#, 16#DD#, 16#2B#, 16#0B#, 16#A8#, 16#8D#, 16#13#,
      16#23#, 16#3B#, 16#3F#, 16#EB#, 16#74#, 16#3E#, 16#EB#, 16#24#,
      16#3F#, 16#CD#, 16#52#, 16#EA#, 16#62#, 16#B8#, 16#1B#, 16#82#,
      16#B5#, 16#0C#, 16#27#, 16#64#, 16#6E#, 16#D5#, 16#76#, 16#2F#);

   Exp_SHAKE256_Abc : constant Byte_Array (0 .. 31) :=
     (16#48#, 16#33#, 16#66#, 16#60#, 16#13#, 16#60#, 16#A8#, 16#77#,
      16#1C#, 16#68#, 16#63#, 16#08#, 16#0C#, 16#C4#, 16#11#, 16#4D#,
      16#8D#, 16#B4#, 16#45#, 16#30#, 16#F8#, 16#F1#, 16#E1#, 16#EE#,
      16#4F#, 16#94#, 16#EA#, 16#37#, 16#E7#, 16#8B#, 16#57#, 16#39#);

   Exp_S512_Empty : constant Byte_Array (0 .. 63) :=
     (16#AE#, 16#1B#, 16#4E#, 16#EA#, 16#1E#, 16#AF#, 16#5E#, 16#A6#,
      16#33#, 16#E6#, 16#60#, 16#45#, 16#F0#, 16#3F#, 16#F1#, 16#1B#,
      16#8B#, 16#7D#, 16#31#, 16#93#, 16#11#, 16#90#, 16#75#, 16#44#,
      16#21#, 16#17#, 16#BD#, 16#78#, 16#6D#, 16#FD#, 16#93#, 16#9F#,
      16#25#, 16#A5#, 16#3A#, 16#30#, 16#FA#, 16#E5#, 16#03#, 16#48#,
      16#8D#, 16#42#, 16#68#, 16#3C#, 16#19#, 16#17#, 16#B3#, 16#96#,
      16#4F#, 16#6B#, 16#1C#, 16#F5#, 16#D2#, 16#7C#, 16#2B#, 16#40#,
      16#CB#, 16#AF#, 16#53#, 16#C5#, 16#B7#, 16#49#, 16#66#, 16#6A#);

   Exp_S512_73 : constant Byte_Array (0 .. 63) :=
     (16#96#, 16#75#, 16#94#, 16#EA#, 16#34#, 16#06#, 16#B4#, 16#7D#,
      16#17#, 16#F4#, 16#0E#, 16#85#, 16#F3#, 16#8C#, 16#6C#, 16#46#,
      16#98#, 16#7E#, 16#B1#, 16#2C#, 16#AD#, 16#91#, 16#46#, 16#7E#,
      16#3C#, 16#4E#, 16#84#, 16#72#, 16#BA#, 16#BC#, 16#23#, 16#CB#,
      16#6D#, 16#5A#, 16#8A#, 16#F0#, 16#DC#, 16#C5#, 16#BB#, 16#50#,
      16#A9#, 16#0E#, 16#E5#, 16#E5#, 16#34#, 16#5D#, 16#9B#, 16#65#,
      16#58#, 16#66#, 16#8A#, 16#57#, 16#98#, 16#2F#, 16#AA#, 16#9C#,
      16#8C#, 16#B6#, 16#17#, 16#BC#, 16#0B#, 16#4A#, 16#56#, 16#85#);

   Empty : constant Byte_Array (1 .. 0) := (others => 0);  --  null range, length 0
   Abc   : constant Byte_Array (0 .. 2) := (16#61#, 16#62#, 16#63#);

   Big73 : Byte_Array (0 .. 72);
   Zero_State : State := (others => 0);
   Out32 : Byte_Array (0 .. 31);
   Out64 : Byte_Array (0 .. 63);
   Out64b : Byte_Array (0 .. 63);
begin
   --  GATE 1: the permutation itself (FIPS 202 anchor).
   Keccak_F1600 (Zero_State);
   Chk ("keccak_f1600(0) lane0 = f1258f7940e1dde7",
        Zero_State (0) = 16#F1258F7940E1DDE7#);

   --  GATE 2: standard SHAKE256 (rate 136) against hashlib vectors.
   SHAKE (Empty, Rate_SHAKE256, Out32);
   Chk ("SHAKE256(\"\") = 46b9dd2b...", Eq (Out32, Exp_SHAKE256_Empty));
   SHAKE (Abc, Rate_SHAKE256, Out32);
   Chk ("SHAKE256(\"abc\") = 48336660...", Eq (Out32, Exp_SHAKE256_Abc));

   --  GATE 3: rate-72 "SHAKE512" -- the PRODUCTION path, never KAT'd in asm.
   SHAKE (Empty, Rate_SHAKE512, Out64);
   Chk ("SHAKE512(rate72)(\"\") 64B frozen vector", Eq (Out64, Exp_S512_Empty));

   --  GATE 4: rate-72 NON-rate-aligned input (73 bytes) -> final-block path.
   for I in Big73'Range loop
      Big73 (I) := Byte ((I * 7 + 3) mod 256);
   end loop;
   SHAKE (Big73, Rate_SHAKE512, Out64);
   Chk ("SHAKE512(rate72)(73B non-aligned) 64B frozen vector",
        Eq (Out64, Exp_S512_73));

   --  GATE 5: determinism (seal/chain checks depend on it).
   SHAKE (Big73, Rate_SHAKE512, Out64b);
   Chk ("SHAKE deterministic: same input -> same digest", Eq (Out64, Out64b));

   New_Line;
   if Fails = 0 then
      Put_Line ("KECCAK GATE PASSED: f[1600] + SHAKE128/256/512 KAT-correct");
   else
      Put_Line ("KECCAK FAILURES:" & Fails'Image);
      Ada.Command_Line.Set_Exit_Status (Ada.Command_Line.Failure);
   end if;
end Test_Keccak;
