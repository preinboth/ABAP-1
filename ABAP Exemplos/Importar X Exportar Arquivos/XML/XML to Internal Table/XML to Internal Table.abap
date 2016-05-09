REPORT zmmprg132.

*--------------------------------------------------------------------*
* Tables
*--------------------------------------------------------------------*
TABLES: t604f,
        ztbmm115,
        usr02.

*--------------------------------------------------------------------*
* Types-pools
*--------------------------------------------------------------------*
TYPE-POOLS: ixml,
            slis.

*--------------------------------------------------------------------*
* Declaração de Types
*--------------------------------------------------------------------*
TYPES: BEGIN OF ty_tab,
        name TYPE string,
        value TYPE string,
       END OF ty_tab.

TYPES : BEGIN OF y_cmdout,
         line(100),
        END OF y_cmdout.

TYPES: BEGIN OF ty_arquivo,
        codigo     TYPE t604f-steuc,
        desc_ncm   TYPE c LENGTH 300,
        uni_med    TYPE c LENGTH 100,
        sigla      TYPE c LENGTH 100,
        nt         TYPE c LENGTH 100,
        aliquota   TYPE c LENGTH 100,
        base_legal TYPE c LENGTH 100,
      END OF ty_arquivo.

TYPES: BEGIN OF ty_log,
        mandt         TYPE sy-mandt,
        codigo        TYPE t604f-steuc,
        data_a        TYPE sy-datum,
        file_import   TYPE c LENGTH 35,
        ret_1         TYPE c LENGTH 8,
        ret_2         TYPE c LENGTH 8,
        ret_3         TYPE c LENGTH 8,
        usuario       TYPE sy-uname,
       END OF ty_log.

*--------------------------------------------------------------------*
* Declaração de Classes
*--------------------------------------------------------------------*
DATA: lcl_xml_doc  TYPE REF TO cl_xml_document,
      v_node       TYPE REF TO if_ixml_node,
      v_child_node TYPE REF TO if_ixml_node,
      v_root       TYPE REF TO if_ixml_node,
      v_iterator   TYPE REF TO if_ixml_node_iterator,
      v_nodemap    TYPE REF TO if_ixml_named_node_map,
      v_attr       TYPE REF TO if_ixml_node.

*--------------------------------------------------------------------*
* Declaração de Variáveis
*--------------------------------------------------------------------*
DATA: v_subrc      TYPE sysubrc,
      v_name       TYPE string,
      v_prefix     TYPE string,
      v_value      TYPE string,
      v_char       TYPE c LENGTH 2,
      v_command    TYPE c LENGTH 100,
      v_mensagem   TYPE c LENGTH 255,
      v_ftp_erro   TYPE c LENGTH 1,
      v_xml_erro   TYPE c LENGTH 1,
      docid        TYPE c LENGTH 40,
      w_cmd        TYPE c LENGTH 40,
      wa           TYPE ty_tab,
      v_slen       TYPE i,
      v_hdl        TYPE i,
      v_count      TYPE i,
      v_index      TYPE i,
      blob_length  TYPE i,
      w_bindata    TYPE blob,
      w_string     TYPE xstring,
      wa_arquivo   TYPE ty_arquivo,
      wa_arquivo_aux TYPE ty_arquivo,
      wa_log       TYPE ty_log,
      wa_iplftp    TYPE ztbl_ipl_ftp,
      wa_cmdout    TYPE y_cmdout,
      w_logid      TYPE numc4 VALUE 1,
      wa_ztbmm115  TYPE ztbmm115.

*--------------------------------------------------------------------*
* Declaração de Tabelas Internas
*--------------------------------------------------------------------*
DATA: itab       TYPE STANDARD TABLE OF ty_tab,
      it_cmdout  TYPE STANDARD TABLE OF y_cmdout,
      bindata    TYPE STANDARD TABLE OF blob,
      t_arquivo      TYPE STANDARD TABLE OF ty_arquivo,
      t_arquivo_aux  TYPE STANDARD TABLE OF ty_arquivo,
      t_arquivo_end  TYPE STANDARD TABLE OF ty_arquivo,
      t_log      TYPE STANDARD TABLE OF ty_log,
      it_iplftp  TYPE STANDARD TABLE OF ztbl_ipl_ftp,
      t_ztbmm115 TYPE STANDARD TABLE OF ztbmm115.

