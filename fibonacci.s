	.section .bss
	.p2align 2
	.global fib_result
	fib_result: .word 0		@ Reserve 4 bytes (unitialized)

	.section .text
	.global fibonacci
	.p2align 2
	.type fibonacci,%function
	
	fibonacci:
		.fnstart
		@Prologue
		PUSH	{R4, R5, LR} @ Save R4, R5 and link register
		
		@Base cases
		CMP		R0, #0		 @ Check if n==0
		BEQ		return_zero
		CMP		R0, #1		 @ Check if n
		BEQ		return_one
		
		MOV		R4, R0		 @ Save n to R4
		
		@fib(n-1)
		SUB		R0, #1		 @ Calc n-1
		BL		fibonacci	 @ Call fib(n-1)
		MOV		R5, R0		 @ Save fib(n-1) to R5
		
		@fib(n-2)
		MOV		R0, R4		 @ Restore n to R0
		SUB		R0, #2		 @ Calc n-2
		BL		fibonacci	 @ Call fib(n-2)
		
		@ Accumulate results
		ADD		R0, R0, R5	 @ R0 = R5 [fib(n-1)] + R0 [fib(n-2)]

		@ Store result to fib_result
		LDR		R1, =fib_result @ Load address of fib_result
		STR		R0, [R1]	 @ Store result to fib_result

		@Epilogue
		POP		{R4, R5, PC}		 @ Restore R4, R5 and LR to PC 
		
	return_zero:
		MOV		R0, #0		 @ Return 0
		LDR		R1, =fib_result @ Also store 0 to fib_result
		STR		R0, [R1]
		POP		{R4, R5, PC} @ Restore R4, R5 and LR to PC
		
	return_one:
		MOV		R0, #1		 @ Return 1
		LDR		R1, =fib_result @ Also store 1 to fib_result
		STR		R0, [R1]
		POP		{R4, R5, PC} @ Restore R4, R5 and LR to PC
		.fnend