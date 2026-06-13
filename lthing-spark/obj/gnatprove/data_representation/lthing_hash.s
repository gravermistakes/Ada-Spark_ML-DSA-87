	.file	"lthing_hash.adb"
	.text
.Ltext0:
	.file 0 "/home/claude/lthing-spark/obj/gnatprove/data_representation" "/home/claude/lthing-spark/src/lthing_hash.adb"
	.section	.rodata
	.align 8
.LC2:
	.ascii	"failed precondition from lthing_hash.ads:24"
.LC3:
	.ascii	"lthing_hash.adb"
	.zero	1
	.align 8
.LC0:
	.long	1
	.long	43
	.align 8
.LC1:
	.long	0
	.long	63
	.text
	.align 2
	.globl	lthing_hash__shake512
	.type	lthing_hash__shake512, @function
lthing_hash__shake512:
.LFB2:
	.file 1 "/home/claude/lthing-spark/src/lthing_hash.adb"
	.loc 1 14 4
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$312, %rsp
	.cfi_offset 13, -24
	.cfi_offset 12, -32
	.cfi_offset 3, -40
	movq	%rdi, %rax
	movq	%rax, %rcx
	movl	$0, %ebx
	movq	%rsi, %rbx
	movq	%rcx, -320(%rbp)
	movq	%rbx, -312(%rbp)
	movq	%rdx, -328(%rbp)
	.loc 1 14 4
	movq	-312(%rbp), %rax
	movl	(%rax), %eax
	movq	-312(%rbp), %rdx
	movl	4(%rdx), %edx
	cmpl	%eax, %edx
	jl	.L2
	.loc 1 14 4 is_stmt 0 discriminator 1
	movslq	%edx, %rcx
	movq	%rcx, %rbx
	sarq	$63, %rbx
	movslq	%eax, %rsi
	movq	%rsi, %rdi
	sarq	$63, %rdi
	subq	%rsi, %rcx
	sbbq	%rdi, %rbx
	addq	$1, %rcx
	adcq	$0, %rbx
	movq	%rcx, %r8
	movq	%rbx, %r9
	jmp	.L3
.L2:
	.loc 1 14 4 discriminator 2
	movl	$0, %r8d
	movl	$0, %r9d
.L3:
.LBB2:
	.loc 1 14 4 discriminator 4
	cmpl	%eax, %edx
	.loc 1 14 4 discriminator 8
	cmpl	%eax, %edx
	.loc 1 14 4 discriminator 12
	cmpl	%eax, %edx
	.file 2 "/home/claude/lthing-spark/src/lthing_hash.ads"
	.loc 2 24 21 is_stmt 1
	cmpl	%edx, %eax
	jle	.L10
.LBB3:
	.loc 2 24 21 is_stmt 0 discriminator 1
	movl	$.LC2, %r10d
	movl	$.LC0, %r11d
	movq	%r10, %rdx
	movq	%r11, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L10:
.LBE3:
	.loc 1 18 7 is_stmt 1
	leaq	-240(%rbp), %rdx
	movl	$0, %eax
	movl	$25, %ecx
	movq	%rdx, %rdi
	rep stosq
	.loc 1 19 7
	pxor	%xmm0, %xmm0
	movaps	%xmm0, -304(%rbp)
	movaps	%xmm0, -288(%rbp)
	movaps	%xmm0, -272(%rbp)
	movaps	%xmm0, -256(%rbp)
	.loc 1 21 7
	movl	%r8d, %eax
	testl	%eax, %eax
	jns	.L11
	.loc 1 21 7 is_stmt 0 discriminator 1
	movl	$24, %esi
	movl	$.LC3, %edi
	call	__gnat_rcheck_CE_Overflow_Check
.L11:
	.loc 1 21 7 discriminator 2
	movl	%r8d, %ecx
	.loc 1 21 7 discriminator 4
	movq	-320(%rbp), %rsi
	movq	-312(%rbp), %rdx
	leaq	-240(%rbp), %rax
	movl	$72, %r8d
	movq	%rax, %rdi
	call	lthing_crypto_ffi__shake_absorb
	.loc 1 27 7 is_stmt 1
	leaq	-304(%rbp), %rax
	movq	%rax, %r12
	movl	$.LC1, %r13d
	movq	%r12, %rsi
	movq	%r13, %rdx
	leaq	-240(%rbp), %rax
	movl	$72, %r8d
	movl	$64, %ecx
	movq	%rax, %rdi
	call	lthing_crypto_ffi__shake_squeeze
