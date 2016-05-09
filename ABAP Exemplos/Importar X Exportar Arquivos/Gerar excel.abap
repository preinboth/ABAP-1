method GERAR_EXCEL .

 DATA: BEGIN OF ls_espec,
          cod_especificacao TYPE zdesd_cod_especificacao,
          vlr_tipico        TYPE zdesd_vlr_tipico,
          vlr_garantido_min TYPE zdesd_vlr_garantido_min,
          vlr_garantido_max TYPE zdesd_vlr_garantido_max,
          dcr_penalidades   TYPE zdesd_dcr_penalidades,
          aenam             TYPE aenam,
          aedat             TYPE aedat,
          aezet             TYPE aezet,
       END OF ls_espec.

  DATA: lt_espec LIKE TABLE OF ls_espec.

  DATA: lo_nd_especificacao TYPE REF TO if_wd_context_node.

  "*************************************************************
  " Tabelas
  "*************************************************************
  DATA: lt_especificacao  TYPE TABLE OF zsds015_especifi,
        lt_aux            TYPE TABLE OF zsds015_especifi.
  "*************************************************************
  " Workareas
  "*************************************************************
  DATA: ls_especificacao TYPE zsds015_especifi,
        wa_especificacao TYPE zsdt006_doc.

  DATA: l_msg TYPE string.

  DATA: lv_encoding  TYPE abap_encoding,
        lv_app_type(50) TYPE c,
        lv_tip_spec  TYPE string,
        lv_material  TYPE string,
        lv_text      TYPE string,
        lv_date(10)  TYPE c,
        lv_hour(8)   TYPE c,
        lv_vl_max    TYPE string,
        lv_vl_min    TYPE string,
        lv_linha     TYPE string,
        lv_name      TYPE string,
        lv_xstring   TYPE xstring.

  lo_nd_especificacao = wd_context->get_child_node( wd_this->wdctx_nd_especificacao ).

  CALL METHOD lo_nd_especificacao->get_static_attributes_table(
    IMPORTING
      table = lt_aux ).

  "Monta header
  CONCATENATE 'Commodity'
              'Specification Type'
              'Specification'
              'Typical'
              'Guaranteed Min.'
              'Guaranteed Max.'
              'Price Adjust. Rules'
              'Changed by'
              'Changed on'
              'Time of Change'
              cl_abap_char_utilities=>newline
              INTO lv_text
              SEPARATED BY cl_abap_char_utilities=>horizontal_tab.

  LOOP AT lt_aux INTO ls_especificacao.

    FREE:  lv_vl_max, lv_vl_min, lv_date, lv_hour, lv_material, lv_tip_spec, lv_linha.

    "Busca valor descritivo
    CASE ls_especificacao-tip_especificacao.
      WHEN 'C'.
        lv_tip_spec = 'Chemical'.
      WHEN 'S'.
        lv_tip_spec = 'Physical'.
      WHEN 'M'.
        lv_tip_spec = 'Metalurgical'.
    ENDCASE.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input   = ls_especificacao-cod_material
      IMPORTING
        output  = ls_especificacao-cod_material.

    "Busca valor descritivo
    CASE ls_especificacao-cod_material.
      WHEN '1'.
        lv_material = 'PBF/STD'.
      WHEN '2'.
        lv_material = 'PBF/MB45'.
      WHEN '3'.
        lv_material = 'PBF/HB'.
      WHEN '4'.
        lv_material = 'PDR/MX'.
      WHEN '5'.
        lv_material = 'PDR/MG'.
      WHEN '6'.
        lv_material = 'PDR/HY'.
      WHEN '7'.
        lv_material = 'PDR/HP'.
      WHEN '8'.
        lv_material = 'PDR/STD'.
      WHEN '9'.
        lv_material = 'PSC/STD'.
      WHEN '10'.
        lv_material = 'PFL/STD'.
      WHEN '11'.
        lv_material = 'PFN/STD'.
      WHEN '12'.
        lv_material = 'Others'.
    ENDCASE.

    "retira quebras de linha
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline
      IN ls_especificacao-dcr_penalidades
        WITH space.

    "Monta saída
    CONCATENATE ls_especificacao-aedat+6(2) '/'
                ls_especificacao-aedat+4(2) '/'
                ls_especificacao-aedat(4) INTO lv_date.

    "Monta saída
    CONCATENATE ls_especificacao-aezet(2) ':'
                ls_especificacao-aezet+2(2) ':'
                ls_especificacao-aezet+4(2) INTO lv_hour.

    lv_vl_min = ls_especificacao-vlr_garantido_min.
    CONDENSE lv_vl_min.
    lv_vl_max = ls_especificacao-vlr_garantido_max.
    CONDENSE lv_vl_max.

    CONCATENATE lv_material
                lv_tip_spec
                ls_especificacao-cod_especificacao
                ls_especificacao-vlr_tipico
                lv_vl_min
                lv_vl_max
                ls_especificacao-dcr_penalidades
                ls_especificacao-aenam
                lv_date
                lv_hour
                cl_abap_char_utilities=>newline
                INTO lv_linha
                SEPARATED BY cl_abap_char_utilities=>horizontal_tab.

    CONCATENATE lv_text lv_linha INTO lv_text.
  ENDLOOP.

  lv_encoding = '1100'.
  lv_app_type = 'APPLICATION/MSEXCEL;charset=utf-8'.

  CALL FUNCTION 'SCMS_STRING_TO_XSTRING'
    EXPORTING
      text     = lv_text
      encoding = lv_encoding
      mimetype = lv_app_type
    IMPORTING
      buffer   = lv_xstring
    EXCEPTIONS
      failed   = 1
      OTHERS   = 2.

  "Monta nome do Arquivo
  lv_name = 'Specifications'.
  CONCATENATE lv_name '_' sy-datum sy-uzeit '.xls' INTO lv_name.

  wdr_task=>client_window->client->attach_file_to_response(
                                  i_filename      = lv_name
                                  i_content       = lv_xstring
                                  i_mime_type     = 'APPLICATION/MSEXCEL'  ).
endmethod.