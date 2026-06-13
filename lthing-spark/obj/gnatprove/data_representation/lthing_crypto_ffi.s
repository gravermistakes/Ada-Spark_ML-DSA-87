	.file	"lthing_crypto_ffi.ads"
	.text
.Ltext0:
	.file 0 "/home/claude/lthing-spark/obj/gnatprove/data_representation" "/home/claude/lthing-spark/src/lthing_crypto_ffi.ads"
	.align 2
	.globl	lthing_crypto_ffi__Tkeccak_stateBIP
	.type	lthing_crypto_ffi__Tkeccak_stateBIP, @function
lthing_crypto_ffi__Tkeccak_stateBIP:
.LFB1:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, %rax
	movq	%rsi, %rcx
	movq	%rax, %rax
	movl	$0, %edx
	movq	%rcx, %rdx
	movq	%rax, -16(%rbp)
	movq	%rdx, -8(%rbp)
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	lthing_crypto_ffi__Tkeccak_stateBIP, .-lthing_crypto_ffi__Tkeccak_stateBIP
	.section	.rodata
	.align 8
.LC1:
	.ascii	"failed precondition from lthing_crypto_ffi.ads:42"
	.align 8
.LC0:
	.long	1
	.long	49
	.text
	.align 2
	.globl	lthing_crypto_ffi__shake_absorb
	.type	lthing_crypto_ffi__shake_absorb, @function
lthing_crypto_ffi__shake_absorb:
.LFB2:
	.file 1 "/home/claude/lthing-spark/src/lthing_crypto_ffi.ads"
	.loc 1 33 14
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r13
	pushq	%r12
	subq	$32, %rsp
	.cfi_offset 13, -24
	.cfi_offset 12, -32
	movq	%rdi, -24(%rbp)
	movq	%rsi, %rax
	movq	%rdx, %rsi
	movq	%rax, %rax
	movl	$0, %edx
	movq	%rsi, %rdx
	movq	%rax, -48(%rbp)
	movq	%rdx, -40(%rbp)
	movl	%ecx, -28(%rbp)
	movl	%r8d, -32(%rbp)
	.loc 1 33 14
	movq	-40(%rbp), %rax
	movl	(%rax), %eax
	movq	-40(%rbp), %rdx
	movl	4(%rdx), %edx
.LBB2:
	cmpl	%eax, %edx
	.loc 1 33 14 is_stmt 0 discriminator 4
	cmpl	%eax, %edx
	.loc 1 33 14 discriminator 8
	cmpl	%eax, %edx
	.loc 1 42 18 is_stmt 1
	cmpl	%edx, %eax
	jle	.L10
.LBB3:
	.loc 1 42 18 is_stmt 0 discriminator 1
	movl	$.LC1, %r12d
	movl	$.LC0, %r13d
	movq	%r12, %rdx
	movq	%r13, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L10:
.LBE3:
	.loc 1 42 43 is_stmt 1 discriminator 2
	cmpl	$72, -32(%rbp)
	je	.L11
.LBB4:
	.loc 1 42 43 is_stmt 0 discriminator 3
	movl	$.LC1, %r10d
	movl	$.LC0, %r11d
	movq	%r10, %rdx
	movq	%r11, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L11:
.LBE4:
	.loc 1 33 14 is_stmt 1
	movq	-48(%rbp), %rsi
	movl	-32(%rbp), %ecx
	movl	-28(%rbp), %edx
	movq	-24(%rbp), %rax
	movq	%rax, %rdi
	call	shake256_absorb
.LBE2:
	addq	$32, %rsp
	popq	%r12
	popq	%r13
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	lthing_crypto_ffi__shake_absorb, .-lthing_crypto_ffi__shake_absorb
	.align 2
	.type	lthing_crypto_ffi__shake_squeeze___wrapped_statements.0, @function
