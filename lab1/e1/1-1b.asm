mov P1, #00h		; clear P1
mov P1, #80h		; turn on the MSB
loop:
	sjmp loop		; loop so the program doesn't run junk from the memory
	