TABLES:     ekko.

TYPE-POOLS: slis.                                 "ALV Declarations
*Data Declaration
*----------------
TYPES: BEGIN OF t_ekko,
  ebeln TYPE ekpo-ebeln,
  ebelp TYPE ekpo-ebelp,
  statu TYPE ekpo-statu,
  aedat TYPE ekpo-aedat,
  matnr TYPE ekpo-matnr,
  menge TYPE ekpo-menge,
  meins TYPE ekpo-meins,
  netpr TYPE ekpo-netpr,
  peinh TYPE ekpo-peinh,
 END OF t_ekko.

DATA: it_ekko TYPE STANDARD TABLE OF t_ekko INITIAL SIZE 0,
      wa_ekko TYPE t_ekko.

*ALV data declarations
DATA: fieldcatalog TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gd_tab_group TYPE slis_t_sp_group_alv,
      gd_layout    TYPE slis_layout_alv,
      gd_repid     LIKE sy-repid,
      gt_events     TYPE slis_t_event,
      gd_prntparams TYPE slis_print_alv.


************************************************************************
*Start-of-selection.
START-OF-SELECTION.

  PERFORM data_retrieval.
  PERFORM build_fieldcatalog.
  PERFORM build_layout.
  PERFORM build_events.
  PERFORM build_print_params.
  PERFORM display_alv_report.


*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*       Build Fieldcatalog for ALV Report
*----------------------------------------------------------------------*
FORM build_fieldcatalog.

* There are a number of ways to create a fieldcat.
* For the purpose of this example i will build the fieldcatalog manualy
* by populating the internal table fields individually and then
* appending the rows. This method can be the most time consuming but can
* also allow you  more control of the final product.

* Beware though, you need to ensure that all fields required are
* populated. When using some of functionality available via ALV, such as
* total. You may need to provide more information than if you were
* simply displaying the result
*               I.e. Field type may be required in-order for
*                    the 'TOTAL' function to work.

  fieldcatalog-fieldname   = 'EBELN'.
  fieldcatalog-seltext_m   = 'Purchase Order'.
  fieldcatalog-col_pos     = 0.
  fieldcatalog-outputlen   = 10.
  fieldcatalog-emphasize   = 'X'.
  fieldcatalog-key         = 'X'.
*  fieldcatalog-do_sum      = 'X'.
*  fieldcatalog-no_zero     = 'X'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'EBELP'.
  fieldcatalog-seltext_m   = 'PO Item'.
  fieldcatalog-col_pos     = 1.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'STATU'.
  fieldcatalog-seltext_m   = 'Status'.
  fieldcatalog-col_pos     = 2.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'AEDAT'.
  fieldcatalog-seltext_m   = 'Item change date'.
  fieldcatalog-col_pos     = 3.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'MATNR'.
  fieldcatalog-seltext_m   = 'Material Number'.
  fieldcatalog-col_pos     = 4.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'MENGE'.
  fieldcatalog-seltext_m   = 'PO quantity'.
  fieldcatalog-col_pos     = 5.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'MEINS'.
  fieldcatalog-seltext_m   = 'Order Unit'.
  fieldcatalog-col_pos     = 6.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'NETPR'.
  fieldcatalog-seltext_m   = 'Net Price'.
  fieldcatalog-col_pos     = 7.
  fieldcatalog-outputlen   = 15.
  fieldcatalog-datatype     = 'CURR'.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.

  fieldcatalog-fieldname   = 'PEINH'.
  fieldcatalog-seltext_m   = 'Price Unit'.
  fieldcatalog-col_pos     = 8.
  APPEND fieldcatalog TO fieldcatalog.
  CLEAR  fieldcatalog.
ENDFORM.                    " BUILD_FIELDCATALOG


*&---------------------------------------------------------------------*
*&      Form  BUILD_LAYOUT
*&---------------------------------------------------------------------*
*       Build layout for ALV grid report
*----------------------------------------------------------------------*
FORM build_layout.
  gd_layout-no_input          = 'X'.
  gd_layout-colwidth_optimize = 'X'.
  gd_layout-totals_text       = 'Totals'(201).
*  gd_layout-totals_only        = 'X'.
*  gd_layout-f2code            = 'DISP'.  "Sets fcode for when double
*                                         "click(press f2)
*  gd_layout-zebra             = 'X'.
*  gd_layout-group_change_edit = 'X'.
*  gd_layout-header_text       = 'helllllo'.
ENDFORM.                    " BUILD_LAYOUT


*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV_REPORT
*&---------------------------------------------------------------------*
*       Display report using ALV grid
*----------------------------------------------------------------------*
FORM display_alv_report.
  gd_repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = gd_repid
      i_callback_top_of_page  = 'TOP-OF-PAGE'  "see FORM
      i_callback_user_command = 'USER_COMMAND'
*     i_grid_title            = outtext
      is_layout               = gd_layout
      it_fieldcat             = fieldcatalog[]
*     it_special_groups       = gd_tabgroup
      it_events               = gt_events
      is_print                = gd_prntparams
      i_save                  = 'X'
