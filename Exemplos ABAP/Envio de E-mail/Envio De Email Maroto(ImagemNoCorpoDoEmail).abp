*&---------------------------------------------------------------------*
*& Report  ZMMR007
*&
*&---------------------------------------------------------------------*
*---------------------------------------------------------------------*
* Empresa  : MegaWork                                                 *
* ID       : SAP/PM: 2011-2442                                        *
* Programa : ZMMR007                                                  *
* Módulo   : MM - Suprimentos                                         *
* Transação: ZMM0070                                                         *
* Descrição: Envio automático de email para fornecedor                *
* Autor    : Bruno Assis Barbosa                                      *
* Data     : 25.07.2012                                               *
* User Exit: N.A.                                                     *
*---------------------------------------------------------------------*
*                          * HITÓRICO *                               *
* ======== ========= =========== =====================================*
*  Data      Autor              ID                    Descrição       *
*  ======== =========     =========== ================================*
*                                                                     *
*                                                                     *
* ======== ========= =========== =====================================*
* dd/mm/aa XXXXXXXX  XXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*
*                                XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX*
*---------------------------------------------------------------------*

REPORT  zmmr007.

TYPE-POOLS: slis.

*&---------------------------------------------------------------------*
* TABLES
*&---------------------------------------------------------------------*
TABLES: eina, ekko, lfa1, ztbmm016, mara.

*&---------------------------------------------------------------------*
* TYPES
*&---------------------------------------------------------------------*
TYPES:  BEGIN OF ty_forn,
            lifnr       TYPE lifnr,
        END OF ty_forn.

TYPES:  BEGIN OF ty_cot,
            ebeln       TYPE ebeln,
            edital      TYPE string,  "Texto do Edital
            obj         TYPE string,  "Texto Objeto
        END OF ty_cot.

TYPES:  BEGIN OF ty_saida,
            sel         TYPE c,
            name        TYPE string,
            stcd1       TYPE stcd1,      "CNPJ
            stcd2       TYPE stcd2,      "CPF
            smtp_addr   TYPE string,     "Endereço de Email
        END OF ty_saida.

TYPES: BEGIN OF ty_lines,
         line(80)       TYPE c,
       END OF ty_lines.

*&---------------------------------------------------------------------*
* INTERNAL TABLES
*&---------------------------------------------------------------------*
DATA: it_forn     TYPE STANDARD TABLE OF ty_forn  WITH HEADER LINE,
      it_chk_forn TYPE STANDARD TABLE OF ty_forn  WITH HEADER LINE,
      it_cot      TYPE STANDARD TABLE OF ty_cot   WITH HEADER LINE,
      it_saida    TYPE STANDARD TABLE OF ty_saida WITH HEADER LINE,
      it_lines    TYPE STANDARD TABLE OF ty_lines WITH HEADER LINE.

DATA: it_eina LIKE STANDARD TABLE OF eina,
      it_mara LIKE STANDARD TABLE OF mara.

*&---------------------------------------------------------------------*
* Table controls
*&---------------------------------------------------------------------*
CONTROLS: tc_lines TYPE TABLEVIEW USING SCREEN 0100.

*&---------------------------------------------------------------------*
* CONSTANTS
*&---------------------------------------------------------------------*
CONSTANTS con_callback_user_local TYPE slis_formname VALUE 'USER_COMMAND'.

*&---------------------------------------------------------------------*
* DEFINIÇÕES ALV GRID
*&---------------------------------------------------------------------*
DATA: tg_fieldcat         TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      vg_layout           TYPE slis_layout_alv,    "Layout ALV
      vg_print            TYPE slis_print_alv,     "Par. Impressão
      ls_fieldcat         TYPE slis_fieldcat_alv.

DATA: imagem_xstring TYPE xstring.

*&---------------------------------------------------------------------*
* DEFINE
*&---------------------------------------------------------------------*

DEFINE d_monta_alv.

