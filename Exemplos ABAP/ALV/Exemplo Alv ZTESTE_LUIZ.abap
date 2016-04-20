*&---------------------------------------------------------------------*
*& Report  ZTESTELUIZ
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

report  ztesteluiz message-id se.

********** ALV Tree - INI
*********CLASS cl_gui_column_tree DEFINITION LOAD.
*********CLASS cl_gui_cfw DEFINITION LOAD.
*********
*********DATA tree1  TYPE REF TO cl_gui_alv_tree_simple.
*********
*********INCLUDE <icon>.
*********INCLUDE bcalv_simple_event_receiver.
*********
*********DATA: "gt_sflight      TYPE sflight OCCURS 0,   " Output-Table
*********      gt_fieldcatalog TYPE lvc_t_fcat,         " Field Catalog
*********      gt_sort1         TYPE lvc_t_sort,         " Sorting Table
*********      ok_code         LIKE sy-ucomm.           " OK-Code
********** ALV Tree - FIM
*********
*********TABLES: t16fc,
*********        t16fs,
*********        ekko,
*********        ekpo,
*********        essr.
*********
*********TYPE-POOLS: icon.
*********
*********INCLUDE zinc_def_alv.
*********
**********&---------------------------------------------------------------------*
**********  Types
**********&---------------------------------------------------------------------*
*********TYPES: BEGIN OF ty_out,
*********        ebeln TYPE essr-ebeln,  " Pedido
*********        ebelp TYPE essr-ebelp,  " Item
*********        lblni TYPE essr-lblni,  " Folha
*********        werks TYPE ekpo-werks,  " Centro
*********        frggr TYPE t16fh-frggr, " Grupo Lib.
*********        frggt TYPE t16fh-frggt, " Grp.lib.
*********        frgct TYPE t16fd-frgct, " Cod.lib
*********        lifnr TYPE ekko-lifnr,  " Cod.fornec.
*********        name1 TYPE lfa1-name1,  " Nome fornec.
*********        netwr TYPE essr-netwr,  " Valor folha
*********        sel   TYPE c,
*********        group TYPE c,            " Grupo para Soma.
*********        stat  TYPE c LENGTH 10,  " Status do Processamento
*********        obs   TYPE c LENGTH 255, " Descri~ção do Status.
*********       END OF ty_out.
*********
*********TYPES: BEGIN OF ty_essr,
*********          ebeln TYPE essr-ebeln,
*********          ebelp TYPE essr-ebelp,
*********          lblni TYPE essr-lblni,
*********          netwr TYPE essr-netwr,
*********          frggr TYPE essr-frggr,
*********          frgsx TYPE essr-frgsx,
*********          frgzu TYPE essr-frgzu,
*********       END OF ty_essr.
*********
*********
*********TYPES: BEGIN OF ty_status,
*********        status  TYPE icon-id,          " S - Sucess | E- Error
*********        ebeln   TYPE essr-ebeln,
*********        lblni   TYPE essr-lblni,
*********        texto   TYPE string,
*********       END OF ty_status.
*********
**********&---------------------------------------------------------------------*
**********  Tabelas Internas
**********&---------------------------------------------------------------------*
*********DATA: tg_out      TYPE STANDARD TABLE OF zstmm_lib_folha    WITH HEADER LINE,
*********      ti_essr     TYPE STANDARD TABLE OF ty_essr   WITH HEADER LINE,
*********      ti_t16fs    TYPE STANDARD TABLE OF t16fs     WITH HEADER LINE,
*********      ti_ekko     TYPE STANDARD TABLE OF ekko      WITH HEADER LINE,
*********      ti_ekpo     TYPE STANDARD TABLE OF ekpo      WITH HEADER LINE,
*********      ti_lfa1     TYPE STANDARD TABLE OF lfa1      WITH HEADER LINE,
*********      ti_t16fh    TYPE STANDARD TABLE OF t16fh     WITH HEADER LINE,
*********      ti_t16fd    TYPE STANDARD TABLE OF t16fd     WITH HEADER LINE,
*********      ti_return   TYPE bapireturn1 OCCURS 0        WITH HEADER LINE,
*********      ti_usuario  TYPE swhactor    OCCURS 0        WITH HEADER LINE,
*********      ti_status   TYPE STANDARD TABLE OF ty_status WITH HEADER LINE,
*********      wa_essr     LIKE LINE OF ti_essr,
*********      wa_t16fs    LIKE LINE OF ti_t16fs,
*********      wa_out      LIKE LINE OF tg_out,
*********      wa_status   LIKE LINE OF ti_status,
*********      gt_out      TYPE zstmm_lib_folha OCCURS 0.
*********
*********
*********DATA: BEGIN OF ti_total OCCURS 0,
*********        ebeln LIKE ekko-lifnr,
*********        netwr LIKE essr-netwr,
**********        brtwr LIKE ekpo-brtwr,
**********        gesbu TYPE p DECIMALS 2,
*********      END OF ti_total.
*********
*********DATA: BEGIN OF xt16fg OCCURS 10.            "Grupos de liberação
*********        INCLUDE STRUCTURE t16fg.
*********DATA: END OF xt16fg.
*********
*********DATA: BEGIN OF xt16fc OCCURS 10.            "Code de Liberação
*********        INCLUDE STRUCTURE t16fc.
*********DATA: END OF xt16fc.
*********
**********&---------------------------------------------------------------------*
**********  Variáveis
**********&---------------------------------------------------------------------*
*********DATA: vl_cont   TYPE i,
*********      vl_len    TYPE i,
*********      vl_tabix  TYPE sy-tabix.
*********
*********DATA: vl_indice TYPE i,
*********      vl_index  TYPE c,
*********      vl_field  TYPE c LENGTH 50,
*********      vl_auth   TYPE c.
*********
**********&---------------------------------------------------------------------*
**********  FIELD SYMBOLS
**********&---------------------------------------------------------------------*
*********FIELD-SYMBOLS: <fs_field>    TYPE ANY.
*********
**********&---------------------------------------------------------------------*
**********  Constantes
**********&---------------------------------------------------------------------*
*********CONSTANTS: c_x TYPE c VALUE 'X'.
*********
*********
**********&---------------------------------------------------------------------*
********** Tela
**********&---------------------------------------------------------------------*
**********SELECTION-SCREEN --- Bloco 1 - Liberação. *************************
*********SELECTION-SCREEN BEGIN OF BLOCK liberacao WITH FRAME TITLE text-t01.
*********PARAMETERS:      p_frgco  TYPE  t16fc-frgco OBLIGATORY.
*********SELECT-OPTIONS:  s_frggr  FOR   t16fc-frggr.
*********SELECTION-SCREEN END OF BLOCK liberacao.
*********
**********SELECTION-SCREEN --- Bloco 2 - Pedido **********************************
*********SELECTION-SCREEN BEGIN OF BLOCK pedido WITH FRAME TITLE text-t02.
*********SELECT-OPTIONS:  s_ebeln  FOR  ekko-ebeln,
*********                 s_aedat  FOR  ekko-aedat,
*********                 s_bsart  FOR  ekko-bsart,
*********                 s_lifnr  FOR  ekko-lifnr,
*********                 s_ekorg  FOR  ekko-ekorg,
*********                 s_ekrgp  FOR  ekko-ekgrp,
*********                 s_werks  FOR  ekpo-werks,
*********                 s_matkl  FOR  ekpo-matkl.
*********SELECTION-SCREEN END OF BLOCK pedido.
*********
**********SELECTION-SCREEN --- Bloco 3 - Folha ***********************************
*********SELECTION-SCREEN BEGIN OF BLOCK folha WITH FRAME TITLE text-t03.
*********SELECT-OPTIONS:  s_lblni  FOR  essr-lblni,
*********                 s_lblne  FOR  essr-lblne,
*********                 s_erdat  FOR  essr-erdat,
*********                 s_banfn  FOR  essr-banfn.
*********SELECTION-SCREEN END OF BLOCK folha.
*********
*********
**********----------------------------------------------------------------------*
**********  AT SELECTION-SCREEN                                                 *
**********----------------------------------------------------------------------*
*********AT SELECTION-SCREEN ON BLOCK liberacao.      " Chega perfil do usuário
*********  PERFORM check_frg.
*********
*********
**********&---------------------------------------------------------------------*
********** Processamento
**********&---------------------------------------------------------------------*
*********START-OF-SELECTION.
*********
*********  PERFORM f_seleciona_dados.
*********
*********  PERFORM f_processa_dados.
*********
*********  IF tg_out[] IS INITIAL.
*********    MESSAGE 'Não houveram registros para esta seleção.' TYPE 'I'.
*********    EXIT.
*********  ELSE.
*********    LOOP AT tg_out INTO wa_out.
*********      APPEND wa_out TO gt_out.
*********    ENDLOOP.
********** Chama tela do ALV Tree
*********    CALL SCREEN 100.
*********
*********  ENDIF.
*********
*********END-OF-SELECTION.
*********
*********
*********
**********&---------------------------------------------------------------------*
**********&      Form  BUILD_FIELDCATALOG
**********&---------------------------------------------------------------------*
**********  This subroutine is used to build the field catalog for the ALV list
**********----------------------------------------------------------------------*
*********FORM build_fieldcatalog.
*********
********** get fieldcatalog
*********  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
*********    EXPORTING
*********      i_structure_name = 'ZSTMM_LIB_FOLHA' "Estrutura a ser exibida no ALV
*********    CHANGING
*********      ct_fieldcat      = gt_fieldcatalog.
*********
********** Modificações nos campos
*********  DATA: ls_fieldcatalog TYPE lvc_s_fcat.
*********  LOOP AT gt_fieldcatalog INTO ls_fieldcatalog.
*********    CASE ls_fieldcatalog-fieldname.
*********      WHEN 'EBELN'. "OR 'EBELP' OR 'LBLNI'.
*********        ls_fieldcatalog-no_out = 'X'.
*********        ls_fieldcatalog-key    = ''.
*********      WHEN 'NETWR'.
*********        ls_fieldcatalog-do_sum = 'X'.
*********    ENDCASE.
*********    MODIFY gt_fieldcatalog FROM ls_fieldcatalog.
*********  ENDLOOP.
*********
*********ENDFORM.                               " BUILD_FIELDCATALOG
**********&---------------------------------------------------------------------*
**********&      Form  BUILD_SORT_TABLE
**********&---------------------------------------------------------------------*
********** This subroutine is used to build the sort table or the sort criteria
**********----------------------------------------------------------------------*
*********
*********FORM build_sort_table.
*********
*********  DATA ls_sort_wa TYPE lvc_s_sort.
*********
********** create sort-table
*********  ls_sort_wa-spos = 1.
*********  ls_sort_wa-fieldname = 'EBELN'.
*********  ls_sort_wa-up = 'X'.
*********  ls_sort_wa-subtot = 'X'.
*********  APPEND ls_sort_wa TO gt_sort1.
*********
**********  ls_sort_wa-spos = 2.
**********  ls_sort_wa-fieldname = 'EBELP'.
**********  ls_sort_wa-up = 'X'.
**********  ls_sort_wa-subtot = 'X'.
**********  APPEND ls_sort_wa TO gt_sort1.
*********
**********  ls_sort_wa-spos = 3.
**********  ls_sort_wa-fieldname = 'FLDATE'.
**********  ls_sort_wa-up = 'X'.
**********  APPEND ls_sort_wa TO gt_sort1.
*********
*********ENDFORM.                               " BUILD_SORT_TABLE
**********&---------------------------------------------------------------------*
**********&      Module  PBO  OUTPUT
**********&---------------------------------------------------------------------*
**********   Esta rotina é usada para construir o ALV Tree
**********----------------------------------------------------------------------*
*********MODULE pbo OUTPUT.
*********
*********  IF tree1 IS INITIAL.
********** Inicia o Custon Control
*********    PERFORM init_tree.
*********  ENDIF.
*********  SET PF-STATUS 'ZSTATUS'.
*********
*********ENDMODULE.                             " PBO  OUTPUT
*********
**********&---------------------------------------------------------------------*
**********&      Module  PAI  INPUT
**********&---------------------------------------------------------------------*
********** This subroutine is used to handle the navigation on the screen
**********----------------------------------------------------------------------*
*********MODULE pai INPUT.
*********
*********  CASE ok_code.
*********    WHEN '&F03' OR '&F15' OR '&F12'. "'EXIT' OR 'BACK' OR 'CANC'.
*********      PERFORM exit_program.
*********
*********    WHEN OTHERS.
*********      CALL METHOD cl_gui_cfw=>dispatch.
*********
*********  ENDCASE.
*********
*********  CLEAR ok_code.
*********
*********ENDMODULE.                             " PAI  INPUT
*********
**********&---------------------------------------------------------------------*
**********&      Form  exit_program
**********&---------------------------------------------------------------------*
**********       free object and leave program
**********----------------------------------------------------------------------*
*********FORM exit_program.
*********
*********  CALL METHOD tree1->free.
*********  LEAVE PROGRAM.
*********
*********ENDFORM.                               " exit_program
*********
**********&---------------------------------------------------------------------*
**********&      Form  register_events
**********&---------------------------------------------------------------------*
**********  Handling the events in the ALV Tree control in backend
**********----------------------------------------------------------------------*
*********FORM register_events.
********** define the events which will be passed to the backend
*********  DATA: lt_events TYPE cntl_simple_events,
*********        l_event TYPE cntl_simple_event.
*********
********** define the events which will be passed to the backend
*********  l_event-eventid = cl_gui_column_tree=>eventid_node_context_menu_req.
*********  APPEND l_event TO lt_events.
*********  l_event-eventid = cl_gui_column_tree=>eventid_item_context_menu_req.
*********  APPEND l_event TO lt_events.
*********  l_event-eventid = cl_gui_column_tree=>eventid_header_context_men_req.
*********  APPEND l_event TO lt_events.
*********  l_event-eventid = cl_gui_column_tree=>eventid_expand_no_children.
*********  APPEND l_event TO lt_events.
*********  l_event-eventid = cl_gui_column_tree=>eventid_header_click.
*********  APPEND l_event TO lt_events.
*********  l_event-eventid = cl_gui_column_tree=>eventid_item_keypress.
*********  APPEND l_event TO lt_events.
*********
*********  CALL METHOD tree1->set_registered_events
*********    EXPORTING
*********      events                    = lt_events
*********    EXCEPTIONS
*********      cntl_error                = 1
*********      cntl_system_error         = 2
*********      illegal_event_combination = 3.
*********
********** set Handler
*********  DATA: l_event_receiver TYPE REF TO lcl_tree_event_receiver.
*********  CREATE OBJECT l_event_receiver.
*********  SET HANDLER l_event_receiver->on_add_hierarchy_node
*********                                                        FOR tree1.
*********ENDFORM.                               " register_events
*********
**********&---------------------------------------------------------------------*
**********&      Form  build_header
**********&---------------------------------------------------------------------*
**********       build table for header
**********----------------------------------------------------------------------*
*********FORM build_comment USING
*********      pt_list_commentary TYPE slis_t_listheader
*********      p_logo             TYPE sdydo_value.
*********
*********  DATA: ls_line TYPE slis_listheader.
**********
********** LIST HEADING LINE: TYPE H
*********  CLEAR ls_line.
*********  ls_line-typ  = 'H'.
********** LS_LINE-KEY:  NOT USED FOR THIS TYPE
*********  ls_line-info = 'ALV TREE DEMO for SAPTechnical.COM'.
*********  APPEND ls_line TO pt_list_commentary.
*********
*********  p_logo = 'ENJOYSAP_LOGO'.
*********
*********ENDFORM.                    "build_comment
*********
**********&---------------------------------------------------------------------*
**********&      Form  init_tree
**********&---------------------------------------------------------------------*
**********  Building the ALV-Tree for the first time display
**********----------------------------------------------------------------------*
*********
*********FORM init_tree.
*********
********** Monta o catalogo de campos
*********  PERFORM build_fieldcatalog.
*********
*********  PERFORM build_sort_table.
*********
********** create container for alv-tree
*********  DATA: l_tree_container_name(30) TYPE c,
*********        l_custom_container        TYPE REF TO cl_gui_custom_container.
*********
*********  l_tree_container_name = 'TREE1'. "Nome do Custon Control criado na tela
*********
*********  CREATE OBJECT l_custom_container
*********    EXPORTING
*********      container_name              = l_tree_container_name
*********    EXCEPTIONS
*********      cntl_error                  = 1
*********      cntl_system_error           = 2
*********      create_error                = 3
*********      lifetime_error              = 4
*********      lifetime_dynpro_dynpro_link = 5.
*********
********** create tree control
*********  CREATE OBJECT tree1
*********    EXPORTING
*********      i_parent                    = l_custom_container
*********      i_node_selection_mode       = cl_gui_column_tree=>node_sel_mode_multiple
*********      i_item_selection            = 'X'
*********      i_no_html_header            = ''
*********      i_no_toolbar                = ''
*********    EXCEPTIONS
*********      cntl_error                  = 1
*********      cntl_system_error           = 2
*********      create_error                = 3
*********      lifetime_error              = 4
*********      illegal_node_selection_mode = 5
*********      failed                      = 6
*********      illegal_column_name         = 7.
*********
********** create info-table for html-header
*********  DATA: lt_list_commentary TYPE slis_t_listheader,
*********        l_logo             TYPE sdydo_value.
*********  PERFORM build_comment USING
*********                 lt_list_commentary
*********                 l_logo.
*********
********** repid for saving variants
*********  DATA: ls_variant TYPE disvariant.
*********  ls_variant-report = sy-repid.
*********
********** register events
*********  PERFORM register_events.
*********
********** create hierarchy
*********  CALL METHOD tree1->set_table_for_first_display
*********    EXPORTING
*********      it_list_commentary = lt_list_commentary
*********      i_logo             = l_logo
*********      i_background_id    = 'ALV_BACKGROUND'
*********      i_save             = 'A'
*********      is_variant         = ls_variant
*********    CHANGING
*********      it_sort            = gt_sort1
*********      it_outtab          = gt_out
*********      it_fieldcatalog    = gt_fieldcatalog.
*********
********** expand first level
*********  CALL METHOD tree1->expand_tree
*********    EXPORTING
*********      i_level = 1.
*********
********** optimize column-width
*********  CALL METHOD tree1->column_optimize
*********    EXPORTING
*********      i_start_column = tree1->c_hierarchy_column_name
*********      i_end_column   = tree1->c_hierarchy_column_name.
*********
*********
*********ENDFORM.                    " init_tree
**********&---------------------------------------------------------------------*
**********&      Form  F_SELECIONA_DADOS
**********&---------------------------------------------------------------------*
**********       text
**********----------------------------------------------------------------------*
**********  -->  p1        text
**********  <--  p2        text
**********----------------------------------------------------------------------*
*********FORM f_seleciona_dados .
*********
**********  Folha de registro de serviços.
*********  SELECT  ebeln ebelp lblni netwr frggr frgsx frgzu
*********    INTO TABLE ti_essr
*********    FROM essr
*********   WHERE frgkl = 'A'
*********     AND loekz <> 'X'
*********     AND lblni IN s_lblni
*********     AND lblne IN s_lblne
*********     AND erdat IN s_erdat
*********     AND banfn IN s_banfn
*********     AND frggr IN s_frggr.
*********
*********  SORT ti_essr BY ebeln ebelp.
*********
*********  IF ti_essr[] IS NOT INITIAL.
*********
*********    SELECT * FROM t16fs
*********      INTO TABLE ti_t16fs
*********       FOR ALL ENTRIES IN ti_essr
*********     WHERE frggr EQ ti_essr-frggr.
*********
*********    SORT ti_t16fs BY frggr frgsx.
*********
***********  Texto do Grupo de liberação ----
*********    SELECT * FROM t16fh
*********      INTO TABLE ti_t16fh
*********       FOR ALL ENTRIES IN ti_essr
*********     WHERE frggr = ti_essr-frggr.
*********
*********
***********  Texto do Cod. de liberação ----
*********    SELECT * FROM t16fd
*********      INTO TABLE ti_t16fd
*********       FOR ALL ENTRIES IN ti_essr
*********     WHERE frggr = ti_essr-frggr
*********       AND frgco = p_frgco.
*********
***********  Dados do Documento de Compra ----
*********    SELECT * FROM ekko
*********      INTO TABLE ti_ekko
*********       FOR ALL ENTRIES IN ti_essr
*********     WHERE ebeln EQ ti_essr-ebeln
*********       AND aedat IN s_aedat
*********       AND bsart IN s_bsart
*********       AND lifnr IN s_lifnr
*********       AND ekorg IN s_ekorg
*********       AND ekgrp IN s_ekrgp.
*********
*********    IF ti_ekko[] IS NOT INITIAL.
*********
*********      SELECT * FROM ekpo
*********        INTO TABLE ti_ekpo
*********         FOR ALL ENTRIES IN ti_ekko
*********       WHERE ebeln EQ ti_ekko-ebeln
*********         AND werks IN s_werks
*********         AND matkl IN s_matkl.
*********
***********  Dados do Fornecedor ----
*********      SELECT * FROM lfa1
*********        INTO TABLE ti_lfa1
*********        FOR ALL ENTRIES IN ti_ekko
*********       WHERE lifnr EQ ti_ekko-lifnr.
*********
*********    ENDIF.
*********
*********  ENDIF.
*********
*********ENDFORM.                    " F_SELECIONA_DADOS
**********&---------------------------------------------------------------------*
**********&      Form  F_PROCESSA_DADOS
**********&---------------------------------------------------------------------*
**********       text
**********----------------------------------------------------------------------*
**********  -->  p1        text
**********  <--  p2        text
**********----------------------------------------------------------------------*
*********FORM f_processa_dados .
*********
*********  LOOP AT ti_essr INTO wa_essr.
*********
*********    CLEAR: vl_cont, vl_len.
*********    vl_tabix = sy-tabix.
*********
*********    LOOP AT ti_t16fs INTO wa_t16fs .
*********
***********  Verifica se tem algum nivel de aprovação...
*********      IF wa_t16fs-frgc1 EQ p_frgco OR
*********         wa_t16fs-frgc2 EQ p_frgco OR
*********         wa_t16fs-frgc3 EQ p_frgco OR
*********         wa_t16fs-frgc4 EQ p_frgco OR
*********         wa_t16fs-frgc5 EQ p_frgco OR
*********         wa_t16fs-frgc6 EQ p_frgco OR
*********         wa_t16fs-frgc7 EQ p_frgco OR
*********         wa_t16fs-frgc8 EQ p_frgco.
*********
***********  Verifica qual Code Lib. esta preenchido para adicionar o registro ao contador. ********
*********        CLEAR: vl_indice, vl_index, vl_field.
*********
*********        DO 8 TIMES.
*********          ADD 1 TO vl_indice.
*********          vl_index = vl_indice.
*********
*********          CONCATENATE: '(ZTESTELUIZ)WA_T16FS-FRGC' vl_index INTO vl_field.
*********
*********          ASSIGN (vl_field) TO <fs_field>.
*********          IF <fs_field> IS ASSIGNED .
*********            IF <fs_field> IS INITIAL.
*********              EXIT. "Sai do DO no primeiro registro Vazio.
*********
*********            ELSEIF <fs_field> EQ p_frgco.
*********              CLEAR: vl_cont.
*********              ADD vl_indice TO vl_cont.
*********            ENDIF.
*********
*********            UNASSIGN: <fs_field>.
*********          ENDIF.
*********
*********        ENDDO.
*********
*********        EXIT. " Sai do LOOP da TI_T16FS
*********
*********      ELSE.
*********        ADD 1 TO vl_cont.
*********        CONTINUE.
*********
*********      ENDIF.
*********
*********    ENDLOOP.
*********
*********** Compara contador ao nivel de aprovação, e apaga registros desconsideráveis.****************
*********    vl_len = STRLEN( wa_essr-frgzu ).
*********    ADD 1 TO vl_len.
*********
*********    IF vl_cont NE vl_len.
*********      DELETE ti_essr INDEX vl_tabix.
*********      CONTINUE.
*********
*********** Monta Tabela de Saída **********************************************************************
*********    ELSE.
*********
*********      wa_out-ebeln = wa_essr-ebeln.
*********      wa_out-ebelp = wa_essr-ebelp.
*********      wa_out-netwr = wa_essr-netwr.
*********      wa_out-lblni = wa_essr-lblni.
*********      wa_out-frggr = wa_essr-frggr.
*********
*********** Dados do Centro -------------------------
*********      READ TABLE ti_ekpo WITH KEY ebeln = wa_essr-ebeln
*********                                  ebelp = wa_essr-ebelp.
*********      IF sy-subrc EQ 0.
*********        wa_out-werks = ti_ekpo-werks.
*********      ELSE.
*********        CONTINUE.
*********      ENDIF.
*********
*********** Dados do Fornecedor -------------
*********      READ TABLE ti_ekko WITH KEY ebeln = wa_essr-ebeln.
*********      IF sy-subrc EQ 0.
*********        wa_out-lifnr = ti_ekko-lifnr.
*********
*********        READ TABLE ti_lfa1 WITH KEY lifnr = wa_out-lifnr.
*********        IF sy-subrc EQ 0.
*********          wa_out-name1 = ti_lfa1-name1.
*********        ENDIF.
*********
*********      ELSE.
*********        CONTINUE.
*********      ENDIF.
*********
*********** Texto do grupo de aprovação ----
*********      READ TABLE ti_t16fh WITH KEY frggr = wa_essr-frggr.
*********      IF sy-subrc EQ 0.
*********        wa_out-frggt = ti_t16fh-frggt.
*********      ELSE.
*********        CONTINUE.
*********      ENDIF.
*********
***********  Texto do code de liberação ----
*********      READ TABLE ti_t16fd WITH KEY frggr = wa_essr-frggr.
*********      IF sy-subrc EQ 0.
*********        wa_out-frgct = ti_t16fd-frgct.
*********      ELSE.
*********        CONTINUE.
*********      ENDIF.
*********
**********Valor total por Pedido
*********      IF ti_total-ebeln <> wa_out-ebeln AND
*********        ti_total-ebeln IS NOT INITIAL.
*********        CLEAR: ti_total-netwr.
*********      ENDIF.
*********
*********      ti_total-ebeln = wa_out-ebeln.
**********      ti_total-netwr = wa_out-netwr.
*********      ti_total-netwr = 0.
*********      COLLECT ti_total.
*********
*********      APPEND wa_out TO tg_out.
*********
*********    ENDIF.
*********
*********  ENDLOOP.
*********
*********
*********ENDFORM.                    " F_PROCESSA_DADOS
*********
**********&---------------------------------------------------------------------*
**********&      Form  F_VALIDA_USUARIO
**********&---------------------------------------------------------------------*
**********       text
**********----------------------------------------------------------------------*
**********  -->  p1        text
**********  <--  p2        text
**********----------------------------------------------------------------------*
*********FORM f_valida_usuario .
*********
********** Verifica autorização de usuário.
*********  CLEAR vl_auth.
*********  AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
*********    ID 'FRGGR' FIELD wa_out-frggr
*********    ID 'FRGCO' FIELD p_frgco.
*********  IF sy-subrc EQ 0.
*********    vl_auth = 'X'.
*********  ENDIF.
*********
*********
*********ENDFORM.                    " F_VALIDA_USUARIO
**********&---------------------------------------------------------------------*
**********&      Form  CHECK_FRG
**********&---------------------------------------------------------------------*
**********       text
**********----------------------------------------------------------------------*
**********  -->  p1        text
**********  <--  p2        text
**********----------------------------------------------------------------------*
*********FORM check_frg.
*********  DATA: auth_flag TYPE c.
*********
********** Verifica os grupos de liberação.
*********  SELECT * FROM t16fg INTO TABLE xt16fg
*********                      WHERE frgot = '3'
*********                      AND   frggr IN s_frggr.
*********  IF sy-subrc NE 0.
*********    MESSAGE e163.
*********  ENDIF.
*********
********** Verifica os Codes de Liberação.
*********  SELECT * FROM t16fc INTO TABLE xt16fc
*********                      FOR ALL ENTRIES IN xt16fg
*********                      WHERE frggr EQ xt16fg-frggr
*********                      AND   frgco EQ p_frgco.
*********  IF sy-subrc NE 0.
*********    MESSAGE e161.
*********  ENDIF.
*********
********** Verifica autorização de usuário.
*********  CLEAR auth_flag.
*********  LOOP AT xt16fc.
*********    AUTHORITY-CHECK OBJECT 'M_EINK_FRG'
*********      ID 'FRGGR' FIELD xt16fc-frggr
*********      ID 'FRGCO' FIELD p_frgco.
*********    IF sy-subrc EQ 0.
*********      auth_flag = 'X'.
*********    ENDIF.
*********  ENDLOOP.
*********
*********  IF auth_flag EQ space.
**********    MESSAGE e162 WITH p_frgco.
*********    MESSAGE 'Code de liberação não pertence ao usuário' TYPE 'E'.
*********  ENDIF.
*********
*********ENDFORM.                    " CHECK_FRG

