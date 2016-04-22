*&---------------------------------------------------------------------*
*& Report  ZPMR050
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zpmr050.


INCLUDE ole2incl.

FIELD-SYMBOLS <fs>.

DATA: BEGIN OF ti_dados OCCURS 0,
        tipo      TYPE c LENGTH 4,
        objeto    TYPE c LENGTH 60,
        categoria TYPE c LENGTH 2,
        contador  TYPE c LENGTH 2,
  "INI  - DRG - 2629760
*        item      TYPE c LENGTH 10,
        item      TYPE c LENGTH 30,
  "FIM  - DRG - 2629760
        descricao TYPE c LENGTH 100,
  "INI  - DRG - 2629760
*        caract    TYPE c LENGTH 20,
        caract    TYPE c LENGTH 30,
  "FIM  - DRG - 2629760
        exp       TYPE c LENGTH 5,
        grupo     TYPE c LENGTH 10,
        avalia    TYPE c LENGTH 5,
        conjunto  TYPE c LENGTH 5,
        valor     TYPE c LENGTH 20,
        marca     TYPE c LENGTH 10,
        atividade TYPE c LENGTH 10,
        texto     TYPE c LENGTH 50,
        cont      TYPE c LENGTH 5,
        limsup    TYPE c LENGTH 5,
        liminf    TYPE c LENGTH 5.
DATA: END OF ti_dados.

DATA: BEGIN OF ti_coluna OCCURS 0,
      numero LIKE alsmex_tabline-col,
      descricao(40) TYPE c.
DATA: END OF ti_coluna.

DATA: BEGIN OF ti_log OCCURS 0,
          objeto    TYPE c LENGTH 60,
          mensagem  TYPE c LENGTH 100,
          linha     TYPE i,
          status(6) TYPE c.
DATA: END OF ti_log.

DATA: tg_fieldcat         TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      ls_fieldcat         TYPE slis_fieldcat_alv,
      vg_layout           TYPE slis_layout_alv,
      gs_variant          TYPE disvariant,
      gt_event_exit       TYPE STANDARD TABLE OF slis_event_exit,
      vg_print            TYPE slis_print_alv,
      vg_repid            TYPE sy-repid,
      gt_list_top_of_page TYPE slis_t_listheader.

DATA: t_bdcdata  LIKE bdcdata    OCCURS 0 WITH HEADER LINE, "Tabela para batch input
      t_bdcmsg   LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE, "Tabela de mensagem do batch input
      t_msg      LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.


DATA: ti_xls LIKE alsmex_tabline OCCURS 0 WITH HEADER LINE,
      v_mode       TYPE c VALUE 'N',
      vg_field(20) TYPE c.

CONSTANTS: c_ok(6)  TYPE c VALUE 'Ok',
           c_nok(6) TYPE c VALUE 'Não Ok'.

PARAMETERS: p_file TYPE rlgrap-filename.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CLEAR : p_file.

  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'                     "#EC *
    EXPORTING
      static        = ' '
      mask          = '*.xls'
    CHANGING
      file_name     = p_file
    EXCEPTIONS
      mask_too_long = 1
      OTHERS        = 2.