* 1-COL_POS, 2-CAMPO, 3-TITULO, 4-TAMANHO, 5-FORMATACAO, 6-COLUNA_FIXA, 7-SUM_UP, 8-NO_OUT, 9-CHECKBOX, 10-COR

  clear ls_fieldcat.
  ls_fieldcat-tabname       = 'IT_SAIDA'.
  ls_fieldcat-col_pos       = &1.
  ls_fieldcat-fieldname     = &2.
  ls_fieldcat-reptext_ddic  = &3.

  if &4 eq 0.
    ls_fieldcat-outputlen     = strlen( &3 ).
  else.
    ls_fieldcat-outputlen     = &4.
  endif.

  ls_fieldcat-just          = &5.
  ls_fieldcat-fix_column    = &6.
  ls_fieldcat-do_sum        = &7.
  ls_fieldcat-no_out        = &8.
  ls_fieldcat-checkbox      = &9.

  if &2 eq 'CLASSIFICAO'.
    ls_fieldcat-emphasize     = 'X'.                        "&10.
  else.
    clear ls_fieldcat-emphasize.
  endif.

  append ls_fieldcat to tg_fieldcat.

END-OF-DEFINITION.

*&---------------------------------------------------------------------*
* PARAMETERS
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK 1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: p_grmerc        FOR eina-matkl,
                p_solcot        FOR ekko-ebeln NO INTERVALS NO-EXTENSION.
SELECTION-SCREEN END OF BLOCK 1.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  IF p_grmerc[] IS INITIAL OR p_solcot[] IS INITIAL.
    MESSAGE s398(00) DISPLAY LIKE 'E' WITH 'Preencher todos os campos!'.
    STOP.
  ENDIF.

*&---------------------------------------------------------------------*
* START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM busca_forn_valido.
  PERFORM busca_solicitacao.
  PERFORM monta_dados.
  PERFORM monta_fieldcat.
  PERFORM imprime_alv.

*&---------------------------------------------------------------------*
* FORMS
*&---------------------------------------------------------------------*
FORM busca_forn_valido.
  DATA: f_mensage  TYPE string,
        f_count    TYPE i,
        wa_eina    TYPE eina,
        v_matkl    TYPE mara-matkl.

  CLEAR:    it_forn, it_chk_forn, f_mensage, f_count, it_eina, it_mara, v_matkl.
  REFRESH:  it_forn, it_chk_forn, it_eina, it_mara.

*Todos os dados do EINA
  SELECT * INTO TABLE it_eina
    FROM eina.

  CLEAR: wa_eina, v_matkl.
  LOOP AT it_eina INTO wa_eina.
    IF wa_eina-matnr IS INITIAL.
* Busca os fornecedores para o Grupo de Compradorias de serviço
      CHECK wa_eina-matkl IN p_grmerc.

      SELECT lifnr APPENDING TABLE it_forn
        FROM eina
        WHERE matkl = wa_eina-matkl.

    ELSE.
* Busca os fornecedores para o Grupo de Compradorias de material
      SELECT SINGLE matkl FROM mara INTO v_matkl
              WHERE matnr EQ wa_eina-matnr.

      CHECK v_matkl IN p_grmerc.

      SELECT lifnr APPENDING TABLE it_forn
        FROM eina
        WHERE infnr = wa_eina-infnr.

    ENDIF.
  ENDLOOP.

  SORT it_forn BY lifnr.

  DELETE ADJACENT DUPLICATES FROM it_forn COMPARING lifnr.

  IF sy-subrc NE 0.
    MESSAGE s398(00) DISPLAY LIKE 'E' WITH 'Não existe(m) fornecedor(es)' 'registrado(s) com o(s) grupo(s)' 'de mercadoria citados!'.
    STOP.
  ENDIF.

