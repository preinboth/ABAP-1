************************************************************************
** PROJETO            : Disponibilidade de Equipamento                 *
** PROGRAMA           : ZRTABLE_IMPORT                                 *
** TRANSACAO          :                                                *
** DESCRICAO          :                                                *
**                                                                     *
** xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx *
**                                                                     *
** AUTOR              : Victor Tozzatto                                *
** DATA               : 24.02.2014                                     *
**---------------------------------------------------------------------*
**                      HISTORICO DE MUDANCAS                          *
**---------------------------------------------------------------------*
** NUM.  DATA        AUTOR          REQUEST      DESCRICAO             *
**---------------------------------------------------------------------*
REPORT  zrtable_import.

**---------------------------------------------------------------------*
**   Tabelas                                                           *
**---------------------------------------------------------------------*
TABLES: rsrd1.

**---------------------------------------------------------------------*
**   Tipos                                                             *
**---------------------------------------------------------------------*
*TYPE-POOLS icon.
**---------------------------------------------------------------------*
**   Constantes                                                        *
**---------------------------------------------------------------------*
*CONSTANTS: c_x(1)  TYPE c VALUE 'X'.
***---------------------------------------------------------------------*
***   Tabelas internas globais                                          *
***---------------------------------------------------------------------*
DATA: gt_fields   TYPE STANDARD TABLE OF rfc_db_fld,
      gt_data     TYPE STANDARD TABLE OF tab512.

DATA: gt_generic_table  TYPE REF TO data,
      gt_fieldcat TYPE lvc_t_fcat.

DATA: gt_table_aux TYPE STANDARD TABLE OF string.
***---------------------------------------------------------------------*
***   Estrutura globais                                                 *
***---------------------------------------------------------------------*

DATA: gs_data      LIKE LINE OF gt_data,
      gs_fields    LIKE LINE OF gt_fields,
      gs_table_aux LIKE LINE OF gt_table_aux.

DATA: gs_line TYPE REF TO data.

***---------------------------------------------------------------------*
***   Variaveis globais                                                 *
***---------------------------------------------------------------------*
FIELD-SYMBOLS: <fs_table> TYPE STANDARD TABLE,
               <fs_line>  TYPE any,
               <fs_field> TYPE any.

DATA: gv_index   TYPE i,
      gv_objname TYPE ddobjname.

***---------------------------------------------------------------------*
***   Parametros de selecao                                             *
***---------------------------------------------------------------------*
*
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME.

PARAMETERS: p_ssyst TYPE ccprof-source_sys.
SELECT-OPTIONS: p_table FOR rsrd1-tbma_val NO INTERVALS.

SELECTION-SCREEN: END OF BLOCK b1.
***---------------------------------------------------------------------*
***   Acoes de tela                                                     *
***---------------------------------------------------------------------*
***---------------------------------------------------------------------*
***   Selecao inicial                                                   *
***---------------------------------------------------------------------*
START-OF-SELECTION.
  LOOP AT p_table.

    REFRESH: gt_data, gt_fieldcat, gt_fields, gt_table_aux.

    gv_objname = p_table-low.

    PERFORM f_define_structure.
    PERFORM f_retrieve_data.
    PERFORM f_show_results.
  ENDLOOP.

***---------------------------------------------------------------------*
***   Assist Performs                                                   *
***---------------------------------------------------------------------*
**&---------------------------------------------------------------------*
**&      Form  F_DEFINE_STRUCTURE
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
FORM f_define_structure.

  CALL METHOD zcl_table_assist=>assist_report_structure
    EXPORTING
      structure_name      = gv_objname
    IMPORTING
      field_catalog       = gt_fieldcat
    EXCEPTIONS
      structure_not_found = 1
      OTHERS              = 2.

ENDFORM.                    " F_DEFINE_STRUCTURE
**&---------------------------------------------------------------------*
**&      Form  F_RETRIEVE_DATA
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
FORM f_retrieve_data.

  CALL FUNCTION 'RFC_READ_TABLE' DESTINATION p_ssyst
    EXPORTING
      query_table          = gv_objname
      delimiter            = '|'
    TABLES
      fields               = gt_fields
      data                 = gt_data
    EXCEPTIONS
      table_not_available  = 1
      table_without_data   = 2
      option_not_valid     = 3
      field_not_valid      = 4
      not_authorized       = 5
      data_buffer_exceeded = 6
      OTHERS               = 7.
  IF sy-subrc <> 0.
    CASE sy-subrc.
      WHEN 1 OR 2.
        MESSAGE text-001 TYPE 'E'.
      WHEN 5.
        MESSAGE text-002 TYPE 'E'.
      WHEN OTHERS.
        MESSAGE text-003 TYPE 'E'.
    ENDCASE.
  ENDIF.

  CALL METHOD cl_alv_table_create=>create_dynamic_table
    EXPORTING
      i_style_table             = ' '
      it_fieldcatalog           = gt_fieldcat
    IMPORTING
      ep_table                  = gt_generic_table
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.

  ASSIGN gt_generic_table->* TO <fs_table>.
  CREATE DATA gs_line LIKE LINE OF <fs_table>.
  ASSIGN gs_line->* TO <fs_line>.

  LOOP AT gt_data INTO gs_data.

    CREATE DATA gs_line LIKE LINE OF <fs_table>.
    ASSIGN gs_line->* TO <fs_line>.

    SPLIT gs_data-wa AT '|' INTO TABLE gt_table_aux.

    LOOP AT gt_fields INTO gs_fields.
      gv_index = sy-tabix.

      CLEAR: gs_table_aux.

      ASSIGN COMPONENT gs_fields-fieldname OF STRUCTURE <fs_line> TO <fs_field>.

      READ TABLE gt_table_aux INTO gs_table_aux INDEX gv_index.
      CONDENSE gs_table_aux.
      IF gs_fields-fieldname EQ 'MANDT'.
        <fs_field> = sy-mandt.
      ELSE.
        <fs_field> = gs_table_aux.
      ENDIF.

    ENDLOOP.

    APPEND <fs_line> TO <fs_table>.
  ENDLOOP.

  DELETE FROM (gv_objname).
  INSERT (gv_objname) FROM TABLE <fs_table>.

ENDFORM.                    " F_RETRIEVE_DATA
*&---------------------------------------------------------------------*
*&      Form  F_SHOW_RESULTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_show_results.

  SKIP.
  SKIP.
  WRITE AT / gv_objname.
  ULINE.
  LOOP AT gt_data INTO gs_data.
    WRITE gs_data-wa.
  ENDLOOP.

ENDFORM.                    " F_SHOW_RESULTS
