 	.syntax unified
 	.cpu cortex-m3
 	.thumb
 	.align 2
 	.global	pid_ctrl
 	.thumb_func
@  EE2024 Assignment 1: pid_ctrl(int en, int st) assembly language function
@  CK Tham, ECE, NUS, 2017
.equ KP, 2
.equ KI, 1
.equ KD, 6
.equ sn_hi_limit, 9500000
.equ sn_lo_limit, -9500000

.lcomm sn 4
.lcomm enOld 4

pid_ctrl:
@ if st argument == 1, don't pop
	LDR R2, =sn
	LDR R2, [R2]
	LDR R3, =enOld
	LDR R3, [R3]
	CMP R1, #1
	IT NE
	BNE check_sn

init_reg:
	MOV R2, #0 @ sn
	MOV R3, #0 @ enOld

check_sn:
	ADD R2, R2, R0 @ sn = sn + en
	LDR R4, =sn_hi_limit

	CMP R2, R4 @ if sn > 9
	IT GE
	MOVGE R2, R4 @ sn = 9

	LDR R4, =sn_lo_limit

	CMP R2, R4 @ if sn < -9
	IT LE
	MOVLE R2, R4 @ sn = -9

compute_en:
	LDR R10, =KD
	LDR R11, =KI
	LDR R12, =KP

	SUB R5, R0, R3 @ R5 = en - enOld
	MUL R6, R10, R5 @ R6 = KD * R5

	MUL R8, R11, R2 @ R8 = KI * sn

	MUL R9, R12, R0 @ R9 = KP * en

	MOV R3, R0 @ enOld = en
	ADD R0, R6, R8
	ADD R0, R0, R9
	LSR R0, R0, 3 @ divide un by 8

save_reg:
	LDR R4, =sn
	STR R2, [R4]
	LDR R4, =enOld
	STR R3, [R4]

 	BX LR @ return to calling C fn
