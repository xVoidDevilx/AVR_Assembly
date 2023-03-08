;
; R11679913_Rodriguez_P400.asm
;
; Created: 10/4/2022 12:30:54 AM
; Author : Silas aka that goon
;
; Include mnuemonics for the 328P
.INCLUDE "M328PDEF.INC"

;initialize the stack
.ORG $0
LDI R20, HIGH(RAMEND)	;set stack high
OUT SPH, R20
LDI R20, LOW(RAMEND)	;set stack low
OUT SPL, R20

;initialize PORT B
LDI R20, 0xFF	;FF will do 8 bits of ones to enable all ports to be output type
OUT DDRD, R20	
LDI R21, 0x55	;Pattern 1 where LEDs will be 01010101
LDI R22, 0xAA	;Pattern 2 where LEDs will be 10101010	-> LEDs will oscillate in a loop
LOOP:
	OUT PORTD, R21	;SEND FIRST PATTERN
	CALL DELAY		;wait .25 sec
	OUT PORTD, R22	;SEND 2ND PATTERN
	CALL DELAY		;wait .25 sec
	RJMP LOOP		;KEEP REPEATING THIS PATTERN

;Delay waits .25 s, happens twice to Hz for a single LED is .25 x 2 = .5 s between two highs. (2Hz) 
DELAY:
		   LDI R16, 25	;REPEAT NESTED LOOPS 50 TIMES
	LOOP3: LDI R17, 200	;REPEAT INNER LOOP 200 TIMES
	LOOP2: LDI R18, 200	;REPEAT INNEREST LOOP 200 TIMES
	LOOP1: NOP			;BURN CYCLES
		   NOP			;WASTE TIME
		   DEC R18		
		   BRNE LOOP1	;DO IT AGAIN
		   DEC R17		
		   BRNE LOOP2	;DO IT AGAIN, BUT AGAIN
		   DEC R16
		   BRNE LOOP3	;ALRIGHT DOING IT AGAIN FOR THE LAST TIME
		   RET			;BANISH BACK TO BEGIN

;Very Respectfully,
;Silas Rodriguez