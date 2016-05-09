*&---------------------------------------------------------------------*
*& Report  ZTESTELUIZ
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

report  ztesteluiz message-id se.

tables: mara,
        ztable_test,
        makt.

types: begin of ty_saida,
         matnr  type mara-matnr,
         mtart  type mara-mtart,
         maktx  type makt-maktx,
         teste  type ztable_test-cod,
       end of ty_saida.

*Tabelas internas
data: t_mara  type table of mara,
      t_makt  type table of makt,
      t_saida type table of ty_saida,
      t_teste type table of ztable_test.
*Captura de campos
data: t_fieldcat  type slis_t_fieldcat_alv with header line.

*estruturas
data: s_mara  type mara,
      s_makt  type makt,
      s_saida type ty_saida,
      s_teste type ztable_test.
*estrutura de layout
data: s_layout  type slis_layout_alv.

select-options: so_matnr for mara-matnr.

start-of-selection.
  perform f_busca_dados.

  perform f_monta_dados.

  perform f_gera_alv.
*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_DADOS
*&---------------------------------------------------------------------*
*       Busca dados nas tabelas
*----------------------------------------------------------------------*
form f_busca_dados .
"gabriel teste
  select *
    into table t_mara
    from mara
   where matnr = so_matnr."'2000000044'.

  if t_mara[] is not initial." o campo(tabela) deve ter pelo menos um valor  nele
    select *
      into table t_makt
      from makt
       for all entries in t_mara
     where matnr eq t_mara-matnr " 'join' vinculo das tabelas
       and spras eq sy-langu.
  endif.

endform.                    " F_BUSCA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_DADOS
*&---------------------------------------------------------------------*
*       Monta dados na tabela de saida
*----------------------------------------------------------------------*
form f_monta_dados .

  loop at t_mara into s_mara.
    read table t_makt into s_makt with key matnr = s_mara-matnr.
    if sy-subrc eq 0.
      s_saida-matnr = s_makt-matnr.
      s_saida-mtart = s_mara-mtart.
      s_saida-maktx = s_makt-maktx.

      append s_saida to t_saida.
    endif.
  endloop.

endform.                    " F_MONTA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_GERA_ALV
*&---------------------------------------------------------------------*
*       Mota Saida do relatório
*----------------------------------------------------------------------*
form f_gera_alv .

  t_fieldcat-fieldname      = 'MATNR'.
  t_fieldcat-tabname        = 'T_SAIDA'.
  t_fieldcat-ref_fieldname  = 'MATNR'.
  t_fieldcat-ref_tabname    = 'MARA'.
  t_fieldcat-outputlen      = 18.

  append t_fieldcat.

  t_fieldcat-fieldname      = 'MTART'.
  t_fieldcat-tabname        = 'T_SAIDA'.
  t_fieldcat-ref_fieldname  = 'MTART'.
  t_fieldcat-ref_tabname    = 'MARA'.
  t_fieldcat-outputlen      = 4.

  append t_fieldcat.

  t_fieldcat-fieldname      = 'MAKTX'.
  t_fieldcat-tabname        = 'T_SAIDA'.
  t_fieldcat-ref_fieldname  = 'MAKTX'.
  t_fieldcat-ref_tabname    = 'MAKT'.
  t_fieldcat-outputlen      = 40.

  append t_fieldcat.

  t_fieldcat-fieldname      = 'MAKTX'.
  t_fieldcat-tabname        = 'T_SAIDA'.
  t_fieldcat-ref_fieldname  = 'MAKTX'.
  t_fieldcat-ref_tabname    = 'MAKT'.
  t_fieldcat-outputlen      = 20.

  append t_fieldcat.

  s_layout-zebra             = 'X'.
  s_layout-colwidth_optimize = 'X'.

  call function 'REUSE_ALV_GRID_DISPLAY'
   exporting
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
     i_buffer_active                   = 'X'
     i_callback_program                = sy-repid
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  = I_STRUCTURE_NAME
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE                      = I_GRID_TITLE
*     I_GRID_SETTINGS                   = I_GRID_SETTINGS
     is_layout                         = s_layout
     it_fieldcat                       = t_fieldcat[]
*     IT_EXCLUDING                      = IT_EXCLUDING
*     IT_SPECIAL_GROUPS                 = IT_SPECIAL_GROUPS
*     IT_SORT                           = IT_SORT
*     IT_FILTER                         = IT_FILTER
*     IS_SEL_HIDE                       = IS_SEL_HIDE
*     I_DEFAULT                         = 'X'
*     I_SAVE                            = ' '
*     IS_VARIANT                        = IS_VARIANT
*     IT_EVENTS                         = IT_EVENTS
*     IT_EVENT_EXIT                     = IT_EVENT_EXIT
*     IS_PRINT                          = IS_PRINT
*     IS_REPREP_ID                      = IS_REPREP_ID
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0
*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   = IT_ALV_GRAPHICS
*     IT_HYPERLINK                      = IT_HYPERLINK
*     IT_ADD_FIELDCAT                   = IT_ADD_FIELDCAT
*     IT_EXCEPT_QINFO                   = IT_EXCEPT_QINFO
*     IR_SALV_FULLSCREEN_ADAPTER        = IR_SALV_FULLSCREEN_ADAPTER
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           = E_EXIT_CAUSED_BY_CALLER
*     ES_EXIT_CAUSED_BY_USER            = ES_EXIT_CAUSED_BY_USER
    tables
      t_outtab                          = t_saida
   exceptions
     program_error                     = 1
     others                            = 2
            .
  if sy-subrc <> 0.
* Implement suitable error handling here
  endif.


endform.                    " F_GERA_ALV
