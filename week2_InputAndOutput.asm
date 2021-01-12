; Author: Lodewyk Jansen van Rensburg
; Date: Januray 12, 2021
; Description: INPUT and OUTPUT using the Irvine32.inc library.
                - Goal: First program written that outputs data to the console.
                - Objective:  Study how to use external libraries and make use of basic
                              instruction defined in the instruction set of a Complex Instruction Set Computer.
          
; Rember the null terminating charater in a string.
;	- What happens is that the procdures defined to perform tasks on string,
;		searches for the 0 that marks the end of the string. It continues searching
;		untill a zero is found.

; We use the irvine library to print/read from console.
INCLUDE Irvine32.inc

; 1. We first tell the assebler that this text file (source code) is a 
;		x86 assembly source file.
.386

; We comment this out because it is included inside the Irvine32.inc library.
;2. We run the program in the processor's protected mode.
;.model flat,stdcall     ; This is the memory model that we specified.

; 3. We allocate memory in the main memory of the computer for the program's runtime stack.
.stack 4096				; 4096 bytes of memory.

; 4. Here we declare a prototype for the basic windows process called ExitProcess.
;		- Format of a prototype: function_name PROTO, input_parameters
ExitProcess PROTO, dwExitCode:DWORD

; We define constants outside the .data segment.
MAX_CHAR EQU 256
dog_year_const EQU 7

; We used the .data directive to start the data segment of the program.
.data
	hello_msg BYTE "Hi, my name is Wikus and this is my first assmebly language program.",0
	goodbey_msg BYTE "Goodbey, I hope you enjoy the rest of your day.",0
	
	; Use these variables for user input.
	prompt_1 BYTE "Please enter your age: ",0
	prompt_2 BYTE 33 DUP(0)							; Declares an array of 256 bytes, each of the value 0.
	result_msg BYTE "Your age in dog years are: ",0		; You need to remember the null terminating character.
						
.data?													; We use this section of data to define uninitialized values.
	; Because I want to move these two variables to the eax register, I make them a 4-byte variable.
	; You need to have operands of the same size when using the mov instruction.
	user_age DWORD ?
	dog_years DWORD ?
	user_name BYTE 33 DUP(?)
						
.code 
main PROC							
		
	; 1. Print programmer's name.
	; The Crlf procedure calls a character return. Same as std::endl.
	; You must move the data from the string variable into edx to use the WriteString procdure.
	mov edx, OFFSET hello_msg				; mov the address of the hello_msg to edx.
	call WriteString						; Output the contents of the edx register.
	call Crlf								; Call a procedure that outputs the 'endline' charater.

	; 2. Get the input from the user.
	; WriteDec always outputs the value from the eax register.
	; OFFSET: The address of. Same as the & operator in C++.
	; I) - We ask the user to enter his/her age.
	mov edx, OFFSET prompt_1
	call WriteString
	
	; II) - We take the input from the user that is stored in the eax register and store it
	;		inside the one of our user defined variables.
	call ReadInt							; This procedure takes input from the console and stores
											;	it inside the eax register.
	mov user_age,eax						; We store the contents of the eax register inside a 4-byte variable.
	call WriteInt

	; For user input
	; You must specify the max size that you need to read. You must specify this value into ecx.
	;	- Remember that a string of size 33 bytes.

	; 3. Calculate the user's age in dog years.
	mov ebx,dog_year_const
	mov eax,user_age
	
	; mul: is an example of an instruction with an implied operand.
	;	- This will multiply the value of eax and ebx  
	;	- After this instruction, the value is stored in the eax register, ebx is unchanged,
	;		and the edx is set to zero.
	mul ebx
	mov dog_years,eax

	; 4. Print result.
	; You can move the value from the integer variable direclty to eax and do not need 
	;	to move the address. But using WriteString, you first need to assign the address of the character
	;	array.
	;	* Remember to always load the address of the string into the edx register before
	;		using the WriteString procedure.
	mov edx, OFFSET result_msg
	call WriteString
	mov eax,dog_years								; Notice that you dont need to user 'OFFSET'
	call WriteInt

	; 5. Say goodbey.
	mov edx, OFFSET goodbey_msg
	call WriteString
	call Crlf

	; For ReadInt you dont need to setup anything. You just need to retrieve the data from eax
	;	afterwards.


	INVOKE ExitProcess,0			; We call the ExitProcess procedure which is a windows service.
main ENDP							; We end the procedure called main.
END main							; This tells the assembler that we reached the end of the
									; source file and tells it where the entry point of the program
									; is.
