*&---------------------------------------------------------------------*
*& Report  ZTESTEGABRIEL
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
report ztestegabriel.
*&---------------------------------------------------------------------*
*&Declarações
*&---------------------------------------------------------------------*
types: slis_t_fieldcat_alv type slis_fieldcat_alv occurs 1.

data: lt_fieldcat         type slis_t_fieldcat_alv with header line,
      ls_fieldcat          type slis_fieldcat_alv,
      ls_print             type slis_print_alv,
      ls_layout            type slis_layout_alv.

data: v_repid like sy-repid,
      v_pos   like sy-index.

*tipo, wa e tabela de saida provisória para teste
*Criação de tipo para ser usado em tabela
types: begin of ty_material,
         matnr type mara-matnr,
         maktx type makt-maktx,
*         texto TYPE c LENGTH 1000,
       end of ty_material.

data: it_arquivo type table of ty_material with header line.
data: wa_arquivo type ty_material.
*******************************************************
select-options: so_matnr for it_arquivo-matnr.

wa_arquivo-matnr = '188'.
wa_arquivo-maktx = ' descrição do 188 wa'.
*wa_arquivo-texto = 'texto 188 wa'.

start-of-selection.
  "write: 'teste'.

  perform seleciona_dados.

  perform f_montar_alv.

*&---------------------------------------------------------------------*
*&      Form  F_MONTAR_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form f_montar_alv.
  "Cabeçalho das colunas
  perform field_cat using lt_fieldcat[].

  perform print_alv.

endform.                    " F_MONTAR_ALV
*&---------------------------------------------------------------------*
*&      Form  FIELD_CAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form field_cat using p_lt_fieldcat type slis_t_fieldcat_alv.
  clear: ls_fieldcat, v_pos.
  refresh lt_fieldcat.
  v_pos = 0.
  "Os campos veem da 'wa_arquivo'-matnr , -maktx , -texto.
  add 1 to v_pos.
  perform montagrid using v_pos 'MATNR' 'Nr Material' 18 'L' '' '' '' '' ''.
  append ls_fieldcat to lt_fieldcat.

  add 1 to v_pos.
  perform montagrid using v_pos 'MAKTX' 'Descrição Material' 40 'L' '' '' '' '' ''.
  append ls_fieldcat to lt_fieldcat.

  add 1 to v_pos.
  perform montagrid using v_pos 'TEXTO' 'Texto' 255 'L' '' '' '' '' ''.
  append ls_fieldcat to lt_fieldcat.
endform.                    " FIELD_CAT
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
form montagrid  using v_pos v_field v_tit v_tam v_just v_fix v_sum v_out v_ref_f v_tab.
  clear ls_fieldcat.
  ls_fieldcat-col_pos       = v_pos.
  ls_fieldcat-fieldname     = v_field.
  ls_fieldcat-tabname       = it_arquivo.                 "tabela saída para fieldcat
  ls_fieldcat-reptext_ddic  = v_tit.
  ls_fieldcat-just          = v_just.
  if v_tam = 0.
    ls_fieldcat-outputlen     = strlen( v_tit ).
  else.
    ls_fieldcat-outputlen     = v_tam.
  endif.

  ls_fieldcat-ref_fieldname = v_ref_f.
  ls_fieldcat-ref_tabname = v_tab.
  ls_fieldcat-fix_column    = v_fix.
  ls_fieldcat-do_sum        = v_sum.
  ls_fieldcat-no_out        = v_out.

endform.                    " MONTAGRID
*&---------------------------------------------------------------------*
*&      Form  PRINT_ALV
*&---------------------------------------------------------------------*
*       Exibe ALV na tela com os dados da tabela de saída
*----------------------------------------------------------------------*
form print_alv.
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
  move sy-repid to v_repid.

  call function 'REUSE_ALV_GRID_DISPLAY'
    exporting
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
    tables
      t_outtab                 = it_arquivo   " **************************** tabela de saida  *******************************************
    exceptions
      program_error            = 1
      others                   = 2.

  if sy-subrc ne 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                    " PRINT_ALV
*&---------------------------------------------------------------------*
*&      Form  SELECIONA_DADOS
*&---------------------------------------------------------------------*
*       select dos dados para tabela de saida
*----------------------------------------------------------------------*
form seleciona_dados .

  select a~matnr
      into table it_arquivo
    from mara as a
      join makt as b on ( a~matnr eq b~maktx )
  where
      a~matnr in so_matnr.

  if it_arquivo[] is not initial." o campo(tabela) deve ter pelo menos um valor  nele (se a tabela tiver arquivos, faça!)
    select b~maktx
      into table it_arquivo
      from makt as b
       where matnr eq it_arquivo-matnr. "t_mara-matnr " 'join' vinculo das tabelas
    "and spras eq sy-langu.
  endif.

endform.                    " SELECIONA_DADOS
