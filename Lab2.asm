Title Lab 2: Adding 3 Numbers

;	*************************************************
;	* Name: Seth Urbach								*
;	* Lab Exercise: Lab #2							*
;	* Date Started: July 1, 2002					*
;	* Date Last Modified: July 2, 2002 - 10:50 PM	*
;	* Date Due: July 5, 2002						*
;	*												*
;	* Program Description:							*
;	*	This lab prompts the user to enter in 3 	*
;	*	numbers. The Program then adds those three 	*
;	*	numbers together and displays the sum to	* 
;   *	the user.									*
;	*************************************************

.model small
	LEN		equ	15 
	CR		equ	0dh
	LF		equ	0ah
	string	EQU  [bp+4]
	number	EQU  [bp+6]

.stack 100h

.data
	sum		dw	00h
	prompt	db	"Enter in a number: " ,CR, LF, 0
	msg1	db	"You are adding together 3 Numbers. Press return after each number is entered." ,CR, LF, 0
	msg2	db	"The sum of the three numbers is : " ,CR, LF, 0

.code

Start:
	mov AX, @data
	mov ds, AX
	mov CX, 03h

PrtDisp:
	push offset msg1			; Stores the message location on the stack
	call NewLine				; Displays a new line
	call PUTSTR					; Displays program description string
	call NewLine				; Displays a new line

GetNums:
	push offset prompt			; Stores the message location on the stack
	call PUTSTR					; Displays input prompt
	call GETSTR
	call ATOI					; Converts number string to an integer
	add sum, AX
	dec CX
	cmp CX, 00
	jne GetNums

PrtSum:
	push offset msg2			; Stores the message location on the stack
								;		for the sum display
	call PUTSTR					; Displays input prompt
	push sum					; Save the number in sum to the stack
	call ITOA					; Converts number string to an integer
;	mov number, DX
	push number
	call PUTSTR
	jmp Prt


NewLine proc near
	mov ah, 02h				; print two newlines (i.e. CR + LF + LF)
	mov dl, CR					
	int 21h
	mov dl, LF
	int 21h
	int 21h
	ret
	
NewLine endp


;------------------------------------------------------------
; getstr - read ASCII char string from console keyboard; uses
;          DOS int 21h, function 1, to read chars & echo them
;          to screen
; entry condition:  output ASCII string address held in
;                   argument on stack
; exit condition:  entered string null terminated and stored
;                  at specified address 
;

getstr proc near
	push bp
	mov bp, sp
	push bx
	push ax
	push dx

	mov bx, string			; address of output string [bp+4]
	mov ah, 01h				; use function 1 of INT 21h

GetLoop:
	int 21h 				; wait for char from keyboard
	cmp al, CR				; end of input? (char = CR)
	je	GetEnd
	mov [bx],al 			; save char in string
	inc bx					; point to next char position
	jmp GetLoop

GetEnd:
	mov byte ptr [bx], 0	; CR is converted to null
	mov ah, 02h				; print a newline (i.e. CR + LF)
	mov dl, CR					
	int 21h
	mov dl, LF
	int 21h
	
	pop dx
	pop ax
	pop bx
	pop bp
	ret

getstr endp


;------------------------------------------------------------
; putstr - write ASCIIZ char string to console screen; uses
;          DOS int 21h, function 2, to send chars to screen
; entry condition:  input ASCIIZ string address held in
;                   argument on stack
; exit condition:  none 
;

putstr proc near

	push bp
	mov bp, sp
	push bx
	push ax
	push dx

	mov bx, string			; address of input string [bp+4]
	mov ah, 2

PrtLoop:
	cmp byte ptr [bx], 0	; end of string?
	je PrtEnd
	mov dl, byte ptr [bx]	; grab char from string
	int 21h 				; send to screen
	inc bx					; next char
	jmp PrtLoop

PrtEnd:
	pop dx
	pop ax
	pop bx
	pop bp
	ret

putstr endp


;------------------------------------------------------------
; atoi - Convert ASCIIZ char string to integer
; entry condition:  output value address held in first
;                   argument on stack, and input ASCIIZ
;                   string address in second argument
; exit condition:  output value (word) stored at address in
;                  first argument
;

atoi proc near

	push bp
	mov bp, sp
	push bx
;	push ax
	push dx
	push si
	push di

	mov si, 0				; store sign in si: 0=+ and -1=-
	mov bx, string			; point to input string
	cmp byte ptr [bx], '+'	; check for a + sign
	jne checkNeg			; if no +, check for a - sign
	inc bx					; point to first digit
	jmp short firstDigit

checkNeg:					; check for a - sign
	cmp byte ptr [bx], '-'
	jne firstDigit			; if no -, start conversion
	mov si, -1				; if - sign, set si to -1
	inc bx					; point to first digit

firstDigit: 				; start conversion
	mov ax, 0
	mov di, 10				; load number base into di

convertLoop1:
	cmp byte ptr [bx], '0'	; digit?
	jl	endConvert			; (assumes null terminator)
	cmp byte ptr [bx], '9'
	jg	endConvert
	mul di
	mov dx, 0
	mov dl, [bx]			; move contents of bx to dl
	sub dl, '0' 			; convert ASCII code to digit value
	add ax, dx
	inc bx					; point to next digit
	jmp convertLoop1

endConvert:
	cmp si, 0				; check sign flag
	je	notNeg
	neg ax					; make number negative

notNeg: 					; done
	mov bx, number
	mov word ptr [bx], ax

	pop di
	pop si
	pop dx
;	pop ax
	pop bx
	pop bp
	ret

atoi endp


;------------------------------------------------------------
; itoa - Convert integer to ASCIIZ char string
; entry condition:  input integer address held in first
;                   argument on stack, and output string
;                   address in second argument 
; exit condition:  output (ASCIIZ string) stored at address
;                  in second argument
;

itoa proc near

	push bp
	mov bp, sp
	push bx
	push ax
	push dx
	push cx
	push si
	push di

	mov bx, number
	mov ax, word ptr [bx]	; ax contains integer to convert
	mov bx, string			; point to output buffer

	cmp ax, 0				; check for sign
	jge notNegative 		; if ax >= 0 number is positive
	neg ax					; ax < 0, make positive to work with
	mov byte ptr [bx], '-'	; store - sign for negative number
	inc bx					; point to next character

notNegative:				; start conversion
	push ax 				; preserve value of number
	mov di, 10				; operand for division
	mov cx, 0				; cx holds number of digits found

countDigits:
	mov dx, 0
	inc cx					; increment number of digits
	div di					; div ax by di leaving quotient in ax
	cmp ax, 0
	jne countDigits
	pop ax					; restore original number

convert:
	add bx, cx				; set bx to end of string + 1
	mov byte ptr [bx], 0	; terminate ASCII string
	dec bx

convertLoop2:
	mov dx, 0
	div di
	add dx, '0' 			; convert digit value to ASCII code
	mov [bx], dl			; store ASCII value of digit 
	dec bx					; point to previous character
	loop convertLoop2

	pop di
	pop si
	pop cx
	pop dx
	pop ax
	pop bx
	pop bp
	ret

itoa endp


Prt:
	mov ah, 02h
	mov dx, sum
	int 21h
	jmp Finished


Finished:
	mov ax, 4C00h			;terminate program with 00h in
	int 21h					;	AL as the "return code"

end Start


Prt:
	mov ah, 02h
	mov dl, sum
	int 21h
