;*********************;
; Program Fun to Draw ;
;*********************;

pile    SEGMENT stack
pile    ENDS

data 	SEGMENT public		
	mode 	DW	01h
	autoRun	DB	1
	color 	DB	04h
	dirX	DW	1
	dirY	DW	1
	delay 	DW 	1024
data 	ENDS

code    SEGMENT public
assume  cs:code,ds:data,es:code,ss:pile

; graphic mode
MOV AL, 13h
MOV AH, 0
INT 10h

; MOV AH, 0Ch
JMP initVar 

;**** Sub ReadChar *****
; readChar:
	; mov AH, 07h
	; int 21H
	; MOV AH, 01h
	; INT 16h
	; RET

; *** Sub ReadPxl ***
; readPxl:
	; MOV AH, 0Dh
	; RET
	
; *** Sub EchoChar ***
; Echochar:
	; MOV AH, 02
	; MOV DL,AL
	; INT 21H
	; RET
	
; *** Sub PutPxl ***
PutPxl:
	mov AH, 0Ch
	mov AL, color
	int 10h
	RET

; *** Sub RmvPxl ***
; RmvPxl:
	; mov AH, 0Ch
	; mov BL , AL
	; mov AL, 0		; black color
	; int 10h
	; mov AL, BL
	; RET

; screenReset:
	; MOV AH, 0Ch
	; MOV AL, 0
	; MOV CX, 0
	; MOV DX, 0
; loopScreenReset:
	; int 10h
	; INC CX
	; CMP CX, 320
	; jne loopScreenReset
	; MOV CX, 0
	; INC DX
	; CMP DX, 200
	; jne loopScreenReset	
	; MOV CX, 32
	; MOV DX, 32
	; MOV AL, 15

updateData proc
	CMP mode, 1
	JE rainbow
	CMP mode, 2
	JNE noClear
	MOV AH, 0Ch
	MOV AL, 0
	INT 10h
	JMP noClear
	rainbow:
		CMP color, 54
		JNG upColor
		MOV color, 31
		upColor:
			INC color
	noClear:
		MOV AH, 0Ch
		MOV AL, color
		ADD CX, dirX
		ADD DX, dirY
		INT 10h
		CMP autoRun, 1
		JE yes_autoRun
		MOV dirX, 0
		MOV dirY, 0
		yes_autoRun:
			RET
updateData endp

initVar:
MOV CX, 50
MOV DX, 50
MOV dirX, 1
MOV dirY, 0
MOV autoRun, 0
MOV mode, 1
MOV color, 64

mainLoop:
	CALL handleKeyBoard
	CALL updateData
	
	MOV delay, 32768
	loopDelay:
		DEC delay
		JNZ loopDelay
		
	JMP mainLoop

NLeft:
	CMP dirX, 0		; test to avoid way back
	JNE putPixel
	MOV dirX, -1
	MOV dirY, 0
	JMP putPixel
NRight:
	CMP dirX, 0
	JNE putPixel
	MOV dirX, 1
	MOV dirY, 0
	JMP putPixel
NUp:
	CMP dirY, 0
	JNE	putPixel
	MOV dirX, 0
	MOV dirY, -1
	JMP putPixel
NDown:
	CMP dirY, 0
	JNE putPixel
	MOV dirX, 0
	MOV dirY, 1
	JMP putPixel

putPixel:
	CALL PutPxl
	JMP mainLoop
	
handleKeyBoard proc
	MOV AH, 01h		; just to check if a key is pressed
	INT 16h
	JZ notPressed
	
	MOV AH, 00h 	; get the key
	INT 16h
	pressed:
		CMP AH, 4Bh		; narrow left
		JE NLeft
		CMP AH, 4Dh		; narrow right
		JE NRight
		CMP AH, 48h		; narrow up
		JE NUp
		CMP AH, 50h		; narrow down
		JE NDown
		CMP AL, "a"
		JE toggleAutoRun
		CMP AL, "r"
		JE rainbowMode
		CMP AL, "c"
		JE cursorMode
		CMP AL, "q"
		JE endProgram
		CMP AL, "g"
		JE initGrid
	notPressed:
	
	RET
handleKeyBoard endp
	
toggleAutoRun:
	CMP autoRun, 0
	JE switch
	MOV autoRun, 0
	JMP putPixel
	switch:
		MOV autoRun, 1
	JMP putPixel
	
rainbowMode:
	MOV mode, 1
	JMP putPixel
	
cursorMode:
	MOV mode, 2
	JMP putPixel

; intermediateJump:
	
	; JMP endProgram
	
initGrid:
	mov AH, 0Ch
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
	JMP putPixel
	
; *** EXIT ***
endProgram:
	mov AX, 3		; return to console mode (to avoid typing "cls" command)
	int 10h
	mov AH, 4Ch		; end of DOS program
	mov AL, 00h
	int 21h

code    ENDS
END
