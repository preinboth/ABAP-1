*&---------------------------------------------------------------------*
*& Report  ZTESTE_GABRIEL
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zteste_gabriel.
*----------------------------------------------------------------------*
* Tela de Seleção
*----------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
" Parametros
PARAMETERS: p_file TYPE rlgrap-filename.
SELECTION-SCREEN: END OF BLOCK b1.

DATA ti_bdcdata TYPE TABLE OF bdcdata.
DATA wa_bdcdata TYPE bdcdata.

Data s_mostraJanela type ctu_params.

CLEAR wa_bdcdata.
wa_bdcdata-program  = 'SAPLSD_ENTRY'."nome do programa (label)
wa_bdcdata-dynpro   = '1000'."nome da tela
wa_bdcdata-dynbegin = 'X'."permitir edição do campo
APPEND wa_bdcdata to ti_bdcdata.

CLEAR wa_bdcdata.
wa_bdcdata-fnam = 'RSRD1-TBMA'.
wa_bdcdata-fval = 'X'.
APPEND wa_bdcdata to ti_bdcdata.

CLEAR wa_bdcdata.
wa_bdcdata-fnam = 'RSRD1-TBMA_VAL'.
wa_bdcdata-fval = p_file.
APPEND wa_bdcdata to ti_bdcdata.


CLEAR wa_bdcdata.
wa_bdcdata-fnam = 'BDC_OKCODE'."clique de seleção ou enter, ou dois cliques
wa_bdcdata-fval = 'WB_DISPLAY'."nome da ação exibir que esta em se38
APPEND wa_bdcdata to ti_bdcdata.

s_mostrajanela-dismode = 'E'. "forma de exibir as janelas na execução do batchinput (E para quando der erro, A para sempre, e N para nunca aparecer)

CALL TRANSACTION 'SE11' USING ti_bdcdata OPTIONS FROM s_mostrajanela."options from serve para validar e executar a estrutura s_mostraJanela 
