;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                    MARÇO DE 2021                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       NOME DO PROJETO                           *
;*                           CLIENTE                               *
;*         DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA      *
;*   VERSÃO: 1.0                           DATA: 17/06/03          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRIÇÃO DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_ON & _MCLRE_ON & _INTRC_OSC_CLKOUT

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
		DADO		;ARMAZENA O DADO PARA A EEPROM
		INCR_CONV	;VARIÁVEL DE CONTROLE DE REPETIÇÃO - CONVERSÃO A/D
		INCR_TMR0	;VARIÁVEL DE CONTROLE DE REPETIÇÃO - 'TMR0'    
		INCR_MEDIA      ;VARIÁVEL DE CONTROLE DE REPETIÇÃO - MÉDIA
		SOMAL		;SOMA - 8 BITS MENOS SIGNIFICATIVOS
		SOMAH		;SOMA - 8 BITS MAIS SIGNIFICATIVOS

		;NOVAS VARIÁVEIS

	ENDC			;FIM DO BLOCO DE MEMÓRIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
; INICIALIZAÇÃO DA EEPROM, DE ACORDO COM A DESCRIÇÃO NO ARQUIVO "Def_Rega_Formigas.inc"

;A PARTIR DO ENDEREÇO ZERO DA EEPROM, DADOS EM ORDEM ALEATÓRIA
	ORG 0x2100
	DE	0X89,0X1E,0X39,0X9F,0XC2,0X0C,0XAB,0X33,0X63,0XD3,0X95,0X7B,0X38,0XD6,0X1E,0X48
	DE	0XDB,0XD8,0X86,0XFD,0XA5,0XFC,0X0C,0XBE,0X68,0X9B,0XD9,0X10,0XD8,0XEC,0X90,0X91
	DE	0XAA,0XBB,0XCC,0XDD,0XEE,0XF1,0XC9,0X77

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
LE_EEPROM
;LER DADO DA EEPROM, CUJO ENDEREÇO É INDICADO EM W
;O DADO LIDO RETORNA EM W
	ANDLW	.127		;LIMITA ENDEREÇO MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR		;INDICA O END. DE LEITURA
	BSF		EECON1,RD	;INICIA O PROCESSO DE LEITURA
	MOVF	EEDATA,W	;COLOCA DADO LIDO EM W
	BANK0				;POSICIONA PARA BANK 0
	RETURN

GRAVA_EEPROM
;ESCREVE UM DADO NA EEPROM, CUJO ENDEREÇO É INDICADO EM W
;O DADO A SER ESCRITO DEVE ESTAR ARMAZENADO NA VARIÁVEL DADO
	ANDLW	.127		;LIMITA ENDEREÇO MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR
	MOVF	DADO,W
	MOVWF	EEDATA
	BSF		EECON1,WREN ;HABILITA ESCRITA
	BCF		INTCON,GIE	;DESLIGA INTERRUPÇÕES
	MOVLW	B'01010101'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	MOVLW	B'10101010'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	BSF		EECON1,WR ;INICIA A ESCRITA
AGUARDA
	BTFSC	EECON1,WR ;TERMINOU?
	GOTO	AGUARDA
	BSF		INTCON,GIE ;HABILITA INTERRUPÇÕES
	BANK0				;POSICIONA PARA BANK 0
	RETURN
	
DELAY_10_MS			;DELAY DE 10 MS
	MOVLW	.5		;NÚMERO DE LOOPS
	MOVWF	INCR_TMR0	;QUANTIDADE DE CONTAGENS DO 'TMR0'
INICIO_CONT
	MOVLW	.7		;VALOR INICIAL DE 'TMR0'
	MOVWF	TMR0
VOLTA_DELAY
	BTFSS	INTCON, T0IF	;'TMR0' ESTOUROU?
	GOTO	VOLTA_DELAY	;SE NÃO, VOLTA PARA A VERIFICAÇÃO
	BCF	INTCON, T0IF	;SE SIM, ZERA A FLAG DE ESTOURO DE 'TMR0'
	DECFSZ	INCR_TMR0	;FORAM REALIZADAS 5 CONTAGENS?
	GOTO	INICIO_CONT	;SE NÃO, VOLTA PARA UMA NOVA CONTAGEM
	RETURN			;SE SIM, RETORNA

SOMA				;SOMA OS VALORES DAS CONVERSÕES A/D
	MOVFW	ADRESH
	ADDWF	SOMAL		;ADICIONA O CONTEÚDO DE 'W' EM 'SOMAL'
	BTFSS	STATUS, C	;VERIFICA SE HOUVE CARRY
	RETURN			;SE NÃO, RETORNA
	INCF	SOMAH		;SE SIM, INCREMENTA 'SOMAH'
	RETURN

MEDIA				;CALCULA A MÉDIA DOS VALORES DA 'EEPROM'
	MOVLW	.3		;NÚMERO DE SHIFTS À DIREITA
	MOVWF	INCR_MEDIA
