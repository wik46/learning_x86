;// Author: Wikus Jansen van Rensburg
;// Date: January 14, 2021
;// Description: This .asm file is used to study basic operations.
;//					We study the following:
;//						1. Basic arithmetic and the change in the state of the 
;//							register flags.

.386		;// Tell the assembler this is x86 assembly lang.

.model flat, stdcall ;// This specifies the memory model used by processor.
.stack 4096;// Allocate 4096 bytes for the program's runtime stack.
ExitProcess Proto, dwExitCode:Dword		;// Defining a prototype for a windows 
								;// that will return power to the OS.
.data
op1 DWORD 10
op2 DWORD 20
op3 DWORD 30

large_num WORD 100h
.code
main PROC
;// -------------------------------------------------------------------------
;// Flags:
;// -------------------------------------------------------------------------
;// The status flags change according when an arithmatic operation caused
;// a particular result.

;// A. Carry flag (CY) and Overflow flag (OV).
;// Studying the carry flag: unsigned add/sub leads to over/under flow. 
;// (CY)
mov al, 0ffh			;// 100h is to large for al (8-bit), this will set 
add al,1	;// carryflag
add al, 1	;// this is just to unset the carryflag 
;// Underflow, teh overflow flag is set because we used signed integer arithmetic.
mov al, -128
sub al, 1
dec al		;// This is to unset the overflow flag.
;// Studying the overflow flag.

;// Sign flag (PL), partity flag (PE), and auxillary flag (AC).
;// 1. Sign flag: Is set when the sign of an arithmatic operation's dest is negative.
mov al, 5
mov ah, 4
sub ah, al		;//	The result of this operation is negative, so the sign flag is set. 
;// 2. Parity flag : Set when the least significant byte of dest, has an even number of
;//					1 bits.
mov eax, 01b
add al, 1100b		;// The destination has an od number of 1's in LSB.
add al, 10000b
;// Easy instructions: They do not have implied operands.
;// ---------------------------------------------------------------
mov eax, op1		;// At least one of the operands must be a register.
					;// Destination cannot be a literal.
					;// You cannot have memory location as both destination and source.

					;//
add eax, op2		;// op1 = op1 + op2	
mov eax, op1
sub eax, op2		;// op1 = op1 - op2
inc op1				;// Add 1 to the operand.
dec op1

;// Implied operands. Destination is implied.
;// --------------------------------------------------------------
;// You must have a register as an operand with mul.
mul	op2					;//  EAX = EAX * op2. If result us==is greater than a 32-bit number,
						;// the overflow is stored in the EDX.
; div op2;// Just like mul. EDX:EAX 
;// Quotient goes to EAX and remainder goes to EDX.
; cdq;// This extends sthe register so that we can store turn a 32-bit number to a 64-bit number.
;// (change double word to qword)
; mov ebx, 9;// You need to use registers when using div and mul
; div ebx

;// Irvine libraey procedures.
;// --------------------------------------------------------------

;// How to use a procedure.
;// You must first setup all the parameters into the register values befire you call
;//		the procedure that you want to use.
;// - Use the call procedure to use a function.

;// 1. ReadString:
;// a. Need to store the address of our string in eax and set the capacty in ecx.
;// b. Length of the string will be stored in eax and the string is inside our memory 
;// (Overwrite the entire edx)

;// 2. WriteInt and WriteDec
;// - Ouputs the value of eax to the console.

;// 3. WriteString: Outputs a all the charaters in the array untill null charater found.
;// - You must set the address of the string to the edx regsiter.
;// - Then the procedure outputs all the charaters in the string untill null terminated char is found.

INVOKE ExitProcess, 0	;// Return power to the OS with exitcode 0.
main ENDP
END main
