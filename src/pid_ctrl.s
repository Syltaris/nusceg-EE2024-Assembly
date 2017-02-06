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
	LDR R2, =sn
	LDR R3, =enOld

	LDR R4, [R2]
	LDR R5, [R3]

	@if st != 1, initialise regs
	CMP R1, #1
	IT NE
	BNE check_sn

init_reg:
	MOV R4, #0 @ sn
	MOV R5, #0 @ enOld

check_sn:
	ADD R4, R4, R0 @ sn = sn + en

	LDR R1, =sn_hi_limit
	CMP R4, R1 @ if sn > 9
	IT GE
	MOVGE R4, R1 @ sn = 9

	LDR R1, =sn_lo_limit
	CMP R4, R1 @ if sn < -9
	IT LE
	MOVLE R4, R1 @ sn = -9

compute_en:
	LDR R10, =KD
	SUB R5, R0, R5 @ R5 = en - enOld
	MUL R5, R10, R5 @ R5 = KD * R5
	STR R0, [R3] @ save enOld @ enOld = en

	LDR R10, =KI
	STR R4, [R2] @ save sn
	MLA R4, R10, R4, R5 @ R4 = KI * sn + KD * R5

	LDR R10, =KP
	MLA R0, R10, R0, R4 @ R0 = KP * en + R4

	@LSR R0, R0, 3 @ divide un by 8
	MOV R4, 20
	SDIV R0, R4

save_reg:

 	BX LR @ return to calling C fn
