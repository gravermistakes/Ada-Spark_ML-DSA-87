# Repository operating rules

## Scope

`lthing-spark/` contains genericized ML-DSA-65/87 KeyGen, Sign, and Verify;
pure-Ada Keccak/SHAKE; fail-closed `.jd.lthing` verification; provenance-seal
tooling; authoritative ACVP fixtures; and the Deoxys-II subtree.

The deleted concrete `lthing_mldsa65` / `lthing_mldsa87` packages are
historical. Current implementation work belongs in `src/ml-dsa/lthing_mldsa_g_*`
and the G65/G87 instantiations.

## Language policy

Committed implementation/test/project tooling is Ada and Bash only.

## Acceptance gate

From `lthing-spark/`:

```sh
make clean
make build
make tools
make test
make prove
```

A crypto/control change is complete only after all five commands succeed and
GNATprove reports 0 unproved.

## Cryptographic conventions

- Fail closed.
- Production crypto/control code uses `SPARK_Mode (On)` where applicable.
- Use authoritative vectors or relational/property tests, never self-derived
  frozen outputs as the oracle.
- SPARK proof does not by itself establish FIPS conformance or machine-code
  constant-time behavior.
- Do not commit generated object directories.

## Current generic scope

`LTHING_MLDSA_G_Params` currently supports the common ML-DSA-65/87 Gamma
profile, not ML-DSA-44.

## Next workstream

After this gate is green, continue in
`lthing-spark/src/deoxys/deoxysii256-spark/`.
