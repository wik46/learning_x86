;// Author: Wikus Jansen van Rensburg
;// Last modeifed: February 18,2021
;// Description: This is program that implements a recursive merge sort algorithm
;//					The program fills an array with n number of random integers, sorts it in
;//					descending order (largest first) and then ouputs it to the command prompt.

INCLUDE		Irvine32.inc

.386
.model		stdcall, flat
.stack	4096
ExitProcess		PROTO, dwExitCode:DWORD

;// Macro's
two_parameters = 8
three_parameters24 = 12
four_parameters32 = 16
MAX_SIZE = 200
.data
num_elem		DWORD	200		;// For testing we choose 15 randomly.
IntArray32		DWORD	MAX_SIZE	DUP(?)
;// Variables used for testing the Merge procedure.
Temp32			DWORD	MAX_SIZE	DUP(0)
MergeTest32		DWORD	MAX_SIZE	DUP(5)
left_key		DWORD	0
middle_key		DWORD	?
right_key		DWORD	200

.code
main	PROC
	;// Fillin the array for testing.
	mov		eax, 57
	mov		MergeTest32[0*4], eax
	mov		eax, 1
	mov		MergeTest32[1*4], eax
	mov		eax, 56
	mov		MergeTest32[2*4], eax
	mov		eax, 8555
	mov		MergeTest32[3*4], eax
	mov		eax, 17
	mov		MergeTest32[4*4], eax
	mov		eax, 25
	mov		MergeTest32[5*4], eax


	;// Part 1: Fill the array with random integers.
	call		Randomize								;// Irvine procedure to seed random number generator.
	
	push		OFFSET	MergeTest32
	push		num_elem	
	call		fillArray

	;// Part 2: Print the array of integers.
	push		OFFSET	MergeTest32
	push		num_elem
	call		printArray32

	;// Part 3: Testing merge on two arrays.
	;push		OFFSET	Temp32;// [ebp + 24 + 32 - 4], this is temporary storage to hold elements in merge.
	; push		OFFSET	MergeTest32;// [ebp + 20 + 32 - 4 ]
	; push		left_key;// [ebp + 16 + 32 - 4 ]
	; push		middle_key;// [ebp + 12 + 32 - 4 ]
	; push		right_key;// [ebp + 8 + 32 - 4 ]
	; call		Merge32

	;// Part 4: We test to see if MergeSort32 works.
	push		OFFSET	MergeTest32		;// [ebp + 16]
	push		left_key				;// [ebp + 12]
	push		right_key				;// [ebp + 8]
	call		MergeSort32

	call Crlf
	;// Part 5: Print the array of integers after sorting.
	push		OFFSET	MergeTest32
	push		num_elem
	call		printArray32


	call	Crlf
	

	INVOKE	ExitProcess, 0
main	ENDP

