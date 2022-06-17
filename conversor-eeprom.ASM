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
		DADO		;ARMAZENA O DADO PARA A EEPROM
		INCR		;VARIÁVEL DE CONTROLE DE REPETIÇÕES
		ENDER		;VARIÁVEL DE CONTROLE DE ENDEREÇAMENTO
		SOMAL		;SOMA - 8 BITS MENOS SIGNIFICATIVOS
		SOMAH		;SOMA - 8 BITS MAIS SIGNIFICATIVOS
		
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

;A PARTIR DO ENDEREÇO UM DA EEPROM, DADOS EM ORDEM ALEATÓRIA
	ORG 0x2101
	DE	0X89,0X1E,0X39,0X9F,0XC2,0X0C,0XAB,0X33,0X63,0XD3,0X95,0X7B,0X38,0XD6,0X1E,0X48
	DE	0XDB,0XD8,0X86,0XFD,0XA5,0XFC,0X0C,0XBE,0X68,0X9B,0XD9,0X10,0XD8,0XEC,0X90,0X99

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
; RETORNAR DA INTERRUPÇÃOpOIS BEM

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
	BANK1			;ACESSO VIA BANK 1
	MOVWF	EEADR
	MOVF	DADO,W
	MOVWF	EEDATA
	BSF	EECON1, WREN	;HABILITA ESCRITA
	BCF	INTCON, GIE	;DESLIGA INTERRUPÇÕES
	MOVLW	B'01010101'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	MOVLW	B'10101010'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	BSF	EECON1, WR	;INICIA A ESCRITA
AGUARDA
	BTFSC	EECON1, WR	;TERMINOU?
	GOTO	AGUARDA
	BSF	INTCON, GIE	;HABILITA INTERRUPÇÕES
	INCF	FSR		;APONTA PARA O PRÓXIMO ENDEREÇO DA RAM
	INCF	ENDER		;
	BANK0			;POSICIONA PARA BANK 0
	RETURN
	
GRAVA_RAM			;GRAVA OS VALORES CONVERTIDOS NA RAM
	MOVFW	ADRESH		;MOVE O RESULTADO DA CONVERSÃO A/D PARA 'W'
	MOVWF	INDF		;ATUALIZA O CONTEÚDO APONTADO POR 'FSR'
	INCF	FSR		;INCREMENTA/ATUALIZA O ENDEREÇO APONTADO POR 'FSR'
	RETURN

SOMA				;SOMA OS VALORES EM 'EEPROM'
	ADDWF	SOMAL		;ADICIONA O CONTEÚDO DE 'W' EM 'SOMAL'
	BTFSS	STATUS, C	;VERIFICA SE HOUVE CARRY
	GOTO	RETORNA		;SE NÃO, INCREMENTA O ENDEREÇO APONTADO POR 'FSR' E RETORNA
	INCF	SOMAH		;SE SIM, INCREMENTA 'SOMAH'
	INCF	ENDER		;E INCREMENTA O ENDEREÇO APONTADO POR 'FSR'
	RETURN	
RETORNA
	INCF	ENDER
	RETURN

MEDIA				;CALCULA A MÉDIA DOS VALORES DA 'EEPROM'
	MOVLW	.5		;NÚMERO DE SHIFTS À DIREITA
	MOVWF	INCR
VOLTA_MEDIA
	RRF	SOMAH		;SHIFT À DIREITA DE 'SOMAH'
	BTFSS	STATUS, C	;TEM CARRY?
	GOTO	CONTINUA	;SE NÃO, CONTINUA PARA 'SOMAL'
	RRF	SOMAL		;SE SIM, SHIFT Á DIREITA DE 'SOMAL'
	BSF	SOMAL, 7	;BIT 7 DE 'SOMAL' RECEBE 1
	DECFSZ	INCR		;FORAM REALIZADOS 5 SHIFTS?
	GOTO	VOLTA_MEDIA	;SE NÃO, VOLTA PARA UM NOVO SHIFT À DIREITA
	GOTO	RETORNO_MEDIA	;SE SIM, RETORNA 
CONTINUA
	RRF	SOMAL		;SE NÃO HOUVER CARRY, SHIFT À DIREITA DE 'SOMAL'
	DECFSZ	INCR		;FORAM REALIZADOS 5 SHIFTS?
	GOTO	VOLTA_MEDIA	;SE NÃO, VOLTA PARA UM NOVO SHIFT À DIREITA DE 'SOMAH'
