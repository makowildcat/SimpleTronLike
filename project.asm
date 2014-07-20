;*********************;
; Program Fun to Draw ;
;*********************;

pile    SEGMENT stack
pile    ENDS

data 	SEGMENT public		
	mode 	DW	01h
	color 	DB	04h
	dirX	DB	1
	dirY	DB	1
	delay 	DW 	1024
data 	ENDS

code    SEGMENT public
assume  cs:code,ds:data,es:code,ss:pile

; graphic mode
MOV AL, 13h
MOV AH, 0
INT 10h

MOV AH, 0Ch

; init variable
MOV mode, 01h
MOV color, 64
JMP mainLoop

;**** Sub ReadChar *****
readChar:
	;mov AH, 07h
	;int 21H
	MOV AH, 01h
	INT 16h
	RET

; *** Sub ReadPxl ***
readPxl:
	MOV AH, 0Dh
	RET
	
; *** Sub EchoChar ***
Echochar:
	MOV AH, 02
	MOV DL,AL
	INT 21H
	RET
	
; *** Sub PutPxl ***
PutPxl:
	mov AH, 0Ch
	mov AL, color
	int 10h
	RET

; *** Sub RmvPxl ***
RmvPxl:
	mov AH, 0Ch
	mov BL , AL
	mov AL, 0		; black color
	int 10h
	mov AL, BL
	RET

screenReset:
	MOV AH, 0Ch
	MOV AL, 0
	MOV CX, 0
	MOV DX, 0
loopScreenReset:
	int 10h
	INC CX
	CMP CX, 320
	jne loopScreenReset
	MOV CX, 0
	INC DX
	CMP DX, 200
	jne loopScreenReset	
	MOV CX, 32
	MOV DX, 32
	MOV AL, 15
	
MOV CX, 0
MOV DX, 0
	
mainLoop:
	CALL handleKeyBoard
	CALL updateData
	
	MOV delay, 32768
	loopDelay:
		DEC delay
		JNZ loopDelay
		
	JMP mainLoop

handleKeyBoard proc
	MOV AH, 01h		; just to check if a key is pressed
	INT 16h
	JZ no_
	
	MOV AH, 00h 	; get the key
	INT 16h
	yes_:
		CMP AL, 4Bh		; narrow left
		JE NLeft
		CMP AL, 4Dh		; narrow right
		JE NRight
		CMP AL, 48h		; narrow up
		JE NUp
		CMP AL, 50h		; narrow down
		JE NDown
		CMP AL, "q"
		JE intermediateJump
	no_:
	
	RET
handleKeyBoard endp

updateData proc
	MOV AH, 0Ch
	MOV AL, color
	INC CX
	INC DX
	INT 10h
	RET
updateData endp

; HandleMode:
	; CMP mode, 01h
	; JE removePixel
	; CMP mode, 02h
	; JE changeColor
	
; HandleChar:
	; CMP AL, 4Bh		; narrow left
	; JE NLeft
	; CMP AL, 4Dh		; narrow right
	; JE NRight
	; CMP AL, 48h		; narrow up
	; JE NUp
	; CMP AL, 50h		; narrow down
	; JE NDown
	; CMP AL, "c"
	; JE modeCursor
	; CMP AL, "r"
	; JE modeRainbow
	; CMP AL, "q"
	; JE intermediateJump
	; CMP AL, "s"
	; JE screenReset
	; CMP AL, "g"
	; JE drawGrid
	; JMP putPixel
	
; modeCursor:
	; MOV color, 15
	; MOV mode, 01h
	; JMP putPixel
	
; modeRainbow:
	; MOV color, 32
	; MOV mode, 02h
	; JMP putPixel
	
NLeft:
	DEC CX
	JMP putPixel
NRight:
	INC CX
	JMP putPixel
NUp:
	DEC DX
	JMP putPixel
NDown:
	INC DX
	JMP putPixel
		
putPixel:
	CALL PutPxl
	JMP mainLoop

; removePixel:
	; CALL RmvPxl
	; JMP HandleChar
	
; changeColor:
	; INC color
	; CMP color, 54
	; JG resetColor
	; JMP HandleChar
	
; resetColor:
	; MOV color, 32
	; JMP HandleChar

intermediateJump:
	mov AX, 3		; return to console mode (to avoid typing "cls" command)
	int 10h
	JMP endProgram
	
drawGrid:
	MOV AL, 148
	mov CX, 10
	mov DX, 10
	int 10h
lineH:
	inc CX
	int 10h
	cmp CX, 310
	jne lineH
	ADD DX, 10
	MOV CX, 9
	cmp DX, 200
	jne lineH
MOV DX, 9
MOV CX, 10
lineV:
	INC DX
	int 10h
	CMP DX, 190
	jne lineV
	ADD CX, 10
	MOV DX, 9
	CMP CX, 320
	jne lineV
JMP mainLoop
	
; *** EXIT ***
endProgram:
	mov AH, 4Ch		; end of DOS program
	mov AL, 00h
	int 21h

code    ENDS
END
