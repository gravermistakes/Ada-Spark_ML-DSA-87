# FIPS 204 (ML-DSA) — Verification Protocols (authoritative reference)

> Source: FIPS 204 final (2024-08-13), extracted verbatim from the NIST PDF
> (`nvlpubs.nist.gov/nistpubs/fips/nist.fips.204.pdf`). This file is the
> source-of-truth for the conformance loop: each implementation unit ("document
> N") is read and corrected against the algorithms below. Errata: a 2026-02-23
> errata spreadsheet exists (minor issues, future revision) — none observed to
> affect the verification path below.

## ML-DSA-65 parameters (NIST Security Level 3)
```
n=256   q=8380417 = 2^23 - 2^13 + 1   d=13
(k,l)=(6,5)   eta=4   gamma1=2^19   gamma2=(q-1)/32=261888
tau=49   beta=tau*eta=196   omega=55   lambda=192
c-tilde length = lambda/4 = 48 bytes
pk = 32 + 32*k*(bitlen(q-1)-d) = 1952 bytes
sig = lambda/4 + l*32*(1+bitlen(gamma1-1)) + omega + k = 3309 bytes
```
Conformance: `lthing_mldsa65.ads` constants — **all match** (N,Q,K_Dim=6,L_Dim=5,
Eta=4,Gamma1,Gamma2=261888,Tau=49,Beta=196,Omega=55,D_Bits=13,PK_Bytes=1952,
Sig_Bytes=3309,C_Tilde_Bytes=48). ✓

## Algorithm 3 — ML-DSA.Verify(pk, M, σ, ctx)  [external / "pure"]
```
1: if |ctx| > 255 then return ⊥
5: M' ← BytesToBits(IntegerToBytes(0,1) ∥ IntegerToBytes(|ctx|,1) ∥ ctx) ∥ M
6: return ML-DSA.Verify_internal(pk, M', σ)
```
i.e. **M' = 0x00 ∥ byte(|ctx|) ∥ ctx ∥ M**.
Conformance: `lthing_mldsa65.adb` `Verify` builds `M_Prime(0)=0; M_Prime(1)=Byte(|ctx|);
ctx; msg` and rejects `|ctx|>255` via `Pre`. ✓

## Algorithm 8 — ML-DSA.Verify_internal(pk, M', σ)
```
1:  (ρ, t1) ← pkDecode(pk)
2:  (c̃, z, h) ← sigDecode(σ)
3:  if h = ⊥ then return false                 ▷ hint not properly encoded
5:  Â ← ExpandA(ρ)                              ▷ stored in NTT domain
6:  tr ← H(pk, 64)
7:  μ ← H(BytesToBits(tr) ∥ M', 64)
8:  c ← SampleInBall(c̃)
9:  w'Approx ← NTT⁻¹( Â ∘ NTT(z) − NTT(c) ∘ NTT(t1 · 2^d) )
10: w'1 ← UseHint(h, w'Approx)                  ▷ componentwise
12: c̃' ← H(μ ∥ w1Encode(w'1), λ/4)
13: return [[ ‖z‖∞ < γ1 − β ]] and [[ c̃ = c̃' ]]
```
NOTE: the hint-weight bound (≤ ω) is **not** in line 13; it is enforced inside
`HintBitUnpack` (Alg 21) → if weight>ω or malformed, returns ⊥ → step 3 `false`.
Conformance: `lthing_mldsa65.adb` `Verify` implements steps 1-12 identically
(`H` = `LTHING_Keccak.Sponge` rate-256 SHAKE; `NTT/Inv_NTT/Pointwise` from
`LTHING_MLDSA_NTT`). Final return is `Inf_Norm_OK(z,γ1−β) ∧ c̃'=c̃ ∧
popcount(h)≤ω`. The first two match line 13; the third is a **redundant**
restatement of the Alg-21 weight bound (behaviour-neutral; KAT 15/15). ✓ (with note)

## Sub-algorithms (subjects of later loop iterations)
- Alg 23 `pkDecode` → `LTHING_MLDSA_Codec.Pk_Decode`
- Alg 27 `sigDecode` + Alg 21 `HintBitUnpack` (⊥ on malformed/over-weight) → `Codec.Sig_Decode`
- Alg 32 `ExpandA` (RejNTTPoly, Alg 30) → `LTHING_MLDSA_Sample.Expand_A` / `Rej_NTT_Poly`
- Alg 29 `SampleInBall` → `LTHING_MLDSA_Sample.Sample_In_Ball`
- Alg 36 `Decompose`, Alg 40 `UseHint`, `w1Encode` → `LTHING_MLDSA_Round`
- NTT / NTT⁻¹ → `LTHING_MLDSA_NTT`

## Loop status
- **N=0 `lthing_mldsa65` (Verify, Alg 3+8): CONFORMANT** (one structural note: redundant
  ω check in final return; one doc defect: stale "stubbed/returns Invalid" header).
- N=1.. (codec, sample, round, ntt) — pending subsequent iterations against the
  sub-algorithm pseudocode (to be appended here as each is read from the source).
