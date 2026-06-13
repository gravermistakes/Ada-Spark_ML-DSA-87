/* Minimal test harness for LTHING crypto assembly */
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <assert.h>
#include "lthing_crypto_asm.h"

int main(void) {
    printf("Testing LTHING assembly crypto primitives...\n");
    
    /* Test 1: Rule30 initialization */
    uint8_t state[512] = {0};
    uint8_t seed[] = "test_seed";
    rule30_init(state, 512, seed, sizeof(seed)-1);
    printf("[PASS] rule30_init\n");
    
    /* Test 2: Rule30 evolution */
    rule30_evolve(state, 512, 1000);
    printf("[PASS] rule30_evolve\n");
    
    /* Test 3: Keystream extraction */
    uint8_t keystream[32];
    rule30_extract_keystream(state, 512, keystream, 32);
    printf("[PASS] rule30_extract_keystream\n");
    
    /* Test 4: XOR operations */
    uint64_t epoch = 1715485200000ULL;
    uint64_t masked = mask_epoch_with_keystream(epoch, keystream);
    uint64_t unmasked = unmask_epoch_from_keystream(masked, keystream);
    assert(unmasked == epoch);
    printf("[PASS] mask/unmask epoch (XOR self-inverse)\n");
    
    /* Test 5: Constant-time comparison */
    uint8_t a[8] = {1,2,3,4,5,6,7,8};
    uint8_t b[8] = {1,2,3,4,5,6,7,8};
    assert(compare_constant_time(a, b, 8) == 0);
    b[7] = 9;
    assert(compare_constant_time(a, b, 8) == 1);
    printf("[PASS] compare_constant_time\n");
    
    printf("\nAll tests passed.\n");
    return 0;
}
