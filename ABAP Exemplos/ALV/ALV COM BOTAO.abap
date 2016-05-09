*----------------------------------------------------------------------*
*                            Megawork
*----------------------------------------------------------------------*
* Programa   : ZFIR026                                                 *
* Descrição  : Relatório Cotação de Moedas                             *
* Módulo     : FI                                   Transação: ZFI102  *
* Objetivo   : Lista as cotações de moedas processadas no dia          *
*                                                                      *
*----------------------------------------------------------------------*
* Autor      : Eduardo Pagoto                         Data: 17/09/2013 *
* Observações:                                                         *
* N.Chamado  : INC000031505117                                         *
*----------------------------------------------------------------------*
*                     Histórico das modificações                       *
*----------------------------------------------------------------------*
* Autor      :                                        Data:            *
* Observações:                                                         *
* N.Chamado  :                                                         *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& Report  ZFIR026
*&---------------------------------------------------------------------*

REPORT  ZFIR026.

TYPE-POOLS slis.

CLASS zcl_event_receiver DEFINITION DEFERRED.

TYPES: BEGIN OF ty_out,
         rate_type   TYPE kurst_curr,
         from_curr   TYPE fcurr_curr,
         to_currncy  TYPE tcurr_curr,
         currency    TYPE c LENGTH 13,
         exch_rate   TYPE ukursp,
         exch_rate_v TYPE ukursm,
         rate        TYPE ukursp,
         valid_from  TYPE gdatu_cur,
         usua_autor  TYPE syuname,
         index       TYPE int4,
       END OF ty_out.

DATA: gt_out   TYPE TABLE OF ty_out,
      t_fit004 TYPE TABLE OF zfit004,
      w_fit004 TYPE zfit004.

DATA: gt_fieldcat TYPE lvc_t_fcat,
      gs_layout   TYPE lvc_s_layo,
      gs_variant  TYPE disvariant.

DATA: go_alvgrid     TYPE REF TO cl_gui_alv_grid,
      go_docking     TYPE REF TO cl_gui_docking_container,
      go_splitter    TYPE REF TO cl_gui_splitter_container,
      go_parent_html TYPE REF TO cl_gui_container,
      go_parent_grid TYPE REF TO cl_gui_container,
      go_dyndoc_id   TYPE REF TO cl_dd_document,
      go_html_cntrl  TYPE REF TO cl_gui_html_viewer,
      go_event_receiver TYPE REF TO zcl_event_receiver.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
  PARAMETERS p_data TYPE datum OBLIGATORY DEFAULT sy-datum.
SELECTION-SCREEN END OF BLOCK b1.


START-OF-SELECTION.
  PERFORM f_get_data.  " Busca os dados da tabela ZFIT004

  IF t_fit004[] IS INITIAL.
    MESSAGE s028(zfi) WITH 'Não existem dados para atualizar'.
    EXIT.
  ENDIF.

  PERFORM f_set_data.  " Edita os dados de saída
  CALL SCREEN '1010'.


*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
form f_get_data .

  SELECT *
    FROM zfit004
    INTO TABLE t_fit004
   WHERE valid_from EQ p_data.

endform.                    " F_GET_DATA


*&---------------------------------------------------------------------*
*&      Form  F_SET_DATA
*&---------------------------------------------------------------------*
form f_set_data .

  DATA: ls_out      TYPE ty_out,
        lv_currency TYPE c LENGTH 13.


  LOOP AT t_fit004 INTO w_fit004.

    CLEAR lv_currency.
    CONCATENATE w_fit004-from_curr 'X' w_fit004-to_currncy INTO lv_currency SEPARATED BY space.

    MOVE-CORRESPONDING w_fit004 TO ls_out.
    IF ls_out-exch_rate IS NOT INITIAL.
      ls_out-rate = ls_out-exch_rate.
    ELSEIF ls_out-exch_rate_v IS NOT INITIAL.
      ls_out-rate = ls_out-exch_rate_v.
    ENDIF.
    ls_out-currency = lv_currency.
    ls_out-index    = sy-tabix.
    APPEND ls_out TO gt_out.

  ENDLOOP.

  SORT gt_out BY valid_from rate_type currency.

endform.                    " F_SET_DATA


