;*********************;
; Program Fun to Draw ;
;*********************;

pile    SEGMENT stack
pile    ENDS

data 	SEGMENT public		
	mode 	DW	01h
	color 	DB	04h	
data 	ENDS

code    SEGMENT public
assume  cs:code,ds:data,es:code,ss:pile

; graphic mode
MOV AL, 13h
MOV AH, 0
INT 10h

; dessine une ligne
affichage:
	MOV AH, 0Ch
	MOV AL, 4
	mov CX, 50
	mov DX, 50
	int 10h
;trait:
 ;       inc AL
  ;      inc CX
   ;     inc DX
    ;    int 10h
     ;   cmp DX, 100
      ;  jne trait
		
; boucle de dessin

; init variable
MOV mode, 01h
MOV color, 64
		
Mainloop:
    CALL readChar

HandleMode:
	CMP mode, 01h
	JE removePixel
	CMP mode, 02h
	JE changeColor
	
HandleChar:
	CMP AL, 4Bh		; narrow left
	JE NLeft
	CMP AL, 4Dh		; narrow right
	JE NRight
	CMP AL, 48h		; narrow up
	JE NUp
	CMP AL, 50h		; narrow down
	JE NDown
	CMP AL, "c"
	JE modeCursor
	CMP AL, "r"
	JE modeRainbow
	CMP AL,"q"
	JE endProgram
	JMP putPixel
	
modeCursor:
	MOV color, 15
	MOV mode, 01h
	JMP putPixel
	
modeRainbow:
	MOV color, 32
	MOV mode, 02h
	JMP putPixel
	
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
	JMP Mainloop

removePixel:
	CALL RmvPxl
	JMP HandleChar
	
changeColor:
	INC color
	CMP color, 54
	JG resetColor
	JMP HandleChar
	
resetColor:
	MOV color, 32
	JMP HandleChar
	
;**** Sub ReadChar *****
readChar:
	mov AH,07h
	int 21H
	RET

; *** Sub ReadPxl ***
readPxl:
	MOV AH,0Dh
	
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
	
; *** EXIT ***
endProgram:
	mov AX, 3		; return to console mode (to avoid type "cls" command)
	int 10h
	mov AH, 4Ch		; end of DOS program
	mov AL, 00h
	int 21h

code    ENDS
END