* Checa quais desses fornecedores estão suspensos e os deleta da internal table de fornecedores
  SELECT lifnr INTO TABLE it_chk_forn
    FROM ztbmm016
    FOR ALL ENTRIES IN it_forn
    WHERE lifnr EQ it_forn-lifnr
      AND ztipo EQ 'S'
      AND endda GT sy-datum.

  LOOP AT it_chk_forn.
    READ TABLE it_forn WITH KEY lifnr = it_chk_forn-lifnr TRANSPORTING NO FIELDS.
    DELETE it_forn INDEX sy-tabix.
  ENDLOOP.

  DESCRIBE TABLE it_forn LINES f_count.

  IF f_count EQ 0.
*    CONCATENATE 'Todos os fornecedores desse(s) grupo(s) de mercadoria estão suspensos até' sy-datum INTO f_mensage SEPARATED BY space.
    MESSAGE s398(00) DISPLAY LIKE 'E' WITH 'Todos os fornecedores' 'desse(s) grupo(s) de' 'mercadoria estão suspensos até' sy-datum. "f_mensage.
    STOP.
  ENDIF.

  REFRESH it_chk_forn.
  CLEAR   it_chk_forn.

ENDFORM.                    "busca_forn_Valido

*&---------------------------------------------------------------------*
*&      Form  busca_solicitacao
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM busca_solicitacao.

  DATA: f_name   TYPE thead-tdname,
        it_lines TYPE STANDARD TABLE OF tline WITH HEADER LINE.

  FIELD-SYMBOLS: <fs_cot> TYPE ty_cot.

  CLEAR:   it_cot.
  REFRESH: it_cot.
  UNASSIGN <fs_cot>.

  SELECT ebeln INTO TABLE it_cot
    FROM ekko
    WHERE ebeln IN p_solcot
      AND bstyp EQ 'A'.

  IF sy-subrc NE 0.
    MESSAGE s398(00) DISPLAY LIKE 'E' WITH 'Não existe solicitação de' 'cotação para os fornecedores desse(s) grupo(s)!'.
    STOP.
  ENDIF.

  LOOP AT it_cot ASSIGNING <fs_cot>.
    CLEAR: it_lines, f_name.
    REFRESH it_lines.
    WRITE <fs_cot>-ebeln TO f_name.
    <fs_cot>-edital = 'EDITAL DE'.
* Monta Edital
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        client   = sy-mandt
        id       = 'A18'
        language = 'P'
        name     = f_name
        object   = 'EKKO'
      TABLES
        lines    = it_lines.
    LOOP AT it_lines.
      CONCATENATE <fs_cot>-edital it_lines-tdline INTO <fs_cot>-edital SEPARATED BY space.
    ENDLOOP.

    CLEAR:  it_lines.
    REFRESH it_lines.
* Monta Objeto
    CALL FUNCTION 'READ_TEXT'
      EXPORTING
        client   = sy-mandt
        id       = 'A01'
        language = 'P'
        name     = f_name
        object   = 'EKKO'
      TABLES
        lines    = it_lines.
    LOOP AT it_lines.
      CONCATENATE <fs_cot>-obj it_lines-tdline INTO <fs_cot>-obj SEPARATED BY space.
    ENDLOOP.
  ENDLOOP.


ENDFORM.                    "busca_solicitacao

*&---------------------------------------------------------------------*
*&      Form  monta_dados
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM monta_dados.
  DATA: BEGIN OF it_info OCCURS 0,
          lifnr TYPE lifnr,
          name1 TYPE name1_gp,
          name2 TYPE name2_gp,
          stcd1 TYPE stcd1,
          stcd2 TYPE stcd2,
          smtp_addr   TYPE adr6-smtp_addr,
        END OF it_info.

  CLEAR:   it_info, it_saida.
  REFRESH: it_info, it_saida.

