<!--
doc: DEOXY_1_41
role: reference-extraction (source of truth for both subagents)
epoch: 1783124123
authority: this file transcribes ONLY facts that appear in the two source PDFs
           (Deoxys v1.41, CAESAR round 3) and (Jean et al., J. Cryptology 2021).
           Where the two disagree, the disagreement is recorded verbatim as a
           LANDMINE and resolved by the KAT gate named in DEOXYSIIS.md, never by
           this document guessing.
consumers: SUBAGENT-P reads sections P-*, SUBAGENT-M reads sections M-*,
           MAIN reads sections G-* and both LANDMINE blocks.
-->

# DEOXY_1_41 — Deoxys-II-256-128 reference extraction

## DISCLOSURE (read only what your phase needs)

| you are        | read now                              | defer                 |
|----------------|---------------------------------------|-----------------------|
| MAIN           | 0, LANDMINE-1, LANDMINE-2, G-KAT      | P-*, M-*              |
| SUBAGENT-P     | 0, P-1..P-9, LANDMINE-1, LANDMINE-2   | M-*                   |
| SUBAGENT-M     | 0, M-1..M-6                           | P-2..P-9 (opaque TBC) |

Naming reconciliation used throughout this file:
`Deoxys-BC-384` (v1.41 name) == `Deoxys-TBC-384` (JoC name). Same primitive.

---

## 0. Parameters (frozen)

Target scheme: **Deoxys-II-256-128** (nonce-misuse-resistant, mode SCT-2).

| symbol | meaning                     | value                         | source                    |
|--------|-----------------------------|-------------------------------|---------------------------|
| k      | key size                    | 256 bits (32 bytes)           | v1.41 Tab 2.1 / JoC Tab   |
| n      | block size                  | 128 bits (16 bytes)           | v1.41 Tab 2.1             |
| t      | tweak size (TBC signature)  | 128 bits                      | v1.41 Tab 2.1             |
| \|N\|  | nonce size                  | 120 bits (15 bytes)           | v1.41 Tab 2.1 / JoC 605   |
| tau    | tag size                    | 128 bits (16 bytes)           | v1.41 Tab 2.1             |
| TBC    | internal cipher             | Deoxys-BC-384 (16 rounds)     | v1.41 l.172 / JoC 328,333 |
| tweakey size | k + t                 | 384 bits                      | JoC Tab l.328             |
| maxl   | max message length (blocks) | 2^60  ( = 2^(ceil(t/2)-4) )   | v1.41 l.131               |
| maxm   | max messages per key        | 2^64  ( = 2^floor(t/2) )      | v1.41 l.131               |

Deoxys-II decryption uses **only forward TBC encryption** E_K. No TBC decryption
is invoked anywhere in the mode (auth, tag, keystream, and verify all use E_K).
=> the primitive layer ships **forward-only** for this target. Inverse S-box,
inverse MixColumns, and reverse tweakey order are OUT OF SCOPE (extension point
only; see DEOXYSIIS.md EXT-1).

---

## P — PRIMITIVE: Deoxys-BC-384 (forward encryption)

### P-1. State model
- State S is 16 bytes indexed 0..15, laid out column-major as a 4x4 matrix:
  `pos = row + 4*col`, i.e.
  ```
  col:  0  1  2  3
  row0  0  4  8 12
  row1  1  5  9 13
  row2  2  6 10 14
  row3  3  7 11 15
  ```
- Plaintext byte j (j=0..15) loads into state[j]. Ciphertext read out the same way.
- Field GF(2^8), irreducible polynomial x^8+x^4+x^3+x+1 (0x11B). (v1.41 l.514)

### P-2. Round structure (r = 16)
Order per round differs from AES: **AddRoundTweakey is FIRST.** (v1.41 l.516-526)
```
S := Plaintext
for k in 0 .. 15 loop          -- 16 rounds
    S := S xor STK[k]          -- AddRoundTweakey
    S := SubBytes(S)
    S := ShiftRows(S)
    S := MixColumns(S)
end loop
S := S xor STK[16]             -- final AddRoundTweakey
Ciphertext := S
```
17 subtweakeys STK[0..16] are consumed. There is NO MixColumns after the final
AddRoundTweakey.

