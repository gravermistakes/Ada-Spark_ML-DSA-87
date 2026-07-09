<!--
doc: DEOXYSIIS
role: build spec + requirements (Ada/SPARK) for Deoxys-II-256-128
epoch: 1783124123
depends: DEOXY_1_41.md (reference extraction)
consumers: MAIN (all), SUBAGENT-P (P-lane + shared), SUBAGENT-M (M-lane + shared)
license: THE EVERMOOR SANCTUARY LICENSE (ESL-ANCSA-MRA-IndiModSHA v1.3),
         per the repository LICENSE file. GPL-3.0-or-later compatible copyleft.
-->

# DEOXYSIIS — Ada/SPARK build specification, Deoxys-II-256-128

## DISCLOSURE

| you are     | read now                                  | defer         |
|-------------|-------------------------------------------|---------------|
| MAIN        | 1, 2, 3, 6, 7, 8, 9                       | 4, 5          |
| SUBAGENT-P  | 1, 2, 3 (P rows), 4, 6 (P1,P2), 7         | 5, 8          |
| SUBAGENT-M  | 1, 2, 3 (M rows), 5, 6 (M1), 7            | 4, 8          |

## 1. Toolchain (deterministic)
- Compiler: FSF GNAT (Ada 2012 subset used by SPARK). Prover: SPARK / gnatprove.
- Build: `gprbuild -P deoxysii256.gpr`. Proof: `gnatprove -P deoxysii256.gpr --level=2`.
- Ada does NOT run in the claude.ai sandbox. If no local GNAT: MAIN emits the full
  source tree + a `BUILD.md` with exact commands as the deliverable (scaffold path),
  and gates are recorded as "to be run on a GNAT host". Do NOT substitute Python.
- No dynamic allocation, no secondary stack in the crypto core; bounded loops only.

## 2. Type contract (shared, frozen at G0)
```ada
type Byte is mod 2**8 with Size => 8;
type Block_128 is array (0 .. 15) of Byte;   -- column-major state (P-1)
type Key_256   is array (0 .. 31) of Byte;
type Nonce_120 is array (0 .. 14) of Byte;
type Tag_128   is array (0 .. 15) of Byte;
type Byte_Seq  is array (Natural range <>) of Byte;
subtype State  is Block_128;
type Subtweakeys is array (0 .. 16) of Block_128;   -- STK[0..16] (P-2)
```

## 3. Package layout (frozen at G0)
```
deoxysii256-spark/
  deoxysii256.gpr
  src/
    deoxysii.ads            [M] public API  (M-6)          SPARK_Mode On
    deoxysii.adb            [M]                             SPARK_Mode On
    deoxysii-tbc.ads        [seam] P-9 signature only       SPARK_Mode On
    deoxysii-tbc.adb        [P]  Deoxys-BC-384 forward      SPARK_Mode On
    deoxysii-tbc-tables.ads [P]  SBOX, SR, h, RCON (P-3..8) SPARK_Mode On
    deoxysii-mode.ads       [M]  internal SCT-2             SPARK_Mode On
    deoxysii-mode.adb       [M]                             SPARK_Mode On
    deoxysii-ct.ads         [shared] ct_equal, zeroize      SPARK_Mode On
    deoxysii-ct.adb         [shared]                        SPARK_Mode On
  tests/  kat_tbc.adb [P/MAIN]  kat_aead.adb [MAIN]  vectors/  (not SPARK)
  BUILD.md
```
Column `[P]/[M]/[seam]/[shared]` = owning lane. The seam `deoxysii-tbc.ads` is
written by MAIN at G0 and is immutable thereafter; P fills the body, M calls it.

## 4. P-lane requirements (SUBAGENT-P)
- Implement exactly DEOXY_1_41 P-2..P-8, forward only. No inverse tables.
- `deoxysii-tbc-tables.ads`: SBOX (P-3), SR map (P-4), h (P-7), RCON (P-8) as
  compile-time constant arrays. Include the SBOX[0x25]=0x3F self-test as an
  aspect/assertion.