lthing_crypto_ffi__shake_squeeze___wrapped_statements.0:
.LFB4:
	.loc 1 45 14
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%r10, %rax
	movq	%r10, -8(%rbp)
	.loc 1 45 14
	movq	8(%rax), %rdx
	movq	(%rdx), %rsi
	movq	(%rax), %rdi
	movl	20(%rax), %edx
	movl	16(%rax), %eax
	movl	%eax, %ecx
	call	shake256_squeeze
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
	.size	lthing_crypto_ffi__shake_squeeze___wrapped_statements.0, .-lthing_crypto_ffi__shake_squeeze___wrapped_statements.0
	.section	.rodata
	.align 8
.LC2:
	.ascii	"failed precondition from lthing_crypto_ffi.ads:54"
	.text
	.align 2
	.globl	lthing_crypto_ffi__shake_squeeze
	.type	lthing_crypto_ffi__shake_squeeze, @function
lthing_crypto_ffi__shake_squeeze:
.LFB3:
	.loc 1 45 14
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%r13
	pushq	%r12
	subq	$64, %rsp
	.cfi_offset 13, -24
	.cfi_offset 12, -32
	movq	%rdi, -56(%rbp)
	movq	%rsi, %rax
	movq	%rdx, %rsi
	movq	%rax, %rax
	movl	$0, %edx
	movq	%rsi, %rdx
	movq	%rax, -80(%rbp)
	movq	%rdx, -72(%rbp)
	movl	%ecx, -60(%rbp)
	movl	%r8d, -64(%rbp)
	.loc 1 45 14
	leaq	16(%rbp), %rax
	.loc 1 45 14 is_stmt 0 discriminator 1
	movq	%rax, -24(%rbp)
	leaq	-80(%rbp), %rax
	movq	-56(%rbp), %rdx
	movq	%rdx, -48(%rbp)
	movq	%rax, -40(%rbp)
	movl	-60(%rbp), %eax
	movl	%eax, -28(%rbp)
	movl	-64(%rbp), %eax
	movl	%eax, -32(%rbp)
	movq	-72(%rbp), %rax
	movl	4(%rax), %edx
	movq	-72(%rbp), %rax
	movl	(%rax), %eax
	cmpl	%eax, %edx
	.loc 1 45 14 discriminator 4
	movq	-72(%rbp), %rax
	movl	4(%rax), %edx
	movq	-72(%rbp), %rax
	movl	(%rax), %eax
	cmpl	%eax, %edx
	.loc 1 45 14 discriminator 8
	movq	-72(%rbp), %rax
	movl	4(%rax), %edx
	movq	-72(%rbp), %rax
	movl	(%rax), %eax
	cmpl	%eax, %edx
	.loc 1 54 33 is_stmt 1
	movq	-72(%rbp), %rax
	movl	(%rax), %edx
	movq	-72(%rbp), %rax
	movl	4(%rax), %eax
	.loc 1 54 19
	cmpl	%eax, %edx
	jle	.L22
.LBB5:
	.loc 1 54 19 is_stmt 0 discriminator 1
	movl	$.LC2, %r12d
	movl	$.LC0, %r13d
	movq	%r12, %rdx
	movq	%r13, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L22:
.LBE5:
	.loc 1 54 46 is_stmt 1 discriminator 2
	movl	-32(%rbp), %eax
	cmpl	$72, %eax
	je	.L23
.LBB6:
	.loc 1 54 46 is_stmt 0 discriminator 3
	movl	$.LC2, %r10d
	movl	$.LC0, %r11d
	movq	%r10, %rdx
	movq	%r11, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L23:
.LBE6:
	.loc 1 45 14 is_stmt 1
	leaq	-48(%rbp), %rax
	movq	%rax, %r10
	call	lthing_crypto_ffi__shake_squeeze___wrapped_statements.0
	addq	$64, %rsp
	popq	%r12
	popq	%r13
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	lthing_crypto_ffi__shake_squeeze, .-lthing_crypto_ffi__shake_squeeze
	.section	.rodata
	.align 8
.LC3:
	.ascii	"failed precondition from lthing_crypto_ffi.ads:66"