VOLTA_MEDIA
	RRF	SOMAH		;SHIFT À DIREITA DE 'SOMAH'
	BTFSS	STATUS, C	;TEM CARRY?
	GOTO	CONTINUA	;SE NÃO, CONTINUA PARA 'SOMAL'
	RRF	SOMAL		;SE SIM, SHIFT Á DIREITA DE 'SOMAL'
	BSF	SOMAL, 7	;BIT 7 DE 'SOMAL' RECEBE 1
	DECFSZ	INCR_MEDIA	;FORAM REALIZADOS 3 SHIFTS?
	GOTO	VOLTA_MEDIA	;SE NÃO, VOLTA PARA UM NOVO SHIFT À DIREITA
	GOTO	RETORNO_MEDIA	;SE SIM, RETORNA 
CONTINUA
	RRF	SOMAL		;SE NÃO HOUVER CARRY, SHIFT À DIREITA DE 'SOMAL'
	DECFSZ	INCR_MEDIA	;FORAM REALIZADOS 3 SHIFTS?
	GOTO	VOLTA_MEDIA	;SE NÃO, VOLTA PARA UM NOVO SHIFT À DIREITA DE 'SOMAH'
RETORNO_MEDIA
	RETURN			;SE SIM, RETORNA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1			;ALTERA PARA O BANCO 1
	MOVLW	B'00000010'	;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO	
	MOVLW	B'00000010'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00001110'	;'WDT' COM PRESCALER 1:64
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'	;DESABILITA INTERRUPÇÕES
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	MOVLW	B'00000000'
	MOVWF	VRCON		;'VRCON' DESABILITADO
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000111'	;DESLIGA COMPARADOR
	MOVWF	CMCON		
	MOVLW	B'00000000'	;DESLIGA CONVERSOR A/D
	MOVWF   ADCON0

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	BCF	GPIO, GP5	;'GP5' RECEBE 'LOW', PIC INATIVO
	BCF	INTCON, T0IF	;ZERA FLAG DE ESTOURO DE 'TMR0'
	;O MICROCONTROLADOR SAIRÁ DO MODO 'SLEEP' A PARTIR DO MOMENTO
	;EM QUE O 'WDT' ESTOURAR SUA CONTAGEM
	SLEEP			;PIC DORME
	NOP			;AGUARDA 'WDT' ESTOURAR
	BSF	GPIO, GP5	;'GP5' RECEBE 'HIGH'; PIC ATIVO
	MOVLW	.8		;NÚMERO DE CONVERSÕES A/D
	MOVWF	INCR_CONV
	CLRWDT			;LIMPA 'WDT'
	CLRF	SOMAL		;ZERA 'SOMAL'
	CLRF	SOMAH		;ZERA 'SOMAH'
	BANK1			;RETORNA PARA O BANCO
	MOVLW	B'00000010'	;'TMR0' COM PRESCALER 1:8
	MOVWF	OPTION_REG	
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000101'	;LIGA CONVERSOR A/D - CANAL ANALÓGICO 'AN1'
	MOVWF   ADCON0
ATIVA_CONV
	NOP			;ESTÍMULO DE TENSÃO A SER CONVERTIDA
	NOP
	BSF	ADCON0, 1	;INÍCIO DA CONVERSÃO A/D
	CLRWDT			;LIMPA 'WDT'
VOLTA_AD
	BTFSC	ADCON0, 1	;A CONVERSÃO TERMINOU?
	GOTO	VOLTA_AD	;SE NÃO, VOLTA PARA CONFERIR
	CALL	SOMA		;SE SIM, REALIZA A SOMA
	CALL	DELAY_10_MS	;DELAY DE 10 MS
	DECFSZ	INCR_CONV	;FORAM REALIZADAS 8 CONVERSÕES?
	GOTO	ATIVA_CONV	;SE NÃO, INICIA UMA NOVA CONVERSÃO
	CALL	MEDIA		;SE SIM, CALCULA A MÉDIA DOS VALORES CONVERTIDOS
	MOVFW	SOMAL		;MOVE O VALOR DA MÉDIA DE 'SOMAL' PARA 'W'
	MOVWF	DADO		;'DADO' RECEBE 'W'
	MOVLW	0XF2		;'W' RECEBE O ENDEREÇO '0XF2'
	;VALE RESSALTAR QUE 'EEPROM' POSSUI APENAS 128 ESPAÇOS DE MEMÓRIA. NESTE
	;CONTEXTO, O ENDEREÇO ENCAMINHADO É 242 (DECIMAL). ASSIM, AO GRAVAR A
	;MÉDIA NA 'EEPROM', A INSTRUÇÃO 'ANDLW	.127' REALIZARÁ:
	;
	;		    11110010 (242)
	;		    01111111 (127)
	;		    --------------	    
	;		    01110010 (114) -> A MÉDIA IRÁ PARA O END. '72h'
	;						    
	CALL	GRAVA_EEPROM	;GRAVA O VALOR DA MÉDIA NO ENDEREÇO INDICADO
	BANK1			;RETORNA PARA O BANCO
	MOVLW	B'00001110'	;'WDT' COM PRESCALER 1:64
	MOVWF	OPTION_REG	
	BANK0			;RETORNA PARA O BANCO
	MOVLW	B'00000000'	;DESLIGA CONVERSOR A/D
	MOVWF   ADCON0
	GOTO	MAIN		

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
