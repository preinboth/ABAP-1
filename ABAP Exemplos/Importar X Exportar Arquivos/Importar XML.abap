TYPES: BEGIN OF ty_tab,
                caminho TYPE string,
                name TYPE string,
                value TYPE string,
       END OF ty_tab. 

DATA: itab    TYPE STANDARD TABLE OF ty_tab,
          ls_tab TYPE ty_tab.
 

DATA: result_xml TYPE STANDARD TABLE OF smum_xmltb,
      gs_result_xml TYPE smum_xmltb. 

  DATA: filename TYPE string ,
        xmldata TYPE xstring .

  DATA: return TYPE STANDARD TABLE OF bapiret2 .
  CONSTANTS: line_size TYPE i VALUE 255.
  DATA: BEGIN OF xml_tab OCCURS 0,
           raw(line_size) TYPE x,
        END   OF xml_tab,
        file  TYPE string,
        size  TYPE i.

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


  IF result_xml[] IS INITIAL.
    MESSAGE 'Não foi possivel Carregar XML' TYPE 'S' DISPLAY LIKE 'E'.
    STOP.
  ENDIF.

  LOOP AT result_xml ASSIGNING <fs_result>.
    TRANSLATE <fs_result>-cname TO UPPER CASE.
     ls_tab-name = <fs_result>-cname.
     ls_tab-value = <fs_result>-cvalue.
    APPEND ls_tabTO itab.
    CLEAR ls_tab.
  ENDLOOP. 