# ML-DSA-87 Signer (SPARK/Ada) — Standalone Package

The ML-DSA-87 (FIPS 204, NIST security category 5) signing implementation
from `lthing-spark/`, distributed here as a self-contained package — no
dependency on the rest of this repository. The packaged, built, and signed
distribution artifact lives at
[`lthing-spark/dist/mldsa87_signer_package.tar.gz`](lthing-spark/dist/mldsa87_signer_package.tar.gz);
this README documents that package's contents.

## Contents (inside the packaged tarball)

- `src/` — the complete with-closure of the signer, 15 units / 2,678 lines:
  - `sign_doc87.adb` — CLI entry point (`sign_doc87 <file> <passphrase>`)
  - `lthing_mldsa87_sign.ads/.adb` — Key_Gen + Sign (FIPS 204 Alg. 6/7)
  - `lthing_mldsa87.ads/.adb` — Verify (FIPS 204 Alg. 3/8) + public types
  - `lthing_mldsa87_codec.ads/.adb` — pkEncode/pkDecode, sigEncode/sigDecode
  - `lthing_mldsa87_sample.ads/.adb` — SampleInBall, ExpandA, RejNTTPoly
  - `lthing_mldsa_field.ads/.adb`, `lthing_mldsa_ntt.ads/.adb`,
    `lthing_mldsa_round.ads/.adb` — shared field arithmetic, NTT, rounding
    core (shared with the ML-DSA-65 implementation in the parent repo)
  - `lthing_keccak.ads/.adb` — pure-Ada Keccak-f[1600] / SHAKE256 / SHAKE512
  - `lthing_types.ads` — `Byte_Array` and shared subtypes
- `bin/sign_doc87` — built x86_64 Linux binary (GNAT 13.3.0, `-g -O0 -gnata`),
  present once you build (see below) — not shipped in the tarball itself
- `LICENSE.txt` (packaged copy; see [`LICENSE`](LICENSE) at this repo's root
  for the same text) — The Evermoor Sanctuary License
  (ESL-ANCSA-MRA-IndiModSHA) v1.3, the canonical license version for this
  package (see note below)

## Build

```sh
gnatmake -q -D obj -aIsrc -o bin/sign_doc87 src/sign_doc87.adb
```

No external libraries required — only the Ada/GNAT standard library
(`Ada.Text_IO`, `Ada.Command_Line`, `Ada.Streams.Stream_IO`, `Interfaces`).

## Usage

```sh
./bin/sign_doc87 <file> <passphrase>
```

Derives a 32-byte seed from the passphrase via SHAKE256, generates an
ML-DSA-87 keypair from that seed (`Key_Gen`), signs the file's contents
under an empty context string, and prints the hex-encoded public key
(2592 bytes / 5184 hex chars) followed by the hex-encoded signature
(4627 bytes / 9254 hex chars).

This CLI signs only — it does not verify. Signing is deterministic in the
passphrase: the same file + passphrase always reproduces the same keypair
and signature.

## Provenance

Extracted from `lthing-spark/src/` at commit `57fcb0b`
(branch `claude/check-function-hrzp7u`), 2026-07-03. The test suite this
code was verified against (`test_sign87.adb`, `test_verify_adv87.adb`,
`test_judicial87_sign.adb`, `test_kat87.adb` against NIST ACVP tcId 61–75)
and the standing SPARK proof status (`SPARK_PROOF_GAPS.md` / CI `gnatprove`
run) are not included in the packaged tarball — see `lthing-spark/` in this
repository for both.

## Licensing note

The Evermoor Sanctuary License's own provenance-sealing machinery
(Section 5A) is pinned to **ML-DSA-65** for signing Provenance Seals —
that governs how *seals under this license* are signed, not what
algorithm a *Work* licensed under it may implement. There is no conflict
in licensing an ML-DSA-87 signer under a license whose own seals use
ML-DSA-65.

v1.3 is used here (over v1.0) because it explicitly defines the LTHING
attribution/provenance format and its cryptographic stack (SHAKE512,
ML-DSA-65, Deoxys-II-256-128) — the same primitives implemented in the
parent `lthing-spark` project. v1.0 (JSON-based, `ed25519`-recommended)
is not included in this package but is available on request.
