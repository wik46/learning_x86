;// Author: Lodewyk Jansen van Rensburg
;// Last modeifed: February 25,2021
;// Course: CS 271
;// Assignment 5
;// Description: This is program that implements a recursive merge sort algorithm
;//					The program fills an array with n number of random integers, sorts it in
;//					descending order (largest first) and then ouputs it to the command prompt.

INCLUDE		Irvine32.inc

.386
.model		stdcall, flat
.stack	4096
ExitProcess		PROTO, dwExitCode:DWORD

;// Macro's
one_parameter		= 4
two_parameters		= 8
three_parameters24	= 12
four_parameters32	= 16
MAX_SIZE			= 200
MAX_CHAR    EQU		  256
lo					= 100
hi					= 999
min					= 15
max					= 200

.data
;// Used for introduction.
user_name		BYTE	MAX_CHAR dup(? )
user_input		DWORD	?

;// Variables used for needed the MergeSort32 procedure.
Temp32			DWORD	MAX_SIZE	DUP(0)
MergeTest32		DWORD	MAX_SIZE	DUP(5)
left_key		DWORD	0
middle_key		DWORD ?
right_key		DWORD	200
;// Headings for printArray32
unsorted_msg	BYTE	"Unsorted Array of Integers:", 0dh, 0ah, 0
sorted_msg		BYTE	"Sorted Array of Integers - sorted with a Recursive Merge Sort Algorithm:", 0dh, 0ah, 0

.code
main	PROC
	
	;// 1. Program Introduction.
	mov		edx, OFFSET user_name		;// Setup for sayHello to store the username.
	call	sayHello

	;// 2. Retrieve and Validate Data.
	call	Crlf
	push	OFFSET user_input
	call	valData						;// Valid integer is inside parameter passed on the stack the stack.

	;// 3. Working with the data:
	;// Part 1: Fill the array with random integers.
	call		Randomize						;// Irvine procedure to seed random number generator.
	push		OFFSET	MergeTest32
	push		user_input						;// Replace with the user validated number.
	call		fillArray

	;// Part 2: Print the array of integers.
	push		OFFSET  unsorted_msg			;// See top of program for string contents.
	push		OFFSET	MergeTest32
	push		user_input						;// Replace with the user validated integer.
	call		printArray32

	;// Part 3: We sort the MergeTest32 array in deceinding order using recursive merge sort implementation.
	push		OFFSET  Temp32			;// This array is only used as a temporary container while sorting.
	push		OFFSET	MergeTest32		;// [ebp + 16]
	push		left_key				;// [ebp + 12]
	push		right_key				;// [ebp + 8]
	call		MergeSort32
	call		Crlf

	;// Part 4: Display the median after the array was sorted.
	push		OFFSET	MergeTest32
	push		user_input
	call		PrintMedian
	call		Crlf

	;// Part 5: Print the array of integers after sorting.
	push		OFFSET  sorted_msg		;// See top of program for string contents. This is the header if the list/array.
	push		OFFSET	MergeTest32
	push		user_input				;// The number of elements in the array.
	call		printArray32

	;// 4. Terminate Program
	mov			edx, OFFSET user_name	;// User's name needed for termination message.
	call		sayGoodbey


	INVOKE	ExitProcess, 0
main	ENDP

