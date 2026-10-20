# LTHING Ada/SPARK — current verification surface

**Architecture refresh:** 2026-10-19

Exact proof/check totals belong to fresh CI output, not copied historical
snapshots. Reproduce the acceptance surface with:

```sh
cd lthing-spark
make clean
make build
make tools
make test
make prove
```

## Test inventory

`run_tests.sh` discovers `src/test_*.adb`. The current tree contains **24**
test mains:

- codec/encoding: `test_codec`, `test_codec87`, `test_encode`,
  `test_encode87`, `test_g_codec`, `test_g_params`
- arithmetic: `test_field`, `test_ntt`, `test_round`
- hashing/XOF: `test_keccak`, `test_hash`, `test_xof_cap`
- sampling: `test_sample`, `test_sample87`
- signing: `test_sign`, `test_sign87`
- verification/KAT: `test_kat`, `test_kat87`, `test_verify_adv`,
  `test_verify_adv87`
- judicial: `test_judicial`, `test_judicial87`,
  `test_judicial87_sign`, `test_judicial_suites`

The runner fails on compile failure, non-zero exit, or `[FAIL]` output.

## Canonical implementation under test

The duplicated concrete ML-DSA implementations are gone. Tests exercise the
generic parameter, codec, sampler, signer, and verifier packages instantiated
for ML-DSA-65 and ML-DSA-87, plus shared field/NTT/round/timing and Keccak code.

## Authoritative interoperability gates

- ML-DSA-65: NIST ACVP sigVer tcId 31..45, full expected-result gate.
- ML-DSA-87: NIST ACVP sigVer tcId 61..75, full expected-result gate.

## Shipped-tool gate

`make tools` compiles the provenance-seal CLIs. These live outside the normal
project source directories and therefore need an explicit gate.

## Proof scope

`make prove` runs whole-project GNATprove at level 2. Acceptance is 0 unproved.
This is AoRTE/flow/contracts evidence; FIPS behavior is separately KAT-gated.

## Remaining verification work

- instrumented GNATcov line/branch/MC/DC coverage is not yet a CI gate;
- machine-code timing analysis remains separate from source/SPARK claims;
- ML-DSA-44 needs Gamma1/Gamma2 parameterization;
- Deoxys-II currently has its own project and is not part of the top-level
  `lthing.gpr` proof claim.
