# Ada/SPARK ML-DSA + LTHING cryptographic core

This repository contains the Ada/SPARK cryptographic core used by LTHING. The
current tree implements shared FIPS 204 machinery instantiated for
**ML-DSA-65** and **ML-DSA-87**, pure-Ada Keccak/SHAKE, fail-closed judicial
envelope verification, provenance-seal tooling, and a Deoxys-II subtree.

## Current ML-DSA architecture

Canonical code lives under `lthing-spark/src/ml-dsa/`:

- `LTHING_MLDSA_G_Params` — shared parameter/type substrate.
- `LTHING_MLDSA_G_Codec` — generic pk/signature encoding and decoding.
- `LTHING_MLDSA_G_Sample` — generic sampling and matrix expansion.
- `LTHING_MLDSA_G_Sign` — FIPS 204 KeyGen + Sign.
- `LTHING_MLDSA_G_Verify` — FIPS 204 Verify.
- `LTHING_MLDSA_Params_65` / `_87` and the `*_G65` / `*_G87`
  instantiations — the concrete parameter sets.
- `LTHING_MLDSA_Field`, `_NTT`, `_Round`, `_Timing` — shared arithmetic
  and timing-hardening support.

The pre-generic concrete `lthing_mldsa65` / `lthing_mldsa87` families were
deleted and are historical.

The current parameter generic is intentionally a **65/87 shared profile**:
`Gamma1 = 2^19` and `Gamma2 = (q-1)/32` are fixed because both current
instantiations share them. ML-DSA-44 would require extending those parameters.

## Build / test / proof

From `lthing-spark/`:

```sh
make clean
make build
make tools
make test
make prove
```

Acceptance requires:

1. the core project builds;
2. shipped provenance tools compile against the current packages;
3. every `src/test_*.adb` main exits 0 with no `[FAIL]`;
4. whole-project GNATprove reports **0 unproved**.

## Authoritative FIPS 204 gates

- ML-DSA-65 sigVer: NIST ACVP tcId 31..45.
- ML-DSA-87 sigVer: NIST ACVP tcId 61..75.

Both are full expected-result gates containing accept and reject vectors.

## Judicial verification

`LTHING_Judicial.Parse_Unverified` cannot return trusted data.
`Parse_And_Verify` performs structural, seal/chain, and signature checks before
returning trusted data.

- suite `0x0001`: ML-DSA-65
- suite `0x0002`: ML-DSA-87

## ML-DSA-87 signer CLI

`lthing-spark/src/sign_doc87.adb` derives a deterministic KeyGen seed from a
passphrase, signs a file with ML-DSA-87 under an empty context, and prints the
public key and signature as hex.

## Next workstream: Deoxys-II

The next active implementation/audit target is:

`lthing-spark/src/deoxys/deoxysii256-spark/`

See `LICENSE` and `ATTRIBUTION.lthing` for licensing/provenance.
