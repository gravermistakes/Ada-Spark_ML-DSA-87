# Ada-Spark_ML-DSA-87 Development Patterns

> Repo skill, corrected by hand from the auto-generated ECC bundle (which misdetected the codebase as TypeScript).

## Overview
This skill guides contributions to the Ada-Spark_ML-DSA-87 codebase: an **Ada/SPARK**
implementation of **ML-DSA-65 and ML-DSA-87 (FIPS 204)** signature verification and
signing, a **fail-closed `.jd.lthing` judicial-document layer**, a **pure-Ada
Keccak/SHAKE core**, and the pinned **Deoxys-II-256-128** build contract in
`lthing-spark/src/deoxys/`. There is no framework. The root `CLAUDE.md` is
authoritative; this file summarizes it.

## Language policy (non-negotiable)
**Ada and Bash only** — everywhere, including tooling, KAT generators, and anything
run to produce a committed artifact. No Python (including `hashlib`), Go, Rust,
Ruby, Perl, or JavaScript. If a task seems to need another language, do it in Ada
or Bash, or stop and ask.

## Coding conventions
- **Ada source files:** GNAT requires the lowercase Ada unit name, one unit per
  pair: `lthing_*.ads` (spec) / `lthing_*.adb` (body). Examples:
  `lthing_keccak.ads`, `lthing_mldsa87_sign.adb`. That's a compiler rule, not a
  style choice.
- **Everything else:** naming is deliberately mixed — sometimesMixedCases,
  some_with_underscores, some-with-hyphens (`Ada-Spark_ML-DSA-87`, `rnDEOXYSii`,
  `leadEngineer`, `DEOXY_1_41.md`, `lthing-status.html`). Match the file or
  context you're in; don't impose a case convention.
- **SPARK:** `pragma SPARK_Mode (On)` for crypto/control code; proof target is
  AoRTE + flow + stated contracts.
- **Fail-closed is sacred:** no gate (e.g. `Verify_Signature`, `Parse_And_Verify`)
  returns accept until it genuinely verifies. Never weaken a judicial postcondition.
- **Modules:** Ada `with`/`use` context clauses and package specs — not imports/exports.

## Build / test / prove (from `lthing-spark/`)
```sh
export PATH=/root/.alire/bin:$PATH
gnatmake -q -D /tmp/b -aIsrc -aIsrc/ml-dsa -o /tmp/b/<main> src/<main>.adb && /tmp/b/<main>
./run_tests.sh                                          # builds + runs every src/test_*.adb
gnatprove -P lthing.gpr --level=2 --report=all -j0      # whole project
```
**Definition of done:** it builds, every test main prints all `[PASS]` and exits 0,
and `gnatprove` reports **0 unproved**.

## Testing patterns
- Test mains live at `lthing-spark/src/test_*.adb`; they print `[PASS]`/`[FAIL]`
  and call `Set_Exit_Status (Failure)` on any failure.
- **No frozen / self-derived vectors:** assert only (a) authoritative KATs from a
  published standard or pinned reference file (FIPS 202/204, Keccak reference
  vectors, NIST ACVP sigVer, pinned Deoxys vector files), or (b) relational /
  property facts (determinism, input-sensitivity, fail-closed-on-garbage).
  Never paste a self-computed digest, never generate vectors with a non-Ada/Bash tool.

## Commit patterns
- Freeform imperative messages, ~50–60 characters, often area-prefixed:
  `changelog:`, `deoxys:`, or plain (`Fix CI: add ml-dsa source path ...`).

## Workflows

### Update the engineering status sheet
**Trigger:** recording shipped work, proof-status changes, or roadmap updates.

1. Open `changelog/lthing-status.html` (fully self-contained; fonts are inlined
   as data URIs — keep it that way, the artifact CSP blocks CDNs).
2. Refresh the internal front loader comment at the top: `epoch` (current Unix
   seconds), `currentStage`, `leadEngineer`.
3. Update the stamp row (gnatprove count, KAT tallies), the verified-units table,
   the FIPS 204 parameter strips, and/or the Deoxys phase pipeline as needed.
4. Commit with a `changelog:` prefixed message.
