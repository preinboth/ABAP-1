*&---------------------------------------------------------------------*
*& Report  ZTESTE_DANY2
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

*report zteste_dany2 line-size 69 line-count 50(3) no standard page heading.
REPORT zteste_dany2.

*REPORT  ZSEND_MAIL_WITH_PDF.
*--------------------------------------------------------*
"  Data retrieval related declarations
*--------------------------------------------------------*
"Variables
DATA:
      g_spool_no TYPE tsp01-rqident.
"Types
TYPES:
      BEGIN OF t_emp_dat,
        pernr     TYPE pa0001-pernr,
        persg     TYPE pa0001-persg,
        persk     TYPE pa0001-persk,
        plans     TYPE pa0001-plans,
        stell     TYPE pa0001-stell,
      END OF t_emp_dat.
"Work area
DATA:
      w_emp_data  TYPE t_emp_dat.
"Internal tables
DATA:
      i_emp_data  TYPE STANDARD TABLE OF t_emp_dat.
*--------------------------------------------------------*
"  Mail related declarations
*--------------------------------------------------------*
"Variables
DATA :
    g_sent_to_all   TYPE sonv-flag,
    g_tab_lines     TYPE i.
"Types
TYPES:
    t_document_data  TYPE  sodocchgi1,
    t_packing_list   TYPE  sopcklsti1,
    t_attachment     TYPE  solisti1,
    t_body_msg       TYPE  solisti1,
    t_receivers      TYPE  somlreci1,
    t_pdf            TYPE  tline.
"Workareas
DATA :
    w_document_data  TYPE  t_document_data,
    w_packing_list   TYPE  t_packing_list,
    w_attachment     TYPE  t_attachment,
    w_body_msg       TYPE  t_body_msg,
    w_receivers      TYPE  t_receivers,
    w_pdf            TYPE  t_pdf.
"Internal Tables
DATA :
    i_document_data  TYPE STANDARD TABLE OF t_document_data,
    i_packing_list   TYPE STANDARD TABLE OF t_packing_list,
    i_attachment     TYPE STANDARD TABLE OF t_attachment,
    i_body_msg       TYPE STANDARD TABLE OF t_body_msg,
    i_receivers      TYPE STANDARD TABLE OF t_receivers,
    i_pdf            TYPE STANDARD TABLE OF t_pdf.
*--------------------------------------------------------*
"Selection Screen
*--------------------------------------------------------*
PARAMETERS p_mail TYPE char120.
*--------------------------------------------------------*
"Top-of-page.
*--------------------------------------------------------*
TOP-OF-PAGE.
  PERFORM top_of_page.

*--------------------------------------------------------*
  "Start-of-selection.
*--------------------------------------------------------*
START-OF-SELECTION.
  PERFORM get_data.
  IF i_emp_data[] IS INITIAL.
    PERFORM test_data.
  ENDIF.
  PERFORM do_print_n_get_spoolno.

*--------------------------------------------------------*
  "End-of-selection.
*--------------------------------------------------------*
END-OF-SELECTION.
  PERFORM send_mail.

*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
FORM top_of_page.
  DATA: inc_colnum TYPE i.
  ULINE.
  inc_colnum = sy-linsz - 60.
  WRITE: / 'Report: ', sy-repid(18).
  WRITE AT 30(inc_colnum) sy-title CENTERED.
  inc_colnum = sy-linsz - 20.
  WRITE: AT inc_colnum 'Page: ', (11) sy-pagno RIGHT-JUSTIFIED.
  WRITE: / 'Client: ', sy-mandt.
  inc_colnum = sy-linsz - 20.
  WRITE: AT inc_colnum 'Date: ', sy-datum.
  WRITE: / 'User  : ', sy-uname.
  inc_colnum = sy-linsz - 60.
  WRITE AT 30(inc_colnum) 'Company Confidential' CENTERED.
  inc_colnum = sy-linsz - 20.
  WRITE: AT inc_colnum 'Time: ', (10) sy-uzeit RIGHT-JUSTIFIED.
  ULINE .
  SKIP.
  ULINE AT /(127).
  WRITE:/ sy-vline,'pernr' COLOR COL_HEADING,13
  sy-vline,'persg' COLOR COL_HEADING,20
  sy-vline,'persk' COLOR COL_HEADING,26
  sy-vline,'plans' COLOR COL_HEADING,35
  sy-vline,'stell' COLOR COL_HEADING,46
  sy-vline.
  ULINE AT /(46).
ENDFORM.                    "top_of_page
*&--------------------------------------------------------*
"Form  get_data from PA0001
*&--------------------------------------------------------*
FORM get_data.

  SELECT pernr
  persg
  persk
  plans
  stell
  FROM pa0001
  INTO CORRESPONDING FIELDS OF TABLE i_emp_data
  UP TO 4 ROWS.

