.org 00h				; power up and reset vector
	ljmp start			; when the micro wakes up, jump to the beginning of
						; the main body or loop in the program, called "start"
.org 100h				; and located at address location 100h in external mem
start: 
	lcall init			; Start the serial port by calling subroutine "init".
	loop:				; Now, endlessly repeat a loop
		lcall getnibble	; Gets the next nibble from the keypad
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
	;mov acc, P1			; puts P1 in read mode
	mov P1, #0FFh
	clr P3.4			; lower output enable (active low)
	checkdata:
		mov acc, P1		; move in values
		anl acc, #80h	; mask all but data available
		cjne a, #80h, checkdata 	; loop if data isn't available yet
	mov acc, P1			; since data is available, put P1 in acc
	setb P3.4			; sets output enable off (active low)
	mov P1, acc			; displays the whole byte on the LED bank
	anl acc, #0Fh		; mask all but the 4 data bits
	lcall keytab		; uses the table to convert the nibble to its real value
	add a, #30h			; add value to the acc so it becomes an ASCII number
	lcall sndchr		; Send carriage return character
	
	pop acc				; pop the old accumulator value
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
	.db 01h, 02h, 03h, 0Ah, 04h, 05h, 06h, 0Bh
	.db 07h, 08h, 09h, 0Ch, 0Eh, 00h, 0Fh, 0Dh
	