.org 00h				; power up and reset vector
	ljmp start			; when the micro wakes up, jump to the beginning of
						; the main body or loop in the program, called "start"
.org 100h				; and located at address location 100h in external mem
start: 
	lcall init			; Start the serial port by calling subroutine "init".
	loop:				; Now, endlessly repeat a loop that
		lcall getchr	; <- gets a character from the PC keyboard
		mov P1, a		; move most recent character to LED bank
		lcall crlf		; call carriage return/line feed segment
		lcall sndchr	; -> and then echoes the character to the PC screen
	sjmp loop
	
init:
; set up serial port with a 11.0592 MHz crystal,
; use timer 1 for 9600 baud serial communications
	mov tmod, #20h		; set timer 1 for auto reload - mode 2
	mov tcon, #40h		; run timer 1
	mov th1,  #0FDh		; set 9600 baud with xtal=11.059Mhz
	mov scon, #50h		; set serial control reg for 8 bit data
						; and mode 100h
	mov b, #41h			; put 65 decimal in register b for cr/lf segment
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
; This routine counts the number of characters so that line feeds and 
; carriage returns can be implemented.

	djnz b, jumphere	; If b != 0, jump forward, otherwise do a cr/lf
	mov a, #0Ah			; Move linefeed character to accumulator
	lcall sndchr		; Send linefeed character
	mov a, #0Dh			; Move carriage return character to accumulator
	lcall sndchr		; Send carriage return character
	mov b, #41h			; Reset register b with 65 decimal
	
jumphere:	
	ret
	