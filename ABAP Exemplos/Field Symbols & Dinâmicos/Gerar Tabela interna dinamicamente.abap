*&---------------------------------------------------------------------*
*& Report  ZGERA_TABELA_INTERNA                                        *
*& Autor: André Ferreira - andremd@gmail.com                           *
*&---------------------------------------------------------------------*
REPORT  zcompontes_dinamicos.

*&---------------------------------------------------------------------*
*Tabelas
*&---------------------------------------------------------------------*
TABLES: dd04t, "DD-R/3: textos elementos dados
        dd03l, "Campos tabela
        dd02l, "Tabelas SAP
        dd02t, "DD-R/3: textos de tabelas SAP
        dd07t. "DD: textos p/valores fixos dom.(depend.idioma)

*&---------------------------------------------------------------------*
* TYPE-POOLS
*&---------------------------------------------------------------------*
TYPE-POOLS: slis, "Tipos globais para ALV
            sydes.

*&---------------------------------------------------------------------*
* Tabelas Internas
*&---------------------------------------------------------------------*
DATA: BEGIN OF ti_tab OCCURS 0,
   tabname    LIKE dd03l-tabname,
   fieldname  LIKE dd03l-fieldname,
   keyflag    LIKE dd03l-keyflag,
   rollname   LIKE dd03l-rollname,
   position   LIKE dd03l-position,
   inttype    LIKE dd03l-inttype,
   intlen     LIKE dd03l-intlen,
   scrtext_s  LIKE dd04t-scrtext_s,
   scrtext_m  LIKE dd04t-scrtext_m,
   scrtext_l  LIKE dd04t-scrtext_l,
   tabclass   LIKE dd02l-tabclass,
   nome       LIKE dd02t-ddtext,
   ddtext     LIKE dd07t-ddtext,
   mark,
   ordem(3)      TYPE n.
DATA: END OF ti_tab.

DATA: BEGIN OF ti_tab2 OCCURS 0.
        INCLUDE STRUCTURE ti_tab.
DATA:   alter(3),
        campnou(16).
DATA: END OF ti_tab2.

DATA: BEGIN OF ti_down OCCURS 0,
        linha(72).
DATA: END OF ti_down.

*ALV
DATA:
  v_fieldcat          TYPE  slis_t_fieldcat_alv WITH HEADER LINE,
  ti_listhead         TYPE slis_t_listheader,
  ti_listhead1        TYPE slis_listheader,
  ti_list_header      TYPE slis_t_listheader,
  ti_fieldcat         TYPE slis_t_fieldcat_alv WITH HEADER LINE,
  ti_sort             TYPE slis_sortinfo_alv OCCURS 0 WITH HEADER LINE,
  wc_repid            LIKE sy-repid,
  wc_layout           TYPE slis_layout_alv,
  gt_events           TYPE slis_t_event,
  g_top_of_page       TYPE slis_formname VALUE 'TOP_OF_PAGE',
  gt_list_top_of_page TYPE slis_t_listheader.

*&---------------------------------------------------------------------*
*Variáveis
*&---------------------------------------------------------------------*
DATA:      v_info1(50),
           v_data(10),
           v_hora(10),
           v_erro(50),
           v_linha(10),
           v_flinha(34),
           v_cabec(30),
           v_nome(60),
           v_caminho    LIKE rlgrap-filename,
           v_url(250)   TYPE c,
           v_resp,
           v_fun(2)     TYPE c,
           v_cont(3)    TYPE n,
           v_cont2(3)   TYPE n,
           v_cont3(3)   TYPE n,
           v_ult        LIKE sy-tabix,           "No. linhas da tabela
           v_linhas(10) TYPE n.           "No. linhas da tabela

