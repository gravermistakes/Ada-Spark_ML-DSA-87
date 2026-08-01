------------------------------------------------------------------------------
--  test_g_sign — validate LTHING_MLDSA_G_Sign instantiations
--
--  Relational tests: generic signer (Sign_G65 / Sign_G87) must produce
--  byte-identical keys and signatures to the concrete signer (LTHING_MLDSA_Sign
--  / LTHING_MLDSA87_Sign), and both must round-trip through Verify.
------------------------------------------------------------------------------

pragma SPARK_Mode (Off);

with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Command_Line;  use Ada.Command_Line;
with Interfaces;        use Interfaces;
with LTHING_Types;      use LTHING_Types;

with LTHING_MLDSA65;
with LTHING_MLDSA87;
with LTHING_MLDSA_Sign;
with LTHING_MLDSA87_Sign;
with LTHING_MLDSA_Sign_G65;
with LTHING_MLDSA_Sign_G87;
with LTHING_MLDSA_Verify_G65;
with LTHING_MLDSA_Verify_G87;
with LTHING_MLDSA_Params_65;
with LTHING_MLDSA_Params_87;

procedure Test_G_Sign is

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

   Seed : constant Byte_Array (0 .. 31) :=
     (16#AA#, 16#BB#, 16#CC#, 16#DD#, 16#EE#, 16#FF#,
      16#11#, 16#22#, 16#33#, 16#44#, 16#55#, 16#66#,
      16#77#, 16#88#, 16#99#, 16#00#,
      16#01#, 16#02#, 16#03#, 16#04#, 16#05#, 16#06#,
      16#07#, 16#08#, 16#09#, 16#0A#, 16#0B#, 16#0C#,
      16#0D#, 16#0E#, 16#0F#, 16#10#);

   Msg : constant Byte_Array (0 .. 3) := (16#48#, 16#65#, 16#6C#, 16#6F#);
   Ctx : constant Byte_Array (1 .. 0) := (others => 0);

begin
   Put_Line ("=== Generic Signer ML-DSA-65 ===");
   declare
      C_PK  : LTHING_MLDSA65.Public_Key;
      C_SK  : LTHING_MLDSA_Sign.Secret_Key;
      C_Sig : LTHING_MLDSA65.Signature;
      C_Ok  : Boolean;

      G_PK  : LTHING_MLDSA_Params_65.Public_Key;
      G_SK  : LTHING_MLDSA_Sign_G65.Secret_Key;
      G_Sig : LTHING_MLDSA_Params_65.Signature;
      G_Ok  : Boolean;

      PK_Match : Boolean := True;
   begin
      LTHING_MLDSA_Sign.Key_Gen (Seed, C_PK, C_SK);
      LTHING_MLDSA_Sign_G65.Key_Gen (Seed, G_PK, G_SK);

      for I in C_PK'Range loop
         if C_PK (I) /= G_PK (I) then PK_Match := False; exit; end if;
      end loop;
      Report ("65: KeyGen PK byte-identical", PK_Match);

      LTHING_MLDSA_Sign.Sign (C_SK, Msg, Ctx, C_Sig, C_Ok);
      LTHING_MLDSA_Sign_G65.Sign (G_SK, Msg, Ctx, G_Sig, G_Ok);

      Report ("65: concrete Sign Ok", C_Ok);
      Report ("65: generic Sign Ok", G_Ok);

      if C_Ok and G_Ok then
         declare
            Sig_Match : Boolean := True;
         begin
            for I in C_Sig'Range loop
               if C_Sig (I) /= G_Sig (I) then Sig_Match := False; exit; end if;
            end loop;
            Report ("65: Sig byte-identical", Sig_Match);
         end;

         Report ("65: concrete Verify(concrete sig)",
                 LTHING_MLDSA65.Verify (C_PK, Msg, Ctx, C_Sig));
         Report ("65: generic Verify(generic sig)",
                 LTHING_MLDSA_Verify_G65.Verify (G_PK, Msg, Ctx, G_Sig));
         Report ("65: generic Verify(concrete sig)",
                 LTHING_MLDSA_Verify_G65.Verify (G_PK, Msg, Ctx,
                   LTHING_MLDSA_Params_65.Signature (C_Sig)));
      end if;
   end;

   Put_Line ("=== Generic Signer ML-DSA-87 ===");
   declare
      C_PK  : LTHING_MLDSA87.Public_Key;
      C_SK  : LTHING_MLDSA87_Sign.Secret_Key;
      C_Sig : LTHING_MLDSA87.Signature;
      C_Ok  : Boolean;

      G_PK  : LTHING_MLDSA_Params_87.Public_Key;
      G_SK  : LTHING_MLDSA_Sign_G87.Secret_Key;
      G_Sig : LTHING_MLDSA_Params_87.Signature;
      G_Ok  : Boolean;

      PK_Match : Boolean := True;
   begin
      LTHING_MLDSA87_Sign.Key_Gen (Seed, C_PK, C_SK);
      LTHING_MLDSA_Sign_G87.Key_Gen (Seed, G_PK, G_SK);

      for I in C_PK'Range loop
         if C_PK (I) /= G_PK (I) then PK_Match := False; exit; end if;
      end loop;
      Report ("87: KeyGen PK byte-identical", PK_Match);

      LTHING_MLDSA87_Sign.Sign (C_SK, Msg, Ctx, C_Sig, C_Ok);
      LTHING_MLDSA_Sign_G87.Sign (G_SK, Msg, Ctx, G_Sig, G_Ok);

      Report ("87: concrete Sign Ok", C_Ok);
      Report ("87: generic Sign Ok", G_Ok);

      if C_Ok and G_Ok then
         declare
            Sig_Match : Boolean := True;
         begin
            for I in C_Sig'Range loop
               if C_Sig (I) /= G_Sig (I) then Sig_Match := False; exit; end if;
            end loop;
            Report ("87: Sig byte-identical", Sig_Match);
         end;

         Report ("87: concrete Verify(concrete sig)",
                 LTHING_MLDSA87.Verify (C_PK, Msg, Ctx, C_Sig));
         Report ("87: generic Verify(generic sig)",
                 LTHING_MLDSA_Verify_G87.Verify (G_PK, Msg, Ctx, G_Sig));
         Report ("87: generic Verify(concrete sig)",
                 LTHING_MLDSA_Verify_G87.Verify (G_PK, Msg, Ctx,
                   LTHING_MLDSA_Params_87.Signature (C_Sig)));
      end if;
   end;

   if All_Pass then
      Put_Line ("All generic signer checks passed.");
   else
      Put_Line ("SOME CHECKS FAILED.");
      Set_Exit_Status (Failure);
   end if;
end Test_G_Sign;
