.org 00h				; power up and reset vector
	ljmp start			; when the micro wakes up, jump to the beginning of
						; the main body or loop in the program, called "start"
.org 100h				; and located at address location 100h in external mem
start: 
	lcall init			; Start the serial port by calling subroutine "init".
	loop:				; Now, endlessly repeat a loop
		lcall getnum 	; Get the first number
		push acc
		mov acc, R0		; Put the first number into the acc
		mov R1, acc		; Put the first number into R1
		pop acc
		lcall getnum 	; Get the second number
		push acc
		mov acc, R0		; Put the second number into the acc
		mov R2, acc		; Put the second number into R2
		pop acc
		lcall getsymbol	; Get the + or -
		lcall crlf		; Call carriage return/line feed segment
		lcall crlf		; Call carriage return/line feed segment again
	sjmp loop
	
init:
; set up serial port with a 11.0592 MHz crystal,
; use timer 1 for 9600 baud serial communications	
	mov tmod, #20h		; set timer 1 for auto reload - mode 2
	mov tcon, #40h		; run timer 1
	mov th1,  #0FDh		; set 9600 baud with xtal=11.059Mhz
	mov scon, #50h		; set serial control reg for 8 bit data
						; and mode 100h
	setb P3.4			; sets output enable high (active low)
	mov P1, #00h		; Clear the LED bank
	ret
	
getchr:
; This routine "gets" or receives a character from the PC, transmitted over
; the serial port. RI is the same as SCON.0 - the assembler recognizes
; either shorthand. The 7-bit ASCII code is returned in the accumulator.

	jnb ri, getchr		; wait till character received
	mov a, sbuf			; get character and put it in the accumulator
	anl a, #7fh			; mask off 8th bit
	clr ri
	ret
	
sndchr:
; This routine "sends" or transmits a character to the PC, using the serial
; port. The character to be sent is stored in the accumulator. SCON.1 and 
; TI are the same as far as the assembler is concerned.

	clr scon.1			; clear the ti complete flag
	mov sbuf, a			; move a character from acc to the sbuf
txloop:
	jnb scon.1, txloop	; wait till chr is sent
	ret
	
crlf:
; This routine sends a linefeed and a carriage return when called.

	push acc			; push the old accumulator value
	mov a, #0Ah			; Move linefeed character to accumulator
	lcall sndchr		; Send linefeed character
	mov a, #0Dh			; Move carriage return character to accumulator
	lcall sndchr		; Send carriage return character
	pop acc				; pop the old accumulator value
	ret

getnibble:
; This function gets a nibble from the keypad

	push acc			; push the old accumulator value
	mov P1, #0FFh		; puts P1 in read mode
	clr P3.4			; lower output enable (active low)
	checkdata:
		mov acc, P1		; move in values
		anl acc, #80h	; mask all but data available
		cjne a, #80h, checkdata 	; loop if data isn't available yet
	mov acc, P1			; since data is available, put P1 in acc
	setb P3.4			; sets output enable off (active low)
	anl acc, #0Fh		; mask all but the 4 data bits
	lcall keytab		; uses the table to convert the nibble to its real value
	mov R0, a			; return the value of the number
	mov P1, R0
	add a, #30h			; add value to the acc so it becomes an ASCII number
	lcall sndchr		; Send carriage return character
	
	mov R5, #00h
	mov R4, #00h
	loopa:				; loop to deal with multiple key presses
		djnz R5, loopa
		djnz R4, loopa	
	
	pop acc				; pop the old accumulator value
	ret

getnum:
; This routine gets the three characters from the keypad

	push acc		; push the accumulator to save its value
	
	lcall getnibble	; get the first nibble and send to the PC
	mov acc, R0		; puts the numerical result in the acc
	mov b, #64h		; Puts decimal 100 in register b
	mul ab			; Multiplies the first numeral by 100 since it is in the 100s place
	mov R3, a		; Moves the lowest byte result into R3
	
	lcall getnibble	; get the second nibble and send to the PC
	mov acc, R0		; puts the numerical result in the acc
	mov b, #0Ah		; Puts decimal 10 in register b
	mul ab			; Multiplies the first numeral by 10 since it is in the 10s place
	add a, R3		; Adds this numeral with the previous numeral
	mov R3, a		; Moves the lowest byte result into R3
	
	lcall getnibble	; get the second nibble and send to the PC
	mov acc, R0
	add a, R3		; Adds this numeral with the previous two numerals
	mov R0, acc		; Moves the result into R0
	lcall crlf		; Call carriage return/line feed segment
	
	;mov P1, R0		; pushes to LED bank for debugging
	
	pop acc			; pop the old accumulator value
	ret	
	
dispnum:
; This routine displays the result of the calculation on the screen
	mov b, #64h				; put 100 in the b reg
	div ab					; the result is already in the accumulator
	add a, #30h				; mask the result back to ASCII
	lcall sndchr			; send the first numeral
	mov a, b				; move the remainer from b to acc
	mov b, #0Ah				; move 10 into b
	div ab
	add a, #30h				; mask the result back to ASCII
	lcall sndchr			; send the second numeral
	mov a, b				; move the remainer from b to acc
	add a, #30h				; mask the result back to ASCII
	lcall sndchr			; send the third numeral
	ret

keytab:
; This subroutine takes the nibble from the keypad and converts it to the value	

	inc a
	movc a, @a+pc
	ret
	.db 01h, 02h, 03h, 0Ah, 04h, 05h, 06h, 0Bh, 07h, 08h, 09h, 0Ch, 0Eh, 00h, 0Fh, 0Dh
	
getsymbol:
; This routine gets the + or - from the user		

	push acc				; push the old accumulator value
	lcall getchr			; <- gets symbol from the PC keyboard
	cjne a, #02Bh, notadd	; if the symbol is not +, jump
	lcall sndchr			; print +	
	lcall crlf				; Call carriage return/line feed segment
	lcall addnums			; add the numbers
	pop acc					; pop the old accumulator value
	ret
	
	notadd:					; jumps to here if it isn't a + symbol
	cjne a, #02Dh, getsymbol	; if the symbol isn't a - either, return to beginning of subroutine
	lcall sndchr			; print -
	lcall crlf				; Call carriage return/line feed segment
	lcall subnums			; subtract the numbers
	pop acc					; pop the old accumulator value
	ret	
	
addnums:
; This routine adds the numbers in R1 and R2
	push acc				; pushes the old accumulator value
	mov acc, R1				; moves R1 into accumulator so we can use add
	add a, R2				; add R1 and R2
	mov P1, a				; move the result into the LED bank
	lcall dispnum			; display the result on the screen
	pop acc					; pop the old accumulator value
	ret

subnums:
; This routine subtracts the number in R2 from the number in R1
	push acc				; pushes the old accumulator value
	mov acc, R1				; moves R1 into accumulator so we can use add
	subb a, R2				; subtract R2 from R1
	mov P1, a				; move the result into the LED bank
	lcall dispnum			; display the result on the screen
	pop acc					; pop the old accumulator value
	ret	
	