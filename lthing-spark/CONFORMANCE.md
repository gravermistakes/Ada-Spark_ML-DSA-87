# FIPS 204 conformance map — ML-DSA-65 / ML-DSA-87

This note records the current package layout. Older revisions named concrete
`lthing_mldsa65` / `lthing_mldsa87` packages that were deleted during the
generic migration.

## Current package map

- params: `lthing_mldsa_g_params`, `lthing_mldsa_params_65`,
  `lthing_mldsa_params_87`
- codec: `lthing_mldsa_g_codec` + G65/G87 instances
- sampling: `lthing_mldsa_g_sample` + G65/G87 instances
- signing: `lthing_mldsa_g_sign` + G65/G87 instances
- verification: `lthing_mldsa_g_verify` + G65/G87 instances
- shared arithmetic: field / NTT / round / timing

## Authoritative sigVer fixtures

- `kat/mldsa65_sigver.json`: NIST ACVP tcId 31..45
- `kat/mldsa87_sigver.json`: NIST ACVP tcId 61..75

`test_kat.adb` and `test_kat87.adb` require verifier output to equal the
authoritative expected result for both accepting and rejecting vectors.

## Generic scope

The current parameter generic fixes the Gamma1/Gamma2 profile shared by
ML-DSA-65 and ML-DSA-87. It is not yet an ML-DSA-44-capable abstraction.

## Evidence categories

- GNATprove: stated contracts, flow, AoRTE.
- ACVP KATs: FIPS behavioral interoperability.
- timing/code-generation analysis: side-channel evidence.

No one category substitutes for the others.
