begin:
	mov  a, #00h		; 74 00 - clear acc
	mov  P1, acc		; 85 E0 90 - move acc into P1
	setb 0x92			; D2 92
	sjmp begin			; 80 F7
	jnc  labtwo			; 50 61
	orl	 c, 0x74		; 72 74
	mov	 R1, #20h		; 79 20
	xrl  a, R7			; 6F
	
	xrl  a, R6			; 6E
	jb   0x69, labthree	; 20 69 6E
	jb   0x36, labone	; 20 36 2E
	acall labfour		; 31 31
	addc a, 0x21		; 35 21

.org 0x45
labone:
	
.org 0x6C
labtwo:

.org 0x82
labthree:

.org 0x131
labfour:	