*&---------------------------------------------------------------------*
*&      Form  PREPARE_FIELD_CATALOG
*&---------------------------------------------------------------------*
FORM prepare_field_catalog CHANGING t_fieldcat TYPE lvc_t_fcat.

  DATA ls_fieldcat TYPE lvc_s_fcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-outputlen = '25'.
  ls_fieldcat-fieldname = 'RATE_TYPE'.
  ls_fieldcat-tabname   = 'T_OUT'.
  ls_fieldcat-reptext   = 'Categoria'.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'CURRENCY'.
  ls_fieldcat-tabname   = 'T_OUT'.
  ls_fieldcat-reptext   = 'Descrição'.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-edit      = 'X'.
  ls_fieldcat-outputlen = '25'.
  ls_fieldcat-fieldname = 'RATE'.
  ls_fieldcat-tabname   = 'T_OUT'.
  ls_fieldcat-reptext   = 'Taxa'.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VALID_FROM'.
  ls_fieldcat-tabname   = 'T_OUT'.
  ls_fieldcat-reptext   = 'Data'.
  APPEND ls_fieldcat TO t_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'USUA_AUTOR'.
  ls_fieldcat-tabname   = 'T_OUT'.
  ls_fieldcat-reptext   = 'Usuário'.
  APPEND ls_fieldcat TO t_fieldcat.

ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  prepare_layout
*&---------------------------------------------------------------------*
FORM prepare_layout CHANGING ps_layout TYPE lvc_s_layo.

  ps_layout-zebra      = 'X'.
  ps_layout-smalltitle = 'X'.
  ps_layout-numc_total = 'X'.
  ps_layout-cwidth_opt = 'X'.
  ps_layout-no_toolbar = 'X'.
  ps_layout-stylefname = 'CELLSTYLES'.

ENDFORM. "PREPARE_LAYOUT


*&---------------------------------------------------------------------*
*&      Form  F_ATUALIZACAO
*&---------------------------------------------------------------------*
FORM f_atualizacao.

    DATA lv_answer TYPE answer.

    LOOP AT gt_out TRANSPORTING NO FIELDS WHERE usua_autor IS NOT INITIAL.
      EXIT.
    ENDLOOP.

    IF sy-subrc EQ 0.
      MESSAGE w028(zfi) WITH 'Os dados já foram atualizados'.
    ENDIF.

    CALL FUNCTION 'POPUP_TO_CONFIRM'
      EXPORTING
        text_question  = 'Confirma atualização?'
        text_button_1  = 'Sim'
        icon_button_1  = 'ICON_OKAY'
        text_button_2  = 'Não'
        icon_button_2  = 'ICON_CANCEL'
        default_button = '2'
        display_cancel_button = ''
      IMPORTING
        answer         = lv_answer
      EXCEPTIONS
        text_not_found = 1
        OTHERS         = 2.

    IF lv_answer EQ '1'.
      PERFORM f_autor_atualizacao.
      LEAVE PROGRAM.
    ENDIF.

ENDFORM.                    " F_ATUALIZACAO


*&---------------------------------------------------------------------*
*&      Form  F_AUTOR_ATUALIZACAO
*&---------------------------------------------------------------------*
FORM f_autor_atualizacao .

  DATA: wa_return TYPE bapiret2,
        ls_out    TYPE ty_out,
        lv_error  TYPE c,
        lv_cambi  TYPE string,
        lv_curor  TYPE string,
        lv_curdt  TYPE string,
        lv_fator  TYPE string,
        lv_fatdt  TYPE string.


  LOOP AT t_fit004 INTO w_fit004.

    READ TABLE gt_out INTO ls_out WITH KEY rate_type  = w_fit004-rate_type
                                           from_curr  = w_fit004-from_curr
                                           to_currncy = w_fit004-to_currncy
                                           valid_from = w_fit004-valid_from.

    IF sy-subrc EQ 0.

      IF ls_out-exch_rate IS NOT INITIAL.
        w_fit004-exch_rate   = ls_out-rate.
      ELSEIF ls_out-exch_rate_v IS NOT INITIAL.
        w_fit004-exch_rate_v = ls_out-rate.
      ENDIF.
      w_fit004-dt_autor   = sy-datum.
      w_fit004-hora_autor = sy-uzeit.
      w_fit004-usua_autor = sy-uname.
      MODIFY t_fit004 FROM w_fit004.

    ELSE.
      DELETE t_fit004.
    ENDIF.

  ENDLOOP.

  MODIFY zfit004 FROM TABLE t_fit004.
  IF sy-subrc EQ 0.

    LOOP AT t_fit004 INTO w_fit004.

      CLEAR: wa_return, lv_cambi, lv_curor, lv_curdt, lv_fator, lv_fatdt.
      IF w_fit004-exch_rate IS NOT INITIAL.

        MOVE: w_fit004-exch_rate   TO lv_cambi,
              w_fit004-from_curr   TO lv_curor,
              w_fit004-to_currncy  TO lv_curdt,
              w_fit004-from_factor TO lv_fator,
              w_fit004-to_factor   TO lv_fatdt.

      ELSEIF w_fit004-exch_rate_v IS NOT INITIAL.

        MOVE: w_fit004-exch_rate_v   TO lv_cambi,
              w_fit004-from_curr     TO lv_curor,
              w_fit004-to_currncy    TO lv_curdt,
              w_fit004-from_factor_v TO lv_fator,
              w_fit004-to_factor_v   TO lv_fatdt.

      ENDIF.


      IF w_fit004-exch_rate IS NOT INITIAL.

        CALL FUNCTION 'ZFI_COTACAO_MOEDAS'
          EXPORTING
            taxa_cambio   = lv_cambi
            moeda_destino = lv_curdt
            moeda_origem  = lv_curor
            categoria     = w_fit004-rate_type
            data          = w_fit004-valid_from
            fator_origem  = lv_fator
            fator_destino = lv_fatdt
          IMPORTING
            return        = wa_return.

      ELSEIF w_fit004-exch_rate_v IS NOT INITIAL.

        CALL FUNCTION 'ZFI_COTACAO_MOEDAS'
          EXPORTING
            taxa_cambio_indireta = lv_cambi
            moeda_destino = lv_curdt
            moeda_origem  = lv_curor
            categoria     = w_fit004-rate_type
            data          = w_fit004-valid_from
            fator_origem  = lv_fator
            fator_destino = lv_fatdt
          IMPORTING
            return        = wa_return.

      ENDIF.

      IF wa_return-type EQ 'E'.
        MOVE 'X' TO lv_error.
        EXIT.
      ENDIF.

    ENDLOOP.

  ELSE.
    MOVE 'X' TO lv_error.
  ENDIF.

  IF lv_error IS INITIAL.

    COMMIT WORK.
    MESSAGE s028(zfi) WITH 'Atualização concluída com sucesso'.

  ELSE.

    ROLLBACK WORK.
    MESSAGE e028(zfi) WITH 'Falha na atualização'.

  ENDIF.

