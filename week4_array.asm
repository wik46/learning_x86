;// Author: Lodewyk Jansen van Rensburg
;// Last Modified: January 26, 2021
;// Description: 
;//				 Purpose: This source file is to study arraysand how to use them
;//							inside of a procedure.
;//				 Basic Idea: We define a procedure call sum array that will sum all 
;//							  the elements inside of an array. This procedure is taken from the textbook.
		
Include Irvine32.inc
.386
.model flat, stdcall			;// Not needed when using Irvine library. But adding it to remember about using it.
.stack 40960
ExitProcess PROTO, dwExitCode:DWORD

.data
array_dword DWORD 00h, 10h, 20h, 30h, 40h
array_byte	BYTE 65, 66, 67, 68, 69, 70
array_char BYTE 'a', 'b', 'c', 'd', 'e', 'f', 'g'

result1 DWORD ?
result2 DWORD ?
.code
main PROC
	;// I: We need the address/ offset of the array and the number of elements in the array.
	mov		esi, OFFSET array_dword
	mov		ecx, LENGTHOF array_dword
	call	SumArray						;// Result is stored in eax
	mov		result1, eax					;// We store the sum to free up eax for other uses.

	INVOKE ExitProcess, 0
main ENDP

;// =====================================================================================
;// Procedure Name: SumArray
;//	Description: This procedure will take in an array and the number of elements inside 
;//					the array, sum all the elements and return the sum.
;//				 The procdure only works with arrays that contain 32-bit elements.
;// Receives/ Input: Assumes that * ESI = offset of the array
;//								  * ECX = the number of elements in the array.
;// Returns/ Output: * Eax = sum of all the elements.
;// Pre-conditions: The ESI and ECX registers must be set as specified above.
;//					The EAX register is used to store the return value.
;// =====================================================================================
SumArray PROC
	
	;// Step 1: We store the values of the registers to pop them back when we are finished.
	push	esi
	push	ecx

	;// Step 2: Set the memory needed for the result equal to zero.
	mov		eax, 0
	StartLoop:
	;// Step 3: Add the integer to the current total
	add		eax, [esi]
	;// Step 4: Walk one element foward.
	add		esi, TYPE DWORD
	;// Step 5: Continue untill last element is added and the terminate the loop.
	LOOP StartLoop

	;// Restoring registers
	pop		ecx
	pop		esi
	RET
SumArray ENDP


END main
