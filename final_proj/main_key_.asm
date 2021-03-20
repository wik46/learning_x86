;// Author: Wikus Jansen van Rensburg
;// Last Modified: March 11, 2021
;// Description: This procedure accepts a memory location of a 26-bit byte array,
;//					uses Irvine's Randomize procedure and fill the array radnomly
;//					with integers between 97 and 122. Every integer will appear only once in
;//					the array.
;// Application: This procedure is part of the Compute procedure created for the final
;//					project in a Computer Architecture and Assembly language course.

.386
.model			stdcall, flat
.stack			4096
ExitProcess		PROTO, dwExitCode:DWORD

INCLUDE			Irvine32.inc

num_letters = 26

.data
test_str	BYTE	num_letters		dup('a')
test_decoy	WORD	97,0ffffh, 0eeeeh
test_mode	DWORD	0
.code
main		PROC
	call	Randomize

	push	OFFSET test_str
	push	OFFSET test_mode
	call	KeyGeneration

	INVOKE	ExitProcess, 0
main		ENDP



;// Procedure: KeyGeneration
;// Description: This procedure accepts the offset of a byte array that has room for at least
;//				 26 bytes (because we need to fill it with all the alphabet letters, randomly).
;//				 It uses RandomRange defined in the Irvine32 library and randomly inserts 
;//				 the ascii values of the charaters at the memory location provided.
;// Receives: 
;//			  Parameter1: The 32-bit address of the first element in the array. 
;//			  Parameter2: A 32 - bit operand that is used by the outer procedure, Compute.
;//	Returns: 
;//			 A string of all the alphabet charaters are randomly inserted in the array
;//			 provided. Any contents stored in the array before the procedure call will be lost.
;// Pre-conditions: The memory block allocated by the array must contain at least 26 bytes.
;// Post-condtions: The string IS NOT NULL-TERMINATED as specified by the project instructions.
KeyGeneration	PROC
	str_length1 = 26
	ascii_a97	= 97
	;// Setting up stackframe.
	push		ebp
	mov			ebp, esp
	pushad
	
	;// Step1: We fill the array with 0's so that when we test for a charater we no we start
	;//			without any in the array.
	mov		edi, [ebp + 12]						;// Edi -> string[0].
	mov		ecx, str_length1						
	mov		eax, 0
	cld
	rep		stosb								;// We fill the array contents with value of al = 0.
	;// From here on we know that our array is filled with 0's
	
	;// Entrance of the main loop that will iterate 26 times.
	mov		ecx, str_length1
	mov		edi, [ebp + 12]					;// We point to the start of the string.
	mov		eax, 0

	MainLoop:
		push	ecx
		push	edi

		InnerLoop:
			mov		al, str_length1					;// Eax = 26 so that we create a random int [0, 26-1]
			call	RandomRange
			add		al, ascii_a97			;// Eax is any int in range [97, 122] inclusively.

			;// If the value of eax is already in the array we loop back to start to find
			;//	a new random number, else we insert the value into the array and walk onwards
			;// to the next byte of data.
			mov		edi, [ebp + 12]			;// We do a basic linear search that always start from the beginning
			mov		ecx, str_length1
			repne	scasb 
			jz		InnerLoop 
			;// If we dont jump back to the start we foun a charater that is not yet in the string.
			pop		edi						;// We found a char to insert and need to insert it at the 
											;// correct location.
			stosb							;// Store value in current accumulator in the array.
			pop		ecx						;// Return value of outerloop counter.

	LOOP	MainLoop				;// We continue for 26 iterations. 

	;// Preparing stackframe/ activation record for procedure return.
	popad
	mov		esp, ebp
	pop		ebp
	ret		8					;// We assume that 2 32-bit operands are passed as parameters on the stack.
KeyGeneration	ENDP
END			main