*&---------------------------------------------------------------------*
*Constants
*&---------------------------------------------------------------------*
CONSTANTS: c_h             VALUE 'H',
           c_rele(50)    VALUE 'ABAP Util - Generator Internal Tables!',
           c_exec(15)      VALUE 'Exec By:',
           c_dpt(15)       VALUE 'Date / Time:',
           c_ntab(23)      VALUE 'Transparent Table:',
           c_ttab(23)      VALUE 'Type of Table:',
           c_linc(23)      VALUE 'Qty. of fields:',
           c_data(5)       VALUE 'Date:',
           c_tipo(5)       VALUE 'Type:',
           c_tipo2(14)     VALUE 'Type of Field:',
           c_comp(8)       VALUE '#Width:',
           c_comp2(17)     VALUE '#Width of Field:',
           c_desc(8)       VALUE '#Desc.:',
           c_like(4)       VALUE 'LIKE',
           c_begin(10)     VALUE 'BEGIN OF',
           c_end(8)        VALUE 'END OF',
           c_ponto         VALUE '.',
           c_velha         VALUE '#',
           c_aster         VALUE '*',
           c_aspas         VALUE '"',
           c_traco         VALUE '-',
           c_virgula       VALUE ',',
           c_3velha(3)     VALUE '###',
           c_mentor(72)    VALUE
'*#By Gambi Plus®# - Sugestões enviar à andremd@gmail.com!!!',
           c_occurs(10)    VALUE 'OCCURS 0,',
           c_x             VALUE 'X',
           c_s             VALUE 'S'.

*&---------------------------------------------------------------------*
*Tela de seleção
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE text-t02.
*Nome da tabela
PARAMETERS: p_tabint   LIKE dd02l-tabname OBLIGATORY.
*Noma da tabela interna
PARAMETERS: p_nome(30) OBLIGATORY.

SELECTION-SCREEN SKIP.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN COMMENT 1(20) text-p03.

SELECTION-SCREEN  BEGIN OF LINE.
PARAMETERS: p_np         RADIOBUTTON GROUP visi DEFAULT 'X' .
SELECTION-SCREEN COMMENT 6(60) text-p01 FOR FIELD p_np.
SELECTION-SCREEN  END OF LINE.

SELECTION-SCREEN  BEGIN OF LINE.
PARAMETERS: p_bw       RADIOBUTTON GROUP visi.
SELECTION-SCREEN COMMENT 6(60) text-p02 FOR FIELD p_bw.
SELECTION-SCREEN  END OF LINE.

*SELECTION-SCREEN SKIP.
*SELECTION-SCREEN SKIP.
*SELECTION-SCREEN PUSHBUTTON 10(25) text-p04
*                   USER-COMMAND US01.
*SELECTION-SCREEN COMMENT 1(50) text-p05.
SELECTION-SCREEN END OF BLOCK  a1.

*&---------------------------------------------------------------------*
*Initialization
*&---------------------------------------------------------------------*
INITIALIZATION.

*&---------------------------------------------------------------------*
*Start-of-selection
*&---------------------------------------------------------------------*
START-OF-SELECTION.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      text = 'Wait...Processing.'.

*Seleção da tabela!!!
  SELECT a~tabname   a~fieldname a~keyflag
         a~rollname  a~position  a~inttype
         a~intlen    b~scrtext_s b~scrtext_m
         b~scrtext_l c~tabclass  n~ddtext
         e~ddtext
    INTO TABLE ti_tab
    FROM dd03l AS a
   INNER JOIN dd04t AS b
      ON a~rollname = b~rollname
   INNER JOIN dd02l AS c
      ON a~tabname  = c~tabname
   INNER JOIN dd02t AS n
      ON c~tabname  = n~tabname
   INNER JOIN dd07l AS d
      ON c~tabclass = d~domvalue_l
   INNER JOIN dd07t AS e
      ON d~domvalue_l = e~domvalue_l
     AND d~as4local   = e~as4local
     AND d~valpos     = e~valpos
   WHERE e~ddlanguage = sy-langu
     AND b~ddlanguage = sy-langu
     AND n~ddlanguage = sy-langu
     AND a~tabname    = p_tabint
     AND d~domname    = 'TABCLASS'
     AND a~fieldname <> 'MANDT'.

  IF NOT sy-subrc IS INITIAL.