*******************TYPES: BEGIN OF y_perio,
*******************         pernr TYPE ptrv_perio-pernr,
*******************         reinr TYPE ptrv_perio-reinr,
*******************         perio TYPE ptrv_perio-perio,
*******************         pdvrs TYPE ptrv_perio-pdvrs,
*******************         pdatv TYPE ptrv_perio-pdatv,
*******************         pdatb TYPE ptrv_perio-pdatb,
*******************         antrg TYPE ptrv_perio-antrg,
*******************       END OF y_perio.
*******************
*******************DATA: t_perio   TYPE STANDARD TABLE OF y_perio,
*******************      wa_perio  TYPE y_perio.
*******************
*******************DATA: BEGIN OF t_text OCCURS 0,
*******************        line  TYPE char200,
*******************      END OF t_text.
*******************
*******************DATA: v_pdatb     TYPE ptrv_perio-pdatb.
*******************DATA: v_erro      TYPE c,
*******************      v_data(10)  TYPE c.
*******************
*******************
*******************BREAK-POINT.
*******************IF t_perio[] IS NOT INITIAL.
*******************  t_text-line = 'Existe Viagem, com mais de 5 (cinco) dias após retorno, sem prestação de Contas'.
*******************  APPEND t_text.
*******************  CLEAR: t_text.
*******************  LOOP AT t_perio INTO wa_perio.
*******************    WRITE wa_perio-reinr TO v_data.
*******************    CONCATENATE 'Viagem:' v_data INTO t_text-line SEPARATED BY space.
*******************    WRITE wa_perio-pdatv TO v_data.
*******************    CONCATENATE: t_text-line 'data inicio:' v_data INTO t_text-line SEPARATED BY space.
*******************    WRITE wa_perio-pdatb TO v_data.
*******************    CONCATENATE: t_text-line 'data fim:' v_data INTO t_text-line SEPARATED BY space.
*******************    APPEND t_text.
*******************    CLEAR t_text.
*******************  ENDLOOP.
*******************ENDIF.
*******************
*******************DATA: v_titulo TYPE char50.
*******************
*******************v_titulo = 'Viagen(s) pendente(s)'.
*******************
*******************CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY_OK'
*******************  EXPORTING
*******************    endpos_col         = '90'
*******************    endpos_row         = '20'
*******************    startpos_col       = '5'
*******************    startpos_row       = '1'
*******************    titletext          = v_titulo
******************** IMPORTING
********************   CHOISE             = CHOISE
*******************  TABLES
*******************    valuetab           = t_text
*******************  EXCEPTIONS
*******************    BREAK_OFF          = 1
*******************    OTHERS             = 2.
*******************IF sy-subrc <> 0.
******************** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
********************         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
*******************ENDIF.
*******************
*******************BREAK-POINT.