.LBB4:
	.loc 1 33 11
	movl	$0, -36(%rbp)
.L13:
	.loc 1 33 11 is_stmt 0 discriminator 1
	cmpl	$63, -36(%rbp)
	jg	.L15
	.loc 1 34 21 is_stmt 1
	movl	-36(%rbp), %eax
	movslq	%eax, %rdx
	movl	-36(%rbp), %eax
	cltq
	movzbl	-304(%rbp,%rdx), %ecx
	.loc 1 34 21 is_stmt 0 discriminator 1
	movq	-328(%rbp), %rdx
	movb	%cl, (%rdx,%rax)
	.loc 1 33 11 is_stmt 1 discriminator 2
	addl	$1, -36(%rbp)
	.loc 1 35 15
	jmp	.L13
.L15:
.LBE4:
	.loc 1 36 8
	nop
.LBE2:
	addq	$312, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	lthing_hash__shake512, .-lthing_hash__shake512
	.section	.rodata
	.align 8
.LC4:
	.ascii	"failed precondition from lthing_hash.ads:35"
	.align 8
.LC5:
	.ascii	"failed precondition from lthing_hash.ads:36"
	.align 8
.LC6:
	.ascii	"LOOP_INVARIANT failed at lthing_hash.adb:54"
	.text
	.align 2
	.globl	lthing_hash__chain_hash
	.type	lthing_hash__chain_hash, @function
lthing_hash__chain_hash:
.LFB3:
	.loc 1 38 4
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r15
	pushq	%r14
	pushq	%r13
	pushq	%r12
	pushq	%rbx
	subq	$136, %rsp
	.cfi_offset 15, -24
	.cfi_offset 14, -32
	.cfi_offset 13, -40
	.cfi_offset 12, -48
	.cfi_offset 3, -56
	movq	%rdi, -120(%rbp)
	movq	%rsi, %rax
	movq	%rdx, %rsi
	movq	%rax, %rax
	movl	$0, %edx
	movq	%rsi, %rdx
	movq	%rax, -144(%rbp)
	movq	%rdx, -136(%rbp)
	movq	%rcx, -128(%rbp)
	.loc 1 38 4
	movq	-136(%rbp), %rax
	movl	(%rax), %ebx
	movq	-136(%rbp), %rax
	movl	4(%rax), %r12d
	cmpl	%ebx, %r12d
	jl	.L17
	.loc 1 38 4 is_stmt 0 discriminator 1
	movslq	%r12d, %rax
	cqto
	movslq	%ebx, %rcx
	movq	%rcx, %rsi
	movq	%rcx, %rdi
	sarq	$63, %rdi
	subq	%rsi, %rax
	sbbq	%rdi, %rdx
	addq	$1, %rax
	adcq	$0, %rdx
	jmp	.L18
.L17:
	.loc 1 38 4 discriminator 2
	movl	$0, %eax
	movl	$0, %edx
.L18:
.LBB5:
	movq	%rsp, %rcx
	movq	%rcx, -168(%rbp)
	.loc 1 38 4 discriminator 4
	movslq	%ebx, %r13
	cmpl	%ebx, %r12d
	.loc 1 38 4 discriminator 8
	cmpl	%ebx, %r12d
	.loc 1 38 4 discriminator 12
	cmpl	%ebx, %r12d
	.loc 2 35 21 is_stmt 1
	cmpl	%r12d, %ebx
	jle	.L25
.LBB6:
	.loc 2 35 21 is_stmt 0 discriminator 1
	movl	$.LC4, %r10d
	movl	$.LC0, %r11d
	movq	%r10, %rdx
	movq	%r11, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L25:
.LBE6:
	.loc 2 36 46 is_stmt 1
	movslq	%ebx, %rcx
	leaq	1048511(%rcx), %rsi
	movslq	%r12d, %rcx
	.loc 2 36 30
	cmpq	%rcx, %rsi
	jge	.L26
.LBB7:
	.loc 2 36 30 is_stmt 0 discriminator 1
	movl	$.LC5, %r8d
	movl	$.LC0, %r9d
	movq	%r8, %rdx
	movq	%r9, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L26:
.LBE7:
	.loc 1 44 7 is_stmt 1
	addl	$64, %eax
	movl	%eax, -64(%rbp)
	.loc 1 45 7
	cmpl	$0, -64(%rbp)
	.loc 1 45 7 is_stmt 0 discriminator 4
	cmpl	$0, -64(%rbp)
	.loc 1 45 7 discriminator 8
	cmpl	$0, -64(%rbp)
	.loc 1 45 34 is_stmt 1 discriminator 12
	cmpl	$0, -64(%rbp)
	jle	.L33
	.loc 1 45 34 is_stmt 0 discriminator 13
	cmpl	$1048577, -64(%rbp)
	jle	.L33
	.loc 1 45 34 discriminator 15
	movl	$45, %esi
	movl	$.LC3, %edi
	call	__gnat_rcheck_CE_Range_Check
.L33:
	.loc 1 45 56 is_stmt 1 discriminator 16
	movl	-64(%rbp), %eax
	subl	$1, %eax
	movl	%eax, -68(%rbp)
	cmpl	$0, -68(%rbp)
	js	.L34
	.loc 1 45 56 is_stmt 0 discriminator 17
	movl	-68(%rbp), %eax
	cltq
	movq	%rax, -80(%rbp)
	jmp	.L35
.L34:
	.loc 1 45 56 discriminator 18
	movq	$-1, -80(%rbp)
.L35:
	.loc 1 45 56 discriminator 20
	cmpl	$0, -68(%rbp)
	.loc 1 45 56 discriminator 24
	cmpl	$0, -68(%rbp)
	.loc 1 45 7 is_stmt 1 discriminator 28
	cmpl	$0, -68(%rbp)
	.loc 1 45 7 is_stmt 0 discriminator 32
	cmpl	$0, -68(%rbp)
	js	.L42
	.loc 1 45 7 discriminator 33
	movl	-68(%rbp), %eax
	cltq
	addq	$1, %rax
	jmp	.L43
.L42:
	.loc 1 45 7 discriminator 34
	movl	$0, %eax
.L43:
	.loc 1 45 7 discriminator 36
	movl	$16, %edx
	subq	$1, %rdx
	addq	%rdx, %rax
	movl	$16, %edi
	movl	$0, %edx
	divq	%rdi
	imulq	$16, %rax, %rax
	subq	%rax, %rsp
	movq	%rsp, %rax
	movq	%rax, -88(%rbp)
	.loc 1 45 56 is_stmt 1 discriminator 1
	cmpl	$0, -68(%rbp)
	js	.L44
	.loc 1 45 56 is_stmt 0 discriminator 37
	movl	-68(%rbp), %eax
	cltq
	addq	$1, %rax
	jmp	.L45
.L44:
	.loc 1 45 56 discriminator 38
	movl	$0, %eax
.L45:
	.loc 1 45 56 discriminator 40
	movq	-88(%rbp), %rdx
	movq	%rdx, %rcx
	movq	%rax, %rdx
	movl	$0, %esi
	movq	%rcx, %rdi
	call	memset
	.loc 1 46 7 is_stmt 1
	movl	$0, -52(%rbp)
.LBB8:
	.loc 1 48 11
	movl	$0, -56(%rbp)
.L48:
	.loc 1 48 11 is_stmt 0 discriminator 1
	cmpl	$63, -56(%rbp)
	jg	.L46
	.loc 1 49 10 is_stmt 1
	movl	-56(%rbp), %eax
	cmpl	-68(%rbp), %eax
	jle	.L47
	.loc 1 49 10 is_stmt 0 discriminator 1
	movl	$49, %esi
	movl	$.LC3, %edi
	call	__gnat_rcheck_CE_Index_Check
.L47:
	.loc 1 49 21 is_stmt 1 discriminator 2
	movl	-56(%rbp), %eax
	movslq	%eax, %rdx
	movl	-56(%rbp), %eax
	cltq
	movq	-120(%rbp), %rcx
	movzbl	(%rcx,%rdx), %ecx
	.loc 1 49 21 is_stmt 0 discriminator 3
	movq	-88(%rbp), %rdx
	movb	%cl, (%rdx,%rax)
	.loc 1 48 11 is_stmt 1 discriminator 2
	addl	$1, -56(%rbp)
	.loc 1 50 15
	jmp	.L48
