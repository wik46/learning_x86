;// Author: Lodewyk Jansen van Rensburg
;// Last Modified: January 30, 2021
;// Course: CS 271, 
;// Description: This program sums all the values entered by the user in range [-100,-1].
;//					* The program displays its name and the name of the author.
;//					* Then it informs the user about the game rules by printing insructions to 
;//						the console window.
;//					* The user is then allowed to enter valid integers. An integer is valid if it
;//						is in the range specified above.
;//					* The program will gather all the negative integers in the range and sum them.
;//						- It will display the number of valid inputs, as well as the sum/ num.
;//					* If the user enters a negative integer outside the range, the value is 
;//						discarded and the user is asked to re-enter an valid integer.
;//					* If the user enters a non-negative integer, then the program calculates the average
;//						from the previous inputs received and terminates the program with a goodeby message.

INCLUDE Irvine32.inc

.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD

;// Input range limits.
lower_limit		EQU		-100
upper_limit		EQU		-1
MAX_CHAR		EQU		256
.data
user_name		BYTE	MAX_CHAR dup(?)
.code

main	PROC

	;// Segment 1: Introduction.
	mov		edx, OFFSET user_name		;// Setup for sayHello to store the username.
	call	sayHello
	;// Segment 2: Gathering Data.
	call	getData
	;// ESI = 0 means that no valid input was entered by the user.
	cmp		esi, 0 
	je		NoInput_term
	
	;// Segment 3: Using Data and Displaying Calculations.
	call	CalcAndDisp
	
	;// Program will skip calculation if there was less than one valid input entered.
	NoInput_term: 
	;// Segment 4: Termintation.
	mov		edx, OFFSET user_name		;// User's name needed for termination message.
	call	sayGoodbey

	INVOKE ExitProcess, 0
main	ENDP

;// =====================================================================================
;// Procedure: sayHello
;//	Description: The procedure displays the program title, author's name, and asks
;//					the user for their name. Afterwards it greats the user and stores their
;//					name at the offset of the variable passed as argument.
;//	Receives/ Input: * The offset of the memory where the user's name should be stored must
;//						be in Edx.
;// Returns/ Output: * Stores the user's name at the address provided.
;// =====================================================================================
sayHello	PROC
	.data
	f_line1 BYTE "=============================================================="
	f_line2	BYTE "=============================", 0dh, 0ah, 0
	prog_info			BYTE "Welcome to fun with negative numbers by "
	programmer_name		BYTE "Lodewyk Jansen van Rensburg.", 0dh, 0ah, 0
	prompt_name			BYTE 0dh, 0ah, "Please enter your name: ", 0
	prompt_welcome		BYTE "Nice to meet you, ", 0 
	.code
	push	edx			;// Needed later to store user name.
	;// Improving format of console output.
	mov		edx, OFFSET f_line1
	call	WriteString

	mov		edx, OFFSET prog_info
	call	WriteString
	mov		edx, OFFSET prompt_name
	call	WriteString
	;// Storing user's name.
	pop		edx
	mov		ecx, MAX_CHAR
	call	ReadString
	push	edx
	mov		edx, OFFSET prompt_welcome
	call	WriteString
	;// User's name is outputted.
	pop		edx
	call	WriteString
	call	Crlf
	;// Improving format of console output.
	mov		edx, OFFSET f_line1
	call	WriteString

	ret
sayHello	ENDP

