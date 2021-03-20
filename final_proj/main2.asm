;// Author: Lodewyk Jansen van Rensburg
;// Last Modified: March 6, 2021
;// Part 2:
;// Description: This is the second component of the compute procedure required for
;//					the final project.
;// Goal: This filed is used to develop, test, and demonstrate the encryption procedure.
;// Assume that we only deal with lowercase letters. Also we only map charaters and leave spaces.
;// Understanding:	
;//			*This procedure accepts a key_map, message_ar, and a mode_number.
;//			* message_ar is an message that needs to be encrypted based
;//				on the mapping rules stored in key_map.
;//			* key_map is a string contianing all 26 charaters from the alphabet in the order
;//				that they encrypt data. Example if the first 5 charaters are "epbfh..." then
;//				we know that 'e' in the message array maps back to an 'a',
;//				'p' -> 'b', 'b' -> 'c', 'f' -> 'd', ...

.386
.model		stdcall, flat
.stack		4096
ExitProcess PROTO, dwExitCode:DWORD

.data
key_map			BYTE "qwertyuiopasdfghjklzxcvbnm", 0
key_map_no_null	BYTE "qwertyuiopasdfghjklzxcvbnm"
msg_1			BYTE "rugby ball ", 0					
msg_2			BYTE "This is an extremly long message that will need to be decoded.", 0
number_mode		DWORD - 2

.code
main	PROC
	;// Demonstration od the encryption procedure.
	push	OFFSET key_map_no_null			;// [ebp + 16]
	push	OFFSET msg_2					;// [ebp + 12]
	push	OFFSET number_mode				;// [ebp + 8]
	call	encryption

	INVOKE		ExitProcess, 0
main	ENDP
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
	num_char = 26
	ascii_a = 97
	ascii_z = 122
	;// Setting up the stackframe.
	push	ebp
	mov		ebp, esp
	;// Storing contents of all the general-purpose registers.
	pushad
	;// Saving the location of the original message.
	mov		esi, [ebp + 12]				;// esi = offset of the message that needs to be incrypted.

	cld
	StartLoop_enc:
		mov		cl, num_char 
		mov		bl, cl
		lodsb
		dec		esi						;// We first want to change the current byte before moving on.
		
		
		;// Case I  : We reached the end of the string.
		cmp		al, 0
		je		End_of_string_enc
		;// Case II : We do not have an alphabetic character. We then leave the byte unchanged.
		cmp		al, ascii_a						;// 'a' = 97.
		jl		No_change_enc
		cmp		al, ascii_z						;// 'z' = 122.
		jg		No_change_enc
		;// Case III: We map the charater back to its original contents.
		;// If we reached this part, we can assume that AL contains a alphabet character.
		mov		edi, [ebp + 16]
		mov		ebx, 0
		mov		bl, [esi]
		sub		bl, ascii_a			;// bl = index in key_map of character we pam to.
		
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
END		main