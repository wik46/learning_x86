;// Author: Wikus Jansen van Resnburg
;// Last Modified: March 2, 2021
;// Description: The goal of this program isto study how to effieciently process strings.
;//				 We start with basic on how strings are built as a sequence of charaters.
;//				 Some algorithms we implement are the one that takes a string representation 
;//				 of a numerical value and convert its actual value as a integer DWORD.

;// We investigate: 1. The 5 Basic String Primitive Instructions.
;//					2. How to use REP, REPE, and REPNE alongside them.
.386
.model			stdcall, flat
.stack			4096
ExitProcess		PROTO, dwExitCode:DWORD

MAXSIZE = 100

.data
;// For example a.
char_a			BYTE	'a'
char_b			BYTE	'b'
char_target		DWORD	0			;// This is used as the target/destination in demonstarting.
little_endian	BYTE	10h, 20h, 30h, 40h, 50h, 60h, 70h, 80h
;// For example b.
source_word		WORD	2318h	
target_word		WORD	0			;// We give target the value zero to easily notice the change.
;// For Example c.
string_we_search	BYTE	"alliteration", 0
testChar_l			BYTE	'l'
testChar_w			BYTE	'w'
;// For Example d and e.
source_byte			BYTE "abcdef_*_ghi_*_jkl.", 0
target_byte			BYTE LENGTHOF source_byte dup(?)

.code
main	PROC

;// 5 Basic String Primitive Instructions.
;// --------------------------------------
;// - These instructions modify the esi, edi, al, or ax register depending on which intructions.
;// ===============================================================================================
;// DIRECTION FLAG:
;// (cld): If clear, then esi and edi gets incremented after primitive instruction.
;// (std): If set, then esi and edi get decremented after primitive instruction.

;// a. MOVS B, W, or D : - This copies value from memory address at source to memory addres in 
;//							 target.
	cld										;// esi is incremented after MOVSB becuase d-flag clear.
	mov		esi, OFFSET char_a				;// We move the address of the char to the source.
	mov		edi, OFFSET	char_target			;// edi must point to the address where you want to move.
	MOVSB									;// This copies the value at memory address stored in esi
											;// to edi.
	;// Inspect the edi register.

	;// Side note on the little-endian order
	mov		eax, DWORD PTR little_endian				;// Remember: DWORD PTR 'casts'.		
	;// What do you expect the value of eax to be?
	;// Answer: eax = 40 30 20 10h.
	mov		eax, DWORD PTR [little_endian + 2]				;// eax = 60 50 40 30h

;// b. CMPS B, W, or D.
;//		- This will compare the memory pointed to by esi and edi.
;//		That is it compares the contents/ value at the two memory locations address at esi and edi.
	cld								;// source and target registers will get incremented after ins.
	mov		esi, OFFSET source_word
	mov		edi, OFFSET target_word
	CMPSW							;// source > target
	ja		source_above_target		;// Jump Above: Only works with unsigned comparison.
	;// We dont execute this mov instruction because the contents at memoty location
	;//		addressed by esi is above the contents address by edi. There we jmp over.
	mov		eax, 10101010h					;// This is to see if the condition jumped.
	source_above_target:

;// c. SCAS B, W, or D
;//		- This intructions compares the contents inside the accumulator (AL, AX, or EAX) with
;//		the contents at the memoru location pointed to by EDI (destination/ target)


;// 2 Main uses: 
;// - We can use it to search for a particular character inside the string.
;//		* We use repne that will continue searching for a char and stop when found, while ecx > 0.
;// - We can use it to count the number of occurances of a charater in a string.

;// Example 1: We search the string "alliteration" for the charaters 'l' and 'w'.
;//				* We search from the front of the string
;//				* Note if we find a char it will be the first of that char.
	cld
	mov		edi, OFFSET string_we_search					;// we pass address of the string.
	mov		ecx, LENGTHOF string_we_search				;// repne will stop when ecx = 0.
	mov		al,	testChar_l
	
	;// This will:
	;// 1. Test ecx == 0 and test zero flag == 1.
	;//	   * If one is true, it will stop.
	;//    * If false, then ecx--, execute SCASB, and repeat.
	repne	SCASB				;// Repeat when zero flag = 0 and ecx > 0.
	
	;// If we found the char, we set eax = 1, else we set eax = 0.
	jz		char_found			;// If the zero flag was set, then we know that the char was found.
	mov		eax, 0
	mov		ebx, 0
	jmp		Next
	char_found:
	mov		eax, 1	
	mov		ebx, LENGTHOF string_we_search
	dec		ebx								;// ebx = index of last element = length - 1. 
	sub		ebx, ecx						;// ebx = index where we found the char.
	NEXT:

	;// Example 2: Same as example 1, this time we search from the back of the string.
	std					;// Wehn the direction flag is set, we decrement esi and edi after ins.
	mov		edi, OFFSET string_we_search
	mov		ecx, LENGTHOF string_we_search
	mov		al, testChar_l

	repne	SCASB
	jz		char_found2
	;// We set these values so that we know we did not find eax and ebx.
	mov		eax, 0
	mov		ebx, 0 
	jmp		NEXT2
	char_found2:
		mov		eax, 1
		mov		ebx, ecx
	NEXT2:

;// We can use these following instruction together.

;// d. LODS, B, W, or D:
;// - This string primitive instruction takes the contents at the memory location that
;//		the source (esi) register is pointing to an loads it to the accumulator (AL, AX, EAX)


;// e. STOS B, W, or D:
;// - This string primitive instruction takes the contents from the accumulator
;//		and stores it at the memory location that the the destination is pointing to (edi).
	mov		esi, OFFSET source_byte
	mov		ecx, LENGTHOF source_byte

	mov		ebx, LENGTHOF target_byte
	dec		ebx								;// ebx = index of the last element in target_byte.
	mov		edi, OFFSET target_byte
	add		edi, ebx						;// edi points to the last element in target_byte.

	still_chars_left:
	;// Take char from source and load into accumulator.
	cld							;// We need to increment esi after LODSB.		
	LODSB
	;// Take value from accumulator and load into target.
	std							;// We need to decrement edi after STOSB.
	STOSB
	;// We do this for every charater in the string.
	LOOP	still_chars_left
	;// The contents at the target_byte memory location must contain the string in reverse order.

	
	INVOKE	ExitProcess, 0
main	ENDP
END		main