ENDFORM.                    " get_data
*&---------------------------------------------------------------------*
"Form  do_print_n_get_spoolno
*&---------------------------------------------------------------------*
FORM do_print_n_get_spoolno.

  "Display Output
  LOOP AT i_emp_data INTO w_emp_data .
    AT FIRST.
      PERFORM get_print_parameters.
    ENDAT.
    WRITE:/ sy-vline,w_emp_data-pernr,13
    sy-vline,w_emp_data-persg,20
    sy-vline,w_emp_data-persk,26
    sy-vline,w_emp_data-plans,35
    sy-vline,w_emp_data-stell,46
    sy-vline.
    ULINE AT /(46).
    AT LAST.
      g_spool_no  = sy-spono.
      NEW-PAGE PRINT OFF.
      CALL FUNCTION 'ABAP4_COMMIT_WORK'.
    ENDAT.
  ENDLOOP.

ENDFORM.                    "do_print_n_get_spoolno
*&----------------------------------------------------------*
"Form  send_mail
"---------------
"PACKING LIST
"This table requires information about how the data in the
"tables OBJECT_HEADER, CONTENTS_BIN and CONTENTS_TXT are to
"be distributed to the documents and its attachments.The first
"row is for the document, the following rows are each for one
"attachment.
*&-----------------------------------------------------------*
FORM send_mail .

  "Subject of the mail.
  w_document_data-obj_name  = 'MAIL_TO_HEAD'.
  w_document_data-obj_descr = 'Regarding Mail Program by SAP ABAP'.

  "Body of the mail
  PERFORM build_body_of_mail
  USING:space,
  'Hi,',
  'I am fine. How are you? How are you doing ? ',
  'This program has been created to send simple mail',
  'with Subject,Body with Address of the sender. ',
  'Regards,',
  'Venkat.O,',
  'SAP HR Technical Consultant.'.
  "Convert ABAP Spool job to PDF
  PERFORM convert_spool_2_pdf TABLES i_attachment.

  "Write Packing List for Body
  DESCRIBE TABLE i_body_msg LINES g_tab_lines.
  w_packing_list-head_start = 1.
  w_packing_list-head_num   = 0.
  w_packing_list-body_start = 1.
  w_packing_list-body_num   = g_tab_lines.
  w_packing_list-doc_type   = 'RAW'.
  APPEND w_packing_list TO i_packing_list.
  CLEAR  w_packing_list.

  "Write Packing List for Attachment
  w_packing_list-transf_bin = 'X'.
  w_packing_list-head_start = 1.
  w_packing_list-head_num   = 1.
  w_packing_list-body_start = 1.
  DESCRIBE TABLE i_attachment LINES w_packing_list-body_num.
  w_packing_list-doc_type   = 'PDF'.
  w_packing_list-obj_descr  = 'PDF Attachment'.
  w_packing_list-obj_name   = 'PDF_ATTACHMENT'.
  w_packing_list-doc_size   = w_packing_list-body_num * 255.
  APPEND w_packing_list TO i_packing_list.
  CLEAR  w_packing_list.

  "Fill the document data and get size of attachment
  w_document_data-obj_langu  = sy-langu.
  READ TABLE i_attachment INTO w_attachment INDEX g_tab_lines.
  w_document_data-doc_size = ( g_tab_lines - 1 ) * 255 + strlen( w_attachment ).

  "Receivers List.
  w_receivers-rec_type   = 'U'.  "Internet address
  w_receivers-receiver   = 'daniely.santos@megawork.com'.    "P_MAIL.
  w_receivers-com_type   = 'INT'.
  w_receivers-notif_del  = 'X'.
  w_receivers-notif_ndel = 'X'.
  APPEND w_receivers TO i_receivers .
  CLEAR:w_receivers.

  "Function module to send mail to Recipients
  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
    EXPORTING
      document_data              = w_document_data
      put_in_outbox              = 'X'
      commit_work                = 'X'
    IMPORTING
      sent_to_all                = g_sent_to_all
    TABLES
      packing_list               = i_packing_list
      contents_bin               = i_attachment
      contents_txt               = i_body_msg
      receivers                  = i_receivers
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.

  IF sy-subrc = 0 .
    MESSAGE i303(me) WITH 'Mail has been Successfully Sent.'.
  ELSE.
    WAIT UP TO 2 SECONDS.
    "This program starts the SAPconnect send process.
    SUBMIT rsconn01 WITH mode = 'INT'
    WITH output = 'X'
    AND RETURN.
  ENDIF.

ENDFORM.                    " send_mail
*&-----------------------------------------------------------*
"      Form  build_body_of_mail
*&-----------------------------------------------------------*
FORM build_body_of_mail  USING l_message.

  w_body_msg = l_message.
  APPEND w_body_msg TO i_body_msg.
  CLEAR  w_body_msg.

