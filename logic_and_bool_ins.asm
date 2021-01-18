;// Author: Wikus Jansen van Rensburg
;// Date: January 18, 2020
;// Description: 
;//					-----------------------------------
;//						CONDITIONAL PROCESSING: 
;//            * CH 6.1: Logic and Boolean ins.
;//					-----------------------------------
;//	The idea is that we used the below named instructions to test for a condition.
;// After the ALU has performed the instruction, the processor flags are set resulting
;// what happend during the instruction. We then use the results stored in the status
;//	flags as conditions to perform the rest of our task.

;//	1. We first look at the various operators that set the processor flags.
;// 2. We look at the different types of conditional jump instructions.
;// 3. We look at the different types of conditional LOOP instructions.

.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

.data
;// Variables used to store data so that it can be viewed in main memory.
byte1 BYTE ?
.code
main PROC
;// 1. Instructions that set the processor flags.
;// =============================================
	;// a. AND: Performs a bitwize AND and stores the result in the dest operand.
	mov al, 10110011b
	mov ah, 00110100b
	AND	al, ah				;// al = 00 11 00 00b after operation. CY = 0, OV = 0

	;// We can use the AND instruction to convert lower case -> upper case letters.
	;// 'a' = 01 10 00 01b, 'A' = 01 00 00 01b. 
	mov al, 01100001b
	mov ah, 11011111b		;// We only wat to set bit-5 to zero and leave rest.
	AND al, ah				;// al = 01 00 00 01b, i.e. 'A'
	mov byte1, al
	;// b. OR is used when we want to SET specific bits in our bit-vector.
	;// c. NOT will switchs all the bits in the destination operand.
	mov al, 11001111b
	NOT al					;// al = 00 11 00 00b
	;// d. XOR performs an exclusive-or. That is false when operands have same truth 
	;//		truth value ( 1,1 ; 0,0) and true otherwize.
	mov al, 11001100b
	XOR al, 00111100b		;// al = 11 11 00 00b	
	;// e. TEST performs just like AND, excpet the value of the destination operand is
	;//		not changed, only the flags are set as if an AND instruction was used.
	mov al, 01010111b
	TEST al, 11001010b		;// al = 01 01 01 11, which is same as before instruction.

	;// Boolean instructions: <, <=, ==, >, => using CMP.
	;// CMP is an implied instruction that does destination - source without changeing
	;//		the value of destination. All it does is set the
	;//			Overflow, Carry, Sign, Zero, and Parity flags accordingly.
	;// Example 1
	mov al, 10
	cmp al, 15				;// Carry (CY) = 1 becuase 10 - 15 will cause unsigned overflow.
	;// Example 2
	mov ah, -23				;// in hexadecimal, E9
	cmp ah, 16				;// -23 -26. => sign (PL) = 1. 

		
		INVOKE ExitProcess,0
main ENDP
END main
