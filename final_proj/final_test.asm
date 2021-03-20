;// Author: Wikus Jansen van Rensburg
;// Last Modified: March 11, 2021
;// Description: 


.386
.model			stdcall, flat
.stack			4096
ExitProcess		PROTO, dwExitCode:DWORD

INCLUDE			Irvine32.inc

bytes50_000 = 50000
.data
key_map		BYTE 26 dup(?)
msg			BYTE "I am running out of messages to think about. This is the last testing case before",
				 " I submit the project and I feel proud of my work.", 0
long_msg	BYTE	bytes50_000 dup('a')

op_pos  DWORD  23
op0		DWORD  0
op1		DWORD -1
op2		DWORD -2
op3		DWORD -3

val1	WORD  45
val2	WORD  -12
.code
main			PROC
	
	;// Testing Key Generation.
	push	OFFSET	key_map
	push	OFFSET	op3
	call	Compute

	;// Printing the message.
	mov		edx, OFFSET msg
	call	WriteString
	call	Crlf
	call	Crlf
	
	;// Testing Encryption Mode
	push	OFFSET	key_map
	push	OFFSET	msg
	push	OFFSET	op1
	call	Compute
	
	;// Printing the message.
	mov		edx, OFFSET msg
	call	WriteString
	call	Crlf
	call	Crlf

	;// Testing Decryption Mode
	push	OFFSET	key_map
	push	OFFSET	msg
	push	OFFSET	op2
	call	Compute

	;// Printing the message.
	mov		edx, OFFSET msg
	call	WriteString
	call	Crlf
	call	Crlf

	;// Testing Decoy mode.
	push	val1
	push	val2
	push	OFFSET	op_pos
	call	Decoy
	

	INVOKE	ExitProcess, 0
main			ENDP


;// Procedure: Compute
;// Description: This function will provide an interface to encrypt and decrypt
;//				 messages for the Top Secret Agency.
;//				 It has 4 operation modes. The operation mode is selected by passing the OFFSET
;//	             of a 32-bit memory location containing an integer between [-3, 0], inclusively.
;// Receives:	
;//				Parameter1: Must aggree with operation mode selected.
;//				Parameter2: Must aggree with operation mode selected.
;//				Parameter3: 32-bit operand specifying the operation mode.
;//				* Note that the operation mode integer will be stored in edi at the start of the 
;//					procedure.
;// Returns:	Dependent on operation mode selected.
;// Pre-conditions: 
;//					The parameters passed to the procedure must correspond to the parameters
;//					needed to implement the selected operation mode.
;//					That is for example, operation mode 0 needs offsets of 16-bit operands passed
;//					on the stack. Failing to abide by the correct parameters will lead to undefined behaviour.
;//					* Note that the 32-bit operand specifiying the operation mode must alway preceed
;//					  the procedure call. That is the operand must be on the line above the procedure call.
;// Post-conditions:
;//					The contents at the memory locations passed	as parameters will be altered
;//					according to the operation mode specified.
;//
Compute		PROC
	operM_3 = -3
	operM_2 = -2
	operM_1 = -1
	operM_0 =  0

	;// Setup stackframe.
	push	ebp
	mov		ebp, esp
	;// Storing original contents of general-purpose register 
	pushad
	mov		edi, [ebp + 8]

		call	Randomize
	;// Operation Mode -3: Key Generation.
		mov		ebx, operM_3
		cmp		[edi], ebx
		jne		Next_2
		push	[ebp + 12]
		push	[ebp + 8]
		call	KeyGeneration
	;// Stackframe clean up when only a total of 8 bytes were passed on the stack.
		popad
		mov		esp, ebp
		pop		ebp
		ret		8

	;// Operation Mode -2: Decryption Mode.
	Next_2:
		mov		ebx, operM_2
		cmp		[edi], ebx
		jne		Next_1
		push	[ebp + 16]
		push	[ebp + 12]
		push	[ebp + 8]
		call	Decryption
		jmp		Ending
	;// Operation Mode -1: Encryption Mode.
	Next_1:
		mov		ebx, operM_1
		cmp		[edi], ebx
		jne		Next_0
		push	[ebp + 16]
		push	[ebp + 12]
		push	[ebp + 8]
		call	Encryption
		jmp		Ending
	;// Operation Mode  0: Decoy Mode.
	Next_0:
		mov		ax, WORD PTR [ebp + 14]
		push	ax
		mov		ax, WORD PTR [ebp + 12]
		push	ax
		push	[ebp + 8]
		call	Decoy
		;// Stackframe clean up when only a total of 8 bytes were passed on the stack.
		popad
		mov		esp, ebp
		pop		ebp
		ret		8

	Ending:
	;// Cleaning up the Stackframe for the case when 12 bytes were passed on the stack.
	popad
	mov		esp, ebp
	pop		ebp
	ret		12						
Compute		ENDP

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

