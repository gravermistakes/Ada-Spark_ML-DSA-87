# Provenance Seal tooling

These Ada/Bash tools generate and verify LTHING provenance seals using the
current generic ML-DSA-65 implementation.

Build from `lthing-spark/`:

```sh
make tools
```

Binaries are written to `obj_tools/bin/`.

The signer uses `LTHING_MLDSA_Sign_G65`; the verifier uses
`LTHING_MLDSA_Verify_G65`. References to the deleted concrete
`LTHING_MLDSA65` / `LTHING_MLDSA_Sign` packages are obsolete.

Direct builds must include both source roots: `src/` and `src/ml-dsa/`.
The signing tool draws a fresh 32-byte seed from `/dev/urandom` per run and
prints only the public key and detached signature.