* Busca os dados dos fornecedores
  SELECT a~lifnr a~name1 a~name2 a~stcd1 a~stcd2 b~smtp_addr INTO CORRESPONDING FIELDS OF TABLE it_info
    FROM lfa1 AS a INNER JOIN adr6 AS b ON a~adrnr EQ b~addrnumber
    FOR ALL ENTRIES IN it_forn
    WHERE lifnr EQ it_forn-lifnr.

  IF it_info[] IS NOT INITIAL.

    LOOP AT it_info.
      CONCATENATE it_info-name1 it_info-name2 INTO it_saida-name SEPARATED BY space.
      it_saida-stcd1      = it_info-stcd1.
      it_saida-stcd2      = it_info-stcd2.
      it_saida-smtp_addr  = it_info-smtp_addr.
      APPEND it_saida.
    ENDLOOP.

    SORT it_saida BY name ASCENDING.

  ELSE.

    MESSAGE s398(00) DISPLAY LIKE 'E' WITH 'Dados do(s) fornecedor(es) incompleto(s)!'.
    STOP.

  ENDIF.



ENDFORM.                    "monta_dados

*&---------------------------------------------------------------------*
*&      Form  monta_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM monta_fieldcat.
  DATA: v_num TYPE i.

  ADD 1 TO v_num.
  d_monta_alv v_num 'NAME' 'Nome' '50' 'L' space space space space.

  ADD 1 TO v_num.
  d_monta_alv v_num 'STCD1' 'CNPJ' '50' 'L' space space space space.

  ADD 1 TO v_num.
  d_monta_alv v_num 'STCD2' 'CPF' '50' 'L' space space space space.

  ADD 1 TO v_num.
  d_monta_alv v_num 'SMTP_ADDR' 'E-Mail' '50' 'L' space space space space.

ENDFORM.                    "monta_fieldcat

*&---------------------------------------------------------------------*
*&      Form  imprime_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM imprime_alv.

  vg_layout-box_fieldname  = 'SEL'.
  vg_layout-edit_mode      = 'A'.
  vg_layout-zebra          = 'X'.

* Largura ótima
  vg_layout-colwidth_optimize = 'X'.


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_buffer_active          = 'X'
      i_callback_program       = sy-repid
      i_callback_user_command  = con_callback_user_local
      i_callback_pf_status_set = 'SET_PF_STATUS'
      is_layout                = vg_layout
      it_fieldcat              = tg_fieldcat[]
    TABLES
      t_outtab                 = it_saida
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    "imprime_alv

*&---------------------------------------------------------------------*
*&      Form  set_pf_status
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->RT_EXTAB   text
*----------------------------------------------------------------------*
FORM set_pf_status USING rt_extab TYPE slis_t_extab.
  SET PF-STATUS 'ZGUIZMMR007'.
ENDFORM. "Set_pf_status

*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->R_UCOMM      text
*      -->RS_SELFIELD  text
*----------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN '&BACK'.
      LEAVE TO SCREEN 0.
    WHEN '&CANCEL' OR '&EXIT'.
      LEAVE PROGRAM.
    WHEN '&EMAIL'.
      CALL SCREEN 100 STARTING AT 10 20.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.  "User_command

*----------------------------------------------------------------------*
*  MODULE STATUS_0100 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'ZSTATUS100'.
  SET TITLEBAR 'ZTITLE'.

  PERFORM f_monta_visualizacao.

ENDMODULE.                 " STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  DATA ok_code TYPE sy-ucomm.
  ok_code = sy-ucomm.

  CASE ok_code.
    WHEN '&ENV'.
      READ TABLE it_saida WITH KEY sel = 'X'.
      IF sy-subrc NE 0.
        MESSAGE e398(00) WITH 'Nenhum fornecedor foi selecionado.'.
      ENDIF.
      PERFORM info_mail.
      MESSAGE s398(00) WITH 'E-mail(s) enviado(s) com sucesso!.'.
      LEAVE TO SCREEN 0.
    WHEN '&CANC'.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  ENVIAR_MAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM info_mail.
  DATA: f_data           TYPE string,
        lr_mail_dados    TYPE REF TO cl_crm_email_data,
        lv_para          TYPE crms_email_recipient,
        v_corpo_email    TYPE string.