INITIALIZATION.

  FREE ti_coluna.

  ti_coluna-numero    = '0001'.
  ti_coluna-descricao = 'TIPO'.
  APPEND ti_coluna.

  ti_coluna-numero    = '0002'.
  ti_coluna-descricao = 'OBJETO'.
  APPEND ti_coluna.

  ti_coluna-numero    = '0003'.
  ti_coluna-descricao = 'CATEGORIA'.
  APPEND ti_coluna.

  ti_coluna-numero    = '0004'.
  ti_coluna-descricao = 'CONTADOR'.
  APPEND ti_coluna.

  ti_coluna-numero    = '0005'.
  ti_coluna-descricao = 'ITEM'.
  APPEND ti_coluna.


  ti_coluna-numero    = '0006'.
  ti_coluna-descricao = 'DESCRICAO'.
  APPEND ti_coluna.

  ti_coluna-numero    = '0007'.
  ti_coluna-descricao = 'CARACT'.
  APPEND ti_coluna.

  ti_coluna-numero    = '0008'.
  ti_coluna-descricao = 'EXP'.
  APPEND ti_coluna.

  ti_coluna-numero    = '0009'.
  ti_coluna-descricao = 'GRUPO'.
  APPEND ti_coluna.

  ti_coluna-numero    = '0010'.
  ti_coluna-descricao = 'AVALIA'.
  APPEND ti_coluna.

  ti_coluna-numero    = '0011'.
  ti_coluna-descricao = 'CONJUNTO'.
  APPEND ti_coluna.

  ti_coluna-numero    = '0012'.
  ti_coluna-descricao = 'VALOR'.
  APPEND ti_coluna.

  ti_coluna-numero    = '0013'.
  ti_coluna-descricao = 'MARCA'.
  APPEND ti_coluna.

  ti_coluna-numero    = '0014'.
  ti_coluna-descricao = 'ATIVIDADE'.
  APPEND ti_coluna.

  ti_coluna-numero    = '0015'.
  ti_coluna-descricao = 'TEXTO'.
  APPEND ti_coluna.
  ti_coluna-numero    = '0016'.
  ti_coluna-descricao = 'CONT'.
  APPEND ti_coluna.
  ti_coluna-numero    = '0017'.
  ti_coluna-descricao = 'LIMSUP'.
  APPEND ti_coluna.
  ti_coluna-numero    = '0018'.
  ti_coluna-descricao = 'LIMINF'.
  APPEND ti_coluna.


START-OF-SELECTION.

  PERFORM f_importar_arquivo.
  PERFORM f_processar_erros.

  "INI - Megawork - 14/10/2014 - 45428833 - DRG
*  IF ti_log[] IS INITIAL.
  PERFORM f_processar.
*  ENDIF.
  "FIM - Megawork - 14/10/2014 - 45428833 - DRG
  PERFORM f_print_relatorio_alv.


*&---------------------------------------------------------------------*
*&      Form  F_IMPORTAR_ARQUIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_importar_arquivo .

  "INI  - DRG - 2629760
  DATA: lv_start_row TYPE i,
        lv_end_row   TYPE i,
        lv_num_lines TYPE i.

  lv_start_row = 2.
  lv_end_row   = 9999.
  "FIM  - DRG - 2629760

  REFRESH ti_dados.
  DO.
    CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
      EXPORTING
        filename                = p_file
        i_begin_col             = '1'
        i_begin_row             = lv_start_row
        i_end_col               = '18'
                       "INI - Megawork - 16/10/2014 - 45428833 - DRG
                           "Permite ler mais que 4 linhas
*       i_end_row               = '5'
        i_end_row               = lv_end_row
                       "FIM - Megawork - 16/10/2014 - 45428833 - DRG
      TABLES
        intern                  = ti_xls
      EXCEPTIONS
        inconsistent_parameters = 1
        upload_ole              = 2
        OTHERS                  = 3.

    SORT ti_xls BY row col.
    CLEAR ti_dados.

    LOOP AT ti_xls.
      AT NEW row.
        CLEAR ti_dados.
      ENDAT.
      READ TABLE ti_coluna WITH KEY numero = ti_xls-col.
      CHECK sy-subrc = 0.
      CONCATENATE 'TI_DADOS-' ti_coluna-descricao INTO vg_field.
      ASSIGN (vg_field) TO <fs>.
      IF ti_xls-col = 7 OR
         ti_xls-col = 13.
        TRANSLATE ti_xls-value USING ',.'.
      ENDIF.
      <fs> = ti_xls-value.
      AT END OF row.
        APPEND ti_dados.
      ENDAT.
    ENDLOOP.

    "INI  - DRG - 2629760
    lv_num_lines = lines( ti_dados ).
    IF lv_num_lines >= lv_end_row.
      lv_start_row = lv_end_row + 1.
      lv_end_row   = lv_start_row + 9998.
    ELSE.
      EXIT.
    ENDIF.
    "FIM  - DRG - 2629760

  ENDDO.

