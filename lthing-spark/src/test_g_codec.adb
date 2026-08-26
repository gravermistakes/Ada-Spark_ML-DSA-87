------------------------------------------------------------------------------
--  test_g_codec — validate LTHING_MLDSA_G_Codec instantiations
--
--  Exercises the generic codec for ML-DSA-65 and ML-DSA-87 with:
--    * Pk_Encode / Pk_Decode roundtrip  (relational property)
--    * Sig_Encode / Sig_Decode roundtrip (relational property)
--    * Simple_Bit_Pack / Simple_Bit_Unpack roundtrip
--    * Get_Bit basic correctness
--
--  All tests are relational / property-based — no frozen vectors.
------------------------------------------------------------------------------

pragma SPARK_Mode (Off);

with Ada.Text_IO;       use Ada.Text_IO;
with Ada.Command_Line;  use Ada.Command_Line;
with Interfaces;        use Interfaces;
with LTHING_Types;      use LTHING_Types;
with LTHING_MLDSA_Params_65;
with LTHING_MLDSA_Params_87;
with LTHING_MLDSA_Codec_G65;
with LTHING_MLDSA_Codec_G87;

procedure Test_G_Codec is

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
   --  ML-DSA-65 tests
   ---------------------------------------------------------------------------
   procedure Test_65 is
      package P renames LTHING_MLDSA_Params_65;
      package C renames LTHING_MLDSA_Codec_G65;
   begin
      --  Get_Bit: byte 0xA5 = 10100101 in little-endian bit order
      declare
         V : Byte_Array (0 .. 0) := (0 => 16#A5#);
         Ok : Boolean := True;
      begin
         Ok := Ok and C.Get_Bit (V, 0) = 1;  -- bit 0
         Ok := Ok and C.Get_Bit (V, 1) = 0;  -- bit 1
         Ok := Ok and C.Get_Bit (V, 2) = 1;  -- bit 2
         Ok := Ok and C.Get_Bit (V, 3) = 0;  -- bit 3
         Ok := Ok and C.Get_Bit (V, 4) = 0;  -- bit 4
         Ok := Ok and C.Get_Bit (V, 5) = 1;  -- bit 5
         Ok := Ok and C.Get_Bit (V, 6) = 0;  -- bit 6
         Ok := Ok and C.Get_Bit (V, 7) = 1;  -- bit 7
         Report ("65: Get_Bit on 0xA5", Ok);
      end;

      --  Simple_Bit_Pack / Simple_Bit_Unpack roundtrip (10-bit, Hi=1023)
      declare
         Src : P.Poly := (others => 0);
         Ok  : Boolean := True;
      begin
         for I in P.Poly'Range loop
            Src (I) := P.Coeff (I mod 1024);
         end loop;
         declare
            Packed   : constant Byte_Array :=
              C.Simple_Bit_Pack (Src, 10, 1023);
            Unpacked : constant P.Poly :=
              C.Simple_Bit_Unpack (Packed, 10, 1023);
         begin
            for I in P.Poly'Range loop
               if Unpacked (I) /= Src (I) then
                  Ok := False;
                  exit;
               end if;
            end loop;
         end;
         Report ("65: Bit_Pack/Unpack roundtrip (10-bit)", Ok);
      end;

      --  Pk_Encode / Pk_Decode roundtrip
      declare
         Rho_In  : P.Rho_Array := (others => 0);
         T1_In   : P.T1_Vec := (others => (others => 0));
         Rho_Out : P.Rho_Array;
         T1_Out  : P.T1_Vec;
         Ok      : Boolean := True;
      begin
         for I in Rho_In'Range loop
            Rho_In (I) := Byte (I mod 256);
         end loop;
         for I in P.T1_Vec'Range loop
            for J in P.Poly'Range loop
               T1_In (I) (J) := P.Coeff ((I * 256 + J) mod 1024);
            end loop;
         end loop;

         declare
            PK : constant P.Public_Key := C.Pk_Encode (Rho_In, T1_In);
         begin
            C.Pk_Decode (PK, Rho_Out, T1_Out);
         end;

         for I in Rho_In'Range loop
            if Rho_In (I) /= Rho_Out (I) then
               Ok := False;
               exit;
            end if;
         end loop;

         if Ok then
            for I in P.T1_Vec'Range loop
               for J in P.Poly'Range loop
                  if T1_In (I) (J) /= T1_Out (I) (J) then
                     Ok := False;
                     exit;
                  end if;
               end loop;
               exit when not Ok;
            end loop;
         end if;

         Report ("65: Pk_Encode/Pk_Decode roundtrip", Ok);
      end;

      --  Sig_Encode / Sig_Decode roundtrip
      declare
         CT_In : P.C_Tilde_Array := (others => 0);
         Z_In  : P.Z_Vec := (others => (others => 0));
         H_In  : P.H_Vec := (others => (others => 0));

         CT_Out : P.C_Tilde_Array;
         Z_Out  : P.Z_Vec;
         H_Out  : P.H_Vec;
         Ok_Sig : Boolean;
         Ok     : Boolean := True;
      begin
         for I in CT_In'Range loop
            CT_In (I) := Byte (I mod 256);
         end loop;

         for I in P.Z_Vec'Range loop
            for J in P.Poly'Range loop
               Z_In (I) (J) := P.Coeff ((I * 256 + J) mod (P.Q - 1));
            end loop;
         end loop;

         --  Set a few hint bits (within Omega budget)
         H_In (0) (0) := 1;
         H_In (0) (42) := 1;
         H_In (1) (100) := 1;

         declare
            Sig : constant P.Signature :=
              C.Sig_Encode (CT_In, Z_In, H_In);
         begin
            C.Sig_Decode (Sig, CT_Out, Z_Out, H_Out, Ok_Sig);
         end;

         if not Ok_Sig then
            Ok := False;
         end if;

         if Ok then
            for I in CT_In'Range loop
               if CT_In (I) /= CT_Out (I) then
                  Ok := False;
                  exit;
               end if;
            end loop;
         end if;

         if Ok then
            for I in P.Z_Vec'Range loop
               for J in P.Poly'Range loop
                  if Z_In (I) (J) /= Z_Out (I) (J) then
                     Ok := False;
                     exit;
                  end if;
               end loop;
               exit when not Ok;
            end loop;
         end if;

         if Ok then
            for I in P.H_Vec'Range loop
               for J in P.Hint_Poly'Range loop
                  if H_In (I) (J) /= H_Out (I) (J) then
                     Ok := False;
                     exit;
                  end if;
               end loop;
               exit when not Ok;
            end loop;
         end if;

         Report ("65: Sig_Encode/Sig_Decode roundtrip", Ok);
      end;
   end Test_65;

   ---------------------------------------------------------------------------
   --  ML-DSA-87 tests
   ---------------------------------------------------------------------------
   procedure Test_87 is
      package P renames LTHING_MLDSA_Params_87;
      package C renames LTHING_MLDSA_Codec_G87;
   begin
      --  Get_Bit: byte 0x5A = 01011010 in little-endian bit order
      declare
         V : Byte_Array (0 .. 0) := (0 => 16#5A#);
         Ok : Boolean := True;
      begin
         Ok := Ok and C.Get_Bit (V, 0) = 0;  -- bit 0
         Ok := Ok and C.Get_Bit (V, 1) = 1;  -- bit 1
         Ok := Ok and C.Get_Bit (V, 2) = 0;  -- bit 2
         Ok := Ok and C.Get_Bit (V, 3) = 1;  -- bit 3
         Ok := Ok and C.Get_Bit (V, 4) = 1;  -- bit 4
         Ok := Ok and C.Get_Bit (V, 5) = 0;  -- bit 5
         Ok := Ok and C.Get_Bit (V, 6) = 1;  -- bit 6
         Ok := Ok and C.Get_Bit (V, 7) = 0;  -- bit 7
         Report ("87: Get_Bit on 0x5A", Ok);
      end;

      --  Simple_Bit_Pack / Simple_Bit_Unpack roundtrip (10-bit, Hi=1023)
      declare
         Src : P.Poly := (others => 0);
         Ok  : Boolean := True;
      begin
         for I in P.Poly'Range loop
            Src (I) := P.Coeff (I mod 1024);
         end loop;
         declare
            Packed   : constant Byte_Array :=
              C.Simple_Bit_Pack (Src, 10, 1023);
            Unpacked : constant P.Poly :=
              C.Simple_Bit_Unpack (Packed, 10, 1023);
         begin
            for I in P.Poly'Range loop
               if Unpacked (I) /= Src (I) then
                  Ok := False;
                  exit;
               end if;
            end loop;
         end;
         Report ("87: Bit_Pack/Unpack roundtrip (10-bit)", Ok);
      end;

      --  Pk_Encode / Pk_Decode roundtrip
      declare
         Rho_In  : P.Rho_Array := (others => 0);
         T1_In   : P.T1_Vec := (others => (others => 0));
         Rho_Out : P.Rho_Array;
         T1_Out  : P.T1_Vec;
         Ok      : Boolean := True;
      begin
         for I in Rho_In'Range loop
            Rho_In (I) := Byte (I mod 256);
         end loop;
         for I in P.T1_Vec'Range loop
            for J in P.Poly'Range loop
               T1_In (I) (J) := P.Coeff ((I * 256 + J) mod 1024);
            end loop;
         end loop;

         declare
            PK : constant P.Public_Key := C.Pk_Encode (Rho_In, T1_In);
         begin
            C.Pk_Decode (PK, Rho_Out, T1_Out);
         end;

         for I in Rho_In'Range loop
            if Rho_In (I) /= Rho_Out (I) then
               Ok := False;
               exit;
            end if;
         end loop;

         if Ok then
            for I in P.T1_Vec'Range loop
               for J in P.Poly'Range loop
                  if T1_In (I) (J) /= T1_Out (I) (J) then
                     Ok := False;
                     exit;
                  end if;
               end loop;
               exit when not Ok;
            end loop;
         end if;

         Report ("87: Pk_Encode/Pk_Decode roundtrip", Ok);
      end;

      --  Sig_Encode / Sig_Decode roundtrip
      declare
         CT_In : P.C_Tilde_Array := (others => 0);
         Z_In  : P.Z_Vec := (others => (others => 0));
         H_In  : P.H_Vec := (others => (others => 0));

         CT_Out : P.C_Tilde_Array;
         Z_Out  : P.Z_Vec;
         H_Out  : P.H_Vec;
         Ok_Sig : Boolean;
         Ok     : Boolean := True;
      begin
         for I in CT_In'Range loop
            CT_In (I) := Byte (I mod 256);
         end loop;

         for I in P.Z_Vec'Range loop
            for J in P.Poly'Range loop
               Z_In (I) (J) := P.Coeff ((I * 256 + J) mod (P.Q - 1));
            end loop;
         end loop;

         --  Set a few hint bits (within Omega budget)
         H_In (0) (0) := 1;
         H_In (0) (42) := 1;
         H_In (1) (100) := 1;
         H_In (2) (200) := 1;

         declare
            Sig : constant P.Signature :=
              C.Sig_Encode (CT_In, Z_In, H_In);
         begin
            C.Sig_Decode (Sig, CT_Out, Z_Out, H_Out, Ok_Sig);
         end;

         if not Ok_Sig then
            Ok := False;
         end if;

         if Ok then
            for I in CT_In'Range loop
               if CT_In (I) /= CT_Out (I) then
                  Ok := False;
                  exit;
               end if;
            end loop;
         end if;

         if Ok then
            for I in P.Z_Vec'Range loop
               for J in P.Poly'Range loop
                  if Z_In (I) (J) /= Z_Out (I) (J) then
                     Ok := False;
                     exit;
                  end if;
               end loop;
               exit when not Ok;
            end loop;
         end if;

         if Ok then
            for I in P.H_Vec'Range loop
               for J in P.Hint_Poly'Range loop
                  if H_In (I) (J) /= H_Out (I) (J) then
                     Ok := False;
                     exit;
                  end if;
               end loop;
               exit when not Ok;
            end loop;
         end if;

         Report ("87: Sig_Encode/Sig_Decode roundtrip", Ok);
      end;
   end Test_87;

begin
   Put_Line ("=== Generic Codec ML-DSA-65 ===");
   Test_65;
   Put_Line ("=== Generic Codec ML-DSA-87 ===");
   Test_87;

   if All_Pass then
      Put_Line ("All generic codec checks passed.");
   else
      Put_Line ("SOME CHECKS FAILED.");
      Set_Exit_Status (Failure);
   end if;
end Test_G_Codec;
