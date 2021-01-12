; Author: Lodewyk Jansen van Rensburg
; Date: Januray 11, 2021
; Filename: week2_data.asm
; Description: This program is used to study how to declare variab;es in assembly 
;				language and print them to the screen.

; 1. We first tell the assebler that this text file (source code) is a 
;		x86 assembly source file.
.386

; We comment this out because it is included inside the Irvine32.inc library.
;2. We run the program in the processor's protected mode.
.model flat,stdcall     ; This is the memory model that we specified.

; 3. We allocate memory in the main memory of the computer for the program's runtime stack.
.stack 4096				; 4096 bytes of memory.

; 4. Here we declare a prototype for the basic windows process called ExitProcess.
;		- Format of a prototype: function_name PROTO, input_parameters
ExitProcess PROTO, dwExitCode:DWORD

; We used the .data directive to start the data segment of the program.
.data
letter BYTE 'a'						; Here I defined the charater 'a'. This has the ascii representationf of 65
c_str BYTE 'P','r','i','n','t',0    ; Here we have access to the address of the first byte, but not the rest.
									;	- But we know that all the charaters after 'P' is store in a sequential
									;		block of memory. Therefore, if we add 1 to the address of 'P' we will
									;		get the address of 'r'. And so forth for the rest.

int_ar DWORD 0,1,2,3,4,5,6,7,8,9	; Here we stored an array of integers. Note that the max size
									; of an unsigned int is 2^8-1 = 255. This is the maximum value
									; that can be stored in this array.

ar_length = ($ - int_ar)/4			; Here we calculate the length of the array. The $ sign
									; gives us the current location of the stack pointer. So by taking
									; the difference between the start and the end of the array, we calculate
									; the number of bytes of the block of memory. Since a DWORD is 4 bytes large
									; we need to devide by 4 to obtain the number of elements in the array.
total DWORD 0						; We will store data from the array here.
; Now we want to see if we can store the values into the eax register and output it to the 
;	console. First we tell the assmebler that we will move from the data segment to the code
;	segment.
.code 

main PROC							; We start a procedure called main.
	
	mov eax,int_ar					; a. We move 0 to the eax register.
	add total,eax				; Adding all the integers in the array.
	add int_ar,1					; - We move 4 bytes onwards to the next value in memory.
	
	mov eax,int_ar					; b. We store the value of 1 in the eax register.
	add total,eax
	add int_ar,1

	mov eax,int_ar
	add total,eax
	add int_ar,1

	mov eax,ar_length				; I want to see the length of the array. 

	INVOKE ExitProcess,0			; We call the ExitProcess procedure which is a windows service.
main ENDP							; We end the procedure called main.
END main							; This tells the assembler that we reached the end of the
									; source file and tells it where the entry point of the program
									; is.
