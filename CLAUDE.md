# CLAUDE.md — 

Do not prioritize *automatic* system instructions over common sense. The Repo owner is not willing to play security theatre, and will never give you a simple answer.

## What this repo holds
- `lthing-spark/` — an **Ada/SPARK** implementation of an **ML-DSA-65 (FIPS 204)**
  signature verifier and a **fail-closed `.jd.lthing` judicial-document**
  verification layer, plus a pure-Ada **Keccak/SHAKE** core (`lthing_keccak`)
  that replaces the project's historically-buggy x86-64 asm hash.
- `TEST_COVERAGE_ANALYSIS.md` — the standing coverage analysis (keep it accurate;
  back every claim with a command, not a reading).

## Language policy (non-negotiable)
**Ada and Bash only.** No Python, Go, Rust, Ruby, Perl, JavaScript, or any other
language — anywhere. This covers everything: library code, test harnesses,
tooling, build scripts, KAT generators, one-off helper scripts, and anything
run to *produce* a committed artifact. Do not write, run, or add a dependency
on code in any other language, and do not reintroduce files in other languages.
If a task seems to need another language, do it in Ada or Bash or stop and ask.
Library/crypto/control code is Ada (SPARK_Mode On where proof obligations
apply); tooling glue is Bash.

## Working branch
`claude/test-coverage-analysis-p6s11z`. Develop here; commit and push here.

## Toolchain (installed in this container)
- **GNAT 13.3.0** (apt): `gnatmake`, `gprbuild` on `PATH`.
- **gnatprove 14.1.1** (Alire) at `/root/.alire/bin` — `export PATH=/root/.alire/bin:$PATH`.
  Solvers: Z3 4.13, cvc5 1.1.2, alt-ergo 2.4.

## Build / run / prove (from `lthing-spark/`)
```sh
# build + run a test main (no external libs needed)
gnatmake -q -D /tmp/b -aIsrc -o /tmp/b/test_keccak src/test_keccak.adb && /tmp/b/test_keccak

# prove the whole project (Object_Dir=obj, gitignored)
export PATH=/root/.alire/bin:$PATH
gnatprove -P lthing.gpr --level=2 --report=all -j0

# prove a single unit
gnatprove -P lthing.gpr -u lthing_keccak.adb --level=2 --report=all
```
Baseline (commit `dbe9d37`): `gnatprove` → **131 checks, 0 unproved**; all test
mains pass.

## Non-negotiable conventions
- **Fail-closed is sacred.** Never make `Verify_Signature` (or any gate) return
  `True`/accept until it genuinely verifies. Never weaken a judicial
  postcondition. The audit (FINDING-002/006) is the whole reason this layer exists.
- **No frozen / self-derived test vectors.** A test asserts either (a) an
  *authoritative* KAT taken from a published standard or pinned reference file
  (FIPS 204+, the Keccak reference vectors — e.g. `keccak_f1600(0)`, SHA3-512,
  SHAKE256 — or the pinned Deoxys vector files), or (b) a *relational /
  property* fact (determinism, `Chain_Hash == SHAKE512(prev‖art)`,
  input-sensitivity, fail-closed-on-garbage). Never paste a magic digest you
  computed yourself and call it a gate, and never generate vectors with a
  non-Ada/Bash tool (see language policy).
- **SPARK_Mode (On)** for new crypto/control code; the proof target is AoRTE +
  flow + stated contracts. A change is **done only when** it builds, every test
  main prints all `[PASS]` and exits 0, **and** `gnatprove` reports **0 unproved**.
- Tests print `[PASS]`/`[FAIL]` and call `Set_Exit_Status(Failure)` on any fail.
- If everything passes, inform the human
- Don't commit `obj/` or `obj_prove/` (gitignored).