**BREAK-POINT.
**
**DATA: vl_months TYPE pea_scrmm,
**      vl_meses(5)  TYPE n,
**      vl_mes    TYPE month,
**      vl_endda  TYPE d,
**      vl_begda  TYPE d,
**      vl_CALC_DATE  TYPE d,
**      v_year  TYPE  gjahr.
**
**vl_endda = '20121231'.
**vl_begda = '20121001'.
**
*** INI - LCMJ - 20.12.2012 - 2010-0273
**
**  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
**    EXPORTING
**      date            = vl_begda
**      days            = 00 "days
**      months          = 01 "months
**      SIGNUM          = '-'
**      years           = 00 "years
**    IMPORTING
**      CALC_DATE       = vl_CALC_DATE.
*** FIM - LCMJ - 20.12.2012 - 2010-0273
**
**CALL FUNCTION 'HR_HK_DIFF_BT_2_DATES'
**  EXPORTING
**    date1                       = vl_endda
**    date2                       = vl_begda
**    output_format               = '08'
**  IMPORTING
***      years                       = vl_years
**    months                      = vl_months
***      days                        = vl_days
**  EXCEPTIONS
**    overflow_long_years_between = 1
**    invalid_dates_specified     = 2
**    OTHERS                      = 3.
**IF sy-subrc <> 0.
*** MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
***         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
**ENDIF.
**
**vl_meses = vl_months.
**
**vl_mes = vl_begda+4(2).
**v_year = vl_begda(4).
**
**DO vl_meses TIMES.
**  WRITE: vl_mes.
**  IF vl_mes EQ 12.
**    CLEAR vl_mes.
**    add 1 TO v_year.
**  ENDIF.
**  ADD 1 TO vl_mes.
**ENDDO.
**
**BREAK-POINT.
**
**DATA: tl_retro_month_diff TYPE STANDARD TABLE OF  hr99lret_s_month_diff,
**      t_retro_month_diff TYPE STANDARD TABLE OF  hr99lret_s_month_diff.
**
**APPEND LINES OF tl_retro_month_diff TO t_retro_month_diff.
**
**BREAK-POINT.


