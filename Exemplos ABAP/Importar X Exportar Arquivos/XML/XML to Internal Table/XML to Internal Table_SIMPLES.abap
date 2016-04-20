filename = p_file .
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename            = filename
      filetype            = 'BIN'
      has_field_separator = ' '
      header_length       = 0
    IMPORTING
      filelength          = size
    TABLES
      data_tab            = xml_tab
    EXCEPTIONS
      OTHERS              = 1.

  CLEAR: result_xml[], result_xml.
  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length = size
    IMPORTING
      buffer       = xmldata
    TABLES
      binary_tab   = xml_tab
    EXCEPTIONS
      failed       = 1
      OTHERS       = 2.


  CALL FUNCTION 'SMUM_XML_PARSE'
    EXPORTING
      xml_input = xmldata
    TABLES
      xml_table = result_xml
      return    = return.