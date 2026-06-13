------------------------------------------------------------------------------
--  LTHING.Keccak — pure Ada/SPARK Keccak-f[1600] + SHAKE (FIPS 202)
--
--  WHY THIS EXISTS
--  ---------------
--  The hardened x86-64 asm Keccak (keccak.asm, via LTHING_Crypto_FFI) has now
--  shipped FOUR distinct correctness bugs across the project's history — the
--  3-register addressing + uninitialised-shift pair (AVRS FINDING-001) and the
--  three masking bugs fixed 2026-06-08 (rho+pi no-op, in-place chi corruption,
--  missing SHAKE pad/domain). Each masked the next and none was caught by the
--  committed test harness (which exercises only rule30 / XOR / compare_ct, never
--  Keccak). Every one of those bug classes — out-of-range indexing, reading a
--  half-overwritten state during chi, wrong shift amounts — is exactly what
--  SPARK's Absence-of-Run-Time-Errors proof plus structured (write-to-B, read-
--  from-B) array code eliminates by construction.
--
--  This package replaces the FFI hash core with provable Ada. It is the
--  drop-in source of SHAKE for LTHING_Hash (the Provenance Seal and
--  provenance_chain_hash) and, once Parts 3-5 land, for ExpandA / SampleInBall.
--
--  POSTURE (honest)
--  ----------------
--  * SPARK_Mode (On): the intended proof obligation is AoRTE (no overflow — the
--    lanes are modular Unsigned_64; no index-out-of-range — every subscript is
--    a static 0..24 or a checked byte offset). It must be discharged by
--    gnatprove in a real GNAT/SPARK toolchain; this was authored in an
--    environment without one, so AoRTE is asserted as the design target, NOT
--    claimed as discharged.
--  * Functional correctness is KAT-gated, not proved (proving a hash equals
--    FIPS 202 is infeasible). The algorithm here was validated byte-for-byte
--    against FIPS 202 and Python hashlib before transcription:
--      keccak_f1600(0) lane0 = f1258f7940e1dde7
--      SHAKE256("")/("abc")/200B and SHAKE128("")/("abc") match hashlib
--    See test_keccak.adb for the frozen vectors, including the rate-72
--    "SHAKE512" production vectors that the asm path NEVER had a KAT for.
--
--  GPL-3.0-or-later.
------------------------------------------------------------------------------

pragma SPARK_Mode (On);

with Interfaces; use Interfaces;

package LTHING_Keccak is

   subtype Byte is Unsigned_8;

   --  Local byte string. Mirrors LTHING_Types.Byte_Array; kept local so this
   --  unit compiles standalone and can be dropped into lthing-spark as-is.
   type Byte_Array is array (Natural range <>) of Byte;

   --  Keccak state: 25 lanes of 64 bits, lane index = x + 5*y.
   type State is array (0 .. 24) of Unsigned_64;

   --  FIPS 202 sponge rates (bytes). "SHAKE512" (rate 72, capacity 1024) is the
   --  LTHING-specific 64-byte digest the judicial seal/chain use; it is a valid
   --  Keccak[c=1024] sponge with SHAKE domain separation, not a standard FIPS
   --  function name.
   Rate_SHAKE128 : constant := 168;
   Rate_SHAKE256 : constant := 136;
   Rate_SHAKE512 : constant := 72;

   --  Keccak-f[1600] permutation (24 rounds), in place.
   procedure Keccak_F1600 (A : in out State)
     with Global => null;

   --  One-shot SHAKE: absorb Input, then squeeze Output'Length bytes.
   --  Rate selects the variant; SHAKE domain byte 0x1F + pad10*1 are applied.
   --  Deterministic: equal (Input, Rate) always yields equal Output — the
   --  property the seal-match and chain-link checks rely on.
   procedure SHAKE
     (Input  : Byte_Array;
      Rate   : Positive;
      Output : out Byte_Array)
     with Global => null,
          Pre    => Rate <= 200 and then Output'Length > 0;

end LTHING_Keccak;
