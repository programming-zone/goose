struc proc
	.id:			resq	1
	.phys:			resq	1
	.rsp:			resq	1
	.rip:			resq	1
	.rax:			resq	1
	.rbx:			resq	1
	.flags:			resq	1
	.syscall_len:	resq	1
	.syscalls:		resq	80
endstruc

current_proc equ 0x7FFFFFFFF000