.LC4:
	.ascii	"lthing_crypto_ffi.ads"
	.zero	1
	.align 8
.LC5:
	.ascii	"failed precondition from lthing_crypto_ffi.ads:67"
	.align 8
.LC6:
	.ascii	"failed precondition from lthing_crypto_ffi.ads:68"
	.text
	.align 2
	.globl	lthing_crypto_ffi__compare_ct
	.type	lthing_crypto_ffi__compare_ct, @function
lthing_crypto_ffi__compare_ct:
.LFB5:
	.loc 1 58 13
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
	subq	$88, %rsp
	.cfi_offset 15, -24
	.cfi_offset 14, -32
	.cfi_offset 13, -40
	.cfi_offset 12, -48
	.cfi_offset 3, -56
	movq	%rdi, %rax
	movq	%rsi, %r9
	movq	%rax, %rsi
	movl	$0, %edi
	movq	%r9, %rdi
	movq	%rsi, -64(%rbp)
	movq	%rdi, -56(%rbp)
	movq	%rdx, -80(%rbp)
	movq	%rcx, -72(%rbp)
	movl	%r8d, -84(%rbp)
	.loc 1 58 13
	movq	-72(%rbp), %rax
	movl	(%rax), %esi
	movq	-72(%rbp), %rax
	movl	4(%rax), %r8d
	cmpl	%esi, %r8d
	jl	.L26
	.loc 1 58 13 is_stmt 0 discriminator 1
	movslq	%r8d, %rax
	cqto
	movslq	%esi, %rcx
	movq	%rcx, %rbx
	sarq	$63, %rbx
	subq	%rcx, %rax
	sbbq	%rbx, %rdx
	addq	$1, %rax
	adcq	$0, %rdx
	movq	%rax, %r12
	movq	%rdx, %r13
	jmp	.L27
.L26:
	.loc 1 58 13 discriminator 2
	movl	$0, %r12d
	movl	$0, %r13d
.L27:
	.loc 1 58 13 discriminator 4
	movq	-56(%rbp), %rax
	movl	(%rax), %ecx
	movq	-56(%rbp), %rax
	movl	4(%rax), %edi
	cmpl	%ecx, %edi
	jl	.L28
	.loc 1 58 13 discriminator 5
	movslq	%edi, %rax
	cqto
	movslq	%ecx, %r9
	movq	%r9, %r10
	movq	%r9, %r11
	sarq	$63, %r11
	subq	%r10, %rax
	sbbq	%r11, %rdx
	addq	$1, %rax
	adcq	$0, %rdx
	jmp	.L29
.L28:
	.loc 1 58 13 discriminator 6
	movl	$0, %eax
	movl	$0, %edx
.L29:
.LBB7:
	.loc 1 58 13 discriminator 8
	cmpl	%esi, %r8d
	.loc 1 58 13 discriminator 12
	cmpl	%esi, %r8d
	.loc 1 58 13 discriminator 16
	cmpl	%esi, %r8d
	.loc 1 58 13 discriminator 20
	cmpl	%ecx, %edi
	.loc 1 58 13 discriminator 24
	cmpl	%ecx, %edi
	.loc 1 58 13 discriminator 28
	cmpl	%ecx, %edi
	.loc 1 66 22 is_stmt 1
	movl	-84(%rbp), %ecx
	.loc 1 66 18
	testl	%ecx, %ecx
	jns	.L42
.LBB8:
	.loc 1 66 18 is_stmt 0 discriminator 1
	movq	$.LC3, -128(%rbp)
	movq	$.LC0, -120(%rbp)
	movq	-128(%rbp), %rbx
	movq	-120(%rbp), %rsi
	movq	%rbx, %rdx
	movq	%rsi, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L42:
.LBE8:
	.loc 1 67 48 is_stmt 1
	movl	-84(%rbp), %ecx
	testl	%ecx, %ecx
	jns	.L43
	.loc 1 67 48 is_stmt 0 discriminator 1
	movl	$67, %esi
	movl	$.LC4, %edi
	call	__gnat_rcheck_CE_Range_Check
