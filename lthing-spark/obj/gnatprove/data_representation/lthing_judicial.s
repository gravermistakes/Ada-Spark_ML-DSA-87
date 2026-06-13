	.file	"lthing_judicial.adb"
	.text
.Ltext0:
	.file 0 "/home/claude/lthing-spark/obj/gnatprove/data_representation" "/home/claude/lthing-spark/src/lthing_judicial.adb"
	.align 2
	.type	lthing_judicial__envelope_ok, @function
lthing_judicial__envelope_ok:
.LFB2:
	.file 1 "/home/claude/lthing-spark/src/lthing_judicial.adb"
	.loc 1 32 4
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
	.loc 1 32 4
	movq	-8(%rbp), %rax
	movl	(%rax), %eax
	movq	-8(%rbp), %rdx
	movl	4(%rdx), %edx
.LBB2:
	cmpl	%eax, %edx
	.loc 1 32 4 is_stmt 0 discriminator 4
	cmpl	%eax, %edx
	.loc 1 32 4 discriminator 8
	cmpl	%eax, %edx
	.loc 1 37 30 is_stmt 1
	cltq
	leaq	46(%rax), %rcx
	movslq	%edx, %rax
	.loc 1 37 7
	cmpq	%rax, %rcx
	setl	%al
.LBE2:
	.loc 1 38 8
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	lthing_judicial__envelope_ok, .-lthing_judicial__envelope_ok
	.section	.rodata
.LC5:
	.ascii	"lthing_judicial.adb"
	.zero	1
	.text
	.align 2
	.type	lthing_judicial__magic_ok, @function
lthing_judicial__magic_ok:
.LFB3:
	.loc 1 42 4
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, %rax
	movq	%rsi, %rcx
	movq	%rax, %rax
	movl	$0, %edx
	movq	%rcx, %rdx
	movq	%rax, -16(%rbp)
	movq	%rdx, -8(%rbp)
	.loc 1 42 4
	movq	-8(%rbp), %rax
	movl	(%rax), %eax
	movq	-8(%rbp), %rdx
	movl	4(%rdx), %edx
.LBB3:
	movslq	%eax, %rsi
	cmpl	%eax, %edx
	.loc 1 42 4 is_stmt 0 discriminator 4
	cmpl	%eax, %edx
	.loc 1 42 4 discriminator 8
	cmpl	%eax, %edx
	.loc 1 48 30 is_stmt 1
	movslq	%eax, %rcx
	leaq	8(%rcx), %rdi
	movslq	%edx, %rcx
	.loc 1 49 9
	cmpq	%rcx, %rdi
	jge	.L16
	.loc 1 49 52 discriminator 1
	cmpl	$2147483638, %eax
	jle	.L17
	.loc 1 49 52 is_stmt 0 discriminator 3
	movl	$49, %esi
	movl	$.LC5, %edi
	call	__gnat_rcheck_CE_Overflow_Check
.L17:
	.loc 1 49 52 discriminator 4
	leal	9(%rax), %ecx
	.loc 1 49 27 is_stmt 1 discriminator 6
	cmpl	%eax, %ecx
	jl	.L18
	.loc 1 49 27 is_stmt 0 discriminator 8
	cmpl	%edx, %ecx
	jle	.L19
.L18:
	.loc 1 49 27 discriminator 9
	movl	$49, %esi
	movl	$.LC5, %edi
	call	__gnat_rcheck_CE_Index_Check
.L19:
	.loc 1 49 58 is_stmt 1 discriminator 10
	movq	-16(%rbp), %rdx
	.loc 1 49 52 discriminator 10
	addl	$9, %eax
	cltq
	.loc 1 49 58 discriminator 10
	subq	%rsi, %rax
	movzbl	(%rdx,%rax), %eax
	cmpb	$4, %al
	sete	%al
	.loc 1 49 9 discriminator 10
	testb	%al, %al
	je	.L16
	.loc 1 49 9 is_stmt 0 discriminator 11
	movl	$1, %eax
	.loc 1 49 9
	jmp	.L20
.L16:
	.loc 1 49 9 discriminator 12
	movl	$0, %eax
.L20:
.LBE3:
	.loc 1 50 8 is_stmt 1
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	lthing_judicial__magic_ok, .-lthing_judicial__magic_ok
	.section	.rodata
	.align 8
.LC0:
	.long	0
	.long	63
	.text
	.align 2
	.type	lthing_judicial__digest_equal, @function
lthing_judicial__digest_equal:
.LFB4:
	.loc 1 53 4
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$168, %rsp
	.cfi_offset 3, -24
	movq	%rdi, -168(%rbp)
	movq	%rsi, -176(%rbp)
.LBB4:
	.loc 1 59 11
	movl	$0, -20(%rbp)
.L24:
	.loc 1 59 11 is_stmt 0 discriminator 1
	cmpl	$63, -20(%rbp)
	jg	.L23
	.loc 1 60 20 is_stmt 1
	movl	-20(%rbp), %esi
	movslq	%esi, %rdi
	movl	-20(%rbp), %esi
	movslq	%esi, %rsi
	movq	-168(%rbp), %r8
	movzbl	(%r8,%rdi), %edi
	.loc 1 60 20 is_stmt 0 discriminator 1
	movb	%dil, -96(%rbp,%rsi)
	.loc 1 61 20 is_stmt 1
	movl	-20(%rbp), %esi
	movslq	%esi, %rdi
	movl	-20(%rbp), %esi
	movslq	%esi, %rsi
	movq	-176(%rbp), %r8
	movzbl	(%r8,%rdi), %edi
	.loc 1 61 20 is_stmt 0 discriminator 1
	movb	%dil, -160(%rbp,%rsi)
	.loc 1 59 11 is_stmt 1 discriminator 2
	addl	$1, -20(%rbp)
	.loc 1 62 15
	jmp	.L24