;// =====================================================================================
;// Procedure: getData
;// Description: Procedure prompts the user to enter an integer in specified range. If the
;//					is inside the range, it get accumulated and the user is prompted 
;//					to enter another input. This continues untill a non-negative integer
;//					is enter by the user, where that will lead to prodcure returning
;//					to caller. 
;//					If a negative integer outside the range is entered, the value is 
;//					discarded and the user is prompted to re-enter input.
;//					Definition: 
;//						- Valid Input: Integer in specified range.
;//						- Invalid Input: a Non-negative integer.
;// Receives/ Input: a. Makes use of eax, ebx, edi, and esi registers.
;// Returns/ Output: * Ebx = total.
;//					 * Esi = # of valid inputs.
;//					 * Esi = 0 means no valid input was entered. This will cause the program to terminate
;//						before doing calculations.
;// Pre-conditions: * This procedure makes use of valData for range validation.
;// Post-conditions: * Procedure terminates when a non-negative integer is received as
;//						input.
;// =====================================================================================
getData		PROC
	.data
	rules_tot BYTE 0dh, 0ah, "==============================================================", 0dh, 0ah 
	rule_msg1 BYTE "1. You will be prompted to enter a number in a specified range.",0dh, 0ah
	rule_msg2 BYTE "2. If you enter a integer inside the range, I will prompt you for another integer.",0dh, 0ah
	rule_msg3 BYTE "3. I will continue to prompt you untill you enter a non-negative number.", 0dh, 0ah
	rule_msg4 BYTE "4. If a non-neg integer was entered,",
					" I will sum up all the integers and display the average.", 0dh, 0ah
	rule_msg5		BYTE "** Note: If negative number received outside of range, I"
	rule_msg5a		BYTE " will discard it and reprompt you.", 0dh, 0ah
	f_linea			BYTE "=============================================================="
	f_lineb			BYTE "=============================", 0dh, 0ah, 0
	no_valid_msg	BYTE 0dh, 0ah, "Oh no!. You did not even enter at least one valid integer.", 0dh,  0ah, 0

	.code 

	;// Register storage:
	push	edx
	push	edi

	;// Rules message:
	mov		edx, OFFSET f_linea
	call	WriteString
	mov		edx, OFFSET rule_msg1
	call	WriteString
	call	Crlf 

	;// Loop Setup:
	mov		esi, 0			;// Esi will count the number of valid input. Used to calc ave later.
	mov		ebx, 0			;// Ebx is used as the accumulator for valid input.
	InputLoop:
	;// 1. Get input.
	call	valData
	;// 2. React on input.
	cmp		edi, 0
	jne		END_Invalid
	;// Case 1: Valid input:
	add		ebx, eax
	inc		esi
	jmp		InputLoop
	;// Case 2: Invalid input:
	END_Invalid:
	;// Special message will be displayed if the user did not enter at least one valid number.	
	cmp		esi, 0
	jne		ENDING
	mov		edx, OFFSET no_valid_msg
	call	WriteString
	call	Crlf

	ENDING:

	;// Register return:
	pop		edi
	pop		edx
	ret
getData		ENDP

;// =====================================================================================
;// Procedure: valData
;// Description: - The procedure is used to validata an integer in a range specified
;//				    by integers literals declared in global scope. 
;//				 - Def: Valid integer:
;//					- An integer is valid if it is in the specified range.
;//
;//	Receives/ Input: * Eax is the integer to validate in the range [lower_lim, upper_lim].
;// Returns/ Output: * Eax is a valid integer.
;//					 * Edi = 0 means succesfull execution.
;//					 * Edi = 1 implies non-negative number entered. 
;// Pre-conditions: Assumes that only integer input. Only error checking is range checking.
;// Post-conditions: - 
;// =====================================================================================
valData PROC
	.data
	prompt1			BYTE "Enter integer in range [", 0
	comma			BYTE", ",0
	right_bracket	BYTE "]: ",0
	invalid_msg		BYTE 0dh, 0ah, "[** Warning **]: Integer out of range.", 0dh, 0ah, 0
	ending_msg		BYTE 0dh, 0ah, "[** Note **]: Non-negative number was entered: ",0
	.code
	;// Case 1: x < lower_limit ( => reprompt)
	Validation:
		;// Entire block is used to output the message specifying the range of input.	
		mov		edx, OFFSET prompt1
		call	WriteString
		mov		eax, lower_limit
		call	WriteInt
		mov		edx, OFFSET comma
		call	WriteString
		mov		eax, upper_limit
		call	WriteInt
		mov		edx, OFFSET right_bracket
		call	WriteString

		call	ReadInt
	;// Is input less than lower limit?
	cmp		eax, lower_limit
	jl		Invalid
	;// Is input greater than upper limit?
	cmp		eax, upper_limit
	jg		Non_neg
	;// If this executes we know integer is valid.
	jmp		Valid

	;// Case 1: x < lower_limit ( => reprompt)
	Invalid:
		mov		edx, OFFSET invalid_msg
		call	WriteString
		call	Crlf
		jmp		Validation
	;// Case 2: lower_limit <= x <= upper_limit.
	Valid:
		mov		edi, 0
		jmp		Ending	
	;// Case 3: x > upper_limit ( => return 1)
	Non_neg:
		mov		edx, OFFSET ending_msg				
		call	WriteString
		call	WriteInt					;// Value wil still be in eax after ReadDec.
		mov		edi, 1		
	Ending:
	ret
