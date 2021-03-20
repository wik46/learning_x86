;// Author: Wikus Jansen van Rensburg
;// Last Modified: Marc 9, 2021
;// Description: This is a very basic program that takes two 16-bit integers,
;//				  sums them, and stores the result at the memory address
;//				  passed as parameter on the system stack.

INCLUDE		Irvine32.inc

.386
.model			stdcall, flat
.stack			4096
ExitProcess		PROTO, dwExitCode:DWORD

.data
;// ====================== TEST FOR VERY LARGE NUMBERS
test1_16	WORD -32750	
test2_16	WORD -32750
location32	DWORD ?

.code
main	PROC
	push	test1_16
	push	test2_16
	push	OFFSET location32
	call	decoy

	mov		eax, location32
	call	WriteInt
	INVOKE		ExitProcess, 0
main	ENDP
;// Procedure: decoy
;// Description: This procedure accepts 3 parameters on the system stack. 
;//				 It takes two 16-bit integers and stores the sum at the location
;//				 memory address passed onto the stack. It makes use of the EAX and EBX
;//				 registers, but it stores and returns there values during the procedure
;//			     call.
;// Receives:	 Parameter1: Address to a 32-bit memory location. 
;//				 Parameter2: 16-bit signed integer.
;//				 Parameter3: 16-bit signed integer.
;// Returns:	The sum of the two 16-bit integers are store at the memory location given.
;// Pre-conditions: The function assumes that the thw parameters are passed onto the stack
;//					in order parameter3, parameter2, parameter1. That is the offset is the last
;//					value pushed onto the stack before the procedure is called.
;// Post-condtions: All registers used are stored and restored during procedure call.
decoy	PROC
	;// Setting up the stackframe.
	push	ebp
	mov		ebp, esp
	;// 1. Store values: Store the eax, ebx registers and obtain values at the parameters provided.
	push	eax
	push	ebx
	
	mov		ebx, [ebp + 8]					;// Memory location where we will store the result.

	;// 2. Sum the two integers.
	mov		ax, WORD PTR [ebp + 12]
	mov		dx, WORD PTR [ebp + 14]
	movsx	eax, ax
	movsx	edx, dx
	add		eax, edx

	;// 3. Store the value at the memory location provided.
	mov		[ebx], eax

	;// Settinh up stack for procedure return.
	pop		ebx
	pop		eax
	mov		esp, ebp
	pop		ebp
	ret		8				;// Dword + word + word = 4 + 2 + 2 = 8
decoy	ENDP


END		main

