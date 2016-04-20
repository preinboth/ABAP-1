&---------------------------------------------------------------------*
*& Report  ZPMR045
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
**                           Samarco                                 **
**                           MEGAWORK                                **
** PROGRAMA: ZPMR045 - Log Interface M.E.S x SAP-PM                  **
** DESCRIÇÃO: Programa para listar os dados da tabela ZPMT003        **
** TRANSAÇÃO:                                                        **
** AUTOR:.....Daniely Santos                                         **
** FUNCIONAL:.Gilson Martin                                          **
** DATA:......25.09.2013                                             **
***********************************************************************
** HISTÓRICO DAS MODIFICAÇÕES                                        **
**-------------------------------------------------------------------**
** DATA       | AUTOR | DESCRIÇÃO                                    **
**-------------------------------------------------------------------**
REPORT  zpmr045.

TYPE-POOLS: slis.

*FIELD-SYMBOLS: <p_param>.

*&---------------------------------------------------------------------*
*& Tabelas
*&---------------------------------------------------------------------*
TABLES: zpmt003.

*&---------------------------------------------------------------------*
*& Tipos
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_zpmt003.
        INCLUDE STRUCTURE zpmt003.
TYPES: END OF ty_zpmt003.

*&---------------------------------------------------------------------*
*& Tabelas internas
*&---------------------------------------------------------------------*

DATA: it_zpmt003    TYPE STANDARD TABLE OF ty_zpmt003.

* ALV
DATA: it_header     TYPE TABLE OF slis_listheader.   "Cabeçalho

*&---------------------------------------------------------------------*
*& Estrutura
*&---------------------------------------------------------------------*
DATA: st_header        LIKE LINE OF it_header.      "Cabeçalho

*&---------------------------------------------------------------------*
*& Variaveis
*&---------------------------------------------------------------------*
DATA:        lf_fieldcat      TYPE slis_t_fieldcat_alv,
             lf_layout        TYPE slis_layout_alv.

*&---------------------------------------------------------------------*
*& Variaveis
*&---------------------------------------------------------------------*
CONSTANTS: c_top_of_page  LIKE slis_ev_top_of_page VALUE 'F_TOP_OF_PAGE'.

SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-t01.
SELECT-OPTIONS: s_werks  FOR zpmt003-werks,   " OBLIGATORY.
                s_data   FOR zpmt003-data OBLIGATORY,
                s_hora   FOR zpmt003-hora,
                s_qmnum  FOR zpmt003-qmnum,         "NUMERO DA NOTA
                s_status FOR zpmt003-status.
SELECTION-SCREEN: END OF BLOCK b1.

START-OF-SELECTION.

  PERFORM busca_dados.                   "buscar dados na tabela
  PERFORM monta_alv.                     " configura e imprime a alv

*&---------------------------------------------------------------------*
*&      Form  BUSCA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM busca_dados .

  SELECT *
    INTO TABLE it_zpmt003
    FROM zpmt003
    WHERE werks  IN s_werks AND
          data   IN s_data  AND
          hora   IN s_hora  AND
          qmnum  IN s_qmnum AND
          status IN s_status.

