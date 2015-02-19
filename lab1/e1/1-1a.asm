mov P1, #00h		; clear P1
mov P1, #01h		; turn on the LSB
loop:
	sjmp loop		; loop so that the program doesn't run junk in the memory
	