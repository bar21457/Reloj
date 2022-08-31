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
    movwf STATUS_TEMP     ; Se carga el valor de W a STAT_TEMP
    
ISR_TMR1:
    btfss PIR1, 0	; Revisa el bit 0 de PIR1, si vale 1 se salta el GOTO
    goto POP
    bcf PIR1, 0		; Baja la bandera que indica una interrupción en 
                        ; el TMR1
    movlw 0xEE		; Cargamos 0xEE a W
    movwf TMR1L         ; Cargamos W a TMR1L
    movlw 0x85		; Cargamos 0x85 a W
    movwf TMR1H         ; Cargamos W a TMR1H
    goto INC_U_SEG
    
INC_U_SEG:
    incf U_SEG, F
    movf U_SEG, W
    sublw 10
    btfss STATUS, 2
    goto POP
    clrf U_SEG
    goto INC_D_SEG

INC_D_SEG:
    incf D_SEG, F
    movf D_SEG, W
    sublw 6
    btfss STATUS, 2
    goto POP
    clrf D_SEG
    goto POP
   
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
    
    BANKSEL OSCCON
    
    ; Selección de 1MHz
    
    bsf OSCCON, 6	; IRCF2
    bcf OSCCON, 5	; IRCF1
    bcf OSCCON, 4	; IRCF0
    
    bsf OSCCON, 0	; SCS Reloj Interno
    
    BANKSEL ANSEL
    
    clrf ANSEL          
    clrf ANSELH         ; I/O Digitales
    
    BANKSEL TRISA
    
    clrf TRISA
    clrf TRISC
    clrf TRISD		; Se configuran los puertos A, C y D como outputs
    
    bsf TRISB, 0
    bsf TRISB, 1	
    bsf TRISB, 2        ; Se configuran RB0, RB1 y RB2 como inputs
    
    BANKSEL WPUB
    
    bsf WPUB, 0
    bsf WPUB, 1
    bsf WPUB, 2		; Habilitando los pull-ups en RB0, RB1 y RB2
    
    BANKSEL PORTC
    
    clrf PORTA		; Se limpia PORTA
    clrf PORTC          ; Se limpia PORTC
    clrf PORTD          ; Se limpia PORTD
    
    clrf U_SEG
    clrf D_SEG
    
    BANKSEL OPTION_REG
    
    bcf OPTION_REG, 7	; Habilitando que el PORTB tenga pull-ups
    
    ; Configuración de las interrupciones
    
    BANKSEL INTCON
    
    bsf INTCON, 7       ; Habilitamos las interrupciones globales (GIE)
    bsf INTCON, 6       ; Habilitamos la interrupción del PEIE
    bsf INTCON, 3       ; Habilitamos la interrupción del PORTB (RBIF)
    bcf INTCON, 0       ; Baja la bandera que indica una interrupción en
                        ; el PORTB

    BANKSEL PIE1
    
    bsf PIE1, 0		; Habilitamos la interrupción del TMR1
    
    BANKSEL PIR1
    
    bcf PIR1, 0		; Baja la bandera que indica una interrupción en
			; el TMR1
    
    BANKSEL IOCB
    
    bsf IOCB, 0
    bsf IOCB, 1
    bsf IOCB, 2		; Habilitando RB0, RB1 y RB2 para las ISR de RBIE
    
    ; Configuración TMR1
    
    BANKSEL T1CON
    
    bsf T1CON, 0	; Habilitamos el TMR1
    bcf T1CON, 1	; Selección del Reloj Interno
    
    ; Selección del Prescaler en 1:8
    
    bsf T1CON, 4
    bsf T1CON, 5
    
    ; Cargamos el valor de N = 34286 = 0x85EE (Desborde de 1s)
    
    BANKSEL TMR1L
    
    movlw 0xEE
    movwf TMR1L
    movlw 0x85
    movwf TMR1H

;******************************************************************************* 
; Loop   
;*******************************************************************************     
    
LOOP:
    
DISP0:
    movf U_SEG, W	; Copia el valor de U_SEG a W
    PAGESEL TABLA
    call TABLA
    PAGESEL DISP0
    movwf PORTC		; Se carga W a PORTC
    
DISP1:
    movf D_SEG, W	; Copia el valor de D_SEG a W
    PAGESEL TABLA
    call TABLA
    PAGESEL DISP1
    movwf PORTD		; Se carga W a PORTD
    
    goto LOOP
    
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