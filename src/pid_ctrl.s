 	.syntax unified
 	.cpu cortex-m3
 	.thumb
 	.align 2
 	.global	pid_ctrl
 	.thumb_func
@  EE2024 Assignment 1: pid_ctrl(int en, int st) assembly language function
@  CK Tham, ECE, NUS, 2017
.equ KP, 5
.equ KI, 2
.equ KD, 16

.equ sn_hi_limit, 9500000
.equ sn_lo_limit, -9500000

.lcomm sn 4
.lcomm enOld 4

pid_ctrl:
	PUSH {R2-R5}

	LDR R2, =sn
	LDR R3, =enOld

	LDR R4, [R2]
	LDR R5, [R3]

	LDR R8, =sn_lo_limit
	LDR R9, =sn_hi_limit

	@if st != 1, initialise regs
	CMP R1, #1
	IT NE
	BNE check_sn

init_reg:
	MOV R4, #0 @ sn
	MOV R5, #0 @ enOld

check_sn:
	ADD R4, R4, R0 @ sn = snOld + en

	CMP R4, R8 @ if sn < -9500000
	IT LE
	MOVLE R4, R8 @ sn = -9500000

	CMP R4, R9 @ if sn > 9500000
	IT GE
	MOVGE R4, R9 @ sn = 9500000

compute_en:
	STR R4, [R2]
	STR R0, [R3]

	MOV R3, #8
	SUB R5, R0, R5 @ en - enOld
	MUL R5, R5, R3 @ sn + 8(en - enOld)

	ADD R2, R4, R5 @ sn + 8(en - enold)

	MOV R3, #2
	MUL R2, R3 @ Ki(sn + 8(en - enOld))

	MOV R3, #5
	MLA R0, R0, R3, R2 @ Kp(en) + Ki(sn + 8(en - enOld))

	MOV R3, #20
	SDIV R0, R3

	POP {R2-R5}

 	BX LR @ return to calling C fn
