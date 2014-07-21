;*********************;
; Program Fun to Draw ;
;*********************;

pile    SEGMENT stack
pile    ENDS

data 	SEGMENT public		
	mode 	DB	0
	autoRun	DB	0
	delay 	DW 	0
	color1 	DB	0
	exCol1  DB  0
	dirX1	DW	0
	dirY1	DW	0
data 	ENDS

;*****************************************************************************;
;** FEW TESTS // and failed :( don't know why I can't add more variable without
;** getting some strange effects like freezing when I quite
; datap1	SEGMENT public			
	; posX1	DW 	0
	; posY1 	DW 	0
; datap1 	ENDS
; datap2	SEGMENT public		
	; color2 	DB	0
	; exCol2  DB 	0
	; dirX2	DW	0
	; dirY2	DW	0
	; posX2	DW 	0
	; posY2 	DW 	0
; datap2 	ENDS
; dataAll 	group 	data, datap1
;*****************************************************************************;

code    SEGMENT public
assume  cs:code,ds:data,es:code,ss:pile
; assume	ds:datap1
; assume 	ds:datap2

; graphic mode
MOV AL, 13h
MOV AH, 0
INT 10h

MOV CX, 50
MOV DX, 50
; MOV posX1, 30
; MOV posY1, 30
MOV dirX1, 1
MOV dirY1, 0
MOV exCol1, 0
MOV autoRun, 1
MOV mode, 1
MOV color1, 64

; MOV	dirX2, 0
; MOV	dirY2, 0
; MOV	exCol2, 0
; MOV color2, 14
; MOV posX2, 180
; MOV	posY2, 100
	
JMP mainLoop 
	
; *** Sub PutPxl ***
PutPxl:
	MOV AH, 0Ch
	; MOV CX, posX1
	; MOV DX, posY1
	MOV AL, color1
	INT 10h
	; MOV CX, posX2
	; MOV DX, posY2
	; MOV AL, color2
	; INT 10h
	RET
	
; *** Sub ReadPxl ***
fReadPxl:
	MOV AH, 0Dh
	INT 10h
	CMP dirX1, 0
	JNE withExColor
	CMP dirY1, 0
	JE withOutExColor 
	withExColor:
	MOV exCol1, AL
	withOutExColor:
	RET
	
fCheckCollision:
	MOV BX, 0
	CMP CX, 10 ;CMP posX1, 10
	JNG yes_collision
	CMP DX, 10 ;CMP posY1, 10
	JNG yes_collision
	CMP CX, 309 ;CMP posX1, 309
	JG yes_collision
	CMP DX, 189 ;CMP posY1, 189
	JG yes_collision	
	CMP exCol1, 0
	JE no_collision
	CMP exCol1, 52
	JE no_collision
	yes_collision:
	MOV BX, 1
	no_collision:
	RET
	
fInitGrid:
	MOV AH, 0Ch
	MOV AL, 52 ;148
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
		
	MOV CX, 100
	MOV DX, 95
	MOV AL, 15
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
	CMP mode, 4
	JE noClear
	erase:
		MOV exCol1, 0
	cursor:
		MOV AL, exCol1
		MOV AH, 0Ch
		INT 10h
		JMP noClear		
	rainbow:
		CMP color1, 54
		JNG upColor
		MOV color1, 31
		upColor:
			INC color1
	noClear:
		; MOV CX, posX1
		ADD CX, dirX1
		; MOV posX1, CX
		; MOV DX, posY1
		ADD DX, dirY1
		; MOV posY1, DX
		CALL fReadPxl
		CALL PutPxl
		CMP autoRun, 1
		JE yes_autoRun
		MOV dirX1, 0
		MOV dirY1, 0
		yes_autoRun:
		
	RET
updateData endp

mainLoop:
	CALL handleKeyBoard
	CALL updateData
	CALL fCheckCollision
	CMP BX, 1
	JE collision
	
	MOV delay, 32768
	loopDelay:
		DEC delay
		JNZ loopDelay
		
	JMP mainLoop

NLeft:
	CMP dirX1, 0		; test to avoid way back
	JNE mainLoop
	MOV dirX1, -1
	MOV dirY1, 0
	JMP mainLoop
NRight:
	CMP dirX1, 0		; idem
	JNE mainLoop
	MOV dirX1, 1
	MOV dirY1, 0
	JMP mainLoop
NUp:
	CMP dirY1, 0		; ...
	JNE	mainLoop
	MOV dirX1, 0
	MOV dirY1, -1
	JMP mainLoop
NDown:
	CMP dirY1, 0
	JNE mainLoop
	MOV dirX1, 0
	MOV dirY1, 1
	JMP mainLoop
	
putPixel:
	JMP mainLoop
	
collision:
	CMP mode, 4
	JE cleanScreen
	
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
		CMP AL, "g"
		JE initGrid
		CMP AL, "s"
		JE cleanScreen
		CMP AL, "e"
		JE eraseMode
		CMP AL, "t"
		JE traceMode
		CMP AL, "q"
		JE endProgram
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

cleanScreen:
	CALL fCleanScreen
	JMP putPixel
	
rainbowMode:
	MOV mode, 1
	JMP putPixel
	
cursorMode:
	MOV mode, 2
	JMP putPixel
	
initGrid:
	CALL fCleanScreen
	CALL fInitGrid
	MOV dirX1, 1
	MOV dirY1, 0
	MOV color1, 14
	MOV autoRun, 1
	JMP traceMode

eraseMode:
	MOV color1, 15
	MOV mode, 3
	JMP PutPxl
	
traceMode:
	MOV mode, 4
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
