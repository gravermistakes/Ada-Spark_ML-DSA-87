	.file	"lthing_mldsa_field.adb"
	.text
.Ltext0:
	.file 0 "/home/claude/lthing-spark/obj/gnatprove/data_representation" "/home/claude/lthing-spark/src/lthing_mldsa_field.adb"
	.section	.rodata
.LC2:
	.ascii	"lthing_mldsa_field.adb"
	.zero	1
	.text
	.align 2
	.type	lthing_mldsa_field__add___wrapped_statements.0, @function
lthing_mldsa_field__add___wrapped_statements.0:
.LFB3:
	.file 1 "/home/claude/lthing-spark/src/lthing_mldsa_field.adb"
	.loc 1 10 4
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%r10, %rax
	movq	%r10, -24(%rbp)
	.loc 1 11 49
	movl	4(%rax), %edx
	movslq	%edx, %rdx
	movl	(%rax), %eax
	cltq
	.loc 1 11 7
	addq	%rdx, %rax
	movq	%rax, -8(%rbp)
	.loc 1 15 20
	movq	-8(%rbp), %rcx
	movq	%rcx, %rsi
	sarq	$63, %rsi
	movq	%rcx, %rax
	xorq	%rsi, %rax
	movabsq	$2308096734784685153, %rdx
	mulq	%rdx
	movq	%rdx, %rax
	shrq	$20, %rax
	xorq	%rsi, %rax
	imulq	$8380417, %rax, %rdx
	movq	%rcx, %rax
	subq	%rdx, %rax
	.loc 1 15 14
	movabsq	$-2147483649, %rdx
	cmpq	%rdx, %rax
	jle	.L2
	.loc 1 15 20 discriminator 2
	movq	-8(%rbp), %rcx
	movq	%rcx, %rsi
	sarq	$63, %rsi
	movq	%rcx, %rax
	xorq	%rsi, %rax
	movabsq	$2308096734784685153, %rdx
	mulq	%rdx
	movq	%rdx, %rax
	shrq	$20, %rax
	xorq	%rsi, %rax
	imulq	$8380417, %rax, %rdx
	movq	%rcx, %rax
	subq	%rdx, %rax
	.loc 1 15 14 discriminator 2
	movl	$2147483648, %edx
	cmpq	%rdx, %rax
	jl	.L3
.L2:
	.loc 1 15 14 is_stmt 0 discriminator 3
	movl	$15, %esi
	movl	$.LC2, %edi
	call	__gnat_rcheck_CE_Overflow_Check
.L3:
	.loc 1 15 20 is_stmt 1 discriminator 4
	movq	-8(%rbp), %rcx
	movq	%rcx, %rsi
	sarq	$63, %rsi
	movq	%rcx, %rax
	xorq	%rsi, %rax
	movabsq	$2308096734784685153, %rdx
	mulq	%rdx
	movq	%rdx, %rax
	shrq	$20, %rax
	xorq	%rsi, %rax
	imulq	$8380417, %rax, %rdx
	movq	%rcx, %rax
	subq	%rdx, %rax
	.loc 1 16 8
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	lthing_mldsa_field__add___wrapped_statements.0, .-lthing_mldsa_field__add___wrapped_statements.0
	.section	.rodata
	.align 8
.LC3:
	.ascii	"failed postcondition from lthing_mldsa_field.ads:35"
	.align 8
.LC0:
	.long	1
	.long	51
	.text
	.align 2
	.globl	lthing_mldsa_field__add
	.type	lthing_mldsa_field__add, @function
lthing_mldsa_field__add:
.LFB2:
	.loc 1 10 4
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
	movl	%edi, -36(%rbp)
	movl	%esi, -40(%rbp)
	.loc 1 10 4
	leaq	16(%rbp), %rax
	.loc 1 10 4 is_stmt 0 discriminator 1
	movq	%rax, -24(%rbp)
	movl	-36(%rbp), %eax
	movl	%eax, -28(%rbp)
	movl	-40(%rbp), %eax
	movl	%eax, -32(%rbp)
