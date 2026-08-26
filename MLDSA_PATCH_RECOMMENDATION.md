# Patch Recommendation: Ada-Spark\_ML-DSA-87

**Target**: `gravermistakes/Ada-Spark_ML-DSA-87` (`lthing-spark/`)
**Scope**: Generics refactor, FIPS 204 completion, timing side-channel elimination
**Verification**: Every change below is mechanically checkable — `gprbuild` must succeed, `gnatprove` must discharge all VCs, NIST ACVP test vectors must pass. No narrative claims.

---

## 0. Prerequisite Fixes

### L14: Makefile `|| true` Mask

The Makefile swallows build failures:

```makefile
# CURRENT (line 14)
gprbuild -P lthing.gpr || true

# PATCH
gprbuild -P lthing.gpr
```

Remove `|| true`. A build that fails should fail.

### M12: Keccak Rate/Domain Precondition Gap

`Sponge` accepts any `Rate <= 200` and any `Domain : Byte`, but FIPS 202 defines exactly four valid combinations. Add a type constraint:

```ada
-- In lthing_keccak.ads

type Sponge_Mode is (SHAKE_128, SHAKE_256, SHA3_256, SHA3_512);

type Mode_Params is record
   Rate   : Positive;
   Domain : Byte;
end record;

Mode_Table : constant array (Sponge_Mode) of Mode_Params :=
  (SHAKE_128 => (Rate => 168, Domain => 16#1F#),
   SHAKE_256 => (Rate => 136, Domain => 16#1F#),
   SHA3_256  => (Rate => 136, Domain => 16#06#),
   SHA3_512  => (Rate =>  72, Domain => 16#06#));

procedure Sponge
  (Input  : Byte_Array;
   Mode   : Sponge_Mode;
   Output : out Byte_Array)
with
  Pre => Output'Length > 0;
```

The old `(Rate, Domain)` signature stays as a `pragma Inline` private wrapper if needed for testing, but all ML-DSA code calls the `Sponge_Mode` variant. This makes invalid mode pairs unrepresentable.

---

## 1. Generics: Eliminating Duplication

### 1.1 The Parameter Set

FIPS 204 Table 1 defines three parameter sets. Every piece of duplicated code differs only in these constants:

| Parameter     | ML-DSA-44 | ML-DSA-65 | ML-DSA-87 |
|---------------|-----------|-----------|-----------|
| K             | 4         | 6         | 8         |
| L             | 4         | 5         | 7         |
| Eta           | 2         | 4         | 2         |
| Tau           | 39        | 49        | 60        |
| Beta          | 78        | 196       | 120       |
| Omega         | 80        | 55        | 75        |
| Gamma1        | 2^17      | 2^19      | 2^19      |
| Gamma2        | (q-1)/88  | (q-1)/32  | (q-1)/32  |
| C_Tilde_Bytes | 32        | 48        | 64        |
| PK_Bytes      | 1312      | 1952      | 2592      |
| Sig_Bytes     | 2420      | 3309      | 4627      |

### 1.2 Generic Parameter Package

Create a single spec that every downstream generic imports:

```ada
-- lthing_mldsa_params.ads

with Lthing_MLDSA_NTT; use Lthing_MLDSA_NTT;

generic
   K_Dim         : Positive;
   L_Dim         : Positive;
   Eta           : Positive;
   Tau           : Positive;
   Beta_Bound    : Integer_32;   -- "Beta" is an Ada reserved attribute
   Omega         : Positive;
   Gamma1        : Integer_32;
   Gamma2        : Integer_32;
   C_Tilde_Bytes : Positive;
   PK_Bytes      : Positive;
   Sig_Bytes     : Positive;
package Lthing_MLDSA_Params
  with SPARK_Mode => On
is
   subtype K_Range is Positive range 1 .. K_Dim;
   subtype L_Range is Positive range 1 .. L_Dim;

   type K_Vec is array (K_Range) of Poly;
   type L_Vec is array (L_Range) of Poly;
   type Matrix is array (K_Range, L_Range) of Poly;

   subtype Public_Key is Byte_Array (1 .. PK_Bytes);
   subtype Signature  is Byte_Array (1 .. Sig_Bytes);

   type Secret_Key is record
      Rho : Byte_Array (1 .. 32);
      KK  : Byte_Array (1 .. 32);
      Tr  : Byte_Array (1 .. 64);
      S1  : L_Vec;
      S2  : K_Vec;
      T0  : K_Vec;
   end record;
end Lthing_MLDSA_Params;
```

