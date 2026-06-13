# LTHING Ada/SPARK Control Layer — Proof Report

**Component:** .jd.lthing parse-and-verify (judicial / legal path)
**For:** Anja Evermoor, CulpabilityAnchor
**Date:** 2026-06-06  |  **Epoch:** 1780769748
**Toolchain:** GNAT 13.3.0 + gnatprove 14.1.1 (Why3 1.6.0; solvers Z3, cvc5, alt-ergo 2.4.0)
**Posture:** SPARK_Mode (On), proof level 2
**License:** GPL-3.0-or-later

## Result

```
gnatprove --level=2 --report=all : 0 high, 0 medium, 0 low. All checks proved.
```

14 verification conditions discharged across the unit. The two legally
load-bearing postconditions are proved by SMT solver, not asserted:

| Obligation | Location | Meaning |
|------------|----------|---------|
| Parse_Unverified postcondition | lthing_judicial.ads:51 | Structural parse can NEVER return a trusted record (Trusted=False, Status≠Verified always). Kills audit root-cause Pattern 3. |
| Parse_And_Verify postcondition | lthing_judicial.ads:80 | Fail-closed: Trusted=True iff Status=Verified; every failure path forces Trusted=False. This is the requirement reassigned from retired FINDING-006. |
| Verified_Record predicate | lthing_types.ads:51 | No code path anywhere can desync Trusted from Status. Proved at every assignment. |

## What this resolves from the AVRS audit

- **FINDING-006** (parser performs no cryptographic verification): the control
  layer now exposes two distinct operations. Parse_Unverified is *provably*
  incapable of returning trust; Parse_And_Verify is *provably* fail-closed.
- **Audit Pattern 1** (stubs that fail open): the ML-DSA-65 boundary
  (Verify_Signature) REJECTS by default. No real verifier is linked yet (the
  asm library lacks ML-DSA), so the pipeline fails closed today — the safe
  inverse of the original FINDING-002 "stub returns True."

## Honest residuals (court-grade means stating these)

1. **ML-DSA-65 verifier is not yet implemented.** Verify_Signature returns
   False unconditionally. The contracts are proven, but the layer cannot yet
   ACCEPT any real document — by design, until a verified ML-DSA-65 impl is
   linked. Replacing that body is the next crypto-critical task; do NOT make
   it return True before it genuinely verifies.
2. **Envelope slicing is minimal.** Envelope_Ok / Magic_Ok check size and the
   doctype byte; full PEM-block extraction and the carried-seal/carried-chain
   comparison are placeholders. The *trust gate* is proven sound regardless,
   because the signature gate rejects — but the seal/chain comparisons must be
   wired to real extracted fields before production.
3. **FFI boundary is outside SPARK.** The asm bodies (validated by the asm
   regression harness, 2026-06-06) are SPARK_Mode Off; gnatprove reasons about
   the Ada side only. This separation is documented in lthing_crypto_ffi.ads.
4. **Proof is of the contracts as written.** Soundness of the legal claim
   depends on the contracts capturing the right property; they were written to
   encode fail-closed, and runtime tests (test_judicial) confirm the behavior.

## Runtime confirmation

`test_judicial` (dynamic): 4/4 PASS — Parse_Unverified never trusted;
Parse_And_Verify fails closed at the signature gate; short envelope rejected;
Trusted↔Verified invariant holds. Static proof and runtime behavior agree.

---

## ML-DSA-65 Verifier — Part-by-Part Build Log

Pure Ada/SPARK, zero dependencies. Each part has its own gate; the verifier
stays fail-closed (Verify returns False) until Part 5 passes the full KAT.

### Part 1 — Z_q Field Arithmetic — COMPLETE (2026-06-06)

- Module: lthing_mldsa_field.ads/.adb
- q = 8380417 = 2**23 - 2**13 + 1 (FIPS 204, source-verified)
- Operations: Add, Sub, Mul, Reduce, To_Centered
- **Gate 1 (compile):** clean.
- **Gate 2 (proof):** gnatprove level 2 — all postconditions proved; every
  operation provably emits a canonical [0,q-1] (or centered) result. 0 unproved.
