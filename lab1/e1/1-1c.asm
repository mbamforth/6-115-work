clr a			; clear the accumulator
setb acc.0		; set the LSB of the accumulator
mov P1, a		; move the value from the accumulator to P1
loop:
	sjmp loop	; loop so the program doesn't run junk from memory
	