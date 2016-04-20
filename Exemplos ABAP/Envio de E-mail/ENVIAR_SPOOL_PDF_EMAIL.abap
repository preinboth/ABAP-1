Outro exemplo ZSDR017 na Samarco

***&-------------------------------------------------------------------*
***& Report  ZDANY_TESTE
***&
***&---------------------------------------------------------------------*
***&
***&
***&---------------------------------------------------------------------*
REPORT  ZDANY_TESTE LINE-SIZE 69 LINE-COUNT 50(3) NO STANDARD PAGE HEADING.
TABLES : vbak, vbap.
TYPES : BEGIN OF str_vbak,
          vbeln TYPE vbak-vbeln,
          erdat TYPE vbak-erdat,
          kunnr TYPE vbak-kunnr,
          netwr TYPE vbak-netwr,
          waerk TYPE vbak-waerk,
        END OF str_vbak.
TYPES : BEGIN OF str_vbap,
          vbeln TYPE vbap-vbeln,
          posnr TYPE vbap-posnr,
          matnr TYPE vbap-matnr,
          kwmeng TYPE vbap-kwmeng,
          meins TYPE vbap-meins,
        END OF str_vbap.
DATA : it_vbak TYPE TABLE OF str_vbak WITH HEADER LINE,
       wa_vbak TYPE str_vbak,
       it_vbap TYPE TABLE OF str_vbap WITH HEADER LINE.
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
SELECT-OPTIONS : s_vbeln FOR vbak-vbeln,
                 s_erdat FOR vbak-erdat.
PARAMETERS : po_email TYPE ad_smtpadr LOWER CASE.
SELECTION-SCREEN END OF BLOCK bl1.

TOP-OF-PAGE.
  PERFORM top_of_page.

START-OF-SELECTION.
*format color 7 INVERSE off.
  SET PF-STATUS 'PDF1'.
  PERFORM get_data.
  PERFORM print.

END-OF-PAGE.
  PERFORM end_of_page.

AT USER-COMMAND.
  CASE sy-ucomm.
    WHEN 'EMAIL'.
      PERFORM send_pdf.
  ENDCASE.
*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM top_of_page .
  FORMAT COLOR 1 INTENSIFIED ON.
  WRITE : / 'Sales Report' CENTERED.
  IF s_vbeln-high IS INITIAL.
    WRITE : / 'Sales report for sales order', s_vbeln-low.
  ELSE.
    WRITE : / 'Sales order report for sales orders from',
              s_vbeln-low,'to',s_vbeln-high.
  ENDIF.
  FORMAT COLOR 1 INTENSIFIED OFF.              " top_of_page
ENDFORM.                    " top_of_page
*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_data .
  SELECT vbeln erdat kunnr netwr waerk FROM vbak
          INTO CORRESPONDING FIELDS OF TABLE it_vbak
              WHERE vbeln IN s_vbeln
                AND erdat IN s_erdat.
  IF it_vbak[] IS NOT INITIAL.
    SELECT vbeln posnr matnr kwmeng meins
         FROM vbap
           INTO CORRESPONDING FIELDS OF TABLE it_vbap
            FOR ALL ENTRIES IN it_vbak
               WHERE vbeln = it_vbak-vbeln.
  ENDIF.