- **Gate 3 (known values):** 11/11 hand-computed cases pass, incl. (q-1)^2 = 1,
  subtraction underflow, 2q+7 reduction, centered q-1 -> -1.
- Status: BANKED. Self-validating, no external vectors needed.

### Parts 2-5 — PENDING (each gated, fail-closed until done)

- Part 2: NTT / inverse-NTT over Z_q (zeta table). Gate: roundtrip identity + vector.
- Part 3: ExpandA (SHAKE128) + SampleInBall. Gate: NIST KAT.
- Part 4: pk/sig decode (1952 / 3309 bytes) + z-norm & hint-weight bounds. Gate: decode KAT.
- Part 5: Verify assembly (w'1 = UseHint(h, Az - c*t1*2^d), recompute c~). Gate: full ML-DSA-65 verify KAT.

Until Part 5's KAT passes, LTHING_MLDSA65.Verify returns False and the judicial
gate rejects. Nothing is left in a partially-trusting state.

### Part 2 — NTT / Inverse-NTT over Z_q — COMPLETE (2026-06-06)

- Module: lthing_mldsa_ntt.ads/.adb
- 256-point negacyclic NTT, zeta = 1753 (FIPS 204). Zeta table COMPUTED at
  elaboration via bit-reversal (no transcribed constants).
- SPARK_Mode Off for the in-place butterflies (the field ops they call are
  proved, Part 1); validated by test.
- **Gate A (roundtrip):** INTT(NTT(a)) = a. PASS.
- **Gate B (convolution, strong):** NTT(a) o NTT(b) -> INTT == schoolbook
  negacyclic product mod (x^256+1). PASS on 2 independent vectors. This proves
  the transform is the CORRECT FIPS 204 NTT, not just self-consistent.
- Status: BANKED. Self-validating, no external vectors needed.

### Part 3 — ExpandA + SampleInBall — BLOCKED (2026-06-06)

**Foundational blocker found by KAT gate (this is the system working):**

Before building the SHAKE-dependent sampling, the asm hash was tested against
FIPS 202 known-answer vectors:

- SHAKE256("") -> got all zeros; expected 46b9dd2b0ba88d13...
- keccak_f1600(zero state) lane0 -> got 00017314c0dcd419; expected f1258f7940e1dde7

**Conclusion:** the asm Keccak-f[1600] PERMUTATION is incorrect. It now
assembles (FINDING-001 fixed earlier) but does not compute Keccak. The earlier
`make test` only checked the functions RAN, not that output was correct, so
this was invisible until KAT-tested.

**Impact:** SHAKE128/256 are built on Keccak; ExpandA, SampleInBall, mu, and
c_tilde (Parts 3-5) are built on SHAKE. They cannot be built or KAT-gated until
the permutation is correct. Parts 3-5 are therefore BLOCKED on a Keccak fix.

**This is a NEW critical finding** beyond the 2026-05-14 audit, which had marked
keccak only as "build fail" (FINDING-001). The deeper truth: even once it
builds, it computes the wrong value. Logged for the next session.

**Next-session task order:**
  1. Fix keccak_f1600 against FIPS 202 KATs (round constants, rho offsets,
     pi lane map, chi, theta) -- the hard, precise part.
  2. Rebuild SHAKE128/256, gate against SHAKE KATs.
  3. Resume Part 3 (ExpandA/SampleInBall) on the corrected SHAKE.
  4. Part 4 (decode + bounds), Part 5 (verify assembly).
  5. Final gate: ML-DSA-65 sigVer KAT (15 vectors saved in kat/, 3 accept /
     12 reject) -- valid must accept, tampered must reject.

### Status summary (end of 2026-06-06 session)

BANKED (real, verified):
  - Part 1 field arithmetic: proven + tested
  - Part 2 NTT: verified correct via negacyclic convolution
  - SPARK judicial layer: fail-closed, gnatprove-proven
  - asm rule30 + xor_mask: hardened, tested
  - LTHING spec: legalized (ML-DSA-65 erratum)

BLOCKED:
  - asm Keccak permutation computes wrong output (new critical finding)
  - Parts 3-5 wait on the Keccak fix

The ML-DSA verifier remains FAIL-CLOSED throughout. Nothing accepts anything.
