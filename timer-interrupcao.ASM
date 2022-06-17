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
		COMP		;VARIÁVEL PARA COMPARAÇÃO COM A DURAÇÃO DE TMR0

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
; DURAÇÃO   ; GP2 GP1 GP0 ; TIPO ;  TMR0
; 170<T<230 ; OFF OFF ON  ; LOW  ;  85<TMR0<115
; 350<T<450 ; OFF ON  OFF ; HIGH ;  175<TMR0<225
; FORA	    ; ON  OFF OFF ; ERRO ;  FORA
	
	MOVLW	.3
	MOVWF	TMR0		;PRESCALER 1:2
NAO_VOLTOU
	BTFSS	GPIO, GP4	;SALTA SE 'GP4' VOLTOU PARA O NÍVEL LÓGICO 'HIGH' 
	GOTO	NAO_VOLTOU	
	MOVFW	TMR0		;MOVE 'TMR0' PARA 'W' - METADE DA DURAÇÃO DO PULSO
	MOVWF	COMP		;'COMP' RECEBE 'W'
VERIFICA_ESTOURO_TMR0		;SE 'TMR0' ESTOUROU AO MENOS UMA VEZ
	BTFSC	INTCON, T0IF	;SALTA SE 'TMR0' NÃO CHEGOU NA CONTAGEM MÁXIMA
	GOTO	ERRO_		;SE 'T0IF' FOR 1, CLASSIFICA COMO 'ERRO'
MAIOR_QUE_170			;VERIFICA SE O PULSO DURA MAIS DO QUE 170 us
	MOVLW	.86		
	SUBWF	COMP, W		;SUBTRAI 86 DE 'COMP'
	BTFSS	STATUS, C	;SALTA SE 'COMP' FOR MAIOR OU IGUAL A 86
	GOTO	ERRO_		;SE 'COMP' FOR MENOR OU IGUAL A 85, CLASSIFICA COMO 'ERRO'
MENOR_QUE_230			;VERIFICA SE O PULSO DURA MENOS DO QUE 230 us
	MOVLW	.115
	SUBWF	COMP, W		;SUBTRAI 115 DE 'COMP'
	BTFSC	STATUS, C	;SALTA SE 'W' FOR MAIOR QUE 'COMP'
	GOTO	MAIOR_QUE_350	;SE 'COMP' FOR MAIOR OU IGUAL A 115
	GOTO	LOW_		;SE 'COMP' FOR MENOR QUE 115, CLASSIFICA COMO 'LOW'
MAIOR_QUE_350			;VERIFICA SE O PULSO DURA MAIS DO QUE 350 us
	MOVLW	.176		
	SUBWF	COMP, W		;SUBTRAI 176 DE 'COMP'
	BTFSS	STATUS, C	;SALTA SE 'COMP' FOR MAIOR OU IGUAL A 176
	GOTO	ERRO_		;SE 'COMP' FOR MENOR OU IGUAL A 175, CLASSIFICA COMO 'ERRO'
MENOR_QUE_450			;VERIFICA SE O PULSO DURA MENOS DO QUE 450 us
	MOVLW	.225		
	SUBWF	COMP, W		;SUBTRAI 225 DE 'COMP'
	BTFSC	STATUS, C	;SALTA SE 'W' FOR MAIOR QUE 'COMP'
	GOTO	ERRO_		;SE 'COMP' FOR MAIOR OU IGUAL A 225, CLASSIFICA COMO 'ERRO'
	GOTO	HIGH_		;SE 'COMP' FOR MENOR QUE 225, CLASSIFICA COMO 'HIGH'
LOW_				;PULSO SERÁ CLASSIFICADO COMO 'LOW'
	BSF	GPIO, GP0	;'GP0' RECEBE 1
	BCF	GPIO, GP1	;'GP1' RECEBE 0
	BCF	GPIO, GP2	;'GP2' RECEBE 0
	BCF	INTCON, GPIF	;ZERA FLAG DE INTER. POR MUDANÇA DE NÍVEL LÓGICO
	BCF	INTCON, T0IF	;ZERA FLAG DE ESTOURO DE 'TMR0', SE NECESSÁRIO
	GOTO	SAI_INT
HIGH_				;PULSO SERÁ CLASSIFICADO COMO 'HIGH'
	BCF	GPIO, GP0	;'GP0' RECEBE 0
	BSF	GPIO, GP1	;'GP1' RECEBE 1
	BCF	GPIO, GP2	;'GP2' RECEBE 0
	BCF	INTCON, GPIF	;ZERA FLAG DE INTER. POR MUDANÇA DE NÍVEL LÓGICO
	BCF	INTCON, T0IF	;ZERA FLAG DE ESTOURO DE 'TMR0', SE NECESSÁRIO
	GOTO	SAI_INT
ERRO_				;PULSO SERÁ CLASSIFICADO COMO 'ERRO'
	BCF	GPIO, GP0	;'GP0' RECEBE 0
	BCF	GPIO, GP1	;'GP1' RECEBE 0
	BSF	GPIO, GP2	;'GP2' RECEBE 1
	BCF	INTCON, GPIF	;ZERA FLAG DE INTER. POR MUDANÇA DE NÍVEL LÓGICO
	BCF	INTCON, T0IF	;ZERA FLAG DE ESTOURO DE 'TMR0', SE NECESSÁRIO

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
	;ESTÍMULO (GP4 <- 1)
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00010000'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'10000000'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'10001000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'00010000'
	MOVWF	IOC		;DEFINE QUAL PORTA GERARÁ A INTERRUPÇÃO POR MUDANÇA DE NÍVEL LÓGICO
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

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
ATIVA_PULSO
	NOP			;LANÇAMENTO DE PULSO COM DURAÇÃO X us,
				;ATRAVÉS DO ESTÍMULO
	GOTO	ATIVA_PULSO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
