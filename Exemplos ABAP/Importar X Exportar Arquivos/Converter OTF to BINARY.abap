
  DATA: v_pdf_xstring      TYPE xstring,
        v_pdf_string       TYPE string,
        v_string           TYPE string,
        it_pdf_tab         TYPE STANDARD TABLE OF tline,
        bin_size           TYPE i,
        it_att_content_hex TYPE TABLE OF x,
        v_md5_out          TYPE string,
        v_id_doc           TYPE char10,
        v_bsunit           TYPE zconst0001-low,
        v_bs_aux           TYPE string,
        lv_ok              TYPE c,
        lv_user            TYPE sy-uname,
        lv_length          TYPE i.


  CHECK lv_ok IS NOT INITIAL.
*.........................CONVERT FROM OTF TO PDF.......................*
  CALL FUNCTION 'CONVERT_OTF'
    EXPORTING
      format                = 'PDF'
    IMPORTING
      bin_file              = v_pdf_xstring
    TABLES
      otf                   = p_job_output_info-otfdata
      lines                 = it_pdf_tab
    EXCEPTIONS
      err_max_linewidth     = 1
      err_format            = 2
      err_conv_not_possible = 3
      OTHERS                = 4.

  CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
    EXPORTING
      buffer        = v_pdf_xstring
    IMPORTING
      output_length = bin_size
    TABLES
      binary_tab    = it_att_content_hex.

* 10/12/2013 - Anexos -INI
* Converter binário para string
  CALL FUNCTION 'SCMS_BINARY_TO_STRING'
    EXPORTING
      input_length  = bin_size
    IMPORTING
      text_buffer   = v_pdf_string
      output_length = lv_length
    TABLES
      binary_tab    = it_att_content_hex
    EXCEPTIONS
      failed        = 1
      OTHERS        = 2.
* 10/12/2013 - Anexos -FIM