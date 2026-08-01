------------------------------------------------------------------------------
--  test_g_sample — validate LTHING_MLDSA_G_Sample instantiations
--
--  Property tests:
--    * Sample_In_Ball produces exactly Tau nonzero coefficients
--    * All nonzero coefficients are +1 or -1 (as Fq: 1 or Q-1)
--    * Sample_In_Ball is deterministic (same c_tilde -> same output)
--    * Expand_A is deterministic (same rho -> same output)
--    * Expand_A produces coefficients in 0 .. Q-1
--    * Generic -65 output matches concrete -65 output
--    * Generic -87 output matches concrete -87 output
--
--  All tests are relational / property-based — no frozen vectors.
------------------------------------------------------------------------------

pragma SPARK_Mode (Off);

with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Command_Line;  use Ada.Command_Line;
with Interfaces;        use Interfaces;
with LTHING_Types;      use LTHING_Types;
with LTHING_MLDSA_NTT;  use LTHING_MLDSA_NTT;
with LTHING_MLDSA_Field; use LTHING_MLDSA_Field;

with LTHING_MLDSA_Params_65;
with LTHING_MLDSA_Params_87;
with LTHING_MLDSA_Sample_G65;
with LTHING_MLDSA_Sample_G87;
with LTHING_MLDSA_Sample;
with LTHING_MLDSA87_Sample;