*Se a budega num tá traduzida tem que refazer o select em inglês
*Se nem em inglês puxar todos os dados se vire e faça na mão a parada!!
    SELECT a~tabname   a~fieldname a~keyflag
           a~rollname  a~position  a~inttype
           a~intlen    b~scrtext_s b~scrtext_m
           b~scrtext_l c~tabclass  n~ddtext
           e~ddtext
      INTO TABLE ti_tab
      FROM dd03l AS a
     INNER JOIN dd04t AS b
        ON a~rollname = b~rollname
     INNER JOIN dd02l AS c
        ON a~tabname  = c~tabname
     INNER JOIN dd02t AS n
        ON c~tabname  = n~tabname
     INNER JOIN dd07l AS d
        ON c~tabclass = d~domvalue_l
     INNER JOIN dd07t AS e
        ON d~domvalue_l = e~domvalue_l
       AND d~as4local   = e~as4local
       AND d~valpos     = e~valpos
     WHERE e~ddlanguage = 'EN'
       AND b~ddlanguage = 'EN'
       AND n~ddlanguage = 'EN'
       AND a~tabname    = p_tabint
       AND d~domname    = 'TABCLASS'
       AND a~fieldname <> 'MANDT'.
  ENDIF.

  SORT ti_tab BY position.
  DELETE ADJACENT DUPLICATES FROM ti_tab COMPARING position.

  IF ti_tab[] IS INITIAL.
    MESSAGE i011(pc) WITH 'Data not found!'.
    STOP.
  ENDIF.

  DESCRIBE TABLE ti_tab LINES v_linhas.

  PERFORM monta_fieldcat USING :
   'FIELDNAME' 'TI_TAB' 'DD03L' 'FIELDNAME'
   ' '  ' '   ' '   ' '   ' '   ' '   ' '  ' '  ' ',
   'KEYFLAG'   'TI_TAB' 'DD03L'  'KEYFLAG'
   ' '  ' '   ' '   ' '   ' '   ' '   ' '  ' '  ' ',
   'ROLLNAME'  'TI_TAB' 'DD03L'  'ROLLNAME'
   ' '  ' '   ' '   ' '   ' '   ' '   ' '  ' '  ' ',
   'POSITION'  'TI_TAB' 'DD03L'  'POSITION'
   ' '  ' '   ' '   ' '   ' '   ' '   ' '  ' '  ' ',
   'SCRTEXT_L' 'TI_TAB' 'DD04T'  'SCRTEXT_L'
   ' '  ' '   ' '   ' '   ' '   ' '   ' '  ' '  ' '.
*   'ORDEM'     'TI_TAB' ' '  ' '
*   'Ordenação'  ' '   ' '   ' '   ' '   ' '   ' '  'X'  ' '.

  PERFORM eventtab_build USING gt_events[].
  PERFORM comment_build USING gt_list_top_of_page[].
  PERFORM zf_executar_alv.

*&---------------------------------------------------------------------*
*&      FORM  MONTA_FIELDCAT
*&---------------------------------------------------------------------*
FORM monta_fieldcat  USING
          x_field   x_tab   x_ref     x_fil    x_text
          x_sum     x_type  x_just    x_qfield x_checkbox
          x_no_out  x_edit  x_hotspot.

  v_fieldcat-fieldname         =  x_field.
  v_fieldcat-tabname           =  x_tab.
  v_fieldcat-ref_tabname       =  x_ref.
  v_fieldcat-ref_fieldname     =  x_fil.
  v_fieldcat-reptext_ddic      =  x_text.
  v_fieldcat-do_sum            =  x_sum.
  v_fieldcat-inttype           =  x_type.
  v_fieldcat-just              =  x_just.
  v_fieldcat-qfieldname        =  x_qfield.
  v_fieldcat-checkbox          =  x_checkbox.
  v_fieldcat-no_out            =  x_no_out.
  v_fieldcat-edit              =  x_edit.
  v_fieldcat-hotspot           =  x_hotspot.

  APPEND v_fieldcat.
  CLEAR v_fieldcat.