### P-3. SubBytes — AES S-box (forward). (v1.41 App A.1)
`S[i] := SBOX[S[i]]`, table indexed by full byte value, row = high nibble,
col = low nibble.
```
      .0 .1 .2 .3 .4 .5 .6 .7 .8 .9 .A .B .C .D .E .F
0.    63 7C 77 7B F2 6B 6F C5 30 01 67 2B FE D7 AB 76
1.    CA 82 C9 7D FA 59 47 F0 AD D4 A2 AF 9C A4 72 C0
2.    B7 FD 93 26 36 3F F7 CC 34 A5 E5 F1 71 D8 31 15
3.    04 C7 23 C3 18 96 05 9A 07 12 80 E2 EB 27 B2 75
4.    09 83 2C 1A 1B 6E 5A A0 52 3B D6 B3 29 E3 2F 84
5.    53 D1 00 ED 20 FC B1 5B 6A CB BE 39 4A 4C 58 CF
6.    D0 EF AA FB 43 4D 33 85 45 F9 02 7F 50 3C 9F A8
7.    51 A3 40 8F 92 9D 38 F5 BC B6 DA 21 10 FF F3 D2
8.    CD 0C 13 EC 5F 97 44 17 C4 A7 7E 3D 64 5D 19 73
9.    60 81 4F DC 22 2A 90 88 46 EE B8 14 DE 5E 0B DB
A.    E0 32 3A 0A 49 06 24 5C C2 D3 AC 62 91 95 E4 79
B.    E7 C8 37 6D 8D D5 4E A9 6C 56 F4 EA 65 7A AE 08
C.    BA 78 25 2E 1C A6 B4 C6 E8 DD 74 1F 4B BD 8B 8A
D.    70 3E B5 66 48 03 F6 0E 61 35 57 B9 86 C1 1D 9E
E.    E1 F8 98 11 69 D9 8E 94 9B 1E 87 E9 CE 55 28 DF
F.    8C A1 89 0D BF E6 42 68 41 99 2D 0F B0 54 BB 16
```
Self-test: SBOX[0x25] = 0x3F (v1.41 A.1 example).

### P-4. ShiftRows. (v1.41 l.523)
Row i rotated LEFT by rho[i], rho = (0,1,2,3). Standard AES ShiftRows.
Column-major position map (new[i] := old[SR[i]]):
```
SR = ( 0, 5,10,15,  4, 9,14, 3,  8,13, 2, 7, 12, 1, 6,11 )
```

### P-5. MixColumns — AES MDS. (v1.41 l.526-534; v1.41 calls it "MixBytes")
Per column c, with a=S[4c+0], b=S[4c+1], d=S[4c+2], e=S[4c+3]:
```
S[4c+0] = 2.a xor 3.b xor 1.d xor 1.e
S[4c+1] = 1.a xor 2.b xor 3.d xor 1.e
S[4c+2] = 1.a xor 1.b xor 2.d xor 3.e
S[4c+3] = 3.a xor 1.b xor 1.d xor 2.e
```
where `2.x = xtime(x)` (left shift, xor 0x1B if the pre-shift MSB was 1) and
`3.x = xtime(x) xor x`, all in GF(2^8)/0x11B.

### P-6. Tweakey material assembly
KT is the 384-bit tweakey = concatenation `K || T`:
- K = 256-bit key = `Khi || Klo` (Khi = most-significant 128 bits of K).
- T = 128-bit tweak (supplied by the mode per call).
KT (most-significant first) = `Khi(128) || Klo(128) || T(128)`.
The three 128-bit tweakey words W1,W2,W3 seed lanes TK1,TK2,TK3 via
TK1[0]=W1, TK2[0]=W2, TK3[0]=W3. **Which physical slice is W1 vs W3 is
LANDMINE-2 below.**

### P-7. Tweakey schedule recurrences (v1.41 l.593-620 == JoC 438-460)
For i = 0 .. 15:
```
TK1[i+1] = h(         TK1[i] )      -- lane p=1: h only, no LFSR
TK2[i+1] = h( LFSR2(  TK2[i]) )     -- lane p=2
TK3[i+1] = h( LFSR3(  TK3[i]) )     -- lane p=3
```
Subtweakey: `STK[i] = TK1[i] xor TK2[i] xor TK3[i] xor RC[i]`.

Byte permutation h (gather form: `new[i] := old[h[i]]`, i=0..15):
```
h = ( 1, 6,11,12,  5,10,15, 0,  9,14, 3, 4, 13, 2, 7, 8 )
```
LFSR2 (per byte, x7=MSB..x0=LSB): out = (x6 x5 x4 x3 x2 x1 x0, x7 xor x5)
  => `out = ((b << 1) and 16#FF#) or (((b >> 7) xor (b >> 5)) and 1)`
LFSR3 (per byte): out = (x0 xor x6, x7 x6 x5 x4 x3 x2 x1)
  => `out = (b >> 1) or ((((b and 1) xor ((b >> 6) and 1)) and 1) << 7)`

