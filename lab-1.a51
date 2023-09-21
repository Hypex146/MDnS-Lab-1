; Start
	ORG 	0000h			; (Starting address)
	P4 		EQU 0C0h		; (Define P4)


; Writing a reference function to external memory
	MOV		DPTR, #8000h
	MOV		A, #08h
	MOVX	@DPTR, A
	MOV		DPTR, #8008h
	MOV		A, #15h
	MOVX	@DPTR, A

	MOV		DPTR, #8000h
	MOVX	A, @DPTR
	MOV		DPL, A
	MOVX	A, @DPTR
	MOV		DPL, A
	MOV		R2, DPL
	
	MOV 	A, #0E3h		; A := 11100011b (The first part of the reference function)
	MOVX 	@DPTR, A		; [DPTR] := A
	INC		DPTR
	MOV 	A, #0C5h		; A := 11000101b (The second part of the reference function)
	MOVX 	@DPTR, A		; [DPTR] := A
	
	
; Waiting for permission to start program execution
WAIT:
	MOV		DPTR, #7FFBh
	MOVX	A, @DPTR
	JZ		WAIT	
	MOV		R0, #00h		; R0 := 00h
	
	
; Iterating through all input values
CYCLE_1:
	MOV		DPTR, #7FFAh
	MOV		A, R0
	MOVX	@DPTR, A
	MOV		20h, R0			; [20h] := R0 (Loading input values)
	
; Calculation of a logical function
	MOV		C, 1			; C := [20.1h]
	ANL		C, /2			; C := C and ![20.2h]
	ANL		C, /3			; C := C and ![20.3h]
	MOV		8, C			; [21.0h] := C (x1 * !x2 * !x3)
	MOV		C, 2			; C := [20.2h]
	ANL		C, /0			; C := C and ![20.0h]
	ANL		C, /1			; C := C and ![20.1h]
	MOV		9, C			; [21.1h] := C (x2 * !x0 * !x1)
	MOV		C, 2			; C := [20.2h]
	ANL		C, /1			; C := C and ![20.1h]
	ANL		C, 3			; C := C and [20.3h]
	MOV		10, C			; [21.2h] := C (x2 * !x1 * x3)
	MOV		C, 0			; C := [20.0h]
	ANL		C, /2			; C := C and ![20.2h]
	ANL		C, 3			; C := C and [20.3h] (x0 * !x2 * x3)
	ORL		C, 8			; C := C or [20.4h]
	ORL		C, 9			; C := C or [20.5h]
	ORL		C, 10			; C := C or [20.6h]
	MOV		8, C			; [21.0h] := F
	
; Comparison of the obtained result with the reference function
	MOV		DPTR, #8000h	;
	MOV		DPL, R2
	JB		3, PTR_1		; if [20.3h] == 1 then PC := ${PTR_1}
	AJMP	PTR_2			; PC := ${PTR_2}
PTR_1:
	INC		DPTR
	CLR		3
PTR_2:
	MOVX	A, @DPTR		; A := [DPTR] (Loading the required part of the reference function)
	MOV		R1, 20h			; (Preparing the shift counter)
CYCLE_2: 					; Shift cycle
	CJNE 	R1, #0, PTR_3	; if R0 != 0 then PC := ${PTR_4}
	AJMP	PTR_4			; PC := ${PTR_5}
PTR_3:
	RR		A				; A -> (Right shift)
	DEC		R1				; R1 := R1 - 1
	AJMP	CYCLE_2			; PC := ${CYCLE_2}
PTR_4:
;	XRL		21h, A			; [20h] := [20h] xor A
	MOV		C, 8			; C := [20.0h] (Check bit)
	MOV		P4.0, C
	MOV		21h, A
	MOV		C, 8
	MOV		P4.1, C
	CJNE	R0, #0Fh, PTR_5	; if R0 != 0Fh then PC := ${PTR_6}
	MOV		R0, #00h
	MOV		DPTR, #7FFBh
	MOV		A, #00h
	MOVX	@DPTR, A
	AJMP	WAIT				; PC := PC (End of programme)
PTR_5:
	MOV		DPTR, #7FFBh
	MOV		A, #00h
	MOVX	@DPTR, A
	INC		R0				; R0 := R0 + 1 (Next input value)
	AJMP	WAIT			; PC := ${CYCLE_1}
	END						; (End of the program text)