ENDFORM.                    " F_IMPORTAR_ARQUIVO
*&---------------------------------------------------------------------*
*&      Form  f_add_line
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_START    text
*      -->P_NAME     text
*      -->P_VALUE    text
*----------------------------------------------------------------------*
FORM f_add_line USING  p_start TYPE c
                       p_name  TYPE c
                       p_value TYPE any.

  DATA: vl_tipo TYPE c.

  CLEAR t_bdcdata.
  MOVE  p_start  TO  t_bdcdata-dynbegin.

  IF  p_start EQ 'X'.
    MOVE:  p_name  TO  t_bdcdata-program,
           p_value TO  t_bdcdata-dynpro.
  ELSE.
    MOVE  p_name   TO  t_bdcdata-fnam.
    MOVE  p_value  TO  t_bdcdata-fval.
  ENDIF.

  APPEND t_bdcdata.

ENDFORM.                               "F_ADD_LINE

*&---------------------------------------------------------------------*
*&      Form  F_PROCESSAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_processar_erros .
  CLEAR: ti_log[], ti_log.

  "INI - Megawork - 16/10/2014 - 45428833 - DRG
  DATA: l_line TYPE i.
  "FIM - Megawork - 16/10/2014 - 45428833 - DRG

  LOOP AT ti_dados.
    "INI - Megawork - 16/10/2014 - 45428833 - DRG
    l_line = l_line + 1.
    "FIM - Megawork - 16/10/2014 - 45428833 - DRG


    IF ti_dados-tipo EQ 'IEQ'.
      IF ti_dados-objeto+1(3) EQ '_'.
        ti_log-objeto = ti_dados-objeto.
        ti_log-mensagem = 'Tipo de carga incompatível com o objeto'.
        "INI - Megawork - 16/10/2014 - 45428833 - DRG
        ti_log-linha = l_line.
        ti_log-status = c_nok.
        "FIM - Megawork - 16/10/2014 - 45428833 - DRG
        APPEND ti_log.
        CONTINUE.
      ENDIF.
    ELSEIF ti_dados-tipo EQ 'IFL'.
      IF ti_dados-objeto EQ '_'.
        ti_log-objeto = ti_dados-objeto.
        ti_log-mensagem = 'Tipo de carga incompatível com o objeto'.
        "INI - Megawork - 16/10/2014 - 45428833 - DRG
        ti_log-linha = l_line.
        ti_log-status = c_nok.
        "FIM - Megawork - 16/10/2014 - 45428833 - DRG
        APPEND ti_log.
        CONTINUE.
      ENDIF.
    ENDIF.
*    IF ti_dados-contador EQ 'S'.
*  "INI - Megawork - 16/10/2014 - 45428833 - DRG
**      IF ti_dados-marca <> ti_dados-valor OR ti_dados-atividade <> ti_dados-valor.
*      IF ti_dados-marca <> ti_dados-valor AND ti_dados-atividade <> ti_dados-valor.
*        ti_log-objeto = ti_dados-objeto.
**        ti_log-mensagem = 'Contador com campos  Marca_Salto ou Atividade_Atual incorretos'.
*        ti_log-mensagem = 'Contador deve ter campos Marca_Salto e/ou Atividade_Atual preenchidos'.
*        ti_log-linha = l_line.
*  "FIM - Megawork - 16/10/2014 - 45428833 - DRG
*        APPEND ti_log.
*        CONTINUE.
*      ENDIF.
*    ENDIF.
    IF ti_dados-item IS INITIAL OR ti_dados-descricao IS INITIAL.
      ti_log-objeto = ti_dados-objeto.
      ti_log-mensagem = 'Ítem ou Descrição Ítem não preenchidos'.
      "INI - Megawork - 16/10/2014 - 45428833 - DRG
      ti_log-linha = l_line.
      ti_log-status = c_nok.
      "FIM - Megawork - 16/10/2014 - 45428833 - DRG
      APPEND ti_log.
      CONTINUE.
    ENDIF.
    IF ti_dados-caract IS INITIAL.
      ti_log-objeto = ti_dados-objeto.
      ti_log-mensagem = 'Característica não preenchida'.
      "INI - Megawork - 16/10/2014 - 45428833 - DRG
      ti_log-linha = l_line.
      ti_log-status = c_nok.
      "FIM - Megawork - 16/10/2014 - 45428833 - DRG
      APPEND ti_log.
      CONTINUE.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " F_PROCESSAR