;// Procedure: MergeSort32
;// Description: This procedure take an array of 32-bit elements and sorts them in descending order. ( The order in which
;//					they are sorted depends on the setting in Merge32.)
;//				 We implement a recursive merge sort which is a divide and conquer algorithm.
;// Receives: * Parameter1: Address toa temporary container with same size as original array.
;//			  * Parameter2: Address to the original array.
;//			  * Parameter3: The base-key used to identify the leftmost element in the original array.
;//			  * Parameter4: The base-key to identify the rightmost element in the original array.
;// Returns: The array passed to the procedure is sorted from largest value to smallest value.
;// Pre-conditions:	* Merge32: This is a helper procedure that needs to be defined to use MergeSort32. See
;//								procedure header of Merge32 for details on its implentation.
;//					* All three parameters needed by MergeSort32 needs to be passed on the stack in and pushed 
;//						onto the stack before calling MergeSort32. 
;//					* Order in which the parameters should be pushed: Array offset, left key, and right key.
;//	Post-conditions: No clean up of system stack is need after the procedure returns to the scope it was called.
;//				     Any registers used by the procedure will be stored and return to the value before the procedure
;//					 was called.
MergeSort32		PROC
	.data
	two			DWORD	2
	middle		DWORD	?
	.code
	;// 1. Setting up the stackframe
	push	ebp
	mov		ebp, esp
	;// 2. Storing general purpose registers.
	push	eax
	push	ebx
	push	ecx
	push	edx
	push	edi
	push	esi
	;// 3. Storing parameters in general purpose register for later use.
	mov		ebx, [ebp + 12]			;// Value of left key.
	mov		edx, [ebp + 8]			;// Value of right key

	;// If left_key < right_key => left
	cmp		ebx, edx
	jnl		Else1
	;// NOW WE DIVIDE AND CONQUER.
	;// We need the middle of the array to split it.
	;// *** middle = left + (right - left)/2 ***
	mov		eax, edx				;// eax = right_key			
	sub		eax, ebx				;// eax = right_key - left_key
	cdq
	div		two;// eax = (right_key - left_key) / 2
	;// Remember that edx = 0.
	add		eax, ebx				;// eax = left_key + (right_key - left_key) / 2
	mov		middle, eax

	;// A: Divide.******************************************
	;// We push and pop the middle value since every subroutine changes it.
	push		middle
	;// I: Left-sub array is Array[left_key: middle_key]
	push		[ebp + 20]		;// The address to the temporary container. 
	push		[ebp + 16]		;// Array Offset.
	push		[ebp + 12]		;// Left_key
	push		middle			;// Right_key
	call		MergeSort32
	pop			middle
	;// II: Right-sub array is Array[middle_key + 1: right_key]
	push		middle
	push		[ebp + 20]		;// The address to the temporary container. 
	push		[ebp + 16]		;// Array Offset.
	inc			middle
	push		middle			;// Left_key
	push		[ebp + 8]		;// Right_key
	call		MergeSort32
	pop			middle
	;// B: Conquer. ****************************************
	push		middle
	;// -------------------------------------------------------
	;// This array must have the same number of elements as the unsorted array.
	push		[ebp + 20]		;// This is the address to the temporary container to help with merge.
	;// -------------------------------------------------------
	push		[ebp + 16]		;// [ebp + 20 + 32 - 4 ]
	push		[ebp + 12]		;// [ebp + 16 + 32 - 4 ]
	push		middle			;// [ebp + 12 + 32 - 4 ]
	push		[ebp + 8]		;// [ebp + 8 + 32 - 4 ]
	call		Merge32
	pop			Middle
	;// Else: by definition an array of 1 element is sorted.
	Else1:

	;// Restoring general purpose registers.
	pop		esi
	pop		edi
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
	;// Preping the stack for "return to caller".
	mov		esp, ebp
	pop		ebp
	ret		four_parameters32					

MergeSort32		ENDP

