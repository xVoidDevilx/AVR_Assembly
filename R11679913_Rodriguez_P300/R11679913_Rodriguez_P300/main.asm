;
; R11679913_Rodriguez_P300.asm
;
; Created: 10/2/2022 02:05:44 AM <- Ignore this I was bored
; Author : Silas aka that goon
;

.EQU MY_NUM = 0b10000000		;change the number here for program testing
.EQU HUNDREDS = $100	;memory location for hundred place
.EQU TENS = $102		;memory location for tens place
.EQU ONES = $103		;memory location for ones place

.INCLUDE "M328DEF.inc"	; include mnuemonics for I/O ports and such for the ATmega328
.ORG $0000 ;start at ROM memory 0

;initialize le stack (for subroutines)
LDI R20, HIGH(RAMEND)
OUT SPH, R20
LDI R20, LOW(RAMEND)
OUT SPL, R20

;ONES PLACE
LDI R31, MY_NUM	 ;	load the number desired for BCD conversion to R31
CALL MOD10		 ;	this will call MOD 10: R31 / 10. R31 will be quotient, R20 is remainder
STS ONES, R20	 ;	Send the remainder to memory
;TENS PLACE
CALL MOD10		 ;	Take quotient and divide by 10 again
STS TENS, R20	 ;	Push the remainder out to TENS
;HUNDREDS PLACE
CALL MOD10		 ;	Final Divide of quotient (100s place)
STS HUNDREDS, R20;	Banish the 100's place to memory

HERE: RJMP HERE	 ; End of program

;Divide a number by 10, R31 is the quotient, R20 is remainder -> SUBROUTINE
MOD10:
	;Modified Division from P100 -> LOOP
	LDI R20, 0x00		; load 0 into GPR 20
	LDI R16, 10			; used for subtraction of 10
	divide: 
		INC R20			; Increment R20 to show one subtraction step
		SUB R31, R16	; Number - 10, store result in R16
		BRSH divide		; branch if the number is not negative (Carry bit returns 1 if rollunder 0) <- Very ez google lol
	
	DEC R20				; After the loop above, the output would be 1 more than intended
	ADD R31, R16		; Return the remainder from the subtractions by undoing the last subtraction!

	MOV R21, R20		;move the quotient into temp GPR
	MOV R20, R31		;move remainder into R20
	MOV R31, R21		;Move quotient into R31
	CLR R21				;Clean Temp GPR

	RET	;return to main program

	;Very Respectfully,
	;Silas Rodriguez