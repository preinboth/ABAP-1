*&---------------------------------------------------------------------*
*& Report  ZTESTEGABRIEL
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT ztestegabriel.

*&---------------------------------------------------------------------*
*&Declarações
*&---------------------------------------------------------------------*
TYPES: slis_t_fieldcat_alv TYPE slis_fieldcat_alv OCCURS 1.

DATA: lt_fieldcat         TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      ls_fieldcat          TYPE slis_fieldcat_alv,
      ls_print             TYPE slis_print_alv,
      ls_layout            TYPE slis_layout_alv.

DATA: v_repid LIKE sy-repid,
      v_pos   LIKE sy-index.



*tipo, wa e tabela de saida provisória para teste
*Criação de tipo para ser usado em tabela
TYPES: BEGIN OF ty_material,
         matnr TYPE mara-matnr,
         maktx TYPE makt-maktx,
         texto TYPE c LENGTH 1000,
       END OF ty_material.


DATA: it_arquivo TYPE TABLE OF ty_material WITH HEADER LINE.
DATA: wa_arquivo TYPE ty_material.
*******************************************************

SELECT-OPTIONS: so_matnr FOR it_arquivo-matnr.


wa_arquivo-matnr = '188'.
wa_arquivo-maktx = ' descrição do 188 wa'.
wa_arquivo-texto = 'texto 188 wa'.


START-OF-SELECTION.
  "write: 'teste'.

  PERFORM seleciona_dados.

  PERFORM f_montar_alv.


*&---------------------------------------------------------------------*
*&      Form  F_MONTAR_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM f_montar_alv.
  "Cabeçalho das colunas
  PERFORM field_cat USING lt_fieldcat[].

  PERFORM print_alv.

ENDFORM.                    " F_MONTAR_ALV

*&---------------------------------------------------------------------*
*&      Form  FIELD_CAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM field_cat USING p_lt_fieldcat TYPE slis_t_fieldcat_alv.
  CLEAR: ls_fieldcat, v_pos.
  REFRESH lt_fieldcat.
  v_pos = 0.
  "Os campos veem da 'wa_arquivo'-matnr , -maktx , -texto.
  ADD 1 TO v_pos.
  PERFORM montagrid USING v_pos 'MATNR' 'Nr Material' 18 'L' '' '' '' '' ''.
  APPEND ls_fieldcat TO lt_fieldcat.

  ADD 1 TO v_pos.
  PERFORM montagrid USING v_pos 'MAKTX' 'Descrição Material' 40 'L' '' '' '' '' ''.
  APPEND ls_fieldcat TO lt_fieldcat.

  ADD 1 TO v_pos.
  PERFORM montagrid USING v_pos 'TEXTO' 'Texto' 255 'L' '' '' '' '' ''.
  APPEND ls_fieldcat TO lt_fieldcat.

ENDFORM.                    " FIELD_CAT
*&---------------------------------------------------------------------*
*&      Form  MONTAGRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->V_POS      text
*      -->V_FIELD    text
*      -->V_TIT      text
*      -->V_TAM      text
*      -->V_JUST     text
*      -->V_FIX      text
*      -->V_SUM      text
*      -->V_OUT      text
*      -->V_REF_F    text
*      -->V_TAB      text
*----------------------------------------------------------------------*
FORM montagrid  USING v_pos v_field v_tit v_tam v_just v_fix v_sum v_out v_ref_f v_tab.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       = v_pos.
  ls_fieldcat-fieldname     = v_field.
  ls_fieldcat-tabname       = it_arquivo.                 "tabela saída para fieldcat
  ls_fieldcat-reptext_ddic  = v_tit.
  ls_fieldcat-just          = v_just.
  IF v_tam = 0.
    ls_fieldcat-outputlen     = strlen( v_tit ).
  ELSE.
    ls_fieldcat-outputlen     = v_tam.
  ENDIF.

  ls_fieldcat-ref_fieldname = v_ref_f.
  ls_fieldcat-ref_tabname = v_tab.
  ls_fieldcat-fix_column    = v_fix.
  ls_fieldcat-do_sum        = v_sum.
  ls_fieldcat-no_out        = v_out.

ENDFORM.                    " MONTAGRID
*&---------------------------------------------------------------------*
*&      Form  PRINT_ALV
*&---------------------------------------------------------------------*
*       Exibe ALV na tela com os dados da tabela de saída
*----------------------------------------------------------------------*

FORM print_alv.

* Indexar os campos do ALV
*  PERFORM index_alv.

* Dados de Layout
  ls_layout-expand_all        = ''.
  ls_layout-edit              = ''.
*  ls_layout-no_totalline      = 'X'. " no total line
*  ls_layout-no_totalline      = 'X'. " no total line
  ls_layout-zebra             = 'X'.
  ls_layout-colwidth_optimize = 'X'.

* Dados de Impressão
  ls_print-no_print_listinfos = 'X'.

* Nome do programa de impressão
  MOVE sy-repid TO v_repid.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_buffer_active          = 'X'
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'SET_PF_STATUS_ALV_1'
*     i_callback_user_command  = c_user_command
      i_callback_top_of_page   = 'TOP_OF_PAGE'
      is_layout                = ls_layout
      it_fieldcat              = lt_fieldcat[]
*     it_sort                  = lt_sort
*     i_save                   = lv_save
*     is_variant               = ls_variant
*     it_event_exit            = lt_event_exit
    TABLES
      t_outtab                 = it_arquivo   " **************************** tabela de saida  *******************************************
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " PRINT_ALV
*&---------------------------------------------------------------------*
*&      Form  SELECIONA_DADOS
*&---------------------------------------------------------------------*
*       select dos dados para tabela de saida
*----------------------------------------------------------------------*
FORM seleciona_dados .

  SELECT *
      INTO TABLE it_arquivo
    FROM mara AS a
      "join makt as b on ( a~matnr eq b~maktx )
  WHERE
      a~matnr IN so_matnr.

  IF it_arquivo[] IS NOT INITIAL." o campo(tabela) deve ter pelo menos um valor  nele (se a tabela tiver arquivos, faça!)
    SELECT *
      INTO TABLE it_arquivo-maktx
      FROM makt
       FOR ALL ENTRIES IN it_arquivo-matnr "t_mara
     WHERE matnr EQ it_arquivo-matnr. "t_mara-matnr " 'join' vinculo das tabelas
    "and spras eq sy-langu.
  ENDIF.
ENDFORM.                    " SELECIONA_DADOS