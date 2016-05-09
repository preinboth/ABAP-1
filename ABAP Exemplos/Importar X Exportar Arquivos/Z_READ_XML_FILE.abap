*&---------------------------------------------------------------------*
*& Report  Z_READ_XML_FILE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z_READ_XML_FILE.

PARAMETERS: p_filnam TYPE localfile OBLIGATORY DEFAULT 'C:\DADOS.xml'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_filnam.

  DATA: l_v_fieldname TYPE dynfnam.
  l_v_fieldname = p_filnam.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = l_v_fieldname
    IMPORTING
      file_name     = p_filnam.

START-OF-SELECTION.

  TYPES: BEGIN OF ty_tab,
                  caminho type string,
                  name TYPE string,
                  value TYPE string,
  END OF ty_tab.

  DATA: lcl_xml_doc     TYPE REF TO cl_xml_document,
        v_subrc         TYPE sysubrc,
        v_node          TYPE REF TO if_ixml_node,
        v_child_node    TYPE REF TO if_ixml_node,
        v_root          TYPE REF TO if_ixml_node,
        v_iterator      TYPE REF TO if_ixml_node_iterator,
        v_nodemap       TYPE REF TO if_ixml_named_node_map,
        v_count         TYPE i, v_index TYPE i,
        v_attr          TYPE REF TO if_ixml_node,
        v_name          TYPE string,
        v_prefix        TYPE string,
        v_value         TYPE string,
        v_char          TYPE char2.

  DATA: itab   TYPE STANDARD TABLE OF ty_tab,
        wa     TYPE ty_tab.

  CREATE OBJECT lcl_xml_doc.

  CALL METHOD lcl_xml_doc->import_from_file
    EXPORTING
      filename = p_filnam
    RECEIVING
      retcode  = v_subrc.

  CHECK v_subrc = 0.

        v_node = lcl_xml_doc->m_document.

        CHECK NOT v_node IS INITIAL.

              v_iterator = v_node->create_iterator( ).
              v_node = v_iterator->get_next( ).

              WHILE NOT v_node IS INITIAL.

                  CASE v_node->get_type( ).

                    WHEN if_ixml_node=>co_node_element.
                      v_name = v_node->get_name( ).
                      v_nodemap = v_node->get_attributes( ).

                      IF NOT v_nodemap IS INITIAL.

                        v_count = v_nodemap->get_length( ).
                        DO v_count TIMES.
                          v_index = sy-index - 1.
                          v_attr = v_nodemap->get_item( v_index ).
                          v_name = v_attr->get_name( ).
                          v_prefix = v_attr->get_namespace_prefix( ).
                          v_value = v_attr->get_value( ).
                        ENDDO.

                      ENDIF.

                    WHEN if_ixml_node=>co_node_text OR if_ixml_node=>co_node_cdata_section.

                      v_value = v_node->get_value( ).  " text node
                      MOVE v_value TO v_char.

                      IF v_char <> cl_abap_char_utilities=>cr_lf.

                        wa-name = v_name.
                        wa-value = v_value.

                        APPEND wa TO itab.
                        CLEAR wa.

                      ENDIF.

                  ENDCASE.

                  v_node = v_iterator->get_next( ).    " advance to next node

              ENDWHILE.


  LOOP AT itab INTO wa.

      WRITE: / wa-name,
               ': ',
               wa-value.

  ENDLOOP.