.L23:
.LBE4:
	.loc 1 63 14
	leaq	-160(%rbp), %rsi
	movq	%rsi, %rax
	movl	$.LC0, %edx
	leaq	-96(%rbp), %rsi
	movq	%rsi, %rcx
	movl	$.LC0, %ebx
	movq	%rcx, %rdi
	movq	%rbx, %rsi
	movl	$64, %r8d
	movq	%rdx, %rcx
	movq	%rax, %rdx
	call	lthing_crypto_ffi__compare_ct
	.loc 1 63 7 discriminator 1
	testl	%eax, %eax
	sete	%al
	.loc 1 64 8
	movq	-8(%rbp), %rbx
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
	.size	lthing_judicial__digest_equal, .-lthing_judicial__digest_equal
	.align 2
	.type	lthing_judicial__verify_signature, @function
lthing_judicial__verify_signature:
.LFB5:
	.loc 1 71 4
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movq	%rdi, %rax
	movq	%rsi, %r8
	movq	%rax, %rsi
	movl	$0, %edi
	movq	%r8, %rdi
	movq	%rsi, -16(%rbp)
	movq	%rdi, -8(%rbp)
	movq	%rdx, -32(%rbp)
	movq	%rcx, -24(%rbp)
	.loc 1 71 4
	movq	-24(%rbp), %rax
	movl	(%rax), %edx
	movq	-24(%rbp), %rax
	movl	4(%rax), %esi
	movq	-8(%rbp), %rax
	movl	(%rax), %eax
	movq	-8(%rbp), %rcx
	movl	4(%rcx), %ecx
.LBB5:
	cmpl	%edx, %esi
	.loc 1 71 4 is_stmt 0 discriminator 4
	cmpl	%edx, %esi
	.loc 1 71 4 discriminator 8
	cmpl	%edx, %esi
	.loc 1 71 4 discriminator 12
	cmpl	%eax, %ecx
	.loc 1 71 4 discriminator 16
	cmpl	%eax, %ecx
	.loc 1 71 4 discriminator 20
	cmpl	%eax, %ecx
	.loc 1 78 7 is_stmt 1
	movl	$0, %eax
.LBE5:
	.loc 1 79 8
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	lthing_judicial__verify_signature, .-lthing_judicial__verify_signature
	.section	.rodata
	.align 8
.LC6:
	.ascii	"Dynamic_Predicate failed at lthing_judicial.adb:90"
	.align 8
.LC7:
	.ascii	"Dynamic_Predicate failed at lthing_judicial.adb:93"
	.align 8
.LC2:
	.long	1
	.long	50
	.text
	.align 2
	.type	lthing_judicial__parse_unverified___wrapped_statements.0, @function
lthing_judicial__parse_unverified___wrapped_statements.0:
.LFB7:
	.loc 1 84 4
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
	subq	$24, %rsp
	.cfi_offset 15, -24
	.cfi_offset 14, -32
	.cfi_offset 13, -40
	.cfi_offset 12, -48
	.cfi_offset 3, -56
	movq	%r10, %rbx
	movq	%r10, -56(%rbp)
	.loc 1 89 14
	movq	8(%rbx), %rax
	movq	(%rax), %rdx
	movq	8(%rax), %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	lthing_judicial__envelope_ok
	.loc 1 89 14 is_stmt 0 discriminator 1
	xorl	$1, %eax
	.loc 1 89 7 is_stmt 1 discriminator 1
	testb	%al, %al
	je	.L41
	.loc 1 90 17
	movq	(%rbx), %rax
	movb	$1, (%rax)
	movq	(%rbx), %rax
	movb	$0, 1(%rax)
	.loc 1 90 10
	movq	(%rbx), %rax
	movzwl	(%rax), %eax
	movl	%eax, %edi
	call	lthing_types__verified_recordPredicate
	.loc 1 90 10 is_stmt 0 discriminator 1
	xorl	$1, %eax
	testb	%al, %al
	je	.L44
.LBB6:
	movl	$.LC6, %r14d
	movl	$.LC2, %r15d
	movq	%r14, %rdx
	movq	%r15, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L41:
.LBE6:
	.loc 1 93 17 is_stmt 1
	movq	(%rbx), %rax
	movb	$7, (%rax)
	movq	(%rbx), %rax
	movb	$0, 1(%rax)
	.loc 1 93 10
	movq	(%rbx), %rax
	movzwl	(%rax), %eax
	movl	%eax, %edi
	call	lthing_types__verified_recordPredicate
	.loc 1 93 10 is_stmt 0 discriminator 1
	xorl	$1, %eax
	testb	%al, %al
	je	.L44
.LBB7:
	movl	$.LC7, %r12d
	movl	$.LC2, %r13d
	movq	%r12, %rdx
	movq	%r13, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L44:
.LBE7:
	.loc 1 95 8 is_stmt 1
	nop
	addq	$24, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	lthing_judicial__parse_unverified___wrapped_statements.0, .-lthing_judicial__parse_unverified___wrapped_statements.0
	.section	.rodata
	.align 8