ENDFORM.                    " BUSCA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LF_FIELDCAT[]  text
*----------------------------------------------------------------------*
FORM f_field  USING    p_lf_fieldcat   TYPE slis_t_fieldcat_alv.  "configurando os campos
 
  PERFORM field_alv USING 'VBELN'    text-001 'X' ' ' p_t_fieldcat.     "Documento de vendas
  PERFORM field_alv USING 'ERDAT'    text-002 ' ' ' ' p_t_fieldcat.     "Data de criação do registro
  PERFORM field_alv USING 'KUNNR'    text-003 ' ' ' ' p_t_fieldcat.     "Emissor da ordem
  PERFORM field_alv USING 'NAME1'    text-004 ' ' ' ' p_t_fieldcat.     "Nome 1
  PERFORM field_alv USING 'NETWR'    text-005 ' ' ' ' p_t_fieldcat.     "Valor líquido da ordem na moeda do documento
  PERFORM field_alv USING 'BSTNK'    text-006 ' ' ' ' p_t_fieldcat.     "Nº pedido do cliente
  PERFORM field_alv USING 'N_LIFSK'  text-014 ' ' ' ' p_t_fieldcat.     "Descrição - Bloqueio de nota de remessa (cabeçalho do documento)
  PERFORM field_alv USING 'N_FAKSK'  text-015 ' ' ' ' p_t_fieldcat.     "Descrição - Bloqueio tipos de doc.faturamento - documento SD
  PERFORM field_alv USING 'C_VKORG'  text-017 ' ' ' ' p_t_fieldcat.     "Codigo Organização de vendas
  PERFORM field_alv USING 'N_VKORG'  text-016 ' ' ' ' p_t_fieldcat.     "Descrição Organização de vendas
  PERFORM field_alv USING 'VKBUR'    text-018 ' ' 'C' p_t_fieldcat.     "Codigo Escritório de vendas
  PERFORM field_alv USING 'BEZEI'    text-012 ' ' ' ' p_t_fieldcat.     "Descrição Escritório de vendas

ENDFORM.                    " F_FIELD
*&---------------------------------------------------------------------*
*&      Form  F_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_layout .

  lf_layout-zebra               = 'X'.
  lf_layout-colwidth_optimize   = 'X'.
  lf_layout-lights_fieldname    = 'SINAL'.


ENDFORM.                    " F_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  SHOW_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_alv .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = 'F_ALV_USER_COMMAND'
      i_callback_top_of_page  = c_top_of_page
      is_layout               = lf_layout
      it_fieldcat             = lf_fieldcat
      i_save                  = 'A'
    TABLES
      t_outtab                = it_zpmt003
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  IF sy-subrc <> 0.

    MESSAGE e398(00) WITH text-t14.
    STOP.

  ENDIF.

ENDFORM.                    " SHOW_ALV
*&---------------------------------------------------------------------*
*&      Form  MONTA_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM monta_alv .

  IF it_zpmt003[] IS INITIAL.

    MESSAGE e398(00) WITH text-t13.
    STOP.

  ELSE.

    PERFORM f_header.                      "configurando o cabeçario
    PERFORM f_field USING lf_fieldcat[].   "configurando os campos
    PERFORM f_layout.                      "configurando o layout
    PERFORM show_alv.                      "imprime a alv

  ENDIF.

ENDFORM.                    " MONTA_ALV
*&---------------------------------------------------------------------*
*&      Form  F_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_header .

*-H = Header, S = Seleção, A = Ação
*-KEY => String with keyword character output in
*        combination with TYP = 'S'.
*-INFO:                Information output in header, formatted by type.

  DATA: vl_info(50) TYPE c,
        vl_param_i(80) TYPE c,
        vl_param_e(80) TYPE c,
        vl_separ_e(03) TYPE c,
        vl_separ_i(03) TYPE c.

  CLEAR : st_header, it_header.

  st_header-info = text-t11.
  st_header-typ  = 'H'.
  APPEND st_header TO it_header.

  CLEAR: st_header, vl_info.
  CONCATENATE sy-datum+6(2) '.' sy-datum+4(2) '.' sy-datum(4) INTO vl_info.

  st_header-info = vl_info.
  st_header-key = text-t15.
  st_header-typ  = 'S'.
  APPEND st_header TO it_header.

  CLEAR: st_header, vl_info.

* monta_cab é um perform para pegar todos os registros do select options
  PERFORM monta_cab USING 'S_WERKS'  text-t02 'S' 'C'.     "não muda a formatação - caracter
  PERFORM monta_cab USING 'S_DATA'   text-t03 'S' 'D'.     "formata para data
  PERFORM monta_cab USING 'S_HORA'   text-t04 'S' 'H'.     "formata para hora
  PERFORM monta_cab USING 'S_QMNUM'  text-t06 'S' 'U'.     "retira os zeros a esquerda - PACK
  PERFORM monta_cab USING 'S_STATUS' text-t08 'S' 'C'.     "não muda a formatação - caracter