.LBB2:
	leaq	-32(%rbp), %rax
	movq	%rax, %r10
	call	lthing_mldsa_field__add___wrapped_statements.0
	movl	%eax, %esi
	.file 2 "/home/claude/lthing-spark/src/lthing_mldsa_field.ads"
	.loc 2 35 45 is_stmt 1
	movslq	%esi, %rdi
	.loc 2 35 63
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movl	-32(%rbp), %eax
	cltq
	leaq	(%rdx,%rax), %rcx
	.loc 2 35 81
	movabsq	$2308096734784685153, %rdx
	movq	%rcx, %rax
	imulq	%rdx
	movq	%rdx, %rax
	sarq	$20, %rax
	movq	%rcx, %rdx
	sarq	$63, %rdx
	subq	%rdx, %rax
	imulq	$8380417, %rax, %rdx
	movq	%rcx, %rax
	subq	%rdx, %rax
	.loc 2 35 21
	cmpq	%rax, %rdi
	je	.L7
.LBB3:
	.loc 2 35 21 is_stmt 0 discriminator 1
	movl	$.LC3, %r12d
	movl	$.LC0, %r13d
	movq	%r12, %rdx
	movq	%r13, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L7:
.LBE3:
	.loc 1 10 4 is_stmt 1 discriminator 1
	movl	%esi, %eax
.LBE2:
	.loc 1 10 4 is_stmt 0
	addq	$32, %rsp
	popq	%r12
	popq	%r13
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	lthing_mldsa_field__add, .-lthing_mldsa_field__add
	.align 2
	.type	lthing_mldsa_field__sub___wrapped_statements.1, @function
lthing_mldsa_field__sub___wrapped_statements.1:
.LFB5:
	.loc 1 18 4 is_stmt 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%r10, %rax
	movq	%r10, -24(%rbp)
	.loc 1 19 49
	movl	4(%rax), %edx
	movslq	%edx, %rdx
	movl	(%rax), %eax
	cltq
	subq	%rax, %rdx
	.loc 1 19 7
	leaq	8380417(%rdx), %rax
	movq	%rax, -8(%rbp)
	.loc 1 22 20
	movq	-8(%rbp), %rcx
	movq	%rcx, %rsi
	sarq	$63, %rsi
	movq	%rcx, %rax
	xorq	%rsi, %rax
	movabsq	$2308096734784685153, %rdx
	mulq	%rdx
	movq	%rdx, %rax
	shrq	$20, %rax
	xorq	%rsi, %rax
	imulq	$8380417, %rax, %rdx
	movq	%rcx, %rax
	subq	%rdx, %rax
	.loc 1 22 14
	movabsq	$-2147483649, %rdx
	cmpq	%rdx, %rax
	jle	.L9
	.loc 1 22 20 discriminator 2
	movq	-8(%rbp), %rcx
	movq	%rcx, %rsi
	sarq	$63, %rsi
	movq	%rcx, %rax
	xorq	%rsi, %rax
	movabsq	$2308096734784685153, %rdx
	mulq	%rdx
	movq	%rdx, %rax
	shrq	$20, %rax
	xorq	%rsi, %rax
	imulq	$8380417, %rax, %rdx
	movq	%rcx, %rax
	subq	%rdx, %rax
	.loc 1 22 14 discriminator 2
	movl	$2147483648, %edx
	cmpq	%rdx, %rax
	jl	.L10
.L9:
	.loc 1 22 14 is_stmt 0 discriminator 3
	movl	$22, %esi
	movl	$.LC2, %edi
	call	__gnat_rcheck_CE_Overflow_Check
.L10:
	.loc 1 22 20 is_stmt 1 discriminator 4
	movq	-8(%rbp), %rcx
	movq	%rcx, %rsi
	sarq	$63, %rsi
	movq	%rcx, %rax
	xorq	%rsi, %rax
	movabsq	$2308096734784685153, %rdx
	mulq	%rdx
	movq	%rdx, %rax
	shrq	$20, %rax
	xorq	%rsi, %rax
	imulq	$8380417, %rax, %rdx
	movq	%rcx, %rax
	subq	%rdx, %rax
	.loc 1 23 8
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	lthing_mldsa_field__sub___wrapped_statements.1, .-lthing_mldsa_field__sub___wrapped_statements.1
	.section	.rodata
	.align 8