.L43:
	.loc 1 67 36 is_stmt 1 discriminator 2
	movl	%eax, %edx
	movl	-84(%rbp), %eax
	.loc 1 67 27 discriminator 2
	cmpl	%eax, %edx
	jge	.L44
.LBB9:
	.loc 1 67 27 is_stmt 0 discriminator 3
	movq	$.LC5, -112(%rbp)
	movq	$.LC0, -104(%rbp)
	movq	-112(%rbp), %rbx
	movq	-104(%rbp), %rsi
	movq	%rbx, %rdx
	movq	%rsi, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L44:
.LBE9:
	.loc 1 68 48 is_stmt 1
	movl	-84(%rbp), %eax
	testl	%eax, %eax
	jns	.L45
	.loc 1 68 48 is_stmt 0 discriminator 1
	movl	$68, %esi
	movl	$.LC4, %edi
	call	__gnat_rcheck_CE_Range_Check
.L45:
	.loc 1 68 36 is_stmt 1 discriminator 2
	movl	%r12d, %edx
	movl	-84(%rbp), %eax
	.loc 1 68 27 discriminator 2
	cmpl	%eax, %edx
	jge	.L46
.LBB10:
	.loc 1 68 27 is_stmt 0 discriminator 3
	movl	$.LC6, %r14d
	movl	$.LC0, %r15d
	movq	%r14, %rdx
	movq	%r15, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L46:
.LBE10:
	.loc 1 58 13 is_stmt 1
	movq	-80(%rbp), %rcx
	movq	-64(%rbp), %rax
	movl	-84(%rbp), %edx
	movq	%rcx, %rsi
	movq	%rax, %rdi
	call	compare_constant_time
.LBE7:
	addq	$88, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	lthing_crypto_ffi__compare_ct, .-lthing_crypto_ffi__compare_ct
	.globl	lthing_crypto_ffi_E
	.data
	.align 2
	.type	lthing_crypto_ffi_E, @object
	.size	lthing_crypto_ffi_E, 2
lthing_crypto_ffi_E:
	.zero	2
	.text