- Tweakey seed mapping (P-6/LANDMINE-2) is ONE named constant:
  `Seed_Order : constant := ORD_A;` -- flip to ORD_B if gate P1 fails.
  ORD_A: TK1<-Khi, TK2<-Klo, TK3<-T.   ORD_B: TK1<-T, TK2<-Klo, TK3<-Khi.
- `TBC_Encrypt_384` body: schedule STK[0..16] then run the P-2 loop.
- SPARK: prove AoRTE at --level=2. GF ops (xtime, LFSR2/3) are `mod 2**8`, no
  overflow VC survives. No secret-dependent control flow (table lookups excepted,
  see 7).

## 5. M-lane requirements (SUBAGENT-M)
- Implement M-2..M-6 over the P-9 seam. Never open the TBC body.
- Build tweaks by the M-2 table; the 4-bit prefix occupies the top nibble of
  byte 0, counters big-endian in the remaining 124 bits. Keystream tweak =
  `tagp xor int_128(j)`, `tagp = tag or 2**127` (set bit 7 of byte 0).
- pad10 per M-1; empty tail skips its block entirely.
- Decrypt is forward-only (M-4). Verify via `Deoxysii.CT.CT_Equal` (constant-time).
- SPARK: prove AoRTE, prove loop counters bounded by maxl, prove the Decrypt
  `Post` (fail => Msg all zero). Prove no read of `Msg` out param on the fail path
  except the zeroizing write.

## 6. Milestone gates (deterministic; P and M run in PARALLEL after G0)
| gate | owner       | exit condition (all must hold)                                   |
|------|-------------|------------------------------------------------------------------|
| G0   | MAIN        | tree + gpr build green with STUB tbc (returns Plaintext); gnatprove --level=2 clean on stubs; seam + types frozen |
| P1   | SUBAGENT-P  | single-block Deoxys-BC-384 KAT passes -> LANDMINE-2 selected & Seed_Order fixed |
| P2   | SUBAGENT-P  | full 16-round TBC KAT passes; gnatprove AoRTE clean on tbc + tables |
| M1   | SUBAGENT-M  | mode over a reference-TBC oracle reproduces a full-mode KAT enc+dec; gnatprove AoRTE clean on mode + ct; Decrypt Post proven |
| G3   | MAIN        | real P + M integrated; official deoxysii256v141 KAT suite green (encrypt, decrypt, >=1 forgery rejected); gnatprove --level=2 clean whole crate |

Every exit condition is a passing vector or a discharged VC. None closes on
inspection. If P1 fails on ORD_A, flip to ORD_B and re-run; if both fail, STOP and
report a vector/interpretation mismatch to MAIN (do not invent a third ordering).

## 7. Constant-time + hardening rules (shared)
- `CT_Equal(a,b)`: `diff := 0; for i loop diff := diff or (a(i) xor b(i)); end loop;
  return diff = 0;` No early return, no branch on a byte value.
- `Zeroize(Msg)`: unconditional overwrite with 0; mark `pragma Inspection_Point`
  or use `System.Storage_Elements` write to resist DCE (document if the compiler
  elides it).
- Fail-closed: Decrypt returns `Ok=False` and zeroized `Msg`; no plaintext leaks.
- TIMING CAVEAT (documented non-goal for v1): the AES S-box is a secret-indexed
  table lookup and is not cache-timing-constant. Functional-correctness scope
  accepts this. Bitsliced/constant-time S-box = EXT-2 (hardening pass, route via
  /AVRS-dusk2dawn or /analgapes).

## 8. Extension points (OUT OF SCOPE for v1, wired as seams)
- EXT-1: full Deoxys-BC-384 with TBC DECRYPTION (inverse S-box, inverse
  MixColumns, reverse tweakey order) to support a general Deoxys-BC library or
  Deoxys-I. Add `TBC_Decrypt_384` beside the seam; do not alter forward path.
- EXT-2: constant-time S-box (see 7).

## 9. Acceptance (MAIN)
- Ground truth = pinned `deoxysii256v141` reference vectors (DEOXY_1_41 G-KAT).
  MAIN fetches and commits them under `tests/vectors/`; never fabricated.
- The crate is DONE when G3 holds. Report per-vector pass/fail and the gnatprove
  summary, nothing softer.
