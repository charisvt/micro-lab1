	.section .data
	.p2align 2
	.global crc_result       @ Make symbol globally visible
crc_result:      .word 0     @ Reserve space for storing the crc result

	.section .text
	.global crc
	.p2align 2
	.type crc,%function
	
	crc:
		.fnstart
		@Prologue
		PUSH	{LR} 	 	 @ Save LR
		MOV		R1, #0	 	 @ Initialize checksum R1=0
		MOV		R2, R0	 	 @ Save pointer to string
	
	loop:
		LDRB	R3, [R2], #1 @ Load byte from string (R3) increment pointer by 1
		CBZ		R3, done	 @ Compare character to null byte ('/0' string terminator) and branch out
		EOR		R1, R1, R3	 @ XOR checksum with character
		B		loop
		
	done:
		MOV		R0, R1		 @ Store crc value to R0 to be returned
		LDR		R2, =crc_result @ Load global crc address
		STR		R2, [R0]		@ Save crc value
		@Epilogue
		POP		{PC}		 @ Restore LR to PC
			
		.fnend