ENDFORM.                               " MONTA_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  EVENTTAB_BUILD
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
FORM eventtab_build  USING rt_events TYPE slis_t_event.

  DATA: ls_event TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = rt_events.
  READ TABLE rt_events WITH KEY name = slis_ev_top_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE g_top_of_page TO ls_event-form.
    APPEND ls_event TO rt_events.
  ENDIF.

ENDFORM.                    " EVENTTAB_BUILD
*&---------------------------------------------------------------------*
*&      Form  COMMENT_BUILD
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*      -->P_GT_LIST_TOP_OF_PAGE[]  text
*----------------------------------------------------------------------*
FORM comment_build  USING  lt_top_of_page TYPE slis_t_listheader..

  DATA: ls_line TYPE slis_listheader.

  CLEAR: ls_line.

  ls_line-typ  = c_h.
  ls_line-info = c_rele.
  APPEND ls_line TO lt_top_of_page.
  CLEAR ls_line.

  READ TABLE ti_tab INDEX 1.

*-- Nome
  ls_line-typ     = c_s.
  ls_line-key     = c_ntab.
  IF ti_tab-nome <> space.
    CONCATENATE p_tabint ' - ' ti_tab-nome INTO v_info1.
  ELSE.
    WRITE p_tabint TO v_info1.
  ENDIF.
  WRITE v_info1 TO ls_line-info.
  APPEND ls_line TO lt_top_of_page.
  CLEAR: ls_line, v_info1.

*-- Tipo
  ls_line-typ     = c_s.
  ls_line-key     = c_ttab.
  IF ti_tab-ddtext <> space.
    WRITE ti_tab-ddtext TO v_info1.
  ELSE.
    WRITE 'Uknwon'  TO v_info1.
  ENDIF.
  WRITE v_info1 TO ls_line-info.
  APPEND ls_line TO lt_top_of_page.
  CLEAR: ls_line, v_info1.

*-- Campos
  ls_line-typ     = c_s.
  ls_line-key     = c_linc.
  WRITE v_linhas TO v_info1.
  PACK v_info1 TO v_info1.
  WRITE v_info1 TO ls_line-info.
  APPEND ls_line TO lt_top_of_page.
  CLEAR: ls_line, v_info1.

*Usuário
  ls_line-typ     = c_s.
  ls_line-key     = c_exec.
  WRITE sy-uname TO v_info1.
  WRITE  v_info1 TO ls_line-info.
  APPEND ls_line TO lt_top_of_page.
  CLEAR: ls_line, v_info1.

*-- Data e Hora
  ls_line-typ     = c_s.
  ls_line-key     = c_dpt.
  WRITE sy-datum TO v_data.
  WRITE sy-uzeit TO v_hora.
  CONCATENATE v_data '-'  v_hora 'hs' INTO v_info1 SEPARATED BY space.
  WRITE  v_info1 TO ls_line-info.
  APPEND ls_line TO lt_top_of_page.
  CLEAR: ls_line, v_info1.

ENDFORM.                    " COMMENT_BUILD
*&---------------------------------------------------------------------*
*&     FORM  TOP_OF_PAGE                                               *
*&---------------------------------------------------------------------*
FORM top_of_page.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      i_logo             = 'ENJOYSAP_LOGO'  "ENJOYSAP_LOGO
      it_list_commentary = gt_list_top_of_page.

ENDFORM.                               " top_of_page
*&---------------------------------------------------------------------
*
*&      Form  F_STATUS - GUI ALV
*&---------------------------------------------------------------------
*
FORM f_status USING rt_extab TYPE slis_t_extab.             "#EC CALLED

  SET PF-STATUS 'ZSTATUSGUI'.

ENDFORM.                    "f_status
*&---------------------------------------------------------------------*
*&      Form  zf_executar_alv_infor
*&---------------------------------------------------------------------*
FORM zf_executar_alv.

* Preenchendo algumas opções de impressão (Não é obrigatório)
  wc_layout-expand_all        = 'X'.   "Abrir subitens
  wc_layout-colwidth_optimize = 'X'.   "Largura melhor possível coluna
