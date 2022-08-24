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
STAT_TEMP:
    DS 1
CONT_10MS:
    DS 1
DISP:
    DS 1
SEGS:
    DS 1
NL_SEGS:
    DS 1
NH_SEGS:
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
    movwf STAT_TEMP     ; Se carga el valor de W a STAT_TEMP
    
ISR:
    btfss INTCON, 2	; Revisa el bit 2 de INTCON, si vale 1 se salta el GOTO
    goto POP
    bcf INTCON, 2	; Baja la bandera que indica una interrupción en 
                        ; el TMR0
    movlw 100           ; Cargamos 100 a W
    movwf TMR0		; Se carga W a TMR0 (se carga al valor de N en  el TMR0)
    incf CONT_10MS, F   ; Se incrementa el valor de CONT_10MS
   
POP:
    swapf STAT_TEMP, W  ; Se intercambian el nibble más significativo y el
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
 ORG 0x0100

MAIN:
    
    BANKSEL OSCCON
    
    bcf OSCCON, 6	; IRCF2 Selección de 250KHz
    bsf OSCCON, 5	; IRCF1
    bcf OSCCON, 4	; IRCF0
    
    bsf OSCCON, 0	; SCS Reloj Interno
    
    BANKSEL TRISA
    
    clrf TRISA
    clrf TRISC
    clrf TRISD		; Se configuran los puertos A, C y D como outputs
    
    bsf TRISB, 0
    bsf TRISB, 1	
    bsf TRISB, 2        ; Se configuran RB0, RB1 y RB2 como inputs
    
    BANKSEL IOCB
    
    bsf IOCB, 0
    bsf IOCB, 1
    bsf IOCB, 2		; Habilitando RB0, RB1 y RB2 para las ISR de RBIE
    
    BANKSEL WPUB
    
    bsf WPUB, 0
    bsf WPUB, 1
    bsf WPUB, 2		; Habilitando los pull-ups en RB0, RB1 y RB2
    
    BANKSEL ANSEL
    clrf ANSEL          
    clrf ANSELH         ; I/O Digitales
    
    BANKSEL PORTC
    clrf PORTA		; Se limpia PORTA
    clrf PORTC          ; Se limpia PORTC
    clrf PORTD          ; Se limpia PORTD
    
    clrf CONT_10MS
    
    BANKSEL OPTION_REG
    bcf OPTION_REG, 7	; Habilitando que el PORTB tenga pull-ups
    
    ; Configuración TMR0
    
    bcf OPTION_REG, 5	; T0CS: FOSC/4 como reloj (modo temporizador)
    bcf OPTION_REG, 3	; PSA: Se asigna el Prescaler al TMR0
    
    bcf OPTION_REG, 2
    bcf OPTION_REG, 1
    bsf OPTION_REG, 0	; PS2-0: Prescaler 1:4 
    
    movlw 100           ; Cargamos 100 a W
    movwf TMR0		; Se carga W a TMR0 (se carga al valor de N en  el TMR0)
    
    ; Configuración de interrupciones
    
    bsf INTCON, 7       ; Habilitamos las interrupciones globales (GIE)
    bsf INTCON, 5       ; Habilitamos la interrupción del TMR0 (T0IE)
    bsf INTCON, 3       ; Habilitamos la interrupción del PORTB (RBIF)
    bcf INTCON, 0       ; Baja la bandera que indica una interrupción en
                        ; el PORTB

;******************************************************************************* 
; Loop   
;*******************************************************************************     
    
LOOP:
    incf SEGS, F	; Se incrementa el valor de SEGS
    movf SEGS, W	; Copia el valor de SEGS a W
    movwf NL_SEGS	; Se carga W a NL_SEGS
    movwf NH_SEGS	; Se carga W a NL_SEGS
    movlw 0x09		; Cargamos 9 a W		
    andwf NL_SEGS, F	; AND entre NL y W
    movlw 0x05          ; Cargamos 5 a W
    andwf NH_SEGS, F	; AND entre NH y W
    swapf NH_SEGS, F	; Se intercambian el nibble más significativo y el
                        ; nibble menos significativo de NH y se carga en F
    btfss DISP0, 0      ; Revisa el bit 0 de DIS0; si vale 1, se salta el 
                        ; goto
    goto DISP0
    goto DISP1
    
DISP0:
    movf NL_SEGS, W	; Copia el valor de NL_SEGS a W
    PAGESEL TABLA
    call TABLA
    PAGESEL DISP0
    movwf PORTD		; Se carga W a PORTD
    bsf DISP, 0		; Seteamos a 1 el bit 0 de DISP
    goto VERIFICACION
    
DISP1:
    movf NH_SEGS, W	; Copia el valor de NH_SEGS a W
    PAGESEL TABLA
    call TABLA
    PAGESEL DISP1
    movwf PORTD		; Se carga W a PORTD
    bcf DISP, 0		; Seteamos a 0 el bit 0 de DISP
    goto VERIFICACION
    
VERIFICACION:    
    movf CONT_10MS, W	; Copia el valor de CONT_10MS a W
    sublw 10
    btfss STATUS, 2	; Revisa el bit 2 de STATUS, si vale 1 se salta el goto
			; (si la resta fue igual a 0, se salta el GOTO)
    goto VERIFICACION
    clrf CONT_10MS	; Limpiamos CONT_10MS
    goto LOOP		
    
PSECT CODE, ABS, DELTA=2
 ORG 0x1800
 
 TABLA:
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