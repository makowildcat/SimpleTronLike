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
	exColor DB 	0
data 	ENDS

code    SEGMENT public
assume  cs:code,ds:data,es:code,ss:pile

; graphic mode
MOV AL, 13h
MOV AH, 0
INT 10h

JMP initVar 
	
; *** Sub EchoChar ***
; Echochar:
	; MOV AH, 02
	; MOV DL,AL
	; INT 21H
	; RET
	
; *** Sub PutPxl ***
PutPxl:
	MOV AH, 0Ch
	MOV AL, color
	INT 10h
	RET
	
; *** Sub ReadPxl ***
fReadPxl:
	MOV AH, 0Dh
	INT 10h
	MOV exColor, AL
	RET
	
fInitGrid:
	MOV AH, 0Ch
	MOV AL, 148
	MOV CX, 10
	MOV DX, 10
	INT 10h
	lineH:
		INC CX
		INT 10h
		CMP CX, 310
		JNE lineH
		ADD DX, 10
		MOV CX, 9
		CMP DX, 200
		JNE lineH
		
	MOV DX, 9
	MOV CX, 10
	lineV:
		INC DX
		INT 10h
		CMP DX, 190
		JNE lineV
		ADD CX, 10
		MOV DX, 9
		CMP CX, 320
		JNE lineV
	RET

fCleanScreen:
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
	RET

updateData proc
	CMP mode, 1
	JE rainbow
	CMP mode, 2
	JE cursor
	CMP mode, 3
	JE erase
	erase:
		MOV exColor, 0
	cursor:
		MOV AL, exColor
		MOV AH, 0Ch
		INT 10h
		JMP noClear		
	rainbow:
		CMP color, 54
		JNG upColor
		MOV color, 31
		upColor:
			INC color
	noClear:
		ADD CX, dirX
		ADD DX, dirY
		CALL fReadPxl
		CALL PutPxl
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
MOV exColor, 0

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
	JNE mainLoop
	MOV dirX, -1
	MOV dirY, 0
	JMP mainLoop
NRight:
	CMP dirX, 0
	JNE mainLoop
	MOV dirX, 1
	MOV dirY, 0
	JMP mainLoop
NUp:
	CMP dirY, 0
	JNE	mainLoop
	MOV dirX, 0
	MOV dirY, -1
	JMP mainLoop
NDown:
	CMP dirY, 0
	JNE mainLoop
	MOV dirX, 0
	MOV dirY, 1
	JMP mainLoop

putPixel:
	; CALL PutPxl
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
		CMP AL, "s"
		JE cleanScreen
		CMP AL, "e"
		JE eraseMode
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
	
initGrid:
	CALL fInitGrid
	JMP putPixel
	
cleanScreen:
	CALL fCleanScreen
	JMP putPixel

eraseMode:
	MOV color, 15
	MOV mode, 3
	JMP PutPxl
	
; *** EXIT ***
endProgram:
	mov AX, 3		; return to console mode (to avoid typing "cls" command)
	int 10h
	mov AH, 4Ch		; end of DOS program
	mov AL, 00h
	int 21h

code    ENDS
END
