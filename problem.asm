; warning this program make it freeze DOSBox, but don't know why ? 

pile    SEGMENT stack
pile    ENDS

data 	SEGMENT public
		
	mode 	DB	?
	autoRun	DB	?
	delay 	DW 	?

	posX	DW 	?
	posY 	DW 	?
	color 	DB	?
	exCol  	DB  	?
	dirX	DW	?
	dirY	DW	?


	colorb 	DB	?
	exColb  DB 	?
	dirXb	DW	?
	dirYb	DW	?
	posXb	DW 	?
	posYb 	DW 	?
	
data 	ENDS

code    SEGMENT public

assume  cs:code,es:code,ss:pile,ds:data


; graphic mode
MOV AL, 13h
MOV AH, 0
INT 10h

; init variable (because doesn't work when I try to init during declaration)
MOV mode, 1
MOV autoRun, 1
MOV delay, 1

MOV color, 64
MOV exCol, 0
MOV dirX, 1
MOV dirY, 0
MOV posX, 64
MOV posY, 64

MOV colorb, 14
MOV	exColb, 0
MOV	dirXb, 0
MOV	dirYb, 1
MOV posXb, 20h
MOV	posYb, 20h

mainLoop:
	CALL handleKeyBoard
	MOV AH, 0Ch
	MOV CX, posX
	MOV DX, posY
	MOV AL, 14
	INT 10h
	JMP mainLoop

handleKeyBoard proc
	MOV AH, 01h		; just to check if a key is pressed
	INT 16h
	JZ notPressed
	
	MOV AH, 00h 	; get the key
	INT 16h
	pressed:
		CMP AL, "q"
		JE endProgram
	notPressed:
	RET
handleKeyBoard endp
	
; *** EXIT ***
endProgram:
	mov AX, 03h		; return to console mode (to avoid typing "cls" command)
	int 10h
	mov AH, 4Ch		; end of DOS program
	mov AL, 00h
	int 21h

code    ENDS
END