.LC4:
	.ascii	"failed postcondition from lthing_mldsa_field.ads:40"
	.text
	.align 2
	.globl	lthing_mldsa_field__sub
	.type	lthing_mldsa_field__sub, @function
lthing_mldsa_field__sub:
.LFB4:
	.loc 1 18 4
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
	movl	%edi, -36(%rbp)
	movl	%esi, -40(%rbp)
	.loc 1 18 4
	leaq	16(%rbp), %rax
	.loc 1 18 4 is_stmt 0 discriminator 1
	movq	%rax, -24(%rbp)
	movl	-36(%rbp), %eax
	movl	%eax, -28(%rbp)
	movl	-40(%rbp), %eax
	movl	%eax, -32(%rbp)
.LBB4:
	leaq	-32(%rbp), %rax
	movq	%rax, %r10
	call	lthing_mldsa_field__sub___wrapped_statements.1
	movl	%eax, %esi
	.loc 2 40 45 is_stmt 1
	movslq	%esi, %r8
	.loc 2 40 64
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movl	-32(%rbp), %eax
	cltq
	movq	%rdx, %rcx
	subq	%rax, %rcx
	.loc 2 40 82
	movq	%rcx, %rdi
	sarq	$63, %rdi
	movq	%rcx, %rax
	xorq	%rdi, %rax
	movabsq	$2308096734784685153, %rdx
	mulq	%rdx
	movq	%rdx, %rax
	shrq	$20, %rax
	xorq	%rdi, %rax
	imulq	$8380417, %rax, %rdx
	movq	%rcx, %rax
	subq	%rdx, %rax
	.loc 2 40 21
	cmpq	%rax, %r8
	je	.L14
.LBB5:
	.loc 2 40 21 is_stmt 0 discriminator 1
	movl	$.LC4, %r12d
	movl	$.LC0, %r13d
	movq	%r12, %rdx
	movq	%r13, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L14:
.LBE5:
	.loc 1 18 4 is_stmt 1 discriminator 1
	movl	%esi, %eax
.LBE4:
	.loc 1 18 4 is_stmt 0
	addq	$32, %rsp
	popq	%r12
	popq	%r13
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
	.size	lthing_mldsa_field__sub, .-lthing_mldsa_field__sub
	.align 2
	.type	lthing_mldsa_field__mul___wrapped_statements.2, @function
lthing_mldsa_field__mul___wrapped_statements.2:
.LFB7:
	.loc 1 25 4 is_stmt 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%r10, %rax
	movq	%r10, -24(%rbp)
	.loc 1 26 49
	movl	4(%rax), %edx
	movslq	%edx, %rdx
	movl	(%rax), %eax
	cltq
	.loc 1 26 7
	imulq	%rdx, %rax
	movq	%rax, -8(%rbp)
	.loc 1 29 20
	movq	-8(%rbp), %rcx
	movq	%rcx, %rsi
	sarq	$63, %rsi
	movq	%rcx, %rax
	xorq	%rsi, %rax
	movabsq	$2308096734784685153, %rdx
	mulq	%rdx
	movq	%rdx, %rax
	shrq	$20, %rax
	xorq	%rsi, %rax
	imulq	$8380417, %rax, %rdx
	movq	%rcx, %rax
	subq	%rdx, %rax
	.loc 1 29 14
	movabsq	$-2147483649, %rdx
	cmpq	%rdx, %rax
	jle	.L16
	.loc 1 29 20 discriminator 2
	movq	-8(%rbp), %rcx
	movq	%rcx, %rsi
	sarq	$63, %rsi
	movq	%rcx, %rax
	xorq	%rsi, %rax
	movabsq	$2308096734784685153, %rdx
	mulq	%rdx
	movq	%rdx, %rax
	shrq	$20, %rax
	xorq	%rsi, %rax
	imulq	$8380417, %rax, %rdx
	movq	%rcx, %rax
	subq	%rdx, %rax
	.loc 1 29 14 discriminator 2
	movl	$2147483648, %edx
	cmpq	%rdx, %rax
	jl	.L17