* Traz a descrição da data.
  PERFORM busca_data CHANGING f_data.

*   Cria a Mensagem de E-mail
  CREATE OBJECT lr_mail_dados.

*   Preenche o Remetente.
*  lr_mail_dados->from-address = 'sigaobi@cesan.com.br'.
*  lr_mail_dados->from-name    = lr_mail_dados->from-address.
  lr_mail_dados->from-address = 'cadastrofornecedor@cesan.com.br'.
  lr_mail_dados->from-name    = 'CESAN'.
  lr_mail_dados->from-id      = lr_mail_dados->from-address.


  LOOP AT it_cot.
    CLEAR lr_mail_dados->subject.
*     Preenche o destinatário (Só será enviado com cópia para administrador uma única vez - Na primeira passagem do loop)
    lv_para-address = 'cadastrofornecedor@cesan.com.br'.
    lv_para-name    = 'CESAN'.
    APPEND lv_para TO lr_mail_dados->to.

    lr_mail_dados->subject = it_cot-edital.                         "Assunto
    LOOP AT it_saida WHERE sel = 'X'.
      CLEAR: v_corpo_email.

**       Preenche o destinatário
*      lv_para-address = 'cadastrofornecedor@cesan.com.br'.
*      lv_para-name    = 'CESAN'.
*      APPEND lv_para TO lr_mail_dados->to.

      lv_para-address = it_saida-smtp_addr.
      lv_para-name    = it_saida-name.
      APPEND lv_para TO lr_mail_dados->to.

*       Monta a mensagem do e-mail
*       Imagem
      PERFORM busca_imagem.

*      CONCATENATE '<img src="C:\temp\CESAN_LOGO_SF.bmp" width=200 height=80>' '</img>' '<br/>'              INTO v_corpo_email SEPARATED BY space.
      CONCATENATE '<img src="logo.bmp" width=200 height=80>' '</img>' '<br/>'              INTO v_corpo_email SEPARATED BY space.
*       Corpo do e-mail
      CONCATENATE v_corpo_email '<p align = "Right">' f_data '</p>'    '<br/>' '<br/>'        INTO v_corpo_email SEPARATED BY space.

      CONCATENATE v_corpo_email '<p align="Justify">' 'À' '<br/>' it_saida-name '<br/>' '<br/>' INTO v_corpo_email SEPARATED BY space.
      CONCATENATE v_corpo_email 'Prezados Senhores,'             '<br/>' '<br/>'        INTO v_corpo_email SEPARATED BY space.
      CONCATENATE v_corpo_email '<b>' 'REF:' it_cot-edital  '</b> <br/>' '<br/>'        INTO v_corpo_email SEPARATED BY space.
      CONCATENATE v_corpo_email '<b>' 'OBJETO:' it_cot-obj  '</b> <br/>' '<br/> <br/>'  INTO v_corpo_email SEPARATED BY space.

      CONCATENATE v_corpo_email 'Informamos que se encontra disponível no site da' '<b>' 'CESAN' '</b>'  INTO v_corpo_email SEPARATED BY space.
      CONCATENATE v_corpo_email '(<a href="http://www.cesan.com.br">www.cesan.com.br</a>' '), o'                            INTO v_corpo_email SEPARATED BY space.
      CONCATENATE v_corpo_email '<b>' it_cot-edital '</b>'                                                                  INTO v_corpo_email SEPARATED BY space.
      CONCATENATE v_corpo_email 'referenciado, cujo objeto é compatível com o ramo de atuação dessa Empresa. Diante disso,'
                                'estamos contando com a sua participação neste certame, visando aumentar a competitividade'
                                'de nossas licitações. Por oportuno, solicitamos a essa empresa, que de agora em diante'
                                'acesse constantemente o nosso site para participar de nossas licitações. Solicitamos'
                                'confirmar o recebimento desta correspondência através do e-mail: licitacoes@cesan.com.br.' INTO v_corpo_email SEPARATED BY space.

      CONCATENATE v_corpo_email '<br/> <br/>' 'Atenciosamente,'                       '<br/> <br/>'       INTO v_corpo_email SEPARATED BY space.
      CONCATENATE v_corpo_email 'Companhia Espírito-Santense de Saneamento - CESAN.'  '<br/>'             INTO v_corpo_email SEPARATED BY space.
      CONCATENATE v_corpo_email 'Divisão de Licitação - R-DLI.'                       '<br/>'             INTO v_corpo_email SEPARATED BY space.
      CONCATENATE v_corpo_email 'Cadastro de Fornecedor'                              '<br/>'             INTO v_corpo_email SEPARATED BY space.
      CONCATENATE v_corpo_email 'cadastrofornecedor@cesan.com.br'                     '<br/>'             INTO v_corpo_email SEPARATED BY space.
      CONCATENATE v_corpo_email 'Tel. (27) 2127-5418.'                                 '<br/> </p>'   INTO v_corpo_email SEPARATED BY space.