### 1.3 Generic Codec

Collapse `lthing_mldsa_codec` and `lthing_mldsa87_codec`:

```ada
-- lthing_mldsa_codec.ads (replaces both)

with Lthing_MLDSA_Params;

generic
   with package Params is new Lthing_MLDSA_Params (<>);
package Lthing_MLDSA_Codec
  with SPARK_Mode => On
is
   use Params;

   procedure Pk_Encode
     (Rho : Byte_Array;
      T1  : K_Vec;
      PK  : out Public_Key)
   with Pre => Rho'Length = 32;

   procedure Pk_Decode
     (PK  : Public_Key;
      Rho : out Byte_Array;
      T1  : out K_Vec)
   with Pre => Rho'Length = 32;

   procedure Sig_Encode
     (C_Tilde : Byte_Array;
      Z       : L_Vec;
      H       : K_Vec;
      Sig     : out Signature)
   with Pre => C_Tilde'Length = C_Tilde_Bytes;

   procedure Sig_Decode
     (Sig     : Signature;
      C_Tilde : out Byte_Array;
      Z       : out L_Vec;
      H       : out K_Vec;
      Ok      : out Boolean)
   with Pre => C_Tilde'Length = C_Tilde_Bytes;
end Lthing_MLDSA_Codec;
```

The body uses `K_Dim`, `L_Dim`, `C_Tilde_Bytes` from the `Params` formal package — no constants change, only the instantiation.

### 1.4 Generic Sampler

Collapse `lthing_mldsa_sample` and `lthing_mldsa87_sample`:

```ada
-- lthing_mldsa_sample.ads (replaces both)

with Lthing_MLDSA_Params;

generic
   with package Params is new Lthing_MLDSA_Params (<>);
package Lthing_MLDSA_Sample
  with SPARK_Mode => On
is
   use Params;

   procedure Sample_In_Ball
     (Seed : Byte_Array;
      C    : out Poly)
   with Pre => Seed'Length = C_Tilde_Bytes;
   -- Uses Tau from Params. Full scan, no early exit.

   procedure Rej_NTT_Poly
     (Rho   : Byte_Array;
      Nonce : Interfaces.Unsigned_16;
      P     : out Poly)
   with Pre => Rho'Length = 34;

   procedure Expand_A
     (Rho : Byte_Array;
      A   : out Matrix)
   with Pre => Rho'Length = 32;
   -- Dimensions K_Dim x L_Dim from Params.
end Lthing_MLDSA_Sample;
```

### 1.5 Generic Verifier

Collapse `lthing_mldsa65` and `lthing_mldsa87`:

```ada
-- lthing_mldsa_verify.ads (replaces both)

with Lthing_MLDSA_Params;
with Lthing_MLDSA_Codec;
with Lthing_MLDSA_Sample;

generic
   with package Params is new Lthing_MLDSA_Params (<>);
   with package Codec  is new Lthing_MLDSA_Codec (Params);
   with package Sample is new Lthing_MLDSA_Sample (Params);
package Lthing_MLDSA_Verify
  with SPARK_Mode => On
is
   use Params;

   function Verify
     (PK      : Public_Key;
      Message : Byte_Array;
      Context : Byte_Array;
      Sig     : Signature) return Boolean
   with Pre => Context'Length <= 255;
end Lthing_MLDSA_Verify;
```

The body contains `Add_Poly`/`Sub_Poly` as local subprograms — written once.

### 1.6 Generic Signer

Extend `lthing_mldsa_sign` to work for all parameter sets:

```ada
-- lthing_mldsa_sign.ads (replaces current ML-DSA-65-only signer)

with Lthing_MLDSA_Params;
with Lthing_MLDSA_Codec;
with Lthing_MLDSA_Sample;

generic
   with package Params is new Lthing_MLDSA_Params (<>);
   with package Codec  is new Lthing_MLDSA_Codec (Params);
   with package Sample is new Lthing_MLDSA_Sample (Params);
package Lthing_MLDSA_Sign
  with SPARK_Mode => On
is
   use Params;

   procedure Key_Gen
     (Seed : Byte_Array;
      PK   : out Public_Key;
      SK   : out Secret_Key)
   with Pre => Seed'Length = 32;

   procedure Sign
     (SK      : Secret_Key;
      Message : Byte_Array;
      Context : Byte_Array;
      Sig     : out Signature;
      Ok      : out Boolean)
   with Pre => Context'Length <= 255;

   Max_Attempts : constant := 1000;
end Lthing_MLDSA_Sign;
```

### 1.7 Instantiations

```ada
-- lthing_mldsa44_instance.ads
with Lthing_MLDSA_Params;
package Lthing_MLDSA44_Params is new Lthing_MLDSA_Params
  (K_Dim => 4, L_Dim => 4, Eta => 2, Tau => 39,
   Beta_Bound => 78, Omega => 80,
   Gamma1 => 2**17, Gamma2 => 95232,   -- (q-1)/88
   C_Tilde_Bytes => 32, PK_Bytes => 1312, Sig_Bytes => 2420);

-- lthing_mldsa65_instance.ads
with Lthing_MLDSA_Params;
package Lthing_MLDSA65_Params is new Lthing_MLDSA_Params
  (K_Dim => 6, L_Dim => 5, Eta => 4, Tau => 49,
   Beta_Bound => 196, Omega => 55,
   Gamma1 => 2**19, Gamma2 => 261888,  -- (q-1)/32
   C_Tilde_Bytes => 48, PK_Bytes => 1952, Sig_Bytes => 3309);

-- lthing_mldsa87_instance.ads
with Lthing_MLDSA_Params;
package Lthing_MLDSA87_Params is new Lthing_MLDSA_Params
  (K_Dim => 8, L_Dim => 7, Eta => 2, Tau => 60,
   Beta_Bound => 120, Omega => 75,
   Gamma1 => 2**19, Gamma2 => 261888,  -- (q-1)/32
   C_Tilde_Bytes => 64, PK_Bytes => 2592, Sig_Bytes => 4627);

-- Then for each:
-- package MLDSA65_Codec  is new Lthing_MLDSA_Codec  (Lthing_MLDSA65_Params);
-- package MLDSA65_Sample is new Lthing_MLDSA_Sample (Lthing_MLDSA65_Params);
-- package MLDSA65_Verify is new Lthing_MLDSA_Verify (Lthing_MLDSA65_Params, MLDSA65_Codec, MLDSA65_Sample);
-- package MLDSA65_Sign   is new Lthing_MLDSA_Sign   (Lthing_MLDSA65_Params, MLDSA65_Codec, MLDSA65_Sample);
```

### 1.8 Migration Path

1. Write the generic specs and bodies first. Compile — `gprbuild` must succeed.
2. Write the three instantiation packages.
3. Update `lthing_judicial.ads` to dispatch through `MLDSA65_Verify.Verify` and `MLDSA87_Verify.Verify` instead of the old standalone packages.
4. Delete the six old files: `lthing_mldsa_codec`, `lthing_mldsa87_codec`, `lthing_mldsa_sample`, `lthing_mldsa87_sample`, `lthing_mldsa65`, `lthing_mldsa87`.
5. Run NIST ACVP vectors for all three parameter sets.

Do **not** attempt steps 4-5 until step 3 compiles and proves clean.

---

## 2. Timing Side-Channel Elimination

