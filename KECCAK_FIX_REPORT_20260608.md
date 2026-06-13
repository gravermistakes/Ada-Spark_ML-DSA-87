# Keccak / SHAKE Fix Report — LTHING crypto asm

**Date:** 2026-06-08T08:40:47Z  |  **Epoch:** 1780908047
**For:** Anja Evermoor, CulpabilityAnchor
**Substrate:** avrs-dusk2dawn (repo mode) + cutting-edge-cadence (KAT gates)
**Supersedes blocker logged 2026-06-06 (Parts 3-5 were blocked on this)**

## Summary

The asm Keccak-f[1600] was wrong at the FIPS 202 level (returned
00017314c0dcd419 for keccak_f1600(0); spec requires f1258f7940e1dde7).
THREE independent bugs were found and fixed, each masking the next —
caught only because the work was KAT-gated layer by layer.

## The three bugs

1. **Missing rho+pi step (P0).** The combined ρ (rotate) + π (lane permute)
   step was a no-op — three comment lines reading "skipped for brevity." The
   permutation ran θ → (nothing) → χ → ι, a third of each round absent.
   FIX: implemented B[((2x+3y) mod 5)*5 + y] = ROL(A[y*5+x], rho_offsets[..])
   into a dedicated temp buffer (keccak_temp_b), then copied back. The B-formula
   was cross-checked against a reference piln-loop in isolation (matched).

2. **In-place chi corruption (P0).** χ computed A[idx] ^= (~A[idx1]) & A[idx2]
   in place, so lanes at x=3,4 in each row read already-overwritten values
   (10 of 25 lanes wrong). FIX: snapshot each 5-lane row into keccak_temp_c
   before modifying, read from the snapshot.

3. **Missing SHAKE padding (P0).** absorb XORed message bytes and permuted but
   never applied pad10*1 + the SHAKE domain byte 0x1F. Empty/partial messages
   absorbed nothing, so SHAKE output was all zeros. FIX: rewrote absorb to
   process full rate blocks, then on the final block XOR 0x1F at the message
   end and 0x80 at byte (rate-1), then permute. (0x1F verified against FIPS 202.)

## Verification (by execution, KAT-gated)

- keccak_f1600(zero) lane0 = f1258f7940e1dde7  ✓ (FIPS 202)
- SHAKE256("") 64B   ✓
- SHAKE256("abc") 32B ✓
- SHAKE256("") 200B multi-block squeeze ✓ (exercises squeeze-permute boundary)
- Full make-test regression: 5/5 PASS (rule30, mask/unmask, compare_ct)
- rule30 hardening gauntlet: still all green

## Impact: Parts 3-5 UNBLOCKED

ExpandA (SHAKE128), SampleInBall (SHAKE256), mu/c_tilde all depend on SHAKE.
With SHAKE now correct, the ML-DSA-65 verifier build can resume:
  Part 3 — ExpandA + SampleInBall  (next)
  Part 4 — pk/sig decode + bounds
  Part 5 — Verify assembly → final gate: ML-DSA-65 sigVer KAT (15 vectors saved)

## Note on SHAKE128 (rate 168) for ExpandA

The sponge takes rate as a parameter, so SHAKE128 = same routines with
rate=168 and domain byte 0x1F. Will KAT-gate SHAKE128 before building ExpandA
on it (same discipline that caught these three bugs).

## Backups

  keccak.asm.bak2 — pre-sponge-rewrite
  keccak.asm.orig — original (rule30 had its own backup earlier)
