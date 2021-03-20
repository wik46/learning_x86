;// Author: Lodewyk Jansen van Rensburg
;// Last Modified: March 6, 2021
;// Part 3:
;// Description: This is the third component of the compute procedure required for
;//					the final project.
;// Goal: This filed is used to develop, test, and demonstrate the decryption procedure.
;// Assume that we only deal with lowercase letters. Also we only map charaters and leave spaces.
;// Understanding:	
;//			*This procedure accepts a key_map, message_ar, and a mode_number.
;//			* message_ar is an encrypted message and this procedure will decipher the message based
;//				on the mapping rules stored in key_map.
;//			* key_map is a string contianing all 26 charaters from the alphabet in the order
;//				that they encrypt data. Example if the first 5 charaters are "epbfh..." then
;//				we know that 'e' in the message array maps back to an 'a',
;//				'p' -> 'b', 'b' -> 'c', 'f' -> 'd', ...

.386
.model			stdcall, flat
.stack			4096
ExitProcess		PROTO, dwExitCode:DWORD

.data
key_map			BYTE "qwertyuiopasdfghjklzxcvbnm",0
key_map_no_null BYTE "qwertyuiopasdfghjklzxcvbnm"
msg_1			BYTE "kxuwn wqss ",0	;// Decoded we have "rugby ball"
msg_2			BYTE "Tiol ol qf tbzktdsn sgfu dtllqut ziqz voss fttr zg wt rtegrtr", 0
number_mode		DWORD -2

.code
main	PROC
	;// Demonstration of how to use decruption.
	push	OFFSET	key_map_no_null          ;// [ebp + 16]
	push	OFFSET	msg_2					 ;// [ebp + 12]
	push	OFFSET	number_mode				 ;// [ebp + 8]
	call	decryption


	INVOKE	ExitProcess, 0
main	ENDP

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
	num_char = 26
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
		mov		cl, num_char							;// We want ecx = 26.
		mov		bl, cl						;// ebx is used to calculate what original charater was.
		lodsb								;// al current byte we investigate.
		dec		esi							;// We first need to put the real charater back.
		
		;// Case I  : We reached the end of the string.
		cmp		al, 0
		je		End_of_string
		;// Case II : We do not have a alphabetic charater. We then leave the byte unchanged.
		cmp		al, 97						;// 'a' = 97.
		jl		No_change
		cmp		al, 122						;// 'z' = 122.
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
END		main