;// Procedure: Merge32
;// Description: This is a helper procedure to the larger merge procedure. 
;//					This procedure takes two sorted arrays and merge them together as one large sorted array.
;// Receives: Offset of array, left_key, middel_key, and right_key.
;//				Example the left_key is the leftmost index of the array. Most of the time the procedure
;//				merges two smaller sub arrays of one larger one. Remember that left_key is very seldom 0.
;// Returns: The part of the array from element [left_key, right_key] is merged and this section of the array
;//				is sorted.
;// Pre-conditions: The prodedure does no error checking on the parameters passed on the stack.
;//					The procedure makes use of many eax, .. but takes responsibilty of restoring them.
;//					Needs an array of same size to use with temporary storage.
;// Note: edi = base index for left sub array, esi = base index for right sub array, edx = original array offset.
Merge32	PROC
	.data
	left_ar_length			DWORD ?
	right_ar_length			DWORD ?
	left_ar_walker			DWORD	0
	right_ar_walker			DWORD	0
	original_ar_walker		DWORD	0
	.code
	;// Setup stackframe.
	pushad;// We push all the general purpose registers onto stack in order eax, ebx, ...
	mov		ebp, esp
	;// We use edx to store the address of the first element.
	mov		eax, [ebp + 24 + 32 - 4];// We ge the address of the first element in the tmp storage array.
	mov		edx, eax
	;// We find the two base indices for the sub-arrays.
	;// Left Sub Array. [left: middle]
	mov		eax, [ebp + 20 + 32 - 4]		;// Base of the array.
	mov		ebx, [ebp + 16 + 32 - 4]		;// Left key's address.
	imul	ebx, ebx, 4
	add		eax, ebx
	mov		edi, eax;// edi = base index of left sub array. (Offset of its first element.)
	;// Right Sub Array. [middle + 1: right]
	mov		eax, [ebp + 20 + 32 - 4]
	mov		ebx, [ebp + 12 + 32 - 4]		;// middel+1 key's address.
	inc		ebx
	imul	ebx, ebx, 4
	add		eax, ebx
	mov		esi, eax						;// esi = base index of right sub array. (Offset of its first element.)

	;// We need to calculate the length of the left and right sub arrays.
	;// a.)	left_ar_length = middle_key - left_key + 1
	mov		eax, [ebp + 12 + 32 - 4]
	sub		eax, [ebp + 16 + 32 - 4]
	inc		eax
	mov		left_ar_length, eax
	;// b.) right_ar_length = right_key - middle_key
	mov		eax, [ebp + 8 + 32 - 4]
	sub		eax, [ebp + 12 + 32 - 4]
	mov		right_ar_length, eax

	;// Explanation of intuitively thinking of the next block of code.
	;// --------------------------------------------------------------
	;// This part of the procedure is the two finger algorithm part.
	;// The idea is that we look at both arrays' elemets at index 0. We take the largest element and increment its
	;// index. We then look at the second element in the array we took one from an the first element of the untouched 
	;//	array. We again take the largest and walk along to the next element in the array we took from. We continue
	;// this process untill the first array lost all its elements. Afterwards we fill the rest of the original
	;// array with the remaining elements of the other array if there are any. We take the largest element every time 
	;// because we are sorting the array in descending order. (Largest first)
	While_loop:
		;// I: We exit the loop when the first array has no more elements left.
		mov		eax, left_ar_length
		cmp		left_ar_walker, eax
		jge		End_Part1
		mov		eax, right_ar_length
		cmp		right_ar_walker, eax
		jge		End_Part1
		;// II: We search for the largest element in the two sorted arrays because we are sorting in descending order.
		mov		eax, [esi]
		cmp[edi], eax;// ar_left[i] > ar_right[j] ??
		jl		next
		;// 1. Here we insert element in the left array into temporary array
		mov		eax, [edi]
		mov[edx], eax;// edx needs to point to first element in this section
		;// 2. Walk along left array
		add		edi, 4;// Traversing to the next element in the left sub array.
		inc		left_ar_walker;// Used to keep track so that we dont walk pass the end.
		jmp		End_iteration
		next :
		;// 1. Here we insert element in the right array into temporary array
		mov		eax, [esi]
		mov[edx], eax
		;// 2. Walk along right sub array
		add		esi, 4;// Traversing to the next element in the right sub array.
		inc		right_ar_walker;// Used to keep track so that we dont walk pass the end.

		End_iteration:
		inc		original_ar_walker
		add		edx, 4;// Increment where in the original array we are.

		jmp		While_loop;

		End_Part1:

		;// Part 2: Now you need to insert the last few elements that is sill in one of the arrays.
		;// The case exist where lets say the left array had all the largest elements. The our algorithm will stop
		;// witht the elements in the left array insterted, but we still need to insert the elements in the right sub array
		;// into the temporary container. This part ensures that we insert all the elements.

		;// A: Left sub-array.
		LeftSubArray:
		mov		eax, left_ar_length
		cmp		left_ar_walker, eax
		jge		RightSubArray

		;// 1. Here we insert element in the left array into temporary array
		mov		eax, [edi]
		mov[edx], eax;// edx needs to point to first element in this section
		;// 2. Walk along left array
		add		edi, 4;// Traversing to the next element in the left sub array.
		inc		left_ar_walker;// Used to keep track so that we dont walk pass the end.
		inc		original_ar_walker
		add		edx, 4;// Increment where in the temporary array we are.

		jmp LeftSubArray

		;// B: Right sub-array. (We will enter loop if there are still some elements in the right sub array.)
		RightSubArray:
		mov		eax, right_ar_length
		cmp		right_ar_walker, eax
		jge		End_Part2

		;// 1. Here we insert element in the right array into temporary array
		mov		eax, [esi]
		mov[edx], eax
		;// 2. Walk along right sub array
			add		esi, 4				;// Traversing to the next element in the right sub array.
			inc		right_ar_walker		;// Used to keep track so that we dont walk pass the end.
			inc		original_ar_walker
			add		edx, 4				;// Increment where in the temporary array we are.
			jmp		RightSubArray

		End_Part2 :

	;// Part 3: We replace the segment in the array that contained the 2 sorted arrays with the now
	;//			1 sorted array. That is we copy the order that the elements are in the temporary storage over
	;//			to the segement where the elements were stored in the original array.

	;// This first block we calculate the number of elements that is in the segment we just sorted.
	mov		ecx, [ebp + 8 + 32 - 4]
	mov		ebx, [ebp + 16 + 32 - 4]	;// ----- change 
	sub		ecx, ebx					;// Number of elements = right index - left index + 1.
	inc		ecx					;// Now we can loop through temporary container and insert elements into original array
	;// in correct order.

	;// We find the pointer to the first element in the segment of the original array and a pointer to the
	;//		first element in the temporary container so that we can copy the temporary container that has the correct
	;//		order of the elements into the segment we are sorting.
	mov		eax, [ebp + 20 + 32 - 4]	;// Base of the array.
	mov		ebx, [ebp + 16 + 32 - 4]	;// Left key's index.
	imul	ebx, ebx, 4
	add		eax, ebx
	mov		edi, eax					;// Edi points to the start of the segement in the original array.
	mov		edx, [ebp + 24 + 32 - 4]	;// Edx points to the first element in the temporary container.

	;// ******************************************
	;// This loops should not iterate if left index == right index
	;// ******************************************
	;// Now we insert the elements into the original array in descending order.
	FromTempToOriginal:
	mov		eax, [edx]
	mov[edi], eax						;// array[i] = temp[i] , for i = 1,2,3,...,n where n is the # of elements.
	;// temp[i] = 0
	add		edi, 4
	add		edx, 4
	LOOP	FromTempToOriginal

	;// Resetting the our walker's
	;// I walker is used by a sub array alongside the length to keep track that we dont access elements out of range.
	push	eax
	mov		eax, 0
	mov		left_ar_walker, eax
	mov		right_ar_walker, eax
	pop		eax
	;// Prepare stackframe for "return to caller".
	mov		esp, ebp
	popad						;// We pop all the general purpose registers of the stack in reverse order than pushad.
	ret		four_parameters32