*  wc_layout-edit              = 'X'.  "Não Permitir a edição
  wc_layout-zebra             = 'X'.   "Listagem aparece zebrada.
  wc_repid = sy-repid.

  wc_layout-box_tabname         = 'TI_TAB'.
  wc_layout-box_fieldname       = 'MARK'.
  wc_layout-box_rollname        = space.
  wc_layout-key_hotspot         = c_x.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
       EXPORTING
            i_callback_program       = wc_repid
            i_background_id          = 'ALV_BACKGROUND'
*            i_callback_top_of_page   = 'F_TOP_OF_PAGE'
            i_callback_user_command  = 'F_USER_COMMAND3'
            i_callback_pf_status_set = 'F_STATUS'
            it_fieldcat              = v_fieldcat[]
            is_layout                = wc_layout
            it_sort                  = ti_sort[]
            i_default                = 'X'
            i_save                   = 'A'
            it_events                = gt_events[]
       TABLES
            t_outtab                 = ti_tab
       EXCEPTIONS
            program_error            = 1
            OTHERS                   = 2.

  IF sy-subrc <> 0.
    MESSAGE i011(pc) WITH 'Error generate ALV'.
    STOP.
  ENDIF.

ENDFORM.                    " zf_executar_alv_infor
*&--------------------------------------------------------------------*
*&      Form  F_USER_COMMAND_ANUAL
*&--------------------------------------------------------------------*
FORM f_user_command3  USING ucomm  LIKE sy-ucomm
                            selfield TYPE slis_selfield.

  CLEAR v_cont.
  LOOP AT ti_tab WHERE mark = 'X'.
    v_cont = v_cont + 1.
  ENDLOOP.

  IF v_cont = 0.
    MESSAGE e011(pc) WITH 'Select lines to Internal Table'.
  ELSEIF v_cont = 1.

    CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
      EXPORTING
        defaultoption  = 'Y'
        textline1      = 'Your table has been one field ?'
        textline2      = 'Do you ready generate ?'
        titel          = 'Componente Generation'
        start_column   = 25
        start_row      = 6
        cancel_display = 'X'
      IMPORTING
        answer         = v_resp.

    IF v_resp = 'J'.
      MESSAGE i011(pc) WITH 'Cancel!'.
    ELSE.
      MESSAGE e011(pc) WITH 'Select other lines'.
    ENDIF.

  ENDIF.

  CASE ucomm.

    WHEN 'EXEC'.

      CLEAR v_fun.
      CALL FUNCTION 'K_KKB_POPUP_RADIO3'
        EXPORTING
          i_title   = 'Internal Table Type'
          i_text1   = 'Model 1 - No comment´s'
          i_text2   = 'Model 2 - Simple Comment´s (Recommended)'
          i_text3   = 'Model 3 - Comment + Data type '
          i_default = '1'
        IMPORTING
          i_result  = v_fun
        EXCEPTIONS
          cancel    = 1
          OTHERS    = 2.

      IF sy-subrc IS INITIAL AND v_fun <> space.

        LOOP AT ti_tab WHERE mark = 'X'.
          MOVE-CORRESPONDING ti_tab TO ti_tab2.
          APPEND ti_tab2.
          CLEAR ti_tab2.
        ENDLOOP.

        IF ti_tab2[] IS INITIAL.
          MESSAGE e011(pc) WITH 'Try again'.
        ENDIF.

        LOOP AT ti_tab2.
          CLEAR v_cont2.
        LOOP AT ti_tab2 WHERE fieldname+0(10) = ti_tab2-fieldname+0(10).
            v_cont2 = v_cont2 + 1.

            IF v_cont2 >= 2.
      CONCATENATE ti_tab2-fieldname+0(5) v_cont2 INTO ti_tab2-fieldname.
              MODIFY ti_tab2.
            ENDIF.

          ENDLOOP.
        ENDLOOP.

        CASE v_fun.

