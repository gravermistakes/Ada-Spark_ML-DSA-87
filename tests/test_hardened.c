/* Hardened regression harness — LTHING crypto asm.
 * Guards FINDING-004 (seed must affect keystream) and the extract-stub fix.
 * Build: gcc -O0 -g -I. -o build/test_hardened tests/test_hardened.c \
 *        -Llib -llthing_crypto_asm -Wl,-rpath=lib
 */
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <assert.h>
#include "lthing_crypto_asm.h"

static void run(const char* seed, uint8_t* ks, int kslen){
    uint8_t st[512]={0};
    rule30_init(st,512,(const uint8_t*)seed,strlen(seed));
    rule30_evolve(st,512,1000);
    rule30_extract_keystream(st,512,ks,kslen);
}
int main(void){
    uint8_t a[64],b[64],c[64];
    run("l'Evermoor",a,64);
    run("DIFFERENT_SEED_XYZ",b,64);
    run("l'Evermoor",c,64);

    assert(memcmp(a,b,64)!=0);      /* FINDING-004: seed must matter */
    int nz=0; for(int i=0;i<64;i++) if(a[i]) nz=1; assert(nz); /* not all-zero */
    assert(memcmp(a,c,64)==0);      /* deterministic / reconstructible */

    /* epoch mask round-trip with real keystream */
    uint64_t e=1715485200000ULL;
    uint64_t m=mask_epoch_with_keystream(e,a);
    assert(unmask_epoch_from_keystream(m,a)==e);
    assert(m!=e);                   /* masking actually changed the value */

    /* constant-time compare correctness */
    assert(compare_constant_time(a,c,64)==0);
    assert(compare_constant_time(a,b,64)==1);

    printf("All hardened regression tests passed (FINDING-004 guarded).\n");
    return 0;
}
