	.file	"lthing_types.ads"
	.text
.Ltext0:
	.file 0 "/home/claude/lthing-spark/obj/gnatprove/data_representation" "/home/claude/lthing-spark/src/lthing_types.ads"
	.align 2
	.globl	lthing_types__verify_statusH
	.type	lthing_types__verify_statusH, @function
lthing_types__verify_statusH:
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
	movq	-8(%rbp), %rax
	movl	(%rax), %eax
	movq	-8(%rbp), %rdx
	movl	4(%rdx), %edx
	cmpl	%eax, %edx
	jl	.L2
	movl	%edx, %ecx
	subl	%eax, %ecx
	leal	1(%rcx), %r11d
	jmp	.L3
.L2:
	movl	$0, %r11d
.L3:
	movslq	%eax, %r9
	cmpl	%eax, %edx
	cmpl	%eax, %edx
	cmpl	%eax, %edx
	leal	-1(%rax), %r10d
	movl	$0, %esi
	movl	$0, %ecx
	movl	$0, %eax
.L11:
	testl	%eax, %eax
	jg	.L10
	movslq	%eax, %rdx
	movl	verify_statusP.3(,%rdx,4), %edx
	cmpl	%edx, %r11d
	jl	.L10
	movq	-16(%rbp), %rdx
	movslq	%eax, %rdi
	movl	verify_statusP.3(,%rdi,4), %edi
	addl	%r10d, %edi
	movslq	%edi, %rdi
	subq	%r9, %rdi
	movzbl	(%rdx,%rdi), %edx
	movzbl	%dl, %r8d
	movslq	%eax, %rdx
	movzbl	verify_statusT1.2(%rdx), %edx
	movzbl	%dl, %edx
	imull	%r8d, %edx
	leal	(%rsi,%rdx), %edi
	movslq	%edi, %rdx
	imulq	$715827883, %rdx, %rdx
	shrq	$32, %rdx
	movl	%edx, %esi
	sarl	$2, %esi
	movl	%edi, %edx
	sarl	$31, %edx
	subl	%edx, %esi
	movl	%esi, %edx
	addl	%edx, %edx
	addl	%esi, %edx
	sall	$3, %edx
	movl	%edi, %esi
	subl	%edx, %esi
	movslq	%eax, %rdx
	movzbl	verify_statusT2.1(%rdx), %edx
	movzbl	%dl, %edx
	imull	%r8d, %edx
	leal	(%rcx,%rdx), %edi
	movslq	%edi, %rdx
	imulq	$715827883, %rdx, %rdx
	shrq	$32, %rdx
	movl	%edx, %ecx
	sarl	$2, %ecx
	movl	%edi, %edx
	sarl	$31, %edx
	subl	%edx, %ecx
	movl	%ecx, %edx
	addl	%edx, %edx
	addl	%ecx, %edx
	sall	$3, %edx
	movl	%edi, %ecx
	subl	%edx, %ecx
	addl	$1, %eax
	jmp	.L11
.L10:
	movslq	%esi, %rax
	movzbl	verify_statusG.0(%rax), %edx
	movslq	%ecx, %rax
	movzbl	verify_statusG.0(%rax), %eax
	addl	%edx, %eax
	movzbl	%al, %eax
	andl	$7, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	lthing_types__verify_statusH, .-lthing_types__verify_statusH
	.align 2
	.globl	lthing_types__byte_arrayIP
	.type	lthing_types__byte_arrayIP, @function
lthing_types__byte_arrayIP:
.LFB2:
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
.LFE2:
	.size	lthing_types__byte_arrayIP, .-lthing_types__byte_arrayIP
	.align 2
	.globl	lthing_types__TdigestBIP
	.type	lthing_types__TdigestBIP, @function
lthing_types__TdigestBIP:
.LFB3:
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
.LFE3:
	.size	lthing_types__TdigestBIP, .-lthing_types__TdigestBIP
	.align 2
	.globl	lthing_types__verified_recordIP
	.type	lthing_types__verified_recordIP, @function
lthing_types__verified_recordIP:
.LFB4:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movb	$7, -2(%rbp)
	movb	$0, -1(%rbp)
	movzwl	-2(%rbp), %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
	.size	lthing_types__verified_recordIP, .-lthing_types__verified_recordIP
	.align 2
	.globl	lthing_types__verified_recordPredicate
	.type	lthing_types__verified_recordPredicate, @function