*&---------------------------------------------------------------------*
*&      Form  F_PROCESSAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_processar .
  DATA: lv_m_id TYPE sy-msgid,
        lv_m_nr TYPE sy-msgno,
        lv_m_v1 TYPE sy-msgv1,
        lv_m_v2 TYPE sy-msgv2,
        lv_m_v3 TYPE sy-msgv3,
        lv_m_v4 TYPE sy-msgv4,
        lv_m_tx TYPE sy-lisel.

  "INI - Megawork - 16/10/2014 - 45428833 - DRG
  DATA: l_line TYPE i.
  "FIM - Megawork - 16/10/2014 - 45428833 - DRG

  LOOP AT ti_dados.
    "INI - Megawork - 14/10/2014 - 45428833 - DRG
    l_line = l_line + 1.

    IF ti_log[] IS NOT INITIAL.
      READ TABLE ti_log WITH KEY linha = l_line.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.
    ENDIF.

    TRANSLATE ti_dados-marca USING '.,'.
    "FIM - Megawork - 14/10/2014 - 45428833 - DRG

    CLEAR: t_bdcdata[], t_bdcdata.
    IF ti_dados-tipo EQ 'IEQ'.

      IF ti_dados-contador EQ 'S'.
        " Executar Carga de Ponto Medição Equipamento (Utilizar registro SHDB: IK01_IEQ)
        PERFORM f_add_line USING: 'X' 'SAPLIMR0'              '1110',
                                  ' ' 'BDC_CURSOR'            'IMPT-INDCT',
                                  ' ' 'BDC_OKCODE'           	'=HOLD',
                                  ' ' 'RIMR0-MPOTY'           ti_dados-tipo,
                                  ' ' 'IMPT-MPTYP'            ti_dados-categoria.

        PERFORM f_add_line USING: 'X' 'SAPLIMR0'              '1110',
                                  ' ' 'BDC_CURSOR'            'IMPT-INDCT',
                                  ' ' 'BDC_OKCODE'            '/00',
                                  ' ' 'IMPT-INDCT'            'X',
                                  ' ' 'EQUI-EQUNR'            ti_dados-objeto.
        PERFORM f_add_line USING:
                                 'X' 'SAPLIMR0'              '5110',
                                 ' ' 'BDC_CURSOR'            'IMPT-ATNAM',
*                                 ' ' 'BDC_OKCODE'            '=BU',  " GS 2481542
                                 ' ' 'BDC_OKCODE'            '=ADPT', " GS 2481542
                                 ' ' 'IMPT-PSORT'             ti_dados-item,
                                 ' ' 'IMPT-PTTXT'             ti_dados-descricao,
                                 ' ' 'IMPT-ATNAM'             ti_dados-caract,
                                 ' ' 'IMPT-INDCT'             'X',
                                 ' ' 'RIMR0-CJUMC'            ti_dados-marca,
                                 ' ' 'RIMR0-PYEAC'            ti_dados-atividade,
                                 ' ' 'RIMR0-ATEXT'            ti_dados-texto.
        "INI - Megawork - 10/07/2015 - 2481542 - GS
        PERFORM f_add_line USING:
                                 'X' 'SAPLIMR0'              '6110',
                                 ' ' 'BDC_CURSOR'            'RIMR0-MRMIC',
                                 ' ' 'BDC_OKCODE'            '=NEXT',
                                 ' ' 'RIMR0-MRMIC'           ti_dados-liminf,
                                 ' ' 'RIMR0-MRMAC'           ti_dados-limsup.


        PERFORM f_add_line USING:
                                 'X' 'SAPLIMR0'              '5110',
                                 ' ' 'BDC_CURSOR'            'IMPT-ATNAM',
                                 ' ' 'BDC_OKCODE'            '=BU'.
        "FIM - Megawork - 10/07/2015 - 2481542 - GS
      ELSE.
