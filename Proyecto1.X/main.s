;*******************************************************************************
; Universidad del Valle de Guatemala
; IE2023 Programación de Microcontroladores
; Autor: Byron Barrientos  
; Compilador: PIC-AS (v2.36), MPLAB X IDE (v6.00)
; Proyecto: Reloj
; Hardware: PIC16F887
; Creado: 23/08/2022
; Última Modificación: 23/08/2022 
;******************************************************************************* 
PROCESSOR 16F887
#include <xc.inc>
;******************************************************************************* 
; Palabra de configuración
;******************************************************************************* 
; CONFIG1
  CONFIG  FOSC = INTRC_NOCLKOUT ; Oscillator Selection bits (INTOSCIO 
                                ;oscillator: I/O function on RA6/OSC2/CLKOUT
				;pin, I/O function on RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF             ; Watchdog Timer Enable bit (WDT enabled)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = OFF           ; RE3/MCLR pin function select bit (RE3/MCLR 
                                ;pin function is digital input, MCLR internally
				;tied to VDD)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code
                                ;protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code
                                ;protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit 
                                ;(Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit 
                                ;(Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin
                                ;has digital I/O, HV on MCLR must be used for 
				;programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out 
                                ;Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits 
                                ;(Write protection off)
;******************************************************************************* 
; Variables    
;******************************************************************************* 
PSECT udata_bank0
W_TEMP:
    DS 1
STATUS_TEMP:
    DS 1
DISP:
    DS 1
U_SEG:
    DS 1
D_SEG:
    DS 1
U_MIN:
    DS 1
D_MIN:
    DS 1
CONT_1MS:
    DS 1
U_HOR:
    DS 1
D_HOR:
    DS 1
ESTADO:
    DS 1
U_DIA:
    DS 1
D_DIA:
    DS 1
U_MES:
    DS 1
D_MES:
    DS 1
MES:
    DS 1
U_SEG_ALRM:
    DS 1
D_SEG_ALRM:
    DS 1
U_MIN_ALRM:
    DS 1
D_MIN_ALRM:
    DS 1
U_HOR_ALRM:
    DS 1
D_HOR_ALRM:
    DS 1
ALRM:
    DS 1
CONT_500MS:
    DS 1
PNTS:
    DS 1

;******************************************************************************* 
; Vector Reset    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0000
    goto MAIN
    
;******************************************************************************* 
; Vector ISR Interrupciones    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0004
 
PUSH: 
    movwf W_TEMP        ; Se carga el valor de W a W_TEMP
    swapf STATUS, W     ; Se intercambian el nibble más significativo y el
                        ; nibble menos significativo de STATUS y se carga
			; en W
    movwf STATUS_TEMP   ; Se carga el valor de W a STAT_TEMP
    
ISR_RBIF:
    btfss INTCON, 0	; Revisa la bandera de interrupción de RBIF, si vale 1, 
                        ; se salta el goto ISR_TMR0
    goto ISR_TMR0
    btfss PORTB, 4      ; Revisa si el bit 4 del PORTB está en 0, si vale 0,
			; se salta el goto INC_ESTADOS
    goto INC_ESTADO
    goto SEL_ESTADO_ISR
    
INC_ESTADO:
    incf ESTADO, F	; Incrementamos en 1 el valor de ESTADO
    movf ESTADO, W	; Copia el valor de ESTADO a W
    sublw 5		; Restamos "5 - W"
    btfsc STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; clrf ESTADO
    clrf ESTADO		; Limpiamos ESTADO
    bcf INTCON, 0	; Baja la bandera que indica una interrupción en 
                        ; el RBIF
    
SEL_ESTADO_ISR:
    movf ESTADO, W	; Copia el valor de ESTADO a W
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto CHECKE1_ISR
    goto CHECKE1_ISR	
    goto ESTADO0_ISR
    
CHECKE1_ISR:    
    movf ESTADO, W	; Copia el valor de ESTADO a W
    sublw 1		; Restamos "1 - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto CHECKE2_ISR
    goto CHECKE2_ISR
    goto ESTADO1_ISR
    
CHECKE2_ISR:
    movf ESTADO, W	; Copia el valor de ESTADO a W
    sublw 2		; Restamos "2 - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto CHECKE3_ISR
    goto CHECKE3_ISR	
    goto ESTADO2_ISR
    
CHECKE3_ISR:
    movf ESTADO, W	; Copia el valor de ESTADO a W
    sublw 3		; Restamos "3 - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto CHECKE4_ISR
    goto CHECKE4_ISR
    goto ESTADO3_ISR
    
CHECKE4_ISR:    
    movf ESTADO, W	; Copia el valor de ESTADO a W
    sublw 4		; Restamos "4 - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto ISR_TMR0
    goto ISR_TMR0	
    goto ESTADO4_ISR
    
ESTADO0_ISR:
    bcf INTCON, 0	; Baja la bandera que indica una interrupción en 
                        ; el RBIF
    goto ISR_TMR0

ESTADO1_ISR:
    bcf INTCON, 0	; Baja la bandera que indica una interrupción en 
                        ; el RBIF
    goto ISR_TMR0

ESTADO2_ISR:
    
    bcf INTCON, 0	; Baja la bandera que indica una interrupción en 
			; el RBIF
    
    BTN0_E2:			
	btfsc PORTB, 0      ; Revisa si el bit 0 del PORTB está en 0, si vale 0,
			    ; se salta el goto BTN1_E2
	goto BTN1_E2
	incf U_HOR, F	    ; Se incrementa en 1 el valor de U_HOR
	goto ISR_TMR0
 
    BTN1_E2:    
	btfsc PORTB, 1      ; Revisa si el bit 1 del PORTB está en 0, si vale 0,
			    ; se salta el goto
	goto BTN2_E2
	
	DEC_U_HOR:
	    movf U_HOR, W	; Movemos el valor de U_HOR a W
	    sublw 0		; Restamos "0 - W"
	    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0,
				; se salta el DEC_U_HOR_CN
	    goto DEC_U_HOR_CN
	    goto DEC_U_HOR_C00
    
	    DEC_U_HOR_C00:
		movf D_HOR, W	    ; Movemos el valor de D_HOR a W
		sublw 0		    ; Restamos "0 - W"
		btfss STATUS, 2	    ; Revisamos que la resta sea 0, si no es 0,
				    ; se salta el return
		goto DEC_U_HOR_CX0
		movf 3, W	    ; Movemos el valor de 3 a W
		movwf U_HOR	    ; Movemos el valor de W a U_HOR
		movf 2, W	    ; Movemos el valor de 2 a W
		movwf D_HOR	    ; Movemos el valor de W a D_HOR
		goto ISR_TMR0

	    DEC_U_HOR_CX0:
		movf 9, W	    ; Movemos el valor de 9 a W
		movwf U_HOR	    ; Movemos el valor de W a U_HOR
		incf U_HOR, F
		decf D_HOR, F	    ; Se decrementa en 1 el valor de D_HOR
		goto ISR_TMR0
	
	    DEC_U_HOR_CN:
		decf U_HOR, F	    ; Se decrementa en 1 el valor de U_HOR
		goto ISR_TMR0

    BTN2_E2:
	btfsc PORTB, 2      ; Revisa si el bit 2 del PORTB está en 0, si vale 0,
			    ; se salta el goto
	goto BTN3_E2
	incf U_MIN, F	    ; Se incrementa en 1 el valor de U_MIN
	goto ISR_TMR0

    BTN3_E2:
	btfsc PORTB, 3      ; Revisa si el bit 3 del PORTB está en 0, si vale 0,
			    ; se salta el goto
	goto ISR_TMR0
	
	DEC_U_MIN:
	    movf U_MIN, W	; Movemos el valor de U_MIN a W
	    sublw 0		; Restamos "0 - W"
	    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0,
				; se salta el DEC_U_HOR_CN
	    goto DEC_U_MIN_CN
	    goto DEC_U_MIN_C00
    
	    DEC_U_MIN_C00:
		movf D_MIN, W	    ; Movemos el valor de D_MIN a W
		sublw 0		    ; Restamos "0 - W"
		btfss STATUS, 2	    ; Revisamos que la resta sea 0, si no es 0,
				    ; se salta el return
		goto DEC_U_MIN_CX0
		movf 9, W	    ; Movemos el valor de 9 a W
		movwf U_MIN	    ; Movemos el valor de W a U_MIN
		incf U_MIN, F
		movf 5, W	    ; Movemos el valor de 5 a W
		movwf D_MIN	    ; Movemos el valor de W a D_MIN
		incf D_MIN, F
		goto ISR_TMR0

	    DEC_U_MIN_CX0:
		movf 9, W	    ; Movemos el valor de 9 a W
		movwf U_MIN	    ; Movemos el valor de W a U_MIN
		incf U_MIN, F
		decf D_MIN, F	    ; Se decrementa en 1 el valor de D_MIN
		goto ISR_TMR0
	
	    DEC_U_MIN_CN:
		decf U_MIN, F	    ; Se decrementa en 1 el valor de U_MIN
		goto ISR_TMR0
    
ESTADO3_ISR:
    
    bcf INTCON, 0	; Baja la bandera que indica una interrupción en 
			; el RBIF
    
    BTN0_E3:			
	btfsc PORTB, 0      ; Revisa si el bit 0 del PORTB está en 0, si vale 0,
			    ; se salta el goto BTN1_E2
	goto BTN1_E3
	incf U_DIA, F	    ; Se incrementa en 1 el valor de U_DIA
	goto ISR_TMR0
 
    BTN1_E3:    
	btfsc PORTB, 1      ; Revisa si el bit 1 del PORTB está en 0, si vale 0,
			    ; se salta el goto
	goto BTN2_E3
	decf U_DIA, F
	goto ISR_TMR0
	
    BTN2_E3:
	btfsc PORTB, 2      ; Revisa si el bit 2 del PORTB está en 0, si vale 0,
			    ; se salta el goto
	goto BTN3_E3
	incf U_MES, F	    ; Se incrementa en 1 el valor de U_MES
	incf MES	    ; Se incrementa en 1 el valor de MES
	goto ISR_TMR0

    BTN3_E3:
	btfsc PORTB, 3      ; Revisa si el bit 3 del PORTB está en 0, si vale 0,
			    ; se salta el goto
	goto ISR_TMR0
	
	DEC_U_MES:
	    movf U_MES, W	; Movemos el valor de U_MES a W
	    sublw 0		; Restamos "0 - W"
	    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0,
				; se salta el DEC_U_MES_CN
	    goto DEC_U_MES_CN
	    goto DEC_U_MES_C00
    
	    DEC_U_MES_C00:
		movf D_MES, W	    ; Movemos el valor de D_MES a W
		sublw 0		    ; Restamos "0 - W"
		btfss STATUS, 2	    ; Revisamos que la resta sea 0, si no es 0,
				    ; se salta el return
		goto DEC_U_MES_CX0
		movf 2, W	    ; Movemos el valor de 2 a W
		movwf U_MES	    ; Movemos el valor de W a U_MES
		movf 1, W	    ; Movemos el valor de 1 a W
		movwf D_MES	    ; Movemos el valor de W a D_MES
		movf 12, W	    ; Movemos el valor de 12 a W
		movwf MES	    ; Movemos el valor de W a MES
		goto ISR_TMR0

	    DEC_U_MES_CX0:
		movf 9, W	    ; Movemos el valor de 9 a W
		movwf U_MES	    ; Movemos el valor de W a U_MES
		incf U_MES, F
		decf D_MES, F	    ; Se decrementa en 1 el valor de D_MES
		decf MES	    ; Se decrementa en 1 el valor de MES
		goto ISR_TMR0
	
	    DEC_U_MES_CN:
		decf U_MES, F	    ; Se decrementa en 1 el valor de U_MES
		decf MES	    ; Se decrementa en 1 el valor de MES
		goto ISR_TMR0

ESTADO4_ISR:
    
    bcf INTCON, 0	; Baja la bandera que indica una interrupción en 
			; el RBIF
    
    BTN0_E4:			
	btfsc PORTB, 0      ; Revisa si el bit 0 del PORTB está en 0, si vale 0,
			    ; se salta el goto BTN1_E2
	goto BTN1_E4
	incf U_HOR_ALRM, F  ; Se incrementa en 1 el valor de U_HOR_ALRM
	goto ISR_TMR0
 
    BTN1_E4:    
	btfsc PORTB, 1      ; Revisa si el bit 1 del PORTB está en 0, si vale 0,
			    ; se salta el goto
	goto BTN2_E4
	decf U_HOR_ALRM, F  ; Se decrementa en 1 el valor de U_HOR_ALRM
	goto ISR_TMR0

    BTN2_E4:
	btfsc PORTB, 2      ; Revisa si el bit 2 del PORTB está en 0, si vale 0,
			    ; se salta el goto
	goto BTN3_E4
	incf U_MIN_ALRM, F  ; Se incrementa en 1 el valor de U_MIN_ALRM
	goto ISR_TMR0

    BTN3_E4:
	btfsc PORTB, 3      ; Revisa si el bit 3 del PORTB está en 0, si vale 0,
			    ; se salta el goto
	goto ISR_TMR0
	decf U_MIN_ALRM, F  ; Se decrementa en 1 el valor de U_MIN_ALRM
	goto ISR_TMR0
	
ISR_TMR0:
    btfss INTCON, 2	; Revisa la bandera de interrupción de TMR0, si vale 1, 
                        ; se salta el goto POP
    goto ISR_TMR1
    bcf INTCON, 2	; Baja la bandera que indica una interrupción en 
                        ; el TMR0
    movlw 240		; Cargamos 240 a W
    movwf TMR0		; Cargamos W a TMR0
    incf CONT_1MS, F	; Incrementamos en 1 el valor de CONT_1MS
    incf CONT_500MS, F	; Incrementamos en 1 el valor de CONT_500MS
    
ISR_TMR1:
    btfss PIR1, 0	; Revisa la bandera de interrupción de TMR1, si vale 1, 
                        ; se salta el goto POP
    goto POP
    bcf PIR1, 0		; Baja la bandera que indica una interrupción en 
                        ; el TMR1
    movlw 0xEE		; Cargamos 0xEE a W
    movwf TMR1L         ; Cargamos W a TMR1L
    movlw 0x85		; Cargamos 0x85 a W
    movwf TMR1H         ; Cargamos W a TMR1H
    incf U_SEG, F
   
POP:
    swapf STATUS_TEMP, W  ; Se intercambian el nibble más significativo y el
                        ; nibble menos significativo de STAT_TEMP y se carga
			; en W
    movwf STATUS        ; Se carga el valor de W a STATUS
    swapf W_TEMP, F     ; Se intercambian el nibble más significativo y el
                        ; nibble menos significativo de W_TEMP y se carga
			; en F
    swapf W_TEMP, W     ; Se intercambian el nibble más significativo y el
                        ; nibble menos significativo de W_TEMP y se carga
			; en W
    retfie    
    
;******************************************************************************* 
; Código Principal    
;******************************************************************************* 
PSECT CODE, delta=2, abs
 ORG 0x0200

MAIN:
    
    ; Configuración del oscilador interno
    
    BANKSEL OSCCON
    
    ; Selección de 1MHz
    
    bsf OSCCON, 6	; IRCF2
    bcf OSCCON, 5	; IRCF1
    bcf OSCCON, 4	; IRCF0
    
    bsf OSCCON, 0	; SCS Reloj Interno
    
    ; Configuración de puertos
    
    BANKSEL ANSEL
    
    clrf ANSEL          
    clrf ANSELH         ; I/O Digitales
    
    BANKSEL TRISA
    
    clrf TRISA
    
    bcf TRISC, 0	; DISP0
    bcf TRISC, 1	; DISP1
    bcf TRISC, 2	; DISP2
    bcf TRISC, 3	; DISP3
    bcf TRISC, 4	; PT0
    bcf TRISC, 5	; PT1
    bcf TRISC, 6	; ALRM
    
    clrf TRISD		; Se configuran los puertos A, C y D como outputs
    
    bsf TRISB, 0
    bsf TRISB, 1	
    bsf TRISB, 2
    bsf TRISB, 3
    bsf TRISB, 4	; Se configuran RB0, RB1, RB2, RB3 y RB4 como inputs
    
    BANKSEL WPUB
    
    bsf WPUB, 0
    bsf WPUB, 1
    bsf WPUB, 2		
    bsf WPUB, 3
    bsf WPUB, 4		; Habilitando los pull-ups en RB0, RB1, RB2, RB3 y RB4
    
    BANKSEL PORTC
    
    clrf PORTA		; Se limpia PORTA
    clrf PORTC          ; Se limpia PORTC
    clrf PORTD          ; Se limpia PORTD
    
    clrf U_SEG
    clrf D_SEG
    clrf U_MIN
    clrf D_MIN
    clrf DISP
    clrf CONT_1MS
    clrf CONT_500MS
    clrf U_HOR
    clrf D_HOR
    clrf ESTADO
    clrf U_DIA
    incf U_DIA		; Incrementamos en 1 el valor de U_DIA
    clrf D_DIA
    clrf U_MES
    incf U_MES		; Incrementamos en 1 el valor de U_MES
    clrf D_MES
    clrf MES
    incf MES		; Incrementamos en 1 el valor de MES
    clrf PNTS
    clrf U_SEG_ALRM
    clrf D_SEG_ALRM
    clrf U_MIN_ALRM
    movf 5, W
    movwf U_MIN_ALRM
    clrf D_MIN_ALRM
    clrf U_HOR_ALRM
    clrf D_HOR_ALRM
    
    BANKSEL OPTION_REG
    
    bcf OPTION_REG, 7	; Habilitando que el PORTB tenga pull-ups
    
    BANKSEL PIE1
    
    bsf PIE1, 0		; Habilitamos la interrupción del TMR1
    
    BANKSEL PIR1
    
    bcf PIR1, 0		; Baja la bandera que indica una interrupción en
			; el TMR1
    
    BANKSEL IOCB
    
    bsf IOCB, 0
    bsf IOCB, 1
    bsf IOCB, 2
    bsf IOCB, 3
    bsf IOCB, 4		; Habilitando RB0, RB1, RB2, RB3 y RB4 para las ISR 
			; de RBIE
    
    ; Configuración del TMR0
    
    BANKSEL OPTION_REG
    
    bcf OPTION_REG, 5	; T0CS; FOSC/4 como reloj (modo temporizador)
    bcf OPTION_REG, 3	; PSA: asignamos el prescaler al TMR0
    
    ; PS2-0: Selección del prescaler en 1:16
    
    bsf OPTION_REG, 0
    bsf OPTION_REG, 1
    bcf OPTION_REG, 2
    
    ; Cargamos el valor de N = 240 (Desborde de 1ms)
    
    BANKSEL TMR0
    
    movlw 240
    movwf TMR0
    
    ; Configuración del TMR1
    
    BANKSEL T1CON
    
    bsf T1CON, 0	; Habilitamos el TMR1
    bcf T1CON, 1	; Selección del Reloj Interno
    
    ; Selección del prescaler en 1:8
    
    bsf T1CON, 4
    bsf T1CON, 5
    
    ; Cargamos el valor de N = 34286 = 0x85EE (Desborde de 1s)
    
    BANKSEL TMR1L
    
    movlw 0xEE
    movwf TMR1L
    movlw 0x85
    movwf TMR1H
    
    ; Configuración de las interrupciones
    
    BANKSEL INTCON
    
    bsf INTCON, 7       ; Habilitamos las interrupciones globales (GIE)
    bsf INTCON, 6       ; Habilitamos la interrupción del PEIE
    bsf INTCON, 5	; Habilitamos la interrupción del T0IE
    bsf INTCON, 3       ; Habilitamos la interrupción del PORTB (RBIF)
    bcf INTCON, 2	; Baja la bandera que indica una interrupción en
			; el TMR0
    bcf INTCON, 0       ; Baja la bandera que indica una interrupción en
                        ; el PORTB

;******************************************************************************* 
; Loop   
;*******************************************************************************     
    
LOOP:
    
CHECK_E0:
    movf ESTADO, W	; Copia el valor de ESTADO a W
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto CHECK_E1
    goto CHECK_E1	
    goto ESTADO0
    
CHECK_E1:    
    movf ESTADO, W	; Copia el valor de ESTADO a W
    sublw 1		; Restamos "1 - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto CHECK_E2
    goto CHECK_E2
    goto ESTADO1
    
CHECK_E2:
    movf ESTADO, W	; Copia el valor de ESTADO a W
    sublw 2		; Restamos "2 - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto CHECK_E3
    goto CHECK_E3	
    goto ESTADO2
    
CHECK_E3:
    movf ESTADO, W	; Copia el valor de ESTADO a W
    sublw 3		; Restamos "3 - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto CHECK_E4
    goto CHECK_E4	
    goto ESTADO3
    
CHECK_E4:    
    movf ESTADO, W	; Copia el valor de ESTADO a W
    sublw 4		; Restamos "4 - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto CHECK_TIEMPO
    goto CHECK_TIEMPO	
    goto ESTADO4
    
ESTADO0:
    bsf TRISA, 0	; Encendemos LED que indica el modo HRS
    bcf TRISA, 1	; Apagamos LED que indica el modo FCH
    bcf TRISA, 2	; Apagamos LED que indica el modo CONF. H
    bcf TRISA, 3	; Apagamos LED que indica el modo CONF. F
    bcf TRISA, 4	; Apagamos LED que indica el modo CONF. ALRM
    goto CHECK_TIEMPO

ESTADO1:
    bcf TRISA, 0	; Apagamos LED que indica el modo HRS
    bsf TRISA, 1	; Encendemos LED que indica el modo FCH
    bcf TRISA, 2	; Apagamos LED que indica el modo CONF. H
    bcf TRISA, 3	; Apagamos LED que indica el modo CONF. F
    bcf TRISA, 4	; Apagamos LED que indica el modo CONF. ALRM
    goto CHECK_TIEMPO

ESTADO2:
    bcf TRISA, 0	; Apagamos LED que indica el modo HRS
    bcf TRISA, 1	; Apagamos LED que indica el modo FCH
    bsf TRISA, 2	; Encendemos LED que indica el modo CONF. H
    bcf TRISA, 3	; Apagamos LED que indica el modo CONF. F
    bcf TRISA, 4	; Apagamos LED que indica el modo CONF. ALRM
    goto CHECK_TIEMPO
    
ESTADO3:
    bcf TRISA, 0	; Apagamos LED que indica el modo HRS
    bcf TRISA, 1	; Apagamos LED que indica el modo FCH
    bcf TRISA, 2	; Apagamos LED que indica el modo CONF. H
    bsf TRISA, 3	; Encendemos LED que indica el modo CONF. F
    bcf TRISA, 4	; Apagamos LED que indica el modo CONF. ALRM
    goto CHECK_TIEMPO

ESTADO4:
    bcf TRISA, 0	; Apagamos LED que indica el modo HRS
    bcf TRISA, 1	; Apagamos LED que indica el modo FCH
    bcf TRISA, 2	; Apagamos LED que indica el modo CONF. H
    bcf TRISA, 3	; Apagamos LED que indica el modo CONF. F
    bsf TRISA, 4	; Encendemos LED que indica el modo CONF. ALRM
    
CHECK_TIEMPO:    
    call CHECK_SEG
    call CHECK_MIN
    call CHECK_HOR
    call CHECK_DIA
    call CHECK_MES
    call CHECK_MIN_ALRM
    call CHECK_HOR_ALRM
    
CHECK_DISP_E0:
    movf ESTADO, W	; Copia el valor de ESTADO a W
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto CHECK_DISP_E1
    goto CHECK_DISP_E1	
    goto CHECK_X_E0_E2
    
CHECK_DISP_E1:    
    movf ESTADO, W	; Copia el valor de ESTADO a W
    sublw 1		; Restamos "1 - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto CHECK_DISP_E2
    goto CHECK_DISP_E2	
    goto CHECK_X_E1_E3
    
CHECK_DISP_E2:
    movf ESTADO, W	; Copia el valor de ESTADO a W
    sublw 2		; Restamos "2 - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto CHECK_DISP_E3
    goto CHECK_DISP_E3	
    goto CHECK_X_E0_E2
    
CHECK_DISP_E3:
    movf ESTADO, W	; Copia el valor de ESTADO a W
    sublw 3		; Restamos "3 - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto CHECK_DISP_E4
    goto CHECK_DISP_E4	
    goto CHECK_X_E1_E3
    
CHECK_DISP_E4:    
    movf ESTADO, W	; Copia el valor de ESTADO a W
    sublw 4		; Restamos "4 - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto VERIFICACION
    goto VERIFICACION
    goto CHECK_X_E4
    
CHECK_X_E0_E2:
    btfss DISP, 0	; Si el valor del bit 0 de DISP es 1, se salta el
			; goto CHECK_Y
    goto CHECK_Y_E0_E2
    btfss DISP, 1	; Si el valor del bit 1 de DISP es 1, se salta el
			; goto DISP1
    goto DISP1_E0_E2	; DISP = 01
    goto DISP3_E0_E2	; DISP = 11
    
CHECK_Y_E0_E2:
    btfss DISP, 1	; Si el valor del bit 1 de DISP es 1, se salta el
			; goto DISP1
    goto DISP0_E0_E2	; DISP = 00
    goto DISP2_E0_E2	; DISP = 10
    
DISP0_E0_E2:
    bsf TRISC, 0	; Encendemos DISP0
    bcf TRISC, 1	; Apagamos DISP1
    bcf TRISC, 2	; Apagamos DISP2
    bcf TRISC, 3	; Apagamos DISP3
    movf U_MIN, W	; Copia el valor de U_MIN a W
    PAGESEL TABLA
    call TABLA
    PAGESEL DISP0_E0_E2
    movwf PORTD		; Se carga W a PORTD
    incf DISP, F
    goto VERIFICACION
    
DISP1_E0_E2:
    bcf TRISC, 0	; Apagamos DISP0
    bsf TRISC, 1	; Encendemos DISP1
    bcf TRISC, 2	; Apagamos DISP2
    bcf TRISC, 3	; Apagamos DISP3
    movf D_MIN, W	; Copia el valor de D_MIN a W
    PAGESEL TABLA
    call TABLA
    PAGESEL DISP1_E0_E2
    movwf PORTD		; Se carga W a PORTD
    incf DISP, F
    goto VERIFICACION
    
DISP2_E0_E2:
    bcf TRISC, 0	; Apagamos DISP0
    bcf TRISC, 1	; Apagamos DISP1
    bsf TRISC, 2	; Encendemos DISP2
    bcf TRISC, 3	; Apagamos DISP3
    movf U_HOR, W	; Copia el valor de U_HOR a W
    PAGESEL TABLA
    call TABLA
    PAGESEL DISP2_E0_E2
    movwf PORTD		; Se carga W a PORTD
    incf DISP, F
    goto VERIFICACION
    
DISP3_E0_E2:
    bcf TRISC, 0	; Apagamos DISP0
    bcf TRISC, 1	; Apagamos DISP1
    bcf TRISC, 2	; Apagamos DISP2
    bsf TRISC, 3	; Encendemos DISP3
    movf D_HOR, W	; Copia el valor de D_HOR a W
    PAGESEL TABLA
    call TABLA
    PAGESEL DISP3_E0_E2
    movwf PORTD		; Se carga W a PORTD
    clrf DISP		; Limpiamos DISP
    goto VERIFICACION
    
CHECK_X_E1_E3:
    btfss DISP, 0	; Si el valor del bit 0 de DISP es 1, se salta el
			; goto CHECK_Y
    goto CHECK_Y_E1_E3
    btfss DISP, 1	; Si el valor del bit 1 de DISP es 1, se salta el
			; goto DISP1
    goto DISP1_E1_E3	; DISP = 01
    goto DISP3_E1_E3	; DISP = 11
    
CHECK_Y_E1_E3:
    btfss DISP, 1	; Si el valor del bit 1 de DISP es 1, se salta el
			; goto DISP1
    goto DISP0_E1_E3	; DISP = 00
    goto DISP2_E1_E3	; DISP = 10
    
DISP0_E1_E3:
    bsf TRISC, 0	; Encendemos DISP0
    bcf TRISC, 1	; Apagamos DISP1
    bcf TRISC, 2	; Apagamos DISP2
    bcf TRISC, 3	; Apagamos DISP3
    movf U_MES, W	; Copia el valor de U_MES a W
    PAGESEL TABLA
    call TABLA
    PAGESEL DISP0_E1_E3
    movwf PORTD		; Se carga W a PORTD
    incf DISP, F
    goto VERIFICACION
    
DISP1_E1_E3:
    bcf TRISC, 0	; Apagamos DISP0
    bsf TRISC, 1	; Encendemos DISP1
    bcf TRISC, 2	; Apagamos DISP2
    bcf TRISC, 3	; Apagamos DISP3
    movf D_MES, W	; Copia el valor de D_MES a W
    PAGESEL TABLA
    call TABLA
    PAGESEL DISP1_E1_E3
    movwf PORTD		; Se carga W a PORTD
    incf DISP, F
    goto VERIFICACION
    
DISP2_E1_E3:
    bcf TRISC, 0	; Apagamos DISP0
    bcf TRISC, 1	; Apagamos DISP1
    bsf TRISC, 2	; Encendemos DISP2
    bcf TRISC, 3	; Apagamos DISP3
    movf U_DIA, W	; Copia el valor de U_HOR a W
    PAGESEL TABLA
    call TABLA
    PAGESEL DISP2_E1_E3
    movwf PORTD		; Se carga W a PORTD
    incf DISP, F
    goto VERIFICACION
    
DISP3_E1_E3:
    bcf TRISC, 0	; Apagamos DISP0
    bcf TRISC, 1	; Apagamos DISP1
    bcf TRISC, 2	; Apagamos DISP2
    bsf TRISC, 3	; Encendemos DISP3
    movf D_DIA, W	; Copia el valor de D_HOR a W
    PAGESEL TABLA
    call TABLA
    PAGESEL DISP3_E1_E3
    movwf PORTD		; Se carga W a PORTD
    clrf DISP		; Limpiamos DISP
    goto VERIFICACION
    
CHECK_X_E4:
    btfss DISP, 0	; Si el valor del bit 0 de DISP es 1, se salta el
			; goto CHECK_Y
    goto CHECK_Y_E4
    btfss DISP, 1	; Si el valor del bit 1 de DISP es 1, se salta el
			; goto DISP1
    goto DISP1_E4	; DISP = 01
    goto DISP3_E4	; DISP = 11
    
CHECK_Y_E4:
    btfss DISP, 1	; Si el valor del bit 1 de DISP es 1, se salta el
			; goto DISP1
    goto DISP0_E4	; DISP = 00
    goto DISP2_E4	; DISP = 10
    
DISP0_E4:
    bsf TRISC, 0	; Encendemos DISP0
    bcf TRISC, 1	; Apagamos DISP1
    bcf TRISC, 2	; Apagamos DISP2
    bcf TRISC, 3	; Apagamos DISP3
    movf U_MIN_ALRM, W	; Copia el valor de U_MIN_ALRM a W
    PAGESEL TABLA
    call TABLA
    PAGESEL DISP0_E4
    movwf PORTD		; Se carga W a PORTD
    incf DISP, F
    goto VERIFICACION
    
DISP1_E4:
    bcf TRISC, 0	; Apagamos DISP0
    bsf TRISC, 1	; Encendemos DISP1
    bcf TRISC, 2	; Apagamos DISP2
    bcf TRISC, 3	; Apagamos DISP3
    movf D_MIN_ALRM, W	; Copia el valor de D_MIN_ALRM a W
    PAGESEL TABLA
    call TABLA
    PAGESEL DISP1_E4
    movwf PORTD		; Se carga W a PORTD
    incf DISP, F
    goto VERIFICACION
    
DISP2_E4:
    bcf TRISC, 0	; Apagamos DISP0
    bcf TRISC, 1	; Apagamos DISP1
    bsf TRISC, 2	; Encendemos DISP2
    bcf TRISC, 3	; Apagamos DISP3
    movf U_HOR_ALRM, W	; Copia el valor de U_HOR_ALRM a W
    PAGESEL TABLA
    call TABLA
    PAGESEL DISP2_E4
    movwf PORTD		; Se carga W a PORTD
    incf DISP, F
    goto VERIFICACION
    
DISP3_E4:
    bcf TRISC, 0	; Apagamos DISP0
    bcf TRISC, 1	; Apagamos DISP1
    bcf TRISC, 2	; Apagamos DISP2
    bsf TRISC, 3	; Encendemos DISP3
    movf D_HOR_ALRM, W	; Copia el valor de D_HOR_ALRM a W
    PAGESEL TABLA
    call TABLA
    PAGESEL DISP3_E4
    movwf PORTD		; Se carga W a PORTD
    clrf DISP		; Limpiamos DISP
    goto VERIFICACION
    
VERIFICACION:
    movf CONT_1MS, W	; Copia el valor de CONT_1MS a W
    sublw 10		; Restamos "10 - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto VERIFICACION
    goto VERIFICACION
    clrf CONT_1MS	; Limpiamos CONT_1MS
    
    movf CONT_500MS, W	; Copia el valor de CONT_500MS a W
    sublw 500		; Restamos "500 - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto VERIFICACION
    goto ALARMA
    clrf CONT_500MS	; Limpiamos CONT_500MS
    movf PNTS, W	; Copia el valor de PNTS a W
    sublw 1		; Restamos "1 - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0, se salta el
			; goto PNTS_EN_0
    goto PNTS_EN_0
    goto PNTS_EN_1
    
    PNTS_EN_0:
	bcf TRISC, 4	; Se apaga el bit 4 de PORTC
	bcf TRISC, 5	; Se apaga el bit 5 de PORTC
	incf PNTS, F	; Se incrementa en 1 el valor de PNTS
	goto ALARMA
	
    PNTS_EN_1:
	bsf TRISC, 4	; Se enciende el bit 4 de PORTC
	bsf TRISC, 5	; Se enciende el bit 5 de PORTC
	decf PNTS, F	; Se decrementa en 1 el valor de PNTS
	goto ALARMA
    
ALARMA:
;    movf U_SEG, W	; Movemos el valor de U_SEG a W
;    sublw U_SEG_ALRM	; Restamos "U_SEG_ALRM - W"
;    btfss STATUS, 2	; Revisamos que la resta sea 0, si es 0,
;			; se salta el goto ISR_TMR1
;    goto ISR_TMR1	
;    movf D_SEG, W	; Movemos el valor de D_SEG a W
;    sublw D_SEG_ALRM	; Restamos "D_SEG_ALRM - W"
;    btfss STATUS, 2	; Revisamos que la resta sea 0, si es 0,
;			; se salta el goto ISR_TMR1
;    goto ISR_TMR1	
    
    movf U_MIN, W	; Movemos el valor de U_MIN a W
    sublw U_MIN_ALRM	; Restamos "U_MIN_ALRM - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si es 0,
			; se salta el goto ISR_TMR1
    goto LOOP	
    movf D_MIN, W	; Movemos el valor de D_MIN a W
    sublw D_MIN_ALRM	; Restamos "D_MIN_ALRM - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si es 0,
			; se salta el goto ISR_TMR1
    goto LOOP	
    
    movf U_HOR, W	; Movemos el valor de U_HOR a W
    sublw U_HOR_ALRM	; Restamos "U_HOR_ALRM - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si es 0,
			; se salta el goto ISR_TMR1
    goto LOOP	
    movf D_HOR, W	; Movemos el valor de D_HOR a W
    sublw D_HOR_ALRM	; Restamos "D_HOR_ALRM - W"
    btfss STATUS, 2	; Revisamos que la resta sea 0, si es 0,
			; se salta el goto ISR_TMR1
    goto LOOP	
    bsf TRISC, 6	; Se enciende el bit 6 del PORTC (LED de alarma)
    incf ALRM		; Se incrementa en 1 el valor de ALRM
    goto LOOP
    
CHECK_SEG:
        
    INC_U_SEG:
	movf U_SEG, W		; Movemos el valor de U_SEG a W
	sublw 10		; Restamos "10 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	return		
	clrf U_SEG		; Limpiamos U_SEG

    INC_D_SEG:
	incf D_SEG, F		; Incrementamos en 1 el valor de D_SEG
	movf D_SEG, W		; Movemos el valor de D_SEG a W
	sublw 6			; Restamos "6 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	return
	clrf D_SEG		; Limpiamos D_SEG
	incf U_MIN, F		; Incrementamos en 1 el valor de U_MIN
	call CHECK_MIN
	return
	
CHECK_MIN:
    
    INC_U_MIN:
	movf U_MIN, W		; Movemos el valor de U_MIN a W
	sublw 10	   	; Restamos "10 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	return
	clrf U_MIN		; Limpiamos U_MIN

    INC_D_MIN:
	incf D_MIN, F		; Incrementamos en 1 el valor de D_MIN
	movf D_MIN, W		; Movemos el valor de D_MIN a W
	sublw 6			; Restamos "6 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	return
	clrf D_MIN		; Limpiamos D_MIN
	incf U_HOR		; Incrementamos en 1 el valor de U_HOR
	call CHECK_HOR		
	return
	
CHECK_HOR:
    
	movf D_HOR, W		; Movemos el valor de D_HOR a W
	sublw 2			; Restamos "2 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el INC_U_HOR
	goto INC_U_HOR
	goto INC_U_HOR_2
    
    INC_U_HOR:
	movf U_HOR, W		; Movemos el valor de U_HOR a W
	sublw 10		; Restamos "10 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	return
	clrf U_HOR		; Limpiamos U_HOR
	goto INC_D_HOR

    INC_U_HOR_2:
	movf U_HOR, W		; Movemos el valor de U_HOR a W
	sublw 4			; Restamos "4 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	return
	clrf U_HOR		; Limpiamos U_HOR
	clrf D_HOR		; Limpiamos D_HOR
	incf U_DIA		; Incrementamos en 1 el valor de U_DIA
	return
	
    INC_D_HOR:
	incf D_HOR, F		; Incrementamos en 1 el valor de D_HOR
	return

CHECK_DIA:
    
    CHECK_ENE:
	movf MES, W		; Copia el valor de MES a W
	sublw 1			; Restamos "1 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el goto CHECK_FEB
	goto CHECK_FEB	
	goto MES_31

    CHECK_FEB:    
	movf MES, W		; Copia el valor de MES a W
	sublw 2			; Restamos "2 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el goto CHECK_MAR
	goto CHECK_MAR
	goto MES_28

    CHECK_MAR:
	movf MES, W		; Copia el valor de MES a W
	sublw 3			; Restamos "3 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el goto CHECK_ABR
	goto CHECK_ABR	
	goto MES_31

    CHECK_ABR:
	movf MES, W		; Copia el valor de MES a W
	sublw 4			; Restamos "4 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el goto CHECK_MAY
	goto CHECK_MAY	
	goto MES_30

    CHECK_MAY:    
	movf MES, W		; Copia el valor de MES a W
	sublw 5			; Restamos "5 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el goto CHECK_JUN
	goto CHECK_JUN
	goto MES_31

    CHECK_JUN:
	movf MES, W		; Copia el valor de MES a W
	sublw 6			; Restamos "6 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el goto CHECK_JUL
	goto CHECK_JUL	
	goto MES_30

    CHECK_JUL:
	movf MES, W		; Copia el valor de MES a W
	sublw 7			; Restamos "7 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el goto CHECK_AGO
	goto CHECK_AGO	
	goto MES_31

    CHECK_AGO:    
	movf MES, W		; Copia el valor de MES a W
	sublw 8			; Restamos "8 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el goto CHECK_SEP
	goto CHECK_SEP
	goto MES_31

    CHECK_SEP:
	movf MES, W		; Copia el valor de MES a W
	sublw 9			; Restamos "9 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
			        ; se salta el goto CHECK_OCT
	goto CHECK_OCT	
	goto MES_30

    CHECK_OCT:
	movf MES, W		; Copia el valor de MES a W
	sublw 10		; Restamos "10 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
			        ; se salta el goto CHECK_NOV
	goto CHECK_NOV	
	goto MES_31

    CHECK_NOV:    
	movf MES, W		; Copia el valor de MES a W
	sublw 11		; Restamos "11 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el goto CHECK_DIC
	goto CHECK_DIC
	goto MES_30

    CHECK_DIC:
	movf MES, W		; Copia el valor de MES a W
	sublw 12		; Restamos "12 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	return	
	goto MES_31
	
    MES_31:
	
	movf D_DIA, W		; Movemos el valor de D_DIA a W
	sublw 3			; Restamos "3 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el INC_U_DIA_ENE1
	goto INC_U_DIA_MES_31
	goto INC_U_DIA_MES_31_2
    
	INC_U_DIA_MES_31:
	    movf U_DIA, W	; Movemos el valor de U_HOR a W
	    sublw 10		; Restamos "10 - W"
	    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	    return
	    clrf U_DIA		; Limpiamos U_DIA
	    goto INC_D_DIA_MES_31

	INC_U_DIA_MES_31_2:
	    movf U_DIA, W	; Movemos el valor de U_DIA a W
	    sublw 2		; Restamos "2 - W"
	    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	    return
	    clrf U_DIA		; Limpiamos U_DIA
	    incf U_DIA		; Incrementamos en 1 el valor de U_DIA
	    clrf D_DIA		; Limpiamos D_DIA
	    incf U_MES		; Incrementamos en 1 el valor de U_MES
	    incf MES		; Incrementamos en 1 el valor de MES
	    return

	INC_D_DIA_MES_31:
	    incf D_DIA, F	; Incrementamos en 1 el valor de D_DIA
	    return
	
    MES_28:
    
	movf D_DIA, W		; Movemos el valor de D_DIA a W
	sublw 2			; Restamos "2 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el INC_U_DIA_FEB1
	goto INC_U_DIA_MES_28
	goto INC_U_DIA_MES_28_2
    
	INC_U_DIA_MES_28:
	    movf U_DIA, W	; Movemos el valor de U_HOR a W
	    sublw 10		; Restamos "10 - W"
	    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	    return
	    clrf U_DIA		; Limpiamos U_DIA
	    goto INC_D_DIA_MES_28

	INC_U_DIA_MES_28_2:
	    movf U_DIA, W	; Movemos el valor de U_DIA a W
	    sublw 9		; Restamos "9 - W"
	    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	    return
	    clrf U_DIA		; Limpiamos U_DIA
	    incf U_DIA		; Incrementamos en 1 el valor de U_DIA
	    clrf D_DIA		; Limpiamos D_DIA
	    incf U_MES		; Incrementamos en 1 el valor de U_MES
	    incf MES		; Incrementamos en 1 el valor de MES
	    return

	INC_D_DIA_MES_28:
	    incf D_DIA, F	; Incrementamos en 1 el valor de D_DIA
	    return
	
    MES_30:
	
	movf D_DIA, W		; Movemos el valor de D_DIA a W
	sublw 3			; Restamos "3 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el INC_U_DIA_MAR1
	goto INC_U_DIA_MES_30
	goto INC_U_DIA_MES_30_2
    
	INC_U_DIA_MES_30:
	    movf U_DIA, W	; Movemos el valor de U_DIA a W
	    sublw 10		; Restamos "10 - W"
	    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	    return
	    clrf U_DIA		; Limpiamos U_DIA
	    goto INC_D_DIA_MES_30

	INC_U_DIA_MES_30_2:
	    movf U_DIA, W	; Movemos el valor de U_DIA a W
	    sublw 2		; Restamos "2 - W"
	    btfss STATUS, 2	; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	    return
	    clrf U_DIA		; Limpiamos U_DIA
	    incf U_DIA		; Incrementamos en 1 el valor de U_DIA
	    clrf D_DIA		; Limpiamos D_DIA
	    incf U_MES		; Incrementamos en 1 el valor de U_MES
	    incf MES		; Incrementamos en 1 el valor de MES
	    return

	INC_D_DIA_MES_30:
	    incf D_DIA, F	; Incrementamos en 1 el valor de D_DIA
	    return

CHECK_MES:
    
    	movf D_MES, W		; Movemos el valor de D_MES a W
	sublw 1			; Restamos "1 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el INC_U_MES
	goto INC_U_MES
	goto INC_U_MES_2
    
    INC_U_MES:
	movf U_MES, W		; Movemos el valor de U_MES a W
	sublw 10		; Restamos "10 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	return
	clrf U_MES		; Limpiamos U_MES
	clrf MES		; Limpiamos MES
	goto INC_D_MES

    INC_U_MES_2:
	movf U_MES, W		; Movemos el valor de U_MES a W
	sublw 3			; Restamos "3 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	return
	clrf U_MES		; Limpiamos U_MES
	incf U_MES		; Incrementamos en 1 el valor de U_MES
	clrf MES		; Limpiamos MES
	incf MES		; Incrementamos en 1 el valor de MES
	clrf D_MES		; Limpiamos D_MES
	return
	
    INC_D_MES:
	incf D_MES, F		; Incrementamos en 1 el valor de D_MES
	return
	
CHECK_MIN_ALRM:
    
    INC_U_MIN_ALRM:
	movf U_MIN_ALRM, W	; Movemos el valor de U_MIN_ALRM a W
	sublw 10	   	; Restamos "10 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	return
	clrf U_MIN_ALRM		; Limpiamos U_MIN_ALRM

    INC_D_MIN_ALRM:
	incf D_MIN_ALRM, F	; Incrementamos en 1 el valor de D_MIN_ALRM
	movf D_MIN_ALRM, W	; Movemos el valor de D_MIN_ALRM a W
	sublw 6			; Restamos "6 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	return
	clrf D_MIN_ALRM		; Limpiamos D_MIN_ALRM
	incf U_HOR_ALRM		; Incrementamos en 1 el valor de U_HOR_ALRM
	call CHECK_HOR_ALRM		
	return
	
CHECK_HOR_ALRM:
    
	movf D_HOR_ALRM, W	; Movemos el valor de D_HOR_ALRM a W
	sublw 2			; Restamos "2 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el INC_U_HOR_ALRM
	goto INC_U_HOR_ALRM
	goto INC_U_HOR_2_ALRM
    
    INC_U_HOR_ALRM:
	movf U_HOR_ALRM, W	; Movemos el valor de U_HOR_ALRM a W
	sublw 10		; Restamos "10 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	return
	clrf U_HOR_ALRM		; Limpiamos U_HOR_ALRM
	goto INC_D_HOR_ALRM

    INC_U_HOR_2_ALRM:
	movf U_HOR_ALRM, W	; Movemos el valor de U_HOR_ALRM a W
	sublw 4			; Restamos "4 - W"
	btfss STATUS, 2		; Revisamos que la resta sea 0, si no es 0,
				; se salta el return
	return
	clrf U_HOR_ALRM		; Limpiamos U_HOR
	clrf D_HOR_ALRM		; Limpiamos D_HOR
	return
	
    INC_D_HOR_ALRM:
	incf D_HOR_ALRM, F	; Incrementamos en 1 el valor de D_HOR_ALRM
	return
	
PSECT CODE, ABS, DELTA=2
 ORG 0x100
 
 TABLA:
    clrf PCLATH
    bsf PCLATH, 0
    addwf PCL, F
    retlw 0b00111111	; 0
    retlw 0b00000110	; 1
    retlw 0b01011011	; 2
    retlw 0b01001111	; 3
    retlw 0b01100110	; 4
    retlw 0b01101101	; 5
    retlw 0b01111101	; 6
    retlw 0b00000111	; 7
    retlw 0b01111111	; 8
    retlw 0b01101111	; 9
    
;******************************************************************************* 
; Fin de Código    
;******************************************************************************* 
END   