;// Procedure: decryption
;// Procedure Number 3.
;// Description: This procedure takes an encrypted string of characters and a rule on how
;//					the decryption occured and returns the string message to normal english.
;// Receives: Parameter 1: 32-bit offset to the 26 charater key_map.
;//			  Parameter 2: 32-bit offset to the encrypted message.
;//			  Parameter 3: 32-bit offset of a signed integer (value at offset of -2).
;// Returns: The contents at the memory location at parameter 2 now contains the decrypted message.
;// Pre-conditions: Assumes that all the charaters used in the program are lowercase.
;// Post-coditions: The procedures stores, uses, and return eax, ebx, ecx, edi, and esi.
decryption		PROC
	Dnum_char = 26
	Dascii_a = 97
	Dascii_z = 122
	;// Setting up a stackframe.
	push	ebp
	mov		ebp, esp
	;// We store all the general purpose registers.
	pushad
	;// Saving our stackparameters so that we can use the basic string primitive instructions.
	mov		esi, [ebp + 12]			;// Storing the message_ar.
	mov		edi, [ebp + 16]
	;// Now we start remapping the encrypted string back to its original values.
	cld
	StartLoop:
		mov		cl, Dnum_char							;// We want ecx = 26.
		mov		bl, cl						;// ebx is used to calculate what original charater was.
		lodsb								;// al current byte we investigate.
		dec		esi							;// We first need to put the real charater back.
		
		;// Case I  : We reached the end of the string.
		cmp		al, 0
		je		End_of_string
		;// Case II : We do not have a alphabetic charater. We then leave the byte unchanged.
		cmp		al, Dascii_a						;// 'a' = 97.
		jl		No_change
		cmp		al, Dascii_z						;// 'z' = 122.
		jg		No_change
		;// Case III: We map the charater back to its original contents.
		;// If we reached this part, we can assume that AL contains a alphabet character.
		mov		edi, [ebp + 16]				;// Offset of the key_map.
		repne		scasb					;// Finding the idex.
		inc		cl							;// scasb will decrement ecx by one over.
		sub		bl, cl 					    ;// ebx = index number of key_map helps us find char.
											;// Example: ebx = 0 => 'a' , ebx = 1 => 'b' ...

		add		bl, 97						;// ebx = ascii value we want.
		mov		[esi], bl					;// Replace real character with encrypted one.

		No_change:
		inc		esi							;// We walk to the next character.

		LOOP	StartLoop
		End_of_string:
	popad
	;// Preparing stackframe for procedure return.
	mov		esp, ebp
	pop		ebp
	ret		12							;// The procedure accepts 3 parameters on the stack.
decryption		ENDP

;// Procedure: encryption
;// Procedure Number 2.
;// Description: This procedure takes an string of characters and a rule on how
;//					the decryption occured and returns a encrypted string.
;// Receives: Parameter 1: 32-bit offset to the 26 charater key_map.
;//			  Parameter 2: 32-bit offset to the message that will be encrypted.
;//			  Parameter 3: 32-bit offset of a signed integer (value at offset of -1).
;// Returns: The contents at the memory location at parameter 2 now contains the encrypted message.
;// Pre-conditions: Assumes that all the charaters used in the program are lowercase.
;// Post-coditions: The procedures stores, uses, and return eax, ebx, ecx, edi, and esi.
encryption		PROC
	num_char_enc = 26
	ascii_a_enc = 97
	ascii_z_enc = 122
	;// Setting up the stackframe.
	push	ebp
	mov		ebp, esp
	;// Storing contents of all the general-purpose registers.
	pushad
	;// Saving the location of the original message.
	mov		esi, [ebp + 12]				;// esi = offset of the message that needs to be incrypted.

	cld
	StartLoop_enc:
		mov		cl, num_char_enc 
		mov		bl, cl
		lodsb
		dec		esi						;// We first want to change the current byte before moving on.
		
		
		;// Case I  : We reached the end of the string.
		cmp		al, 0
		je		End_of_string_enc
		;// Case II : We do not have an alphabetic character. We then leave the byte unchanged.
		cmp		al, ascii_a_enc						;// 'a' = 97.
		jl		No_change_enc
		cmp		al, ascii_z_enc						;// 'z' = 122.
		jg		No_change_enc
		;// Case III: We map the charater back to its original contents.
		;// If we reached this part, we can assume that AL contains a alphabet character.
		mov		edi, [ebp + 16]
		mov		ebx, 0
		mov		bl, [esi]
		sub		bl, ascii_a_enc			;// bl = index in key_map of character we pam to.
		
		add		edi, ebx			;// edi points to character we map to.
		mov		bl, [edi]			;// bl = ascii value of charater we map to.
		mov		[esi], bl			;// We replace the original character with the one we map to.

		No_change_enc:

		inc		esi
	LOOP	StartLoop_enc
	End_of_string_enc:

	;// Restoring general-purpose registers.
	popad
	;// Preparing stack for procedure return.
	mov		esp, ebp
	pop		ebp
	ret		12					;// The procedure takes three parameters passed on the stack.	
encryption		ENDP

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

	;// Setting up stack for procedure return.
	pop		ebx
	pop		eax
	mov		esp, ebp
	pop		ebp
	ret		8				;// Dword + word + word = 4 + 2 + 2 = 8
decoy	ENDP
END			main