.LC8:
	.ascii	"failed postcondition from lthing_judicial.ads:51"
	.align 8
.LC9:
	.ascii	"failed postcondition from lthing_judicial.ads:52"
	.align 8
.LC1:
	.long	1
	.long	48
	.text
	.align 2
	.globl	lthing_judicial__parse_unverified
	.type	lthing_judicial__parse_unverified, @function
lthing_judicial__parse_unverified:
.LFB6:
	.loc 1 84 4
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
	subq	$72, %rsp
	.cfi_offset 15, -24
	.cfi_offset 14, -32
	.cfi_offset 13, -40
	.cfi_offset 12, -48
	.cfi_offset 3, -56
	movq	%rdi, %rax
	movq	%rax, %rcx
	movl	$0, %ebx
	movq	%rsi, %rbx
	movq	%rcx, -96(%rbp)
	movq	%rbx, -88(%rbp)
	movw	%dx, -98(%rbp)
	.loc 1 84 4
	leaq	16(%rbp), %rax
	.loc 1 84 4 is_stmt 0 discriminator 1
	leaq	-96(%rbp), %rdx
	movq	%rax, -64(%rbp)
	leaq	-98(%rbp), %rax
	movq	%rdx, -72(%rbp)
	movq	%rax, -80(%rbp)
	movq	-88(%rbp), %rax
	movl	(%rax), %eax
	movq	-88(%rbp), %rdx
	movl	4(%rdx), %edx
.LBB8:
	cmpl	%eax, %edx
	.loc 1 84 4 discriminator 4
	cmpl	%eax, %edx
	.loc 1 84 4 discriminator 8
	cmpl	%eax, %edx
	.loc 1 84 4 discriminator 12
	leaq	-80(%rbp), %rax
	movq	%rax, %r10
	call	lthing_judicial__parse_unverified___wrapped_statements.0
	.file 2 "/home/claude/lthing-spark/src/lthing_judicial.ads"
	.loc 2 51 21 is_stmt 1
	movzbl	-97(%rbp), %eax
	testb	%al, %al
	je	.L52
.LBB9:
	.loc 2 51 21 is_stmt 0 discriminator 1
	movl	$.LC8, %r14d
	movl	$.LC1, %r15d
	movq	%r14, %rdx
	movq	%r15, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L52:
.LBE9:
	.loc 2 52 44 is_stmt 1
	movzbl	-98(%rbp), %eax
	.loc 2 52 30
	testb	%al, %al
	jne	.L56
.LBB10:
	.loc 2 52 30 is_stmt 0 discriminator 1
	movl	$.LC9, %r12d
	movl	$.LC1, %r13d
	movq	%r12, %rdx
	movq	%r13, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L56:
.LBE10:
	.loc 1 84 4 is_stmt 1
	nop
.LBE8:
	movzwl	-98(%rbp), %eax
	addq	$72, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	lthing_judicial__parse_unverified, .-lthing_judicial__parse_unverified
	.section	.rodata
	.align 8
.LC10:
	.ascii	"Dynamic_Predicate failed at lthing_judicial.adb:111"
	.align 8
.LC11:
	.ascii	"Dynamic_Predicate failed at lthing_judicial.adb:115"
	.align 8
.LC12:
	.ascii	"Dynamic_Predicate failed at lthing_judicial.adb:121"
	.align 8
.LC13:
	.ascii	"Dynamic_Predicate failed at lthing_judicial.adb:133"
	.align 8
.LC14:
	.ascii	"Dynamic_Predicate failed at lthing_judicial.adb:139"
	.align 8
.LC15:
	.ascii	"Dynamic_Predicate failed at lthing_judicial.adb:144"
	.align 8
.LC4:
	.long	1
	.long	51
	.text
	.align 2
	.type	lthing_judicial__parse_and_verify___wrapped_statements.1, @function
lthing_judicial__parse_and_verify___wrapped_statements.1:
.LFB9:
	.loc 1 100 4
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
	subq	$152, %rsp
	.cfi_offset 15, -24
	.cfi_offset 14, -32
	.cfi_offset 13, -40
	.cfi_offset 12, -48
	.cfi_offset 3, -56
	movq	%r10, %rbx
	movq	%r10, -120(%rbp)
	.loc 1 111 14
	movq	24(%rbx), %rax
	movb	$7, (%rax)
	movq	24(%rbx), %rax
	movb	$0, 1(%rax)
	.loc 1 111 7
	movq	24(%rbx), %rax
	movzwl	(%rax), %eax
	movl	%eax, %edi
	call	lthing_types__verified_recordPredicate
	.loc 1 111 7 is_stmt 0 discriminator 1
	xorl	$1, %eax
	testb	%al, %al
	je	.L58
.LBB11:
	.loc 1 111 7 discriminator 2
	movq	$.LC10, -192(%rbp)
	movq	$.LC4, -184(%rbp)
	movq	-192(%rbp), %rcx
	movq	-184(%rbp), %rbx
	movq	%rcx, %rdx
	movq	%rbx, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L58:
.LBE11:
	.loc 1 114 14 is_stmt 1
	movq	16(%rbx), %rax
	movq	(%rax), %rdx
	movq	8(%rax), %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	lthing_judicial__envelope_ok
	.loc 1 114 14 is_stmt 0 discriminator 1
	xorl	$1, %eax
	.loc 1 114 7 is_stmt 1 discriminator 1
	testb	%al, %al
	je	.L59
	.loc 1 115 17
	movq	24(%rbx), %rax
	movb	$1, (%rax)
	movq	24(%rbx), %rax
	movb	$0, 1(%rax)
	.loc 1 115 10
	movq	24(%rbx), %rax
	movzwl	(%rax), %eax
	movl	%eax, %edi
	call	lthing_types__verified_recordPredicate
	.loc 1 115 10 is_stmt 0 discriminator 1
	xorl	$1, %eax
	testb	%al, %al
	je	.L70
.LBB12:
	.loc 1 115 10 discriminator 2
	movq	$.LC11, -176(%rbp)
	movq	$.LC4, -168(%rbp)
	movq	-176(%rbp), %rcx
	movq	-168(%rbp), %rbx
	movq	%rcx, %rdx
	movq	%rbx, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L59:
.LBE12:
	.loc 1 120 14 is_stmt 1
	movq	16(%rbx), %rax
	movq	(%rax), %rdx
	movq	8(%rax), %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	lthing_judicial__magic_ok
	.loc 1 120 14 is_stmt 0 discriminator 1
	xorl	$1, %eax
	.loc 1 120 7 is_stmt 1 discriminator 1
	testb	%al, %al
	je	.L62
	.loc 1 121 17
	movq	24(%rbx), %rax
	movb	$2, (%rax)
	movq	24(%rbx), %rax
	movb	$0, 1(%rax)
	.loc 1 121 10
	movq	24(%rbx), %rax
	movzwl	(%rax), %eax
	movl	%eax, %edi
	call	lthing_types__verified_recordPredicate
	.loc 1 121 10 is_stmt 0 discriminator 1
	xorl	$1, %eax
	testb	%al, %al
	je	.L71
.LBB13:
	.loc 1 121 10 discriminator 2
	movq	$.LC12, -160(%rbp)
	movq	$.LC4, -152(%rbp)
	movq	-160(%rbp), %rcx
	movq	-152(%rbp), %rbx
	movq	%rcx, %rdx
	movq	%rbx, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L62:
.LBE13:
	.loc 1 127 7 is_stmt 1
	movq	8(%rbx), %rdi
	movq	16(%rbx), %rax
	leaq	-112(%rbp), %rcx
	movq	(%rax), %rdx
	movq	8(%rax), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdx
	call	lthing_hash__chain_hash
	.loc 1 132 14
	leaq	-112(%rbp), %rdx
	leaq	-112(%rbp), %rax
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	lthing_judicial__digest_equal
	.loc 1 132 14 is_stmt 0 discriminator 1
	xorl	$1, %eax
	.loc 1 132 7 is_stmt 1 discriminator 1
	testb	%al, %al
	je	.L64
	.loc 1 133 17
	movq	24(%rbx), %rax
	movb	$5, (%rax)
	movq	24(%rbx), %rax
	movb	$0, 1(%rax)
	.loc 1 133 10
	movq	24(%rbx), %rax
	movzwl	(%rax), %eax
	movl	%eax, %edi
	call	lthing_types__verified_recordPredicate
	.loc 1 133 10 is_stmt 0 discriminator 1
	xorl	$1, %eax
	testb	%al, %al
	je	.L72
.LBB14:
	.loc 1 133 10 discriminator 2
	movq	$.LC13, -144(%rbp)
	movq	$.LC4, -136(%rbp)
	movq	-144(%rbp), %rsi
	movq	-136(%rbp), %rdi
	movq	%rsi, %rdx
	movq	%rdi, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L64:
.LBE14:
	.loc 1 138 14 is_stmt 1
	movq	16(%rbx), %rcx
	movq	(%rbx), %rax
	movq	8(%rax), %rdx
	movq	(%rax), %rax
	movq	(%rcx), %rdi
	movq	8(%rcx), %rsi
	movq	%rdx, %rcx
	movq	%rax, %rdx
	call	lthing_judicial__verify_signature
	.loc 1 138 14 is_stmt 0 discriminator 1
	xorl	$1, %eax
	.loc 1 138 7 is_stmt 1 discriminator 1
	testb	%al, %al
	je	.L66
	.loc 1 139 17
	movq	24(%rbx), %rax
	movb	$6, (%rax)
	movq	24(%rbx), %rax
	movb	$0, 1(%rax)
	.loc 1 139 10
	movq	24(%rbx), %rax
	movzwl	(%rax), %eax
	movl	%eax, %edi
	call	lthing_types__verified_recordPredicate
	.loc 1 139 10 is_stmt 0 discriminator 1
	xorl	$1, %eax
	testb	%al, %al
	je	.L73
.LBB15:
	.loc 1 139 10 discriminator 2
	movl	$.LC14, %r14d
	movl	$.LC4, %r15d
	movq	%r14, %rdx
	movq	%r15, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L66:
.LBE15:
	.loc 1 144 14 is_stmt 1
	movq	24(%rbx), %rax
	movb	$0, (%rax)
	movq	24(%rbx), %rax
	movb	$1, 1(%rax)
	.loc 1 144 7
	movq	24(%rbx), %rax
	movzwl	(%rax), %eax
	movl	%eax, %edi
	call	lthing_types__verified_recordPredicate
	.loc 1 144 7 is_stmt 0 discriminator 1
	xorl	$1, %eax
	testb	%al, %al
	je	.L74
.LBB16:
	.loc 1 144 7 discriminator 2
	movl	$.LC15, %r12d
	movl	$.LC4, %r13d
	movq	%r12, %rdx
	movq	%r13, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L70:
.LBE16:
	.loc 1 116 10 is_stmt 1
	nop
	jmp	.L57
.L71:
	.loc 1 122 10
	nop
	jmp	.L57
.L72:
	.loc 1 134 10
	nop
	jmp	.L57
.L73:
	.loc 1 140 10
	nop
	jmp	.L57
.L74:
	.loc 1 145 8
	nop
.L57:
	addq	$152, %rsp
	popq	%rbx
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE9:
	.size	lthing_judicial__parse_and_verify___wrapped_statements.1, .-lthing_judicial__parse_and_verify___wrapped_statements.1
	.section	.rodata
	.align 8
.LC16:
	.ascii	"failed precondition from lthing_judicial.ads:79"
	.align 8
.LC17:
	.ascii	"failed precondition from lthing_judicial.ads:80"
	.align 8
.LC18:
	.ascii	"failed precondition from lthing_judicial.ads:81"
	.align 8
.LC19:
	.ascii	"failed postcondition from lthing_judicial.ads:82"
	.align 8
.LC20:
	.ascii	"failed postcondition from lthing_judicial.ads:84"
	.align 8
.LC3:
	.long	1
	.long	47
	.text
	.align 2
	.globl	lthing_judicial__parse_and_verify
	.type	lthing_judicial__parse_and_verify, @function
lthing_judicial__parse_and_verify:
.LFB8:
	.loc 1 100 4
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
	subq	$144, %rsp
	.cfi_offset 15, -24
	.cfi_offset 14, -32
	.cfi_offset 13, -40
	.cfi_offset 12, -48
	movq	%rdi, %rax
	movq	%rsi, %r10
	movq	%rax, %rsi
	movl	$0, %edi
	movq	%r10, %rdi
	movq	%rsi, -96(%rbp)
	movq	%rdi, -88(%rbp)
	movq	%rdx, -104(%rbp)
	movq	%rcx, %rax
	movq	%r8, %rcx
	movq	%rax, %rax
	movl	$0, %edx
	movq	%rcx, %rdx
	movq	%rax, -128(%rbp)
	movq	%rdx, -120(%rbp)
	movw	%r9w, -106(%rbp)
	.loc 1 100 4
	leaq	16(%rbp), %rdx
	.loc 1 100 4 is_stmt 0 discriminator 1
	leaq	-96(%rbp), %rax
	movq	%rdx, -48(%rbp)
	movq	%rax, -64(%rbp)
	leaq	-128(%rbp), %rdx
	movq	-104(%rbp), %rax
	movq	%rax, -72(%rbp)
	leaq	-106(%rbp), %rax
	movq	%rdx, -80(%rbp)
	movq	%rax, -56(%rbp)
	movq	-120(%rbp), %rax
	movl	(%rax), %ecx
	movq	-120(%rbp), %rax
	movl	4(%rax), %esi
	movq	-88(%rbp), %rax
	movl	(%rax), %eax
	movq	-88(%rbp), %rdx
	movl	4(%rdx), %edx
.LBB17:
	cmpl	%ecx, %esi
	.loc 1 100 4 discriminator 4
	cmpl	%ecx, %esi
	.loc 1 100 4 discriminator 8
	cmpl	%ecx, %esi
	.loc 1 100 4 discriminator 12
	cmpl	%eax, %edx
	.loc 1 100 4 discriminator 16
	cmpl	%eax, %edx
	.loc 1 100 4 discriminator 20
	cmpl	%eax, %edx
	.loc 2 79 21 is_stmt 1
	cmpl	%edx, %eax
	jle	.L88
.LBB18:
	.loc 2 79 21 is_stmt 0 discriminator 1
	movq	$.LC16, -176(%rbp)
	movq	$.LC3, -168(%rbp)
	movq	-176(%rbp), %rsi
	movq	-168(%rbp), %rdi
	movq	%rsi, %rdx
	movq	%rdi, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L88:
.LBE18:
	.loc 2 80 46 is_stmt 1
	cltq
	leaq	1048511(%rax), %rdi
	movslq	%edx, %rax
	.loc 2 80 30
	cmpq	%rax, %rdi
	jge	.L89
.LBB19:
	.loc 2 80 30 is_stmt 0 discriminator 1
	movq	$.LC17, -160(%rbp)
	movq	$.LC3, -152(%rbp)
	movq	-160(%rbp), %rsi
	movq	-152(%rbp), %rdi
	movq	%rsi, %rdx
	movq	%rdi, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L89:
.LBE19:
	.loc 2 81 30 is_stmt 1
	cmpl	%esi, %ecx
	jle	.L90
.LBB20:
	.loc 2 81 30 is_stmt 0 discriminator 1
	movq	$.LC18, -144(%rbp)
	movq	$.LC3, -136(%rbp)
	movq	-144(%rbp), %rsi
	movq	-136(%rbp), %rdi
	movq	%rsi, %rdx
	movq	%rdi, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L90:
.LBE20:
	.loc 1 100 4 is_stmt 1
	leaq	-80(%rbp), %rax
	movq	%rax, %r10
	call	lthing_judicial__parse_and_verify___wrapped_statements.1
	.loc 2 82 39
	movzbl	-106(%rbp), %eax
	.loc 2 82 22
	testb	%al, %al
	je	.L91
	.loc 2 82 22 is_stmt 0 discriminator 1
	movzbl	-105(%rbp), %eax
	testb	%al, %al
	je	.L91
