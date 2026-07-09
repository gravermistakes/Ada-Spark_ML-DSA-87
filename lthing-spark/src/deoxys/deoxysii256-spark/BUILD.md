# BUILD — deoxysii256-spark

Ada/SPARK crate for Deoxys-II-256-128 (SCT-2 over Deoxys-BC-384, forward-only).
Contract: `../DEOXYSIIS.md` (build spec) + `../DEOXY_1_41.md` (reference
extraction). Language policy: Ada and Bash only (root `CLAUDE.md`).

## Toolchain
- GNAT (apt: `gnatmake`/`gprbuild`), gnatprove (Alire): `export PATH=/root/.alire/bin:$PATH`

## Build
```sh
gprbuild -P deoxysii256.gpr
```

## Prove (gate: 0 unproved at level 2)
```sh
gnatprove -P deoxysii256.gpr --level=2 --report=all -j0
```

## Test mains (built out-of-project; tests/ is not SPARK)
```sh
gnatmake -q -D /tmp/dxb -aIsrc -aItests -o /tmp/dxb/kat_tbc  tests/kat_tbc.adb  && /tmp/dxb/kat_tbc
gnatmake -q -D /tmp/dxb -aIsrc -aItests -o /tmp/dxb/kat_aead tests/kat_aead.adb && /tmp/dxb/kat_aead
```
Tests print `[PASS]`/`[FAIL]` and exit non-zero on failure.

## Vectors (pinned, authoritative — never regenerate)
`tests/vectors/deoxysii256v141-verbose-kat.txt` — the reference
implementation's verbose known-answer traces for Deoxys-II-256-128
(8 vectors: AD/Message/Key/Nonce -> Ciphertext/Tag, including raw
Deoxys-BC-384 block-cipher calls usable as single-block TBC vectors).

## Gates
G0 stubs prove clean -> P1 (single-block TBC KAT fixes Seed_Order) ->
P2 (full TBC KAT + AoRTE) ∥ M1 (mode over oracle + Decrypt Post) ->
G3 (integrated official suite + >=1 forgery rejected + whole-crate prove).
