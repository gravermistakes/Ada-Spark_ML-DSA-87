# Hostile Review + Remediation Guide — `lthing-spark`

> Adversarial audit (2026-06-16). Every finding is tied to `file:line` and was
> re-verified against the source. No code was changed in producing this review.
>
> Verdict: the ML-DSA-65 **math is correct** (KAT 15/15; bounds/overflow audited
> in the SPARK-Off units — no crypto bug found). But it is wired into **nothing**,
> the chain check is **fake**, three statuses are **dead**, the asm was **not**
> retired, and the "306 checks / 0 unproved" headline is **rigged** (the verifier
> core is excluded from analysis). Findings ranked; each has a fix guide below.
>
> Format-dependent fixes (C1/C2/H4-seal) are **BLOCKED on J's `.jd.lthing` byte
> spec** — guide says exactly what to do once it lands. Everything else is
> independently fixable now.

---

## PART 1 — FINDINGS (ranked)

### CRITICAL
- **C1. `Verify_Signature` hardcoded `return False`** — `lthing_judicial.adb:71-79`
  (`pragma Unreferenced` on both params; `return False` at :78). `Parse_And_Verify`
  can never reach `Verified`; the real verifier in `lthing_mldsa65.adb` is never
  called. The product rejects every document.
- **C2. Chain-of-custody gate is a tautology** — `lthing_judicial.adb:132`:
  `if not Digest_Equal (Recomputed_Chain, Recomputed_Chain)`. Value vs itself →
  `Chain_Broken` can never fire. Zero provenance security.
- **C3. The proof metric is rigged** — `lthing_mldsa65.adb:25`, `lthing_mldsa_ntt.adb:7`,
  `lthing_mldsa_sample.adb:17` are `SPARK_Mode (Off)`. gnatprove emits checks only
  for On code, so the verifier core contributes **0** of the 306 checks; "0 unproved"
  is guaranteed by construction. Baseline was ~131; growth to 306 is mechanical
  range proofs in `round`/`codec`, not a single line of `Verify`.

### HIGH
- **H4. Three dead status codes** — `lthing_types.ads:41-43`: `Bad_Length`,
  `Seal_Mismatch`, `Chain_Broken` are never assigned anywhere.
- **H5. `Compare_CT` (constant-time) untested + asm-imported** — call `lthing_judicial.adb:63`,
  import `lthing_crypto_ffi.ads:58`. No test exercises `Digest_Equal`; the one
  timing-sensitive primitive has zero coverage.
- **H6. asm not actually retired** — `run_tests.sh:19` still links
  `-llthing_crypto_asm`; `lthing_crypto_ffi.ads:33-55` still imports unused
  `SHAKE_Absorb`/`SHAKE_Squeeze`. Dead trust surface in the TCB.
- **H7. Docs assert false things** — `lthing-spark/CLAUDE.md` table calls
  `lthing_mldsa65`/`_sample` "spec-only stubs (no body yet)" (they're the working
  verifier); `TEST_COVERAGE_ANALYSIS.md` §1 lists `lthing_hash` "0/2 — No test at
  all" (test_hash.adb exists); `test_kat.adb:9-25` header still says "NEGATIVE
  gate / NO Context parameter," contradicting its own current code.

### MEDIUM
- **M8. Empty-message precondition** `Message'Length > 0` — `lthing_mldsa65.ads:77`
  (FIPS 204 allows empty). `test_kat.adb:59` builds a 1-element array when
  `Msg_Len=0`. Latent (none of the 15 vectors has an empty message) but real.
- **M9. KAT is thin** — 15 vectors, no boundary cases (‖z‖∞ at γ1−β, hint weight
  at ω, near-valid encodings, zeta-walk). NTT was round-trip+convolution checked,
  so risk is low, not zero.
- **M10. KAT generator output never cross-validated** — `tools/gen_kat_vectors.py`
  asserts pk/sig lengths only (`:76-77`); nothing checks the emitted `.ads` matches
  the JSON byte-for-byte.
- **M11. Vacuous postcondition** `Post => Output'Length = Output'Length` —
  `lthing_crypto_ffi.ads:55`.
- **M12. Keccak API under-constrained** — `Sponge` lets a caller pair rate 72 with
  domain `0x1F`; FIPS rate/domain pairing isn't enforced.

### LOW
- **L13. `test_judicial` never calls `Set_Exit_Status`** — `:42-43`. NOT CI-blind
  (it prints `[FAIL]`; `run_tests.sh:26` greps for it), but inconsistent/fragile.
- **L14. `Makefile:6`** `gprbuild ... || true` masks build failures.
- **L15. `SHAKE512`/`Chain_Hash` forbid empty input** — `lthing_hash.ads:24,35`.
- **L16. Duplicate rate constant** — `lthing_crypto_ffi.ads:25` vs `lthing_keccak.ads:43`.
- **L17. `collaborative_neon_garden.py`** — unrelated 559-line file in the repo.

---

