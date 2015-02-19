start:
	mov P1, #11h		; light two of the lights, four lights apart
	mov R1, #00h		; set r1 to zero
	mov R2, #00h		; set r2 to zero
first:
	djnz R1, first		; use this line and the next to loop here to delay
	djnz R2, first		;   the changes in the lights

mov P1, #22h			; move which two lights are lit
mov R1, #00h			; reset r1 to zero
mov R2, #00h			; reset r2 to zero
second:
	djnz R1, second		; use this line and the next to loop here to delay
	djnz R2, second		;   the changes in the lights

mov P1, #44h			; move which two lights are lit
mov R1, #00h			; reset r1 to zero
mov R2, #00h			; reset r2 to zero
third:
	djnz R1, third		; use this line and the next to loop here to delay
	djnz R2, third		;   the changes in the lights	
	
mov P1, #88h			; move which two lights are lit
mov R1, #00h			; reset r1 to zero
mov R2, #00h			; reset r2 to zero
fourth:
	djnz R1, fourth		; use this line and the next to loop here to delay
	djnz R2, fourth		;   the changes in the lights	
	
ljmp start				; go back to the beginning
	