ENDFORM.                    " get_data
*&---------------------------------------------------------------------*
*&      Form  print
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print .
  LOOP AT it_vbak.
    AT FIRST.
      ULINE.
      FORMAT COLOR 4 ON.
      WRITE :/10 'VBELN',21 sy-vline,22 'ERDAT',33 sy-vline, 34 'KUNNR',
               45 sy-vline,46 'NETWR',62 sy-vline,63 'WAERK',69 sy-vline.
      ULINE.
      FORMAT COLOR 4 OFF.
    ENDAT.
    wa_vbak = it_vbak.
    AT NEW vbeln.
      WRITE : /10 wa_vbak-vbeln,21 sy-vline,22 wa_vbak-erdat,33 sy-vline, 34 wa_vbak-kunnr,
               45 sy-vline,46 wa_vbak-netwr,62 sy-vline,63 wa_vbak-waerk,69 sy-vline.
      ULINE.
      LOOP AT it_vbap WHERE vbeln = wa_vbak-vbeln.
        AT FIRST.
          FORMAT COLOR 5 ON.
          WRITE : /22 'POSNR',29 sy-vline,30 'MATNR',45 sy-vline,
                 46 'KWMENG',62 sy-vline,63 'MEINS',69 sy-vline.
          ULINE.
          FORMAT COLOR 5 OFF.
        ENDAT.
        WRITE : /22 it_vbap-posnr,29 sy-vline,30 it_vbap-matnr,45 sy-vline,
                 46 it_vbap-kwmeng,62 sy-vline,63 it_vbap-meins,69 sy-vline.
        AT LAST.
          ULINE.
        ENDAT.
      ENDLOOP.
      CLEAR wa_vbak.
    ENDAT.
    AT END OF vbeln.
      ULINE.
    ENDAT.
  ENDLOOP.
ENDFORM.                    " print
*&---------------------------------------------------------------------*
*&      Form  END_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM end_of_page .
  FORMAT COLOR 7 ON.
  ULINE.
  WRITE : / 'Page ended Page Number :',sy-pagno.
  FORMAT COLOR 7 OFF.
ENDFORM.                    " END_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  SEND_PDF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_pdf .
  DATA: l_params TYPE pri_params,
              l_valid TYPE string,
              w_spool_nr LIKE tsp01-rqident.
  DATA : it_pdf TYPE TABLE OF tline.
  DATA : it_pdfdata TYPE TABLE OF solisti1.
  DATA : wa_pdf TYPE tline,
     wa_pdfdata TYPE solisti1,
     i TYPE i,
     j TYPE i,
     k TYPE i,
     l TYPE i.
  DATA: li_objcont TYPE STANDARD TABLE OF solisti1,
        li_reclist TYPE STANDARD TABLE OF somlreci1,
        li_objpack TYPE STANDARD TABLE OF sopcklsti1,
        li_objhead TYPE STANDARD TABLE OF solisti1,
        li_content TYPE STANDARD TABLE OF solisti1,
        lwa_objcont TYPE solisti1,
        lwa_reclist TYPE somlreci1,
        lwa_objpack TYPE sopcklsti1,
        lwa_objhead TYPE solisti1,
        lwa_content TYPE solisti1,
        lwa_doc TYPE sodocchgi1,
        l_lines TYPE i,
        obj_list TYPE TABLE OF  abaplist,
        lwa_list TYPE abaplist.
  REFRESH: li_objcont[], li_reclist[],
            li_objpack[], li_objhead[],
            li_content[].
  CLEAR: lwa_objcont, lwa_reclist,
         lwa_objpack, lwa_objhead,
         lwa_content, lwa_doc.
**
  CALL FUNCTION 'GET_PRINT_PARAMETERS'
    EXPORTING
      no_dialog      = 'X'
    IMPORTING
      out_parameters = l_params
      valid          = l_valid.
  IF sy-subrc <> 0.
  ENDIF.
  DATA: BEGIN OF i_rsparams OCCURS 0.
          INCLUDE STRUCTURE rsparams.
  DATA: END OF i_rsparams.
  CALL FUNCTION 'RS_REFRESH_FROM_SELECTOPTIONS'
    EXPORTING
      curr_report     = sy-repid
    TABLES
      selection_table = i_rsparams.
  SUBMIT ZDANY_TESTE WITH SELECTION-TABLE i_rsparams
                               TO SAP-SPOOL
                               SPOOL PARAMETERS l_params
                               WITHOUT SPOOL DYNPRO
                               AND RETURN.
  SELECT MAX( rqident ) INTO w_spool_nr FROM tsp01
                             WHERE rqclient = sy-mandt
                             AND   rqowner  = sy-uname.
  CALL FUNCTION 'CONVERT_ABAPSPOOLJOB_2_PDF'
    EXPORTING
      src_spoolid = w_spool_nr
    TABLES
      pdf         = it_pdf.