* Envia o E-mail
      PERFORM envia_email USING lr_mail_dados v_corpo_email.
*Para que outros fornecedores não recebam os e-mails de outros e que o administrador receba uma única vez
      CLEAR: lv_para, lr_mail_dados->to.
      REFRESH lr_mail_dados->to.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " ENVIAR_MAIL

*&---------------------------------------------------------------------*
*&      Form  envia_email
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LR_MAIL_DADOS  text
*      -->V_CORPO_EMAIL  text
*----------------------------------------------------------------------*
FORM envia_email USING lr_mail_dados v_corpo_email.

  DATA: ls_mail_struc    TYPE crms_email_mime_struc,
        vl_send_request  TYPE sysuuid_x,
        lr_email         TYPE REF TO cl_crm_email_data.

  lr_email = lr_mail_dados.


  CLEAR: lr_email->body, ls_mail_struc.

*   Mensagem no Corpo do E-mail.
  ls_mail_struc-mime_type     = 'text/html'.
  ls_mail_struc-file_name     = 'body.htm'.
  ls_mail_struc-content_ascii =  v_corpo_email.
  APPEND ls_mail_struc TO lr_email->body.

  CLEAR ls_mail_struc.
  ls_mail_struc-is_attachment = 'X'.
  ls_mail_struc-mime_type     = 'pictures'.
  ls_mail_struc-file_name     = 'logo.bmp'.
  ls_mail_struc-content_bin   = imagem_xstring.
  APPEND ls_mail_struc TO lr_email->body.


*   Envia o E-mail
  vl_send_request = cl_crm_email_utility_base=>send_email( iv_mail_data = lr_email ).

* Processa o Envio Imediato
  SUBMIT rsconn01 AND RETURN.

ENDFORM.                    " F_ENVIA_EMAIL_BBNY

*&---------------------------------------------------------------------*
*&      Form  busca_imagem
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM busca_imagem.
  DATA : l_bytecount TYPE i,
         l_tdbtype   LIKE stxbitmaps-tdbtype,
         l_content   TYPE STANDARD TABLE OF bapiconten INITIAL SIZE 0.

  DATA: BEGIN OF graphic_table OCCURS 0,
  line(255) TYPE x,
  END OF graphic_table.

  DATA: graphic_size TYPE i.

  CLEAR graphic_table[].

  CALL FUNCTION 'SAPSCRIPT_GET_GRAPHIC_BDS'
    EXPORTING
      i_object       = 'GRAPHICS'
      i_name         = 'CESAN_LOGO_SF'
      i_id           = 'BMAP'
      i_btype        = 'BCOL'
    IMPORTING
      e_bytecount    = l_bytecount
    TABLES
      content        = l_content
    EXCEPTIONS
      not_found      = 1
      bds_get_failed = 2
      bds_no_content = 3
      OTHERS         = 4.

  CALL FUNCTION 'SAPSCRIPT_CONVERT_BITMAP'
    EXPORTING
      old_format               = 'BDS'
      new_format               = 'BMP'
      bitmap_file_bytecount_in = l_bytecount
    IMPORTING
      bitmap_file_bytecount    = graphic_size
    TABLES
      bds_bitmap_file          = l_content
      bitmap_file              = graphic_table
    EXCEPTIONS
      OTHERS                   = 1.

  CALL FUNCTION 'SCMS_BINARY_TO_XSTRING'
    EXPORTING
      input_length       = graphic_size
