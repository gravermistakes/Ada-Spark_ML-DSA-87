------------------------------------------------------------------------------
--  test_g_params — validate LTHING_MLDSA_G_Params instantiations
--
--  Checks that the derived constants (Beta, PK_Bytes, Sig_Bytes) match the
--  FIPS 204 values for ML-DSA-65 and ML-DSA-87, and exercises the per-set
--  type declarations (Poly, T1_Vec, Z_Vec, H_Vec, Public_Key, Signature).
--
--  Authoritative values come from FIPS 204 Table 1 (final).
------------------------------------------------------------------------------

pragma SPARK_Mode (Off);

with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Command_Line;  use Ada.Command_Line;
with LTHING_MLDSA_Params_65;
with LTHING_MLDSA_Params_87;

procedure Test_G_Params is

   package P65 renames LTHING_MLDSA_Params_65;
   package P87 renames LTHING_MLDSA_Params_87;

   All_Pass : Boolean := True;

   procedure Check (Name : String; Got, Expected : Integer) is
   begin
      if Got = Expected then
         Put_Line ("[PASS] " & Name & " =" & Integer'Image (Got));
      else
         Put_Line ("[FAIL] " & Name & ": got" &
                   Integer'Image (Got) & ", expected" &
                   Integer'Image (Expected));
         All_Pass := False;
      end if;
   end Check;

begin
   Put_Line ("=== ML-DSA-65 derived constants (FIPS 204) ===");
   Check ("K_Dim",         P65.K_Dim,         6);
   Check ("L_Dim",         P65.L_Dim,         5);
   Check ("Eta",           P65.Eta,           4);
   Check ("Tau",           P65.Tau,           49);
   Check ("Omega",         P65.Omega,         55);
   Check ("C_Tilde_Bytes", P65.C_Tilde_Bytes, 48);
   Check ("Beta",          P65.Beta,          196);
   Check ("PK_Bytes",      P65.PK_Bytes,      1952);
   Check ("Sig_Bytes",     P65.Sig_Bytes,     3309);

   Put_Line ("=== ML-DSA-65 type sizes ===");
   Check ("Public_Key'Length",  P65.Public_Key'Length,  1952);
   Check ("Signature'Length",   P65.Signature'Length,   3309);
   Check ("C_Tilde_Array'Len", P65.C_Tilde_Array'Length, 48);
   Check ("Poly'Length",        P65.Poly'Length,        256);
   Check ("T1_Vec'Length",      P65.T1_Vec'Length,      6);
   Check ("Z_Vec'Length",       P65.Z_Vec'Length,       5);
   Check ("H_Vec'Length",       P65.H_Vec'Length,       6);
   Check ("Hint_Poly'Length",   P65.Hint_Poly'Length,   256);

   Put_Line ("=== ML-DSA-87 derived constants (FIPS 204) ===");
   Check ("K_Dim",         P87.K_Dim,         8);
   Check ("L_Dim",         P87.L_Dim,         7);
   Check ("Eta",           P87.Eta,           2);
   Check ("Tau",           P87.Tau,           60);
   Check ("Omega",         P87.Omega,         75);
   Check ("C_Tilde_Bytes", P87.C_Tilde_Bytes, 64);
   Check ("Beta",          P87.Beta,          120);
   Check ("PK_Bytes",      P87.PK_Bytes,      2592);
   Check ("Sig_Bytes",     P87.Sig_Bytes,     4627);

   Put_Line ("=== ML-DSA-87 type sizes ===");
   Check ("Public_Key'Length",  P87.Public_Key'Length,  2592);
   Check ("Signature'Length",   P87.Signature'Length,   4627);
   Check ("C_Tilde_Array'Len", P87.C_Tilde_Array'Length, 64);
   Check ("Poly'Length",        P87.Poly'Length,        256);
   Check ("T1_Vec'Length",      P87.T1_Vec'Length,      8);
   Check ("Z_Vec'Length",       P87.Z_Vec'Length,       7);
   Check ("H_Vec'Length",       P87.H_Vec'Length,       8);
   Check ("Hint_Poly'Length",   P87.Hint_Poly'Length,   256);

   Put_Line ("=== Shared constants ===");
   Check ("N",      P65.N,      256);
   Check ("Q",      P65.Q,      8_380_417);
   Check ("Gamma1", P65.Gamma1, 524_288);
   Check ("Gamma2", P65.Gamma2, 261_888);
   Check ("D_Bits", P65.D_Bits, 13);

   if All_Pass then
      Put_Line ("All generic params checks passed.");
   else
      Put_Line ("SOME CHECKS FAILED.");
      Set_Exit_Status (Failure);
   end if;
end Test_G_Params;