*--------------------------------------------------------------------*
* Declaração de Constans
*--------------------------------------------------------------------*
CONSTANTS: c_key                    TYPE i VALUE 26101957,
           c_rfcdest                TYPE rfcdes-rfcdest VALUE 'SAPFTPA',
           con_callback_user_local  TYPE slis_formname  VALUE 'ALV_USER_COMMAND'.

*&---------------------------------------------------------------------*
* Definições ALV GRID
*&---------------------------------------------------------------------*
TYPE-POOLS: slis.

DATA: t_sort              TYPE slis_t_sortinfo_alv WITH HEADER LINE ,
      tg_fieldcat         TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      gt_list_top_of_page TYPE slis_t_listheader,
      vg_pos              LIKE sy-index,           'Posição coluna ALV
      vg_layout           TYPE slis_layout_alv,    'Layout ALV
      vg_print            TYPE slis_print_alv,     'Par. Impressão
      vg_repid            LIKE sy-repid,           'Programa
      ls_event_exit       TYPE slis_event_exit,
      gt_event_exit       TYPE STANDARD TABLE OF slis_event_exit,
      gs_variant          LIKE disvariant,
      ls_fieldcat         TYPE slis_fieldcat_alv,
      l_save              TYPE char1 VALUE 'A',
      v_erro.

*--------------------------------------------------------------------*
* Constructor
*--------------------------------------------------------------------*
CREATE OBJECT lcl_xml_doc.

*--------------------------------------------------------------------*
* Tela de Seleção
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

PARAMETER: p_impo RADIOBUTTON GROUP a1 USER-COMMAND screen DEFAULT 'X',
           p_rela RADIOBUTTON GROUP a1.

SELECTION-SCREEN END OF BLOCK b1.

* Parametros de Importação
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME.
PARAMETERS: p_user        TYPE c LENGTH 30       LOWER CASE  DEFAULT 'CHuser'            MODIF ID ftp,
            p_pwd         TYPE c LENGTH 30       LOWER CASE  DEFAULT 'Samarco1973'       MODIF ID ftp,
            p_host        TYPE c LENGTH 100      LOWER CASE  DEFAULT '200.241.4.139'     MODIF ID ftp,
            p_ftp         TYPE e_dexcommfilepath LOWER CASE  DEFAULT '/ch_codin/prod/'   MODIF ID ftp,
            p_file        TYPE c LENGTH 100      LOWER CASE  DEFAULT 'NCMT'              MODIF ID ftp.
SELECTION-SCREEN END OF BLOCK b2.

* Parametros do Relatório
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME.
SELECT-OPTIONS: s_cod  FOR t604f-steuc           MODIF ID rel,
                s_data FOR ztbmm115-data_a       MODIF ID rel,
                s_ret  FOR ztbmm115-ret_1        MODIF ID rel,
                s_file FOR ztbmm115-file_import  MODIF ID rel,
                s_user FOR usr02-bname           MODIF ID rel.
SELECTION-SCREEN END OF BLOCK b3.

*----------------------------------------------------------------------*
* Verificação da tela de seleção para Active                           *
*----------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.

    IF screen-name EQ 'P_PWD'.'Set the password field as invisible
      screen-invisible = '1'.
    ENDIF.

    IF p_impo EQ 'X'.
      IF screen-group1 EQ 'REL'.
        screen-active = 0.
      ENDIF.
    ELSEIF p_rela EQ 'X'.
      IF screen-group1 EQ 'FTP'.
        screen-active = 0.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
  ENDLOOP.