### P-8. Round constants RC[i] (RESOLVED, no ambiguity)
RC[i] is a 128-bit constant, column-major bytes:
```
RC[i] = ( 16#1#,16#2#,16#4#,16#8#,  RCON(i),RCON(i),RCON(i),RCON(i),
          0,0,0,0,  0,0,0,0 )
```
RCON is the 17-byte sequence indexed 0..16:
```
RCON = ( 2f, 5e, bc, 63, c6, 97, 35, 6a, d4,
         b3, 7d, fa, ef, c5, 91, 39, 72 )   -- hex
```
Provenance (independently derived, not transcribed on faith):
RCON(i) = x^(15+i) in GF(2^8)/0x11B (JoC l.497: "i+15-th AES key-schedule
constant"). x^15=2f, x^16=5e, x^17=bc, x^18=63, ... reproduces the row exactly.

### P-9. Primitive interface (the seam SUBAGENT-M depends on)
```
function TBC_Encrypt_384 (Key       : Key_256;      -- 32 bytes
                          Tweak     : Block_128;    -- 16 bytes
                          Plaintext : Block_128)    -- 16 bytes
                          return Block_128          -- 16 bytes
with Global => null;                                -- pure, side-effect free
```
SUBAGENT-M treats this as opaque and MUST NOT reimplement any of P-2..P-8.

---

## LANDMINE-1 (RESOLVED) — RCON caption vs table

v1.41 App A.2 *table row* gives RCON(0)=0x2f (indices 0..16). v1.41 A.2
*caption* says "RCON[1]=0x2f, RCON[2]=0x5e, RCON[11]=0xb3", which is 1-based and
internally inconsistent. RESOLUTION: the table row is authoritative and matches
x^(15+i) (P-8 provenance). Ignore the caption. STK[0] uses RCON(0)=0x2f.

## LANDMINE-2 (KAT-RESOLVED) — tweakey word ordering

The two sources label the physical slices of KT oppositely, yet both set
TK1[0]=W1, TK2[0]=W2, TK3[0]=W3. Since lane p=1 has no LFSR while p=2,p=3 do,
the assignment of physical slice to lane is FUNCTIONAL, not cosmetic.

| candidate | (TK1[0], TK2[0], TK3[0]) fed from | source of the labeling      |
|-----------|-----------------------------------|-----------------------------|
| ORD-A     | (Khi, Klo, T)  = (MSB, mid, LSB)   | v1.41 l.584-594 prose       |
| ORD-B     | (T, Klo, Khi)  = (LSB, mid, MSB)   | JoC l.423-439 prose         |

Both are written out so nothing is lost. The implementation selects the one that
reproduces the official single-block Deoxys-BC-384 KAT (DEOXYSIIS.md gate P1).
This document does NOT declare a winner; the vector does. Wire the seed mapping
as one isolated, swappable constant so flipping A<->B is a one-line change.

---

## M — MODE: Deoxys-II SCT-2 (E^II / D^II)

SUBAGENT-M may read M-* without any P section except the P-9 seam.

### M-1. Notation
- E(tweak, block) = `TBC_Encrypt_384(Key, tweak, block)`, tweak and block are
  16-byte values. Tweaks are built as `prefix_bits || counter_or_nonce`, padded
  to exactly 128 bits.
- `pad10(X)` = 10* padding to n bits: for |X| < n, `X || 1 || 0^(n-|X|-1)`.
  For empty X, pad10 adds nothing and the term is skipped (no block). (v1.41 l.116)
- Counters i, j, l, la are big-endian integers packed into the low bits of the
  tweak after the 4-bit prefix (encoded on t-4 = 124 bits). (v1.41 l.419-421)

### M-2. Domain-separation tweaks (frozen table)
All auth/tag tweaks have MSB = 0; the encryption tweak has MSB = 1. That single
bit is the top-level domain split.

| purpose                | tweak (128 bits)                  | block input to E    |
|------------------------|-----------------------------------|---------------------|
| AD, full block i       | `0010 \|\| i(124)`                | A_{i+1}             |
| AD, last partial (la)  | `0110 \|\| la(124)`               | pad10(A*)           |
| Msg-auth, full block j | `0000 \|\| j(124)`                | M_{j+1}             |
| Msg-auth, last (l)     | `0100 \|\| l(124)`                | pad10(M*)           |
| Tag finalization       | `0001 \|\| 0000 \|\| N(120)`      | running tag         |
| Keystream, block j     | `tagp xor int_128(j)`             | `0x00 \|\| N(120)`  |

`tagp` = tag with its most-significant bit forced to 1 (`tagp = tag or 2^127`).
Because j <= maxl-1 = 2^60-1, `int_128(j)` never touches bit 127, so every
keystream tweak keeps MSB=1. This is exactly v1.41's `1 || (tag xor j)` with the
top bit truncated (v1.41 l.420, l.444-448) and JoC's Fig 6 `tagp` convention;
the two descriptions are identical. Use `tagp xor int_128(j)`.

Keystream block input `0x00 || N` = one zero byte then the 15-byte (120-bit)
nonce = 16 bytes total. (v1.41 l.444)

### M-3. Encryption E^II (v1.41 Algorithm 3, l.423-451)
```
-- associated data
Auth := 0^128
split A into full blocks A_1..A_la and remainder A* (|A*| < n)
for i in 0 .. la-1 loop  Auth := Auth xor E(0010||i, A_{i+1})  end loop
if A* nonempty then      Auth := Auth xor E(0110||la, pad10(A*)) end if

-- message authentication -> tag
tag := Auth
split M into full blocks M_1..M_l and remainder M* (|M*| < n)
for j in 0 .. l-1 loop   tag := tag xor E(0000||j, M_{j+1}) end loop
if M* nonempty then      tag := tag xor E(0100||l, pad10(M*)) end if
tag := E(0001||0000||N, tag)              -- tag finalization

-- encryption (counter-style, forward E only)
tagp := tag or 2^127
for j in 0 .. l-1 loop   C_j := M_j xor E(tagp xor j, 0x00||N) end loop
if M* nonempty then
    KS   := E(tagp xor l, 0x00||N)
    C*   := M* xor truncate(KS, |M*|)     -- keep leftmost |M*| bytes
end if
return (C_1||..||C_l||C*, tag)
```

### M-4. Decryption / verification D^II (v1.41 Algorithm 4, l.457-...)
Decryption regenerates the SAME keystream from the RECEIVED tag, recovers M,
then recomputes the tag over the recovered M and the AD, and compares.
```
-- recover message (forward E only, identical keystream as M-3)
tagp := received_tag or 2^127
for j in 0 .. l-1 loop   M_j := C_j xor E(tagp xor j, 0x00||N) end loop
if C* nonempty then
    KS := E(tagp xor l, 0x00||N)
    M* := C* xor truncate(KS, |C*|)
end if

-- recompute Auth over AD (same as M-3 AD phase)
-- recompute tag' over recovered M (same as M-3 auth + finalization)
tag' := finalize(Auth, M_1..M_l, M*, N)

-- verify, fail-closed
if ct_equal(tag', received_tag) then return (M_1||..||M_l||M*)
else zeroize(M);          return BOTTOM  end if
```

### M-5. Verification requirements (security-load-bearing)
- `ct_equal` MUST be constant-time: accumulate `diff := diff or (a[i] xor b[i])`
  over all 16 bytes, then test `diff = 0`. No early return, no branch on byte.
- On failure the plaintext buffer MUST be zeroized before returning BOTTOM; the
  API MUST NOT expose any recovered-plaintext bytes on failure.
- BOTTOM is a distinct return (not an empty message); the caller cannot confuse
  "valid empty message" with "invalid".

### M-6. Mode interface (public API the whole crate exposes)
```
procedure Encrypt (Key   : Key_256;  Nonce : Nonce_120;
                   AD    : Byte_Seq;  Msg   : Byte_Seq;
                   CT    : out Byte_Seq;  Tag : out Tag_128)
with Pre => CT'Length = Msg'Length;

procedure Decrypt (Key   : Key_256;  Nonce : Nonce_120;
                   AD    : Byte_Seq;  CT    : Byte_Seq;  Tag : Tag_128;
                   Msg   : out Byte_Seq;  Ok  : out Boolean)
with Pre  => Msg'Length = CT'Length,
     Post => (if not Ok then (for all B of Msg => B = 0));
```
`Nonce_120` = 15 bytes. Lengths bounded by maxl*16 bytes (2^64 bytes).

---

## G-KAT — acceptance ground truth (MAIN owns)

The cipher is defined by its vectors, not by prose. Two vector sets gate the build:

1. **P1 single-block TBC vector** (resolves LANDMINE-2): one
   (Key_256, Tweak_128, PT_128) -> CT_128 triple for Deoxys-BC-384. Source: the
   authors'/CAESAR reference implementation `deoxysii256v141` (SUPERCOP
   `crypto_aead/deoxysii256v141/ref`), from which a raw TBC vector is lifted, OR
   a peer-reviewed test-vector appendix. MAIN fetches/pins this artifact; it is
   NOT to be fabricated. If no raw TBC vector is available, derive P1 from a
   full-mode KAT with empty AD and a single-block all-zero message and back out
   the TBC output analytically.
2. **Full-mode KAT suite** for `deoxysii256v141`: the CAESAR `genkat_aead`
   LWC/known-answer file (encrypt vectors + at least one forgery/authentication
   -failure vector). Source: same reference package.

Determinism rule: every acceptance claim in DEOXYSIIS.md is "vector X passes",
never "looks correct". No milestone closes on inspection alone.