procedure Test_G_Sample is

   All_Pass : Boolean := True;

   procedure Report (Name : String; Pass : Boolean) is
   begin
      if Pass then
         Put_Line ("[PASS] " & Name);
      else
         Put_Line ("[FAIL] " & Name);
         All_Pass := False;
      end if;
   end Report;

   Q_Const : constant := 8_380_417;

   ---------------------------------------------------------------------------
   --  ML-DSA-65 tests
   ---------------------------------------------------------------------------
   procedure Test_65 is
      package SG renames LTHING_MLDSA_Sample_G65;
      package SC renames LTHING_MLDSA_Sample;

      CT : Byte_Array (0 .. 47) := (others => 0);
      C1, C2 : Poly;
   begin
      --  Fill c_tilde with a non-trivial pattern
      for I in CT'Range loop
         CT (I) := Byte ((I * 37 + 13) mod 256);
      end loop;

      --  Sample_In_Ball: determinism
      SG.Sample_In_Ball (CT, C1);
      SG.Sample_In_Ball (CT, C2);
      declare
         Ok : Boolean := True;
      begin
         for I in Poly'Range loop
            if C1 (I) /= C2 (I) then
               Ok := False;
               exit;
            end if;
         end loop;
         Report ("65: Sample_In_Ball determinism", Ok);
      end;

      --  Sample_In_Ball: exactly Tau=49 nonzero coefficients
      declare
         Count : Natural := 0;
      begin
         for I in Poly'Range loop
            if C1 (I) /= 0 then
               Count := Count + 1;
            end if;
         end loop;
         Report ("65: Sample_In_Ball has exactly 49 nonzero", Count = 49);
      end;

      --  Sample_In_Ball: all nonzero are +1 or -1 (Fq: 1 or Q-1)
      declare
         Ok : Boolean := True;
      begin
         for I in Poly'Range loop
            if C1 (I) /= 0 and then C1 (I) /= 1
              and then C1 (I) /= Fq (Q_Const - 1)
            then
               Ok := False;
               exit;
            end if;
         end loop;
         Report ("65: Sample_In_Ball coeffs in {0, +1, -1}", Ok);
      end;

      --  Generic matches concrete
      declare
         CC : Poly;
         Ok : Boolean := True;
      begin
         SC.Sample_In_Ball (CT, CC);
         for I in Poly'Range loop
            if C1 (I) /= CC (I) then
               Ok := False;
               exit;
            end if;
         end loop;
         Report ("65: Generic Sample_In_Ball = concrete", Ok);
      end;

      --  Expand_A: determinism + range
      declare
         Rho : Byte_Array (0 .. 31) := (others => 0);
         AG  : SG.Matrix;
         AG2 : SG.Matrix;
         Ok_Det   : Boolean := True;
         Ok_Range : Boolean := True;
      begin
         for I in Rho'Range loop
            Rho (I) := Byte ((I * 7 + 3) mod 256);
         end loop;

         SG.Expand_A (Rho, AG);
         SG.Expand_A (Rho, AG2);

         for R in 0 .. 5 loop
            for S in 0 .. 4 loop
               for J in Poly'Range loop
                  if AG (R, S) (J) /= AG2 (R, S) (J) then
                     Ok_Det := False;
                  end if;
                  if AG (R, S) (J) < 0
                    or else AG (R, S) (J) >= Fq (Q_Const - 1)
                  then
                     Ok_Range := False;
                  end if;
               end loop;
            end loop;
         end loop;
         Report ("65: Expand_A determinism", Ok_Det);
         Report ("65: Expand_A coeffs in [0, Q)", Ok_Range);
      end;

      --  Generic Expand_A matches concrete
      declare
         Rho : Byte_Array (0 .. 31) := (others => 0);
         AG  : SG.Matrix;
         AC  : SC.Matrix;
         Ok  : Boolean := True;
      begin
         for I in Rho'Range loop
            Rho (I) := Byte ((I * 7 + 3) mod 256);
         end loop;

         SG.Expand_A (Rho, AG);
         SC.Expand_A (Rho, AC);

         for R in 0 .. 5 loop
            for S in 0 .. 4 loop
               for J in Poly'Range loop
                  if AG (R, S) (J) /= AC (R, S) (J) then
                     Ok := False;
                  end if;
               end loop;
            end loop;
         end loop;
         Report ("65: Generic Expand_A = concrete", Ok);
      end;
   end Test_65;

   ---------------------------------------------------------------------------
   --  ML-DSA-87 tests
   ---------------------------------------------------------------------------
   procedure Test_87 is
      package SG renames LTHING_MLDSA_Sample_G87;
      package SC renames LTHING_MLDSA87_Sample;

      CT : Byte_Array (0 .. 63) := (others => 0);
      C1, C2 : Poly;
   begin
      for I in CT'Range loop
         CT (I) := Byte ((I * 41 + 17) mod 256);
      end loop;

      --  Sample_In_Ball: determinism
      SG.Sample_In_Ball (CT, C1);
      SG.Sample_In_Ball (CT, C2);
      declare
         Ok : Boolean := True;
      begin
         for I in Poly'Range loop
            if C1 (I) /= C2 (I) then
               Ok := False;
               exit;
            end if;
         end loop;
         Report ("87: Sample_In_Ball determinism", Ok);
      end;

      --  Sample_In_Ball: exactly Tau=60 nonzero
      declare
         Count : Natural := 0;
      begin
         for I in Poly'Range loop
            if C1 (I) /= 0 then
               Count := Count + 1;
            end if;
         end loop;
         Report ("87: Sample_In_Ball has exactly 60 nonzero", Count = 60);
      end;

      --  Sample_In_Ball: all nonzero are +1 or -1
      declare
         Ok : Boolean := True;
      begin
         for I in Poly'Range loop
            if C1 (I) /= 0 and then C1 (I) /= 1
              and then C1 (I) /= Fq (Q_Const - 1)
            then
               Ok := False;
               exit;
            end if;
         end loop;
         Report ("87: Sample_In_Ball coeffs in {0, +1, -1}", Ok);
      end;

      --  Generic matches concrete
      declare
         CC : Poly;
         Ok : Boolean := True;
      begin
         SC.Sample_In_Ball (CT, CC);
         for I in Poly'Range loop
            if C1 (I) /= CC (I) then
               Ok := False;
               exit;
            end if;
         end loop;
         Report ("87: Generic Sample_In_Ball = concrete", Ok);
      end;

      --  Expand_A: determinism + range
      declare
         Rho : Byte_Array (0 .. 31) := (others => 0);
         AG  : SG.Matrix;
         AG2 : SG.Matrix;
         Ok_Det   : Boolean := True;
         Ok_Range : Boolean := True;
      begin
         for I in Rho'Range loop
            Rho (I) := Byte ((I * 11 + 5) mod 256);
         end loop;

         SG.Expand_A (Rho, AG);
         SG.Expand_A (Rho, AG2);

         for R in 0 .. 7 loop
            for S in 0 .. 6 loop
               for J in Poly'Range loop
                  if AG (R, S) (J) /= AG2 (R, S) (J) then
                     Ok_Det := False;
                  end if;
                  if AG (R, S) (J) < 0
                    or else AG (R, S) (J) >= Fq (Q_Const - 1)
                  then
                     Ok_Range := False;
                  end if;
               end loop;
            end loop;
         end loop;
         Report ("87: Expand_A determinism", Ok_Det);
         Report ("87: Expand_A coeffs in [0, Q)", Ok_Range);
      end;

      --  Generic Expand_A matches concrete
      declare
         Rho : Byte_Array (0 .. 31) := (others => 0);
         AG  : SG.Matrix;
         AC  : SC.Matrix;
         Ok  : Boolean := True;
      begin
         for I in Rho'Range loop
            Rho (I) := Byte ((I * 11 + 5) mod 256);
         end loop;

         SG.Expand_A (Rho, AG);
         SC.Expand_A (Rho, AC);

         for R in 0 .. 7 loop
            for S in 0 .. 6 loop
               for J in Poly'Range loop
                  if AG (R, S) (J) /= AC (R, S) (J) then
                     Ok := False;
                  end if;
               end loop;
            end loop;
         end loop;
         Report ("87: Generic Expand_A = concrete", Ok);
      end;
   end Test_87;

begin
   Put_Line ("=== Generic Sampler ML-DSA-65 ===");
   Test_65;
   Put_Line ("=== Generic Sampler ML-DSA-87 ===");
   Test_87;

   if All_Pass then
      Put_Line ("All generic sampler checks passed.");
   else
      Put_Line ("SOME CHECKS FAILED.");
      Set_Exit_Status (Failure);
   end if;
end Test_G_Sample;