*--------------------------------------------------------------------*
* Start-of-selection.
*--------------------------------------------------------------------*
START-OF-SELECTION.

  IF p_impo EQ 'X'.
    PERFORM f_get_files_ftp.
    PERFORM f_xml_to_internal_table.
    PERFORM f_write_result.
  ELSEIF p_rela EQ 'X'.
    PERFORM f_get_dados_rel.
    PERFORM f_build_header_alv. 'Cabeçalho ALV
    PERFORM f_monta_alv.        'Campos ALV
    PERFORM f_sort_alv.         'Agrupa Campos
    PERFORM f_processa_dados_alv.
    PERFORM f_imprime_alv.
  ENDIF.

  DEFINE d_monta_alv.

* 1-COL_POS, 2-CAMPO, 3-TITULO, 4-TAMANHO, 5-FORMATACAO, 6-COLUNA_FIXA, 7-SUM_UP, 8-NO_OUT, 9-CHECKBOX, 10-COR

    clear ls_fieldcat.
    ls_fieldcat-tabname       = 'T_ZTBMM115'.
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

    append ls_fieldcat to tg_fieldcat.

  END-OF-DEFINITION.

*&---------------------------------------------------------------------*
*&      Form  F_GET_FILE_FTP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_ARQUIVO  text
*----------------------------------------------------------------------*
FORM f_get_files_ftp.

  CLEAR: blob_length,
       bindata,
       bindata[].

  CALL 'AB_RFC_X_SCRAMBLE_STRING' ID 'SOURCE' FIELD p_pwd ID 'KEY'         FIELD c_key
                                  ID 'SCR'    FIELD 'X'   ID 'DESTINATION' FIELD p_pwd
                                  ID 'DSTLEN' FIELD v_slen.

  SET EXTENDED CHECK OFF.

  v_slen = STRLEN( p_pwd ).

  CALL FUNCTION 'HTTP_SCRAMBLE'
    EXPORTING
      SOURCE      = p_pwd
      sourcelen   = v_slen
      key         = c_key
    IMPORTING
      destination = p_pwd.

  CALL FUNCTION 'FTP_CONNECT'
    EXPORTING
      user            = p_user
      password        = p_pwd
      host            = p_host
      rfc_destination = c_rfcdest
    IMPORTING
      handle          = v_hdl
    EXCEPTIONS
      not_connected   = 1
      OTHERS          = 2.


  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CONCATENATE 'cd' p_ftp INTO w_cmd SEPARATED BY space.

  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle        = v_hdl
      command       = w_cmd
      compress      = 'N'
    TABLES
      data          = it_cmdout
    EXCEPTIONS
      tcpip_error   = 1
      command_error = 2
      data_error    = 3
      OTHERS        = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  REFRESH it_cmdout.
  CLEAR w_cmd.
  w_cmd = 'ls'.

  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle        = v_hdl
      command       = w_cmd
      compress      = 'N'
    TABLES
      data          = it_cmdout
    EXCEPTIONS
      tcpip_error   = 1
      command_error = 2
      data_error    = 3
      OTHERS        = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  LOOP AT it_cmdout INTO wa_cmdout FROM 4.

    CLEAR wa_iplftp.
    CHECK wa_cmdout-line+39(4) EQ p_file. ' 'NCMT'.

    wa_iplftp-file_nm = wa_cmdout-line+39(31).
    wa_iplftp-log_id  = 1.
    wa_iplftp-fdate   = sy-datum.
    wa_iplftp-ftime   = sy-uzeit.
    APPEND wa_iplftp TO it_iplftp.

  ENDLOOP.

  CLEAR it_cmdout.
  REFRESH it_cmdout.

ENDFORM.                    ' F_GET_FILE_FTP