ENDFORM.                    " F_HEADER

*&---------------------------------------------------------------------*
*&      Form  f_top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_top_of_page .
                                                            "#EC CALLED
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = it_header[].

ENDFORM.                    " top_of_page
*&---------------------------------------------------------------------*
*&      Form  MONTA_CAB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM monta_cab USING     p_param
                         p_texto
                         p_tipo
                         p_format.

  DATA: vl_separ_e(03)    TYPE c,            "variavel para colocar ou não a / para separar quando o select options tiver mais de 1 reg.
        vl_separ_i(03)    TYPE c,            "variavel para colocar ou não a / para separar quando o select options tiver mais de 1 reg.
        vl_compar(03)     TYPE c,            "variavel para guadar a forma de comparação (>=, <=, >....)
        vl_param_i        TYPE string,       "variavel para os registro que forem excluidos no select options
        vl_param_e        TYPE string,       "variavel para os registro de busca no select options
        vl_cabec          TYPE string.       "variavel para concatenar varias variaveis para montar o cabeçario

  DATA: vl_campo       TYPE string,
        vl_high(400)   TYPE c,
        vl_low(400)    TYPE c.

  FIELD-SYMBOLS: <fs_tab>      TYPE ANY TABLE,
                 <wa_param>    TYPE ANY,
                 <fs_high>     TYPE ANY,
                 <fs_low>      TYPE ANY,
                 <fs_sign>     TYPE ANY,
                 <fs_option>   TYPE ANY.

  CONCATENATE '(' sy-repid ')' p_param '[]' INTO vl_campo.
  ASSIGN (vl_campo) TO <fs_tab>.
  CHECK sy-subrc EQ 0.

  vl_separ_e = ''.
  vl_separ_i = ''.

  LOOP AT <fs_tab> ASSIGNING <wa_param>.

    ASSIGN COMPONENT 'SIGN' OF STRUCTURE <wa_param> TO <fs_sign>.
    CHECK sy-subrc EQ 0.

    ASSIGN COMPONENT 'OPTION' OF STRUCTURE <wa_param> TO <fs_option>.
    CHECK sy-subrc EQ 0.

    ASSIGN COMPONENT 'LOW' OF STRUCTURE <wa_param> TO <fs_low>.
    CHECK sy-subrc EQ 0.

    ASSIGN COMPONENT 'HIGH' OF STRUCTURE <wa_param> TO <fs_high>.
    CHECK sy-subrc EQ 0.

    IF p_format = 'C' OR p_format = 'U'.          "caracter - não muda a formatação

      vl_low  = <fs_low>.
      vl_high = <fs_high>.

      IF p_format = 'U'.      "PACK - retirar os zeros a esquerda

        PACK vl_low  TO vl_low.
        PACK vl_high TO vl_high.

        CONDENSE vl_low NO-GAPS.
        CONDENSE vl_high NO-GAPS.

      ENDIF.

    ELSEIF p_format = 'D'.      "formata para data

      CONCATENATE <fs_low>+6(2) '.' <fs_low>+4(2) '.' <fs_low>(4) INTO vl_low.
      CONCATENATE <fs_high>+6(2) '.' <fs_high>+4(2) '.' <fs_high>(4) INTO vl_high.

    ELSEIF p_format = 'H'.      "formata para hora

      CONCATENATE <fs_low>(2) ':' <fs_low>+2(2) INTO vl_low.
      CONCATENATE <fs_high>(2) ':' <fs_high>+2(2) INTO vl_high.

    ENDIF.

    IF <fs_option> = 'GE'.
      vl_compar = '>='.
    ELSEIF <fs_option> = 'LE'.
      vl_compar = '<='.
    ELSEIF <fs_option> = 'GT'.
      vl_compar = '>'.
    ELSEIF <fs_option> = 'LT'.
      vl_compar = '<'.
    ELSEIF <fs_option> = 'NE'.
      vl_compar = '#'.
    ELSEIF <fs_option> = 'NB'.
      vl_compar = ']['.
    ELSE.
      vl_compar = ''.
    ENDIF.

    IF <fs_sign> = 'I'.

      IF vl_param_i IS NOT INITIAL.
        vl_separ_i = ' / '.
      ENDIF.

      IF <fs_high> IS INITIAL.
        CONCATENATE vl_compar vl_param_i vl_separ_i vl_low INTO vl_param_i SEPARATED BY space.
      ELSE.
        CONCATENATE vl_compar vl_param_i vl_separ_i vl_low ' até ' vl_high INTO vl_param_i SEPARATED BY space.
      ENDIF.

    ELSEIF <fs_sign> = 'E'.

      IF vl_param_e IS NOT INITIAL.
        vl_separ_e = ' / '.
      ENDIF.

      IF <fs_high> IS INITIAL.
        CONCATENATE vl_compar vl_param_e vl_separ_e vl_low INTO vl_param_e SEPARATED BY space.
      ELSE.
        CONCATENATE vl_compar vl_param_e vl_separ_e vl_low ' até ' vl_high INTO vl_param_e SEPARATED BY space.
      ENDIF.

    ENDIF.

    UNASSIGN: <fs_sign>.
    UNASSIGN: <fs_high>.
    UNASSIGN: <fs_low>.
    UNASSIGN: <fs_option>.

  ENDLOOP.

  vl_cabec = ''.
  CONCATENATE p_texto ':' INTO vl_cabec SEPARATED BY space.

  IF vl_param_i IS NOT INITIAL..
    st_header-info = vl_param_i.
    st_header-key = vl_cabec.
    st_header-typ  = p_tipo.
    APPEND st_header TO it_header.
  ENDIF.

  vl_cabec = ''.
  CONCATENATE p_texto text-t12 ':' INTO vl_cabec SEPARATED BY space.

  IF vl_param_e IS NOT INITIAL..
    st_header-info = vl_param_e.
    st_header-key = vl_cabec.
    st_header-typ  = p_tipo.
    APPEND st_header TO it_header.
  ENDIF.

