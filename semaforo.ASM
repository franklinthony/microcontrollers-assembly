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

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES
		INCR		;VARIÁVEL PARA INCREMENTO DOS LOOPS DE DELAY
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

;DELAY DE 2 SEGUNDOS PARA OS SINAIS VERDE E VERMELHO, QUE SERÁ COMPLEMENTADO
;COM 0,5 SEGUNDO DO SINAL AMARELO, TOTALIZANDO 2,5 SEGUNDOS
DELAY_2
	MOVLW	.39		;CONTAGEM DE 217 MICROSSEGUNDOS
	MOVWF	TMR0		;MOVE 39 PARA O 'TMR0'
	BCF	INTCON, T0IF	;ZERA O 'T0IF', INDICANDO O 'RESET' DO 'TMR0'
	CLRF	INCR		;ZERA O 'INCR', VARIÁVEL RESPONSÁVEL PELA QUANTIDADE DE LOOPS
	GOTO	NOT_FULL_2	;VAI PARA 'NOT_FULL_2', INDICANDO QUE 'TMR0' NÃO ESTÁ CHEIO
FULL_2				;LABEL QUE REPRESENTA O ESTOURO DE 'TMRO'
	MOVLW	.39		;REINÍCIO DA CONTAGEM
	MOVWF	TMR0		;MOVE 39 PARA O 'TMR0'
	BCF	INTCON, T0IF	;ZERA O 'T0IF', INDICANDO O 'RESET' DO 'TMR0'
NOT_FULL_2			;LABEL PARA QUANDO 'TMR0' AINDA NÃO ESTÁ CHEIO
	BTFSS	INTCON, T0IF	;TESTE: SE 'T0IF' ESTIVER CHEIO (1), PULA PARA A INSTRUÇÃO 117
	GOTO	NOT_FULL_2	;SE 'T0IF' NÃO ESTIVER CHEIO (0), VOLTA PARA A LABEL 'NOT_FULL_2'
	INCF	INCR		;SE 'T0IF' ESTIVER CHEIO (1), 'INCR' RECEBE MAIS 1
	MOVLW	.36		;MOVE 36 PARA O REGISTRADOR 'WREG', INDICANDO O MÁXIMO DE LOOPS ESPERADO
	SUBWF	INCR, W		;SUBTRAI 36 DE 'INCR'
	BTFSC	STATUS, C	;SALTA SE O 'INCR' NÃO FOR IGUAL A 36
	RETURN			;SE 'INCR' FOR IGUAL 36, RETORNA PARA A 'MAIN'
	GOTO	FULL_2		;SE 'INCR' FOR MENOR QUE 36, VOLTA PARA 'FULL_2'
	
;DELEY DE 0,5 SEGUNDO PARA O SINAL AMARELO	
DELAY_0_5
	MOVLW	.39		;CONTAGEM DE 217 MICROSSEGUNDOS
	MOVWF	TMR0		;MOVE 39 PARA O 'TMR0'
	BCF	INTCON, T0IF	;ZERA O 'T0IF', INDICANDO O 'RESET' DO 'TMR0'
	CLRF	INCR		;ZERA O 'INCR', VARIÁVEL RESPONSÁVEL PELA QUANTIDADE DE LOOPS
	GOTO	NOT_FULL_0_5	;VAI PARA 'NOT_FULL_0_5', INDICANDO QUE 'TMR0' NÃO ESTÁ CHEIO
FULL_0_5			;LABEL QUE REPRESENTA O ESTOURO DE 'TMRO'
	MOVLW	.39		;REINÍCIO DA CONTAGEM
	MOVWF	TMR0		;MOVE 39 PARA O 'TMR0'
	BCF	INTCON, T0IF	;ZERA O 'T0IF', INDICANDO O 'RESET' DO 'TMR0'
NOT_FULL_0_5			;LABEL PARA QUANDO 'TMR0' AINDA NÃO ESTÁ CHEIO
	BTFSS	INTCON, T0IF	;TESTE: SE 'T0IF' ESTIVER CHEIO (1), PULA PARA A INSTRUÇÃO 138
	GOTO	NOT_FULL_0_5	;SE 'T0IF' NÃO ESTIVER CHEIO (0), VOLTA PARA A LABEL 'NOT_FULL_0_5'
	INCF	INCR		;SE 'T0IF' ESTIVER CHEIO (1), 'INCR' RECEBE MAIS 1
	MOVLW	.9		;MOVE 9 PARA O REGISTRADOR 'WREG', INDICANDO O MÁXIMO DE LOOPS ESPERADO
	SUBWF	INCR, W		;SUBTRAI 9 DE 'INCR'
	BTFSC	STATUS, C	;SALTA SE O 'INCR' NÃO FOR IGUAL A 9
	RETURN			;SE 'INCR' FOR IGUAL 9, RETORNA PARA A 'MAIN'
	GOTO	FULL_0_5	;SE 'INCR' FOR MENOR QUE 9, VOLTA PARA 'FULL_0_5'

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00000000'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000111'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000111'	;'TMR0' 1:256
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
	;SEMÁFORO 1: GP0 - VERDE E VERMELHO
	;	     GP1 - AMARELO
	;
	;SEMÁFORO 2: GP2 - VERDE E VERMELHO
	;	     GP4 - AMARELO
	;
	;PARA OS CASOS ENVOLVENDO VERDE E VERMELHO, FOI ADOTADO:
	;	     '0' - VERMELHO ACESO
	;	     '1' - VERDE ACESO
MAIN
	BSF	GPIO, GP0	;SEM. 1 - VERDE ACENDE
	BCF	GPIO, GP2	;SEM. 2 - VERMELHO ACENDE
	CALL	DELAY_2		;DELAY DE 2 SEGUNDOS
	BSF	GPIO, GP1	;SEM. 1 - AMARELO ACENDE
	CALL	DELAY_0_5	;DELAY DE 0,5 SEGUNDO	
	BCF	GPIO, GP1	;SEM. 1 - AMARELO APAGA
	BCF	GPIO, GP0	;SEM. 1 - VERMELHO ACENDE
	BSF	GPIO, GP2	;SEM. 2 - VERDE ACENDE		
	CALL	DELAY_2		;DELAY DE 2 SEGUNDOS
	BSF	GPIO, GP4	;SEM. 2 - AMARELO ACENDE
	CALL	DELAY_0_5	;DELAY DE 0,5 SEGUNDO
	BCF	GPIO, GP4	;SEM. 2 - AMARELO APAGA
	
	GOTO	MAIN
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