.LBB21:
	.loc 2 82 22 discriminator 2
	movl	$.LC19, %r14d
	movl	$.LC1, %r15d
	movq	%r14, %rdx
	movq	%r15, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L91:
.LBE21:
	.loc 2 84 37 is_stmt 1
	movzbl	-105(%rbp), %edx
	.loc 2 84 54
	movzbl	-106(%rbp), %eax
	testb	%al, %al
	sete	%al
	.loc 2 84 22
	cmpb	%al, %dl
	je	.L95
.LBB22:
	.loc 2 84 22 is_stmt 0 discriminator 1
	movl	$.LC20, %r12d
	movl	$.LC1, %r13d
	movq	%r12, %rdx
	movq	%r13, %rax
	movq	%rdx, %rdi
	movq	%rax, %rsi
	call	system__assertions__raise_assert_failure
.L95:
.LBE22:
	.loc 1 100 4 is_stmt 1
	nop
.LBE17:
	movzwl	-106(%rbp), %eax
	addq	$144, %rsp
	popq	%r12
	popq	%r13
	popq	%r14
	popq	%r15
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	lthing_judicial__parse_and_verify, .-lthing_judicial__parse_and_verify
	.globl	lthing_judicial_E
	.data
	.align 2
	.type	lthing_judicial_E, @object
	.size	lthing_judicial_E, 2
lthing_judicial_E:
	.zero	2
	.text
