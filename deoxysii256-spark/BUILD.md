# Build / prove

Toolchain used and verified in this environment: apt GNAT 13.3.0 for
`gnatls`/plain compiles, plus `gprbuild`/`gnatprove` 14.1.1 from the Nix
binary cache (no local GNAT project setup finds `gprbuild` via apt alone on
this image — see `lthing-spark/tools/setup-spark-toolchain.sh` in this repo
for how that toolchain was provisioned).

```sh
export PATH=/root/.nix-profile/bin:$PATH   # gprbuild, gnatprove

# build the crate (library, no main program)
gprbuild -P deoxysii256.gpr

# prove the whole crate
gnatprove -P deoxysii256.gpr --level=2 --report=all -j0

# prove a single unit
gnatprove -P deoxysii256.gpr -u deoxysii-tbc.adb --level=2 --report=all
```

G0 baseline (stub `deoxysii.adb` + identity-stub `deoxysii-tbc.adb` +
real `deoxysii-ct.ads/.adb`): `gnatprove` → **14 checks, 0 unproved**.

Test mains (`tests/kat_tbc.adb`, `tests/kat_aead.adb`) print `[PASS]`/`[FAIL]`
per vector and call `Set_Exit_Status (Failure)` on any fail, matching the
convention in `lthing-spark/run_tests.sh`.
