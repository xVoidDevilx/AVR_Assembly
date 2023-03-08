;
; R11679913_Rodriguez_P500.asm
;
; CREATED: 11/1/2022 8:48:03 PM
; AUTHOR : Silas Rodriguez, you already know I spent too much time on this ;)

;INITAL INSTRUCTION JUNK
.ORG $0000
	RJMP MAIN

MAIN:
	;INITIALIZE THE STACK
	LDI R20, HIGH(RAMEND)
	OUT SPH, R20
	LDI R20, LOW(RAMEND)
	OUT SPL, R20
	
	;SET I/O DIRECTIONS
	CBI DDRB, 1	;SET PORT B1 INPUT
	SBI PORTB,1 ;ACTIVE PULL-UP
	SBI DDRB, 0 ;SET PORT B0 OUTPUT (PWM)
	SBI DDRB, 2	;SET OUTPUT (LED)
	
	;INTIIAL OUTPUTS 0
	CBI PORTB, 0
	CBI PORTB, 2

;MOTOR CONTROL LOOP
MOTORCONTROL: 
	ZERO:
		LDI R25, 10	;DELAY 10 TIMES TO KEEP FREQUENCY (AND PREVENT BUTTON SKIPPING)
		WAIT0:
			CALL DELAY
			DEC R25
			BRNE WAIT0
		CBI PORTB, 0 ;OUTPUT LOW FROM PB0
		SBIC PINB, 1 ;SKIP IF PUSH BUTTON LOW
		RJMP ZERO	 ;CONTINUE LOOP OTHERWISE

	CALL INTERLOOP  ;WAIT FOR NEXT LOOP

	FORTY:
		LDI R25, 6	;OFF 6/10 TIMES
		LDI R26, 4	;ON 4/10 TIMES
		SBI PORTB, 0;MOTOR ON
		;INNERLOOP FOR ON STATE
		ON40LOOP:
			CALL DELAY
			DEC R26
			BRNE ON40LOOP
		CBI PORTB, 0;MOTOR OFF
		;INNERLOOP FOR OFF STATE
		OFF40LOOP:
			CALL DELAY
			DEC R25
			BRNE OFF40LOOP
		
		SBIC PINB, 1	;SKIP IF PUSH BUTTON LOW
		RJMP FORTY		;JUMP OTHERWISE
	
	CALL INTERLOOP  ;WAIT BEFORE NEXT LOOP

	SEVENTY:
		LDI R25, 3	;OFF 3/10 TIMES
		LDI R26, 7	;ON 7/10 TIMES
		SBI PORTB, 0;MOTOR ON
		;INNERLOOP TO HOLD ON STATE
		ON70LOOP:
			CALL DELAY
			DEC R26
			BRNE ON70LOOP
		CBI PORTB, 0	;MOTOR OFF
		;INNERLOOP TO HOLD OFF STATE
		OFF70LOOP:
			CALL DELAY
			DEC R25
			BRNE OFF70LOOP
		SBIC PINB, 1;SKIP IF PUSH BUTTON LOW
		RJMP SEVENTY;JUMP OTHERWISE
	
	CALL INTERLOOP  ;WAIT BEFORE NEXT LOOP

	DC:
		LDI R25, 10
		SBI PORTB, 0;SET PB=1
		WAIT:		
			CALL DELAY
			DEC R25
			BRNE WAIT
		SBIC PINB, 1;SKIP IF PUSHBUTTON LOW
		RJMP DC;STAY IN DC OTHERWISE

	CALL INTERLOOP  ;WAIT BEFORE STEP OVER
	RJMP MOTORCONTROL	;RETURN TO THE BEGINNING

;CREATE A DELAY FOR FREQUENCY. 250 Hz => DELAY OF .004 s. CYCLES = .004 / .00000005 = 80,000 / 10 CALLS = 8,000 CYCLES
DELAY:
	LDI R20, 6
	DELOOP1: LDI R19, 212
	DELOOP0:
		NOP
		NOP
		DEC R19
		BRNE DELOOP0
		DEC R20
		BRNE DELOOP1
	RET

;DELAY BETWEEN LOOPS (.25 A SEC) DELAY 5,000,000 CYCLES - PREVENT BUTTON MISREADS
INTERLOOP:
	CBI PORTB, 2	;SHOW CHANGE STATE
	LDI R22, 16		;BURN THESE DAMN CYCLES 
	WAITER2:LDI R21, 250
	WAITER1:LDI R20, 250
	WAITER0:
		NOP
		NOP
		DEC R20
		BRNE WAITER0
		DEC R21
		BRNE WAITER1
		DEC R22
		BRNE WAITER2
	SBI PORTB, 2	;SHOW ENTRANCE INTO NEXT LOOP
RET