*        Executar Carga de Ponto Medição Equipamento (Utilizar registro SHDB: IK01_IEQN)
        PERFORM f_add_line USING: 'X' 'SAPLIMR0'              '1110',
                                  ' ' 'BDC_CURSOR'            'IMPT-INDCT',
                                  ' ' 'BDC_OKCODE'           	'=HOLD',
                                  ' ' 'RIMR0-MPOTY'           ti_dados-tipo,
                                  ' ' 'IMPT-MPTYP'            ti_dados-categoria.


        PERFORM f_add_line USING: 'X' 'SAPLIMR0'              '1110',
                                  ' ' 'BDC_CURSOR'            'IMPT-INDCT',
                                  ' ' 'BDC_OKCODE'            '/00',
                                  ' ' 'EQUI-EQUNR'            ti_dados-objeto.
        PERFORM f_add_line USING:
                                  'X' 'SAPLIMR0'              '5110',
                                  ' ' 'BDC_CURSOR'            'IMPT-ATNAM',
*                                 ' ' 'BDC_OKCODE'            '=BU',   " GS 2481542
                                  ' ' 'BDC_OKCODE'            '=ADPT', " GS 2481542
                                  ' ' 'IMPT-PSORT'            ti_dados-item,
                                  ' ' 'IMPT-PTTXT'            ti_dados-descricao,
                                  ' ' 'IMPT-ATNAM'            ti_dados-caract,
                                  ' ' 'IMPT-CODGR'            ti_dados-grupo,
                                  ' ' 'RIMR0-DESIC'           ti_dados-valor,
                                  ' ' 'IMPT-DSTXT'            ti_dados-texto. "GS 2481542

        "INI - Megawork - 10/07/2015 - 2481542 - GS
        PERFORM f_add_line USING:
                                 'X' 'SAPLIMR0'              '6110',
                                 ' ' 'BDC_CURSOR'            'RIMR0-MRMIC',
                                 ' ' 'BDC_OKCODE'            '=NEXT',
                                 ' ' 'RIMR0-MRMIC'           ti_dados-liminf,
                                 ' ' 'RIMR0-MRMAC'           ti_dados-limsup.


        PERFORM f_add_line USING:
                                 'X' 'SAPLIMR0'              '5110',
                                 ' ' 'BDC_CURSOR'            'IMPT-ATNAM',
                                 ' ' 'BDC_OKCODE'            '=BU'.
        "FIM - Megawork - 10/07/2015 - 2481542 - GS
      ENDIF.



    ELSEIF ti_dados-tipo EQ 'IFL'.
*      executar carga de ponto medição local instalação  (utilizar registro shdb: ik01_ifl)
      PERFORM f_add_line USING: 'X' 'SAPLIMR0'              '1110',
                                ' ' 'BDC_CURSOR'            'RIMR0-MPOTY',
                                ' ' 'BDC_OKCODE'           	'=HOLD',
                                ' ' 'RIMR0-MPOTY'           ti_dados-tipo,
                                ' ' 'IMPT-MPTYP'            ti_dados-categoria.



      PERFORM f_add_line USING: 'X' 'SAPLIMR0'              '1110',
                                ' ' 'BDC_CURSOR'            'IFLOT-TPLNR',
                                ' ' 'BDC_OKCODE'            '/00',
                                ' ' 'IFLOT-TPLNR'           ti_dados-objeto.

      PERFORM f_add_line USING:
                            'X' 'SAPLIMR0'              '5110',
                            ' ' 'BDC_CURSOR'            'IMPT-ATNAM',