*&---------------------------------------------------------------------*
*&      Form  F_PROCESSA_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_processa_file USING p_p_arquivo.

  DATA l_tabix TYPE sy-tabix.

  CLEAR: wa,
         t_arquivo,
         t_arquivo_aux,
         t_arquivo_end,
         wa_arquivo,
         t_log,
         wa_log.

  REFRESH: t_arquivo,
           t_arquivo_aux,
           t_arquivo_end,
           t_log.


  LOOP AT itab INTO wa.

    CASE wa-name.
      WHEN 'codigo'.
        wa_arquivo-codigo     = wa-value.
      WHEN 'desc_ncm'.
        wa_arquivo-desc_ncm   = wa-value.
      WHEN 'uni_med'.
        wa_arquivo-uni_med    = wa-value.
      WHEN 'sigla'.
        wa_arquivo-sigla      = wa-value.
      WHEN 'nt'.
        wa_arquivo-nt         = wa-value.
      WHEN 'aliquota'.
        wa_arquivo-aliquota   = wa-value.
      WHEN 'base_legal'.
        wa_arquivo-base_legal = wa-value.
      WHEN OTHERS.
    ENDCASE.

    IF  wa-name EQ 'base_legal'.
      APPEND wa_arquivo TO t_arquivo.
      CLEAR wa_arquivo.
    ENDIF.

  ENDLOOP.

  SORT t_arquivo BY sigla.
  DELETE t_arquivo WHERE sigla EQ 'II'. 'Imposto de Importação

  SORT t_arquivo BY codigo.
  DELETE t_arquivo WHERE codigo EQ space.

  SORT t_arquivo BY desc_ncm.
  DELETE t_arquivo WHERE desc_ncm EQ space.

  SORT t_arquivo BY base_legal.
  DELETE t_arquivo WHERE base_legal EQ space.



*  DELETE t_arquivo WHERE codigo NE '4822.10.00'. 'teste
  break carloshp.

  t_arquivo_aux[] = t_arquivo[].

  SORT t_arquivo_aux BY codigo.
  DELETE ADJACENT DUPLICATES FROM t_arquivo_aux COMPARING codigo.

  LOOP AT t_arquivo_aux INTO wa_arquivo_aux.
    l_tabix = sy-tabix.

    IF wa_arquivo_aux-aliquota IS INITIAL OR wa_arquivo_aux-aliquota(3) EQ '0.0'.
      READ TABLE t_arquivo INTO wa_arquivo WITH KEY codigo = wa_arquivo_aux-codigo.
      IF sy-subrc EQ 0.
        IF wa_arquivo-aliquota IS NOT INITIAL AND wa_arquivo-aliquota(3) NE '0.0'.
          wa_arquivo_aux-aliquota = wa_arquivo-aliquota.
        ENDIF.
      ENDIF.
    ENDIF.

    MODIFY t_arquivo_aux FROM wa_arquivo_aux INDEX l_tabix.

  ENDLOOP.

  CLEAR t_arquivo.
  REFRESH t_arquivo.

  t_arquivo[] = t_arquivo_aux[].


  LOOP AT t_arquivo INTO wa_arquivo.

    PERFORM f_check_ncm_valido USING wa_arquivo-codigo
                               CHANGING sy-subrc.

    IF sy-subrc EQ 9.
      CONTINUE.
    ENDIF.

* Cadastro NCM
    PERFORM f_update_t604f USING wa_arquivo-codigo
                           CHANGING sy-subrc.

    wa_log-mandt   = sy-mandt.
    wa_log-codigo  = wa_arquivo-codigo.
    wa_log-file_import = p_p_arquivo.
    wa_log-usuario = sy-uname.
    wa_log-data_a  = sy-datum.
    wa_log-ret_1   = sy-subrc.

* Atualiza Texto NCM
    PERFORM f_update_t604n USING wa_arquivo-codigo
                                 wa_arquivo-desc_ncm
                           CHANGING sy-subrc.

    wa_log-ret_2  = sy-subrc.

* Cadastra Alíquota IPI.
    PERFORM f_update_j_1btxip1 USING wa_arquivo-codigo
                                     wa_arquivo-aliquota
                                     wa_arquivo-base_legal
                               CHANGING sy-subrc.

    wa_log-ret_3 = sy-subrc.

    MODIFY ztbmm115 FROM wa_log.
    COMMIT WORK.

  ENDLOOP.

