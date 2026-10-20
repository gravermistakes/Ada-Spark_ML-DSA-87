# LTHING cryptographic design — current implementation

This document supersedes the pre-generic roadmap that referenced live assembly
FFI, missing signing, SPARK-off crypto units, and the deleted concrete
ML-DSA-65/87 package families.

## Trust boundary

The active LTHING cryptographic core is Ada/SPARK:

1. pure-Ada Keccak/SHAKE;
2. shared field / NTT / rounding / timing primitives;
3. generic ML-DSA parameters, codec, sampling, signing, verification;
4. ML-DSA-65 and ML-DSA-87 instantiations;
5. fail-closed judicial envelope verification.

## ML-DSA generic layer

`LTHING_MLDSA_G_Params` provides the types/constants consumed by the generic
codec, sampler, signer, and verifier. The repository currently instantiates
ML-DSA-65 and ML-DSA-87.

The current generic is a shared 65/87 arithmetic profile, not a universal
44/65/87 abstraction: Gamma1/Gamma2 must become formals before ML-DSA-44 can be
added correctly.

## Signing / verification

Both current parameter sets have KeyGen, Sign, and Verify paths. Verification is
fail-closed and checked against authoritative NIST ACVP sigVer fixtures.

Timing hardening includes branchless helpers and full-scan checks, but
machine-code constant-time behavior remains a separate verification concern.

## Judicial layer

`Parse_Unverified` cannot return trusted data. `Parse_And_Verify` performs
structural, seal/chain, and suite-selected ML-DSA verification.

- `0x0001` → ML-DSA-65
- `0x0002` → ML-DSA-87

## Acceptance gates

```sh
make clean
make build
make tools
make test
make prove
```

The explicit tools gate exists because provenance CLIs live outside the normal
project source directories.

## Next boundary: Deoxys-II

Deoxys-II-256-128 lives under `src/deoxys/deoxysii256-spark/` with its own GPR
project and KATs. Audit it from that ground truth before integrating it into
LTHING's top-level proof/build claim.
