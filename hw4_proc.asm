;// Author: Wikus Jansen van Rensburg
;// Last Modified: February 7, 2021
;// Course: CS271 
;// Description: The goal of this program is to display composite number.
;//				 * The user will be prompted to enter a number between [1,300], inclusively.
;//				 * The number will be validated. A valid input is an integer inside the range. 
;//					Invalid input is any other input.
;//				 * The user will be repromted in the case of invalid input untill valid input is entered.
;//				 * After valid input n is received, the program will display the first n composite numbers
;//					10 per line.
;//				 * Lastly, the program will terminated with a goodbey message.

INCLUDE		Irvine32.inc
.386
.model	flat, stdcall
.stack 4096
ExitProcess		PROTO, dwExitCode:DWORD

;// Constants
lower_limit	= 1
upper_limit = 300
one_parameter4 = 4
two_parameter8 = 8
MAX_CHAR    EQU	 256

.data
print_all1	DWORD	?
twenty		DWORD	577
test_even	DWORD	2
user_name	BYTE	MAX_CHAR dup(?)

.code
main	PROC
	;// 1. Program Introduction.
	mov		edx, OFFSET user_name		;// Setup for sayHello to store the username.
	call	sayHello
	
	;// 2. Retrieve and Validate Data.
	call	Crlf
	call	getData						;// Valid integer is inside eax.

	;// 3. Manipulate Data and Display.
	;// Prompts the user if the program should print all composite numbers or only odd ones.
	push	eax
	call	setPrint
	mov		Print_all1, eax
	pop		eax

	push	Print_all1				 ;// Parameter1: For testing we let it print all.
	push	eax						 ;// Parameter2: Valid integer in range [1,300]
	call	showComposite			 ;// Testing for Composite procedure is called from showComposite procedure.
	add		esp, two_parameter8
	
	;// 4. Terminate Program
	mov		edx, OFFSET user_name;// User's name needed for termination message.
	call	sayGoodbey
	INVOKE	ExitProcess, 0
main	ENDP



;// *********************************
;// Sub-Routines
;// *********************************


;// Procedure: sayHello
;//	Description: The procedure displays the program title, author's name, and asks
;//					the user for their name. Afterwards it greats the user and stores their
;//					name at the offset of the variable passed as argument.
;//	Receives/ Input: * The offset of the memory where the user's name should be stored must
;//						be in Edx.
;// Returns/ Output: * Stores the user's name at the address provided.

sayHello	PROC
	.data
	f_line1 BYTE "****************************************************************"
	f_line2	BYTE "***************************", 0dh, 0ah, 0
	prog_info			BYTE "Welcome to Fun with Composote Numbers by "
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

;// Procedure: sayGoodbey
;//	Description: Displays a termination message to the user using their name.
;// Receives/ Input: Assumes address/ offset of user's name is in edx.
;// Returns/ Output: Displays a termination of program message.
;// Pre-condtions: -
;// Post-conditions: -

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