*######################################################################*
*#########################Opção 1######################################*
*######################################################################*
          WHEN 1.

*Declaração
            CONCATENATE c_data
                        c_velha
                        c_begin
                        c_velha
                        p_nome
                        c_velha
                        c_occurs
                   INTO ti_down-linha.
            TRANSLATE ti_down-linha USING '# '.
            APPEND ti_down.
            CLEAR ti_down.

            DESCRIBE TABLE ti_tab2 LINES v_ult.

*Linhas
            LOOP AT ti_tab2.
              CLEAR v_linha.
              IF sy-tabix = v_ult.
                v_linha = ti_tab2-fieldname+0(10).
                TRANSLATE v_linha USING ' #'.

                CONCATENATE c_3velha
                            v_linha
                            c_velha
                            c_like
                            c_velha
                            ti_tab2-tabname
                            c_traco
                            ti_tab2-fieldname
                            c_ponto
                       INTO ti_down-linha.
                TRANSLATE ti_down-linha USING '# '.
                APPEND ti_down.
                CLEAR ti_down.
              ELSE.
                v_linha = ti_tab2-fieldname+0(10).
                TRANSLATE v_linha USING ' #'.

                CONCATENATE c_3velha
                            v_linha
                            c_velha
                            c_like
                            c_velha
                            ti_tab2-tabname
                            c_traco
                            ti_tab2-fieldname
                            c_virgula
                       INTO ti_down-linha.
                TRANSLATE ti_down-linha USING '# '.
                APPEND ti_down.
                CLEAR ti_down.
              ENDIF.

            ENDLOOP.

*Declaração final
            CONCATENATE c_data
                        c_velha
                        c_end
                        c_velha
                        p_nome
                        c_ponto
                   INTO ti_down-linha.
            TRANSLATE ti_down-linha USING '# '.
            APPEND ti_down.
            CLEAR ti_down.

*Propaganda!
            WRITE c_mentor TO ti_down-linha.
            APPEND ti_down.
            CLEAR ti_down.

*######################################################################*
*#########################Opção 2######################################*
*######################################################################*
          WHEN 2.

            CLEAR v_nome.
            READ TABLE ti_tab2 INDEX 1.
            IF sy-subrc IS INITIAL.
              v_nome = ti_tab2-nome.
            ENDIF.

            IF v_nome <> space.
              CONCATENATE c_aster
                          v_nome
                     INTO ti_down-linha.
              APPEND ti_down.
              CLEAR ti_down.
            ENDIF.

*Declaração
            CONCATENATE c_data
                        c_velha
                        c_begin
                        c_velha
                        p_nome
                        c_velha
                        c_occurs
                   INTO ti_down-linha.
            TRANSLATE ti_down-linha USING '# '.
            APPEND ti_down.
            CLEAR ti_down.

            DESCRIBE TABLE ti_tab2 LINES v_ult.

*Linhas
            LOOP AT ti_tab2.

              CLEAR v_linha.
              IF sy-tabix = v_ult.
                CLEAR: v_linha, v_flinha.
                v_linha = ti_tab2-fieldname+0(10).
                TRANSLATE v_linha USING ' #'.

                CONCATENATE ti_tab2-tabname
                            c_traco
                            ti_tab2-fieldname
                            c_ponto
                       INTO v_flinha.
                TRANSLATE v_flinha USING ' #'.

                IF ti_tab2-scrtext_m = space.
                  CONCATENATE c_3velha
                              v_linha
                              c_velha
                              c_like
                              c_velha
                              v_flinha
                         INTO ti_down-linha.
                  TRANSLATE ti_down-linha USING '# '.
                  APPEND ti_down.
                  CLEAR ti_down.
                ELSE.
                  CONCATENATE c_3velha
                              v_linha
                              c_velha
                              c_like
                              c_velha
                              v_flinha
                              c_velha
                              c_aspas
                              ti_tab2-scrtext_m+0(17)
                         INTO ti_down-linha.
                  TRANSLATE ti_down-linha USING '# '.
                  APPEND ti_down.
                  CLEAR ti_down.
                ENDIF.
              ELSE.
                CLEAR: v_linha, v_flinha.
                v_linha = ti_tab2-fieldname+0(10).
                TRANSLATE v_linha USING ' #'.

                CONCATENATE ti_tab2-tabname
                            c_traco
                            ti_tab2-fieldname
                            c_virgula
                       INTO v_flinha.
                TRANSLATE v_flinha USING ' #'.

                IF ti_tab2-scrtext_m = space.
                  CONCATENATE c_3velha
                              v_linha
                              c_velha
                              c_like
                              c_velha
                              v_flinha
                         INTO ti_down-linha.
                  TRANSLATE ti_down-linha USING '# '.
                  APPEND ti_down.
                  CLEAR ti_down.
                ELSE.
                  CONCATENATE c_3velha
                              v_linha
                              c_velha
                              c_like
                              c_velha
                              v_flinha
                              c_velha
                              c_aspas
                              ti_tab2-scrtext_m+0(17)
                         INTO ti_down-linha.
                  TRANSLATE ti_down-linha USING '# '.
                  APPEND ti_down.
                  CLEAR ti_down.

                ENDIF.
              ENDIF.

            ENDLOOP.