* TO CONVERT TLINE WITH LENGHT 134 TO 255
  i = 134.          "LENGTH FOR TLINE IN PDF FORMAT.
  LOOP AT it_pdf INTO wa_pdf.
    MOVE wa_pdf(i) TO wa_pdfdata+j.
    j = j + i.
    IF j >= 255.         "255 LENGTH FOR solisti1
      APPEND wa_pdfdata TO it_pdfdata.
      CLEAR wa_pdfdata.
      CLEAR j.
      k = 134 - i.
      IF k > 0.
        MOVE wa_pdf+i(k) TO wa_pdfdata+0(k).
      ENDIF.
      j = j + k.
    ENDIF.
    l = j + i.
    IF l >= 255.
      i = 255 - j.
    ELSE.
      i = 134.
    ENDIF.
  ENDLOOP.
* END OF CONVERT.
  li_objcont[] = it_pdfdata[].
  lwa_reclist-receiver = po_email.
  lwa_reclist-rec_type = 'U'.
  APPEND lwa_reclist TO li_reclist.
  lwa_objhead = 'SEND OUTPUT AS PDF'.
  APPEND lwa_objhead TO li_objhead.
  lwa_content = 'Hi'.
  APPEND lwa_content TO li_content.
  CLEAR lwa_content.
  APPEND lwa_content TO li_content.
  lwa_content = 'Please find attached document as output in pdf format'. "test anmol
  APPEND lwa_content TO li_content.                                      "test anmol
  CLEAR l_lines.
  DESCRIBE TABLE li_content LINES l_lines.
  READ TABLE li_content INTO lwa_content INDEX l_lines.
  lwa_doc-doc_size = ( l_lines - 1 ) * 255 + strlen( lwa_content ).
  lwa_doc-obj_langu = 'E'.
  lwa_doc-obj_name = 'PDF OUTPUT'.
  lwa_doc-obj_descr = 'OUTPUT AS PDF'.
  CLEAR lwa_objpack-transf_bin.
  lwa_objpack-head_start = 1.
  lwa_objpack-head_num = 0.
  lwa_objpack-body_start = 1.
  lwa_objpack-body_num = l_lines.
  lwa_objpack-doc_type = 'RAW'.
  APPEND lwa_objpack TO li_objpack.
  CLEAR: lwa_objpack, l_lines.
  DESCRIBE TABLE li_objcont LINES l_lines.
  READ TABLE li_objcont INTO lwa_objcont INDEX l_lines.
  lwa_objpack-doc_size = ( l_lines - 1 ) * 255 + strlen( lwa_objcont ).
  lwa_objpack-transf_bin = 'X'.
  lwa_objpack-head_start = 1.
  lwa_objpack-head_num = 0.
  lwa_objpack-body_start = 1.
  lwa_objpack-body_num = l_lines.
  lwa_objpack-doc_type = 'PDF' .
  lwa_objpack-obj_name = 'PDF OUTPUT'.
  lwa_objpack-obj_descr = 'OUTPUT AS PDF'.
  APPEND lwa_objpack TO li_objpack.
*Sending the mail
  CALL FUNCTION 'SO_NEW_DOCUMENT_ATT_SEND_API1'
    EXPORTING
      document_data              = lwa_doc
      put_in_outbox              = 'X'
    TABLES
      packing_list               = li_objpack
      object_header              = li_objhead
      contents_bin               = li_objcont
      contents_txt               = li_content
      receivers                  = li_reclist
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      operation_no_authorization = 4
      OTHERS                     = 99.
  IF sy-subrc NE 0.
    WRITE:/ 'Document sending failed'.
  ELSE.
    WRITE:/ 'Document successfully sent'.
    COMMIT WORK.
  ENDIF.
ENDFORM.                    " SEND_PDF