*********DATA: vl_int  TYPE i,
*********      vl_num(15) TYPE n.
*********
*********BREAK-POINT.
*********vl_num = 2151916910.
*********BREAK-POINT.

***TYPES: BEGIN OF ty_transacao.
***        INCLUDE TYPE zfit033.
***TYPES:   lancr  TYPE markfield,
***       END OF ty_transacao.
***
***DATA: gt_trans_man  TYPE TABLE OF ty_transacao.
***
***DATA: gs_trans_man  TYPE ty_transacao.
***
***
***
***START-OF-SELECTION.
***  CALL SCREEN 0200.
***
***
****&---------------------------------------------------------------------*
****&      Module  STATUS_0200  OUTPUT
****&---------------------------------------------------------------------*
****       text
****----------------------------------------------------------------------*
***MODULE status_0200 OUTPUT.
***  SET PF-STATUS 'STATUS_0200'.
****  SET TITLEBAR 'xxx'.
***
***ENDMODULE.                 " STATUS_0200  OUTPUT
****&---------------------------------------------------------------------*
****&      Module  EXIT_COMMAND_0200  INPUT
****&---------------------------------------------------------------------*
****       text
****----------------------------------------------------------------------*
***MODULE exit_command_0200 INPUT.
***
***  LEAVE TO SCREEN 0.
***
***ENDMODULE.                 " EXIT_COMMAND_0200  INPUT
***
****&SPWIZARD: DECLARATION OF TABLECONTROL 'TC_MANU' ITSELF
***CONTROLS: TC_MANU TYPE TABLEVIEW USING SCREEN 0200.
***
****&SPWIZARD: LINES OF TABLECONTROL 'TC_MANU'
***DATA:     G_TC_MANU_LINES  LIKE SY-LOOPC.
***
***DATA:     OK_CODE LIKE SY-UCOMM.
***
****&SPWIZARD: OUTPUT MODULE FOR TC 'TC_MANU'. DO NOT CHANGE THIS LINE!
****&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
***MODULE TC_MANU_CHANGE_TC_ATTR OUTPUT.
***  DESCRIBE TABLE GT_TRANS_MAN LINES TC_MANU-lines.
***ENDMODULE.
***
****&SPWIZARD: OUTPUT MODULE FOR TC 'TC_MANU'. DO NOT CHANGE THIS LINE!
****&SPWIZARD: GET LINES OF TABLECONTROL
***MODULE TC_MANU_GET_LINES OUTPUT.
***  G_TC_MANU_LINES = SY-LOOPC.
***ENDMODULE.
***
****&SPWIZARD: INPUT MODULE FOR TC 'TC_MANU'. DO NOT CHANGE THIS LINE!
****&SPWIZARD: MODIFY TABLE
***MODULE TC_MANU_MODIFY INPUT.
***  MODIFY GT_TRANS_MAN
***    FROM GS_TRANS_MAN
***    INDEX TC_MANU-CURRENT_LINE.
***ENDMODULE.
***
****&SPWIZARD: INPUT MODULE FOR TC 'TC_MANU'. DO NOT CHANGE THIS LINE!
****&SPWIZARD: PROCESS USER COMMAND
***MODULE TC_MANU_USER_COMMAND INPUT.
***  OK_CODE = SY-UCOMM.
***  PERFORM USER_OK_TC USING    'TC_MANU'
***                              'GT_TRANS_MAN'
***                              ' '
***                     CHANGING OK_CODE.
***  SY-UCOMM = OK_CODE.
***ENDMODULE.
***
****----------------------------------------------------------------------*
****   INCLUDE TABLECONTROL_FORMS                                         *
****----------------------------------------------------------------------*
***
****&---------------------------------------------------------------------*
****&      Form  USER_OK_TC                                               *
****&---------------------------------------------------------------------*
*** FORM USER_OK_TC USING    P_TC_NAME TYPE DYNFNAM
***                          P_TABLE_NAME
***                          P_MARK_NAME
***                 CHANGING P_OK      LIKE SY-UCOMM.
***
****&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
***   DATA: L_OK              TYPE SY-UCOMM,
***         L_OFFSET          TYPE I.
****&SPWIZARD: END OF LOCAL DATA------------------------------------------*
***
****&SPWIZARD: Table control specific operations                          *
****&SPWIZARD: evaluate TC name and operations                            *
***   SEARCH P_OK FOR P_TC_NAME.
***   IF SY-SUBRC <> 0.
***     EXIT.
***   ENDIF.
***   L_OFFSET = STRLEN( P_TC_NAME ) + 1.
***   L_OK = P_OK+L_OFFSET.
****&SPWIZARD: execute general and TC specific operations                 *
***   CASE L_OK.
***     WHEN 'INSR'.                      "insert row
***       PERFORM FCODE_INSERT_ROW USING    P_TC_NAME
***                                         P_TABLE_NAME.
***       CLEAR P_OK.
***
***     WHEN 'DELE'.                      "delete row
***       PERFORM FCODE_DELETE_ROW USING    P_TC_NAME
***                                         P_TABLE_NAME
***                                         P_MARK_NAME.
***       CLEAR P_OK.
***
***     WHEN 'P--' OR                     "top of list
***          'P-'  OR                     "previous page
***          'P+'  OR                     "next page
***          'P++'.                       "bottom of list
***       PERFORM COMPUTE_SCROLLING_IN_TC USING P_TC_NAME
***                                             L_OK.
***       CLEAR P_OK.
****     WHEN 'L--'.                       "total left
****       PERFORM FCODE_TOTAL_LEFT USING P_TC_NAME.
****
****     WHEN 'L-'.                        "column left
****       PERFORM FCODE_COLUMN_LEFT USING P_TC_NAME.
****
****     WHEN 'R+'.                        "column right
****       PERFORM FCODE_COLUMN_RIGHT USING P_TC_NAME.
****
****     WHEN 'R++'.                       "total right
****       PERFORM FCODE_TOTAL_RIGHT USING P_TC_NAME.
****
***     WHEN 'MARK'.                      "mark all filled lines
***       PERFORM FCODE_TC_MARK_LINES USING P_TC_NAME
***                                         P_TABLE_NAME
***                                         P_MARK_NAME   .
***       CLEAR P_OK.
***
***     WHEN 'DMRK'.                      "demark all filled lines
***       PERFORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
***                                           P_TABLE_NAME
***                                           P_MARK_NAME .
***       CLEAR P_OK.
***
****     WHEN 'SASCEND'   OR
****          'SDESCEND'.                  "sort column
****       PERFORM FCODE_SORT_TC USING P_TC_NAME
****                                   l_ok.
***
***   ENDCASE.
***
*** ENDFORM.                              " USER_OK_TC
***
****&---------------------------------------------------------------------*
****&      Form  FCODE_INSERT_ROW                                         *
****&---------------------------------------------------------------------*
*** FORM fcode_insert_row
***               USING    P_TC_NAME           TYPE DYNFNAM
***                        P_TABLE_NAME             .
***
****&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
***   DATA L_LINES_NAME       LIKE FELD-NAME.
***   DATA L_SELLINE          LIKE SY-STEPL.
***   DATA L_LASTLINE         TYPE I.
***   DATA L_LINE             TYPE I.
***   DATA L_TABLE_NAME       LIKE FELD-NAME.
***   FIELD-SYMBOLS <TC>                 TYPE CXTAB_CONTROL.
***   FIELD-SYMBOLS <TABLE>              TYPE STANDARD TABLE.
***   FIELD-SYMBOLS <LINES>              TYPE I.
****&SPWIZARD: END OF LOCAL DATA------------------------------------------*
***
***   ASSIGN (P_TC_NAME) TO <TC>.
***
****&SPWIZARD: get the table, which belongs to the tc                     *
***   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
***   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
***
****&SPWIZARD: get looplines of TableControl                              *
***   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_LINES_NAME.
***   ASSIGN (L_LINES_NAME) TO <LINES>.
***
****&SPWIZARD: get current line                                           *
***   GET CURSOR LINE L_SELLINE.
***   IF SY-SUBRC <> 0.                   " append line to table
***     L_SELLINE = <TC>-LINES + 1.
****&SPWIZARD: set top line                                               *
***     IF L_SELLINE > <LINES>.
***       <TC>-TOP_LINE = L_SELLINE - <LINES> + 1 .
***     ELSE.
***       <TC>-TOP_LINE = 1.
***     ENDIF.
***   ELSE.                               " insert line into table
***     L_SELLINE = <TC>-TOP_LINE + L_SELLINE - 1.
***     L_LASTLINE = <TC>-TOP_LINE + <LINES> - 1.
***   ENDIF.
****&SPWIZARD: set new cursor line                                        *
***   L_LINE = L_SELLINE - <TC>-TOP_LINE + 1.
***
****&SPWIZARD: insert initial line                                        *
***   INSERT INITIAL LINE INTO <TABLE> INDEX L_SELLINE.
***   <TC>-LINES = <TC>-LINES + 1.
****&SPWIZARD: set cursor                                                 *
***   SET CURSOR LINE L_LINE.
***
*** ENDFORM.                              " FCODE_INSERT_ROW
***
****&---------------------------------------------------------------------*
****&      Form  FCODE_DELETE_ROW                                         *
****&---------------------------------------------------------------------*
*** FORM fcode_delete_row
***               USING    P_TC_NAME           TYPE DYNFNAM
***                        P_TABLE_NAME
***                        P_MARK_NAME   .
***
****&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
***   DATA L_TABLE_NAME       LIKE FELD-NAME.
***
***   FIELD-SYMBOLS <TC>         TYPE cxtab_control.
***   FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
***   FIELD-SYMBOLS <WA>.
***   FIELD-SYMBOLS <MARK_FIELD>.
****&SPWIZARD: END OF LOCAL DATA------------------------------------------*
***
***   ASSIGN (P_TC_NAME) TO <TC>.
***
****&SPWIZARD: get the table, which belongs to the tc                     *
***   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
***   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
***
****&SPWIZARD: delete marked lines                                        *
***   DESCRIBE TABLE <TABLE> LINES <TC>-LINES.
***
***   LOOP AT <TABLE> ASSIGNING <WA>.
***
****&SPWIZARD: access to the component 'FLAG' of the table header         *
***     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
***
***     IF <MARK_FIELD> = 'X'.
***       DELETE <TABLE> INDEX SYST-TABIX.
***       IF SY-SUBRC = 0.
***         <TC>-LINES = <TC>-LINES - 1.
***       ENDIF.
***     ENDIF.
***   ENDLOOP.
***
*** ENDFORM.                              " FCODE_DELETE_ROW
***
****&---------------------------------------------------------------------*
****&      Form  COMPUTE_SCROLLING_IN_TC
****&---------------------------------------------------------------------*
****       text
****----------------------------------------------------------------------*
****      -->P_TC_NAME  name of tablecontrol
****      -->P_OK       ok code
****----------------------------------------------------------------------*
*** FORM COMPUTE_SCROLLING_IN_TC USING    P_TC_NAME
***                                       P_OK.
****&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
***   DATA L_TC_NEW_TOP_LINE     TYPE I.
***   DATA L_TC_NAME             LIKE FELD-NAME.
***   DATA L_TC_LINES_NAME       LIKE FELD-NAME.
***   DATA L_TC_FIELD_NAME       LIKE FELD-NAME.
***
***   FIELD-SYMBOLS <TC>         TYPE cxtab_control.
***   FIELD-SYMBOLS <LINES>      TYPE I.
****&SPWIZARD: END OF LOCAL DATA------------------------------------------*
***
***   ASSIGN (P_TC_NAME) TO <TC>.
****&SPWIZARD: get looplines of TableControl                              *
***   CONCATENATE 'G_' P_TC_NAME '_LINES' INTO L_TC_LINES_NAME.
***   ASSIGN (L_TC_LINES_NAME) TO <LINES>.
***
***
****&SPWIZARD: is no line filled?                                         *
***   IF <TC>-LINES = 0.
****&SPWIZARD: yes, ...                                                   *
***     L_TC_NEW_TOP_LINE = 1.
***   ELSE.
****&SPWIZARD: no, ...                                                    *
***     CALL FUNCTION 'SCROLLING_IN_TABLE'
***          EXPORTING
***               ENTRY_ACT             = <TC>-TOP_LINE
***               ENTRY_FROM            = 1
***               ENTRY_TO              = <TC>-LINES
***               LAST_PAGE_FULL        = 'X'
***               LOOPS                 = <LINES>
***               OK_CODE               = P_OK
***               OVERLAPPING           = 'X'
***          IMPORTING
***               ENTRY_NEW             = L_TC_NEW_TOP_LINE
***          EXCEPTIONS
****              NO_ENTRY_OR_PAGE_ACT  = 01
****              NO_ENTRY_TO           = 02
****              NO_OK_CODE_OR_PAGE_GO = 03
***               OTHERS                = 0.
***   ENDIF.
***
****&SPWIZARD: get actual tc and column                                   *
***   GET CURSOR FIELD L_TC_FIELD_NAME
***              AREA  L_TC_NAME.
***
***   IF SYST-SUBRC = 0.
***     IF L_TC_NAME = P_TC_NAME.
****&SPWIZARD: et actual column                                           *
***       SET CURSOR FIELD L_TC_FIELD_NAME LINE 1.
***     ENDIF.
***   ENDIF.
***
****&SPWIZARD: set the new top line                                       *
***   <TC>-TOP_LINE = L_TC_NEW_TOP_LINE.
***
***
*** ENDFORM.                              " COMPUTE_SCROLLING_IN_TC
***
****&---------------------------------------------------------------------*
****&      Form  FCODE_TC_MARK_LINES
****&---------------------------------------------------------------------*
****       marks all TableControl lines
****----------------------------------------------------------------------*
****      -->P_TC_NAME  name of tablecontrol
****----------------------------------------------------------------------*
***FORM FCODE_TC_MARK_LINES USING P_TC_NAME
***                               P_TABLE_NAME
***                               P_MARK_NAME.
****&SPWIZARD: EGIN OF LOCAL DATA-----------------------------------------*
***  DATA L_TABLE_NAME       LIKE FELD-NAME.
***
***  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
***  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
***  FIELD-SYMBOLS <WA>.
***  FIELD-SYMBOLS <MARK_FIELD>.
****&SPWIZARD: END OF LOCAL DATA------------------------------------------*
***
***  ASSIGN (P_TC_NAME) TO <TC>.
***
****&SPWIZARD: get the table, which belongs to the tc                     *
***   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
***   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
***
****&SPWIZARD: mark all filled lines                                      *
***  LOOP AT <TABLE> ASSIGNING <WA>.
***
****&SPWIZARD: access to the component 'FLAG' of the table header         *
***     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
***
***     <MARK_FIELD> = 'X'.
***  ENDLOOP.
***ENDFORM.                                          "fcode_tc_mark_lines
***
****&---------------------------------------------------------------------*
****&      Form  FCODE_TC_DEMARK_LINES
****&---------------------------------------------------------------------*
****       demarks all TableControl lines
****----------------------------------------------------------------------*
****      -->P_TC_NAME  name of tablecontrol
****----------------------------------------------------------------------*
***FORM FCODE_TC_DEMARK_LINES USING P_TC_NAME
***                                 P_TABLE_NAME
***                                 P_MARK_NAME .
****&SPWIZARD: BEGIN OF LOCAL DATA----------------------------------------*
***  DATA L_TABLE_NAME       LIKE FELD-NAME.
***
***  FIELD-SYMBOLS <TC>         TYPE cxtab_control.
***  FIELD-SYMBOLS <TABLE>      TYPE STANDARD TABLE.
***  FIELD-SYMBOLS <WA>.
***  FIELD-SYMBOLS <MARK_FIELD>.
****&SPWIZARD: END OF LOCAL DATA------------------------------------------*
***
***  ASSIGN (P_TC_NAME) TO <TC>.
***
****&SPWIZARD: get the table, which belongs to the tc                     *
***   CONCATENATE P_TABLE_NAME '[]' INTO L_TABLE_NAME. "table body
***   ASSIGN (L_TABLE_NAME) TO <TABLE>.                "not headerline
***
****&SPWIZARD: demark all filled lines                                    *
***  LOOP AT <TABLE> ASSIGNING <WA>.
***
****&SPWIZARD: access to the component 'FLAG' of the table header         *
***     ASSIGN COMPONENT P_MARK_NAME OF STRUCTURE <WA> TO <MARK_FIELD>.
***
***     <MARK_FIELD> = SPACE.
***  ENDLOOP.
***ENDFORM.                                          "fcode_tc_mark_lines


