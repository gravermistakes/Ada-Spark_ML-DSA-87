<!--
doc: CLAUDE
role: MAIN orchestrator entry point (read this first)
epoch: 1783124123
reads: DEOXYSIIS.md, AGENTS.md, DEOXY_1_41.md
-->

# CLAUDE — orchestrator entry, Deoxys-II-256-128 (Ada/SPARK)

## Mission
Produce a forward-only, KAT-validated, gnatprove-clean Ada/SPARK implementation of
**Deoxys-II-256-128** (mode SCT-2, internal cipher Deoxys-BC-384). Spec + build
contract are fixed in DEOXY_1_41.md and DEOXYSIIS.md. This file is the run order.

## Read map (sequential disclosure)
```
1. CLAUDE.md            (this file)            -- MAIN
2. DEOXYSIIS.md         sec 1,2,3,6,7,8,9      -- MAIN
3. DEOXY_1_41.md        sec 0, LANDMINE-1/2, G-KAT
4. AGENTS.md            (dispatch the two subagents)
```
Do NOT preload P-2..P-8 or M-3..M-4 into MAIN; those are subagent-scoped.

## Invariants (never violate)
- I1 Forward-only TBC. No inverse anything in v1 (EXT-1 is a seam, not a task).
- I2 Types (DEOXYSIIS 2) and seam `TBC_Encrypt_384` (P-9) frozen at G0.
- I3 Every gate closes on a passing vector or a discharged VC. Never inspection.
- I4 The cipher is defined by the pinned reference vectors, not by prose. When
     v1.41 and JoC disagree (LANDMINE-2), the KAT decides; both readings are
     already written, so no new source hunt is needed.
- I5 Constant-time verify, fail-closed, zeroize on failure (DEOXYSIIS 7).
- I6 No Python in the deliverable. If no GNAT host, ship the tree + BUILD.md and
     record gates as host-pending.

## Phase order
```
G0  MAIN     scaffold gpr + all .ads + stub tbc (returns Plaintext);
             gnatprove --level=2 clean on stubs; FREEZE seam + types.
             fetch + pin tests/vectors/ (P1 single-block + full-mode suite).
--- fork ---------------------------------------------------------------
P1  P        single-block TBC KAT -> pick ORD_A|ORD_B, set Seed_Order.
P2  P        full TBC KAT + AoRTE clean on tbc/tables.
M1  M        mode over reference-TBC oracle: full-mode KAT enc+dec;
             AoRTE clean on mode/ct; Decrypt Post proven.
--- join ---------------------------------------------------------------
G3  MAIN     swap oracle for real P; run official deoxysii256v141 suite
             (encrypt + decrypt + >=1 forgery); gnatprove --level=2 whole crate.
```
P1/P2 and M1 run concurrently after G0; they share only the frozen seam.

## Dispatch
- Give SUBAGENT-P: AGENTS.md#SUBAGENT-P, and its READ list resolves the exact
  DEOXY_1_41 / DEOXYSIIS sections. Nothing from M-*.
- Give SUBAGENT-M: AGENTS.md#SUBAGENT-M, plus a KAT-backed TBC oracle stub so M1
  can close before P2 lands.
- Do not relay P internals to M or vice versa. The seam is the only shared surface.

## Integration + proof (MAIN, at G3)
1. Replace the M-side oracle with `Deoxysii.TBC.TBC_Encrypt_384`.
2. Run `tests/kat_aead` against pinned vectors; require every vector pass and at
   least one forgery rejected (Ok=False, Msg zeroized).
3. `gnatprove -P deoxysii256.gpr --level=2` clean across tbc, mode, ct, api.
4. Report: per-vector table + gnatprove summary. DONE == G3 holds.

## Escalation
Any source conflict beyond LANDMINE-1/2, any vector that fails under BOTH ORD_A
and ORD_B, or any VC that will not discharge at level 2: STOP, report with the
concrete artifact, do not improvise a fix that diverges from the vectors.