*                           ' ' 'BDC_OKCODE'            '=BU',  " GS 2481542
                            ' ' 'BDC_OKCODE'            '=ADPT', " GS 2481542
                            ' ' 'IMPT-PSORT'            ti_dados-item,
                            ' ' 'IMPT-PTTXT'            ti_dados-descricao,
                            ' ' 'IMPT-ATNAM'            ti_dados-caract,
                            ' ' 'IMPT-CODGR'            ti_dados-grupo,
                            ' ' 'RIMR0-DESIC'           ti_dados-valor.

      "INI - Megawork - 10/07/2015 - 2481542 - GS
      PERFORM f_add_line USING:
                               'X' 'SAPLIMR0'              '6110',
                               ' ' 'BDC_CURSOR'            'RIMR0-MRMIC',
                               ' ' 'BDC_OKCODE'            '=NEXT',
                               ' ' 'RIMR0-MRMIC'           ti_dados-liminf,
                               ' ' 'RIMR0-MRMAC'           ti_dados-limsup.

      PERFORM f_add_line USING:
                               'X' 'SAPLIMR0'              '5110',
                               ' ' 'BDC_CURSOR'            'IMPT-ATNAM',
                               ' ' 'BDC_OKCODE'            '=BU'.
      "FIM - Megawork - 10/07/2015 - 2481542 - GS

    ENDIF.



    CLEAR: t_msg, t_msg[].

    CALL TRANSACTION  'IK01'  USING  t_bdcdata
                               MODE   v_mode
                               UPDATE 'S'
                               MESSAGES INTO t_msg.

    READ TABLE t_msg WITH KEY msgtyp = 'S'.
    IF sy-subrc EQ 0 AND t_msg-msgnr <> '348'.
      lv_m_id = t_msg-msgid.
      lv_m_nr = t_msg-msgnr.
      lv_m_v1 = t_msg-msgv1.
      lv_m_v2 = t_msg-msgv2.
      lv_m_v3 = t_msg-msgv3.
      lv_m_v4 = t_msg-msgv4.


      CALL FUNCTION 'RPY_MESSAGE_COMPOSE'
        EXPORTING
          language          = sy-langu
          message_id        = lv_m_id
          message_number    = lv_m_nr
          message_var1      = lv_m_v1
          message_var2      = lv_m_v2
          message_var3      = lv_m_v3
          message_var4      = lv_m_v4
        IMPORTING
          message_text      = lv_m_tx
        EXCEPTIONS
          message_not_found = 1
          OTHERS            = 2.

      ti_log-objeto   = ti_dados-objeto.
      ti_log-mensagem = lv_m_tx.
      "INI - Megawork - 16/10/2014 - 45428833 - DRG
      ti_log-linha    = l_line.
      ti_log-status   = c_ok.
      APPEND ti_log.
    ELSEIF t_msg-msgnr = '348'.
      ti_log-objeto   = ti_dados-objeto.
      ti_log-mensagem = 'Objeto não pertence ao tipo informado'.
      ti_log-linha    = l_line.
      ti_log-status   = c_nok.
      APPEND ti_log.
    ENDIF.
    "FIM - Megawork - 16/10/2014 - 45428833 - DRG
    READ TABLE t_msg WITH KEY msgtyp = 'E'.
    IF sy-subrc EQ 0.
      lv_m_id = t_msg-msgid.
      lv_m_nr = t_msg-msgnr.
      lv_m_v1 = t_msg-msgv1.
      lv_m_v2 = t_msg-msgv2.
      lv_m_v3 = t_msg-msgv3.
      lv_m_v4 = t_msg-msgv4.


      CALL FUNCTION 'RPY_MESSAGE_COMPOSE'
        EXPORTING
          language          = sy-langu
          message_id        = lv_m_id
          message_number    = lv_m_nr
          message_var1      = lv_m_v1
          message_var2      = lv_m_v2
          message_var3      = lv_m_v3
          message_var4      = lv_m_v4
        IMPORTING
          message_text      = lv_m_tx
        EXCEPTIONS
          message_not_found = 1
          OTHERS            = 2.
      ti_log-objeto   = ti_dados-objeto.
      ti_log-mensagem = lv_m_tx.
      "INI - Megawork - 16/10/2014 - 45428833 - DRG
      ti_log-linha    = l_line.
      ti_log-status   = c_nok.
      "FIM - Megawork - 16/10/2014 - 45428833 - DRG
      APPEND ti_log.
    ENDIF.



  ENDLOOP.
ENDFORM.                    " F_PROCESSAR
*&---------------------------------------------------------------------*
*&      Form  F_PRINT_RELATORIO_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_relatorio_alv .
  PERFORM f_field_cat USING tg_fieldcat[].
  PERFORM f_comment_build USING gt_list_top_of_page[].
  PERFORM f_print_alv.
