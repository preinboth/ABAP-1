# ABAP
Comandos básicos da linguagem Abap e suas aplicações.

<div class><pre>

**************************VARIÁVEIS PARA O POPUP DE SEEÇÃO DE ARQUIVOS

DATA it_files TYPE filetable.
DATA wa_files TYPE file_table.
DATA v_rc     TYPE i.

**************************VARIÁVEIS PARA O GUI UPLOAD
data lv_file  type string.


**************************TABELA E WA PARA O GUI UPLOAD
TYPES:BEGIN OF ty_arquivo,
 linha TYPE c LENGTH 2000,
END OF ty_arquivo.
*
DATA it_outdata TYPE STANDARD TABLE OF ty_arquivo WITH HEADER LINE.
data wa_outdata type ty_arquivo.


*********************** Definição de parametro de seleção
PARAMETERS p_file(1024) TYPE c.

********************* Evento para ativaro matchcode
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.


********************* metodo para exibir o popup de seleção de arquivos
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    CHANGING
      file_table              = it_files
      rc                      = v_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
               WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
************************** identifica o arquivo selecionado e joga para o parametro de seleção
    READ TABLE it_files INTO wa_files INDEX 1.
    p_file = wa_files-filename.
  ENDIF.

START-OF-SELECTION.

* Função para fazer upload e jogar para tabela Interna. Neste
* caso o tipo ASC é para arquivos TXT e excel.
* o tipo BIN é para word, pdf.

  lv_file = p_file.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
   filename                      = lv_file
   FILETYPE                      = 'ASC'
*   HAS_FIELD_SEPARATOR           = ' '
*   HEADER_LENGTH                 = 0
*   READ_BY_LINE                  = 'X'
*   DAT_MODE                      = ' '
*   CODEPAGE                      = ' '
*   IGNORE_CERR                   = ABAP_TRUE
*   REPLACEMENT                   = '#'
*   CHECK_BOM                     = ' '
*   VIRUS_SCAN_PROFILE            =
*   NO_AUTH_CHECK                 = ' '
* IMPORTING
*   FILELENGTH                    =
*   HEADER                        =
    TABLES
      data_tab                      = it_outdata
 EXCEPTIONS
   FILE_OPEN_ERROR               = 1
   FILE_READ_ERROR               = 2
   NO_BATCH                      = 3
   GUI_REFUSE_FILETRANSFER       = 4
   INVALID_TYPE                  = 5
   NO_AUTHORITY                  = 6
   UNKNOWN_ERROR                 = 7
   BAD_DATA_FORMAT               = 8
   HEADER_NOT_ALLOWED            = 9
   SEPARATOR_NOT_ALLOWED         = 10
   HEADER_TOO_LONG               = 11
   UNKNOWN_DP_ERROR              = 12
   ACCESS_DENIED                 = 13
   DP_OUT_OF_MEMORY              = 14
   DISK_FULL                     = 15
   DP_TIMEOUT                    = 16
   OTHERS                        = 17
            .
  IF sy-subrc NE 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
*

************************************  READ TABLE FAZ A LEITURA SOMENTE DE 1 LINHA, DE 1 ÚNICO REGISTRO
*READ TABLE it_outdata INTO WA_OUTDATA.
*WRITE WA_OUTDATA.


************************************* LOOP AT FAZ A LEITURA DE TODAS AS LINHAS, TODOS OS REGISTROS
LOOP AT it_outdata INTO wa_outdata.


DATA v_pais     TYPE string.
DATA v_codigo   TYPE string.
DATA v_banco    TYPE string.
DATA v_endereco TYPE string.
DATA v_estado   TYPE string.


***********************************SEPARANDO O TEXTO

SPLIT WA_OUTDATA AT ';' INTO v_pais
                             v_codigo
                             v_banco
                             v_endereco
                             v_estado.

CASE V_PAIS.
  WHEN 'BRA'.
    V_PAIS = 'BR'.
  WHEN 'USA'.
    v_pais = 'US'.
  ENDCASE.


WRITE: / v_pais, v_codigo, v_banco, v_endereco, v_estado.
ENDLOOP.
</pre></div>
___________