*     FIRST_LINE         = 0
*     LAST_LINE          = 0
   IMPORTING
     buffer             = imagem_xstring
    TABLES
      binary_tab         = graphic_table
   EXCEPTIONS
     failed             = 1
     OTHERS             = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


*  CALL FUNCTION 'WS_DOWNLOAD'
*    EXPORTING
*      bin_filesize            = graphic_size
*      filename                = 'C:\temp\CESAN_LOGO_SF.bmp'
*      filetype                = 'BIN'
*    TABLES
*      data_tab                = graphic_table
*    EXCEPTIONS
*      invalid_filesize        = 1
*      invalid_table_width     = 2
*      invalid_type            = 3
*      no_batch                = 4
*      unknown_error           = 5
*      gui_refuse_filetransfer = 6.
*
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.

ENDFORM.                    "busca_imagem

*&---------------------------------------------------------------------*
*&      Form  busca_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->F2_DATA    text
*----------------------------------------------------------------------*
FORM busca_data CHANGING f2_data.

  CALL FUNCTION 'CONV_EXIT_LDATE_OUTPUT_LANGU'
    EXPORTING
      input    = sy-datum
      language = sy-langu
    IMPORTING
      output   = f2_data.

  REPLACE '.' WITH ' de' INTO  f2_data.
  CONCATENATE 'Serra,' f2_data INTO f2_data SEPARATED BY space.
ENDFORM.                    "busca_data
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_VISUALIZACAO
*&---------------------------------------------------------------------*
*       Monta visualização do e-mail
*----------------------------------------------------------------------*
FORM f_monta_visualizacao .

  DATA: f_data     TYPE string,
        vl_len     TYPE sy-tabix,
        vl_tam     TYPE sy-tabix,
        vl_obj     TYPE string,
        vl_obj1    TYPE string,
        vl_obj2    TYPE string,
        vl_obj3    TYPE string,
        v_num      TYPE string.

  CLEAR: it_lines, it_lines[],vl_tam, vl_obj, vl_obj1, vl_obj2, v_num.

* Traz a descrição da data.
  PERFORM busca_data CHANGING f_data.

  LOOP AT it_cot.
    LOOP AT it_saida WHERE sel = 'X'.
