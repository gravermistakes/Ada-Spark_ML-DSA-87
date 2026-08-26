------------------------------------------------------------------------------
--  LTHING_MLDSA_G_Verify body — generic FIPS 204 ML-DSA verifier
--
--  Unifies ML-DSA-65 and ML-DSA-87 verifier bodies (Alg. 3 + Alg. 8).
--  All parameter-set differences come from the Params/Codec/Sample formals.
--
--  Fail-closed: any decode failure, malformed hint, norm overflow, challenge
--  mismatch, or excess hint weight returns False.  Verify only returns True
--  on a genuine FIPS 204 acceptance.
--
--  SPARK_Mode (On).  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with LTHING_Keccak;       use LTHING_Keccak;
with LTHING_MLDSA_Field;
with LTHING_MLDSA_NTT;
with LTHING_MLDSA_Round;

package body LTHING_MLDSA_G_Verify is

   package Fld renames LTHING_MLDSA_Field;
   package Ntt renames LTHING_MLDSA_NTT;
   package Rnd renames LTHING_MLDSA_Round;

   subtype FPoly is Ntt.Poly;

   Two_Pow_D : constant := 8_192;

   function Add_Poly (A, B : FPoly) return FPoly is
      R : FPoly;
   begin
      for I in FPoly'Range loop
         R (I) := Fld.Add (A (I), B (I));
      end loop;
      return R;
   end Add_Poly;

   function Sub_Poly (A, B : FPoly) return FPoly is
      R : FPoly;
   begin
      for I in FPoly'Range loop
         R (I) := Fld.Sub (A (I), B (I));
      end loop;
      return R;
   end Sub_Poly;

   ---------------------------------------------------------------------------
   --  Verify — FIPS 204 Algorithm 3 + Algorithm 8.
   ---------------------------------------------------------------------------
   function Verify
     (PK      : Public_Key;
      Message : Byte_Array;
      Context : Byte_Array;
      Sig     : Signature) return Boolean
   is
      M_Prime : Byte_Array (0 .. Message'Length + Context'Length + 1) :=
        (others => 0);

      Rho     : Rho_Array;
      T1      : T1_Vec;
      C_Tilde : C_Tilde_Array;
      Z       : Z_Vec;
      H       : H_Vec;
      Ok      : Boolean;

      A_Hat   : Sample.Matrix;

      C_Poly  : Ntt.Poly;
      C_Hat   : FPoly;

      Tr      : Byte_Array (0 .. 63);
      Mu      : Byte_Array (0 .. 63);
      C_Tilde2 : Byte_Array (0 .. C_Tilde_Bytes - 1);

      W1_Bytes : Byte_Array (0 .. K_Dim * 128 - 1) := (others => 0);

      Hint_Weight : Natural := 0;
   begin
      --  ---- Alg. 3 prefix construction ----
      M_Prime (0) := 0;
      M_Prime (1) := Byte (Context'Length);
      for I in 0 .. Context'Length - 1 loop
         M_Prime (2 + I) := Context (Context'First + I);
      end loop;
      for I in 0 .. Message'Length - 1 loop
         M_Prime (2 + Context'Length + I) := Message (Message'First + I);
      end loop;

      --  ---- Alg. 8 step 1: pkDecode ----
      Codec.Pk_Decode (PK, Rho, T1);

      --  ---- step 2: sigDecode (fail-closed) ----
      Codec.Sig_Decode (Sig, C_Tilde, Z, H, Ok);
      if not Ok then
         return False;
      end if;

      --  ---- step 3: A_hat := ExpandA(rho) (NTT domain) ----
      declare
         Rho_BA : Byte_Array (0 .. 31);
      begin
         for I in Rho'Range loop
            Rho_BA (I) := Rho (I);
         end loop;
         Sample.Expand_A (Rho_BA, A_Hat);
      end;

      --  ---- step 4: tr := H(pk, 64); mu := H(tr || M', 64) ----
      Sponge (Input  => Byte_Array (PK),
              Mode   => Mode_SHAKE256,
              Output => Tr);

      declare
         Tr_Mp : Byte_Array (0 .. 64 + M_Prime'Length - 1) := (others => 0);
      begin
         for I in 0 .. 63 loop
            Tr_Mp (I) := Tr (I);
         end loop;
         for I in M_Prime'Range loop
            Tr_Mp (64 + I) := M_Prime (I);
         end loop;
         Sponge (Input  => Tr_Mp,
                 Mode   => Mode_SHAKE256,
                 Output => Mu);
      end;

      --  ---- step 5: c := SampleInBall(c_tilde); c_hat := NTT(c) ----
      declare
         Ct_BA : Byte_Array (0 .. C_Tilde_Bytes - 1);
      begin
         for I in C_Tilde'Range loop
            Ct_BA (I) := C_Tilde (I);
         end loop;
         Sample.Sample_In_Ball (Ct_BA, C_Poly);
      end;
      C_Hat := C_Poly;
      Ntt.NTT (C_Hat);

      --  ---- step 6: w(r) = INTT( sum_s A_hat(r,s) o NTT(z(s))
      --                            - c_hat o NTT(t1(r) * 2^d) ) ----
      declare
         Z_Hat : array (0 .. L_Dim - 1) of FPoly :=
           (others => (others => 0));
         W1    : array (0 .. K_Dim - 1) of Rnd.Poly :=
           (others => (others => 0));
      begin
         for S in 0 .. L_Dim - 1 loop
            for I in FPoly'Range loop
               Z_Hat (S) (I) := Z (S) (I);
            end loop;
            Ntt.NTT (Z_Hat (S));
         end loop;

         for R in 0 .. K_Dim - 1 loop
            pragma Loop_Invariant
              (for all RR in 0 .. R - 1 =>
                 (for all J in FPoly'Range => W1 (RR) (J) <= Rnd.M_Bins - 1));
            declare
               Acc     : FPoly := (others => 0);
               T1d     : FPoly;
               T1d_Hat : FPoly;
               W_Hat   : FPoly;
               W_Poly  : FPoly;
            begin
               for S in 0 .. L_Dim - 1 loop
                  Acc := Add_Poly (Acc, Ntt.Pointwise (A_Hat (R, S), Z_Hat (S)));
               end loop;

               for I in FPoly'Range loop
                  T1d (I) := Fld.Fq
                    ((Integer_64 (T1 (R) (I)) * Two_Pow_D) mod Q);
               end loop;
               T1d_Hat := T1d;
               Ntt.NTT (T1d_Hat);

               W_Hat := Sub_Poly (Acc, Ntt.Pointwise (C_Hat, T1d_Hat));
               W_Poly := W_Hat;
               Ntt.Inv_NTT (W_Poly);

               --  ---- step 7: w1(r) = UseHint(h(r), w(r)) ----
               for I in FPoly'Range loop
                  pragma Loop_Invariant
                    (for all J in FPoly'First .. I - 1 =>
                       W1 (R) (J) <= Rnd.M_Bins - 1);
                  W1 (R) (I) := Rnd.Use_Hint (H (R) (I), W_Poly (I));
               end loop;
            end;
         end loop;

         --  ---- step 8: w1bytes := W1_Encode over all k polys ----
         for R in 0 .. K_Dim - 1 loop
            declare
               Enc : constant Rnd.W1_Bytes := Rnd.W1_Encode (W1 (R));
            begin
               for I in Enc'Range loop
                  W1_Bytes (R * 128 + I) := Enc (I);
               end loop;
            end;
         end loop;
      end;

      --  c_tilde2 := H(mu || w1bytes, C_Tilde_Bytes)
      declare
         Mu_W1 : Byte_Array (0 .. 64 + W1_Bytes'Length - 1) := (others => 0);
      begin
         for I in 0 .. 63 loop
            Mu_W1 (I) := Mu (I);
         end loop;
         for I in W1_Bytes'Range loop
            Mu_W1 (64 + I) := W1_Bytes (I);
         end loop;
         Sponge (Input  => Mu_W1,
                 Mode   => Mode_SHAKE256,
                 Output => C_Tilde2);
      end;

      --  ---- step 9: three acceptance conditions ----

      --  (a) ||z||_inf < gamma1 - beta
      for S in 0 .. L_Dim - 1 loop
         declare
            Zp : Rnd.Poly;
         begin
            for I in FPoly'Range loop
               Zp (I) := Z (S) (I);
            end loop;
            if not Rnd.Inf_Norm_OK (Zp, Integer_32 (Gamma1 - Beta)) then
               return False;
            end if;
         end;
      end loop;

      --  (b) hint weight <= omega
      for R in 0 .. K_Dim - 1 loop
         pragma Loop_Invariant (Hint_Weight <= R * N);
         for I in Hint_Poly'Range loop
            pragma Loop_Invariant (Hint_Weight <= R * N + I);
            Hint_Weight := Hint_Weight + Integer (H (R) (I));
         end loop;
      end loop;
      if Hint_Weight > Omega then
         return False;
      end if;

      --  (c) c_tilde2 = c_tilde
      for I in C_Tilde'Range loop
         if C_Tilde2 (I) /= C_Tilde (I) then
            return False;
         end if;
      end loop;

      return True;
   end Verify;

end LTHING_MLDSA_G_Verify;