## PART 2 — FIX GUIDES (one per finding)

### C1 — wire `Verify_Signature` → `LTHING_MLDSA65.Verify`  [BLOCKED on J's spec]
The verifier needs the artifact (message), context, and signature *sliced out of
the envelope*, and a trusted PK. That slicing requires the `.jd.lthing` byte layout
(J is writing it). Once the spec lands: rework `Verify_Signature` to take
`(Artifact, Context, Public_Key, Signature)`, copy the unconstrained slices into the
constrained `LTHING_MLDSA65.Public_Key (0..1951)` / `Signature (0..3308)` subtypes,
and `return LTHING_MLDSA65.Verify (PKc, Artifact, Context, Sgc);`. The On→Off call is
safe (caller proved against the On spec contract). **Interim (no spec):** keep it
`return False` but delete the `pragma Unreferenced` deception and add a `pragma
Assert (False)`-free comment stating it is intentionally unreachable pending the
spec — do not pretend it is finished.

### C2 — real chain-of-custody gate  [BLOCKED on J's spec]
Replace `Digest_Equal (Recomputed_Chain, Recomputed_Chain)` with a compare against
the **carried** chain hash sliced from the envelope:
`Digest_Equal (Recomputed_Chain, Carried_Chain)` where `Recomputed_Chain =
Chain_Hash (Previous_Seal, Artifact)`. Needs the spec's offset/size for the carried
hash. **Interim:** rip out the tautology line entirely — a gate that cannot fail is
worse than no gate (it reads as security). Until the spec, either remove the chain
"check" and document the gap honestly, or leave a `Chain_Broken` return that is
clearly a placeholder, never a `Digest_Equal(X,X)`.

### C3 — stop rigging the proof number (honesty, do now)
Two honest options: (a) **label it** — in `TEST_COVERAGE_ANALYSIS.md` and the PR,
state that the arithmetic core (`lthing_mldsa65` body, `_ntt`, `_sample`) is
`SPARK_Mode (Off)` and **KAT-validated, NOT gnatprove-proved**; report the proof
count *with that exclusion named*, never as whole-project assurance. (b) **earn it**
— flip those units to `SPARK_Mode (On)` and discharge AoRTE (large effort: in-place
NTT, rejection sampling). Do (a) now regardless. The lie isn't the number; it's
presenting a number whose scope was drawn to exclude the security-critical code.

### H4 — light up the dead statuses  [partly BLOCKED on J's spec]
`Bad_Length`, `Seal_Mismatch`, `Chain_Broken` become reachable once the envelope
gates exist: length/consistency gate → `Bad_Length`; seal recompute mismatch →
`Seal_Mismatch`; real chain compare (C2) → `Chain_Broken`. **Interim:** if the spec
is not coming soon and these stay unreachable, *delete them from the
`Verify_Status` enum* (`lthing_types.ads:41-43`) rather than ship dead API — a
status that can never be returned is a lie about capability. Re-add with the gates.