RETORNO_MEDIA
	RETURN			;SE SIM, RETORNA
	
GRAVA_MEDIA			;GRAVA MÉDIA NO ENDEREÇO 0 DA 'EEPROM'
	MOVLW	0X2100		;ENDEREÇO 0 DA 'EEPROM'
	MOVWF	ENDER		;'ENDER' RECEBE O ENDEREÇO 0 DA 'EEPROM'
	MOVFW	SOMAL		;'W' RECEBE O VALOR DA MÉDIA CONTIDO EM 'SOMAL'
	MOVWF	DADO		;'DADO' RECEBE 'W'
	MOVFW	ENDER		;'W' RECEBE O ENDEREÇO 0 DA 'EEPROM'
	CALL	GRAVA_EEPROM	;ROTINA DE ESCRITA NA 'EEPROM'
	RETURN
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000100' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	MOVLW	B'00001100'
	MOVWF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000100'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00001001'
	MOVWF	ADCON0

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN
	MOVLW	0X30		;ENDEREÇO INICIAL DA RAM
	MOVWF	FSR		;ENDEREÇAMENTO INDIRETO DE '0X30'
	MOVLW	.32		
	MOVWF	INCR		;CONTROLE DE 32 VALORES
ATIVA_CONV			
	NOP			;ESTÍMULO DE TENSÃO POR 'GP2'
	NOP
	BSF	ADCON0, 1	;INÍCIO DA CONVERSÃO A/D
VOLTA_AD
	BTFSC	ADCON0, 1	;VERIFICA SE A CONVERSÃO CONCLUIU
	GOTO	VOLTA_AD	;SE NÃO, CONTINUA VERIFICANDO
	CALL	GRAVA_RAM	;SE SIM, GRAVA O RESULTADO NA RAM
	DECFSZ	INCR		;FORAM ADICIONADOS 32 VALORES?
	GOTO	ATIVA_CONV	;SE NÃO, INICIA UMA NOVA CONVERSÃO
TRANSF_EEPROM
	MOVLW	0X30		;ENDEREÇO INICIAL DA RAM
	MOVWF	FSR		;ENDEREÇAMENTO INDIRETO DE '0X30'
	MOVLW	.32		
	MOVWF	INCR		;CONTROLE DE 32 VALORES
	MOVLW	0X2101		;ENDEREÇO 1 DA 'EEPROM'
	MOVWF	ENDER
VOLTA_EEPROM
	MOVFW	INDF		;MOVE O CONTEÚDO APONTADO POR 'FSR' PARA 'W'
	MOVWF	DADO		;'DADO' RECEBE 'W'
	MOVFW	ENDER		;'W' RECEBE O ENDEREÇO APONTADO POR 'FSR'
	CALL	GRAVA_EEPROM	;ROTINA DE ESCRITA NA 'EEPROM'
	DECFSZ	INCR		;FORAM TRANSFERIDOS OS 32 VALORES PARA A EEPROM?
	GOTO	VOLTA_EEPROM	;SE NÃO, INICIA UMA NOVA TRANSFERÊNCIA/GRAVAÇÃO
LEITURA_EEPROM
	MOVLW	.32		
	MOVWF	INCR		;CONTROLE DE 32 VALORES
	MOVLW	0X2101		;ENDEREÇO 1 DA 'EEPROM'
	MOVWF	ENDER		;'ENDER' RECEBE O ENDEREÇO 1 DA 'EEPROM'
	CLRF	SOMAL		;LIMPA 'SOMAL'
	CLRF	SOMAH		;LIMPA 'SOMAH'
VOLTA_LEITURA
	MOVFW	ENDER		;'W' RECEBE 'ENDER'
	CALL	LE_EEPROM	;RPTINA DE LEITURA DOS VALORES DA 'EEPROM'
	CALL	SOMA		;ROTINA DE SOMA
	DECFSZ	INCR		;FORAM SOMADOS OS 32 VALORES DA 'EEPROM'?
	GOTO	VOLTA_LEITURA	;SE NÃO, INICIA UMA NOVA LEITURA E SOMA
	CALL	MEDIA		;SE SIM, CALCULA A MÉDIA
	CALL	GRAVA_MEDIA	;GRAVA MÉDIA EM 'EEPROM'
FIM
	GOTO	FIM

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	END
