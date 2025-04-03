	.extern hash_result		@ Global hash variable declared elsewhere
	
	.section .text
	.global modhash
	.p2align 2
	.type modhash,%function
		
	modhash:
		.fnstart
		@Prologue
		PUSH	{R4-R11, LR} @ Save R4-R11 registers and link register
			
		CMP		R1, #0xA 	 @ Check if R1 < 10
		BLO 	modhash_end		 @ Skip if single digit
			
		MOV R1, #0			 @ Init R1 (sum) to 0
	
	sum:
		MOV 	R3, 0xA		 @ Set R3 to 10 (UDIV and MLS do not support immediates)
		UDIV 	R2, R0, R3   @ Divide with R3 (10) to get rid of last digit 
		MLS 	R3, R2, R3, R0  @ R3 = R0 - (R2 * 10) Extract last digit
		ADD		R1, R1, R3	 @ Add last digit to sum
		MOV 	R0, R2		 @ Update R0 to R0 / 10
		CMP		R0, #0		 @ Check if (R0 = 0) any digits left
		BNE		sum			 @ Repeat if digit(s) left
		
		@ Apply mod7 to sum
		MOV 	R0, R1		 @ Move hash to R0
		
		MOV		R3, #7		 @ Set R3 to 7 (UDIV and MLS do not support immediates)
		UDIV	R2, R0, R3 	 @ R2 = R0 / 7
		MLS		R0, R2, R3, R0  @ R0 = R0 - (R2 * 7)	
	
	modhash_end:
		LDR R2, =hash_result @ Load global hash address first
		STR R0, [R2]         @ Then store to it
		
		@Epilogue
		POP		{R4-R11, PC} @ Restore R4-R11 and LR straight to PC
		.fnend