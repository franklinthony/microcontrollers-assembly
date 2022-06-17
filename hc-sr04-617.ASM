;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F617                   *
;*                FEITAS POR FRANKLIN ANTHONY                      *
;*                      JUNHO DE 2022                              *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David José de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F617                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f617.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F617

	__CONFIG _FOSC_INTOSCIO & _WDTE_OFF & _PWRTE_OFF & _MCLRE_OFF & _CP_OFF & _IOSCFS_4MHZ & _BOREN_OFF & _WRT_OFF

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES
		COMP		;VARIÁVEL PARA COMPARAÇÃO COM A DURAÇÃO DE 'TMR0'
		AUX		;VARIÁVEL DE PROPÓSITO GERAL

	ENDC			;FIM DO BLOCO DE DEFINIÇÃO DE VARIÁVEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04		;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÃO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES
	
;TABELA QUE RELACIONA O PERÍODO DO PULSO COM A DURAÇÃO ESPERADA DE TMR0
;
;PARA A CONVERSÃO DA DISTÂNCIA PARA O TEMPO, FOI USADA A SEGUINTE EQUAÇÃO:
;	
;	    DISTÂNCIA (EM CM) = TEMPO (EM US)/58 (US/CM)
;
; DURAÇÃO (us) ; GP1 GP2 GP4 GP5 ;  TMR0 (PRESCALER 1:8)
;   T < 290    ;  TODOS PISCAM   ;       T < 36
; 290<= T <580 ; ON  ON  ON  ON  ;    36<= T <73
; 580<= T <870 ; ON  ON  ON  OFF ;    73<= T <109
; 870<= T <1160; ON  ON  OFF OFF ;    109<= T <145
;1160<= T <1450; ON  OFF OFF OFF ;   145<= T <181
;   T >= 1450  ; OFF OFF OFF OFF ;       T >= 181
	
	MOVLW	.2
	MOVWF	TMR0		;PRESCALER 1:8
	BTFSS	GPIO, GP3	;VERIFICA SE A INTERRUPÇÃO FOI POR 'HIGH'
	GOTO	SAI_INT		;SE NÃO FOI, SAI DA INTERRUPÇÃO
NAO_VOLTOU
	BTFSC	GPIO, GP3	;SALTA SE 'GP3' VOLTOU PARA O NÍVEL LÓGICO 'LOW' 
	GOTO	NAO_VOLTOU
	MOVFW	TMR0		;MOVE 'TMR0' PARA 'W' - 1/4 DA DURAÇÃO DO PULSO
	MOVWF	COMP		;'COMP' RECEBE 'W'
MENOR_QUE_290			;VERIFICA SE O PULSO DURA MENOS QUE 290 us
	MOVLW	.36		
	SUBWF	COMP, W		;SUBTRAI 36 DE 'COMP'
	BTFSC	STATUS, C	;SALTA SE 'COMP' FOR MENOR QUE 36
	GOTO	MENOR_QUE_580	;SE FOR MAIOR OU IGUAL, PRÓXIMO INTERVALO
	;SETA PINOS
	BSF	GPIO, GP1
	BSF	GPIO, GP2
	BSF	GPIO, GP4
	BSF	GPIO, GP5
	CALL	DELAY_250_ms
	BCF	GPIO, GP1
	BCF	GPIO, GP2
	BCF	GPIO, GP4
	BCF	GPIO, GP5
	CALL	DELAY_250_ms
	BCF	INTCON, GPIF	;ZERA FLAG DE INTER. POR MUDANÇA DE NÍVEL LÓGICO
	BCF	INTCON, T0IF	;ZERA FLAG DE ESTOURO DE 'TMR0', SE NECESSÁRIO
	CALL	DELAY_44_us	;INTERVALO MÍNIMO PARA UM NOVO PULSO DE ENTRADA
	GOTO	SAI_INT		;+ ROTINA DE SAÍDA -> 50 us
MENOR_QUE_580			;VERIFICA SE O PULSO DURA MENOS QUE 580 us
	MOVLW	.73
	SUBWF	COMP, W		;SUBTRAI 73 DE 'COMP'
	BTFSC	STATUS, C	;SALTA SE 'COMP' FOR MENOR QUE 73
	GOTO	MENOR_QUE_870	;SE FOR MAIOR OU IGUAL, PRÓXIMO INTERVALO
	;SETA PINOS
	BSF	GPIO, GP1
	BSF	GPIO, GP2
	BSF	GPIO, GP4
	BSF	GPIO, GP5
	BCF	INTCON, GPIF	;ZERA FLAG DE INTER. POR MUDANÇA DE NÍVEL LÓGICO
	BCF	INTCON, T0IF	;ZERA FLAG DE ESTOURO DE 'TMR0', SE NECESSÁRIO
	CALL	DELAY_44_us	;INTERVALO MÍNIMO PARA UM NOVO PULSO DE ENTRADA
	GOTO	SAI_INT		;+ ROTINA DE SAÍDA -> 50 us
MENOR_QUE_870			;VERIFICA SE O PULSO DURA MENOS QUE 870 us
	MOVLW	.109		
	SUBWF	COMP, W		;SUBTRAI 109 DE 'COMP'
	BTFSC	STATUS, C	;SALTA SE 'COMP' FOR MENOR QUE 109
	GOTO	MENOR_QUE_1160	;SE FOR MAIOR OU IGUAL, PRÓXIMO INTERVALO
	;SETA PINOS
	BSF	GPIO, GP1
	BSF	GPIO, GP2
	BSF	GPIO, GP4
	BCF	GPIO, GP5
	BCF	INTCON, GPIF	;ZERA FLAG DE INTER. POR MUDANÇA DE NÍVEL LÓGICO
	BCF	INTCON, T0IF	;ZERA FLAG DE ESTOURO DE 'TMR0', SE NECESSÁRIO
	CALL	DELAY_44_us	;INTERVALO MÍNIMO PARA UM NOVO PULSO DE ENTRADA
	GOTO	SAI_INT		;+ ROTINA DE SAÍDA -> 50 us