.Letext0:
	.file 3 "/tmp/gnatprove_14.1.1_f6ca6f8c/libexec/spark/lib/gcc/x86_64-pc-linux-gnu/14.1.0/adainclude/interfac.ads"
	.file 4 "/home/claude/lthing-spark/src/lthing_types.ads"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0x3e4
	.value	0x5
	.byte	0x1
	.byte	0x8
	.long	.Ldebug_abbrev0
	.uleb128 0x11
	.long	.LASF38
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
	.uleb128 0x12
	.byte	0
	.byte	0xff
	.long	.LASF39
	.long	0x2e
	.uleb128 0xa
	.long	.LASF6
	.byte	0x10
	.byte	0x1c
	.byte	0x9
	.long	0x6c
	.uleb128 0x5
	.long	.LASF2
	.byte	0x3
	.byte	0x46
	.byte	0x1d
	.long	0x59
	.byte	0
	.uleb128 0xb
	.long	0x8f
	.uleb128 0x5
	.long	.LASF3
	.byte	0x3
	.byte	0x46
	.byte	0x1d
	.long	0xe8
	.byte	0x8
	.byte	0
	.uleb128 0x2
	.long	0x40
	.uleb128 0x2
	.long	0x40
	.uleb128 0x2
	.long	0x40
	.uleb128 0x2
	.long	0x40
	.uleb128 0x2
	.long	0x40
	.uleb128 0x2
	.long	0x40
	.uleb128 0x2
	.long	0x40
	.uleb128 0x6
	.long	.LASF19
	.long	0x35
	.long	0xb2
	.uleb128 0x13
	.long	0xb2
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
	.uleb128 0xa
	.long	.LASF7
	.byte	0x8
	.byte	0x1a
	.byte	0x2e
	.long	0xe8
	.uleb128 0xc
	.string	"LB0"
	.long	0xcf
	.byte	0
	.uleb128 0x14
	.sleb128 0
	.sleb128 1048576
	.long	.LASF40
	.long	0xb2
	.uleb128 0xc
	.string	"UB0"
	.long	0xcf
	.byte	0x4
	.byte	0
	.uleb128 0xb
	.long	0xb9
	.uleb128 0x15
	.long	.LASF41
	.byte	0x7
	.byte	0x1
	.byte	0x4
	.byte	0x25
	.byte	0x9
	.long	0x12c
	.uleb128 0x3
	.long	.LASF8
	.byte	0
	.uleb128 0x3
	.long	.LASF9
	.byte	0x1
	.uleb128 0x3
	.long	.LASF10
	.byte	0x2
	.uleb128 0x3
	.long	.LASF11
	.byte	0x3
	.uleb128 0x3
	.long	.LASF12
	.byte	0x4
	.uleb128 0x3
	.long	.LASF13
	.byte	0x5
	.uleb128 0x3
	.long	.LASF14
	.byte	0x6
	.uleb128 0x3
	.long	.LASF15
	.byte	0x7
	.byte	0
	.uleb128 0x16
	.long	.LASF42
	.byte	0x2
	.byte	0x4
	.byte	0x33
	.byte	0x9
	.long	0x154
	.uleb128 0x5
	.long	.LASF16
	.byte	0x4
	.byte	0x34
	.byte	0x7
	.long	0xed
	.byte	0
	.uleb128 0x5
	.long	.LASF17
	.byte	0x4
	.byte	0x35
	.byte	0x7
	.long	0x154
	.byte	0x1
	.byte	0
	.uleb128 0x4
	.byte	0x1
	.byte	0x2
	.long	.LASF18
	.uleb128 0x6
	.long	.LASF20
	.long	0x35
	.long	0x16e
	.uleb128 0x7
	.long	0xb2
	.byte	0
	.uleb128 0xd
	.byte	0x4
	.long	.LASF22
	.uleb128 0x4
	.byte	0x4
	.byte	0x7
	.long	.LASF21
	.uleb128 0x17
	.long	.LASF43
	.byte	0x2
	.byte	0x24
	.byte	0x4
	.long	0x18e
	.byte	0x4
	.uleb128 0xd
	.byte	0x10
	.long	.LASF23
	.uleb128 0x2
	.long	0x188
	.uleb128 0xe
	.long	.LASF28
	.byte	0x64
	.long	0x12c
	.quad	.LFB8
	.quad	.LFE8-.LFB8
	.uleb128 0x1
	.byte	0x9c
	.long	0x236
	.uleb128 0x1
	.long	.LASF24
	.byte	0x2
	.byte	0x4a
	.byte	0x7
	.long	0x8a
	.uleb128 0x3
	.byte	0x91
	.sleb128 -112
	.uleb128 0x1
	.long	.LASF25
	.byte	0x2
	.byte	0x4b
	.byte	0x7
	.long	0x236
	.uleb128 0x5
	.byte	0x91
	.sleb128 -96
	.byte	0x23
	.uleb128 0x8
	.uleb128 0x1
	.long	.LASF26
	.byte	0x2
	.byte	0x4c
	.byte	0x7
	.long	0x85
	.uleb128 0x3
	.byte	0x91
	.sleb128 -144
	.uleb128 0x1
	.long	.LASF27
	.byte	0x2
	.byte	0x4d
	.byte	0x7
	.long	0x12c
	.uleb128 0x3
	.byte	0x91
	.sleb128 -122
	.uleb128 0x8
	.quad	.LBB17
	.quad	.LBE17-.LBB17
	.uleb128 0x18
	.long	.LASF44
	.quad	.LFB9
	.quad	.LFE9-.LFB9
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x7
	.byte	0x91
	.sleb128 -136
	.byte	0x6
	.byte	0x23
	.uleb128 0x20
	.byte	0x6
	.uleb128 0x9
	.long	.LASF33
	.byte	0x6a
	.long	0x15b
	.uleb128 0x3
	.byte	0x91
	.sleb128 -128
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x19
	.byte	0x8
	.long	0x15b
	.uleb128 0xe
	.long	.LASF29
	.byte	0x54
	.long	0x12c
	.quad	.LFB6
	.quad	.LFE6-.LFB6
	.uleb128 0x1
	.byte	0x9c
	.long	0x2ae
	.uleb128 0x1
	.long	.LASF24
	.byte	0x2
	.byte	0x30
	.byte	0x7
	.long	0x80
	.uleb128 0x3
	.byte	0x91
	.sleb128 -112
	.uleb128 0x1
	.long	.LASF27
	.byte	0x2
	.byte	0x31
	.byte	0x7
	.long	0x12c
	.uleb128 0x3
	.byte	0x91
	.sleb128 -114
	.uleb128 0x8
	.quad	.LBB8
	.quad	.LBE8-.LBB8
	.uleb128 0x1a
	.long	.LASF45
	.quad	.LFB7
	.quad	.LFE7-.LFB7
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x7
	.byte	0x91
	.sleb128 -72
	.byte	0x6
	.byte	0x23
	.uleb128 0x10
	.byte	0x6
	.byte	0
	.byte	0
	.uleb128 0x1b
	.long	.LASF30
	.byte	0x1
	.byte	0x47
	.byte	0x4
	.long	0x154
	.quad	.LFB5
	.quad	.LFE5-.LFB5
	.uleb128 0x1
	.byte	0x9c
	.long	0x2ef
	.uleb128 0x1
	.long	.LASF24
	.byte	0x1
	.byte	0x48
	.byte	0x7
	.long	0x7b
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.uleb128 0x1
	.long	.LASF26
	.byte	0x1
	.byte	0x49
	.byte	0x7
	.long	0x76
	.uleb128 0x2
	.byte	0x91
	.sleb128 -48
	.byte	0
	.uleb128 0xf
	.long	.LASF31
	.byte	0x35
	.long	0x154
	.quad	.LFB4
	.quad	.LFE4-.LFB4
	.uleb128 0x1
	.byte	0x9c
	.long	0x389
	.uleb128 0x10
	.string	"a"
	.byte	0x1b
	.long	0x236
	.uleb128 0x3
	.byte	0x91
	.sleb128 -184
	.uleb128 0x10
	.string	"b"
	.byte	0x1e
	.long	0x236
	.uleb128 0x3
	.byte	0x91
	.sleb128 -192
	.uleb128 0x6
	.long	.LASF32
	.long	0x35
	.long	0x33a
	.uleb128 0x7
	.long	0xb2
	.byte	0
	.uleb128 0x9
	.long	.LASF34
	.byte	0x38
	.long	0x327
	.uleb128 0x3
	.byte	0x91
	.sleb128 -112
	.uleb128 0x6
	.long	.LASF35
	.long	0x35
	.long	0x35b
	.uleb128 0x7
	.long	0xb2
	.byte	0
	.uleb128 0x9
	.long	.LASF36
	.byte	0x39
	.long	0x348
	.uleb128 0x3
	.byte	0x91
	.sleb128 -176
	.uleb128 0x8
	.quad	.LBB4
	.quad	.LBE4-.LBB4
	.uleb128 0x1c
	.string	"i"
	.byte	0x1
	.byte	0x3b
	.byte	0xb
	.long	0xb2
	.uleb128 0x2
	.byte	0x91
	.sleb128 -36
	.byte	0
	.byte	0
	.uleb128 0xf
	.long	.LASF37
	.byte	0x2a
	.long	0x154
	.quad	.LFB3
	.quad	.LFE3-.LFB3
	.uleb128 0x1
	.byte	0x9c
	.long	0x3b9
	.uleb128 0x1
	.long	.LASF24
	.byte	0x1
	.byte	0x2a
	.byte	0x17
	.long	0x71
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.byte	0
	.uleb128 0x1d
	.long	.LASF46
	.byte	0x1
	.byte	0x20
	.byte	0x4
	.long	0x154
	.quad	.LFB2
	.quad	.LFE2-.LFB2
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x1
	.long	.LASF24
	.byte	0x1
	.byte	0x20
	.byte	0x1a
	.long	0x6c
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
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
	.uleb128 0xb
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
	.uleb128 0x26
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x34
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x3
	.uleb128 0x28
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1c
	.uleb128 0xb
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
	.uleb128 0xd
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
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x6
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
	.uleb128 0x7
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x22
	.uleb128 0x21
	.sleb128 0
	.uleb128 0x2f
	.uleb128 0x21
	.sleb128 63
	.byte	0
	.byte	0
	.uleb128 0x8
	.uleb128 0xb
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.byte	0
	.byte	0
	.uleb128 0x9
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
	.uleb128 0xa
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
	.uleb128 0xd
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
	.uleb128 0xe
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
	.uleb128 0xf
	.uleb128 0x2e
	.byte	0x1
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
	.uleb128 0x10
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0x21
	.sleb128 1
	.uleb128 0x3b
	.uleb128 0x21
	.sleb128 53
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x11
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
	.uleb128 0x12
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
	.uleb128 0x13
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
	.uleb128 0x14
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
	.uleb128 0x15
	.uleb128 0x4
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x16
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x39
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x17
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
	.uleb128 0x18
	.uleb128 0x2e
	.byte	0x1
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
	.uleb128 0x19
	.uleb128 0x10
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1a
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
	.uleb128 0x1b
	.uleb128 0x2e
	.byte	0x1
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
	.uleb128 0x7a
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1c
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
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
	.uleb128 0x1d
	.uleb128 0x2e
	.byte	0x1
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
	.uleb128 0x7a
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
.LASF8:
	.string	"lthing_types__verified"
