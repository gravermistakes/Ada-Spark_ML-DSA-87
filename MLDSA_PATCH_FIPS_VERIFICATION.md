# FIPS Verification: MLDSA_PATCH_RECOMMENDATION.md

Cross-referenced against **FIPS 204** (ML-DSA, August 2024) and **FIPS 202** (SHA-3).

## Verified Correct

### Parameter Table (§1.1) — matches FIPS 204 Table 1 + Table 2

| Parameter     | ML-DSA-44 | ML-DSA-65 | ML-DSA-87 | Source       |
|---------------|-----------|-----------|-----------|--------------|
| K, L          | (4,4)     | (6,5)     | (8,7)     | Table 1      |
| Eta           | 2         | 4         | 2         | Table 1      |
| Tau           | 39        | 49        | 60        | Table 1      |
| Beta          | 78        | 196       | 120       | Table 1 (=Tau*Eta) |
| Omega         | 80        | 55        | 75        | Table 1      |
| Gamma1        | 2^17      | 2^19      | 2^19      | Table 1      |
| Gamma2        | (q-1)/88  | (q-1)/32  | (q-1)/32  | Table 1      |
| C_Tilde_Bytes | 32        | 48        | 64        | Lambda/4     |
| PK_Bytes      | 1312      | 1952      | 2592      | Table 2      |
| Sig_Bytes     | 2420      | 3309      | 4627      | Table 2      |

- **q = 8380417** (= 2^23 - 2^13 + 1): correct per FIPS 204.
- **Gamma2 computed**: 95232 = (q-1)/88, 261888 = (q-1)/32: correct.
- **Barrett_M = 1025**: floor(2^33 / 8380417) = 1025: arithmetically correct.
- **HashML-DSA M' format (§3.3)**: `0x01 || len(ctx) || ctx || OID || PH(M)` matches
  FIPS 204 Algorithm 4, line 23.
- **Secret_Key fields (§1.2)**: Rho(32), K(32), Tr(64), S1(L_Vec), S2(K_Vec), T0(K_Vec)
  matches FIPS 204 KeyGen_internal.
- **Hedged signing code (§3.4)**: `rnd := OS_Random(32)` hedged, `(others => 0)`
  deterministic — matches Algorithm 2 line 5.
- **Sponge mode table (§0 M12)**: all four rate/domain pairs match FIPS 202:
  SHAKE128 (168, 0x1F), SHAKE256 (136, 0x1F), SHA3-256 (136, 0x06), SHA3-512 (72, 0x06).

## Errors

### E1. Barrett_Shift = 33 insufficient for Mul — SERIOUS

**Location**: §2.1, `Barrett_Shift : constant := 33`

The patch applies `Barrett_Reduce` to `Add`, `Mul`, and `Reduce`. For Mul inputs
(two field elements in [0, q-1], product up to (q-1)^2 = 70,231,372,333,056), a
Barrett_Shift of 33 produces a quotient error of **7**:

```
Barrett_t = floor((q-1)^2 * 1025 / 2^33) = 8,380,408
True quotient = floor((q-1)^2 / q)        = 8,380,415
Error = 7
R = (q-1)^2 - 8,380,408 * q = 58,662,920 ≈ 7 * q
```

The single conditional subtraction in the code handles R in [0, 2q) only.
Correct Barrett_Shift for single-subtraction on multiply results: **>= 46**.

The comment `-- ceil(log2(q)) * 2 + 1` is also arithmetically wrong:
ceil(log2(8380417)) = 23, and 23*2+1 = **47**, not 33.

### E2. CT_Eq has two return statements — dead code bug

**Location**: §2.5

```ada
begin
   return Interfaces.Shift_Right (V, 31) xor 1;        -- executes: gives 0 or 1
   return 0 - (Interfaces.Shift_Right (V, 31) xor 1);  -- dead: gives mask
end CT_Eq;
```

The first (reachable) return yields 0 or 1, not an all-ones mask. The usage in
Decompose (§2.5) expects a mask: `R0 := R0 and not Integer_32(Eq)`. With Eq=1,
`not 1 = 16#FFFFFFFE#`, clearing only bit 0 instead of zeroing R0.

Fix: delete the first return statement.

### E3. Hedged signing prose says "XORs" — should say "concatenates"

**Location**: §3.4, first paragraph.

FIPS 204 Algorithm 7 line 7: `rho'' <- H(K || rnd || mu, 64)`. rnd is
**concatenated**, not XORed. The code in the patch is correct; only the prose
description is wrong.

### E4. Section reference "§5.2, Note 4" is about context strings, not hedged signing

**Location**: §3.4 heading.

Footnote 4 in FIPS 204 §5.2 discusses default context strings. The hedged/
deterministic description is in Section 3.4 (prose) and Algorithm 2 line 5
(mechanism).

## Summary

E1 and E2 are implementation-affecting: E1 would produce incorrect field
arithmetic for products, E2 would produce incorrect Decompose corrections.
E3 and E4 are documentation-only inaccuracies. All parameter values, sizes, and
algorithmic descriptions are otherwise faithful to FIPS 204 and FIPS 202.
