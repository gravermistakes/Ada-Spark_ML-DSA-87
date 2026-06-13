/**
 * lthing_crypto_asm.h — C FFI Header for LTHING Assembly Primitives
 * 
 * Provides C-compatible interface to x86-64 assembly implementations of:
 *   - Rule 30 cellular automaton keystream generation
 *   - Keccak-f[1600] permutation (SHAKE-256/512)
 *   - Constant-time XOR operations
 * 
 * License: GPL-3.0-or-later (copyleft)
 * Author: Anja Evermoor, Claude Sonnet 4.5
 * Specification: LTHING v1.0 (Proof of Spacetime)
 */

#ifndef LTHING_CRYPTO_ASM_H
#define LTHING_CRYPTO_ASM_H

#include <stdint.h>
#include <stddef.h>

#ifdef __cplusplus
extern "C" {
#endif

/* ========================================================================== */
/* Rule 30 Cellular Automaton                                                */
/* ========================================================================== */

/**
 * Initialize Rule 30 cellular automaton state from seed.
 * 
 * @param state     Output state buffer (width bytes, must be zero-initialized)
 * @param width     Width of cellular automaton (minimum 256, divisible by 8)
 * @param seed      Seed bytes for initialization
 * @param seed_len  Length of seed buffer
 * 
 * Preconditions:
 *   - state != NULL and points to allocated buffer of width bytes
 *   - width >= 256 && (width % 8 == 0)
 *   - seed != NULL
 *   - seed_len > 0
 */
void rule30_init(uint8_t *state, uint32_t width,
                 const uint8_t *seed, uint32_t seed_len);

/**
 * Evolve Rule 30 cellular automaton for N rounds.
 * 
 * @param state   State buffer (modified in-place)
 * @param width   Width of cellular automaton
 * @param rounds  Number of evolution steps (minimum 1000 for security)
 * 
 * Preconditions:
 *   - state != NULL
 *   - rounds >= 1000 (RULE30_MIN_ROUNDS)
 */
void rule30_evolve(uint8_t *state, uint32_t width, uint32_t rounds);

/**
 * Extract keystream bytes from evolved Rule 30 state.
 * Samples center cell via continued evolution.
 * 
 * @param state       Evolved state (const)
 * @param width       Width of cellular automaton
 * @param output      Output keystream buffer
 * @param output_len  Number of bytes to extract
 * 
 * Preconditions:
 *   - state != NULL
 *   - output != NULL and points to buffer of output_len bytes
 */
void rule30_extract_keystream(const uint8_t *state, uint32_t width,
                               uint8_t *output, uint32_t output_len);

/* ========================================================================== */
/* Keccak-f[1600] Permutation (SHAKE-256/512)                                */
/* ========================================================================== */

/**
 * Keccak-f[1600] permutation (24 rounds).
 * FIPS 202 compliant implementation.
 * 
 * @param state  Keccak state (25 x 64-bit lanes = 200 bytes, modified in-place)
 * 
 * Preconditions:
 *   - state != NULL and points to 200-byte aligned buffer
 */
void keccak_f1600(uint64_t state[25]);

/**
 * SHAKE-256 absorb phase: XOR data into sponge state.
 * 
 * @param state     Keccak state (25 x 64-bit lanes)
 * @param data      Input data buffer
 * @param data_len  Length of input data
 * @param rate      Sponge rate in bytes (SHAKE256: 136, SHAKE512: 72)
 * 
 * Preconditions:
 *   - state != NULL
 *   - data != NULL
 *   - rate > 0 && rate <= 200
 */
void shake256_absorb(uint64_t state[25], const uint8_t *data,
                     uint32_t data_len, uint32_t rate);

/**
 * SHAKE-256 squeeze phase: Extract output from sponge state.
 * 
 * @param state       Keccak state (25 x 64-bit lanes)
 * @param output      Output buffer
 * @param output_len  Number of bytes to squeeze
 * @param rate        Sponge rate in bytes (SHAKE256: 136, SHAKE512: 72)
 * 
 * Preconditions:
 *   - state != NULL
 *   - output != NULL and points to buffer of output_len bytes
 *   - rate > 0 && rate <= 200
 */
void shake256_squeeze(uint64_t state[25], uint8_t *output,
                      uint32_t output_len, uint32_t rate);

/* ========================================================================== */
/* Constant-Time XOR Operations                                              */
/* ========================================================================== */

/**
 * XOR two 64-bit values (constant time).
 * 
 * @param a  First operand
 * @param b  Second operand
 * @return   a ^ b
 * 
 * Timing: Constant (single instruction)
 */
uint64_t xor_u64_constant_time(uint64_t a, uint64_t b);

/**
 * XOR two byte buffers (constant time).
 * Modifies dest in-place: dest = dest ^ src
 * 
 * @param dest  Destination buffer (modified)
 * @param src   Source buffer (const)
 * @param len   Number of bytes to XOR
 * 
 * Preconditions:
 *   - dest != NULL and points to buffer of len bytes
 *   - src != NULL and points to buffer of len bytes
 * 
 * Timing: Constant per byte (no data-dependent branches)
 */
void xor_buffer_constant_time(uint8_t *dest, const uint8_t *src, uint32_t len);

/**
 * Mask 64-bit epoch with Rule30 keystream (Proof of Spacetime).
 * 
 * @param epoch_ms   Unix epoch in milliseconds (uint64_t)
 * @param keystream  8-byte mask from Rule30 engine
 * @return           Masked epoch value
 * 
 * Preconditions:
 *   - keystream != NULL and points to 8-byte buffer
 * 
 * Implementation:
 *   epoch_bytes = to_big_endian(epoch_ms)
 *   mask = keystream[0:8]
 *   return from_big_endian(epoch_bytes ^ mask)
 */
uint64_t mask_epoch_with_keystream(uint64_t epoch_ms, const uint8_t *keystream);

/**
 * Unmask epoch from keystream (verification operation).
 * Identical to masking (XOR is self-inverse).
 * 
 * @param epoch_masked  Masked epoch value
 * @param keystream     8-byte mask from Rule30 engine
 * @return              Original epoch_ms
 */
uint64_t unmask_epoch_from_keystream(uint64_t epoch_masked,
                                      const uint8_t *keystream);

/**
 * Constant-time buffer comparison.
 * 
 * @param a    First buffer
 * @param b    Second buffer
 * @param len  Number of bytes to compare
 * @return     0 if equal, 1 if different
 * 
 * Timing: Constant (no early exit on mismatch)
 */
int compare_constant_time(const uint8_t *a, const uint8_t *b, uint32_t len);

/* ========================================================================== */
/* Constants                                                                  */
/* ========================================================================== */

#define RULE30_MIN_ROUNDS  1000U
#define RULE30_MIN_WIDTH   256U
#define KECCAK_STATE_SIZE  200U   /* 25 x 64-bit lanes */
#define SHAKE256_RATE      136U   /* bytes */
#define SHAKE512_RATE      72U    /* bytes */

#ifdef __cplusplus
}
#endif

#endif /* LTHING_CRYPTO_ASM_H */