;// Procedure: MergeSort32
;// Description: This procedure take an array of 32-bit elements and sorts them in descending order. ( The order in whuch
;//					they are sorted depends on the setting in Merge32.)
;//				 We implement a recursive merge sort which is a divide and conquer algorithm.
;// Receives: * Parameter1
;//			  * Parameter2
;//			  * Parameter3
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
	; mov		esi, [ebp + 16];// Pointer to first element in array.
	mov		ebx, [ebp + 12]			;// Value of left key.
	mov		edx, [ebp + 8]			;// Value of right key

	;// If left_key < right_key => left
	cmp		ebx, edx
	jnl		Else1
	;// NOW WE DIVIDE AND CONQUER.
	;// We need the middle of the array to split it.
	;// *** middle = left + (right - left)/2 ***
	mov		eax, edx			;// eax = right_key			
	sub		eax, ebx			;// eax = right_key - left_key
	cdq							
	div		two					;// eax = (right_key - left_key) / 2
	;// Remember that edx = 0.
	add		eax, ebx			;// eax = left_key + (right_key - left_key) / 2
	mov		middle, eax
	
	;// A: Divide.******************************************
	;// We push and pop the middle value since every subroutine changes it.
	push		middle
	;// I: Left-sub array is Array[left_key: middle_key]
	push		[ebp + 16]			;// Array Offset.
	push		[ebp + 12]			;// Left_key
	push		middle				;// Right_key
	call		MergeSort32
	pop			middle
	;// II: Right-sub array is Array[middle_key + 1: right_key]
	push		middle
	push		[ebp + 16]			;// Array Offset.
	inc			middle
	push		middle					;// Left_key
	push		[ebp + 8]				;// Right_key
	call		MergeSort32
	pop			middle			
	;// B: Conquer. ****************************************
	push		middle
	push		OFFSET	Temp32		;// [ebp + 24 + 32 - 4], this is temporary storage to hold elements in merge.
	push		[ebp + 16]			;// [ebp + 20 + 32 - 4 ]
	push		[ebp + 12]			;// [ebp + 16 + 32 - 4 ]
	push		middle			;// [ebp + 12 + 32 - 4 ]
	push		[ebp + 8]			;// [ebp + 8 + 32 - 4 ]
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
	ret		three_parameters24
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
	left_ar_length			DWORD	?
	right_ar_length			DWORD	?
	left_ar_walker			DWORD	0
	right_ar_walker			DWORD	0
	original_ar_walker		DWORD	0
	.code
	;// Setup stackframe.
	pushad					;// We push all the general purpose registers onto stack in order eax, ebx, ...
	mov		ebp, esp
	;// We use edx to store the address of the first element.
	mov		eax, [ebp + 24 + 32 - 4]			;// We ge the address of the first element in the tmp storage array.
	mov		edx, eax
	;// We find the two base indices for the sub-arrays.
	;// Left Sub Array. [left: middle]
	mov		eax, [ebp + 20 + 32 - 4]			;// Base of the array.
	mov		ebx, [ebp + 16 + 32 - 4]			;// Left key's address.
	imul	ebx, ebx, 4
	add		eax, ebx
	mov		edi, eax					;// edi = base index of left sub array. (Offset of its first element.)
	;// Right Sub Array. [middle + 1: right]
	mov		eax, [ebp + 20 + 32 - 4]
	mov		ebx, [ebp + 12 + 32 - 4]			;// middel+1 key's address.
	inc		ebx
	imul	ebx, ebx, 4
	add		eax, ebx
	mov		esi, eax					;// esi = base index of right sub array. (Offset of its first element.)

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
	cmp		[edi], eax					;// ar_left[i] > ar_right[j] ??
	jl		next
		;// 1. Here we insert element in the left array into temporary array
		mov		eax, [edi]
		mov		[edx], eax					;// edx needs to point to first element in this section
		;// 2. Walk along left array
		add		edi, 4							;// Traversing to the next element in the left sub array.
		inc		left_ar_walker					;// Used to keep track so that we dont walk pass the end.
	jmp		End_iteration
	next:
		;// 1. Here we insert element in the right array into temporary array
		mov		eax, [esi]
		mov		[edx], eax
		;// 2. Walk along right sub array
		add		esi, 4							;// Traversing to the next element in the right sub array.
		inc		right_ar_walker					;// Used to keep track so that we dont walk pass the end.
		
	End_iteration:
		inc		original_ar_walker
		add		edx, 4										;// Increment where in the original array we are.

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
		mov		[edx], eax					;// edx needs to point to first element in this section
		;// 2. Walk along left array
		add		edi, 4							;// Traversing to the next element in the left sub array.
		inc		left_ar_walker					;// Used to keep track so that we dont walk pass the end.
		inc		original_ar_walker
		add		edx, 4							;// Increment where in the temporary array we are.

	jmp LeftSubArray

	;// B: Right sub-array. (We will enter loop if there are still some elements in the right sub array.)
	RightSubArray:
	mov		eax, right_ar_length
	cmp		right_ar_walker, eax
	jge		End_Part2

	;// 1. Here we insert element in the right array into temporary array
		mov		eax, [esi]
		mov		[edx], eax
		;// 2. Walk along right sub array
		add		esi, 4							;// Traversing to the next element in the right sub array.
		inc		right_ar_walker					;// Used to keep track so that we dont walk pass the end.
		inc		original_ar_walker
		add		edx, 4						;// Increment where in the temporary array we are.
		jmp		RightSubArray

		End_Part2:
	
	;// Part 3: We replace the segment in the array that contained the 2 sorted arrays with the now
	;//			1 sorted array. That is we copy the order that the elements are in the temporary storage over
	;//			to the segement where the elements were stored in the original array.

	;// This first block we calculate the number of elements that is in the segment we just sorted.
	mov		ecx, [ebp + 8 + 32 - 4]
	mov		ebx, [ebp + 16 + 32 - 4] ;// ----- change 
	sub		ecx, ebx	;// Number of elements = right index - left index + 1.
	inc		ecx			;// Now we can loop through temporary container and insert elements into original array
						;// in correct order.

	;// We find the pointer to the first element in the segment of the original array and a pointer to the
	;//		first element in the temporary container so that we can copy the temporary container that has the correct
	;//		order of the elements into the segment we are sorting.
	mov		eax, [ebp + 20 + 32 - 4]			;// Base of the array.
	mov		ebx, [ebp + 16 + 32 - 4]			;// Left key's index.
	imul	ebx, ebx, 4
	add		eax, ebx
	mov		edi, eax						;// Edi points to the start of the segement in the original array.
	mov		edx, [ebp + 24 + 32 - 4]		;// Edx points to the first element in the temporary container.

	;// ******************************************
	;// This loops should not iterate if left index == right index
	;// ******************************************
	;// Now we insert the elements into the original array in descending order.
	FromTempToOriginal:
		mov		eax, [edx]
		mov		[edi], eax			;// array[i] = temp[i] , for i = 1,2,3,...,n where n is the # of elements.
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
	popad					;// We pop all the general purpose registers of the stack in reverse order than pushad.
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

;// Filling the array with random numbers.
fillLoop:
	call	Random32;// Storing a 32-bit random number in eax.


	mov[ebx + esi], eax
	add		esi, 4
	LOOP	fillLoop

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
newline_tracker		DWORD reset;// Used to format ouput. 
tab1					BYTE	9, 0;// Distance between int output.
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

;// Preparing for procedure return.
mov		esp, ebp
pop		ebp
ret		two_parameters;// ret decrements the stack pointer by 4 and then by the number 8 specified.
printArray32		ENDP


END		main
© 2021 GitHub, Inc.
