FORM zf_download .

*Verificar essa função para fazer download de arquivos no lugar de usar a função GUI_DOWNLOAD
*Endereço Básico Exemplo adquirido do report ZFIR0021 da Cesan
  CALL FUNCTION 'WS_DOWNLOAD'
    EXPORTING
      filename                = p_end
      filetype                = 'DAT'
    TABLES
      data_tab                = t_nivel
    EXCEPTIONS
      file_open_error         = 1
      file_write_error        = 2
      invalid_filesize        = 3
      invalid_type            = 4
      no_batch                = 5
      unknown_error           = 6
      invalid_table_width     = 7
      gui_refuse_filetransfer = 8
      customer_error          = 9
      OTHERS                  = 10.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " ZF_DOWNLOAD