ENDFORM.                    " F_PRINT_RELATORIO_ALV
*&---------------------------------------------------------------------*
*&      Form  F_FIELD_CAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TG_FIELDCAT[]  text
*----------------------------------------------------------------------*
FORM f_field_cat USING lt_fieldcat TYPE slis_t_fieldcat_alv.

  DATA: v_num TYPE i.

  CLEAR: ls_fieldcat,

         v_num.

  ADD 1 TO v_num.
  PERFORM montacabedit USING  v_num   'OBJETO'   'Objeto'   10        'L'   ' ' ' ' ' ' space '' . APPEND ls_fieldcat TO lt_fieldcat.
  PERFORM montacabedit USING  v_num   'MENSAGEM' 'Mensagem' 10        'L'   ' ' ' ' ' ' space ''. APPEND ls_fieldcat TO lt_fieldcat.
  "INI - Megawork - 16/10/2014 - 45428833 - DRG
  PERFORM montacabedit USING  v_num   'LINHA'    'Linha'    10        'L'   ' ' ' ' ' ' space ''. APPEND ls_fieldcat TO lt_fieldcat.
  PERFORM montacabedit USING  v_num   'STATUS'   'Status'   10        'L'   ' ' ' ' ' ' space ''. APPEND ls_fieldcat TO lt_fieldcat.
  "FIM - Megawork - 16/10/2014 - 45428833 - DRG

ENDFORM.                    " F_FIELD_CAT
*&---------------------------------------------------------------------*
*&      Form  F_COMMENT_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_LIST_TOP_OF_PAGE[]  text
*----------------------------------------------------------------------*
FORM f_comment_build USING lt_top_of_page TYPE slis_t_listheader.
  DATA: ls_line TYPE slis_listheader.

  CLEAR ls_line.

  ls_line-typ  = 'H'.
  ls_line-info = 'Log - Carga de Medição'.
  APPEND ls_line TO lt_top_of_page.
ENDFORM.                    " F_COMMENT_BUILD
*&---------------------------------------------------------------------*
*&      Form  F_PRINT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_alv .
  vg_layout-expand_all     = space.
  vg_layout-edit           = space.
  vg_layout-zebra          = 'X'.

* Dados de Impressão
  vg_print-no_print_listinfos = 'X'.

* Largura ótima
  vg_layout-colwidth_optimize = 'X'.

* Nome do programa de impressão
  MOVE sy-repid TO vg_repid.

  "INI - Megawork - 16/10/2014 - 45428833 - DRG
  SORT ti_log BY linha ASCENDING.
  "FIM - Megawork - 16/10/2014 - 45428833 - DRG

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_buffer_active         = 'X'
      i_callback_program      = sy-repid
*     i_callback_user_command = con_callback_user
      i_callback_top_of_page  = 'TOP_OF_PAGE'
      is_layout               = vg_layout
      it_fieldcat             = tg_fieldcat[]
      i_save                  = 'A'
      is_variant              = gs_variant
      it_event_exit           = gt_event_exit
    TABLES
      t_outtab                = ti_log[]
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " F_PRINT_ALV
*&---------------------------------------------------------------------*
*&      Form  MONTACABEDIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_V_NUM  text
*      -->P_1217   text
*      -->P_1218   text
*      -->P_10     text
*      -->P_1220   text
*      -->P_1221   text
*      -->P_1222   text
*      -->P_1223   text
*      -->P_SPACE  text
*      -->P_1225   text
*----------------------------------------------------------------------*
FORM montacabedit USING v_pos v_field v_tit v_tam v_just v_fix v_sum v_out p_checkbox p_hotspot.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       = v_pos.
  ls_fieldcat-fieldname     = v_field.
  ls_fieldcat-tabname       = 'TI_LOG'.
  ls_fieldcat-reptext_ddic  = v_tit.
  ls_fieldcat-just          = v_just.
  ls_fieldcat-checkbox      = p_checkbox.
  ls_fieldcat-hotspot = p_hotspot.
  IF v_tam = 0.
    ls_fieldcat-outputlen     = strlen( v_tit ).
  ELSE.
    ls_fieldcat-outputlen     = v_tam.
  ENDIF.
  ls_fieldcat-fix_column    = v_fix.
  ls_fieldcat-do_sum        = v_sum.
  ls_fieldcat-no_out        = v_out.

ENDFORM.                    " mon

*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM top_of_page.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      i_logo             = 'PS_LOGO'
      it_list_commentary = gt_list_top_of_page.

ENDFORM.                    "top_of_page