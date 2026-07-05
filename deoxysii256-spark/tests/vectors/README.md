# Test vector provenance

**Single source: `peyrin_genkat_deoxysii256.txt`.**

A genkat trace file shared directly by **Thomas Peyrin**, co-designer of
Deoxys (Jean, Nikolić, Peyrin, Seurin, "The Deoxys AEAD Family",
J. Cryptology 2021), from his own working files. This is not a
third-party mirror or an independently-derived reference — it is the
designers' own reference tool's output, and it is the only vector source
this crate uses.

It contains all 8 official Deoxys-II-256-128 test vectors (associated
data, message, key, nonce, final ciphertext, final tag) **and every
intermediate single-block Deoxys-BC-384 evaluation** the reference tool
performed while sealing them — 133 raw
`(Key, Tweak, Plaintext) -> Ciphertext` calls in total, spanning the
AD-authentication, message-authentication, tag finalization, and
keystream-generation phases of the SCT-2 mode across messages/AD of every
length class (empty, single full block, multiple full blocks, and blocks
with a padded remainder).

No vector or intermediate value here was derived, computed, or adapted by
this project — every value used by this crate's tests is a direct
transcription of what the reference tool printed.

## Consumers

- `tests/kat_tbc.adb` (gate P1/P2): all 133 raw block-cipher calls,
  transcribed as Ada literal constants directly in the file, tested
  against `Deoxysii.TBC.TBC_Encrypt_384`.
- `tests/kat_aead.adb` (gate M1/G3): the 8 vectors' final (ciphertext,
  tag), transcribed the same way, tested as full Encrypt/Decrypt
  round-trips, plus at least one forgery-rejection case built by
  tampering a genuine sealed output.

Both test files are plain Ada with the transcribed values as literal
constants. **No tooling other than Ada/SPARK is used anywhere in this
crate, its tests, or its vector provenance** — not to fetch vectors, not
to derive them, not to transcribe them into test code.
