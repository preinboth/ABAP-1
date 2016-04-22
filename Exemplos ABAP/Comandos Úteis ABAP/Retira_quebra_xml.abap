FUNCTION zf_ebusiness_retira_quebra_xml.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  CHANGING
*"     VALUE(XML_OUT) TYPE  STRING
*"----------------------------------------------------------------------

  DATA: v_url_char     TYPE url_char,
        v_url_char_ant TYPE url_char,
        v_url_code     TYPE url_code,
        v_pos          TYPE i,
        v_tam          TYPE i,
        xml_out_aux    TYPE string.

  CLEAR: v_pos,
         xml_out_aux,
         v_url_char_ant.

  v_tam = strlen( xml_out ).

  DO v_tam TIMES.
    CLEAR v_url_code.
    v_url_char = xml_out+v_pos(1).
    CALL FUNCTION 'URL_ASCII_CODE_GET'
      EXPORTING
        trans_char = v_url_char
      IMPORTING
        char_code  = v_url_code.
    IF v_url_code NE '0A'. "Quebra de linha
      IF sy-index GT 1 AND v_url_char_ant EQ space.
        CONCATENATE xml_out_aux v_url_char INTO xml_out_aux SEPARATED BY space.
      ELSE.
        CONCATENATE xml_out_aux v_url_char INTO xml_out_aux.
      ENDIF.
    ENDIF.
    v_url_char_ant = v_url_char.

    ADD 1 TO v_pos.
  ENDDO.

  xml_out = xml_out_aux.


ENDFUNCTION.