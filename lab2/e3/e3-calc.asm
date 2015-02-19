.org 8000h				; power up and reset vector			
start: 
	lcall init			; Set up the registers with data from memory
	lcall addnums 		; Add the numbers
	lcall subnums		; Subtract the numbers
	lcall mulnums		; Multiple the numbers
	lcall divnums		; Divide the numbers
	ret
	
init:
; Pull values from memory and clear LED bank for debugging
	push dpl				; push data pointer
	push dph				; push data pointer
	mov P1, #00h			; Clear the LED bank
	mov dpl, #00h			; put lsb in dptr
	mov dph, #90h			; put msb in dptr
	movx a, @dptr			; gets first number from memory location 9000h
	mov R1, acc				; puts first number in R1
	inc dptr				; increment address in dptr
	movx a, @dptr			; gets second number from memory location 9001h
	mov R2, acc				; puts second number in R2
	pop dph					; pop data pointer
	pop dpl					; pop data pointer
	ret
	
addnums:
; This routine adds the numbers in R1 and R2
	push acc				; pushes the old accumulator value
	push dpl				; push data pointer
	push dph				; push data pointer
	mov acc, R1				; moves R1 into accumulator so we can use add
	add a, R2				; add R1 and R2
	mov dpl, #02h			; push lsb into data pointer
	mov dph, #90h			; push msb into data pointer
	movx @dptr, a			; move the sum into the next memory location
	pop dph					; pop data pointer
	pop dpl					; pop data pointer
	pop acc					; pop the old accumulator value
	ret

subnums:
; This routine subtracts the number in R2 from the number in R1
	push acc				; pushes the old accumulator value
	push dpl				; push data pointer
	push dph				; push data pointer
	mov acc, R1				; moves R1 into accumulator so we can use add
	subb a, R2				; subtract R2 from R1
	mov dpl, #03h			; push lsb into data pointer
	mov dph, #90h			; push msb into data pointer
	movx @dptr, a			; move the result into the next memory location
	pop dph					; pop data pointer
	pop dpl					; pop data pointer
	pop acc					; pop the old accumulator value
	ret	
	
mulnums:
; This routine multiplies the numbers in R1 and R2
	push acc				; push acc
	push b					; push b because we use it here too
	push dpl				; push data pointer
	push dph				; push data pointer
	mov acc, R1				; move R1 into acc
	mov b, R2				; move R2 into b
	mul ab					; multiply R1 and R2
	mov dpl, #04h			; push lsb into data pointer
	mov dph, #90h			; push msb into data pointer
	movx @dptr, a			; move the result into the next memory location
	inc dptr				; increment address in dptr
	mov a, b				; move b into a
	movx @dptr, a			; move the result into the next memory location
	pop dph					; pop data pointer
	pop dpl					; pop data pointer
	pop b					; pop b
	pop acc					; pop acc
	ret

divnums:
; This routine divides the numbers in R1 and R2
	push acc				; push acc
	push b					; push b because we use it here too
	push dpl				; push data pointer
	push dph				; push data pointer
	mov acc, R1				; move R1 into acc
	mov b, R2				; move R2 into b
	div ab					; divide R1 by R2
	mov dpl, #06h			; push lsb into data pointer
	mov dph, #90h			; push msb into data pointer
	movx @dptr, a			; move the result into the next memory location
	inc dptr				; increment address in dptr
	mov a, b				; move b into a
	movx @dptr, a			; move the result into the next memory location
	pop dph					; pop data pointer
	pop dpl					; pop data pointer
	pop b					; pop b
	pop acc					; pop acc
	ret	