*     is_variant              = z_template
    TABLES
      t_outtab                = it_ekko
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " DISPLAY_ALV_REPORT


*&---------------------------------------------------------------------*
*&      Form  DATA_RETRIEVAL
*&---------------------------------------------------------------------*
*       Retrieve data form EKPO table and populate itab it_ekko
*----------------------------------------------------------------------*
FORM data_retrieval.

  SELECT ebeln ebelp statu aedat matnr menge meins netpr peinh
   UP TO 10 ROWS
    FROM ekpo
    INTO TABLE it_ekko.
ENDFORM.                    " DATA_RETRIEVAL


*-------------------------------------------------------------------*
* Form  TOP-OF-PAGE                                                 *
*-------------------------------------------------------------------*
* ALV Report Header                                                 *
*-------------------------------------------------------------------*
FORM top-of-page.
*ALV Header declarations
  DATA: t_header TYPE slis_t_listheader,
        wa_header TYPE slis_listheader,
        t_line LIKE wa_header-info,
        ld_lines TYPE i,
        ld_linesc(10) TYPE c.

* Title
  wa_header-typ  = 'H'.

  wa_header-info = 'EKKO Table Report'.
  APPEND wa_header TO t_header.
  CLEAR wa_header.

* Date
  wa_header-typ  = 'S'.
  wa_header-key = 'Date: '.
  CONCATENATE  sy-datum+6(2) '.'
               sy-datum+4(2) '.'
               sy-datum(4) INTO wa_header-info.   "todays date
  APPEND wa_header TO t_header.
  CLEAR: wa_header.

* Total No. of Records Selected
  DESCRIBE TABLE it_ekko LINES ld_lines.
  ld_linesc = ld_lines.
  CONCATENATE 'Total No. of Records Selected: ' ld_linesc
                    INTO t_line SEPARATED BY space.
  wa_header-typ  = 'A'.
  wa_header-info = t_line.
  APPEND wa_header TO t_header.
  CLEAR: wa_header, t_line.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_header.
*            i_logo             = 'Z_LOGO'.
ENDFORM.                    "top-of-page


*------------------------------------------------------------------*
*       FORM USER_COMMAND                                          *
*------------------------------------------------------------------*
*       --> R_UCOMM                                                *
*       --> RS_SELFIELD                                            *
*------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                  rs_selfield TYPE slis_selfield.

* Check function code
  CASE r_ucomm.
    WHEN '&IC1'.
*   Check field clicked on within ALVgrid report
      IF rs_selfield-fieldname = 'EBELN'.
*     Read data table, using index of row user clicked on
        READ TABLE it_ekko INTO wa_ekko INDEX rs_selfield-tabindex.
*     Set parameter ID for transaction screen field
        SET PARAMETER ID 'BES' FIELD wa_ekko-ebeln.
*     Sxecute transaction ME23N, and skip initial data entry screen
        CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
      ENDIF.
  ENDCASE.
ENDFORM.                    "user_command


*&---------------------------------------------------------------------*
*&      Form  BUILD_EVENTS
*&---------------------------------------------------------------------*
*       Build events table
*----------------------------------------------------------------------*
FORM build_events.
  DATA: ls_event TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = gt_events[].
  READ TABLE gt_events WITH KEY name =  slis_ev_end_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE 'END_OF_PAGE' TO ls_event-form.
    APPEND ls_event TO gt_events.
  ENDIF.

  READ TABLE gt_events WITH KEY name =  slis_ev_end_of_list
                         INTO ls_event.
  IF sy-subrc = 0.
    MOVE 'END_OF_LIST' TO ls_event-form.
    APPEND ls_event TO gt_events.
  ENDIF.
ENDFORM.                    " BUILD_EVENTS


*&---------------------------------------------------------------------*
*&      Form  BUILD_PRINT_PARAMS
*&---------------------------------------------------------------------*
*       Setup print parameters
*----------------------------------------------------------------------*
FORM build_print_params.
  gd_prntparams-reserve_lines = '3'.   "Lines reserved for footer
  gd_prntparams-no_coverpage = 'X'.
ENDFORM.                    " BUILD_PRINT_PARAMS


*&---------------------------------------------------------------------*
*&      Form  END_OF_PAGE
*&---------------------------------------------------------------------*
FORM end_of_page.
  DATA: listwidth TYPE i,
        ld_pagepos(10) TYPE c,
        ld_page(10)    TYPE c.

  WRITE: sy-uline(50).
  SKIP.
  WRITE:/40 'Page:', sy-pagno .
ENDFORM.                    "END_OF_PAGE


*&---------------------------------------------------------------------*
*&      Form  END_OF_LIST
*&---------------------------------------------------------------------*
FORM end_of_list.
  DATA: listwidth TYPE i,
        ld_pagepos(10) TYPE c,
        ld_page(10)    TYPE c.

  SKIP.
  WRITE:/40 'Page:', sy-pagno .
ENDFORM.                    "END_OF_LIST