;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      MARÇO DE 2021                              *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David José de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

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
		AUX		;VARIÁVEL DE AUXÍLIO

		;COLOQUE AQUI SUAS NOVAS VARIÁVEIS
		;NÃO ESQUEÇA COMENTÁRIOS ESCLARECEDORES

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

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÃO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES
	
	;QUAL TIPO DE INTERRUPÇÃO FOI ATIVADA?
	BTFSS	PIR1, ADIF	;FIM DA CONVERSÃO A/D
	GOTO	FIM_TMR		;ESTOURO DE 'TMR1'
	MOVFW	ADRESH	    
	MOVWF	AUX		;'AUX' RECEBE O VALOR CONVERTIDO
INT_0				
	MOVLW	.26		
	SUBWF	AUX, W	
	BTFSC	STATUS, C	;SALTA SE 'AUX' FOR MENOR QUE 26
	GOTO	INT_1		;SE NÃO, VERIFICA SE É 1
	MOVLW	.0		;SE SIM, CLASSIFICA COMO 0
	MOVWF	AUX
	GOTO	AJUSTE_BCD_GPIO
INT_1				
	MOVLW	.52
	SUBWF	AUX, W		
	BTFSC	STATUS, C	;SALTA SE 'AUX' FOR MENOR QUE 52
	GOTO	INT_2		;SE NÃO, VERIFICA SE É 2
	MOVLW	.1		;SE SIM, CLASSIFICA COMO 1	
	MOVWF	AUX
	GOTO	AJUSTE_BCD_GPIO
INT_2			
	MOVLW	.77
	SUBWF	AUX, W		
	BTFSC	STATUS, C	;SALTA SE 'AUX' FOR MENOR QUE 77
	GOTO	INT_3		;SE NÃO, VERIFICA SE É 3
	MOVLW	.2		;SE SIM, CLASSIFICA COMO 2	
	MOVWF	AUX
	GOTO	AJUSTE_BCD_GPIO
INT_3			
	MOVLW	.103
	SUBWF	AUX, W		
	BTFSC	STATUS, C	;SALTA SE 'AUX' FOR MENOR QUE 103
	GOTO	INT_4		;SE NÃO, VERIFICA SE É 4
	MOVLW	.3		;SE SIM, CLASSIFICA COMO 3
	MOVWF	AUX
	GOTO	AJUSTE_BCD_GPIO
INT_4
	MOVLW	.129
	SUBWF	AUX, W		
	BTFSC	STATUS, C	;SALTA SE 'AUX' FOR MENOR QUE 129
	GOTO	INT_5		;SE NÃO, VERIFICA SE É 5
	MOVLW	.4		;SE SIM, CLASSIFICA COMO 4	
	MOVWF	AUX
	GOTO	AJUSTE_BCD_GPIO
INT_5
	MOVLW	.154
	SUBWF	AUX, W		
	BTFSC	STATUS, C	;SALTA SE 'AUX' FOR MENOR QUE 154
	GOTO	INT_6		;SE NÃO, VERIFICA SE É 6
	MOVLW	.5		;SE SIM, CLASSIFICA COMO 5
	MOVWF	AUX
	GOTO	AJUSTE_BCD_GPIO
INT_6
	MOVLW	.180
	SUBWF	AUX, W		
	BTFSC	STATUS, C	;SALTA SE 'AUX' FOR MENOR QUE 180
	GOTO	INT_7		;SE NÃO, VERIFICA SE É 7
	MOVLW	.6		;SE SIM, CLASSIFICA COMO 6
	MOVWF	AUX
	GOTO	AJUSTE_BCD_GPIO
INT_7
	MOVLW	.205
	SUBWF	AUX, W		
	BTFSC	STATUS, C	;SALTA SE 'AUX' FOR MENOR QUE 205
	GOTO	INT_8		;SE NÃO, VERIFICA SE É 8
	MOVLW	.7		;SE SIM, CLASSIFICA COMO 7
	MOVWF	AUX
	GOTO	AJUSTE_BCD_GPIO
INT_8
	MOVLW	.231
	SUBWF	AUX, W		
	BTFSC	STATUS, C	;SALTA SE 'AUX' FOR MENOR QUE 231
	GOTO	INT_9		;SE NÃO, SÓ PODE SER 9
	MOVLW	.8		;SE SIM, CLASSIFICA COMO 8
	MOVWF	AUX
	GOTO	AJUSTE_BCD_GPIO
INT_9
	MOVLW	.9		;CLASSIFICA COMO 9	
	MOVWF	AUX
