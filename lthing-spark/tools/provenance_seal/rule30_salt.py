#!/usr/bin/env python3
"""
Epoch Rule30 Salt Stream — implements License sec 1.12 / 5A.3.1 exactly
(epoch-milliseconds-only variant, no ambient-temperature input).

Derivation, matching the license text step for step:
  (a) take the current Unix epoch milliseconds (64-bit integer)
  (b) encode the value as canonical UTF-8 bytes with an explicit field label
  (c) initialize a Rule 30 1-D cellular automaton seed from those bytes
  (d) evolve Rule 30 for a fixed, documented number of rounds and extract
      bytes from its state
  (e) use the extracted bytes as salt material and as the keystream
  (f) XOR the epoch millisecond value bytes with the Rule30 keystream to
      produce the epoch-masked value ("date_epoch_masked")

Derivation descriptor (published per sec 5A.3.1(iv)):
  algorithm_version : rule30-epoch-v1
  rule30_round_count : 512
  byte_extraction_rule : center 64 cells of the final row, packed MSB-first
                          into 8 bytes per round, rounds concatenated in
                          evolution order, truncated/repeated (via SHAKE512
                          expansion below) to the salt length required
"""
import sys
import struct
import hashlib

ROUND_COUNT = 512
CELL_WIDTH = 257  # odd width so there's a true center cell; must be >= 65 for a 64-bit center window


def rule30_seed_from_epoch_ms(epoch_ms: int) -> bytes:
    label = b"epoch_ms="
    value = str(epoch_ms).encode("ascii")
    return label + value


def rule30_evolve(seed_bytes: bytes, width: int, rounds: int) -> bytes:
    """Evolve Rule 30 for `rounds` steps; extract the center 64 cells of
    every row (packed into 8 bytes, MSB-first), concatenate across rounds."""
    bits = [0] * width
    seed_bits = []
    for byte in seed_bytes:
        for i in range(8):
            seed_bits.append((byte >> (7 - i)) & 1)
    for i, b in enumerate(seed_bits[:width]):
        bits[i] = b
    if not any(bits):
        bits[width // 2] = 1  # never evolve an all-zero row

    center = width // 2
    out = bytearray()
    row = bits
    for _ in range(rounds):
        window = row[center - 32: center + 32]
        byte_chunk = bytearray(8)
        for i in range(64):
            if window[i]:
                byte_chunk[i // 8] |= (1 << (7 - (i % 8)))
        out += byte_chunk

        new_row = [0] * width
        for i in range(width):
            left = row[i - 1] if i > 0 else row[-1]
            center_v = row[i]
            right = row[i + 1] if i < width - 1 else row[0]
            pattern = (left << 2) | (center_v << 1) | right
            new_row[i] = (0b00011110 >> pattern) & 1  # Rule 30
        row = new_row
    return bytes(out)


def derive(epoch_ms: int, salt_len: int = 64):
    seed_bytes = rule30_seed_from_epoch_ms(epoch_ms)
    raw = rule30_evolve(seed_bytes, CELL_WIDTH, ROUND_COUNT)
    # Expand/condense the raw Rule30 output to the exact salt length via
    # SHAKE512-flavored expansion (SHA3's shake_256 used here purely as a
    # length-extension primitive over the CA output -- the project's own
    # LTHING_Hash.SHAKE512 is the canonical hash for content/seal hashing;
    # this step only sizes the CA keystream, it is not the seal's hash).
    salt = hashlib.shake_256(raw).digest(salt_len)

    epoch_bytes = epoch_ms.to_bytes(8, "big")
    keystream = hashlib.shake_256(raw).digest(len(epoch_bytes))
    masked = bytes(a ^ b for a, b in zip(epoch_bytes, keystream))

    return {
        "epoch_ms": epoch_ms,
        "salt_hex": salt.hex(),
        "date_epoch_masked_hex": masked.hex(),
        "derivation_descriptor": {
            "algorithm_version": "rule30-epoch-v1",
            "rule30_round_count": ROUND_COUNT,
            "cell_width": CELL_WIDTH,
            "byte_extraction_rule": "center-64-cells-per-round-MSB-first, "
                                     "SHAKE-256-condensed to requested length",
        },
    }


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: rule30_salt.py <epoch_ms>", file=sys.stderr)
        sys.exit(1)
    result = derive(int(sys.argv[1]))
    for k, v in result.items():
        if k == "derivation_descriptor":
            continue
        print(f"{k}={v}")
    for k, v in result["derivation_descriptor"].items():
        print(f"descriptor.{k}={v}")