.L16:
	.loc 1 29 14 is_stmt 0 discriminator 3
	movl	$29, %esi
	movl	$.LC2, %edi
	call	__gnat_rcheck_CE_Overflow_Check
.L17:
	.loc 1 29 20 is_stmt 1 discriminator 4
	movq	-8(%rbp), %rcx
	movq	%rcx, %rsi
	sarq	$63, %rsi
	movq	%rcx, %rax
	xorq	%rsi, %rax
	movabsq	$2308096734784685153, %rdx
	mulq	%rdx
	movq	%rdx, %rax
	shrq	$20, %rax
	xorq	%rsi, %rax
	imulq	$8380417, %rax, %rdx
	movq	%rcx, %rax
	subq	%rdx, %rax
	.loc 1 30 8
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	lthing_mldsa_field__mul___wrapped_statements.2, .-lthing_mldsa_field__mul___wrapped_statements.2
	.section	.rodata
	.align 8
.LC5:
	.ascii	"failed postcondition from lthing_mldsa_field.ads:45"
	.text
	.align 2
	.globl	lthing_mldsa_field__mul
	.type	lthing_mldsa_field__mul, @function
lthing_mldsa_field__mul:
.LFB6:
	.loc 1 25 4
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
	movl	%edi, -36(%rbp)
	movl	%esi, -40(%rbp)
	.loc 1 25 4
	leaq	16(%rbp), %rax
	.loc 1 25 4 is_stmt 0 discriminator 1
	movq	%rax, -24(%rbp)
	movl	-36(%rbp), %eax
	movl	%eax, -28(%rbp)
	movl	-40(%rbp), %eax
	movl	%eax, -32(%rbp)
.LBB6:
	leaq	-32(%rbp), %rax
	movq	%rax, %r10
	call	lthing_mldsa_field__mul___wrapped_statements.2
	movl	%eax, %esi
	.loc 2 45 45 is_stmt 1
	movslq	%esi, %rdi
	.loc 2 45 63
	movl	-28(%rbp), %eax
	movslq	%eax, %rdx
	movl	-32(%rbp), %eax
	cltq
	movq	%rdx, %rcx
	imulq	%rax, %rcx
	.loc 2 45 81
	movabsq	$2308096734784685153, %rdx
	movq	%rcx, %rax
	imulq	%rdx
	movq	%rdx, %rax
	sarq	$20, %rax
	movq	%rcx, %rdx
	sarq	$63, %rdx
	subq	%rdx, %rax
	imulq	$8380417, %rax, %rdx
	movq	%rcx, %rax
	subq	%rdx, %rax
	.loc 2 45 21
	cmpq	%rax, %rdi
	je	.L21
.LBB7:
	.loc 2 45 21 is_stmt 0 discriminator 1
	movl	$.LC5, %r12d
	movl	$.LC0, %r13d
	movq	%r12, %rdx
	movq	%r13, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L21:
.LBE7:
	.loc 1 25 4 is_stmt 1 discriminator 1
	movl	%esi, %eax
.LBE6:
	.loc 1 25 4 is_stmt 0
	addq	$32, %rsp
	popq	%r12
	popq	%r13
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	lthing_mldsa_field__mul, .-lthing_mldsa_field__mul
	.align 2
	.type	lthing_mldsa_field__reduce___wrapped_statements.3, @function
lthing_mldsa_field__reduce___wrapped_statements.3:
.LFB9:
	.loc 1 32 4 is_stmt 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%r10, %rcx
	movq	%r10, -8(%rbp)
	.loc 1 34 20
	movq	(%rcx), %rsi
	movq	%rsi, %rdi
	sarq	$63, %rdi
	movq	%rsi, %rax
	xorq	%rdi, %rax
	movabsq	$2308096734784685153, %rdx
	mulq	%rdx
	movq	%rdx, %rax
	shrq	$20, %rax
	xorq	%rdi, %rax
	imulq	$8380417, %rax, %rdx
	movq	%rsi, %rax
	subq	%rdx, %rax
	.loc 1 34 14
	movabsq	$-2147483649, %rdx
	cmpq	%rdx, %rax
	jle	.L23
	.loc 1 34 20 discriminator 2
	movq	(%rcx), %rsi
	movq	%rsi, %rdi
	sarq	$63, %rdi
	movq	%rsi, %rax
	xorq	%rdi, %rax
	movabsq	$2308096734784685153, %rdx
	mulq	%rdx
	movq	%rdx, %rax
	shrq	$20, %rax
	xorq	%rdi, %rax
	imulq	$8380417, %rax, %rdx
	movq	%rsi, %rax
	subq	%rdx, %rax
	.loc 1 34 14 discriminator 2
	movl	$2147483648, %edx
	cmpq	%rdx, %rax
	jl	.L24