ENDFORM.                    ' F_PROCESSA_FILE

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_T604F
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ARQUIVO_CODIGO  text
*      <--P_SY_SUBRC  text
*----------------------------------------------------------------------*
FORM f_update_t604f  USING    p_wa_arquivo_codigo
                     CHANGING p_sy_subrc.

  DATA wa_t604f TYPE t604f.
  CLEAR wa_t604f.

  wa_t604f-mandt = sy-mandt.
  wa_t604f-land1 = 'BR'.
  wa_t604f-steuc = p_wa_arquivo_codigo.
  MODIFY t604f FROM wa_t604f.
  COMMIT WORK.

  p_sy_subrc = sy-subrc.

ENDFORM.                    ' F_UPDATE_T604F

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_T604N
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ARQUIVO_CODIGO  text
*      -->P_WA_ARQUIVO_DESC_NCM  text
*      <--P_SY_SUBRC  text
*----------------------------------------------------------------------*
FORM f_update_t604n  USING    p_wa_arquivo_codigo
                              p_wa_arquivo_desc_ncm
                     CHANGING p_sy_subrc.

  DATA wa_t604n TYPE t604n.
  CLEAR wa_t604n.

  wa_t604n-mandt = sy-mandt.
  wa_t604n-spras = 'PT'.
  wa_t604n-land1 = 'BR'.
  wa_t604n-steuc = p_wa_arquivo_codigo.

  wa_t604n-text1 = p_wa_arquivo_desc_ncm(60).
  wa_t604n-text2 = p_wa_arquivo_desc_ncm+60(60).
  wa_t604n-text3 = p_wa_arquivo_desc_ncm+120(60).
  wa_t604n-text4 = p_wa_arquivo_desc_ncm+180(60).
  wa_t604n-text5 = p_wa_arquivo_desc_ncm+240(60).

  MODIFY t604n FROM wa_t604n.
  COMMIT WORK.

  p_sy_subrc = sy-subrc.

ENDFORM.                    ' F_UPDATE_T604N

*&---------------------------------------------------------------------*
*&      Form  F_XML_TO_INTERNAL_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_xml_to_internal_table.

  CLEAR: itab.

  REFRESH: itab.

  LOOP AT it_iplftp INTO wa_iplftp.

    docid = wa_iplftp-file_nm.

    CALL FUNCTION 'FTP_SERVER_TO_R3'
      EXPORTING
        handle      = v_hdl
        fname       = docid
      IMPORTING
        blob_length = blob_length
      TABLES
        blob        = bindata.


* Converte XML internal Table
    CALL METHOD lcl_xml_doc->create_with_table
      EXPORTING
        table   = bindata
      RECEIVING
        retcode = v_subrc.


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
          v_value = v_node->get_value( ).
          MOVE v_value TO v_char.

          IF v_char <> cl_abap_char_utilities=>cr_lf.
            wa-name = v_name.
            wa-value = v_value.

            APPEND wa TO itab.
            CLEAR wa.
          ENDIF.

      ENDCASE.

      v_node = v_iterator->get_next( ).

    ENDWHILE.

    PERFORM f_processa_file USING wa_iplftp-file_nm.

    PERFORM f_elimina_ftp.


    wa_iplftp-stat = 'OK'. 'Processado
    MODIFY it_iplftp FROM wa_iplftp.

  ENDLOOP.
* Início alteração - Harley - chamado 195668 - 07/02/2012
  PERFORM desconecta_ftp.
* Fimal - Harley - chamado 195668 - 07/02/2012
ENDFORM.                    ' F_XML_TO_INTERNAL_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DADOS_REL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_dados_rel.

  CLEAR t_ztbmm115.
  REFRESH t_ztbmm115.

  SELECT * FROM ztbmm115 INTO TABLE t_ztbmm115
    WHERE codigo        IN s_cod
      AND data_a        IN s_data
      AND file_import   IN s_file
      AND ret_1         IN s_ret
      AND ret_2         IN s_ret
      AND ret_3         IN s_ret
      AND usuario       IN s_user.

  IF sy-subrc NE 0.
    MESSAGE i398(00) WITH 'Nenhum Registro encontrado!'.
    STOP.
  ENDIF.

ENDFORM.                ' F_GET_DADOS_REL


