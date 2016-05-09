
DATA: it_table LIKE t001 OCCURS 0.

DATA: l_dom      TYPE REF TO if_ixml_element,
      m_document TYPE REF TO if_ixml_document,
      g_ixml     TYPE REF TO if_ixml,
      w_string   TYPE xstring,
      w_size     TYPE i,
      w_result   TYPE i,
      w_line     TYPE string,
      it_xml     TYPE dcxmllines,
      s_xml      LIKE LINE OF it_xml,
      w_rc       LIKE sy-subrc.

START-OF-SELECTION.
  SELECT * FROM t001 INTO TABLE it_table.

END-OF-SELECTION.
********************************************
*  initialize ixml-framework          ****
********************************************
  WRITE: / 'initialiazing iXML:'.
  CLASS cl_ixml DEFINITION LOAD.
  g_ixml = cl_ixml=>create( ).
  CHECK NOT g_ixml IS INITIAL.
  WRITE: 'ok'.

********************************************
*  CREATE dom from sap DATA           ****
********************************************
  WRITE: / 'creating iXML doc:'.
  m_document = g_ixml->create_document( ).
  CHECK NOT m_document IS INITIAL.
  WRITE: 'ok'.

  WRITE: / 'converting DATA TO DOM 1:'.
  CALL FUNCTION 'SDIXML_DATA_TO_DOM'
    EXPORTING
      name         = 'IT_TABLE'
      dataobject   = it_table[]
    IMPORTING
      data_as_dom  = l_dom
    CHANGING
      document     = m_document
    EXCEPTIONS
      illegal_name = 1
      OTHERS       = 2.
  IF sy-subrc = 0.
    WRITE  'ok'.
  ELSE.
    WRITE: 'Err =', sy-subrc.
  ENDIF.
  CHECK NOT l_dom IS INITIAL.

  WRITE: / 'appending DOM to iXML doc:'.
  w_rc = m_document->append_child( new_child = l_dom ).
  IF w_rc IS INITIAL.
    WRITE  'ok'.
  ELSE.
    WRITE: 'Err =', w_rc.
  ENDIF.

********************************************
*  visualize ixml (dom)               ****
********************************************
  WRITE: / 'displaying DOM:'.
  CALL FUNCTION 'SDIXML_DOM_TO_SCREEN'
    EXPORTING
      document    = m_document
    EXCEPTIONS
      no_document = 1
      OTHERS      = 2.
  IF sy-subrc = 0.
    WRITE  'ok'.
  ELSE.
    WRITE: 'Err =', sy-subrc.
  ENDIF.

********************************************
*  convert dom to xml doc (table)     ****
********************************************
  WRITE: / 'converting DOM TO XML:'.
  CALL FUNCTION 'SDIXML_DOM_TO_XML'
    EXPORTING
      document      = m_document
      pretty_print  = ' '
    IMPORTING
      xml_as_string = w_string
      size          = w_size
    TABLES
      xml_as_table  = it_xml
    EXCEPTIONS
      no_document   = 1
      OTHERS        = 2.
  IF sy-subrc = 0.
    WRITE  'ok'.
  ELSE.
    WRITE: 'Err =', sy-subrc.
  ENDIF.

  WRITE: / 'XML as string of size:', w_size, / w_string.

  DESCRIBE TABLE it_xml LINES w_result.
  WRITE: / 'XML as table of', w_result, 'lines:'..
  LOOP AT it_xml INTO s_xml.
    WRITE s_xml.
  ENDLOOP.

  WRITE: / 'end of processing'.