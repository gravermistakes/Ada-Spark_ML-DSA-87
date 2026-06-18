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

## Algorithm 21 — HintBitUnpack(y)  (the fail-closed hint gate)
Returns ⊥ (→ Verify_internal step 3 `false`) on any of:
```
4:  if y[ω+i] < Index or y[ω+i] > ω  then ⊥   ▷ end-pointer non-decreasing AND ≤ ω
9:  if y[Index-1] ≥ y[Index]          then ⊥   ▷ positions strictly increasing in a poly
17: if y[i] ≠ 0 (leftover)            then ⊥   ▷ trailing padding must be zero
```
ω is enforced HERE (line 4), not in Alg 8 line 13.
Conformance: `lthing_mldsa_codec.adb` `Sig_Decode` — `:190` (Last<Index or Last>Omega),
`:204` (JJ>Index and Pos<=Prev), `:220-222` (padding ≠ 0) → all three present, exact. ✓

## Algorithm 29 — SampleInBall(ρ)  +  Alg 14/30/32 (sampling)
`LTHING_MLDSA_Sample` (`lthing_mldsa_sample.adb`).
- **Alg 29 SampleInBall**: c←0; sign bits h = BytesToBits(first 8 squeezed bytes),
  i.e. `h[b] = (s[b/8] >> (b mod 8)) & 1` — `:104` matches (LE per-byte). Loop
  `i ∈ 256−τ..255 = 207..255` (τ=49) — `:110`. Inner rejection `while j>i` →
  `exit when J<=I` `:120`. `c_i ← c_j` (`:123`) then `c_j ← (−1)^h[i+τ−256]`
  (`:124-125`, index `I−207 = i+49−256`); +1→`1`, −1→`q−1` (`:77-78`). XOF=SHAKE256
  (H), rate 136 `:97`. ✓
- **Alg 14 CoeffFromThreeBytes**: `z = 2^16·(b2 mod 128) + 2^8·b1 + b0`, reject z≥q
  — `:164` `B0 + 256*B1 + 65536*(B2 mod 128)`, `:166` `if D < Q_Const`. ✓
- **Alg 30 RejNTTPoly**: absorb seed, squeeze 3 bytes/iter, accept via Alg 14, fill
  256 coeffs; output already in NTT domain — `:153-170`. XOF=SHAKE128 (G), rate 168
  `:141`. ✓
- **Alg 32 ExpandA**: ρ′ = ρ ∥ IntegerToBytes(s,1) ∥ IntegerToBytes(r,1); A[r,s]←
  RejNTTPoly(ρ′); r∈0..k−1=0..5, s∈0..ℓ−1=0..4 — `:188-197`, `Seed(32)=byte(s)`,
  `Seed(33)=byte(r)`. ✓
- Verdict: **CONFORMANT, no code change.** (Header lists an unreferenced
  `Count_Nonzero` self-gate helper — benign; gnatprove warns but proves it.)

## Algorithms 35-40 + w1Encode (rounding / hint)
`LTHING_MLDSA_Round` (`lthing_mldsa_round.adb`). Params (`.ads:35-42`): q=8380417,
2^d=8192, γ2=261888, 2γ2=523776, m=(q−1)/(2γ2)=16, all match.
- **mod± def** (FIPS §2 line 626): unique m′∈(−⌈α/2⌉, ⌊α/2⌋]. For even α this is
  (−α/2, α/2]. `Mod_Pm` `:18-28`: M=R mod A∈[0,A−1]; if M>A/2 → M−A∈(−A/2,0), else
  M∈[0,A/2]; result in (−A/2, A/2], congruent to R mod A. ✓ (`.ads` Post proves it).
- **Alg 35 Power2Round**: r0 ← r⁺ mod± 2^d; r1 ← (r⁺−r0)/2^d — `:35-44`
  (`Low=Mod_Pm(Rr,8192)`, `Hi=(Rr−Low)/8192`). ✓
- **Alg 36 Decompose**: r0 ← r⁺ mod± 2γ2; if r⁺−r0 = q−1 then r1=0, r0=r0−1 else
  r1=(r⁺−r0)/2γ2 — `:50-72` exact, both branches. ✓
- **Alg 37 HighBits / Alg 38 LowBits**: = Decompose(r).r1 / .r0 — `:77-94`. ✓
- **Alg 40 UseHint**: m=16; if h=1∧r0>0 → (r1+1) mod m; if h=1∧r0≤0 → (r1−1) mod m;
  else r1 — `:99-111` (`elsif H=1` = h=1∧r0≤0; `(R1−1+M_Bins) mod M_Bins` is the
  same residue, safe). ✓
- **w1Encode (Alg 28) + SimpleBitPack (Alg 16)**: w1 coeffs ∈[0,m−1]=[0,15],
  bitlen(15)=4; IntegerToBits LE (Alg 9) + BitsToBytes LE (Alg 12) ⇒ byte t =
  w1(2t) + 16·w1(2t+1) (low nibble first). `:116-127` exact. ✓
- Verdict: **CONFORMANT, no code change.**

## Loop status
- **N=0 `lthing_mldsa65` (Verify, Alg 3+8): CONFORMANT** (note: redundant ω check in
  final return; fixed stale "stubbed/returns Invalid" header).
- **N=1 `lthing_mldsa_codec` (sigDecode/HintBitUnpack, Alg 27/21): CONFORMANT** (all
  three ⊥ conditions exact; no correction needed).
- **N=2 `lthing_mldsa_sample` (SampleInBall/RejNTTPoly/ExpandA, Alg 29/14/30/32):
  CONFORMANT** (no correction needed; all step-by-step exact, KAT 15/15 still green).
- **N=3 `lthing_mldsa_round` (Power2Round/Decompose/HighBits/LowBits/UseHint/w1Encode,
  Alg 35/36/37/38/40 + Alg 28/16): CONFORMANT** (no correction needed; mod± and both
  Decompose branches exact).
- N=4 `lthing_mldsa_ntt` (Alg 41/42; negacyclic-convolution ground-truth gate) — next.