.Letext0:
	.file 2 "/tmp/gnatprove_14.1.1_f6ca6f8c/libexec/spark/lib/gcc/x86_64-pc-linux-gnu/14.1.0/adainclude/interfac.ads"
	.file 3 "/home/claude/lthing-spark/src/lthing_types.ads"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0x244
	.value	0x5
	.byte	0x1
	.byte	0x8
	.long	.Ldebug_abbrev0
	.uleb128 0xc
	.long	.LASF22
	.byte	0xd
	.long	.LASF0
	.long	.LASF1
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.long	.Ldebug_line0
	.uleb128 0x3
	.byte	0x4
	.byte	0x5
	.long	.LASF2
	.uleb128 0x5
	.sleb128 -2147483648
	.sleb128 2147483647
	.long	.LASF8
	.long	0x48
	.uleb128 0x6
	.byte	0x4
	.long	.LASF14
	.uleb128 0x3
	.byte	0x1
	.byte	0x7
	.long	.LASF3
	.uleb128 0xd
	.byte	0
	.byte	0xff
	.long	.LASF23
	.long	0x4e
	.uleb128 0x7
	.long	.LASF6
	.byte	0x10
	.byte	0x1c
	.byte	0x9
	.long	0x88
	.uleb128 0x8
	.long	.LASF4
	.byte	0x46
	.long	0x77
	.byte	0
	.uleb128 0x9
	.long	0x9c
	.uleb128 0x8
	.long	.LASF5
	.byte	0x46
	.long	0xee
	.byte	0x8
	.byte	0
	.uleb128 0x2
	.long	0x60
	.uleb128 0x2
	.long	0x60
	.uleb128 0x2
	.long	0x60
	.uleb128 0x2
	.long	0x60
	.uleb128 0xa
	.long	.LASF12
	.long	0x55
	.long	0xbf
	.uleb128 0xe
	.long	0x2e
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
	.uleb128 0x7
	.long	.LASF7
	.byte	0x8
	.byte	0x1a
	.byte	0x2e
	.long	0xee
	.uleb128 0xb
	.string	"LB0"
	.long	0xd5
	.byte	0
	.uleb128 0x5
	.sleb128 0
	.sleb128 1048576
	.long	.LASF9
	.long	0x2e
	.uleb128 0xb
	.string	"UB0"
	.long	0xd5
	.byte	0x4
	.byte	0
	.uleb128 0x9
	.long	0xbf
	.uleb128 0x3
	.byte	0x4
	.byte	0x7
	.long	.LASF10
	.uleb128 0xf
	.long	0xf3
	.uleb128 0x3
	.byte	0x8
	.byte	0x7
	.long	.LASF11
	.uleb128 0xa
	.long	.LASF13
	.long	0xff
	.long	0x11b
	.uleb128 0x10
	.long	0x2e
	.sleb128 0
	.sleb128 24
	.byte	0
	.uleb128 0x11
	.long	.LASF24
	.byte	0x1
	.byte	0x19
	.byte	0x4
	.long	0x12e
	.byte	0x48
	.uleb128 0x6
	.byte	0x10
	.long	.LASF15
	.uleb128 0x2
	.long	0x128
	.uleb128 0x12
	.long	.LASF25
	.byte	0x1
	.byte	0x3a
	.byte	0xd
	.long	0x35
	.quad	.LFB5
	.quad	.LFE5-.LFB5
	.uleb128 0x1
	.byte	0x9c
	.long	0x17c
	.uleb128 0x4
	.string	"a"
	.byte	0x3b
	.long	0x97
	.uleb128 0x3
	.byte	0x91
	.sleb128 -80
	.uleb128 0x4
	.string	"b"
	.byte	0x3c
	.long	0x92
	.uleb128 0x3
	.byte	0x91
	.sleb128 -96
	.uleb128 0x4
	.string	"len"
	.byte	0x3d
	.long	0xfa
	.uleb128 0x3
	.byte	0x91
	.sleb128 -100
	.byte	0
	.uleb128 0x13
	.long	.LASF26
	.byte	0x1
	.byte	0x2d
	.byte	0xe
	.quad	.LFB3
	.quad	.LFE3-.LFB3
	.uleb128 0x1
	.byte	0x9c
	.long	0x1f2
	.uleb128 0x1
	.long	.LASF16
	.byte	0x2e
	.long	0x1f2
	.uleb128 0x2
	.byte	0x91
	.sleb128 -64
	.uleb128 0x1
	.long	.LASF17
	.byte	0x2f
	.long	0x8d
	.uleb128 0x3
	.byte	0x91
	.sleb128 -96
	.uleb128 0x1
	.long	.LASF18
	.byte	0x30
	.long	0xfa
	.uleb128 0x4
	.byte	0x91
	.sleb128 -64
	.byte	0x23
	.uleb128 0x14
	.uleb128 0x1
	.long	.LASF19
	.byte	0x31
	.long	0xfa
	.uleb128 0x4
	.byte	0x91
	.sleb128 -64
	.byte	0x23
	.uleb128 0x10
	.uleb128 0x14
	.long	.LASF27
	.quad	.LFB4
	.quad	.LFE4-.LFB4
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x6
	.byte	0x91
	.sleb128 -24
	.byte	0x6
	.byte	0x23
	.uleb128 0x18
	.byte	0x6
	.byte	0
	.uleb128 0x15
	.byte	0x8
	.long	0x106
	.uleb128 0x16
	.long	.LASF28
	.byte	0x1
	.byte	0x21
	.byte	0xe
	.quad	.LFB2
	.quad	.LFE2-.LFB2
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x1
	.long	.LASF16
	.byte	0x22
	.long	0x1f2
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x1
	.long	.LASF20
	.byte	0x23
	.long	0x88
	.uleb128 0x2
	.byte	0x91
	.sleb128 -64
	.uleb128 0x1
	.long	.LASF21
	.byte	0x24
	.long	0xfa
	.uleb128 0x2
	.byte	0x91
	.sleb128 -44
	.uleb128 0x1
	.long	.LASF19
	.byte	0x25
	.long	0xfa
	.uleb128 0x2
	.byte	0x91
	.sleb128 -48
	.byte	0
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x5
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
	.uleb128 0x2
	.uleb128 0x26
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x34
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x3
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
	.uleb128 0x4
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
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
	.uleb128 0x5
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
	.uleb128 0x6
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0x21
	.sleb128 5
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x34
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0x21
	.sleb128 3
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
	.uleb128 0x8
	.uleb128 0xd
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
	.sleb128 29
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x9
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0x21
	.sleb128 8
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xa
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
	.uleb128 0xb
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0x21
	.sleb128 3
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
	.uleb128 0xc
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
	.uleb128 0xd
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
	.uleb128 0xe
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
	.uleb128 0xf
	.uleb128 0x26
	.byte	0
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
	.uleb128 0xd
	.uleb128 0x2f
	.uleb128 0xd
	.byte	0
	.byte	0
	.uleb128 0x11
	.uleb128 0x27
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x1c
	.uleb128 0xb
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
	.uleb128 0x49
	.uleb128 0x13
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
	.uleb128 0x14
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x34
	.uleb128 0x19
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x48
	.uleb128 0x18
	.uleb128 0x7c
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x15
	.uleb128 0x10
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x16
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
.LASF3:
	.string	"interfaces__unsigned_8"
