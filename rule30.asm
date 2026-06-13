; ==============================================================================
; rule30.asm — Rule 30 Cellular Automaton Keystream Generator
; ==============================================================================
; LTHING Cryptographic Primitive (x86-64 Assembly / NASM, System V AMD64 ABI)
; Zero external dependencies. Position-independent (DEFAULT REL).
; Callable from Ada/SPARK via C FFI.
;
; License: GPL-3.0-or-later (copyleft)
; Author: Anja Evermoor, Claude
; Specification: LTHING v1.0 (Proof of Spacetime / Rule30 Salt Stream)
;
; SECURITY HARDENING (2026-06-06, audit delta vs AVRS 2026-05-14):
;   FINDING-004 RESOLVED — rule30_init now actually stores the extracted seed
;     bit. The original computed the bit, then clobbered it with div results
;     before the store, so the seed had zero effect (proven by execution:
;     two different seeds produced identical, all-zero keystreams).
;   EXTRACT-STUB RESOLVED — rule30_extract_keystream now performs one full
;     Rule-30 evolution step between every sampled bit. The original re-read a
;     single static center cell 8x/byte with no evolution (all-0x00 output).
;   Variable-size stack temporaries are anchored to rbp and 16-byte aligned;
;     callee-saved registers restored via a canonical epilogue.
;   Control flow is independent of seed contents (no secret-dependent branch).
; ==============================================================================

BITS 64
DEFAULT REL

section .rodata
align 8
rule30_table:
    db 0, 1, 1, 1, 1, 0, 0, 0          ; Rule 30: index=(L<<2)|(C<<1)|R

section .note.GNU-stack noalloc noexec nowrite progbits   ; non-exec stack

section .text
global rule30_init
global rule30_evolve
global rule30_extract_keystream

; ------------------------------------------------------------------------------
; rule30_init(uint8_t *state, uint32_t width, const uint8_t *seed, uint32_t len)
;   rdi=state  rsi=width(>=256,%8==0)  rdx=seed  rcx=len
;   Writes one seed bit per spaced cell, XOR-accumulating on collision so
;   every seed bit influences the state. Invalid width => state left zeroed.
; ------------------------------------------------------------------------------
rule30_init:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    cmp esi, 256
    jb .ri_done
    test esi, 7
    jnz .ri_done

    mov r12, rdi                       ; state
    mov r13d, esi                      ; width
    mov r14, rdx                       ; seed ptr
    mov r15d, ecx                      ; seed_len
    test r15d, r15d
    jz .ri_done

    ; spacing = max(1, width / (seed_len*8))
    mov eax, r13d
    mov ecx, r15d
    shl ecx, 3
    xor edx, edx
    div ecx
    test eax, eax
    jnz .ri_have_spacing
    mov eax, 1
.ri_have_spacing:
    mov r11d, eax                      ; spacing

    xor rbx, rbx                       ; bit_index
    xor r8, r8                         ; seed_byte_idx
.ri_seed_loop:
    cmp r8d, r15d
    jge .ri_done
    movzx r9d, byte [r14 + r8]         ; seed byte
    mov r10d, 7                        ; bit position
.ri_bit_loop:
    mov ecx, r10d
    mov eax, r9d
    shr eax, cl
    and eax, 1
    mov edi, eax                       ; edi = extracted bit (survives div)

    mov eax, ebx
    imul eax, r11d
    xor edx, edx
    div r13d                           ; edx = (bit_index*spacing) % width

    mov al, byte [r12 + rdx]
    xor al, dil
    and al, 1
    mov byte [r12 + rdx], al

    inc ebx
    dec r10d
    jns .ri_bit_loop

    inc r8
    jmp .ri_seed_loop
.ri_done:
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; ------------------------------------------------------------------------------
; rule30_evolve(uint8_t *state, uint32_t width, uint32_t rounds)
;   rdi=state  rsi=width  rdx=rounds  ; wraparound boundaries
; ------------------------------------------------------------------------------
rule30_evolve:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13d, esi
    mov r14d, edx

    ; aligned temp buffer of width bytes, anchored to rbp
    mov eax, r13d
    add eax, 15
    and eax, -16
    sub rsp, rax
    and rsp, -16                       ; 16-byte align
    mov r15, rsp                       ; temp ptr

    mov rdi, r15
    mov ecx, r13d
    xor eax, eax
    rep stosb

.re_round:
    test r14d, r14d
    jz .re_done
    xor ebx, ebx
