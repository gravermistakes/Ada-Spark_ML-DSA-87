<!--
doc: AGENTS
role: subagent charter (2 subagents under MAIN)
epoch: 1783124123
depends: DEOXY_1_41.md, DEOXYSIIS.md
-->

# AGENTS — Deoxys-II-256-128 build swarm

Two subagents, one main. P and M are independent after G0 because the seam
(`deoxysii-tbc.ads`, P-9) is frozen. Dispatch them in PARALLEL.

```
                MAIN (orchestrator)
                 |  freezes seam @ G0
       +---------+---------+
       |                   |
   SUBAGENT-P          SUBAGENT-M      (concurrent)
   primitive           mode
       |                   |
       +---------+---------+
                 |  MAIN integrates @ G3
              KAT green
```

## SUBAGENT-P — primitive (Deoxys-BC-384 forward)

- READ (in order, nothing else):
  DEOXY_1_41 sec 0, P-1..P-9, LANDMINE-1, LANDMINE-2;
  DEOXYSIIS sec 1,2,3(P rows),4,6(P1,P2),7.
- DELIVER: `deoxysii-tbc.adb`, `deoxysii-tbc-tables.ads` (+ contributes
  `kat_tbc.adb` cases with MAIN).
- SEAM: implement the body of `TBC_Encrypt_384` (P-9) exactly. Signature is
  MAIN's; do not change it.
- MILESTONES: P1 (single-block KAT -> fixes Seed_Order / LANDMINE-2), then P2
  (full TBC KAT + gnatprove AoRTE clean).
- FORBIDDEN: inverse S-box / inverse MixColumns / reverse tweakey (EXT-1 only);
  reading any M-* section; changing the seam; closing P1 on inspection instead of
  a vector; inventing a tweakey ordering beyond ORD_A/ORD_B.

## SUBAGENT-M — mode (SCT-2 AEAD)

- READ (in order, nothing else):
  DEOXY_1_41 sec 0, M-1..M-6;
  DEOXYSIIS sec 1,2,3(M rows),5,6(M1),7.
- DELIVER: `deoxysii.ads/adb` (public API M-6), `deoxysii-mode.ads/adb`,
  `deoxysii-ct.ads/adb`.
- SEAM: call `TBC_Encrypt_384` as an opaque oracle. Never open P-2..P-8. During
  M1 the oracle may be a KAT-backed reference stub supplied by MAIN.
- MILESTONES: M1 (mode vs reference-TBC oracle reproduces a full-mode KAT enc+dec;
  AoRTE clean on mode+ct; Decrypt Post proven).
- FORBIDDEN: reimplementing the TBC; secret-dependent branches in verify;
  early-return tag compare; exposing plaintext on the fail path; reading P-2..P-8.

## MAIN — orchestrator (see CLAUDE.md)
Owns G0 scaffold, the frozen seam, KAT fetch/pin, integration, and the whole-crate
gnatprove run at G3.

## Handshake invariants (all agents)
1. Types (DEOXYSIIS 2) and the seam (P-9) are immutable after G0.
2. Bytes are column-major into the state (P-1); tweaks are built MSB-first (M-2).
3. Acceptance = a named vector passes or a VC is discharged. Never "looks right".
4. On an unresolved source conflict, STOP and surface it to MAIN with both
   candidate readings; do not paper over it.