Merge32	ENDP


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
	push	ebp;// Base index created for stack frame/ activation-record.
	mov		ebp, esp
	;// Accesing parameters passed on the stack.
	mov		ecx, [ebp + 8];// This is the number of random ints that my array will contain. 
	;// Assuming 1 <= [ebp + 8 ] <= max_storage.
	mov		ebx, [ebp + 12];// "Pointer" to the first element in the array.
	mov		esi, 0;// Will be used to traverse trough the array.

	push	edx
	push	edi
	;// Filling the array with random numbers.
	fillLoop:
	mov		eax, hi
	sub		eax, lo
	inc		eax
	call	RandomRange;// Storing a 32-bit random number in eax ( range [0;899])
	add		eax, lo;// Range is now [100; 999].

	mov[ebx + esi], eax
	add		esi, 4
	LOOP	fillLoop
	pop		edx
	pop		edi
	;// Preparing for procedure return.
	mov		esp, ebp
	pop		ebp
	ret		two_parameters;// ret decrements the stack pointer by 4 and then by the number 8 specified.
fillArray	ENDP

;// Procedure: printArray32
;// Description: This procedure takes two parameters on the stack and prints the contents of
;//					a 32 bit integer array to the console. 
;//	Receives: Parameter1 (ebx+8): The number of elements in the array that needs to be printed.

printArray32	PROC
	elements_per_row = 10
	reset = 0
	.data
	newline_tracker			DWORD	?			;// Used to format ouput. 
	tab1					BYTE	9, 0		;// Distance between int output.
	.code
	;// Setting up stack frame.
	push	ebp;// Base index created for stack frame/ activation-record.
		mov		ebp, esp
		;// Accesing parameters passed on the stack.
		mov		ecx, [ebp + 8];// This is the number of random ints that my array will contain. 
		;// Assuming 1 <= [ebp + 8 ] <= max_storage.
		mov		ebx, [ebp + 12];// "Pointer" to the first element in the array.
		mov		esi, 0;// Will be used to traverse trough the array.
		mov		edx, OFFSET tab1
		;// WriteInt prints the contents at eax to the console window.
		mov		newline_tracker, reset
	call	Crlf
	;// Printing the heading.
	push	edx
	mov		edx, [ebp + 16]					;// Moving the offset of the string we want as the heading.
	call	WriteString
	pop		edx			
	PrintLoop:
		;// We print the elements 10 per row.
		cmp		newline_tracker, elements_per_row
		jne		next
		call	Crlf
		mov		newline_tracker, reset

	next :
		;// Print an element.
		mov		eax, [ebx + esi]
		call	WriteInt
		call	WriteString
		add		esi, 4
		inc		newline_tracker
	LOOP	PrintLoop
	;// Tidying up the format.
	call	Crlf
	;// Preparing for procedure return.
	mov		esp, ebp
	pop		ebp
	ret		three_parameters24			;// ret decrements the stack pointer by 4 and then by the number 12 specified.
printArray32		ENDP

