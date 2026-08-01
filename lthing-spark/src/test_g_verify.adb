------------------------------------------------------------------------------
--  test_g_verify — validate LTHING_MLDSA_G_Verify instantiations
--
--  Runs the authoritative FIPS 204 sigVer KAT vectors through both the
--  concrete verifier (LTHING_MLDSA65 / LTHING_MLDSA87) and the generic
--  verifier (LTHING_MLDSA_Verify_G65 / LTHING_MLDSA_Verify_G87) and asserts:
--    (a) the generic result matches the concrete result on every vector
--    (b) the generic result matches the authoritative Expected value
--
--  This is a relational test (generic = concrete) backed by authoritative KATs.
------------------------------------------------------------------------------

pragma SPARK_Mode (Off);

with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Command_Line;  use Ada.Command_Line;
with LTHING_Types;      use LTHING_Types;

with LTHING_MLDSA65;
with LTHING_MLDSA87;
with LTHING_MLDSA_Verify_G65;
with LTHING_MLDSA_Verify_G87;
with LTHING_MLDSA_Params_65;
with LTHING_MLDSA_Params_87;
with MLDSA_KAT_Vectors;
with MLDSA87_KAT_Vectors;

procedure Test_G_Verify is

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

   ---------------------------------------------------------------------------
   --  ML-DSA-65 KAT comparison
   ---------------------------------------------------------------------------
   procedure Run_65 (Id : Natural; V : MLDSA_KAT_Vectors.Vector) is
      package P65 renames LTHING_MLDSA_Params_65;

      Msg : Byte_Array (0 .. (if V.Msg_Len = 0 then 0 else V.Msg_Len - 1));
      Ctx : Byte_Array (0 .. (if V.Ctx_Len = 0 then 0 else V.Ctx_Len - 1));

      R_Concrete : Boolean;
      R_Generic  : Boolean;

      G_PK  : P65.Public_Key;
      G_Sig : P65.Signature;
   begin
      for I in 1 .. V.Msg_Len loop
         Msg (I - 1) := V.Msg (I);
      end loop;
      for I in 1 .. V.Ctx_Len loop
         Ctx (I - 1) := V.Ctx (I);
      end loop;

      R_Concrete := LTHING_MLDSA65.Verify
                       (PK      => V.PK,
                        Message => Msg,
                        Context => Ctx (0 .. V.Ctx_Len - 1),
                        Sig     => V.Sig);

      for I in V.PK'Range loop
         G_PK (I) := V.PK (I);
      end loop;
      for I in V.Sig'Range loop
         G_Sig (I) := V.Sig (I);
      end loop;

      R_Generic := LTHING_MLDSA_Verify_G65.Verify
                     (PK      => G_PK,
                      Message => Msg,
                      Context => Ctx (0 .. V.Ctx_Len - 1),
                      Sig     => G_Sig);

      Report ("65 tcId" & Natural'Image (Id) & " generic=concrete",
              R_Generic = R_Concrete);
      Report ("65 tcId" & Natural'Image (Id) & " matches Expected",
              R_Generic = V.Expected);
   end Run_65;

   ---------------------------------------------------------------------------
   --  ML-DSA-87 KAT comparison
   ---------------------------------------------------------------------------
   procedure Run_87 (Id : Natural; V : MLDSA87_KAT_Vectors.Vector) is
      package P87 renames LTHING_MLDSA_Params_87;

      Msg : Byte_Array (0 .. (if V.Msg_Len = 0 then 0 else V.Msg_Len - 1));
      Ctx : Byte_Array (0 .. (if V.Ctx_Len = 0 then 0 else V.Ctx_Len - 1));

      R_Concrete : Boolean;
      R_Generic  : Boolean;

      G_PK  : P87.Public_Key;
      G_Sig : P87.Signature;
   begin
      for I in 1 .. V.Msg_Len loop
         Msg (I - 1) := V.Msg (I);
      end loop;
      for I in 1 .. V.Ctx_Len loop
         Ctx (I - 1) := V.Ctx (I);
      end loop;

      R_Concrete := LTHING_MLDSA87.Verify
                       (PK      => V.PK,
                        Message => Msg,
                        Context => Ctx (0 .. V.Ctx_Len - 1),
                        Sig     => V.Sig);

      for I in V.PK'Range loop
         G_PK (I) := V.PK (I);
      end loop;
      for I in V.Sig'Range loop
         G_Sig (I) := V.Sig (I);
      end loop;

      R_Generic := LTHING_MLDSA_Verify_G87.Verify
                     (PK      => G_PK,
                      Message => Msg,
                      Context => Ctx (0 .. V.Ctx_Len - 1),
                      Sig     => G_Sig);

      Report ("87 tcId" & Natural'Image (Id) & " generic=concrete",
              R_Generic = R_Concrete);
      Report ("87 tcId" & Natural'Image (Id) & " matches Expected",
              R_Generic = V.Expected);
   end Run_87;

   package M   renames MLDSA_KAT_Vectors;
   package M87 renames MLDSA87_KAT_Vectors;

begin
   Put_Line ("=== Generic Verifier ML-DSA-65 vs concrete (15 KAT vectors) ===");
   Run_65 (31, M.V31);
   Run_65 (32, M.V32);
   Run_65 (33, M.V33);
   Run_65 (34, M.V34);
   Run_65 (35, M.V35);
   Run_65 (36, M.V36);
   Run_65 (37, M.V37);
   Run_65 (38, M.V38);
   Run_65 (39, M.V39);
   Run_65 (40, M.V40);
   Run_65 (41, M.V41);
   Run_65 (42, M.V42);
   Run_65 (43, M.V43);
   Run_65 (44, M.V44);
   Run_65 (45, M.V45);

   Put_Line ("=== Generic Verifier ML-DSA-87 vs concrete (15 KAT vectors) ===");
   Run_87 (61, M87.V61);
   Run_87 (62, M87.V62);
   Run_87 (63, M87.V63);
   Run_87 (64, M87.V64);
   Run_87 (65, M87.V65);
   Run_87 (66, M87.V66);
   Run_87 (67, M87.V67);
   Run_87 (68, M87.V68);
   Run_87 (69, M87.V69);
   Run_87 (70, M87.V70);
   Run_87 (71, M87.V71);
   Run_87 (72, M87.V72);
   Run_87 (73, M87.V73);
   Run_87 (74, M87.V74);
   Run_87 (75, M87.V75);

   if All_Pass then
      Put_Line ("All generic verifier KAT checks passed.");
   else
      Put_Line ("SOME CHECKS FAILED.");
      Set_Exit_Status (Failure);
   end if;
end Test_G_Verify;