valData ENDP


;// =====================================================================================
;// ProcedureName: CalcAndDisp
;// Description: This procedure takes the value at ebx, and divides it by the value in Esi.
;//					 * It pushes the integer at Ebx into the FPU register stack using fild.
;//						 (ST(0)).
;//					 * Then it uses fidiv wich converts esi to a REAL8 before performing
;//						the division operation.
;//					 * It then displays the value at ST(0).
;//	Receives/ Input: * Ebx = dividend, Esi = divisor.
;//	Returns/ Output: * Displays Ebx/Esi and the value is stored at ST(0).
;// Pre-conditions:
;//	Post-conditions:
;// =====================================================================================

CalcAndDisp		PROC
	;// Setting up the FPU.
	finit
	
	.data
	;// Temporary storage needed to load values at general purpose registers to FPU stack.
	count_msg	BYTE 0dh, 0ah, "Number of valid input entered: ", 0
	accum_msg	BYTE 0dh, 0ah, "Sum of all valid input entered: ", 0
	ave_msg		BYTE 0dh, 0ah, "The average (rounded to 3 decimals) is: ", 0
	tmp			DWORD ?
	.code
	;// Part 1: Calculate ================

	;// Step 1: Move values at general registers to memory before loading to FPU stack.
	mov		tmp, ebx	;// a. dividend.
	fild	tmp
	mov		tmp, esi	;// b. divisor.
	
	;// Step 2: Division.
	fidiv	tmp		;// Value we want is stored at ST(0).

	;// Part 2: Display ================
	;// I : Number of valid input message.
	call	Crlf
	mov		edx, OFFSET count_msg
	call	WriteString
	mov		eax, esi
	call	WriteInt
	call	Crlf
	;// II : Accumulation of valid input message.
	mov		edx, OFFSET accum_msg
	call	WriteString
	mov		eax, ebx
	call	WriteInt
	call	Crlf
	;// III : Average value display. 
	mov		edx, OFFSET ave_msg
	call	WriteString
	;// ** Extra credit **
	call	round_st0;// Procedure rounds ST(0) to 3 significant digits.
	;// ******************
	call	WriteFloat
	call	Crlf

	ret
CalcAndDisp		ENDP
;// =====================================================================================
;// Procedure: round_st0
;//	Description: This procedure rounds st(0) to the nearest .001 digits.
;//					We will store st(0) as an int, multiply by 1000, divide by 1000,
;//					and store the value back as a double-precision floating point in eax.
;// Receives/ Input: Value at ST(0) that needs to be rounded.
;//	Returns/ Output: ST(0) is rounded to .001 places.
;// =====================================================================================
round_st0	PROC
	push	eax	

	.data 
	rounding	DWORD	1000
	tmp1		DWORD	?
	.code
	;// Step 1: Store ST(0) as an int.
	fimul	rounding
	fist	tmp1
	;// Converting the float to an int removes all unnecessay/ insignificant digits digits.
	;// Step 2: Store new rounded value as float in ST(0).
	fild	tmp1
	fidiv	rounding

	pop		eax
	ret
round_st0	ENDP


;// =====================================================================================
;// Procedure: sayGoodbey
;//	Description: Displays a termination message to the user using their name.
;// Receives/ Input: Assumes address/ offset of user's name is in edx.
;// Returns/ Output: Displays a termination of program message.
;// Pre-condtions: -
;// Post-conditions: -
;// =====================================================================================
sayGoodbey	PROC
	;// Store register values that will be changed by the procedure.
	push	edx
	
	.data
	term_msg	BYTE "Goodbey. Have a nice day, ", 0
	.code
	;// Display termination.
	mov		edx, OFFSET term_msg
	call	Crlf
	call	WriteString
	pop		edx
	call	WriteString
	call	Crlf
	call	Crlf
	;// ----------------------
	ret
sayGoodbey	ENDP

END		main