AJUSTE_BCD_GPIO			;NO CASO DE 0 A 9, O BINÁRIO E O BCD TÊM A MESMA REPRESENTAÇÃO
	BTFSC	AUX, 0		;VERIFICA SE O BIT 0 DE 'AUX' É 0
	GOTO	HIGH_0		;SE NÃO, COLOCA O BIT 0 DE 'GPIO' EM 1
	BCF	GPIO, 0		;SE SIM, COLOCA O BIT 0 DE 'GPIO' EM 0
	GOTO	BIT_1
HIGH_0
	BSF	GPIO, 0
BIT_1
	BTFSC	AUX, 1		;VERIFICA SE O BIT 1 DE 'AUX' É 0
	GOTO	HIGH_1		;SE NÃO, COLOCA O BIT 1 DE 'GPIO' EM 1
	BCF	GPIO, 1		;SE SIM, COLOCA  BIT 1 DE 'GPIO' EM 0
	GOTO	BIT_2
HIGH_1
	BSF	GPIO, 1
BIT_2	
	BTFSC	AUX, 2		;VERIFICA SE O BIT 2 DE 'AUX' É 0
	GOTO	HIGH_4		;SE NÃO, COLOCA O BIT 4 DE 'GPIO' EM 1
	BCF	GPIO, 4		;SE SIM, COLOCA  BIT 4 DE 'GPIO' EM 0
	GOTO	BIT_3
HIGH_4
	BSF	GPIO, 4
BIT_3	
	BTFSC	AUX, 3		;VERIFICA SE O BIT 3 DE 'AUX' É 0
	GOTO	HIGH_5		;SE NÃO, COLOCA O BIT 5 DE 'GPIO' EM 1
	BCF	GPIO, 5		;SE SIM, COLOCA  BIT 5 DE 'GPIO' EM 0
	BCF	PIR1, ADIF	;LIMPA A FLAG DE TÉRMINO DA CONVERSÃO A/D
	GOTO	SAI_INT
HIGH_5
	BSF	GPIO, 5
	BCF	PIR1, ADIF	;LIMPA A FLAG DE TÉRMINO DA CONVERSÃO A/D
	GOTO	SAI_INT
FIM_TMR
	MOVFW	TMR1H		;MOVE A CONTAGEM DE 'TMR1H' PARA 'W'
	MOVWF	AUX		;MOVE O CONTEÚDO DE 'W' PARA 'AUX'
	MOVLW	.135		;MOVE 135 PARA 'W'
	SUBWF	AUX, W		;FAZ 'AUX' - 'W' E O RESULTADO VAI PARA 'W'
	BTFSS	STATUS, C	;VERIFICA SE 'TMR1H' CHEGOU NA CONTAGEM DE '135' 
	GOTO	FIM_TMR		;SE NÃO, VOLTA PARA 'FIM_TMR'
	BCF	PIR1, TMR1IF	;SE SIM, LIMPA A FLAG DE ESTOURO DE 'TMR1'
	CLRF	TMR1L		;ZERA A PARTE 'LOW' DO 'TIMER1'
	CLRF	TMR1H		;ZERA A PARTE 'HIGH' DO 'TIMER1'
	;NOVA TENSÃO DE ENTRADA POR ESTÍMULO
	NOP
	NOP
	BSF	ADCON0, 1	;INICIA UMA NOVA CONVERSÃO

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


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000100' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	MOVLW	B'00010100'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'11000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'01000001'
	MOVWF	PIE1		;DEFINE AS INTERRUPÇÕES POR PERIFÉRICO
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00001001'
	MOVWF	ADCON0
	MOVLW	B'00000101'	;PRESCALE 1:1, ATRAVÉS DO CLOCK INTERNO
	MOVWF	T1CON	
	CLRF	PIR1		;FLAGS DAS POSSÍVEIS INTERRUPÇÕES POR PERIFÉRICO
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	;TENSÃO DE ENTRADA POR ESTÍMULO
	CLRF	TMR1L		;ZERA A PARTE 'LOW' DO 'TIMER1'
	CLRF	TMR1H		;ZERA A PARTE 'HIGH' DO 'TIMER1'
	BSF	ADCON0, 1	;HABILITA A CONVERSÃO A/D
AGUARDA_INT
	;APÓS O TÉRMINO DO PRIMEIRO CICLO DE CONVERSÃO, UMA NOVA
	;TENSÃO DE ENTRADA E A HABILITAÇÃO DE UMA NOVA CONVERSÃO
	;SÃO FEITAS ATRAVÉS DE ESTÍMULOS AO FINAL DA INTERRUPÇÃO POR 'TIMER1'
	GOTO	AGUARDA_INT
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