.L46:
.LBE8:
	.loc 1 51 9
	movl	$64, -52(%rbp)
	.loc 1 52 11
	movl	%ebx, -92(%rbp)
	movl	%r12d, -96(%rbp)
	movl	-92(%rbp), %eax
	cmpl	-96(%rbp), %eax
	jg	.L49
.LBB9:
	.loc 1 52 11 is_stmt 0 discriminator 1
	movl	-92(%rbp), %eax
	movl	%eax, -60(%rbp)
.L60:
.LBB10:
	.loc 1 54 25 is_stmt 1
	movl	$0, %edx
	movl	-60(%rbp), %eax
	subl	%ebx, %eax
	jno	.L50
	movl	$1, %edx
.L50:
	movl	%eax, %ecx
	.loc 1 54 25 is_stmt 0 discriminator 1
	movl	%edx, %eax
	testl	%eax, %eax
	je	.L52
	movl	$54, %esi
	movl	$.LC3, %edi
	call	__gnat_rcheck_CE_Overflow_Check
.L52:
	.loc 1 54 25 discriminator 2
	movl	%ecx, %eax
	.loc 1 54 20 is_stmt 1 discriminator 4
	cmpl	$2147483583, %eax
	jle	.L53
	.loc 1 54 20 is_stmt 0 discriminator 5
	movl	$54, %esi
	movl	$.LC3, %edi
	call	__gnat_rcheck_CE_Overflow_Check
.L53:
	.loc 1 54 20 discriminator 6
	addl	$64, %eax
	.loc 1 54 13 is_stmt 1 discriminator 8
	cmpl	-52(%rbp), %eax
	jne	.L54
	.loc 1 55 13
	movl	-52(%rbp), %eax
	cmpl	-64(%rbp), %eax
	jl	.L55
.L54:
.LBB11:
	.loc 1 54 13 discriminator 9
	movq	$.LC6, -160(%rbp)
	movq	$.LC0, -152(%rbp)
	movq	-160(%rbp), %rbx
	movq	-152(%rbp), %rsi
	movq	%rbx, %rdx
	movq	%rsi, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L55:
.LBE11:
	.loc 1 56 10
	cmpl	$0, -52(%rbp)
	js	.L56
	.loc 1 56 10 is_stmt 0 discriminator 2
	movl	-52(%rbp), %eax
	cmpl	-68(%rbp), %eax
	jle	.L57
.L56:
	.loc 1 56 10 discriminator 3
	movl	$56, %esi
	movl	$.LC3, %edi
	call	__gnat_rcheck_CE_Index_Check
.L57:
	.loc 1 56 18 is_stmt 1 discriminator 4
	movl	-52(%rbp), %eax
	testl	%eax, %eax
	jns	.L58
	.loc 1 56 18 is_stmt 0 discriminator 5
	movl	$56, %esi
	movl	$.LC3, %edi
	call	__gnat_rcheck_CE_Invalid_Data
.L58:
	.loc 1 56 21 is_stmt 1 discriminator 6
	movq	-144(%rbp), %rdx
	movl	-60(%rbp), %ecx
	movslq	%ecx, %rcx
	cltq
	subq	%r13, %rcx
	movzbl	(%rdx,%rcx), %ecx
	.loc 1 56 21 is_stmt 0 discriminator 7
	movq	-88(%rbp), %rdx
	movb	%cl, (%rdx,%rax)
	.loc 1 57 17 is_stmt 1
	cmpl	$2147483647, -52(%rbp)
	jne	.L59
	.loc 1 57 17 is_stmt 0 discriminator 1
	movl	$57, %esi
	movl	$.LC3, %edi
	call	__gnat_rcheck_CE_Overflow_Check
.L59:
	.loc 1 57 17 discriminator 2
	movl	-52(%rbp), %eax
	addl	$1, %eax
	.loc 1 57 12 is_stmt 1 discriminator 4
	movl	%eax, -52(%rbp)
.LBE10:
	.loc 1 52 11
	movl	-60(%rbp), %eax
	cmpl	-96(%rbp), %eax
	je	.L49
	.loc 1 52 11 is_stmt 0 discriminator 2
	addl	$1, -60(%rbp)
	.loc 1 58 15 is_stmt 1
	jmp	.L60
