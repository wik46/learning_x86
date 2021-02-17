;// Author: Wikus Jansen van Rensburg
;// Last modified: February 16, 2021
;// Description: This source file contains 2 procedures. The first is a procedure that accepts
;//					the offset/ address of the first integer in a 32-bit array and the number of elemtents.
;//					It then fills the array with random numbers using one of the procedures defined in the Irvine32.lib.
;//				 The second procedure takes in the offset of the first element in a 32-bit integer array
;//					and the size (# elements) of the array and prints it to the screen. It assumes that the array
;//					contains at least one element.

;// File Progress: The two procedures work, but still need to change fillArray so that random numbers in
;//					range [100, 999] is filled.

INCLUDE		Irvine32.inc

.386
.model	stdcall, flat
.stack	4096
ExitProcess		PROTO, dwExitCode:DWORD

;// Constants/ Imediate Values.
ar_size	= 200			;// This is the maximum number of ints that will be filled.
two_parameters = 8
test_length = 100

.data
	IntArray	DWORD	ar_size dup(?)					;// Static allocation of maximum size.
.code

main	PROC

	;// Part 1: Fill the array with random integers.
	call		Randomize								;// Irvine procedure to seed random number generator.
	push		OFFSET	IntArray
	push		test_length	
	; push		LENGTHOF	IntArray
	call		fillArray
	;// Part 2: Print the array of integers.
	push		OFFSET	IntArray
	push		test_length
	call		printArray32
	INVOKE		ExitProcess,0
main	ENDP


;// Procedure: fillArray
;// Description: The procedure fills an 32-bit array with random integers using Random32 defined in Irvine32.lib.
;//					The Irvine library procedure generates a 32-bit random number and stores it in eax. Remember
;//					to call Randomize (also from Irvine32.lib) to seed the random number generator.
;// Receives: Parameter1 (ebx+8): number of random integers to store. (The array must have at least room for it.)
;//			  Parameter2 (ebx+12): The offset of the first element in a 32-bit array.
;// Returns: -
;// Pre-conditions: Uses and does not restores eax, ebx, ecx, and esi.
;//					Procedure assumes that memory allocation if sufficient for integer storage.
;//					Assumes the caller called randomize before calling this procedure.
;// Post-conditions: The array is filled with n random integers. (n is the parameter1 specified by the caller)
fillArray	PROC
	;// Setting up stack frame.
	push	ebp						;// Base index created for stack frame/ activation-record.
	mov		ebp, esp
	;// Accesing parameters passed on the stack.
	mov		ecx, [ebp + 8]				;// This is the number of random ints that my array will contain. 
										;// Assuming 1 <= [ebp + 8 ] <= max_storage.
	mov		ebx, [ebp + 12]				;// "Pointer" to the first element in the array.
	mov		esi, 0						;// Will be used to traverse trough the array.

	;// Filling the array with random numbers.
	fillLoop:
		call	Random32				;// Storing a 32-bit random number in eax.
		mov		[ebx + esi], eax
		add		esi, 4				
		LOOP	fillLoop

	;// Preparing for procedure return.
	mov		esp, ebp
	pop		ebp
	ret		two_parameters		;// ret decrements the stack pointer by 4 and then by the number 8 specified.
fillArray	ENDP

;// Procedure: printArray32
;// Description: This procedure takes two parameters on the stack and prints the contents of
;//					a 32 bit integer array to the console. 
;//	Receives: Parameter1 (ebx+8): The number of elements in the array that needs to be printed.

printArray32	PROC
	elements_per_row = 10
	reset = 0
	.data	
		newline_tracker		DWORD reset			;// Used to format ouput. 
		tab1					BYTE	9,0			;// Distance between int output.
	.code
	;// Setting up stack frame.
	push	ebp						;// Base index created for stack frame/ activation-record.
	mov		ebp, esp
	;// Accesing parameters passed on the stack.
	mov		ecx, [ebp + 8]				;// This is the number of random ints that my array will contain. 
										;// Assuming 1 <= [ebp + 8 ] <= max_storage.
	mov		ebx, [ebp + 12]				;// "Pointer" to the first element in the array.
	mov		esi, 0						;// Will be used to traverse trough the array.
	mov		edx, OFFSET tab1
	;// WriteInt prints the contents at eax to the console window.
	PrintLoop:
		;// We print the elements 10 per row.
		cmp		newline_tracker, elements_per_row
		jne		next
		call	Crlf
		mov		newline_tracker, reset 

		next:
		;// Print an element.
		mov		eax, [ebx + esi]
		call	WriteInt
		call	WriteString
		add		esi, 4				
		inc		newline_tracker
		LOOP	PrintLoop

	;// Preparing for procedure return.
	mov		esp, ebp
	pop		ebp
	ret		two_parameters		;// ret decrements the stack pointer by 4 and then by the number 8 specified.
printArray32		ENDP


END		main
