************************************************************************
*                                                                      *
*                        Consultoria                                *
*                                                                      *
* Nome do Programa   : TYPES                                           *
* Transação          : N/A                                             *
* Módulo funcional   : FI                                              *
* Título do Programa : TYPES                                           *
* Programador        : BRUNA                                           *
* Data de criação    : 28/08/2008                                      *
************************************************************************
* Objetivo:                                                            *
*----------------------------------------------------------------------*
* Lista de Modificações:                                               *
* Data        |   Autor      | Request #   |Breve descrição            *
* ---------------------------------------------------------------------*
*  28/08/2008 | BRUNA     | LOCAL  | Versão Inicial                 *
************************************************************************

REPORT  ZPX006_10.

************************************************************************
***  Tabela                                                          ***
************************************************************************

*TABELAS QUE SERÃO ULTILIZADAS.
Tables: MARA, MAKT.

************************************************************************
***  PARAMETRO DE SELEÇÃO                                            ***
************************************************************************

*parameter: p_MATNR type MARA-MATNR. 
*(VAI SER SELECIONADO UM MATERIAL POR VEZ
*OU SEJA, VAI SER VIZUALIZADO UM CAMPO).

*VAI SER VIZUALIDADO DOIS CAMPOS DE, ATÉ ONDE O USUARIO DESCIDIR).
select-options: s_MATNR for MARA-MATNR.


************************************************************************
***  TYPES                                                           ***
************************************************************************

*ABRINDO 3 CAMPOS (LINHAS DA 'PLANILHA' COM SEUS RESPCTIVOS NOMES).
TYPES: BEGIN OF TY_MARA,
*CRIANDO UM TIPO PARA TABELA INTERNA.
MATNR TYPE MARA-MATNR, "NOME DA COLUNA.
ERSDA TYPE MARA-ERSDA,
LAEDA TYPE MARA-LAEDA,
*CRIADO TODOS OS CAMPOS E FINALIZADO.
END OF TY_MARA.

*ABRINDO 2 CAMPOS (LINHAS DA 'PLANILHA' COM SEUS RESPCTIVOS NOMES).
TYPES: BEGIN OF TY_MAKT,
*CRIANDO UM TIPO PARA TABELA INTERNA.
MATNR TYPE MAKT-MATNR,
MAKTX TYPE MAKT-MAKTX,
*CRIADO TODOS OS CAMPOS E FINALIZADO.
END OF TY_MAKT.

************************************************************************
*** TABELAS INTERNAS                                                 ***
************************************************************************

*CRIANDO A TABELA POR INTEIRA
DATA: T_MARA TYPE TABLE OF TY_MARA,
T_MAKT TYPE TABLE OF TY_MAKT.


************************************************************************
*** ESTRUTURAS                                               ***
************************************************************************

*CRIANDO A LINHA QUE VAI LER A TABELA.
DATA: E_MARA TYPE TY_MARA,
E_MAKT TYPE TY_MAKT.

************************************************************************
*** START OF SELECTION                                               ***
************************************************************************

START-OF-SELECTION.

*LIMPAR O CODIGO.
PERFORM F_SELECT.

PERFORM F_IMPRESSAO.

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
*      SELEÇÃO DE MATERIAIS.
*----------------------------------------------------------------------*
FORM F_SELECT .

SELECT MATNR ERSDA LAEDA
*GUARDANDO DENTRO DA TABELA.
INTO TABLE T_MARA
*BUSCANDO DA TABELA MARA.
FROM MARA
*WHERE PEGA SOMENTE AS LINHAS FILTRADAS PELO MATNR (NO CASO).
WHERE MATNR IN S_MATNR.

*VAI CHECAR SE A TABELA MARA NÃO ESTÁ VAZIA.
IF NOT T_MARA[] IS INITIAL.

SELECT MATNR MAKTX
*GUARDANDO DENTRO DA TABELA.
INTO TABLE T_MAKT
*BUSCANDO DA TABELA MARA.
FROM MAKT
*ESTÁ BUSCANDO TODO CONTEUDO DA TABELA MARA.
FOR ALL ENTRIES IN T_MARA
WHERE MATNR = T_MARA-MATNR.

ENDIF.

ENDFORM.                    " F_SELECT


*&---------------------------------------------------------------------*
*&      Form  F_IMPRESSÃO
*&---------------------------------------------------------------------*
*       IMPRESSÃO
*----------------------------------------------------------------------*

FORM F_IMPRESSAO .


*VERIFICANDO REGISTRO A REGISTRO (LINHA Á LINHA).
LOOP AT T_MARA INTO E_MARA.

*LENDO AS DESCRIÇÕES DO REGISTRO E_MAKT.
READ TABLE T_MAKT INTO E_MAKT WITH KEY MATNR = E_MARA-MATNR.

*FORMATAR RELATÓRIO.
FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
FORMAT RESET.
ULINE.
FORMAT COLOR COL_NORMAL INTENSIFIED ON.


*IMPRESSÃO DO RELATÓRIO.
WRITE: / SY-VLINE, E_MARA-MATNR,
SY-VLINE, E_MARA-ERSDA,
SY-VLINE, E_MARA-LAEDA,
SY-VLINE, E_MAKT-MAKTX, SY-VLINE.

*FINALIZAR LOOP.
ENDLOOP.
ENDFORM.                    " F_IMPRESSÃO