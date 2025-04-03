	.section .data
	.p2align 2
	.global hash_result      @ Make symbol globally visible
hash_result:      .word 0    @ Reserve space for storing the hash result
	
	.section .text
	.global hash
	.p2align 2
	.type hash,%function
		
	hash:
		.fnstart
		@Prologue
		PUSH	{R4-R11, LR} @ Save R4-R11 registers and link register (AAPCS)
		
		//Hash logic
		
		//{a} Init hash value to length of string
		MOV		R1, #0		 @ Init R1 to 0 for 0 length
		MOV		R3, R0 		 @ Save R0 (pointer to string) to R3
		
	loop1:
		LDRB	R2, [R3], #1 @ Load byte from string (R3) and advance pointer by 1
		CBZ		R2, done1  	 @ Compare character to null byte ('/0' string terminator) and branch out
		ADD		R1, R1, #1	 @ Increment length by 1
		B 		loop1
		
	done1: 					 @ R1 holds the string length
		
		//{b}
		LDR		R5, =digit_table @ Load address of lookup table

		MOV 	R3, R0 		 @ Load R0 (pointer to string) to R3
	loop2:
		LDRB	R2, [R3], #1 @ Load byte from string (R3), advance pointer by 1
		CBZ 	R2, done2 	 @ Branch out on null byte
		
		CMP 	R2, #0x30 	 @ Check if R2 < '0' (0x30)
		BLO		loop2		 @ Ignore non-alphanumeric
		CMP	 	R2, #0x39  	 @ Check if R2 <= '9' (0x39)
		BLS 	hash_digit	 @ between '0' - '9'
		
		CMP 	R2, #0x41	 @ Check if R2 < 'A' (0x41)
		BLO 	loop2 		 @ Ignore non-alphanumeric
		CMP 	R2, #0x5A 	 @ Check if R2 <= 'Z' (0x5A)
		BLS 	hash_upper	 @ between 'A' - 'Z'
		
		CMP 	R2, #0x61 	 @ Check if R2 < 'a'
		BLO 	loop2		 @ Ignore non-alphanumeric
		CMP 	R2, #0x7A 	 @ Check if R2 <= 'z'
		BLS		hash_lower	 @ between 'a' - 'z'
		B 		loop2
		
	hash_upper:	
		LSL 	R4, R2, #1	 @ Multiply by 2 using left shift
		ADD 	R1, R1, R4	 @ Add value to hash
		B 		loop2

	hash_digit:
		SUB 	R4, R2, 0x30 @ Calculate table index (ASCII - '0')
		LDRB	R6, [R5, R4] @ Load lookup value
		ADD 	R1, R1, R6 	 @ Add value to hash
		B 		loop2
		
	hash_lower:		
		SUB 	R4, R2, #0x61  @ Compute (char - 'a')
		MLA 	R1, R4, R4, R1 @ R1 += R4 * R4
		B 		loop2
		
	done2: 					 @ R1 holds the hash value
	
		MOV 	R0, R1		 @ Move hash value to R0 to be returned
		LDR R2, =hash_result @ Load global hash address first
		STR R0, [R2]         @ Then store to it
		@Epilogue
		POP		{R4-R11, PC}   @ Restore R4-R11 registers and link register straight to the PC
		
	.section .rodata
	.p2align 2
	digit_table:
		.byte 5, 12, 7, 6, 4, 11, 6, 3, 10, 23  @ Values corresponding to '0'-'9'

		.fnend