ENDFORM.                    " build_body_of_mail
*&---------------------------------------------------------------------*
*&      Form  get_print_parameters
*&---------------------------------------------------------------------*
FORM get_print_parameters .
  "Variables
  DATA:
  l_lay    TYPE pri_params-paart,
  l_lines  TYPE pri_params-linct,
  l_cols   TYPE pri_params-linsz,
  l_val    TYPE c.
*Types
  TYPES:
  t_pripar TYPE pri_params,
  t_arcpar TYPE arc_params.
  "Work areas
  DATA:
  lw_pripar TYPE t_pripar,
  lw_arcpar TYPE t_arcpar.

  l_lay   = 'X_65_132'.
  l_lines = 65.
  l_cols  = 132.
  "Read, determine, change spool print parameters and archive parameters
  CALL FUNCTION 'GET_PRINT_PARAMETERS'
    EXPORTING
      in_archive_parameters  = lw_arcpar
      in_parameters          = lw_pripar
      layout                 = l_lay
      line_count             = l_lines
      line_size              = l_cols
      no_dialog              = 'X'
    IMPORTING
      out_archive_parameters = lw_arcpar
      out_parameters         = lw_pripar
      valid                  = l_val
    EXCEPTIONS
      archive_info_not_found = 1
      invalid_print_params   = 2
      invalid_archive_params = 3
      OTHERS                 = 4.
  IF l_val NE space AND sy-subrc = 0.
    lw_pripar-prrel = space.
    lw_pripar-primm = space.
    NEW-PAGE PRINT ON
    NEW-SECTION
    PARAMETERS lw_pripar
    ARCHIVE PARAMETERS lw_arcpar
    NO DIALOG.
  ENDIF.
ENDFORM.                    " get_print_parameters
*&---------------------------------------------------------------------*
*&      Form  convert_spool_2_pdf
*&---------------------------------------------------------------------*
FORM convert_spool_2_pdf TABLES l_attachment .
  "Variables
  DATA:
  l_no_of_bytes TYPE i,
  l_pdf_spoolid LIKE tsp01-rqident,
  l_jobname     LIKE tbtcjob-jobname,
  l_jobcount    LIKE tbtcjob-jobcount.

  CALL FUNCTION 'CONVERT_ABAPSPOOLJOB_2_PDF'
    EXPORTING
      src_spoolid              = g_spool_no
      no_dialog                = ' '
    IMPORTING
      pdf_bytecount            = l_no_of_bytes
      pdf_spoolid              = l_pdf_spoolid
      btc_jobname              = l_jobname
      btc_jobcount             = l_jobcount
    TABLES
      pdf                      = i_pdf
    EXCEPTIONS
      err_no_abap_spooljob     = 1
      err_no_spooljob          = 2
      err_no_permission        = 3
      err_conv_not_possible    = 4
      err_bad_destdevice       = 5
      user_cancelled           = 6
      err_spoolerror           = 7
      err_temseerror           = 8
      err_btcjob_open_failed   = 9
      err_btcjob_submit_failed = 10
      err_btcjob_close_failed  = 11
      OTHERS                   = 12.

  CASE sy-subrc.
    WHEN 0.
    WHEN 1.
      MESSAGE s000(0k) WITH 'No ABAP Spool Job'.
      EXIT.
    WHEN 2.
      MESSAGE s000(0k) WITH 'Spool Number does not exist'.
      EXIT.
    WHEN 3.
      MESSAGE s000(0k) WITH 'No permission for spool'.
      EXIT.
    WHEN OTHERS.
      MESSAGE s000(0k)
      WITH 'Error in Function CONVERT_ABAPSPOOLJOB_2_PDF'.
      EXIT.
  ENDCASE.

  CALL FUNCTION 'SX_TABLE_LINE_WIDTH_CHANGE'
    EXPORTING
      line_width_src              = 134
      line_width_dst              = 255
    TABLES
      content_in                  = i_pdf
      content_out                 = l_attachment
    EXCEPTIONS
      err_line_width_src_too_long = 1
      err_line_width_dst_too_long = 2
      err_conv_failed             = 3
      OTHERS                      = 4.
  IF sy-subrc NE 0.
    MESSAGE s000(0k) WITH 'Conversion Failed'.
    EXIT.
  ENDIF.

ENDFORM.                    " convert_spool_2_pdf
*&---------------------------------------------------------------------*
*&      Form  test_data
*&---------------------------------------------------------------------*
FORM test_data .
  DO 10 TIMES.
    w_emp_data-pernr = sy-index.
    w_emp_data-persg = '2'.
    w_emp_data-persk = '93'.
    w_emp_data-plans = '99999999'.
    w_emp_data-stell = '31414144'.
    APPEND w_emp_data TO i_emp_data.
    CLEAR  w_emp_data.
  ENDDO.

ENDFORM.                    " test_data