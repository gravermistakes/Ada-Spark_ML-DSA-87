# lthing-spark operating map

Read the root `CLAUDE.md` first.

## Canonical production units

| Area | Units |
|---|---|
| Types | `lthing_types` |
| Keccak/hash | `lthing_keccak`, `lthing_hash` |
| Judicial | `lthing_judicial` |
| ML-DSA params | `ml-dsa/lthing_mldsa_g_params`, `params_65`, `params_87` |
| ML-DSA codec | `ml-dsa/lthing_mldsa_g_codec`, `codec_g65`, `codec_g87` |
| ML-DSA sampling | `ml-dsa/lthing_mldsa_g_sample`, `sample_g65`, `sample_g87` |
| ML-DSA signing | `ml-dsa/lthing_mldsa_g_sign`, `sign_g65`, `sign_g87` |
| ML-DSA verify | `ml-dsa/lthing_mldsa_g_verify`, `verify_g65`, `verify_g87` |
| Shared arithmetic | `ml-dsa/lthing_mldsa_field`, `_ntt`, `_round`, `_timing` |

The former concrete ML-DSA packages are deleted. Do not reintroduce or target
them in new work.

## Commands

```sh
make clean
make build
make tools
make test
make prove
```

Single test example:

```sh
gnatmake -q -D /tmp/b -aIsrc -aIsrc/ml-dsa   -o /tmp/b/test_name src/test_name.adb
/tmp/b/test_name
```

## Verification posture

- ML-DSA-65 sigVer: ACVP tcId 31..45, full gate.
- ML-DSA-87 sigVer: ACVP tcId 61..75, full gate.
- Judicial suite `0x0001` uses ML-DSA-65.
- Judicial suite `0x0002` uses ML-DSA-87.
- Whole-project acceptance requires GNATprove 0 unproved.

## Deoxys-II

Next target: `src/deoxys/deoxysii256-spark/`. Keep its proof/test claims
separate until it is explicitly integrated into the top-level project.