;// Procedure: PrintMedian
;// Description: This procedure accepts the address of a sorted array and calculates the median value for the array.
;//				 If the array has an even number of elements the median is the average between the two middle values.
;// Receives: The address of an array passed as a parameter on the stack.
;//			   * esi = OFFSET array
;//			   * edi = number of elements
;//
;// Returns: Prints the median of the array.
;// Pre-conditions: All registers are stored and returned to normal values after procedure return to caller.
;//					* The procedure does not do error checking and assumes length of the array > 0.

PrintMedian		PROC
	.data
	median_msg	BYTE	"The median of the array is: ", 0
	.code
	;// Setting up the stackframe
	pushad
	mov		ebp, esp
	;// Storing offset of the array.
	mov		esi, [ebp + 12 + 32 - 4]
	mov		edi, [ebp + 8 + 32 - 4]

	;// Calculating the median.
	mov		eax, edi
	mov		ebx, 2							;// Division by two will give us the half way mark
	cdq
	div		ebx
	cmp		edx, 0 
	je		Case2
	;// Case 1: The array has an odd number of elements.
	mov		edx, OFFSET		median_msg
	imul	eax, 4						;// Size of the elements is 4 bytes.
	add		esi, eax					;// Indirect address referencing.
	mov		eax, [esi]		
	call	WriteString
	call	WriteInt
	call	Crlf
	jmp		Ending
	;// Case 2: The array has am even number of elements.
	Case2:

	;// We take the average between the two middle values.
	imul	eax, 4;// Size of the elements is 4 bytes.
	add		esi, eax;// Indirect address referencing.
	mov		eax, [esi]
	sub		esi, 4
	add		eax, [esi]
	cdq
	div		ebx						;// eax = median.				
	mov		edx, OFFSET		median_msg
	call	WriteString
	call	WriteInt
	call	Crlf
	Ending:
	;// Restoring the stackframe
	mov		esp, ebp
	popad
	ret		one_parameter
PrintMedian		ENDP



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
	prog_info			BYTE "Welcome to Fun with Mr. M. Sorter written by "
	programmer_name		BYTE "Lodewyk Jansen van Rensburg.", 0dh, 0ah, 0
	prompt_name			BYTE 0dh, 0ah, "Please enter your name: ", 0
	prompt_welcome		BYTE "Nice to meet you, ", 0 
	header_msg			BYTE 0dh, 0ah, "Guidline for Program use:", 0dh, 0ah
	info_msg			BYTE 0dh, 0ah, "1. You must enter an integer n within the given range.", 0dh, 0ah,
							 "2. I will ensure n is in the range and print n random numbers.", 0dh, 0ah,
							 "3. I wil then sort the array in descending order. (Merge Sort Algorithm).", 0dh, 0ah,
							 "4. Futhermore, I will print the median of the array and the newly sorted array.", 0dh, 0ah,
							 "5. Lastly, I will great you and whish you well for the rest of the day.", 0dh, 0ah,0
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
	;// Information message.
	
	mov		edx, OFFSET header_msg
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
;// Post-conditions: The parameter passed onto the stack contains the valid integer. 

valData PROC
	.data
	prompt1			BYTE "Enter integer in range [", 0
	comma			BYTE", ",0
	right_bracket	BYTE "]: ",0
	invalid_msg		BYTE 0dh, 0ah, "[** Warning **]: Integer out of range.", 0dh, 0ah, 0
	ending_msg		BYTE 0dh, 0ah, "[** Note **]: Non-negative number was entered: ",0
	.code
	;// Seting up the stack frame
	push	ebp
	mov		ebp, esp
	push	eax
	;// Case 1: x < lower_limit ( => reprompt)
	Validation:
		;// Entire block is used to output the message specifying the range of input.	
		mov		edx, OFFSET prompt1
		call	WriteString
		mov		eax, min
		call	WriteInt
		mov		edx, OFFSET comma
		call	WriteString
		mov		eax, max
		call	WriteInt
		mov		edx, OFFSET right_bracket
		call	WriteString

		call	ReadInt
	;// Is input less than lower limit?
	cmp		eax, min
	jl		Invalid
	;// Is input greater than upper limit?
	cmp		eax, max
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

	;// Setting up system stack for returning to the caller.
	mov		edx, [ebp + 8]						;// Here we store the value of the valid integer at the address
												;// passed to the user.
	mov		[edx], eax

	pop		eax
	mov		esp, ebp
	pop		ebp
	ret		one_parameter						;// Pops the return address into the instruction pointer,
												;// and decrements the stack pointer by 4 + 4.
valData ENDP

END		main