### H5 — test the constant-time compare (do now)
Add a relational test: two equal 64-byte digests → `Digest_Equal = True`; flip the
first, a middle, and the last byte → `False` each. `Digest_Equal` is private to the
judicial body, so either expose a thin `Compare_Digests` in `lthing_judicial.ads`
or drive it via `Parse_And_Verify` behavior on equal/unequal seals. Do NOT assert a
timing property in a unit test (you can't) — assert correctness, and document the
constant-time intent.

### H6 — actually retire the asm (do now; pairs with H5)
Reimplement `Digest_Equal` in `lthing_judicial.adb` as pure SPARK: `Acc : Byte := 0;
for I in Digest_Index loop Acc := Acc or (A(I) xor B(I)); end loop; return Acc = 0;`
(data-independent; comment that GNAT does not *guarantee* CT). Then **delete
`src/lthing_crypto_ffi.ads`** (all three imports now dead), remove `with
LTHING_Crypto_FFI`/`with Interfaces.C` from `lthing_judicial.adb`, and strip
`-largs -L.. -llthing_crypto_asm -Wl,-rpath` + `LD_LIBRARY_PATH` from
`run_tests.sh:18-24`. Confirm no other referer (`grep -rn lthing_crypto_asm src`),
then the `lib/liblthing_crypto_asm.*` artifacts are dead weight (remove or quarantine).

### H7 — fix the lying docs (do now)
- `lthing-spark/CLAUDE.md` table: change `lthing_mldsa65`/`_sample` rows from
  "spec-only stubs (no body yet)" to "body present, `SPARK_Mode (Off)`,
  KAT-validated"; change `lthing_crypto_ffi` row once H6 deletes it.
- `TEST_COVERAGE_ANALYSIS.md` §1: the `lthing_hash` "0/2 — No test at all" row is
  false — `test_hash.adb` exists; update the table or date-stamp it as the original
  pre-work inventory and add a "current" column.
- `test_kat.adb:9-25`: delete the stale header paragraph (NEGATIVE gate / no Context
  param); it contradicts the code at :55-82. Keep the comment honest about FULL gate.

### M8 — empty-message support (do now)
- `lthing_mldsa65.ads:77`: drop `Message'Length > 0`, keep `Context'Length <= 255`.
  The body already handles len 0 (`for I in 0 .. Message'Length-1` is empty;
  `M_Prime'Length = Message'Length + Context'Length + 2 >= 2`). Re-prove.
- `test_kat.adb:59-60`: replace `0 .. (if Len=0 then 0 else Len-1)` with
  `Byte_Array (1 .. V.Msg_Len)` / `(1 .. V.Ctx_Len)` (true null array when 0), pass
  directly; drop the `Ctx (0 .. V.Ctx_Len-1)` slice on :74.
- Judicial layer still requires a non-empty artifact (SHAKE512/Chain_Hash need
  `>0`) → that becomes a `Bad_Length` gate, not a crash. Document as deliberate.

### M9 — KAT breadth (do now, honestly bounded)
Sourceable: pull authoritative vectors from the user-supplied sources — NIST ACVP
`ML-DSA-sigVer` (accept+reject JSON, same shape as the existing 15) and the PQC
repo `kat_MLDSA_65_det_pure.rsp` (valid sigs → accept). Extend
`gen_kat_vectors.py` to ingest them; regenerate. Plus property/boundary **unit**
tests from proven primitives: `Inf_Norm_OK` at exactly `Gamma1-Beta`; hint weight
at exactly `Omega`; `Inv_NTT(NTT(p)) = p`. Do NOT hand-author vectors. If network
policy blocks the fetch, keep 15 + property tests and say so.

### M10 — validate the KAT generator (do now)
Add a check that the generated `.ads` round-trips to the JSON: either a Python
self-test in `gen_kat_vectors.py` (re-parse its own output, compare bytes to JSON)
run in CI, or assert in `test_kat` that each vector's PK/Sig length and a hash of
its bytes matches a value the generator also emits from the JSON. Goal: the
generator stops being an unverified trust boundary.

### M11 — fix the vacuous contract (do now; mooted by H6)
`lthing_crypto_ffi.ads:55` `Post => Output'Length = Output'Length` asserts nothing.
If H6 deletes the FFI, this vanishes. If kept for any reason, write a real post
(e.g. relate `Output'Length` to `Output_Len`) or remove the cargo-cult contract.

### M12 — constrain the Keccak API (do now, cheap)
Either add separate rate constants bound to their domain, or add a precondition to
`Sponge` rejecting invalid (rate, domain) pairs (e.g. `Domain = Domain_SHAKE or
(Domain = Domain_SHA3)` with the rate matching FIPS 202 Table 1). Prevents a caller
silently computing a nonsense sponge.

### L13 — make `test_judicial` consistent (do now, trivial)
Add `with Ada.Command_Line;` and `if Fails > 0 then Ada.Command_Line.Set_Exit_Status
(Ada.Command_Line.Failure); end if;` at `:42-43`, matching `test_kat.adb:115`. Belt
and suspenders with the `[FAIL]` grep.

### L14 — un-mask build failures (do now, trivial)
`Makefile:6`: remove `|| true` so `make build` fails on a broken build. If it was
there to let `make` continue to other targets, split into `build` (strict) and a
separate best-effort target.

### L15 — allow empty input to SHAKE512/Chain_Hash (optional)
`lthing_hash.ads:24,35`: drop `Input'Length > 0` / `Artifact'Length > 0` if FIPS
empty-input support is wanted; the Keccak pad10*1 handles empty correctly. Note the
judicial layer's own non-empty-artifact policy is separate (M8).

### L16 — de-duplicate the rate constant (do now, trivial)
`lthing_crypto_ffi.ads:25` `SHAKE512_Rate` duplicates `lthing_keccak.ads:43`
`Rate_SHA3_512`. Mooted if H6 deletes the FFI; otherwise reference the keccak one.

### L17 — `collaborative_neon_garden.py` (decide)
Unrelated to the crypto. Either move it out of this repo or add a top-of-file note
that it's intentionally unrelated. Don't let it inflate the security surface or
confuse reviewers. (CLAUDE.md already says "ignore.")

---

## Suggested order
1. **Honesty first, no spec needed:** C3, H7, M11, L13, L14, L16 (docs/contracts/build).
2. **Retire asm + test CT:** H6 + H5 (independent, removes dead TCB).
3. **FIPS correctness:** M8 (empty msg), M12 (keccak pairing), M10 (generator), M9 (KAT breadth).
4. **Blocked on J's spec:** C1, C2, H4 (+ seal gate). When the spec arrives, do the
   envelope slicing + wire Verify + real chain/seal gates; that also lights H4's statuses.
5. Re-run `./run_tests.sh` (expect green incl. new tests) and
   `gnatprove -P lthing.gpr --level=2` after each step; report the count **with the
   SPARK-Off exclusion named** (C3).
