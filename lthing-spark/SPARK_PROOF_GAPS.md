# SPARK proof status

This filename is retained because older audit documents link to it. Its former
contents described the first honest proof pass after crypto units previously
excluded from SPARK were enabled. That checklist is historical.

## Current acceptance rule

```sh
export PATH=/root/.alire/bin:$PATH
gnatprove -P lthing.gpr --level=2 --report=all -j0
```

The required result is **0 unproved** over the current genericized production
tree.

## Historical gaps that were closed

Earlier proof work covered mutable NTT initialization state, NTT loop/index
bounds, XOF and sampling buffer bounds, verifier message sizing, hint-weight
bounds, and production crypto units that had been outside SPARK analysis.

The subsequent generic migration removed the duplicated concrete
ML-DSA-65/87 implementations. The Aug. 1, 2026 history records both the generic
migration and the final branchless `Mod_Pm` proof repair.

## Scope

GNATprove establishes the stated SPARK flow/contracts/AoRTE obligations. It does
not by itself prove FIPS 204 equivalence or machine-code constant-time behavior.
Those require KAT/interoperability and timing/code-generation evidence
respectively.

Deoxys-II currently has its own project and is not included in this top-level
proof claim.