.L23:
	.loc 1 34 14 is_stmt 0 discriminator 3
	movl	$34, %esi
	movl	$.LC2, %edi
	call	__gnat_rcheck_CE_Overflow_Check
.L24:
	.loc 1 34 20 is_stmt 1 discriminator 4
	movq	(%rcx), %rcx
	movq	%rcx, %rsi
	sarq	$63, %rsi
	movq	%rcx, %rax
	xorq	%rsi, %rax
	movabsq	$2308096734784685153, %rdx
	mulq	%rdx
	movq	%rdx, %rax
	shrq	$20, %rax
	xorq	%rsi, %rax
	imulq	$8380417, %rax, %rdx
	movq	%rcx, %rax
	subq	%rdx, %rax
	.loc 1 35 8
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	lthing_mldsa_field__reduce___wrapped_statements.3, .-lthing_mldsa_field__reduce___wrapped_statements.3
	.section	.rodata
	.align 8
.LC6:
	.ascii	"failed precondition from lthing_mldsa_field.ads:50"
	.align 8
.LC7:
	.ascii	"failed postcondition from lthing_mldsa_field.ads:51"
	.align 8
.LC1:
	.long	1
	.long	50
	.text
	.align 2
	.globl	lthing_mldsa_field__reduce
	.type	lthing_mldsa_field__reduce, @function
lthing_mldsa_field__reduce:
.LFB8:
	.loc 1 32 4
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
	movq	%rdi, -40(%rbp)
	.loc 1 32 4
	leaq	16(%rbp), %rcx
	.loc 1 32 4 is_stmt 0 discriminator 1
	movq	%rcx, -24(%rbp)
	movq	-40(%rbp), %rcx
	movq	%rcx, -32(%rbp)
	.loc 2 50 21 is_stmt 1
	movq	-32(%rbp), %rcx
	testq	%rcx, %rcx
	jns	.L27
.LBB8:
	.loc 2 50 21 is_stmt 0 discriminator 1
	movl	$.LC6, %eax
	movl	$.LC1, %edx
	movq	%rax, %rcx
	movq	%rdx, %rax
	movq	%rcx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L27:
.LBE8:
.LBB9:
	.loc 1 32 4 is_stmt 1
	leaq	-32(%rbp), %rax
	movq	%rax, %r10
	call	lthing_mldsa_field__reduce___wrapped_statements.3
	movl	%eax, %esi
	.loc 2 51 48
	movslq	%esi, %r8
	.loc 2 51 52
	movq	-32(%rbp), %rcx
	movq	%rcx, %rdi
	sarq	$63, %rdi
	movq	%rcx, %rax
	xorq	%rdi, %rax
	movabsq	$2308096734784685153, %rdx
	mulq	%rdx
	movq	%rdx, %rax
	shrq	$20, %rax
	xorq	%rdi, %rax
	imulq	$8380417, %rax, %rdx
	movq	%rcx, %rax
	subq	%rdx, %rax
	.loc 2 51 21
	cmpq	%rax, %r8
	je	.L29
.LBB10:
	.loc 2 51 21 is_stmt 0 discriminator 1
	movl	$.LC7, %r12d
	movl	$.LC0, %r13d
	movq	%r12, %rdx
	movq	%r13, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L29:
.LBE10:
	.loc 1 32 4 is_stmt 1 discriminator 1
	movl	%esi, %eax
.LBE9:
	.loc 1 32 4 is_stmt 0
	addq	$32, %rsp
	popq	%r12
	popq	%r13
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	lthing_mldsa_field__reduce, .-lthing_mldsa_field__reduce
	.align 2
	.type	lthing_mldsa_field__to_centered___wrapped_statements.4, @function