MENOR_QUE_1160			;VERIFICA SE O PULSO DURA MENOS QUE 1160 us (1,16 ms)
	MOVLW	.145
	SUBWF	COMP, W		;SUBTRAI 145 DE 'COMP'
	BTFSC	STATUS, C	;SALTA SE 'COMP' FOR MENOR QUE 145
	GOTO	MENOR_QUE_1450	;SE FOR MAIOR OU IGUAL, PRÓXIMO INTERVALO
	;SETA PINOS
	BSF	GPIO, GP1
	BSF	GPIO, GP2
	BCF	GPIO, GP4
	BCF	GPIO, GP5
	BCF	INTCON, GPIF	;ZERA FLAG DE INTER. POR MUDANÇA DE NÍVEL LÓGICO
	BCF	INTCON, T0IF	;ZERA FLAG DE ESTOURO DE 'TMR0', SE NECESSÁRIO
	CALL	DELAY_44_us	;INTERVALO MÍNIMO PARA UM NOVO PULSO DE ENTRADA
	GOTO	SAI_INT		;+ ROTINA DE SAÍDA -> 50 us
MENOR_QUE_1450			;VERIFICA SE O PULSO DURA MENOS QUE 1450 us (1,45 ms)
	MOVLW	.181		
	SUBWF	COMP, W		;SUBTRAI 181 DE 'COMP'
	BTFSC	STATUS, C	;SALTA SE 'COMP' FOR MENOR QUE 181
	GOTO	MAIOR_IGUAL_1450;SE FOR MAIOR OU IGUAL, PRÓXIMO INTERVALO
	;SETA PINOS
	BSF	GPIO, GP1
	BCF	GPIO, GP2
	BCF	GPIO, GP4
	BCF	GPIO, GP5
	BCF	INTCON, GPIF	;ZERA FLAG DE INTER. POR MUDANÇA DE NÍVEL LÓGICO
	BCF	INTCON, T0IF	;ZERA FLAG DE ESTOURO DE 'TMR0', SE NECESSÁRIO
	CALL	DELAY_44_us	;INTERVALO MÍNIMO PARA UM NOVO PULSO DE ENTRADA
	GOTO	SAI_INT		;+ ROTINA DE SAÍDA -> 50 us
MAIOR_IGUAL_1450		;VERIFICA SE O PULSO DURA AO MENOS 1450 us (1,45 ms)
	;SETA PINOS
	BCF	GPIO, GP1
	BCF	GPIO, GP2
	BCF	GPIO, GP4
	BCF	GPIO, GP5
	BCF	INTCON, GPIF	;ZERA FLAG DE INTER. POR MUDANÇA DE NÍVEL LÓGICO
	BCF	INTCON, T0IF	;ZERA FLAG DE ESTOURO DE 'TMR0', SE NECESSÁRIO
	CALL	DELAY_44_us	;INTERVALO MÍNIMO PARA UM NOVO PULSO DE ENTRADA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.

DELAY_44_us
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00000000'	;PRESCALER 1:2
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	BANK0			;ALTERA PARA O BANCO 0
	MOVLW	.244		;'TMR0' RECEBE 243
	MOVWF	TMR0
VOLTA_DELAY
	BTFSS	INTCON, T0IF	;'TMR0' ESTOUROU?
	GOTO	VOLTA_DELAY	;SE NÃO, VOLTA PARA VERIFICAÇÃO
	BCF	INTCON, T0IF	;SE SIM, LIMPA FLAG 'T0IF'
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00000010'	;PRESCALER 1:8
	MOVWF	OPTION_REG
	BANK0			;ALTERA PARA O BANCO 0
	RETURN

DELAY_250_ms
	MOVLW	.255
	MOVWF	TMR1L
	MOVLW	.245
	MOVWF	TMR1H
VOLTA_TIMER1	
	BTFSS	PIR1, TMR1IF	;TIMER1 ESTOUROU?
	GOTO	VOLTA_TIMER1	;SE NÃO, VOLTA PARA VERIFICAÇÃO
	CLRF	TMR1L		;SE SIM, ZERA 'TMR1L'
	CLRF	TMR1H		;ZERA 'TMR1H'
	BCF	PIR1, TMR1IF	;LIMPA FLAG 'TMR1IF'
	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00001000'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000010'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'10001000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'00001000'
	MOVWF	IOC		;DEFINE QUAL PORTA GERARÁ A INTERRUPÇÃO POR MUDANÇA DE NÍVEL LÓGICO
	MOVLW	B'00000000'
	MOVWF	PIE1
	BANK0			;ALTERA PARA O BANCO 0
	MOVLW	B'00000000'
	MOVWF	PIR1
	MOVLW	B'00100001'	;CONFIGURANDO TIMER 1
	MOVWF	T1CON

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	CLRF	GPIO
	BCF	INTCON, T0IF
	BCF	INTCON, GPIF
	CLRF	TMR0
ATIVA_PULSO
	NOP			;LANÇAMENTO DE PULSO COM DURAÇÃO X us,
				;ATRAVÉS DO ESTÍMULO
	GOTO	ATIVA_PULSO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