*Declaração final
            CONCATENATE c_data
                        c_velha
                        c_end
                        c_velha
                        p_nome
                        c_ponto
                   INTO ti_down-linha.
            TRANSLATE ti_down-linha USING '# '.
            APPEND ti_down.
            CLEAR ti_down.

*Propaganda!
            WRITE c_mentor TO ti_down-linha.
            APPEND ti_down.
            CLEAR ti_down.

*######################################################################*
*#########################Opção 3######################################*
*######################################################################*
          WHEN 3.

            CLEAR v_nome.
            READ TABLE ti_tab2 INDEX 1.
            IF sy-subrc IS INITIAL.
              v_nome = ti_tab2-nome.
            ENDIF.

            IF v_nome <> space.
              CONCATENATE c_aster
                          v_nome
                     INTO ti_down-linha.
              APPEND ti_down.
              CLEAR ti_down.
            ENDIF.

*Declaração
            CONCATENATE c_data
                        c_velha
                        c_begin
                        c_velha
                        p_nome
                        c_velha
                        c_occurs
                   INTO ti_down-linha.
            TRANSLATE ti_down-linha USING '# '.
            APPEND ti_down.
            CLEAR ti_down.

            DESCRIBE TABLE ti_tab2 LINES v_ult.

*Linhas
            LOOP AT ti_tab2.
              CLEAR v_linha.
              IF sy-tabix = v_ult.
                CLEAR: v_linha, v_flinha.
                v_linha = ti_tab2-fieldname+0(10).
                TRANSLATE v_linha USING ' #'.

                CONCATENATE ti_tab2-tabname
                            c_traco
                            ti_tab2-fieldname
                            c_ponto
                       INTO v_flinha.
                TRANSLATE v_flinha USING ' #'.

                CONCATENATE c_3velha
                            v_linha
                            c_velha
                            c_like
                            c_velha
                            v_flinha
                       INTO ti_down-linha.
                TRANSLATE ti_down-linha USING '# '.
                APPEND ti_down.
                CLEAR ti_down.
                IF ti_tab2-scrtext_l = space.
                  CONCATENATE c_aster
                              c_tipo2
                              ti_tab2-inttype
                              c_comp2
                              ti_tab2-intlen
                         INTO ti_down-linha.
                  TRANSLATE ti_down-linha USING '# '.
                  APPEND ti_down.
                  CLEAR ti_down.
                ELSE.
                  CONCATENATE c_aster
                              c_tipo
                              ti_tab2-inttype
                              c_comp
                              ti_tab2-intlen
                              c_desc
                              ti_tab2-scrtext_l
                         INTO ti_down-linha.
                  TRANSLATE ti_down-linha USING '# '.
                  APPEND ti_down.
                  CLEAR ti_down.
                ENDIF.
              ELSE.
                CLEAR: v_linha, v_flinha.
                v_linha = ti_tab2-fieldname+0(10).
                TRANSLATE v_linha USING ' #'.

                CONCATENATE ti_tab2-tabname
                            c_traco
                            ti_tab2-fieldname
                            c_virgula
                       INTO v_flinha.
                TRANSLATE v_flinha USING ' #'.

                CONCATENATE c_3velha
                            v_linha
                            c_velha
                            c_like
                            c_velha
                            v_flinha
                       INTO ti_down-linha.
                TRANSLATE ti_down-linha USING '# '.
                APPEND ti_down.
                CLEAR ti_down.

                IF ti_tab2-scrtext_l = space.
                  CONCATENATE c_aster
                              c_tipo2
                              ti_tab2-inttype
                              c_comp2
                              ti_tab2-intlen
                         INTO ti_down-linha.
                  TRANSLATE ti_down-linha USING '# '.
                  APPEND ti_down.
                  CLEAR ti_down.
                ELSE.
                  CONCATENATE c_aster
                              c_tipo
                              ti_tab2-inttype
                              c_comp
                              ti_tab2-intlen
                              c_desc
                              ti_tab2-scrtext_l
                         INTO ti_down-linha.
                  TRANSLATE ti_down-linha USING '# '.
                  APPEND ti_down.
                  CLEAR ti_down.
                ENDIF.
              ENDIF.
            ENDLOOP.