lthing_types__verified_recordPredicate:
.LFB5:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movw	%di, -2(%rbp)
	movzbl	-1(%rbp), %edx
	movzbl	-2(%rbp), %eax
	testb	%al, %al
	sete	%al
	cmpb	%al, %dl
	sete	%al
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	lthing_types__verified_recordPredicate, .-lthing_types__verified_recordPredicate
	.globl	lthing_types_E
	.data
	.align 2
	.type	lthing_types_E, @object
	.size	lthing_types_E, 2
lthing_types_E:
	.zero	2
	.globl	lthing_types__verify_statusS
	.section	.rodata
	.align 32
	.type	lthing_types__verify_statusS, @object
	.size	lthing_types__verify_statusS, 93
lthing_types__verify_statusS:
	.ascii	"VERIFIEDBAD_ENVELOPEBAD_MAGICBAD_LENGTHSEAL_MISMATCHCHAIN_BR"
	.ascii	"OKENSIGNATURE_INVALIDNOT_VERIFIED"
	.globl	lthing_types__verify_statusN
	.align 16
	.type	lthing_types__verify_statusN, @object
	.size	lthing_types__verify_statusN, 16
lthing_types__verify_statusN:
	.byte	1
	.byte	9
	.byte	21
	.byte	30
	.byte	40
	.byte	53
	.byte	65
	.byte	82
	.byte	94
	.zero	7
	.align 4
	.type	verify_statusP.3, @object
	.size	verify_statusP.3, 4
verify_statusP.3:
	.long	5
	.type	verify_statusT1.2, @object
	.size	verify_statusT1.2, 1
verify_statusT1.2:
	.byte	7
	.type	verify_statusT2.1, @object
	.size	verify_statusT2.1, 1
verify_statusT2.1:
	.byte	9
	.align 16
	.type	verify_statusG.0, @object
	.size	verify_statusG.0, 24
verify_statusG.0:
	.byte	0
	.byte	0
	.byte	7
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	1
	.byte	3
	.byte	0
	.byte	0
	.byte	0
	.byte	0
	.byte	4
	.byte	5
	.byte	0
	.byte	0
	.byte	1
	.byte	0
	.byte	6
	.text
.Letext0:
	.file 1 "/home/claude/lthing-spark/src/lthing_types.ads"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0x4c
	.value	0x5
	.byte	0x1
	.byte	0x8
	.long	.Ldebug_abbrev0
	.uleb128 0x2
	.long	.LASF5
	.byte	0xd
	.long	.LASF0
	.long	.LASF1
	.long	.Ldebug_line0
	.uleb128 0x1
	.byte	0x1
	.byte	0x7
	.long	.LASF2
	.uleb128 0x1
	.byte	0x4
	.byte	0x5
	.long	.LASF3
	.uleb128 0x1
	.byte	0x1
	.byte	0x2
	.long	.LASF4
	.uleb128 0x3
	.long	.LASF6
	.byte	0x1
	.byte	0x18
	.byte	0x4
	.long	0x4a
	.long	0x100000
	.uleb128 0x4
	.byte	0x10
	.byte	0x5
	.long	.LASF7
	.uleb128 0x5
	.long	0x43
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.uleb128 0x1
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
	.uleb128 0x2
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
	.uleb128 0x10
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x3
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
	.uleb128 0x4
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x34
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x5
	.uleb128 0x26
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x34
	.uleb128 0x19
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_aranges,"",@progbits
	.long	0x1c
	.value	0x2
	.long	.Ldebug_info0
	.byte	0x8
	.byte	0
	.value	0
	.value	0
	.quad	0
	.quad	0
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
.LASF2:
	.string	"interfaces__unsigned_8"
.LASF6:
	.string	"lthing_types__max_document_bytes"
.LASF7:
	.string	"universal_integer"
.LASF3:
	.string	"integer"
.LASF4:
	.string	"boolean"
.LASF5:
	.string	"GNU Ada 14.1.0 -O0 -gnatA -g -gnatwa -gnata -gnatR2js -gnatws -gnatec=/tmp/GPR.2205/GNAT-TEMP-000003.TMP -gnatem=/tmp/GPR.2205/GNAT-TEMP-000004.TMP -mtune=generic -march=x86-64"
	.section	.debug_line_str,"MS",@progbits,1
.LASF0:
	.string	"/home/claude/lthing-spark/src/lthing_types.ads"
.LASF1:
	.string	"/home/claude/lthing-spark/obj/gnatprove/data_representation"
	.ident	"GCC: (GNU) 14.1.0"
	.section	.note.GNU-stack,"",@progbits