;// Procedure: showComposite
;// Description: This procedure will accept and integer n in range [1,300] and display 
;//					all the composite numbers from 1 up to and including n. The integer must be in specified range.
;// Receives: 2 Parameters passed on the stack.
;//				* First parameter is the integer in range [1,300]. 
;//				* Second parameter determines if only the odd composites numbers are printed.
;//					If 0, all composites in [1,n] gets printed. If 1, only odd composites in [1,n] get printed.
;// Returns: Displays all the composte integers in range [1, n].
;// Pre-conditions: The procedure makes use of to helper procedures namely, IsComp and IsOdd. See procedure headers for
;//					information.
;// Post-conditions: Changes the value of the eax, ecx, and edx registers.
showComposite	PROC
	;// Declaration of local variables.
	.data
	newline_tracker		DWORD	0
	n					DWORD	1			;// This is the integer that will go up to n and be printed if it is_comp.
	print_all			DWORD	?			;// If 1, all composites are printed. If 0, only odd composites are printed.
	format_width		BYTE	9, 0		;// Width between integer output.
	.code
	;// Setting up the stackframe.
	push	ebp
	mov		ebp, esp
	;// Storing parameters from stack into local variables.
	mov		ecx, [ebp + 8]			
	mov		eax, [ebp + 12]
	mov		print_all, eax
	call	Crlf
	OuterLoop:
	;// Part 1: Testing to see if 
	push	ecx			;// This is important because this loop will be an inner-loop.
	
	push	n
	call	IsComposite						;// Inner loop defined in this procedure.
	add		esp, one_parameter4

	pop		ecx
	;// Test 1: If eax = 0, not_comp. If eax = 1, is_comp.
	cmp		eax, 0
	je		no_comp
	;// If is_comp we test to see if it is odd.
	push	n
	call	IsOdd
	add		esp, one_parameter4
	;// Test 2: If eax = 0, not_odd. If eax = 1, is_odd.
	cmp		eax, 1
	je		yes_print
	;// If not_odd, we only print if user selected print all composites.
	;// Test 3: If print_all = 0, we only print odd composites. If print_all = 1, we print all composites.
	cmp		print_all, 0
	je		no_print	
	;// If this block executes, we know we have a integer stored in memory marked by n that needs to be outputted to 
	;// the console window. We print a 'newline charater' for each 10 ints printed.
	yes_print :
	;// Test 4: Print a 'newline charater' if we already printed 10 ints previously.
	cmp		newline_tracker, 10
	jne		after_newline
	call	Crlf
	mov		newline_tracker, 0				;// Reseting the # of outputted ints tracker.

	after_newline:
	mov		eax, n
	call	WriteDec
	mov		edx, OFFSET		format_width
	call	WriteString
	inc		newline_tracker			;// Will be used so that a newline is outputted every 10 ints.
	
	no_comp:
	no_print:
	inc		n

	LOOP	OuterLoop

	call	Crlf
	call	Crlf
	;// Preparing stackframe for procedure exit.
	mov		esp, ebp
	pop		ebp
	ret
showComposite	ENDP

;// Procedure: setPrint
;// Description: This procedure determines prompts the user to enter a value 1 or 0.
;//					It accepts an address of a variable and stores the input in the variable.
;//					it does not do error-checking. Therefore, to used this tell the user
;//					that any non-zero value entered will return true when condition is tested.
;//	Receives: Offset of memory too store result.
;// Returns: Input entered by the user without error checking. ( asks for integers.)
;// Conditions: The procedure changes the value of eax and edx.
setPrint	PROC
	.data
	prompt_msg10	BYTE	"** If you only want to display odd-composite numbers enter 0, else we will",0dh,0ah,
							" display all the composite numbers up to the integer you entered. **", 0dh, 0ah,
							"** [Enter input here (0 - odd composites, 1 - all composites)]: ",0
	.code
	;// Setting up the stackframe.
	push	ebp
	mov		ebp, esp
	;// Prompt user to enter input.
	mov		edx, OFFSET prompt_msg10
	call	WriteString
	call	ReadInt
	call	crlf
	;// Storing the value entered by the user in the parameter given.
	; mov[ebp + 8], eax
	;// Ensuring we return correctly to the caller of the procedure.
	mov		esp, ebp
	pop		ebp
	ret
setPrint	ENDP


;// Procedure: IsComposite
;// Description: This procedure will determine if a number is composite or not.
;//					The procedure accepts a 16-bit unsigned integer as on the stack. The procedure
;//					determines if the integer is composite or not. The result is returned using ax and
;//					needs to be stored in memory after function call returns.
;// Receives/ Input: A 32-bit unsigned integer passed on the stack.
;// Returns/ Output: EAX = 1 implies number is composite. EAX = 0 implies number is not composite. 
;// Pre-condtions: One parameter passed on the stack and the value of eax will be changed.
;// Post-conditions: Assumes that the stack pointer is reset after returning function call and value
;//					of EAX is stored in memory.
;// Terminology: * n is the integer that is validated.
;//				 * is_comp means that n is a composite number.
;//				 * not_comp means that n is no a composite number. (Note that 1 is not a composite number.)
IsComposite		PROC
	;// Setting up the stack
	push	ebp
	mov		ebp, esp
	;// Using parameter passed on the stack and determining if it is a composite number.
	;// Example: We have a number n and want to determine if it is composite. We start by dividing n by n/2.
	;//			 If remainder != 0, devide by n/2 - 1, n/2 -2 ... untill remainder == 0 or n/2 - i == 1.

	mov		eax, [ebp + 8]			;// The number or validate is stored at address ebp + 8.
	cdq
	mov		ecx, 2					;// We want to divide the current number by 2 to shrink our search space. 
	div		ecx
	mov		ecx, eax				
	;// We start our search to determine if out number is composite.
	StartLoop:
		mov		eax, 0;// Sets up eax so that if loop terminates after this, we know n is not_comp.
		cmp		ecx, 1
		jle		not_comp
		mov		eax, [ebp + 8]		;// Moving the number n we want to validate into eax to test for composite.
		cdq							
		div		ecx
		;// Continue loop here, we need to terminate the loop if remainder == 0.
		cmp		edx, 0				;// If remaineder == 0, then n evenly divides by a int > 1. Thus is composite.
		je		is_comp				;//	Remember that our number is stored at address [ebp + 8]
		LOOP	StartLoop
	
	is_comp:
		mov		eax, 1				;// eax = 1 sets the return value of the proc to tell caller that n is_comp.
	not_comp:						;// eax = 0 here tells caller that n not_comp.
			
	;// Restoring the stack so that the stack pointer can load the correct return address into the instruction pointer
	;// when the ret instruction is executed.
	mov		esp, ebp
	pop		ebp
	ret
