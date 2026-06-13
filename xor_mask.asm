; ==============================================================================
; xor_mask.asm — Constant-Time XOR Operations
; ==============================================================================
; LTHING Cryptographic Primitive (x86-64 Assembly / NASM)
; Constant-time XOR for epoch masking and keystream operations.
; Resistant to timing side-channels.
;
; License: GPL-3.0-or-later (copyleft)
; Author: Anja Evermoor, Claude Sonnet 4.5
; Specification: LTHING v1.0 (Proof of Spacetime)
; ==============================================================================

BITS 64
DEFAULT REL

section .note.GNU-stack noalloc noexec nowrite progbits

section .text
global xor_u64_constant_time
global xor_buffer_constant_time
global mask_epoch_with_keystream
global unmask_epoch_from_keystream
global compare_constant_time

; ==============================================================================
; xor_u64_constant_time — XOR two 64-bit values (constant time)
; ==============================================================================
; C signature:
;   uint64_t xor_u64_constant_time(uint64_t a, uint64_t b);
;
; Arguments:
;   rdi = a (uint64_t)
;   rsi = b (uint64_t)
;
; Returns:
;   rax = a ^ b
;
; Timing: Constant (single instruction)
; ==============================================================================
xor_u64_constant_time:
    mov rax, rdi
    xor rax, rsi
    ret

; ==============================================================================
; xor_buffer_constant_time — XOR two byte buffers (constant time)
; ==============================================================================
; C signature:
;   void xor_buffer_constant_time(uint8_t *dest, const uint8_t *src,
;                                  uint32_t len);
;
; Arguments:
;   rdi = dest buffer (uint8_t *) — modified in-place
;   rsi = src buffer (const uint8_t *)
;   rdx = len (uint32_t) — number of bytes to XOR
;
; Returns: void
; Modifies: dest buffer = dest ^ src
;
; Timing: Constant per byte (no data-dependent branches)
; ==============================================================================
xor_buffer_constant_time:
    push rbp
    mov rbp, rsp
    push rbx

    xor rcx, rcx          ; offset = 0

.loop:
    cmp ecx, edx
    jge .done

    ; dest[i] ^= src[i]
    movzx eax, byte [rdi + rcx]
    movzx ebx, byte [rsi + rcx]
    xor eax, ebx
    mov byte [rdi + rcx], al

    inc ecx
    jmp .loop

.done:
    pop rbx
    pop rbp
    ret

; ==============================================================================
; mask_epoch_with_keystream — Mask 64-bit epoch with Rule30 keystream
; ==============================================================================
; C signature:
;   uint64_t mask_epoch_with_keystream(uint64_t epoch_ms,
;                                       const uint8_t *keystream);
;
; Arguments:
;   rdi = epoch_ms (uint64_t) — Unix epoch in milliseconds
;   rsi = keystream (const uint8_t *) — 8-byte mask from Rule30
;
; Returns:
;   rax = epoch_masked (uint64_t)
;
; Implementation:
;   epoch_bytes = struct.pack(">Q", epoch_ms)  # Big-endian
;   mask = keystream[0:8]
;   epoch_masked = struct.unpack(">Q", epoch_bytes ^ mask)
;
; Timing: Constant (no data-dependent branches)
; ==============================================================================
mask_epoch_with_keystream:
    push rbp
    mov rbp, rsp
    push rbx

    ; Convert epoch_ms to big-endian bytes
    mov rax, rdi
    bswap rax             ; Convert to big-endian

    ; XOR with keystream (8 bytes)
    mov rbx, qword [rsi]
    bswap rbx             ; keystream also in big-endian
    xor rax, rbx

    ; Convert result back to native endian
    bswap rax

    pop rbx
    pop rbp
    ret

; ==============================================================================
; unmask_epoch_from_keystream — Reverse epoch masking (verify operation)
; ==============================================================================
; C signature:
;   uint64_t unmask_epoch_from_keystream(uint64_t epoch_masked,
;                                         const uint8_t *keystream);
;
; Arguments:
;   rdi = epoch_masked (uint64_t)
;   rsi = keystream (const uint8_t *) — 8-byte mask
;
; Returns:
;   rax = epoch_ms (uint64_t) — original epoch
;
; Implementation: Identical to masking (XOR is self-inverse)
; ==============================================================================
unmask_epoch_from_keystream:
    ; XOR is its own inverse: (a ^ b) ^ b = a
    jmp mask_epoch_with_keystream

; ==============================================================================
; compare_constant_time — Constant-time buffer comparison
; ==============================================================================
; C signature:
;   int compare_constant_time(const uint8_t *a, const uint8_t *b,
;                              uint32_t len);
;
; Arguments:
;   rdi = buffer a (const uint8_t *)
;   rsi = buffer b (const uint8_t *)
;   rdx = len (uint32_t)
;
; Returns:
;   rax = 0 if equal, 1 if different
;
; Timing: Constant (no early exit on mismatch)
; ==============================================================================
compare_constant_time:
    push rbp
    mov rbp, rsp

    xor rax, rax          ; result = 0 (assume equal)
    xor rcx, rcx          ; offset = 0

.loop:
    cmp ecx, edx
    jge .done

    ; accumulate differences: result |= (a[i] ^ b[i])
    movzx r8d, byte [rdi + rcx]
    movzx r9d, byte [rsi + rcx]
    xor r8d, r9d
    or rax, r8

    inc ecx
    jmp .loop

.done:
    ; Convert non-zero accumulator to 1, keep zero as 0
    test rax, rax
    setnz al
    movzx rax, al

    pop rbp
    ret

; ==============================================================================
; End of xor_mask.asm
; ==============================================================================
