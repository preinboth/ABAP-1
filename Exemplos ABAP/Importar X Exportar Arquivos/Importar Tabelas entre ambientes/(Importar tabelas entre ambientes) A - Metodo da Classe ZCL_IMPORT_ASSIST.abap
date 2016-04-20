METHOD assist_report_structure.

**---------------------------------------------------------------------*
**     Tabelas internas                                                *
**---------------------------------------------------------------------*
  DATA: lt_fields   TYPE ddfields,
        lt_fcat     TYPE lvc_t_fcat,
        lt_fcat_alv TYPE slis_t_fieldcat_alv.
*
*
**---------------------------------------------------------------------*
**     Estrutura                                                       *
**---------------------------------------------------------------------*
  DATA: ls_fcat     TYPE lvc_s_fcat,
        ls_fields   LIKE LINE OF lt_fields,
        ls_fcat_alv LIKE LINE OF lt_fcat_alv.
*
*
*----------------------------------------------------------------------*
*      Variaveis                                                       *
*----------------------------------------------------------------------*
  DATA: lv_index  TYPE i.
*
*
  IF fields IS NOT SUPPLIED.
    CALL FUNCTION 'CATSXT_GET_DDIC_FIELDINFO'
      EXPORTING
        im_structure_name = structure_name
      IMPORTING
        ex_ddic_info      = lt_fields
      EXCEPTIONS
        failed            = 1
        OTHERS            = 2.

    IF sy-subrc <> 0.
      RAISE structure_not_found.
    ENDIF.
  ELSE.
    lt_fields[] = fields[].
  ENDIF.



  LOOP AT lt_fields INTO ls_fields.

    CLEAR: ls_fcat, ls_fcat_alv.

    lv_index = lv_index + 1.

    MOVE-CORRESPONDING:  ls_fields TO ls_fcat_alv,
                         ls_fields TO ls_fcat.

    MOVE: ls_fields-fieldname TO ls_fcat_alv-fieldname,
          ls_fields-fieldname TO ls_fcat-fieldname.

    IF ls_fields-scrtext_m IS NOT INITIAL.
      ls_fcat-coltext   = ls_fields-scrtext_m.
    ELSEIF ls_fields-scrtext_l IS NOT INITIAL.
      ls_fcat-coltext   = ls_fields-scrtext_l.
    ELSEIF ls_fields-scrtext_s IS NOT INITIAL.
      ls_fcat-coltext   = ls_fields-scrtext_s.
    ELSEIF ls_fields-fieldtext IS NOT INITIAL.
      ls_fcat-coltext   = ls_fields-fieldtext.
    ENDIF.

    ls_fcat-intlen = ls_fcat-outputlen.

    ls_fcat_alv-seltext_l = ls_fcat-coltext.

    ls_fcat_alv-col_pos   = lv_index.
    ls_fcat-col_pos       = lv_index.
    ls_fcat-key           = ls_fields-keyflag.

    APPEND: ls_fcat TO lt_fcat,
            ls_fcat_alv TO lt_fcat_alv.
  ENDLOOP.

  field_catalog[] = lt_fcat[].
  field_catalog_alv[] = lt_fcat_alv[].

ENDMETHOD.