*Declaração final
            CONCATENATE c_data
                        c_velha
                        c_end
                        c_velha
                        p_nome
                        c_ponto
                   INTO ti_down-linha.
            TRANSLATE ti_down-linha USING '# '.
            APPEND ti_down.
            CLEAR ti_down.

*Propaganda!
            WRITE c_mentor TO ti_down-linha.
            APPEND ti_down.
            CLEAR ti_down.

        ENDCASE.

        IF NOT ti_down[] IS INITIAL.

          CONCATENATE 'C:\TEMP\'
                      p_tabint
                      '.txt'
                 INTO v_caminho.

          CALL FUNCTION 'WS_DOWNLOAD'
            EXPORTING
              filename                = v_caminho
              filetype                = 'ASC'
            TABLES
              data_tab                = ti_down
            EXCEPTIONS
              file_open_error         = 1
              file_write_error        = 2
              invalid_filesize        = 3
              invalid_table_width     = 4
              invalid_type            = 5
              no_batch                = 6
              unknown_error           = 7
              gui_refuse_filetransfer = 8
              OTHERS                  = 9.

          IF sy-subrc <> 0.
            MESSAGE e011(pc) WITH
            'Error to generate internal Table'.
          ENDIF.

          COMMIT WORK.
          v_url = v_caminho.
          FREE ti_down.

          IF p_bw = 'X'          .

            CALL FUNCTION 'CALL_BROWSER'
              EXPORTING
                url                    = v_url
                new_window             = c_x
              EXCEPTIONS
                frontend_not_supported = 1
                frontend_error         = 2
                prog_not_found         = 3
                no_batch               = 4
                unspecified_error      = 5
                OTHERS                 = 6.

            IF sy-subrc <> 0.
              MESSAGE e011(pc) WITH
              'Your browser with problem, try with other browser'.
            ENDIF.

          ELSE.

            CALL FUNCTION 'WS_EXECUTE'
              EXPORTING
                commandline        = v_url
                program            = 'notepad'
              EXCEPTIONS
                frontend_error     = 1
                no_batch           = 2
                prog_not_found     = 3
                illegal_option     = 4
                gui_refuse_execute = 5
                OTHERS             = 6.

            IF sy-subrc <> 0.
              MESSAGE e011(pc) WITH
              'Problem in Notepad'.
            ELSE.

              WAIT UP TO 5 SECONDS.
              CALL FUNCTION 'WS_FILE_DELETE'
                EXPORTING
                  file = v_caminho.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

    WHEN OTHERS.
  ENDCASE.

  LEAVE TO SCREEN 0.

ENDFORM.                    "F_USER_COMMAND_MENSAL