lthing_mldsa_field__to_centered___wrapped_statements.4:
.LFB11:
	.loc 1 37 4 is_stmt 1
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%r10, %rax
	movq	%r10, -8(%rbp)
	.loc 1 39 7
	movl	(%rax), %edx
	cmpl	$4190208, %edx
	jle	.L31
	.loc 1 40 10
	movl	(%rax), %eax
	subl	$8380417, %eax
	jmp	.L32
.L31:
	.loc 1 42 10
	movl	(%rax), %eax
.L32:
	.loc 1 44 8
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE11:
	.size	lthing_mldsa_field__to_centered___wrapped_statements.4, .-lthing_mldsa_field__to_centered___wrapped_statements.4
	.section	.rodata
	.align 8
.LC8:
	.ascii	"failed postcondition from lthing_mldsa_field.ads:56"
	.align 8
.LC9:
	.ascii	"failed postcondition from lthing_mldsa_field.ads:57"
	.text
	.align 2
	.globl	lthing_mldsa_field__to_centered
	.type	lthing_mldsa_field__to_centered, @function
lthing_mldsa_field__to_centered:
.LFB10:
	.loc 1 37 4
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
	subq	$32, %rsp
	.cfi_offset 15, -24
	.cfi_offset 14, -32
	.cfi_offset 13, -40
	.cfi_offset 12, -48
	movl	%edi, -52(%rbp)
	.loc 1 37 4
	leaq	16(%rbp), %rax
	.loc 1 37 4 is_stmt 0 discriminator 1
	movq	%rax, -40(%rbp)
	movl	-52(%rbp), %eax
	movl	%eax, -48(%rbp)
.LBB11:
	leaq	-48(%rbp), %rax
	movq	%rax, %r10
	call	lthing_mldsa_field__to_centered___wrapped_statements.4
	.loc 2 56 21 is_stmt 1
	cmpl	$-4190208, %eax
	jl	.L34
	.loc 2 56 40 discriminator 2
	cmpl	$4190208, %eax
	jle	.L35
.L34:
.LBB12:
	.loc 2 56 21 discriminator 3
	movl	$.LC8, %r14d
	movl	$.LC0, %r15d
	movq	%r14, %rdx
	movq	%r15, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L35:
.LBE12:
	.loc 2 57 50
	cltd
	movl	%eax, %ecx
	xorl	%edx, %ecx
	movl	%ecx, %ecx
	imulq	$1074791297, %rcx, %rcx
	shrq	$32, %rcx
	shrl	$21, %ecx
	xorl	%ecx, %edx
	imull	$8380417, %edx, %ecx
	movl	%eax, %edx
	subl	%ecx, %edx
	.loc 2 57 31
	movl	-48(%rbp), %ecx
	cmpl	%edx, %ecx
	je	.L37
.LBB13:
	.loc 2 57 31 is_stmt 0 discriminator 1
	movl	$.LC9, %r12d
	movl	$.LC0, %r13d
	movq	%r12, %rdx
	movq	%r13, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L37:
.LBE13:
.LBE11:
	.loc 1 37 4 is_stmt 1
	addq	$32, %rsp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE10:
	.size	lthing_mldsa_field__to_centered, .-lthing_mldsa_field__to_centered
	.globl	lthing_mldsa_field_E
	.data
	.align 2
	.type	lthing_mldsa_field_E, @object
	.size	lthing_mldsa_field_E, 2
lthing_mldsa_field_E:
	.zero	2
	.text