.LASF26:
	.string	"public_key"
.LASF14:
	.string	"lthing_types__signature_invalid"
.LASF30:
	.string	"lthing_judicial__verify_signature"
.LASF6:
	.string	"lthing_types__byte_array"
.LASF43:
	.string	"lthing_judicial__judicial_doctype"
.LASF19:
	.string	"lthing_types__byte_array___XUA"
.LASF7:
	.string	"lthing_types__byte_array___XUB"
.LASF16:
	.string	"status"
.LASF22:
	.string	"interfaces__c__TintB"
.LASF10:
	.string	"lthing_types__bad_magic"
.LASF12:
	.string	"lthing_types__seal_mismatch"
.LASF42:
	.string	"lthing_types__verified_record"
.LASF32:
	.string	"lthing_judicial__digest_equal__Ta_arrS"
.LASF37:
	.string	"lthing_judicial__magic_ok"
.LASF34:
	.string	"a_arr"
.LASF24:
	.string	"document"
.LASF41:
	.string	"lthing_types__verify_status"
.LASF13:
	.string	"lthing_types__chain_broken"
.LASF45:
	.string	"lthing_judicial__parse_unverified___wrapped_statements"
.LASF9:
	.string	"lthing_types__bad_envelope"
.LASF4:
	.string	"interfaces__unsigned_8"
.LASF3:
	.string	"P_BOUNDS"
.LASF36:
	.string	"b_arr"
.LASF29:
	.string	"lthing_judicial__parse_unverified"
.LASF38:
	.string	"GNU Ada 14.1.0 -O0 -gnatA -g -gnatwa -gnata -gnatR2js -gnatws -gnatec=/tmp/GPR.2766/GNAT-TEMP-000003.TMP -gnatem=/tmp/GPR.2766/GNAT-TEMP-000004.TMP -mtune=generic -march=x86-64"
.LASF18:
	.string	"boolean"
.LASF27:
	.string	"result"
.LASF11:
	.string	"lthing_types__bad_length"
.LASF17:
	.string	"trusted"
.LASF35:
	.string	"lthing_judicial__digest_equal__Tb_arrS"
.LASF23:
	.string	"universal_integer"
.LASF25:
	.string	"previous_seal"
.LASF40:
	.string	"lthing_types__index_range"
.LASF28:
	.string	"lthing_judicial__parse_and_verify"
.LASF21:
	.string	"interfaces__c__unsigned"
.LASF39:
	.string	"lthing_types__byte"
.LASF5:
	.string	"integer"
.LASF20:
	.string	"lthing_types__digest"
.LASF46:
	.string	"lthing_judicial__envelope_ok"
.LASF44:
	.string	"lthing_judicial__parse_and_verify___wrapped_statements"
.LASF33:
	.string	"recomputed_chain"
.LASF31:
	.string	"lthing_judicial__digest_equal"
.LASF15:
	.string	"lthing_types__not_verified"
.LASF2:
	.string	"P_ARRAY"
	.section	.debug_line_str,"MS",@progbits,1
.LASF0:
	.string	"/home/claude/lthing-spark/src/lthing_judicial.adb"
.LASF1:
	.string	"/home/claude/lthing-spark/obj/gnatprove/data_representation"
	.ident	"GCC: (GNU) 14.1.0"
	.section	.note.GNU-stack,"",@progbits