**************PARAMETERS: p_date  TYPE zfit033-dtlnc.
**************
**************DATA: gs_docheader TYPE bapiache09.
**************
**************DATA: gt_accgl       TYPE TABLE OF bapiacgl09,
**************      gt_accpay      TYPE TABLE OF bapiacap09,
**************      gt_curramount  TYPE TABLE OF bapiaccr09,
**************      gt_return      TYPE TABLE OF bapiret2,
**************      gt_extension   TYPE TABLE OF bapiparex.
**************
**************DATA: gs_accgl       TYPE bapiacgl09,
**************      gs_accpay      TYPE bapiacap09,
**************      gs_curramount  TYPE bapiaccr09,
**************      gs_return      TYPE bapiret2,
**************      gs_extension   TYPE bapiparex.
**************
**************DATA: lv_idx TYPE posnr_acc.
**************
**************DATA: p_trans TYPE zfit033.
**************CONSTANTS: c_real TYPE waers VALUE 'BRL'.
**************
**************START-OF-SELECTION.
**************
**************  p_trans-belnr = '123456790'.
***************p_trans-hbkid = '0111310384'.
**************  p_trans-vlrtr = 10.
**************  p_trans-lifnr = '0004000034'.
**************
**************
**************  BREAK-POINT.
**************  CLEAR: gs_docheader,
**************         gs_curramount,
**************         gs_return,
**************         lv_idx.
**************
**************  REFRESH: gt_curramount,
**************           gt_return.
**************
**************  gs_docheader-username   = sy-uname. "Nome do usuário
**************  gs_docheader-header_txt = 'Transferência bancária'. "Texto de cabeçalho de documento
**************  gs_docheader-comp_code  = 'CE01'. "Empresa
**************  gs_docheader-doc_date   = p_date. "Data no documento
**************  gs_docheader-pstng_date = p_date. "Data de lançamento no documento
**************  gs_docheader-doc_type   = 'SA'. "Tipo de documento
**************  gs_docheader-ref_doc_no = p_trans-belnr. "Nº documento de referência
**************
**************  ADD 1 TO lv_idx.
*************** Preenche item conta razão
**************  gs_accgl-itemno_acc       = lv_idx.
**************
***************   SELECT SINGLE ukont
***************     INTO gs_accgl-gl_account
***************     FROM t042i
***************    WHERE zbukr EQ 'CE01'
***************      AND hbkid EQ p_trans-hbkid
***************      AND zlsch EQ 'S'.
**************
**************  gs_accgl-gl_account = '0111310384'.
**************
**************  gs_accgl-item_text        = 'v_text_1'.
**************  gs_accgl-acct_type        = 'S'.
**************  gs_accgl-doc_type         = gs_docheader-doc_type.
**************  gs_accgl-comp_code        = gs_docheader-comp_code.
***************  gs_accgl-fis_period       = wa_docheader-fis_period.
***************  gs_accgl-fisc_year        = wa_docheader-fisc_year.
***************  gs_accgl-pstng_date       = wa_docheader-pstng_date.
**************
***************  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
***************    EXPORTING
***************      input  = t_result_imp_aux-prctr
***************    IMPORTING
***************      output = gs_accgl-profit_ctr.
**************
**************  APPEND gs_accgl TO gt_accgl.
**************  CLEAR: gs_accgl.
**************
*************** Preenche valor do iten de conta razão
**************  gs_curramount-itemno_acc    = lv_idx.
**************  gs_curramount-currency      = c_real.
**************  gs_curramount-amt_doccur    = p_trans-vlrtr * -1.
**************
**************  APPEND gs_curramount TO gt_curramount.
**************  CLEAR: gs_curramount.
**************
**************
**************  ADD 1 TO lv_idx.
*************** Preenche item fornecedor
**************  gs_accpay-itemno_acc       = lv_idx.
**************  gs_accpay-vendor_no        = p_trans-lifnr.
**************  gs_accpay-item_text        = 'v_text_1'.
***************   gs_accpay-acct_type        = 'K'.
***************   gs_accpay-doc_type         = gs_docheader-doc_type.
**************  gs_accpay-comp_code        = gs_docheader-comp_code.
***************  gs_accgl-fis_period       = wa_docheader-fis_period.
***************  gs_accgl-fisc_year        = wa_docheader-fisc_year.
***************  gs_accgl-pstng_date       = wa_docheader-pstng_date.
**************
***************  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
***************    EXPORTING
***************      input  = t_result_imp_aux-prctr
***************    IMPORTING
***************      output = gs_accgl-profit_ctr.
**************
**************  APPEND gs_accpay TO gt_accpay.
**************  CLEAR: gs_accpay.
**************
*************** Preenche valor do iten de conta razão
**************  gs_curramount-itemno_acc    = lv_idx.
**************  gs_curramount-currency      = c_real.
**************  gs_curramount-amt_doccur    = p_trans-vlrtr.
**************
**************  APPEND gs_curramount TO gt_curramount.
**************  CLEAR: gs_curramount.
**************
**************  LOOP AT gt_curramount INTO gs_curramount.
**************    gs_extension-structure   = 'Business_Area'.
**************    gs_extension-valuepart1  = gs_curramount-itemno_acc.
**************    gs_extension-valuepart2  = '0001'.
**************
**************    APPEND gs_extension TO gt_extension.
**************  ENDLOOP.
**************
**************  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
**************    EXPORTING
**************      documentheader          = gs_docheader
***************      CUSTOMERCPD             =
***************      CONTRACTHEADER          =
***************    IMPORTING
***************      OBJ_TYPE                =
***************      OBJ_KEY                 =
***************      OBJ_SYS                 =
**************    TABLES
**************     accountgl               = gt_accgl
***************      ACCOUNTRECEIVABLE       =
**************     accountpayable          = gt_accpay
***************      ACCOUNTTAX              =
**************      currencyamount          = gt_curramount
***************      CRITERIA                =
***************      VALUEFIELD              =
***************      EXTENSION1              =
**************      return                  = gt_return
***************      PAYMENTCARD             =
***************      CONTRACTITEM            =
**************     extension2              = gt_extension
***************      REALESTATE              =
***************      ACCOUNTWT               =
**************            .
**************
**************  BREAK-POINT.