.Letext0:
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0x28e
	.value	0x5
	.byte	0x1
	.byte	0x8
	.long	.Ldebug_abbrev0
	.uleb128 0x8
	.long	.LASF18
	.byte	0xd
	.long	.LASF0
	.long	.LASF1
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.long	.Ldebug_line0
	.uleb128 0x2
	.sleb128 0
	.sleb128 8380416
	.long	.LASF2
	.long	0x41
	.uleb128 0x7
	.long	0x2e
	.uleb128 0x4
	.byte	0x4
	.long	.LASF4
	.uleb128 0x2
	.sleb128 -9223372036854775808
	.sleb128 9223372036854775807
	.long	.LASF3
	.long	0x69
	.uleb128 0x7
	.long	0x47
	.uleb128 0x4
	.byte	0x8
	.long	.LASF5
	.uleb128 0x2
	.sleb128 -2147483648
	.sleb128 2147483647
	.long	.LASF6
	.long	0x41
	.uleb128 0x2
	.sleb128 -9223372036854775808
	.sleb128 9223372036854775807
	.long	.LASF7
	.long	0x69
	.uleb128 0x9
	.long	.LASF19
	.byte	0x2
	.byte	0x18
	.byte	0x4
	.long	0xb5
	.long	0x7fe001
	.uleb128 0x4
	.byte	0x10
	.long	.LASF8
	.uleb128 0xa
	.long	0xaf
	.uleb128 0x3
	.long	.LASF9
	.byte	0x25
	.long	0x6f
	.quad	.LFB10
	.quad	.LFE10-.LFB10
	.uleb128 0x1
	.byte	0x9c
	.long	0x109
	.uleb128 0x1
	.string	"a"
	.byte	0x36
	.byte	0x1a
	.long	0x3c
	.uleb128 0x2
	.byte	0x91
	.sleb128 -64
	.uleb128 0xb
	.long	.LASF11
	.long	0x6f
	.quad	.LFB11
	.quad	.LFE11-.LFB11
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x6
	.byte	0x91
	.sleb128 -24
	.byte	0x6
	.byte	0x23
	.uleb128 0x8
	.byte	0x6
	.byte	0
	.uleb128 0x3
	.long	.LASF10
	.byte	0x20
	.long	0x2e
	.quad	.LFB8
	.quad	.LFE8-.LFB8
	.uleb128 0x1
	.byte	0x9c
	.long	0x158
	.uleb128 0x1
	.string	"x"
	.byte	0x30
	.byte	0x15
	.long	0x64
	.uleb128 0x2
	.byte	0x91
	.sleb128 -48
	.uleb128 0xc
	.long	.LASF12
	.long	0x2e
	.quad	.LFB9
	.quad	.LFE9-.LFB9
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x6
	.byte	0x91
	.sleb128 -24
	.byte	0x6
	.byte	0x23
	.uleb128 0x8
	.byte	0x6
	.byte	0
	.uleb128 0x3
	.long	.LASF13
	.byte	0x19
	.long	0x2e
	.quad	.LFB6
	.quad	.LFE6-.LFB6
	.uleb128 0x1
	.byte	0x9c
	.long	0x1c1
	.uleb128 0x1
	.string	"a"
	.byte	0x2b
	.byte	0x12
	.long	0x3c
	.uleb128 0x4
	.byte	0x91
	.sleb128 -48
	.byte	0x23
	.uleb128 0x4
	.uleb128 0x1
	.string	"b"
	.byte	0x2b
	.byte	0x15
	.long	0x3c
	.uleb128 0x2
	.byte	0x91
	.sleb128 -48
	.uleb128 0x5
	.long	.LASF15
	.long	0x2e
	.quad	.LFB7
	.quad	.LFE7-.LFB7
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x6
	.byte	0x91
	.sleb128 -40
	.byte	0x6
	.byte	0x23
	.uleb128 0x8
	.byte	0x6
	.uleb128 0x6
	.string	"p"
	.byte	0x1a
	.long	0x82
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.byte	0
	.uleb128 0x3
	.long	.LASF14
	.byte	0x12
	.long	0x2e
	.quad	.LFB4
	.quad	.LFE4-.LFB4
	.uleb128 0x1
	.byte	0x9c
	.long	0x22a
	.uleb128 0x1
	.string	"a"
	.byte	0x26
	.byte	0x12
	.long	0x3c
	.uleb128 0x4
	.byte	0x91
	.sleb128 -48
	.byte	0x23
	.uleb128 0x4
	.uleb128 0x1
	.string	"b"
	.byte	0x26
	.byte	0x15
	.long	0x3c
	.uleb128 0x2
	.byte	0x91
	.sleb128 -48
	.uleb128 0x5
	.long	.LASF16
	.long	0x2e
	.quad	.LFB5
	.quad	.LFE5-.LFB5
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x6
	.byte	0x91
	.sleb128 -40
	.byte	0x6
	.byte	0x23
	.uleb128 0x8
	.byte	0x6
	.uleb128 0x6
	.string	"s"
	.byte	0x13
	.long	0x82
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.byte	0
	.uleb128 0xd
	.long	.LASF20
	.byte	0x1
	.byte	0xa
	.byte	0x4
	.long	0x2e
	.quad	.LFB2
	.quad	.LFE2-.LFB2
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x1
	.string	"a"
	.byte	0x21
	.byte	0x12
	.long	0x3c
	.uleb128 0x4
	.byte	0x91
	.sleb128 -48
	.byte	0x23
	.uleb128 0x4
	.uleb128 0x1
	.string	"b"
	.byte	0x21
	.byte	0x15
	.long	0x3c
	.uleb128 0x2
	.byte	0x91
	.sleb128 -48
	.uleb128 0x5
	.long	.LASF17
	.long	0x2e
	.quad	.LFB3
	.quad	.LFE3-.LFB3
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x6
	.byte	0x91
	.sleb128 -40
	.byte	0x6
	.byte	0x23
	.uleb128 0x8
	.byte	0x6
	.uleb128 0x6
	.string	"s"
	.byte	0xb
	.long	0x82
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0x21
	.sleb128 2
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
	.uleb128 0x2
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
	.uleb128 0x3
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0x21
	.sleb128 1
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0x21
	.sleb128 4
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
	.uleb128 0x4
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
	.uleb128 0x5
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x49
	.uleb128 0x13
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
	.uleb128 0x6
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
	.uleb128 0x21
	.sleb128 7
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0x26
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x8
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
	.uleb128 0x9
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
	.uleb128 0x6
	.byte	0
	.byte	0
	.uleb128 0xa
	.uleb128 0x26
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x34
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0xb
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x49
	.uleb128 0x13
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
	.uleb128 0x7a
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0xc
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x49
	.uleb128 0x13
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
	.uleb128 0xd
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
.LASF13:
	.string	"lthing_mldsa_field__mul"
