# Provenance Seal tooling

Generates an Inherited Seal of Provenance (Evermoor Sanctuary License
`ESL-ANCSA-MRA-IndiModSHA` v1.3, §5A) for a distributed artifact, using the
project's real SHAKE512 (`LTHING_Hash`) and ML-DSA-65 (`LTHING_MLDSA_Sign`)
implementations — no placeholder or self-derived cryptography.

All tooling is Ada or Bash (no Python).

## Files

- `shake512_file.adb` — prints the SHAKE512 digest of a file as hex.
- `sign_seal65.adb` — ML-DSA-65 detached-signs a file with a fresh seed from
  `/dev/urandom`. The private seed is never printed or persisted — only the
  public key and signature reach stdout.
- `verify_seal65.adb` — independently verifies an ML-DSA-65 signature
  (`verify_seal65 <file> <pk_hex> <sig_hex>`), for checking a seal after the
  fact.
- `rule30_salt.adb` — Epoch Rule30 Salt Stream (License §1.12/§5A.3.1):
  epoch milliseconds seed a Rule 30 cellular automaton, evolved 512 rounds;
  the output both salts the seal and XOR-masks the epoch value into
  `date_epoch_masked`. Uses the project's own `LTHING_Keccak.Sponge`
  (SHAKE256) for the length-condensation step.
- `build_seal.sh` — assembles the canonical LTHING document (4-space indent,
  double-quoted strings, CRLF line endings, alphabetically sorted keys),
  computes `seal_id` (SHAKE512 excluding itself), then signs everything
  except the `signature` field. Requires `jq` and the Ada binaries below.

## Build

```sh
mkdir -p obj bin
gnatmake -q -D obj -aI. -aI../../src -o bin/shake512_file shake512_file.adb
gnatmake -q -D obj -aI. -aI../../src -o bin/sign_seal65   sign_seal65.adb
gnatmake -q -D obj -aI. -aI../../src -o bin/verify_seal65 verify_seal65.adb
gnatmake -q -D obj -aI. -aI../../src -o bin/rule30_salt    rule30_salt.adb
```

(Run from this directory — the `.adb` files pull in the rest of `lthing-spark`
via `-aI../../src`; adjust `-aI` to point at `src/` if building elsewhere.)

## Generate a seal

```sh
CONTENT_HASH=$(bin/shake512_file path/to/artifact.tar.gz)
EPOCH_MS=$(date +%s%3N)
DATE_MASKED=$(bin/rule30_salt "$EPOCH_MS" | grep ^date_epoch_masked_hex= | cut -d= -f2)

cat > seal_fields.json <<EOF
{
  "attribution_name": "l'Evermoor",
  "license": "ESL-ANCSA-MRA-IndiModSHA v1.3",
  "date_epoch_masked": "$DATE_MASKED",
  "artifact": {"name": "...", "uri": "...", "content_hash": "$CONTENT_HASH", "hash_alg": "shake512"},
  "relation": "original",
  "ancestors": [],
  "adapter": {"name": "..."},
  "sig_alg": "ML-DSA-65"
}
EOF

./build_seal.sh --fields-json seal_fields.json --out PROVENANCE_SEAL.lthing
```

## Verify a seal afterward

Reconstruct the exact signed payload (the canonical document with `seal_id`
present and `signature`/`seal_signer_public_key` absent — see the
`canonical_render` jq filter in `build_seal.sh`), then:

```sh
bin/verify_seal65 signed_payload.bin <pk_from_seal> <sig_from_seal>
```

## Design notes

- `relation` must reflect what's actually true per License §1.3: an
  unmodified compilation/aggregation of existing Work is `"aggregation"`,
  not `"original"` — only the first-ever publication of new Work is
  `"original"`. Get this right; it's provenance metadata, not decoration.
- The Rule30 salt derivation here is **epoch-only** (License v1.3 as
  packaged with this tooling was amended to drop the ambient-temperature
  input from §1.12/§5A.3.1/§5A.4 — no physical sensor is assumed available
  to whatever environment runs this).
- `sign_seal65` generates a fresh, ephemeral ML-DSA-65 keypair per run. This
  is a per-seal attestation key, not a persistent identity key — nothing
  about this tooling gives a verifier grounds to treat two seals signed by
  the same run as linked, since a new key is drawn each time.