*PARAMETERS: r_01 RADIOBUTTON GROUP a1,
*            r_02 RADIOBUTTON GROUP a1.

*INITIALIZATION.
**  CLEAR: r_01, r_02.
*
*START-OF-SELECTION.
*  BREAK-POINT.
**  INCLUDE zfii001.
*  BREAK-POINT.

******SELECTION-SCREEN BEGIN OF SCREEN 0010 AS SUBSCREEN.
******PARAMETERS: p1    TYPE c LENGTH 10,
******            p2 TYPE c LENGTH 10,
******            p3 TYPE c LENGTH 10.
******SELECTION-SCREEN END OF SCREEN 0010.
******
******SELECTION-SCREEN BEGIN OF SCREEN 0020 AS SUBSCREEN.
******PARAMETERS: q1 TYPE c LENGTH 10,
******            q2 TYPE c LENGTH 10,
******            q3 TYPE c LENGTH 10.
******SELECTION-SCREEN END OF SCREEN 0020.
******
******SELECTION-SCREEN: BEGIN OF TABBED BLOCK mytab FOR 10 LINES,
******                  TAB (20) button1 USER-COMMAND push1,
******                  TAB (20) button2 USER-COMMAND push2,
******                  END OF BLOCK mytab.
******
******INITIALIZATION.
******  button1 = 'Selection Screen 1'.
******  button2 = 'Selection Screen 2'.
******  mytab-prog = sy-repid.
******  mytab-dynnr = 0010.
******  mytab-activetab = 'PUSH1'.
******
******AT SELECTION-SCREEN.
******  CASE sy-dynnr.
******    WHEN 1000.
******      CASE sy-ucomm.
******        WHEN 'PUSH1'.
******          mytab-dynnr = 0010.
******        WHEN 'PUSH2'.
******          mytab-dynnr = 0020.
******        WHEN OTHERS.
******
******      ENDCASE.
******
******  ENDCASE.