*&---------------------------------------------------------------------*
*&      Form  F_BUILD_HEADER_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_build_header_alv .

  DATA: ls_line TYPE slis_listheader.

  CLEAR ls_line.
  ls_line-typ  = 'H'.
  ls_line-info = 'LOG de Atualização de Códigos de NCM e Alíquota(s).'.
  APPEND ls_line TO gt_list_top_of_page.

ENDFORM.                    ' F_BUILD_HEADER_ALV

*&---------------------------------------------------------------------*
*&      Form  F_MONTA_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_monta_alv .

  DATA: v_num TYPE i.

  ADD 1 TO v_num.
  d_monta_alv v_num 'CODIGO' 'NCM' '50' 'L' space space space space.

  ADD 1 TO v_num.
  d_monta_alv v_num 'DATA_A' 'Data Proces.' '50' 'L' space space space space.

  ADD 1 TO v_num.
  d_monta_alv v_num 'FILE_IMPORT' 'Arq. Proces.' '50' 'L' space space space space.

  ADD 1 TO v_num.
  d_monta_alv v_num 'RET_1' 'T604F' '50' 'C' space space space space.

  ADD 1 TO v_num.
  d_monta_alv v_num 'RET_2' 'T604N' '50' 'C' space space space space.

  ADD 1 TO v_num.
  d_monta_alv v_num 'RET_3' 'J_1BTXIP1' '50' 'C' space space space space.

  ADD 1 TO v_num.
  d_monta_alv v_num 'USUARIO' 'Atual. feita por' '50' 'L' space space space space.


ENDFORM.                    ' F_MONTA_ALV

*&---------------------------------------------------------------------*
*&      Form  F_SORT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sort_alv .

  SORT t_ztbmm115 BY codigo data_a.

ENDFORM.                    ' F_SORT_ALV

*&---------------------------------------------------------------------*
*&      Form  F_IMPRIME_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_imprime_alv .

  vg_layout-expand_all     = ''.
*  vg_layout-edit           = ''.
  vg_layout-zebra          = 'X'.
*  vg_layout-box_fieldname  = 'SEL'.
*  vg_layout-info_fieldname = 'LINE_COLOR'.


* Dados de Impressão
  vg_print-no_print_listinfos = 'X'.

* Largura ótima
  vg_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_buffer_active         = 'X'
      i_callback_program      = sy-repid
      i_callback_user_command = con_callback_user_local
      i_callback_top_of_page  = 'TOP_OF_PAGE'
      is_layout               = vg_layout
      it_fieldcat             = tg_fieldcat[]
      it_sort                 = t_sort[]
      i_save                  = 'A'
      is_variant              = gs_variant
      it_event_exit           = gt_event_exit
    TABLES
      t_outtab                = t_ztbmm115
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    'f_imprime_alv


*&---------------------------------------------------------------------*
*&      Form  TOP_OF_PAGE
*&---------------------------------------------------------------------*
FORM top_of_page.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      i_logo             = 'PS_LOGO'
      it_list_commentary = gt_list_top_of_page.


ENDFORM.                    'TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  alv_user_command2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->VALUE(UCOMM)     text
*      -->VALUE(SELFIELD)  text
*----------------------------------------------------------------------*
FORM alv_user_command USING value(ucomm)    LIKE sy-ucomm
                             value(selfield) TYPE slis_selfield.

  IF ucomm EQ '&IC1'.

  ENDIF.

ENDFORM.                    'alv_user_command


*&---------------------------------------------------------------------*
*&      Form  F_PROCESSA_DADOS_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_processa_dados_alv .

  LOOP AT t_ztbmm115 INTO wa_ztbmm115.

    CONDENSE: wa_ztbmm115-ret_1,
              wa_ztbmm115-ret_2,
              wa_ztbmm115-ret_3.

    IF wa_ztbmm115-ret_1 EQ '0'.
      wa_ztbmm115-ret_1 = '@S_TL_G@'.
    ELSE.
      wa_ztbmm115-ret_1 = '@S_TL_R@'.
    ENDIF.


    IF wa_ztbmm115-ret_2 EQ '0'.
      wa_ztbmm115-ret_2 = '@S_TL_G@'.
    ELSE.
      wa_ztbmm115-ret_2 = '@S_TL_R@'.
    ENDIF.


    IF wa_ztbmm115-ret_3 EQ '0'.
      wa_ztbmm115-ret_3 = '@S_TL_G@'.
    ELSE.
      wa_ztbmm115-ret_3 = '@S_TL_R@'.
    ENDIF.

    MODIFY t_ztbmm115 FROM wa_ztbmm115.
  ENDLOOP.

