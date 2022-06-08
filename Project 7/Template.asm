TITLE Program Template     (template.asm)

; Author: 
; Last Modified:
; OSU email address: ONID_ID@oregonstate.edu
; Course number/section:   CS271 Section ???
; Project Number:                 Due Date:
; Description: This file is provided as a template from which you may work
;              when developing assembly projects in CS271.

INCLUDE Irvine32.inc

; (insert macro definitions here)

printNum MACRO num
PUSH	EAX

mov		EAX, num
call	writedec
call	crlf

POP		EAX

ENDM


printStr MACRO someText:REQ
	LOCAL	theString
.data
	theString	BYTE	someText, 0

.code
PUSH	EDX

MOV		EDX, OFFSET	theString
CALL	WriteString
call	crlf

POP		EDX


ENDM

strToInt MACRO src
	LOCAL	sum

.data
	sum		SDWORD	0

.code
	PUSH	ECX
	PUSH	EAX
	PUSH	EDX
	PUSH	ESI
	PUSH	BX

	MOV		ECX, 5
	MOV		ESI, OFFSET src
	MOV		BX, 10

	_convLoop:
	add		sum, [esi]
	mov		eax, sum
	mul		bx
	mov		sum, eax
	add		esi, 1
	loop	_convLoop

	mov		eax, sum
	call	writedec



	POP		BX
	POP		ESI
	POP		EDX
	POP		EAX
	POP		ECX


ENDM

mGetString MACRO promptOff, usrInputOff, inputMax

;-----------------------------------------------------------------------
; It sounds like this thing is supposed to prompt the use for a number
; (which will be entered as a string). Then we need to call our
; conversion procedure to convert the string to a number and store it
; somewhere. Then, if it's all kosher, put it into the array.
;-----------------------------------------------------------------------

	;PUSH	EDX
	;PUSH	EAX
	;PUSH	ECX

	; Promt the user for a signed number
	MOV		EDX, promptOff
	CALL	WriteString

	; Call ReadString to procure said number
	MOV		EDX, usrInputOff	; where we want the input to go
	MOV		ECX, inputMax		; maximum allowable length
	CALL	ReadString			; EAX = number of chars entered
								; EDX = Address of user string

ENDM

mDisplayString MACRO toPrint

PUSH	EDX

MOV		EDX, toPrint
CALL	WriteString

POP		EDX

ENDM

; (insert constant definitions here)
STRLEN = 42
MAXLEN = 11

.data

; (insert variable definitions here)

intStr			BYTE	"1986",0
output			DWORD	69
intNum			SDWORD	0
mult			WORD	10


testPrompt		BYTE	"Please enter a signed number: ", 0			; To prompt for number
userIn			BYTE	MAXLEN DUP (?)								; Storage for user input string
userInLen		DWORD	?
errorMsg		BYTE	"That value was either too large or, contained non-numeral characters. Please try again.", 13, 10, 0
errorFlag		DWORD	?

.code
main PROC

; (insert executable instructions here)

COMMENT @
	; MACRO PRACTICE
	printNum	222
	printStr	"Will it print?"
	printStr	"It printed!"

@


	MOV		ECX, 10

	_getNumLoop:

		_tryAgain:
			MOV		errorFlag, 0

			PUSH	ECX
			MOV		ECX, 0
			mGetString OFFSET testPrompt, OFFSET userIn, MAXLEN		; EAX = number of digits entered, EDX = Address of input
			
	
			PUSH	OFFSET errorMsg
			PUSH	OFFSET errorFlag
			PUSH	EDX
			PUSH	EAX
			CALL	convertStr			; intStr = array of numerals

		CMP		errorFlag, 1
		JE		_tryAgain

	

	; So now, we should have "intStr" as an array matching the decimal values, e.g. '142' -> [1,4,2]

	push	EDX					; Still address of string input
	PUSH	OFFSET intNum				; Where we want the numeral to go
	PUSH	EAX							; still the number of digits entered
	CALL	toInt




	MOV		EAX, intNum
	call	writeint

	MOV		intNum, 0

	POP		ECX
	LOOP	_getNumLoop

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)


convertStr PROC

;-----------------------------------------------------------------------
; Takes a byte array / string representation of a number and converts
; Each item to it digit representation. i.e. ['1','4','6'] -> [1, 4, 6]
; Validates entries along the way to ensure a valid number was entered.
; Prints error and re-tries until 10 values
;-----------------------------------------------------------------------
	PUSH	EBP
	MOV		EBP, ESP

	PUSH	EAX
	PUSH	ECX
	PUSH	EDI
	PUSH	ESI

	MOV		EAX, 0
	MOV		EBX, [EBP + 16] ; I NEED TO WORK ON GETTING THIS ERROR FLAG THING TO WORK! THEN I'LL BE COOKING WITH OIL

	MOV		ECX, [EBP + 8]

	MOV		ESI, [EBP + 12]
	MOV		EDI, [EBP + 12]
	
	_convertLoop:
	; First check for sign of value
	LODSB
	CMP		EAX, '-'
	JE		_continue

	CMP		EAX, '+'
	JE		_continue

	; Then check if it's the correct range
	CMP		EAX, 48
	JB		_error

	CMP		EAX, 57
	JA		_error


	; If everything's good, subtract 48 and put it back
	SUB		EAX, 48
	JMP		_continue

	_error:
		
		PUSH	EAX

		MOV		EAX, 0
		MOV		EAX, [EBX]
		MOV		EAX, 1
		MOV		[EBX], EAX

		POP		EAX
		mDisplayString [EBP + 20]
		JMP		_exit

	_continue:
		

	STOSB

	loop	_convertLoop

	_exit:

	POP		ESI
	POP		EDI
	POP		ECX
	POP		EAX

	POP		EBP

	RET 20

convertStr ENDP


toInt PROC

PUSH	EBP
MOV		EBP, ESP

PUSH	EAX
PUSH	EBX
PUSH	ECX
PUSH	EDX
PUSH	ESI
PUSH	EDI


MOV		ESI, [EBP + 16]					; Should be the source array
MOV		EDI, [EBP + 12]
MOV		ECX, [EBP + 8]

CMP		ECX, 1
JE		_singleDigit
SUB		ECX, 1
MOV		BX, 10
JMP		_convLoop

_singleDigit:

	PUSH	EAX
	MOV		EAX, 0
	MOV		EAX, [ESI]
	MOV		[EDI], EAX
	POP		EAX
	JMP		_finish

; CONVERT UNTIL 2ND TO LAST DIGIT
_convLoop:
MOV		EAX, 0
LODSB

CMP		EAX, '-'
JE		_skip


CMP		EAX, '+'
JE		_skip


add		[EDI], EAX		
MOV		EAX, [EDI]
MUL		BX
MOV		[EDI], EAX

_skip:


LOOP	_convLoop

; ADD LAST DIGIT
LODSB
ADD		[EDI], AL

MOV		ESI, [EBP + 16]
mov		EAX, 0
LODSB	
CMP		EAX, '-'
JE		_negate
JMP		_finish

_negate:
MOV		EAX, 0
MOV		EDX, 0
MOV		EAX, [EDI]
NEG		EAX
MOV		[EDI], EAX

_finish:


POP		EDI
POP		ESI
POP		EDX
POP		ECX
POP		EBX
POP		EAX

POP		EBP

RET		12

toInt ENDP


END main