************************************************DATA: BEGIN OF t_teste OCCURS 0,
************************************************        flqpos TYPE flqpos,
************************************************      END OF t_teste.
************************************************
************************************************DATA: r_lqpos TYPE RANGE OF flqpos.
************************************************
************************************************DATA: s_lqpos LIKE LINE OF r_lqpos.
************************************************
************************************************PARAMETERS: p_lqpos TYPE flqpos.
************************************************
************************************************BREAK-POINT.
************************************************
************************************************DO 10 TIMES.
************************************************  ADD 3 TO t_teste.
************************************************  APPEND t_teste.
************************************************ENDDO.
************************************************
************************************************s_lqpos-sign    = 'I'.
************************************************s_lqpos-option  = 'BT'.
************************************************s_lqpos-low     = 'F2_111110001'.
************************************************s_lqpos-high    = 'F2_111120020'.
************************************************
************************************************APPEND s_lqpos TO r_lqpos.
************************************************
************************************************s_lqpos-sign    = 'I'.
************************************************s_lqpos-option  = 'BT'.
************************************************s_lqpos-low     = 'F2_111110001'.
************************************************s_lqpos-high    = 'F2_111120020'.
************************************************
************************************************APPEND s_lqpos TO r_lqpos.
************************************************
************************************************s_lqpos-sign    = 'I'.
************************************************s_lqpos-option  = 'BT'.
************************************************s_lqpos-low     = 'F2_111110001'.
************************************************s_lqpos-high    = 'F2_111120020'.
************************************************
************************************************APPEND s_lqpos TO r_lqpos.
************************************************
************************************************s_lqpos-sign    = 'I'.
************************************************s_lqpos-option  = 'BT'.
************************************************s_lqpos-low     = 'F2_111110001'.
************************************************s_lqpos-high    = 'F2_111120020'.
************************************************
************************************************APPEND s_lqpos TO r_lqpos.
************************************************
************************************************s_lqpos-sign    = 'I'.
************************************************s_lqpos-option  = 'BT'.
************************************************s_lqpos-low     = 'F1_111110001'.
************************************************s_lqpos-high    = 'F1_111120020'.
************************************************
************************************************APPEND s_lqpos TO r_lqpos.
************************************************
************************************************s_lqpos-sign    = 'I'.
************************************************s_lqpos-option  = 'BT'.
************************************************s_lqpos-low     = 'F2_111110001'.
************************************************s_lqpos-high    = 'F2_111120020'.
************************************************
************************************************APPEND s_lqpos TO r_lqpos.
************************************************
************************************************s_lqpos-sign    = 'I'.
************************************************s_lqpos-option  = 'BT'.
************************************************s_lqpos-low     = 'F2_111110001'.
************************************************s_lqpos-high    = 'F2_111120020'.
************************************************
************************************************APPEND s_lqpos TO r_lqpos.
************************************************
************************************************IF p_lqpos IN r_lqpos.
************************************************  WRITE: 'OK!!!!!!'.
************************************************ENDIF.
************************************************
************************************************LOOP AT t_teste.
************************************************  LOOP AT r_lqpos INTO s_lqpos.
************************************************    IF s_lqpos-high IS NOT INITIAL.
************************************************      IF p_lqpos BETWEEN s_lqpos-low AND s_lqpos-high.
************************************************        WRITE: sy-tabix.
************************************************        EXIT.
************************************************      ENDIF.
************************************************    ELSE.
************************************************      IF p_lqpos EQ s_lqpos-low.
************************************************        WRITE: sy-tabix.
************************************************        EXIT.
************************************************      ENDIF.
************************************************    ENDIF.
************************************************  ENDLOOP.
************************************************ENDLOOP.
************************************************
************************************************BREAK-POINT.


