mov P1, #00h			; clear P1
mov P1, #0AAh			; puts a static alternating light pattern into P1
loop:
	sjmp loop			; loops so the program doesn't run junk from memory
	