ENDFORM.                    " F_AUTOR_ATUALIZACAO


*&---------------------------------------------------------------------*
*&      Form  F_ELIMINACAO
*&---------------------------------------------------------------------*
FORM f_eliminacao TABLES p_rows.

  DATA: ls_out    TYPE ty_out,
        ls_fit004 TYPE zfit004,
        lv_answer TYPE answer,
        lv_error  TYPE c,
        lr_rows   TYPE TABLE OF int4 WITH HEADER LINE,
        lr_indx   TYPE RANGE OF int4 WITH HEADER LINE.

  APPEND LINES OF p_rows TO lr_rows.
  IF lr_rows[] IS INITIAL.
    MESSAGE w028(zfi) WITH 'Nenhuma linha selecionada'.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      text_question  = 'Confirma eliminação?'
      text_button_1  = 'Sim'
      icon_button_1  = 'ICON_OKAY'
      text_button_2  = 'Não'
      icon_button_2  = 'ICON_CANCEL'
      default_button = '2'
      display_cancel_button = ''
    IMPORTING
      answer         = lv_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.

  IF lv_answer EQ '1'.

    LOOP AT lr_rows.

      CLEAR: lr_indx, ls_out, ls_fit004.
      READ TABLE gt_out INTO ls_out INDEX lr_rows.
      MOVE-CORRESPONDING ls_out TO ls_fit004.

      lr_indx-sign   = 'I'.
      lr_indx-option = 'EQ'.
      lr_indx-low    = ls_out-index.
      APPEND lr_indx.

      DELETE zfit004 FROM ls_fit004.
      IF sy-subrc NE 0.
        MOVE 'X' TO lv_error.
      ENDIF.

    ENDLOOP.

    IF lv_error IS INITIAL.

      DELETE gt_out WHERE index IN lr_indx.
      IF sy-subrc EQ 0.
        MESSAGE s028(zfi) WITH 'Registro(s) eliminado(s) com sucesso!'.
        COMMIT WORK.
      ELSE.
        MESSAGE w028(zfi) WITH 'Erro ao deletar o(s) registro(s)'.
        ROLLBACK WORK.
      ENDIF.

    ELSE.
      MESSAGE w028(zfi) WITH 'Erro ao deletar o(s) registro(s)'.
      ROLLBACK WORK.
    ENDIF.

  ENDIF.

ENDFORM.                    " F_ELIMINACAO


FORM event_top_of_page USING p_dyndoc_id TYPE REF TO cl_dd_document.

  DATA: lv_text(255) TYPE c,
        lv_text_ele  TYPE sdydo_text_element,
        lo_table     TYPE REF TO cl_dd_table_element,
        lo_col_key   TYPE REF TO cl_dd_area,
        lo_col_info  TYPE REF TO cl_dd_area,
        lo_logo      TYPE REF TO cl_dd_area.

  CLEAR lv_text.