.L49:
.LBE9:
	.loc 1 60 7
	movq	-88(%rbp), %r14
	movl	$0, -104(%rbp)
	movl	-68(%rbp), %eax
	movl	%eax, -100(%rbp)
	leaq	-104(%rbp), %rax
	movq	%rax, %r15
	movq	-128(%rbp), %rax
	movq	%r14, %rsi
	movq	%r15, %rcx
	movq	%rax, %rdx
	movq	%rsi, %rdi
	movq	%rcx, %rsi
	call	lthing_hash__shake512
	.loc 1 61 8
	movq	-168(%rbp), %rsp
.LBE5:
	leaq	-40(%rbp), %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	lthing_hash__chain_hash, .-lthing_hash__chain_hash
	.globl	lthing_hash_E
	.data
	.align 2
	.type	lthing_hash_E, @object
	.size	lthing_hash_E, 2
lthing_hash_E:
	.zero	2
	.text
.Letext0:
	.file 3 "/tmp/gnatprove_14.1.1_f6ca6f8c/libexec/spark/lib/gcc/x86_64-pc-linux-gnu/14.1.0/adainclude/interfac.ads"
	.file 4 "/home/claude/lthing-spark/src/lthing_types.ads"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0x2b6
	.value	0x5
	.byte	0x1
	.byte	0x8
	.long	.Ldebug_abbrev0
	.uleb128 0xe
	.long	.LASF25
	.byte	0xd
	.long	.LASF0
	.long	.LASF1
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.long	.Ldebug_line0
	.uleb128 0x4
	.byte	0x1
	.byte	0x7
	.long	.LASF4
	.uleb128 0xf
	.byte	0
	.byte	0xff
	.long	.LASF26
	.long	0x2e
	.uleb128 0x9
	.long	.LASF6
	.byte	0x10
	.byte	0x1c
	.byte	0x9
	.long	0x68
	.uleb128 0xa
	.long	.LASF2
	.byte	0x46
	.long	0x57
	.byte	0
	.uleb128 0xb
	.long	0x72
	.uleb128 0xa
	.long	.LASF3
	.byte	0x46
	.long	0xcb
	.byte	0x8
	.byte	0
	.uleb128 0xc
	.long	0x40
	.uleb128 0xc
	.long	0x40
	.uleb128 0x1
	.long	.LASF8
	.long	0x35
	.long	0x95
	.uleb128 0x10
	.long	0x95
	.uleb128 0x6
	.byte	0x97
	.byte	0x23
	.uleb128 0x8
	.byte	0x6
	.byte	0x94
	.byte	0x4
	.uleb128 0x8
	.byte	0x97
	.byte	0x23
	.uleb128 0x8
	.byte	0x6
	.byte	0x23
	.uleb128 0x4
	.byte	0x94
	.byte	0x4
	.byte	0
	.uleb128 0x4
	.byte	0x4
	.byte	0x5
	.long	.LASF5
	.uleb128 0x9
	.long	.LASF7
	.byte	0x8
	.byte	0x1a
	.byte	0x2e
	.long	0xcb
	.uleb128 0xd
	.string	"LB0"
	.long	0xb2
	.byte	0
	.uleb128 0x11
	.sleb128 0
	.sleb128 1048576
	.long	.LASF27
	.long	0x95
	.uleb128 0xd
	.string	"UB0"
	.long	0xb2
	.byte	0x4
	.byte	0
	.uleb128 0xb
	.long	0x9c
	.uleb128 0x1
	.long	.LASF9
	.long	0x35
	.long	0xe4
	.uleb128 0x6
	.long	0x95
	.sleb128 63
	.byte	0
	.uleb128 0x4
	.byte	0x8
	.byte	0x7
	.long	.LASF10
	.uleb128 0x1
	.long	.LASF11
	.long	0xe4
	.long	0xff
	.uleb128 0x6
	.long	0x95
	.sleb128 24
	.byte	0
	.uleb128 0x4
	.byte	0x4
	.byte	0x7
	.long	.LASF12
	.uleb128 0x12
	.long	.LASF28
	.byte	0x1
	.byte	0x26
	.byte	0x4
	.quad	.LFB3
	.quad	.LFE3-.LFB3
	.uleb128 0x1
	.byte	0x9c
	.long	0x21b
	.uleb128 0x2
	.long	.LASF13
	.byte	0x1f
	.long	0x21b
	.uleb128 0x3
	.byte	0x91
	.sleb128 -136
	.uleb128 0x2
	.long	.LASF14
	.byte	0x20
	.long	0x6d
	.uleb128 0x3
	.byte	0x91
	.sleb128 -160
	.uleb128 0x2
	.long	.LASF15
	.byte	0x21
	.long	0x21b
	.uleb128 0x3
	.byte	0x91
	.sleb128 -144
	.uleb128 0x5
	.quad	.LBB5
	.quad	.LBE5-.LBB5
	.uleb128 0x7
	.long	.LASF17
	.byte	0x2c
	.long	0x16d
	.uleb128 0x3
	.byte	0x91
	.sleb128 -80
	.uleb128 0x13
	.sleb128 0
	.sleb128 2147483647
	.long	.LASF29
	.long	0x95
	.uleb128 0x8
	.long	.LASF19
	.long	0x95
	.uleb128 0x3
	.byte	0x91
	.sleb128 -84
	.uleb128 0x1
	.long	.LASF16
	.long	0x35
	.long	0x1a1
	.uleb128 0x14
	.long	0x95
	.sleb128 0
	.long	0x17c
	.byte	0
	.uleb128 0x7
	.long	.LASF18
	.byte	0x2d
	.long	0x189
	.uleb128 0x4
	.byte	0x91
	.sleb128 -104
	.byte	0x6
	.uleb128 0x3
	.string	"j"
	.byte	0x2e
	.byte	0x7
	.long	0x16d
	.uleb128 0x3
	.byte	0x91
	.sleb128 -68
	.uleb128 0x8
	.long	.LASF20
	.long	0x95
	.uleb128 0x3
	.byte	0x91
	.sleb128 -108
	.uleb128 0x8
	.long	.LASF21
	.long	0x95
	.uleb128 0x3
	.byte	0x91
	.sleb128 -112
	.uleb128 0x15
	.quad	.LBB8
	.quad	.LBE8-.LBB8
	.long	0x1fa
	.uleb128 0x3
	.string	"i"
	.byte	0x30
	.byte	0xb
	.long	0x95
	.uleb128 0x3
	.byte	0x91
	.sleb128 -72
	.byte	0
	.uleb128 0x5
	.quad	.LBB9
	.quad	.LBE9-.LBB9
	.uleb128 0x3
	.string	"i"
	.byte	0x34
	.byte	0xb
	.long	0x95
	.uleb128 0x3
	.byte	0x91
	.sleb128 -76
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x16
	.byte	0x8
	.long	0xd0
	.uleb128 0x17
	.long	.LASF30
	.byte	0x1
	.byte	0xe
	.byte	0x4
	.quad	.LFB2
	.quad	.LFE2-.LFB2
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x2
	.long	.LASF22
	.byte	0x15
	.long	0x68
	.uleb128 0x3
	.byte	0x91
	.sleb128 -336
	.uleb128 0x2
	.long	.LASF15
	.byte	0x16
	.long	0x21b
	.uleb128 0x3
	.byte	0x91
	.sleb128 -344
	.uleb128 0x5
	.quad	.LBB2
	.quad	.LBE2-.LBB2
	.uleb128 0x7
	.long	.LASF23
	.byte	0x12
	.long	0xeb
	.uleb128 0x3
	.byte	0x91
	.sleb128 -256
	.uleb128 0x1
	.long	.LASF24
	.long	0x35
	.long	0x28a
	.uleb128 0x6
	.long	0x95
	.sleb128 63
	.byte	0
	.uleb128 0x3
	.string	"buf"
	.byte	0x13
	.byte	0x7
	.long	0x276
	.uleb128 0x3
	.byte	0x91
	.sleb128 -320
	.uleb128 0x5
	.quad	.LBB4
	.quad	.LBE4-.LBB4
	.uleb128 0x3
	.string	"i"
	.byte	0x21
	.byte	0xb
	.long	0x95
	.uleb128 0x2
	.byte	0x91
	.sleb128 -52
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x2
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0x21
	.sleb128 2
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0x21
	.sleb128 7
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x3
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0x21
	.sleb128 1
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x4
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.byte	0
	.byte	0
	.uleb128 0x5
	.uleb128 0xb
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.byte	0
	.byte	0
	.uleb128 0x6
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x22
	.uleb128 0x21
	.sleb128 0
	.uleb128 0x2f
	.uleb128 0xd
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0x21
	.sleb128 1
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0x21
	.sleb128 7
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x8
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x34
	.uleb128 0x19
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x9
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0x21
	.sleb128 4
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x34
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xa
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0x21
	.sleb128 3
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0x21
	.sleb128 29
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xb
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0x21
	.sleb128 8
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xc
	.uleb128 0x26
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x34
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0xd
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0x21
	.sleb128 4
	.uleb128 0x3b
	.uleb128 0x21
	.sleb128 28
	.uleb128 0x39
	.uleb128 0x21
	.sleb128 9
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xe
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x1f
	.uleb128 0x1b
	.uleb128 0x1f
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x10
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0xf
	.uleb128 0x21
	.byte	0
	.uleb128 0x22
	.uleb128 0xb
	.uleb128 0x2f
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x10
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x22
	.uleb128 0x18
	.uleb128 0x2f
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x11
	.uleb128 0x21
	.byte	0
	.uleb128 0x22
	.uleb128 0xd
	.uleb128 0x2f
	.uleb128 0xd
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x12
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x7c
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x13
	.uleb128 0x21
	.byte	0
	.uleb128 0x22
	.uleb128 0xd
	.uleb128 0x2f
	.uleb128 0xd
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x34
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x14
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x22
	.uleb128 0xd
	.uleb128 0x2f
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x15
	.uleb128 0xb
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x16
	.uleb128 0x10
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x17
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x7c
	.uleb128 0x19
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_aranges,"",@progbits
	.long	0x2c
	.value	0x2
	.long	.Ldebug_info0
	.byte	0x8
	.byte	0
	.value	0
	.value	0
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.quad	0
	.quad	0
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
.LASF4:
	.string	"interfaces__unsigned_8"