****DATA: BEGIN OF lt_arq OCCURS 0,
****        dokar     TYPE dms_doc2loio-dokar,
****        doknr     TYPE dms_doc2loio-doknr,
****        lo_index  TYPE dms_doc2loio-lo_index,
****        lo_objid  TYPE dms_doc2loio-lo_objid,
*****      END OF lt_arq,
*****
*****      BEGIN OF lt_arq1 OCCURS 0,
****        file_id   TYPE dms_phio2file-file_id,
****        filename  TYPE dms_phio2file-filename,
****      END OF lt_arq.
****
****BREAK-POINT.
****
****SELECT a~dokar a~doknr a~lo_index a~lo_objid c~file_id c~filename
****  INTO TABLE lt_arq
****  FROM dms_doc2loio AS a
**** INNER JOIN dms_ph_cd1 AS b ON ( a~lo_objid EQ b~loio_id )
**** INNER JOIN dms_phio2file AS c ON ( b~prop08 EQ c~file_id )
**** WHERE dokar EQ 'ZCD'
****   AND doknr EQ '0000000000000010000000004'.
****
****LOOP AT lt_arq.
****  DO.
****    SHIFT lt_arq-filename UP TO '\'.
****    IF sy-subrc NE 0.
****      EXIT.
****    ENDIF.
****    lt_arq-filename = lt_arq-filename+1.
****  ENDDO.
****ENDLOOP.
****
****DATA: ls_docfile  TYPE bapi_doc_files2.
****DATA: lv_index  TYPE dms_doc2loio-lo_index VALUE 2.
****
****WRITE lv_index TO ls_docfile-originaltype.
****CONDENSE ls_docfile-originaltype NO-GAPS.
****
****ls_docfile-documenttype = 'ZCD'.
****ls_docfile-documentnumber = '0000000000000010000000004'.
****ls_docfile-documentpart = '000'.
****ls_docfile-documentversion = '00'.
*****ls_docfile-originaltype = '2'. "C:\Users\NOTE\Documents\SAP\SAP GUI\RelatóriodeMulta_20140109161321.709_X.PDF
*****ls_docfile-originaltype = '1'. "C:\Users\NOTE\Documents\SAP\SAP GUI\RelatóriodeMulta_20140109170557.820_X.PDF
*****ls_docfile-wsapplication = 'PDF'.
*****ls_docfile-docfile = 'C:\Users\NOTE\Documents\SAP\SAP GUI\RelatóriodeMulta_20140109161321.709_X.PDF'.
****ls_docfile-application_id = '0050568148DF1EE486FF843A1FE0AB76'.
*****ls_docfile-application_id = '0050568148DF1EE486FF843A1FE04B76'.
****ls_docfile-file_id = '0050568148DF1EE486FF843A1FE0EB76'.
*****ls_docfile-file_id = '0050568148DF1EE486FF843A1FE08B76'.
****ls_docfile-active_version = 'X'.
****
****DATA: lt_docfiles TYPE TABLE OF bapi_doc_files2 WITH HEADER LINE.
****
****DATA: lv_return TYPE bapiret2,
****      lv_path   TYPE bapi_doc_aux-filename,
****      lv_temp   TYPE c LENGTH 200.
****
****CALL FUNCTION 'TMP_GUI_GET_TEMPPATH'
****  IMPORTING
****    temppath = lv_temp
****  EXCEPTIONS
****    failed   = 1
****    OTHERS   = 2.
****IF sy-subrc <> 0.
****  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
****          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
****ENDIF.
****
****lv_path = lv_temp.
****
****CALL FUNCTION 'BAPI_DOCUMENT_CHECKOUTVIEW2'
****  EXPORTING
****    documenttype        = 'ZCD'
****    documentnumber      = '0000000000000010000000004'
****    documentpart        = '000'
****    documentversion     = '00'
****    documentfile        = ls_docfile
*****   GETSTRUCTURE        = '1'
*****   GETCOMPONENTS       = 'X'
****    originalpath        = lv_path
*****   HOSTNAME            = ' '
*****   GETHEADER           = 'X'
*****   DOCBOMCHANGENUMBER  =
*****   DOCBOMVALIDFROM     =
*****   DOCBOMREVISIONLEVEL =
*****   PF_HTTP_DEST        = ' '
*****   PF_FTP_DEST         = ' '
****  IMPORTING
****    return              = lv_return
****  TABLES
*****   documentstructure   =
****    documentfiles       = lt_docfiles
*****   COMPONENTS          =
****  .
****
****LOOP AT lt_docfiles.
****  CALL FUNCTION 'GUI_RUN'
****    EXPORTING
****      command = lt_docfiles-docfile.
****ENDLOOP.
****
****BREAK-POINT.


*************************DATA: it_rdv     TYPE STANDARD TABLE OF ztbfrt_rdv WITH HEADER LINE.
*************************
*************************START-OF-SELECTION.
*************************  BREAK-POINT.
*************************
*************************  SELECT *
*************************    FROM ztbfrt_rdv
*************************    INTO TABLE it_rdv
*************************   WHERE data_chegada = '20110329'
*************************     AND rdv_orfao  NE 'X'.
*************************
*************************  SORT it_rdv BY veiculo data_chegada hora_chegada DESCENDING.
*************************
*************************  DELETE ADJACENT DUPLICATES FROM it_rdv COMPARING veiculo.
*************************
*************************  CHECK 1 = 2.

tables: mara,
        makt.

types: begin of ty_saida,
         matnr  type mara-matnr,
         mtart  type mara-mtart,
         maktx  type makt-maktx,
       end of ty_saida.

data: t_mara  type table of mara,
      t_makt  type table of makt,
      t_saida type table of ty_saida.

data: t_fieldcat  type slis_t_fieldcat_alv with header line.

data: s_mara  type mara,
      s_makt  type makt,
      s_saida type ty_saida.

data: s_layout  type slis_layout_alv.

select-options: so_matnr for mara-matnr.


start-of-selection.
  perform f_busca_dados.

  perform f_monta_dados.

  perform f_gera_alv.




*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_DADOS
*&---------------------------------------------------------------------*
*       Busca dados nas tabelas
*----------------------------------------------------------------------*
form f_busca_dados .

  select *
    into table t_mara
    from mara
   where matnr in so_matnr.

  if t_mara[] is not initial.
    select *
      into table t_makt
      from makt
       for all entries in t_mara
     where matnr eq t_mara-matnr
       and spras eq sy-langu.
  endif.

endform.                    " F_BUSCA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_DADOS
*&---------------------------------------------------------------------*
*       Monta dados na tabela de saida
*----------------------------------------------------------------------*
form f_monta_dados .

  loop at t_mara into s_mara.
    read table t_makt into s_makt with key matnr = s_mara-matnr.
    if sy-subrc eq 0.
      s_saida-matnr = s_makt-matnr.
      s_saida-mtart = s_mara-mtart.
      s_saida-maktx = s_makt-maktx.

      append s_saida to t_saida.
    endif.
  endloop.

endform.                    " F_MONTA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_GERA_ALV
*&---------------------------------------------------------------------*
*       Mota Saida do relatório
*----------------------------------------------------------------------*
form f_gera_alv .

  t_fieldcat-fieldname      = 'MATNR'.
  t_fieldcat-tabname        = 'T_SAIDA'.
  t_fieldcat-ref_fieldname  = 'MATNR'.
  t_fieldcat-ref_tabname    = 'MARA'.
  t_fieldcat-outputlen      = 18.

  append t_fieldcat.

  t_fieldcat-fieldname      = 'MTART'.
  t_fieldcat-tabname        = 'T_SAIDA'.
  t_fieldcat-ref_fieldname  = 'MTART'.
  t_fieldcat-ref_tabname    = 'MARA'.
  t_fieldcat-outputlen      = 4.

  append t_fieldcat.

  t_fieldcat-fieldname      = 'MAKTX'.
  t_fieldcat-tabname        = 'T_SAIDA'.
  t_fieldcat-ref_fieldname  = 'MAKTX'.
  t_fieldcat-ref_tabname    = 'MAKT'.
  t_fieldcat-outputlen      = 40.

  append t_fieldcat.


  s_layout-zebra             = 'X'.
  s_layout-colwidth_optimize = 'X'.

  call function 'REUSE_ALV_GRID_DISPLAY'
   exporting
*     I_INTERFACE_CHECK                 = ' '
*     I_BYPASSING_BUFFER                = ' '
     i_buffer_active                   = 'X'
     i_callback_program                = sy-repid
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
*     I_CALLBACK_TOP_OF_PAGE            = ' '
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME                  = I_STRUCTURE_NAME
*     I_BACKGROUND_ID                   = ' '
*     I_GRID_TITLE                      = I_GRID_TITLE
*     I_GRID_SETTINGS                   = I_GRID_SETTINGS
     is_layout                         = s_layout
     it_fieldcat                       = t_fieldcat[]
*     IT_EXCLUDING                      = IT_EXCLUDING
*     IT_SPECIAL_GROUPS                 = IT_SPECIAL_GROUPS
*     IT_SORT                           = IT_SORT
*     IT_FILTER                         = IT_FILTER
*     IS_SEL_HIDE                       = IS_SEL_HIDE
*     I_DEFAULT                         = 'X'
*     I_SAVE                            = ' '
*     IS_VARIANT                        = IS_VARIANT
*     IT_EVENTS                         = IT_EVENTS
*     IT_EVENT_EXIT                     = IT_EVENT_EXIT
*     IS_PRINT                          = IS_PRINT
*     IS_REPREP_ID                      = IS_REPREP_ID
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE                 = 0
*     I_HTML_HEIGHT_TOP                 = 0
*     I_HTML_HEIGHT_END                 = 0
*     IT_ALV_GRAPHICS                   = IT_ALV_GRAPHICS
*     IT_HYPERLINK                      = IT_HYPERLINK
*     IT_ADD_FIELDCAT                   = IT_ADD_FIELDCAT
*     IT_EXCEPT_QINFO                   = IT_EXCEPT_QINFO
*     IR_SALV_FULLSCREEN_ADAPTER        = IR_SALV_FULLSCREEN_ADAPTER
*   IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           = E_EXIT_CAUSED_BY_CALLER
*     ES_EXIT_CAUSED_BY_USER            = ES_EXIT_CAUSED_BY_USER
    tables
      t_outtab                          = t_saida
   exceptions
     program_error                     = 1
     others                            = 2
            .
  if sy-subrc <> 0.
* Implement suitable error handling here
  endif.


endform.                    " F_GERA_ALV