IsComposite		ENDP


;// Procedure: IsOdd
;// Descriprion: This procedure assumes input as a stack parameter. It sets eax = 1 if
;//					the number provided is odd and eax = 0 if the number provided is even.
;// Receives: An integer passed on the stack.
;// Returns: eax = 1 if the integer is odd. eax = 0 if the integer is even.
;// Pre-conditions: Needs to use the eax register and accpets one parameter on the stack.
;// Post-conditions: Changes the value of eax and does not save the value at inside eax.
IsOdd	PROC
	;// Setup stackframe.
	push	ebp			;// Base of the stack.
	mov		ebp, esp 
	;// Store integer that needs to be checked for parity inside eax.
	mov		eax, [ebp + 8]
	cdq
	;// Testing if the integer is odd or even.
	div		test_even
	
	cmp		edx, 0
	jne		Odd_int
	;// Case 1: Divison by two resulting in a zero remainder implies integer is even. (eax = 0)
	mov		eax, 0
	jmp		finished
	;// Case 2: Division by two resulting in a non-zero remainder implies integer is odd. (eax = 1)
	Odd_int:
	mov		eax, 1
	finished:
	;// Setting up stack frame to return to address of caller.
	mov		esp, ebp
	pop		ebp			;// After pop esp points to return address needed by the ret instruction.
	ret
IsOdd	ENDP
	
;// Procedure: getData
;// Description: Procedure prompts the user to enter an integer in specified range. If the
;//					is inside the range, it get stored in eax. 
;//					to enter another input. This continues untill a non-negative integer
;//					is enter by the user, where that will lead to prodcure returning
;//					to caller. 
;//					If a integer outside the range is entered
;//					the user is prompted to re-enter input.
;//					Definition: 
;//						- Valid Input: Integer in specified range.
;//						- Invalid Input: Any other integer.
;// Receives/ Input: a. Makes use of eax register.
;// Returns/ Output: * Eax = user entered integer.
;// Pre-conditions: * This procedure makes use of valData for range validation.
;// Post-conditions: -

getData		PROC
	.data
	rules_tot BYTE 0dh, 0ah, "==============================================================", 0dh, 0ah 
	rule_msg1 BYTE "1. You will be prompted to enter a number in a specified range.",0dh, 0ah
	rule_msg2 BYTE "2. I hope you are ready to see a lot of composite numbers.",0dh, 0ah
	rule_msg3 BYTE "3. If you do not enter an integer insided [1,300] I will reprompt you untill you enter one.", 0dh, 0ah
	rule_msg4 BYTE "4. If a valid integer was entered,",
					" I will display all the composite numbers up to and including the one entered.", 0dh, 0ah
	rule_msg5		BYTE "** Note (Extra credit): You can choose to only display the odd composite numbers ", 0dh, 0ah
	f_linea			BYTE "=============================================================="
	f_lineb			BYTE "=============================", 0dh, 0ah, 0

	.code 

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
	call	valData			;// This is a loop that will prompt the user for valid data and stored in eax.
	
	ret
getData		ENDP


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
	jg		Invalid
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
	ret
valData ENDP

END		main