.re_cell:
    cmp ebx, r13d
    jge .re_step_done
    ; left
    mov eax, ebx
    test eax, eax
    jnz .re_nz
    mov eax, r13d
.re_nz:
    dec eax
    movzx r8d, byte [r12 + rax]
    ; center
    movzx r9d, byte [r12 + rbx]
    ; right
    mov eax, ebx
    inc eax
    xor edx, edx
    div r13d
    movzx r10d, byte [r12 + rdx]
    ; rule lookup
    shl r8d, 2
    shl r9d, 1
    or r8d, r9d
    or r8d, r10d
    and r8d, 7
    lea rax, [rel rule30_table]
    movzx eax, byte [rax + r8]
    mov byte [r15 + rbx], al
    inc ebx
    jmp .re_cell
.re_step_done:
    mov rdi, r12
    mov rsi, r15
    mov ecx, r13d
    rep movsb
    dec r14d
    jmp .re_round
.re_done:
    lea rsp, [rbp - 40]                ; discard temp, land on saved regs
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; ------------------------------------------------------------------------------
; rule30_extract_keystream(const uint8_t *state, uint32_t width,
;                          uint8_t *out, uint32_t out_len)
;   rdi=state  rsi=width  rdx=out  rcx=out_len
;   Copies state to a working buffer, then for each output bit: evolves the
;   working state one Rule-30 step and samples the center cell LSB. 8 bits ->
;   1 output byte, MSB-first. Genuine evolution (not a static re-read).
; ------------------------------------------------------------------------------
rule30_extract_keystream:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi                       ; state (input)
    mov r13d, esi                      ; width
    mov r14, rdx                       ; out
    mov rcx, rcx
    mov r9d, ecx                       ; out_len (save before clobber)

    ; two aligned buffers of width bytes: work (rbp-anchored) + scratch
    mov eax, r13d
    add eax, 15
    and eax, -16
    mov r11d, eax                      ; aligned width
    mov rax, r11
    add rax, r11                       ; 2 * aligned width
    sub rsp, rax
    and rsp, -16
    mov r15, rsp                       ; work buffer
    lea rbx, [rsp + r11]               ; scratch buffer (for evolve step)

    ; copy input state -> work
    mov rdi, r15
    mov rsi, r12
    mov ecx, r13d
    rep movsb

    ; center index = width/2
    mov r12d, r13d
    shr r12d, 1                        ; r12 = center_idx (reuse r12)

    ; out_len back into r10
    mov r10d, r9d                      ; remaining output bytes
    xor r8, r8                         ; byte_idx = 0

.ek_byte_loop:
    cmp r8d, r10d
    jge .ek_done
    xor r9, r9                         ; bit accumulator
    mov ecx, 8                         ; 8 bits per byte
.ek_bit_loop:
    ; --- one Rule-30 evolution step: work -> scratch ---
    push rcx                           ; preserve bit counter
    xor edi, edi                       ; i = 0
.ek_cell:
    cmp edi, r13d
    jge .ek_cell_done
    ; left
    mov eax, edi
    test eax, eax
    jnz .ek_nz
    mov eax, r13d
.ek_nz:
    dec eax
    movzx esi, byte [r15 + rax]        ; left
    ; center
    movzx r11d, byte [r15 + rdi]       ; center (r11 scratch; NOT rbp)
    ; right
    mov eax, edi
    inc eax
    xor edx, edx
    div r13d
    movzx ecx, byte [r15 + rdx]        ; right
    shl esi, 2
    shl r11d, 1
    or esi, r11d
    or esi, ecx
    and esi, 7
    lea rax, [rel rule30_table]
    movzx eax, byte [rax + rsi]
    mov byte [rbx + rdi], al           ; scratch[i]
    inc edi
    jmp .ek_cell
.ek_cell_done:
    ; copy scratch -> work
    mov rdi, r15
    mov rsi, rbx
    mov ecx, r13d
    rep movsb
    pop rcx                            ; restore bit counter

    ; sample center LSB, shift into accumulator (MSB-first)
    movzx eax, byte [r15 + r12]
    and eax, 1
    shl r9, 1
    or r9, rax

    dec ecx
    jnz .ek_bit_loop

    mov byte [r14 + r8], r9b
    inc r8
    jmp .ek_byte_loop
.ek_done:
    lea rsp, [rbp - 40]
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    pop rbp
    ret

; ==============================================================================
; End of rule30.asm
; ==============================================================================