* Split TOP-Document
  CALL METHOD p_dyndoc_id->vertical_split
    EXPORTING
      split_area  = p_dyndoc_id
      split_width = '70%'
    IMPORTING
      right_area  = lo_logo.

* Populating header to top-of-page
  CALL METHOD go_dyndoc_id->add_text
    EXPORTING
      text      = 'Cotação de moedas'
      sap_style = 'HEADING'.

  CALL METHOD lo_logo->add_picture
    EXPORTING
      picture_id = 'PS_LOGO'.

  CALL METHOD go_dyndoc_id->new_line.
  CLEAR lv_text.

  CALL METHOD go_dyndoc_id->add_table
    EXPORTING
      no_of_columns = 2
      with_heading  = ' '
      border        = '0'
    IMPORTING
      table         = lo_table.

  CALL METHOD lo_table->add_column
    IMPORTING
      column = lo_col_key.

  CALL METHOD lo_table->add_column
    IMPORTING
      column = lo_col_info.

  DEFINE m_header_text.

    CALL METHOD lo_col_key->add_text
      EXPORTING
        text         = &1
        sap_emphasis = 'Strong'.

  END-OF-DEFINITION.

  DEFINE m_info_text.

    CALL METHOD lo_col_info->add_gap
      EXPORTING
        width = 2.
    CALL METHOD lo_col_info->add_text
      EXPORTING
        text = &1.

  END-OF-DEFINITION.


  CONCATENATE p_data+6(2) '/' p_data+4(2) '/' p_data(4) INTO lv_text.
  m_header_text 'Data:'.
  m_info_text lv_text.
  CALL METHOD lo_table->new_row.
  PERFORM html.

ENDFORM. " EVENT_TOP_OF_PAGE


*&---------------------------------------------------------------------*
*& Form HTML
*&---------------------------------------------------------------------*
* for summary report display
*----------------------------------------------------------------------*
FORM html.

  DATA: lv_length        TYPE i,                     " Length
        lv_background_id TYPE sdydo_key VALUE space. " Background_id


* Creating html control
  IF go_html_cntrl IS INITIAL.

    CREATE OBJECT go_html_cntrl
      EXPORTING
        parent = go_parent_html.

  ENDIF.

* Reuse_alv_grid_commentary_set
  CALL FUNCTION 'REUSE_ALV_GRID_COMMENTARY_SET'
    EXPORTING
      document = go_dyndoc_id
      bottom   = space
    IMPORTING
      length   = lv_length.

* Get TOP->HTML_TABLE ready
  CALL METHOD go_dyndoc_id->merge_document.

* Set wallpaper
  CALL METHOD go_dyndoc_id->set_document_background
    EXPORTING
      picture_id = lv_background_id.

* Connect TOP document to HTML-Control
  go_dyndoc_id->html_control = go_html_cntrl.

* Display TOP document
  CALL METHOD go_dyndoc_id->display_document
    EXPORTING
      reuse_control      = 'X'
      parent             = go_parent_html
    EXCEPTIONS
      html_display_error = 1.

  IF sy-subrc NE 0.
    MESSAGE i208(00) WITH 'Error in displaying top-of-page'.
  ENDIF.

ENDFORM. " HTML


*&---------------------------------------------------------------------*
*&       Class (Definition)  ZCL_EVENT_RECEIVER
*&---------------------------------------------------------------------*
CLASS zcl_event_receiver DEFINITION.

  PUBLIC SECTION.
    METHODS: handle_top_of_page  FOR EVENT print_top_of_page OF cl_gui_alv_grid,
             handle_data_changed FOR EVENT data_changed OF cl_gui_alv_grid.

  PRIVATE SECTION.
    DATA: pagenum TYPE i.

ENDCLASS.               "ZCL_EVENT_RECEIVER


*&---------------------------------------------------------------------*
*&       Class (Implementation)  ZCL_EVENT_RECEIVER
*&---------------------------------------------------------------------*
CLASS zcl_event_receiver IMPLEMENTATION.

  METHOD handle_top_of_page.

    DATA: lv_data(10) TYPE c,
          lv_cabecalho(60),
          lv_aux(50).

    CONCATENATE sy-datum+6(2) '/' sy-datum+4(2) '/' sy-datum(4) INTO lv_data.
    WRITE: /'Data:                ', lv_data.

  ENDMETHOD.                    "HANDLE_TOP_OF_PAGE

  METHOD handle_data_changed.

    DATA: lv_idx    TYPE i,
          ls_outtab LIKE LINE OF gt_out.

    CALL METHOD go_alvgrid->refresh_table_display
      EXCEPTIONS
        finished = 1
        OTHERS   = 2.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED

ENDCLASS.               "ZCL_EVENT_RECEIVER


INCLUDE zfir026_pbo.
INCLUDE zfir026_pai.