.LASF20:
	.string	"lthing_mldsa_field__add"
.LASF15:
	.string	"lthing_mldsa_field__mul___wrapped_statements"
.LASF16:
	.string	"lthing_mldsa_field__sub___wrapped_statements"
.LASF3:
	.string	"lthing_mldsa_field__wide"
.LASF12:
	.string	"lthing_mldsa_field__reduce___wrapped_statements"
.LASF14:
	.string	"lthing_mldsa_field__sub"
.LASF2:
	.string	"lthing_mldsa_field__fq"
.LASF6:
	.string	"interfaces__integer_32"
.LASF7:
	.string	"interfaces__integer_64"
.LASF17:
	.string	"lthing_mldsa_field__add___wrapped_statements"
.LASF5:
	.string	"interfaces__Tinteger_64B"
.LASF4:
	.string	"interfaces__Tinteger_32B"
.LASF9:
	.string	"lthing_mldsa_field__to_centered"
.LASF10:
	.string	"lthing_mldsa_field__reduce"
.LASF18:
	.string	"GNU Ada 14.1.0 -O0 -gnatA -g -gnatwa -gnata -gnatR2js -gnatws -gnatec=/tmp/GPR.638/GNAT-TEMP-000003.TMP -gnatem=/tmp/GPR.638/GNAT-TEMP-000004.TMP -mtune=generic -march=x86-64"
.LASF19:
	.string	"lthing_mldsa_field__q"
.LASF8:
	.string	"universal_integer"
.LASF11:
	.string	"lthing_mldsa_field__to_centered___wrapped_statements"
	.section	.debug_line_str,"MS",@progbits,1
.LASF1:
	.string	"/home/claude/lthing-spark/obj/gnatprove/data_representation"
.LASF0:
	.string	"/home/claude/lthing-spark/src/lthing_mldsa_field.adb"
	.ident	"GCC: (GNU) 14.1.0"
	.section	.note.GNU-stack,"",@progbits
