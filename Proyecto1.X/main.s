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
    
    BSF OSCCON, 6	; IRCF2 Selección de 2MHz
    BCF OSCCON, 5	; IRCF1
    BSF OSCCON, 4	; IRCF0
    
    BSF OSCCON, 0	; SCS Reloj Interno
    
    BANKSEL TRISA
    
    CLRF TRISA
    CLRF TRISC
    CLRF TRISD		; Se configuran los puertos A, C y D como outputs
    
    BSF TRISB, 0
    BSF TRISB, 1	
    BSF TRISB, 2        ; Se configuran RB0, RB1 y RB2 como inputs
    
    BANKSEL IOCB
    
    BSF IOCB, 0
    BSF IOCB, 1
    BSF IOCB, 2		; Habilitando RB0, RB1 y RB2 para las ISR de RBIE
    
    BANKSEL WPUB
    
    BSF WPUB, 0
    BSF WPUB, 1
    BSF WPUB, 2		; Habilitando los pull-ups en RB0, RB1 y RB2
    
    BANKSEL ANSEL
    
    CLRF ANSEL          
    CLRF ANSELH         ; I/O Digitales
    
    BANKSEL PORTC
    CLRF PORTA		; Se limpia PORTA
    CLRF PORTC          ; Se limpia PORTC
    CLRF PORTD          ; Se limpia PORTD
    
    BANKSEL OPTION_REG
    BCF OPTION_REG, 7	; Habilitando que el PORTB tenga pull-ups
    
    ; Configuración TMR0
    
    BCF OPTION_REG, 5	; T0CS: FOSC/4 como reloj (modo temporizador)
    BCF OPTION_REG, 3	; PSA: Se asigna el Prescaler al TMR0
    
    BSF OPTION_REG, 2
    BSF OPTION_REG, 1
    BCF OPTION_REG, 0	; PS2-0: Prescaler 1:128 
    
    MOVLW 178           ; Cargamos 178 a W
    MOVWF TMR0		; Se carga W a TMR0 (se carga al valor de N en  el TMR0)

;******************************************************************************* 
; Loop   
;*******************************************************************************     
    
LOOP:
    
    
;******************************************************************************* 
; Fin de Código    
;******************************************************************************* 
END   