.LASF3:
	.string	"P_BOUNDS"
.LASF19:
	.string	"lthing_hash__chain_hash__T20b___U"
.LASF27:
	.string	"lthing_types__index_range"
.LASF10:
	.string	"interfaces__unsigned_64"
.LASF18:
	.string	"concat"
.LASF29:
	.string	"natural"
.LASF25:
	.string	"GNU Ada 14.1.0 -O0 -gnatA -g -gnatwa -gnata -gnatR2js -gnatws -gnatec=/tmp/GPR.2766/GNAT-TEMP-000003.TMP -gnatem=/tmp/GPR.2766/GNAT-TEMP-000004.TMP -mtune=generic -march=x86-64"
.LASF22:
	.string	"input"
.LASF13:
	.string	"previous_seal"
.LASF12:
	.string	"interfaces__c__unsigned"
.LASF17:
	.string	"concat_len"
.LASF2:
	.string	"P_ARRAY"
.LASF9:
	.string	"lthing_types__digest"
.LASF15:
	.string	"output"
.LASF26:
	.string	"lthing_types__byte"
.LASF23:
	.string	"state"
.LASF28:
	.string	"lthing_hash__chain_hash"
.LASF24:
	.string	"lthing_hash__shake512__TbufS"
.LASF16:
	.string	"lthing_hash__chain_hash__T21b"
.LASF14:
	.string	"artifact"
.LASF20:
	.string	"lthing_hash__chain_hash__L_3__T26b___L"
.LASF30:
	.string	"lthing_hash__shake512"
.LASF5:
	.string	"integer"
.LASF11:
	.string	"lthing_crypto_ffi__keccak_state"
.LASF21:
	.string	"lthing_hash__chain_hash__L_3__T26b___U"
.LASF8:
	.string	"lthing_types__byte_array___XUA"
.LASF7:
	.string	"lthing_types__byte_array___XUB"
.LASF6:
	.string	"lthing_types__byte_array"
	.section	.debug_line_str,"MS",@progbits,1
.LASF0:
	.string	"/home/claude/lthing-spark/src/lthing_hash.adb"
.LASF1:
	.string	"/home/claude/lthing-spark/obj/gnatprove/data_representation"
	.ident	"GCC: (GNU) 14.1.0"
	.section	.note.GNU-stack,"",@progbits