Every fix below replaces a branch on secret-dependent data with an arithmetic equivalent. The property to verify: `gnatprove` must still discharge all VCs (the postconditions don't change, only the implementation path). The property you **cannot** verify with gnatprove: constant-time execution. That requires inspecting the generated assembly (`objdump -d`) to confirm no conditional branches remain on the hot path.

### 2.1 Field Arithmetic: Barrett Reduction

**Current** (`lthing_mldsa_field.adb`): `Reduce`, `Add`, `Mul` all use `mod Q`. The Ada `mod` operator on `Integer_64` compiles to a division instruction, which is variable-time on most x86 microarchitectures for ML-DSA's `q = 8380417`.

**Patch**: Two constant-time reductions, each matched to its input range.

**`Add`/`Sub`**: inputs are at most 2*(q-1). A single branchless conditional
subtraction suffices — no Barrett needed:

```ada
function Add (A, B : Fq) return Fq
  with SPARK_Mode => On
is
   S  : constant Unsigned_64 := Unsigned_64 (A) + Unsigned_64 (B);
   D  : constant Unsigned_64 := S - Unsigned_64 (Q);
   Hi : constant Unsigned_64 := Shift_Right (D, 63);
   --  Hi = 0 if S >= Q (keep D), Hi = 1 if S < Q (undo subtraction)
begin
   return Fq (D + Unsigned_64 (Q) * Hi);
end Add;
```

**`Reduce`** (bounded inputs from NTT butterfly accumulation, |x| < 2^31):
Barrett reduction with the constants from the Dilithium/ML-DSA reference
implementation:

```ada
Barrett_V     : constant := 8;   -- round(2**26 / Q)
Barrett_Shift : constant := 26;

function Barrett_Reduce (X : Wide) return Fq
  with SPARK_Mode => On,
       Pre => X >= 0 and X < 2**31
is
   T : constant Wide := (X * Barrett_V) / 2**Barrett_Shift;
   R : Wide := X - T * Q;
   RU : Unsigned_64 := Unsigned_64 (R);
   D  : constant Unsigned_64 := RU - Unsigned_64 (Q);
   Hi : constant Unsigned_64 := Shift_Right (D, 63);
begin
   RU := D + Unsigned_64 (Q) * Hi;
   return Fq (RU);
end Barrett_Reduce;
```

**`Mul`**: products reach (q-1)^2 ~ 7*10^13 (47 bits). Barrett reduction
within 64-bit arithmetic cannot achieve single-subtraction correctness at
this range (Barrett_Shift would need to be >= 46, but then x * Barrett_M
overflows 64 bits). The Dilithium/ML-DSA reference implementation uses
**Montgomery multiplication** instead:

```ada
Q_Inv : constant Unsigned_32 := 58_728_449;
--  q * Q_Inv = 1 (mod 2**32), verified.

function Montgomery_Reduce (X : Integer_64) return Fq
  with SPARK_Mode => On
is
   T : Integer_32;
   R : Integer_64;
begin
   T := Integer_32 (Unsigned_32 (X) * Q_Inv);
   R := (X - Integer_64 (T) * Q) / 2**32;
   --  R is in (-q, q); one conditional add:
   declare
      RU   : Unsigned_64 := Unsigned_64 (R + Q);
      D    : constant Unsigned_64 := RU - Unsigned_64 (Q);
      Hi   : constant Unsigned_64 := Shift_Right (D, 63);
   begin
      RU := D + Unsigned_64 (Q) * Hi;
      return Fq (RU);
   end;
end Montgomery_Reduce;

function Mul (A, B : Fq) return Fq is
begin
   return Montgomery_Reduce (Integer_64 (A) * Integer_64 (B));
end Mul;
```

**Note**: Montgomery multiplication returns results in Montgomery form
(a * 2^32 mod q). All NTT coefficients must be stored in Montgomery form;
convert on entry/exit with `Montgomery_Reduce(Integer_64(x) * R2_Mod_Q)`
where `R2_Mod_Q = (2^32)^2 mod q`. This matches the reference implementation.

Replace `mod Q` in `Add` and `Sub` with the branchless conditional
subtraction above. Replace `Mul` with Montgomery multiplication.
Replace `Reduce` with `Barrett_Reduce` for bounded NTT inputs.

### 2.2 `To_Centered`: Branchless

**Current**:
```ada
function To_Centered (A : Fq) return Integer_32 is
begin
   if A > Q / 2 then return Integer_32 (A) - Integer_32 (Q);
   else return Integer_32 (A);
   end if;
end To_Centered;
```

**Patch**:
```ada
function To_Centered (A : Fq) return Integer_32
  with SPARK_Mode => On
is
   Val   : constant Integer_32 := Integer_32 (A);
   Half  : constant Integer_32 := Integer_32 (Q / 2);
   -- Mask is -1 (all ones) if Val > Half, else 0
   Gt    : constant Integer_32 := -Boolean'Pos (Val > Half);
   -- But again, verify assembly. Unsigned fallback:
   Diff  : constant Interfaces.Unsigned_32 :=
     Interfaces.Unsigned_32 (Half) - Interfaces.Unsigned_32 (Val);
   Sign  : constant Interfaces.Unsigned_32 :=
     Interfaces.Shift_Right (Diff, 31);   -- 1 if Val > Half, else 0
   Mask  : constant Integer_32 := -Integer_32 (Sign);
begin
   return Val - (Integer_32 (Q) and Mask);
end To_Centered;
```

### 2.3 `Inf_Norm_OK`: Full Scan, No Early Return

**Current** (`lthing_mldsa_round.adb`):
```ada
function Inf_Norm_OK (P : Poly; Bound : Integer_32) return Boolean is
begin
   for I in P'Range loop
      if abs (To_Centered (P (I))) >= Bound then
         return False;   -- EARLY EXIT: timing leak
      end if;
   end loop;
   return True;
end Inf_Norm_OK;
```

**Patch**:
```ada
function Inf_Norm_OK (P : Poly; Bound : Integer_32) return Boolean
  with SPARK_Mode => On
is
   Fail : Interfaces.Unsigned_32 := 0;
begin
   for I in P'Range loop
      declare
         C : constant Integer_32 := To_Centered (P (I));  -- use branchless version
         Abs_C : constant Interfaces.Unsigned_32 :=
           Interfaces.Unsigned_32 (abs C);  -- abs is branchless on most arch
         Exceeds : constant Interfaces.Unsigned_32 :=
           Interfaces.Shift_Right (
             Interfaces.Unsigned_32 (Bound) - Abs_C - 1, 31);
         -- Exceeds = 1 if Abs_C >= Bound (underflow sets high bit), else 0
      begin
         Fail := Fail or Exceeds;
      end;
   end loop;
   return Fail = 0;
end Inf_Norm_OK;
```

This always iterates all 256 coefficients. Loop invariant for gnatprove:

```ada
pragma Loop_Invariant (Fail <= 1);
```

### 2.4 `Mod_Pm`: Branchless Centered Modular Reduction

**Current**:
```ada
function Mod_Pm (A : Integer_32; M : Positive) return Integer_32 is
   R : Integer_32 := A mod Integer_32 (M);
begin
   if R > Integer_32 (M) / 2 then
      R := R - Integer_32 (M);
   end if;
   return R;
end Mod_Pm;
```

**Patch** (same pattern as `To_Centered` — branchless conditional subtraction):

```ada
function Mod_Pm (A : Integer_32; M : Positive) return Integer_32
  with SPARK_Mode => On
is
   MV   : constant Integer_32 := Integer_32 (M);
   R    : Integer_32 := Barrett_Reduce_General (A, M);  -- or use mod if M is public
   -- M (= 2*Gamma2) is a public parameter, not secret.
   -- The branch danger is that R depends on A, which may be secret.
   Half : constant Integer_32 := MV / 2;
   Diff : constant Interfaces.Unsigned_32 :=
     Interfaces.Unsigned_32 (Half) - Interfaces.Unsigned_32 (R);
   Sign : constant Interfaces.Unsigned_32 :=
     Interfaces.Shift_Right (Diff, 31);
   Mask : constant Integer_32 := -Integer_32 (Sign);
begin
   return R - (MV and Mask);
end Mod_Pm;
```

**Critical note**: `A mod M` itself is safe here **only if** the compiler's division is constant-time for the specific `M` values used (Gamma2 variants: 95232 and 261888). Since these are public constants known at compile time, GNAT may optimize to a multiplication-based reduction. **Verify the assembly.** If variable-time division appears, implement a dedicated Barrett reduction for each Gamma2 value.

### 2.5 `Decompose`: Branchless Corner Case

The existing `Decompose` has a conditional correction when `r1 = (q-1)/(2*Gamma2)`. This correction must be branchless:

```ada
-- Inside Decompose, after computing R1 and R0:
-- The branch: if R0 = Gamma2 then R1 := R1 + 1; R0 := 0; end if;
-- becomes:
declare
   Eq : constant Interfaces.Unsigned_32 :=
     CT_Eq (Interfaces.Unsigned_32 (R0),
            Interfaces.Unsigned_32 (Gamma2));
   -- CT_Eq returns 0xFFFFFFFF if equal, 0 otherwise
begin
   R1 := R1 + Integer_32 (Eq and 1);
   R0 := R0 and not Integer_32 (Eq);  -- R0 = 0 if was equal
end;
```

Where `CT_Eq` is a utility:

```ada
function CT_Eq (A, B : Interfaces.Unsigned_32) return Interfaces.Unsigned_32
  with SPARK_Mode => On, Inline
is
   -- Returns all-ones if A = B, all-zeros otherwise.
   -- XOR gives 0 iff equal. Then: (x | -x) has high bit set iff x /= 0.
   X : constant Interfaces.Unsigned_32 := A xor B;
   V : constant Interfaces.Unsigned_32 := X or (0 - X);
begin
   return 0 - (Interfaces.Shift_Right (V, 31) xor 1);
end CT_Eq;
```

### 2.6 `Make_Hint_Bit` and `Hint_Weight`: Full Scan

Same pattern as `Inf_Norm_OK`. Replace any early-return counting with an accumulator that always processes every element:

```ada
function Hint_Weight (H : K_Vec) return Natural
  with SPARK_Mode => On
is
   Count : Natural := 0;
begin
   for I in H'Range loop
      for J in H (I)'Range loop
         Count := Count + Natural (H (I) (J));
         -- H coefficients are 0 or 1, so this is safe
      end loop;
      pragma Loop_Invariant (Count <= (I - H'First + 1) * 256);
   end loop;
   return Count;
end Hint_Weight;
```

The **check** `Hint_Weight(H) > Omega` must also be done without early exit — compute the full weight, then compare once at the end.

### 2.7 Key Erasure

After signing, zero the secret key material. Ada doesn't guarantee the compiler won't optimize this away. Use a volatile write:

```ada
procedure Secure_Wipe (X : in out Byte_Array)
  with SPARK_Mode => On
is
begin
   for I in X'Range loop
      X (I) := 0;
      pragma Annotate (GNATprove, Intentional,
        "unused assignment", "security: prevent dead-store elimination");
   end loop;
   -- Force the compiler to keep the writes:
   pragma Inspection_Point (X);
end Secure_Wipe;
```

`pragma Inspection_Point` is the standard Ada mechanism to prevent dead-store elimination. Apply to intermediate secret buffers in `Sign` (the `Rho'`, `KK`, nonce `Kappa`, and any expanded-key material).

### 2.8 Constant-Time Utility Package

Collect all the branchless helpers:

```ada
-- lthing_mldsa_ct.ads

with Interfaces; use Interfaces;

package Lthing_MLDSA_CT
  with SPARK_Mode => On, Pure
is
   function CT_Select_U32
     (A, B : Unsigned_32; Choose_B : Boolean) return Unsigned_32
     with Inline;
   -- Returns A if Choose_B = False, B if True. Branchless.

   function CT_Eq (A, B : Unsigned_32) return Unsigned_32
     with Inline;
   -- All-ones mask if A = B, all-zeros otherwise.

   function CT_Ge (A, B : Unsigned_32) return Unsigned_32
     with Inline;
   -- All-ones mask if A >= B, all-zeros otherwise.

   procedure Secure_Wipe (X : in out Byte_Array)
     with Depends => (X => null);
end Lthing_MLDSA_CT;
```

---

## 3. FIPS 204 Completion

### 3.1 What Exists Now

| Component          | ML-DSA-44 | ML-DSA-65 | ML-DSA-87 |
|-------------------|-----------|-----------|-----------|
| Verify            | —         | Yes       | Yes       |
| Sign              | —         | Yes       | —         |
| Key_Gen           | —         | Yes       | —         |
| Codec             | —         | Yes       | Yes       |
| Sample            | —         | Yes       | Yes       |
| HashML-DSA        | —         | —         | —         |
| Hedged signing    | —         | —         | —         |

### 3.2 After Generics (Free)

Once the generic packages exist and are instantiated (Section 1), you get ML-DSA-44 and ML-DSA-87 signing/keygen/verify with **zero new logic** — just new instantiation packages. This is the entire point of the refactor.

### 3.3 HashML-DSA (FIPS 204 §5.4)

HashML-DSA pre-hashes the message with a collision-resistant hash before signing. The modification is small — it wraps the message in an OID-tagged envelope before passing to the internal `Sign`/`Verify`:

```ada
-- lthing_mldsa_hash.ads

with Lthing_MLDSA_Params;
with Lthing_MLDSA_Sign;
with Lthing_MLDSA_Verify;

generic
   with package Params is new Lthing_MLDSA_Params (<>);
   with package Signer is new Lthing_MLDSA_Sign (Params, others);
   with package Verifier is new Lthing_MLDSA_Verify (Params, others);
package Lthing_MLDSA_Hash
  with SPARK_Mode => On
is
   use Params;

   type Hash_OID is (SHA256, SHA512, SHA3_256, SHA3_512, SHAKE128, SHAKE256);

   procedure Hash_Sign
     (SK      : Secret_Key;
      Message : Byte_Array;
      Context : Byte_Array;
      PHoid   : Hash_OID;
      Sig     : out Signature;
      Ok      : out Boolean)
   with Pre => Context'Length <= 255;

   function Hash_Verify
     (PK      : Public_Key;
      Message : Byte_Array;
      Context : Byte_Array;
      PHoid   : Hash_OID;
      Sig     : Signature) return Boolean
   with Pre => Context'Length <= 255;
end Lthing_MLDSA_Hash;
```

The body constructs `M' = 0x01 || len(ctx) || ctx || OID || PH(msg)` per FIPS 204 §5.4.1 and calls through to the internal signer/verifier.

### 3.4 Hedged Signing (FIPS 204 §3.4, Algorithm 2 line 5)

Hedged signing concatenates additional randomness into the nonce derivation to protect against fault attacks. Per FIPS 204 Algorithm 7 line 7, the private random seed is computed as `rho'' = H(K || rnd || mu, 64)` where `rnd` is 32 bytes of fresh randomness (hedged) or 32 zero bytes (deterministic). The change is localized to `Sign` body:

```ada
-- In Sign body, where rnd is generated:
-- Standard (deterministic): rnd := (others => 0);
-- Hedged: rnd := OS_Random (32);  -- 32 bytes from system CSPRNG

-- The generic Sign procedure should take a mode parameter:
type Signing_Mode is (Deterministic, Hedged);

procedure Sign
  (SK      : Secret_Key;
   Message : Byte_Array;
   Context : Byte_Array;
   Mode    : Signing_Mode;
   Sig     : out Signature;
   Ok      : out Boolean);
```

For the CSPRNG source: use `/dev/urandom` via `Ada.Streams.Stream_IO` or bind to `getentropy(2)`. Keep the CSPRNG interface behind a thin abstraction so it can be replaced for deterministic test vectors.

### 3.5 Implementation Order

This is a dependency chain — do not skip ahead:

1. **Constant-time utilities** (`lthing_mldsa_ct`) — no dependencies, proves independently.
2. **Patch field arithmetic** with Barrett reduction — depends on (1).
3. **Patch rounding/decompose** with branchless ops — depends on (1).
4. **Keccak M12 fix** — independent of above.
5. **Generic parameter package** — depends on existing NTT.
6. **Generic codec** — depends on (5).
7. **Generic sampler** — depends on (5), (4).
8. **Generic verifier** — depends on (5), (6), (7), (3).
9. **Generic signer** with constant-time fixes — depends on (5), (6), (7), (2), (3), (1).
10. **Instantiate ML-DSA-44, -65, -87** — depends on (8), (9).
11. **Update judicial dispatcher** — depends on (10).
12. **Delete old duplicated packages** — depends on (11) passing all tests.
13. **HashML-DSA wrapper** — depends on (9), (8).
14. **Hedged signing** — depends on (9), CSPRNG binding.

### 3.6 Test Verification

For each instantiation, run the NIST ACVP test vectors (available at https://github.com/usnistgov/ACVP-Server/tree/master/gen-val/json-files):

- `ML-DSA-44`: keyGen, sigGen, sigVer
- `ML-DSA-65`: keyGen, sigGen, sigVer (regression against existing tests)
- `ML-DSA-87`: keyGen, sigGen, sigVer

**Do not write a custom test harness that reports pass/fail.** Instead:
- Decode the ACVP JSON test vectors into Ada constant arrays (one file per vector group).
- Write a `main` that calls `Key_Gen`/`Sign`/`Verify` with the test inputs and writes the raw outputs to stdout as hex.
- Diff the stdout hex against the expected values with `diff`.
- The test passes if and only if `diff` returns 0.

This structure makes it impossible for a test harness to mask a failure — there is no pass/fail logic to get wrong.

---

## 4. Assembly Audit Checklist

After implementing all patches, for each of the functions below, run:

```bash
gnatmake -P lthing.gpr -cargs -O2 -S
# or
objdump -d lthing_mldsa_field.o | grep -A 50 'barrett_reduce'
```

Confirm **no conditional jump instructions** (`je`, `jne`, `jg`, `jl`, `jge`, `jle`, `jb`, `ja`) appear in:

- [ ] `Barrett_Reduce`
- [ ] `To_Centered`
- [ ] `Inf_Norm_OK` (inner loop)
- [ ] `Mod_Pm`
- [ ] `Decompose` (correction branch)
- [ ] `Make_Hint_Bit`
- [ ] `Hint_Weight`
- [ ] `Secure_Wipe` (not optimized away)

If GNAT emits branches despite the branchless source, the options are:

1. `-O2 -gnatG` to check the expanded code, then adjust the Ada source.
2. Use `pragma Machine_Attribute` to request `cmov` patterns.
3. Last resort: inline assembly via `System.Machine_Code` for the critical reduction step.

---

## 5. Files Created / Deleted

### New files:
- `lthing_mldsa_ct.ads` / `.adb` — constant-time utilities
- `lthing_mldsa_params.ads` — generic parameter package
- `lthing_mldsa_codec.ads` / `.adb` — generic codec (replaces two old files)
- `lthing_mldsa_sample.ads` / `.adb` — generic sampler (replaces two old files)
- `lthing_mldsa_verify.ads` / `.adb` — generic verifier (replaces two old files)
- `lthing_mldsa_sign.ads` / `.adb` — generic signer (replaces ML-DSA-65-only signer)
- `lthing_mldsa44_instance.ads` — ML-DSA-44 instantiation
- `lthing_mldsa65_instance.ads` — ML-DSA-65 instantiation
- `lthing_mldsa87_instance.ads` — ML-DSA-87 instantiation
- `lthing_mldsa_hash.ads` / `.adb` — HashML-DSA wrapper

### Modified files:
- `lthing_keccak.ads` / `.adb` — `Sponge_Mode` enum, type-safe interface
- `lthing_mldsa_field.ads` / `.adb` — Barrett reduction
- `lthing_mldsa_round.ads` / `.adb` — branchless `Inf_Norm_OK`, `Mod_Pm`, `Decompose`
- `lthing_judicial.ads` / `.adb` — dispatch through new instantiations
- `Makefile` — remove `|| true`

### Deleted files (only after all tests pass):
- `lthing_mldsa87_codec.ads` / `.adb`
- `lthing_mldsa87_sample.ads` / `.adb`
- `lthing_mldsa65.ads` / `.adb` (old standalone verifier)
- `lthing_mldsa87.ads` / `.adb` (old standalone verifier)

---

## 6. What This Does Not Cover

- **Formal constant-time verification** (e.g., ct-verif, dudect). The assembly audit in §4 is necessary but not sufficient — microarchitectural side channels (cache timing, speculative execution) are out of scope for this patch.
- **Side-channel hardened NTT**. The current NTT accesses are index-independent (butterfly pattern), which is fine. If you later add table-based multiplication, that changes.
- **FIPS 140-3 module boundary requirements**. This patch addresses algorithmic correctness and timing channels, not the procedural/documentation requirements of CMVP validation.
- **Performance benchmarking**. Barrett reduction is expected to be faster than division-based `mod`, but measure it.
