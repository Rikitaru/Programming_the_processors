
	    LIST        P=16F877A
	    __CONFIG    0x3FFA

INDF	    equ		0x00
FSR	    equ		0x04	    
PORTC       equ         0x07
TRISC       equ         0x07
PORTB	    equ         0x06
TRISB       equ         0x06
STATUS      equ         0x03
PCL         equ         0x02
INTCON	    equ		0x0B
TMR0	    equ		0x01
OPTION_REG  equ		0x01
	    
IND_1	    equ         0x30
IND_2	    equ         0x31
	    
SAVE_W	    equ         0x20  
COUNT       equ         0x21
Reg_T       equ         0x22
TMP	    equ         0x23  
	    
Reg_1       equ         0x24
Reg_2	    equ         0x25
Reg_3	    equ         0x26
	    
	    org		0
	    goto	MAIN
	    org		4
	    call	INT_DETECTION
	    retfie
	    
MAIN:	    
	    bsf         STATUS, 5 //переход на банк 1
	    
	    movlw	b'00000111' //заносим в аккумулятор значение 00000111
	    movwf	OPTION_REG //заносим в OPTION_REG значнеие 00000111
	    
	    clrf        TRISC
	    movlw	.255
	    movwf       TRISB
	    
	    bcf         STATUS, 5
	    
	    bsf		PORTB, 4
	    bsf		PORTB, 5
	    
	    clrf        PORTC
	    
	    clrf        IND_1
	    clrf        IND_2
	    
	    movlw	b'10101000'
	    movwf	INTCON
	    
	    movlw	.100
	    movwf	COUNT
	    
	    clrf        Reg_T
	    
	    movlw	b'00000000'
	    movwf	TMP
	    
	    movlw       IND_1
	    movwf	FSR
	    
START:      
	    movfw       INDF
            call        TABLE_NUM
	    xorwf	TMP, 0
            movwf       PORTC
	    goto	START

DELAY_50M:
		movlw       .169
		movwf       Reg_1
		movlw       .69
		movwf       Reg_2
		movlw       .2
		movwf       Reg_3
		decfsz      Reg_1,1
		goto        $-1
		decfsz      Reg_2,1
		goto        $-3
		decfsz      Reg_3,1
		goto        $-5
		nop
		nop
	    
	    return
	    
INT_DETECTION:	    
	    movwf	SAVE_W
	    btfsc	INTCON, 0
	    call	EVENT_PORTB
	    btfsc	INTCON, 2
	    call	EVENT_TMR0
	    movfw	SAVE_W
	    return

EVENT_PORTB:
	    call	DELAY_50M
	    btfss	PORTB, 4
	    call	EVENT_PORTB_4

	    btfss	PORTB, 5
	    call	EVENT_PORTB_5

	    movfw	PORTB
	    bcf	    	INTCON, 0
	    
	    return
	    
EVENT_PORTB_4:
	    incf        INDF, 1
            movlw       .10
	    bcf		STATUS, 2
            subwf       INDF, 0
	    btfsc       STATUS, 2
            clrf	INDF
	    bsf		PORTB, 4
	    return


EVENT_PORTB_5:
	    decf	INDF, 1
	    movlw       .255
	    bcf		STATUS, 2
            subwf       INDF, 0
	    movlw       .9
	    btfsc       STATUS, 2
	    movwf	INDF
	    bsf		PORTB, 5
	    return
	    
EVENT_TMR0:
	    incf	Reg_T, 1
	    bcf		STATUS, 2
	    movfw	COUNT
	    subwf	Reg_T, 0
	    btfss	STATUS, 2
	    goto	END_TMR0
	    
	    movfw       FSR
	    sublw	IND_2
	    addlw	IND_1
	    movwf	FSR
	    
	    movfw	TMP
	    xorlw	b'10000000'
	    movwf	TMP
	    
	    clrf	Reg_T
	    
END_TMR0:
	    bcf		INTCON, 2
	    return

TABLE_NUM:
			addwf		PCL, 1
			retlw		b'00010000';0
			retlw		b'01011011';1
			retlw		b'00001100';2
			retlw		b'00001001';3
			retlw		b'01000011';4
			retlw		b'00100001';5
			retlw		b'00100000';6
			retlw		b'00011011';7
			retlw		b'00000000';8
			retlw		b'00000001';9
	    
	    end