ENDFORM.                    ' F_PROCESSA_DADOS_ALV


*&---------------------------------------------------------------------*
*&      Form  F_WRITE_RESULT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_result.

  DATA l_text TYPE c LENGTH 100.

  LOOP AT it_iplftp INTO wa_iplftp WHERE stat EQ 'OK'.
    CLEAR l_text.
    CONDENSE wa_iplftp-file_nm.

    CONCATENATE 'Arquivo:' wa_iplftp-file_nm '->' 'Processado.' INTO l_text SEPARATED BY space.

    WRITE : / l_text.

  ENDLOOP.

ENDFORM.                    ' F_WRITE_RESULT

*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_J_1BTXIP1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ARQUIVO_CODIGO  text
*      -->P_WA_ARQUIVO_ALIQUOTA  text
*      -->P_WA_ARQUIVO_BASE_LEGAL  text
*      <--P_SY_SUBRC  text
*----------------------------------------------------------------------*
FORM f_update_j_1btxip1  USING    p_wa_arquivo_codigo
                                  p_wa_arquivo_aliquota
                                  p_wa_arquivo_base_legal
                         CHANGING p_sy_subrc.

  DATA: wa_j_1btxip1 TYPE j_1btxip1,
        l_validfrom  TYPE j_1btxip1-validfrom,
        l_rate       TYPE j_1btxip1-rate,
        l_tam        TYPE n.


  DATA: l_moff TYPE i,
        l_mlen TYPE i.


  CLEAR: wa_j_1btxip1,
         l_validfrom,
         l_rate,
         l_tam.

  wa_j_1btxip1-mandt      = sy-mandt.
  wa_j_1btxip1-nbmcode    = p_wa_arquivo_codigo.

  PERFORM f_check_validfrom USING p_wa_arquivo_base_legal
                            CHANGING l_validfrom.

  CONDENSE p_wa_arquivo_aliquota NO-GAPS.


  IF p_wa_arquivo_aliquota(3) EQ '0.0'.
    CLEAR p_wa_arquivo_aliquota.
  ENDIF.


  IF p_wa_arquivo_aliquota CA '.0123456789'.

    FIND '.' IN p_wa_arquivo_aliquota MATCH OFFSET sy-fdpos.
    IF sy-subrc EQ 0.
      ADD 2 TO sy-fdpos.
      wa_j_1btxip1-rate     = p_wa_arquivo_aliquota(sy-fdpos).
    ENDIF.
  ENDIF.

  wa_j_1btxip1-validfrom  = l_validfrom.
  wa_j_1btxip1-base       = '100.00'.

  MODIFY j_1btxip1 FROM wa_j_1btxip1.
  COMMIT WORK.

  p_sy_subrc = sy-subrc.


ENDFORM.                    ' F_UPDATE_J_1BTXIP1
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_VALIDFROM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_WA_ARQUIVO_BASE_LEGAL  text
*      <--P_L_VALIDFROM  text
*----------------------------------------------------------------------*
FORM f_check_validfrom  USING    p_p_wa_arquivo_base_legal
                        CHANGING p_l_validfrom.


  DATA: l_size  TYPE i,
        l_datum TYPE sy-datum,
        l_data  TYPE c LENGTH 10,
        l_pos   TYPE i.

  CLEAR: l_size,
         l_datum,
         l_pos,
         l_data.


  l_size = STRLEN( p_p_wa_arquivo_base_legal ).

  l_pos = ( l_size - 10 ).

  l_data = p_p_wa_arquivo_base_legal+l_pos(10).