*      CONCATENATE '<img src="C:\temp\CESAN_LOGO_SF.bmp" width=200 height=80>' '</img>' '<br/>'
*             INTO it_lines-line SEPARATED BY space.
*      APPEND it_lines. CLEAR: it_lines.
*       Corpo do e-mail

      vl_len = STRLEN( f_data ).
      vl_len = 80 - vl_len.
      it_lines-line+vl_len = f_data.
      APPEND it_lines. CLEAR: it_lines.
      it_lines-line = 'À'.
      APPEND it_lines. CLEAR: it_lines.
      it_lines-line = it_saida-name.
      APPEND it_lines. CLEAR: it_lines.
      it_lines-line = 'Prezados Senhores,'.
      APPEND it_lines. CLEAR: it_lines.
      APPEND it_lines.
      CONCATENATE 'REF:' it_cot-edital
             INTO it_lines-line SEPARATED BY space.
      APPEND it_lines. CLEAR: it_lines.
      APPEND it_lines.

      vl_obj = it_cot-obj.
      CONDENSE vl_obj.
      vl_tam = STRLEN( vl_obj ).
      IF vl_tam LE 71.
        CONCATENATE 'OBJETO:' vl_obj
               INTO it_lines-line SEPARATED BY space.
        APPEND it_lines. CLEAR: it_lines, vl_obj, vl_tam.
        APPEND it_lines.
      ELSEIF vl_tam GT 71 AND vl_tam LE 142.
        IF vl_tam NE 142.
          v_num = vl_tam - 71.
        ELSE.
          v_num = vl_tam.
        ENDIF.
        vl_obj1 = vl_obj(71).
        vl_obj2 = vl_obj+71(v_num).
        CONCATENATE 'OBJETO:' vl_obj1
             INTO it_lines-line SEPARATED BY space.
        APPEND it_lines. CLEAR: it_lines.
        it_lines-line+8 = vl_obj2.
        APPEND it_lines. CLEAR: it_lines, vl_obj1, vl_obj2, vl_tam.
        APPEND it_lines.
      ELSE.
        IF vl_tam GE 213.
          v_num = 71.
        ELSE.
          v_num = vl_tam - 142.
        ENDIF.
        vl_obj1 = vl_obj(71).
        vl_obj2 = vl_obj+71(71).
        vl_obj3 = vl_obj+142(v_num).
        CONCATENATE 'OBJETO:' vl_obj1
             INTO it_lines-line SEPARATED BY space.
        APPEND it_lines. CLEAR: it_lines.
        it_lines-line+8 = vl_obj2.
        APPEND it_lines. CLEAR: it_lines.
        it_lines-line+8 = vl_obj3.
        APPEND it_lines. CLEAR: it_lines, vl_obj1, vl_obj2,
                                 vl_obj3, vl_tam, v_num.
        APPEND it_lines.
      ENDIF.

      it_lines-line = 'Informamos que se encontra disponível no site da CESAN (www.cesan.com.br),'.
      APPEND it_lines. CLEAR: it_lines.
      CONCATENATE 'o' it_cot-edital 'referenciado, cujo'
             INTO it_lines-line SEPARATED BY space.
      APPEND it_lines. CLEAR: it_lines.
      it_lines-line = 'objeto é compatível com o ramo de atuação dessa Empresa.'.
      APPEND it_lines. CLEAR: it_lines.
      it_lines-line = 'Diante disso, estamos contando com a sua participação neste certame, visando'.
      APPEND it_lines. CLEAR: it_lines.
      it_lines-line = 'aumentar a competitividade de nossas licitações. Por oportuno, solicitamos a'.
      APPEND it_lines. CLEAR: it_lines.
      it_lines-line = 'essa empresa, que de agora em diante acesse constantemente o nosso site para'.
      APPEND it_lines. CLEAR: it_lines.
      it_lines-line = 'participar de nossas licitações. Solicitamos confirmar o recebimento desta'.
      APPEND it_lines. CLEAR: it_lines.
      it_lines-line = 'correspondência através do e-mail: licitacoes@cesan.com.br.'.
      APPEND it_lines. CLEAR: it_lines.
      APPEND it_lines.

      it_lines-line = 'Atenciosamente,'.
      APPEND it_lines. CLEAR: it_lines.
      APPEND it_lines.
      it_lines-line = 'Companhia Espírito-Santense de Saneamento - CESAN.'.
      APPEND it_lines. CLEAR: it_lines.
      it_lines-line = 'Divisão de Licitação - R-DLI.'.
      APPEND it_lines. CLEAR: it_lines.
      it_lines-line = 'Cadastro de Fornecedor'.
      APPEND it_lines. CLEAR: it_lines.
      it_lines-line = 'cadastrofornecedor@cesan.com.br'.
      APPEND it_lines. CLEAR: it_lines.
      it_lines-line = 'tel:(27) 2127-5418.'.
      APPEND it_lines. CLEAR: it_lines.
      APPEND it_lines.
      it_lines-line = '________________________________________________________________________________'.
      APPEND it_lines. CLEAR: it_lines.
      APPEND it_lines.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " F_MONTA_VISUALIZACAO