.LASF27:
	.string	"lthing_crypto_ffi__shake_squeeze___wrapped_statements"
.LASF5:
	.string	"P_BOUNDS"
.LASF9:
	.string	"lthing_types__index_range"
.LASF11:
	.string	"interfaces__unsigned_64"
.LASF14:
	.string	"interfaces__c__TintB"
.LASF26:
	.string	"lthing_crypto_ffi__shake_squeeze"
.LASF19:
	.string	"rate"
.LASF10:
	.string	"interfaces__c__unsigned"
.LASF8:
	.string	"interfaces__c__int"
.LASF4:
	.string	"P_ARRAY"
.LASF17:
	.string	"output"
.LASF21:
	.string	"data_len"
.LASF23:
	.string	"lthing_types__byte"
.LASF20:
	.string	"data"
.LASF28:
	.string	"lthing_crypto_ffi__shake_absorb"
.LASF18:
	.string	"output_len"
.LASF15:
	.string	"universal_integer"
.LASF25:
	.string	"lthing_crypto_ffi__compare_ct"
.LASF16:
	.string	"state"
.LASF2:
	.string	"integer"
.LASF13:
	.string	"lthing_crypto_ffi__keccak_state"
.LASF22:
	.string	"GNU Ada 14.1.0 -O0 -gnatA -g -gnatwa -gnata -gnatR2js -gnatws -gnatec=/tmp/GPR.2392/GNAT-TEMP-000003.TMP -gnatem=/tmp/GPR.2392/GNAT-TEMP-000004.TMP -mtune=generic -march=x86-64"
.LASF12:
	.string	"lthing_types__byte_array___XUA"
.LASF7:
	.string	"lthing_types__byte_array___XUB"
.LASF6:
	.string	"lthing_types__byte_array"
.LASF24:
	.string	"lthing_crypto_ffi__shake512_rate"
	.section	.debug_line_str,"MS",@progbits,1
.LASF0:
	.string	"/home/claude/lthing-spark/src/lthing_crypto_ffi.ads"
.LASF1:
	.string	"/home/claude/lthing-spark/obj/gnatprove/data_representation"
	.ident	"GCC: (GNU) 14.1.0"
	.section	.note.GNU-stack,"",@progbits