*  CONCATENATE l_data+6(4) l_data+3(2) l_data(2) INTO l_datum.

  TRANSLATE l_data USING '/.'.

  CALL FUNCTION 'CONVERSION_EXIT_INVDT_INPUT'
    EXPORTING
      input  = l_data
    IMPORTING
      output = p_l_validfrom.


ENDFORM.                    ' F_CHECK_VALIDFROM


*&---------------------------------------------------------------------*
*&      Form  F_CHECK_NCM_VALIDO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_WA_ARQUIVO_CODIGO  text
*      <--P_SY_SUBRC  text
*----------------------------------------------------------------------*
FORM f_check_ncm_valido  USING    p_wa_arquivo_codigo
                         CHANGING p_sy_subrc.


  DATA: result_tab TYPE match_result_tab,
        l_lines    TYPE sy-tabix.

  CLEAR l_lines.

  FIND ALL OCCURRENCES OF REGEX '[0-9]'
       IN p_wa_arquivo_codigo
       RESULTS result_tab.


  DESCRIBE TABLE result_tab LINES l_lines.

  IF l_lines LT 8.
    p_sy_subrc = 9.
  ENDIF.

ENDFORM.                    ' F_CHECK_NCM_VALIDO


*&---------------------------------------------------------------------*
*&      Form  F_ELIMINA_FTP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_elimina_ftp .

  CLEAR: blob_length,
       bindata,
       bindata[].

* Início alteração - Harley - chamado 195668 - 07/02/2012
  CALL FUNCTION 'FTP_DISCONNECT'
    EXPORTING
      handle = v_hdl
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'RFC_CONNECTION_CLOSE'
    EXPORTING
      destination = c_rfcdest
    EXCEPTIONS
      OTHERS      = 1.

*  CALL 'AB_RFC_X_SCRAMBLE_STRING' ID 'SOURCE' FIELD p_pwd ID 'KEY'         FIELD c_key
*                                  ID 'SCR'    FIELD 'X'   ID 'DESTINATION' FIELD p_pwd
*                                  ID 'DSTLEN' FIELD v_slen.
*
*  SET EXTENDED CHECK OFF.

*  v_slen = STRLEN( p_pwd ).
*
*  CALL FUNCTION 'HTTP_SCRAMBLE'
*    EXPORTING
*      SOURCE      = p_pwd
*      sourcelen   = v_slen
*      key         = c_key
*    IMPORTING
*      destination = p_pwd.
* Início alteração - Harley - chamado 195668 - 07/02/2012

  CALL FUNCTION 'FTP_CONNECT'
    EXPORTING
      user            = p_user
      password        = p_pwd
      host            = p_host
      rfc_destination = c_rfcdest
    IMPORTING
      handle          = v_hdl
    EXCEPTIONS
      not_connected   = 1
      OTHERS          = 2.


  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CONCATENATE 'cd' p_ftp INTO w_cmd SEPARATED BY space.

  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle        = v_hdl
      command       = w_cmd
      compress      = 'N'
    TABLES
      data          = it_cmdout
    EXCEPTIONS
      tcpip_error   = 1
      command_error = 2
      data_error    = 3
      OTHERS        = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*delete from FTP
  CLEAR w_cmd.
  CONCATENATE 'delete' wa_iplftp-file_nm INTO w_cmd SEPARATED BY space.

  CALL FUNCTION 'FTP_COMMAND'
    EXPORTING
      handle        = v_hdl
      command       = w_cmd
      compress      = 'N'
    TABLES
      data          = it_cmdout
    EXCEPTIONS
      command_error = 1
      tcpip_error   = 2.


ENDFORM.                    ' F_ELIMINA_FTP

*&---------------------------------------------------------------------*
*&      Form  DESCONECTA_FTP
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM desconecta_ftp .

  CALL FUNCTION 'FTP_DISCONNECT'
    EXPORTING
      handle = v_hdl
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'RFC_CONNECTION_CLOSE'
    EXPORTING
      destination = c_rfcdest
    EXCEPTIONS
      OTHERS      = 1.

ENDFORM.                    ' DESCONECTA_FTP