ENDFORM.                    " MONTA_CAB

*&---------------------------------------------------------------------*
*&      Form  f_alv_user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UCOMM      text
*      -->SELFIELD   text
*----------------------------------------------------------------------*
FORM f_alv_user_command USING ucomm LIKE sy-ucomm
                           selfield TYPE slis_selfield.
  IF ucomm = '&IC1'.

    CASE selfield-sel_tab_field.
      WHEN 'IT_ZPMT003-QMNUM'.
        SET PARAMETER ID 'IQM' FIELD selfield-value.
        CALL TRANSACTION 'IW23' AND SKIP FIRST SCREEN.
      WHEN OTHERS.
    ENDCASE.

  ENDIF.

ENDFORM. "z_user_command

*&---------------------------------------------------------------------*
*&      Form  FIELD_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0368   text
*      -->P_0369   text
*      -->P_TEXT_T01  text
*      -->P_P_T_FIELDCAT  text
*----------------------------------------------------------------------*
FORM field_alv  USING    campo
                         p_texto
                         p_hotspot
                         p_just
                         p2_t_fieldcat TYPE slis_t_fieldcat_alv..

  DATA: p_field TYPE slis_fieldcat_alv.

  CLEAR p_field.
  p_field-fieldname = campo.
  p_field-tabname   = 'T_ALV'.
  p_field-seltext_s = p_texto.
  p_field-seltext_m = p_texto.
  p_field-seltext_l = p_texto.
  p_field-hotspot   = p_hotspot.        "para aparecer a mão e dar um clique somente para executar o f_alv_user_command
*  p_field-outputlen = p_outputlen.      "para configurar o tamanho do campo, mas a opção do layout colwidth_optimize não pode estar ativa
  p_field-ddictxt   = 'L'.              "para configurar qual dos titulos será mostrado - (S)mall, (M)edium, (L)arge
  p_field-just      = p_just.           "para configurar o alinhamento - (C)enter, (L)eft, (R)igth
  APPEND p_field TO p2_t_fieldcat.

ENDFORM.                    " FIELD_ALV
