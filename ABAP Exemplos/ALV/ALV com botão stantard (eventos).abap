
*----------------------------------------------------------------------*
*                          Megawork - LYPTUS                           *
*----------------------------------------------------------------------*
* Programa : ZHRR0356                                                  *
* Descrição : Acerto da carga horaria                                  *
* Módulo : HR                                  Transação:              *
* Objetivo : Acertar o historico da carga horaria dos funcionarios     *
*            ativos de 40h para 44h                                    *
*----------------------------------------------------------------------*
* Autor : Daniely Santos Data: 25/02/2014                              *
* Observações:                                                         *
* NºChamado ou NºProjeto: 20014                                        *
*----------------------------------------------------------------------*
* Histórico das modificações                                           *
*----------------------------------------------------------------------*
* Autor : Data:                                                        *
* Empresa :                                                            *
* Modificações:                                                        *
* NºChamado ou NºProjeto:                                              *
*----------------------------------------------------------------------*

REPORT zhrr0356 LINE-SIZE 300.

TYPE-POOLS: slis, kkblo..

*&---------------------------------------------------------------------*
*& Tables
*&---------------------------------------------------------------------*

TABLES: pa0007,
        pa0000,
        t508a.
*&---------------------------------------------------------------------*
*& Tipos
*&---------------------------------------------------------------------*

TYPES: BEGIN OF ty_pa0000,
          pernr TYPE pa0000-pernr,
          stat2 TYPE pa0000-stat2,
          endda TYPE pa0000-endda,
       END OF ty_pa0000.

TYPES: BEGIN OF ty_t508a,
          schkz TYPE t508a-schkz,
          wostd TYPE t508a-wostd,
       END OF ty_t508a.

TYPES: BEGIN OF ty_alv,
         pernr      TYPE pa0000-pernr,
         subty      TYPE pa0007-subty,
         objps      TYPE pa0007-objps,
         sprps      TYPE pa0007-sprps,
         seqnr      TYPE pa0007-seqnr,
         name       TYPE pad_cname,
         schkz      TYPE t508a-schkz,
         begda      TYPE pa0007-begda,
         endda      TYPE pa0007-endda,
         wostd_de   TYPE pa0007-wostd,
         wostd_para TYPE t508a-wostd,
      END OF ty_alv.

TYPES: BEGIN OF ty_pa0003,
         pernr      TYPE pa0003-pernr,
         subty      TYPE pa0003-subty,
         objps      TYPE pa0003-objps,
         sprps      TYPE pa0003-sprps,
         begda      TYPE pa0003-begda,
         endda      TYPE pa0003-endda,
         seqnr      TYPE pa0003-seqnr,
         viekn      TYPE pa0003-viekn,
      END OF ty_pa0003.

TYPES: BEGIN OF ty_mens,
          pernr TYPE pa0000-pernr,
          msg   TYPE bapi_msg,
          tipo  TYPE bapi_mtype,
       END OF ty_mens.

*&---------------------------------------------------------------------*
*& Tabelas internas
*&---------------------------------------------------------------------*
DATA: ti_pa0000 TYPE STANDARD TABLE OF ty_pa0000,
      ti_t508a  TYPE STANDARD TABLE OF ty_t508a,
      ti_pa0003 TYPE STANDARD TABLE OF ty_pa0003,
      ti_alv    TYPE STANDARD TABLE OF ty_alv,
      ti_mens   TYPE STANDARD TABLE OF ty_mens,
      ti_return LIKE bapireturn1.                           " OCCURS 0.

DATA BEGIN OF ti_pa0007 OCCURS 0.
        INCLUDE STRUCTURE pa0007.
DATA END   OF ti_pa0007.


* ALV
DATA: lf_fieldcat   TYPE slis_t_fieldcat_alv,
      it_sortcat    TYPE slis_t_sortinfo_alv.

*&---------------------------------------------------------------------*
*& Estrutura
*&---------------------------------------------------------------------*
DATA: st_pa0000 TYPE         ty_pa0000,
      st_pa0003 TYPE         ty_pa0003,
      st_pa0007 LIKE LINE OF ti_pa0007,
      st_t508a  TYPE         ty_t508a,
      st_alv    TYPE         ty_alv,
      st_mens   TYPE         ty_mens.

* ALV
DATA: lf_layout    TYPE slis_layout_alv.


*&---------------------------------------------------------------------*
*& Variaveis Globais
*&---------------------------------------------------------------------*
DATA: gv_encontrou TYPE c.

SELECTION-SCREEN: BEGIN OF BLOCK b1.
SELECT-OPTIONS: s_pernr FOR pa0000-pernr,
                s_schkz FOR t508a-schkz.
PARAMETERS: p_wostd TYPE t508a-wostd OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK b1.



START-OF-SELECTION.

*  SET PF-STATUS 'Z_PF_STATUS'.
  PERFORM busca_dados.

  IF gv_encontrou = 'S'.

    PERFORM processa_dados.
    PERFORM monta_alv.
*    PERFORM alterar_horario.

  ELSE.
    MESSAGE i398(00) WITH text-m01.
  ENDIF.

*&---------------------------------------------------------------------*
*&      Form  BUSCA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM busca_dados .

  gv_encontrou = 'N'.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
            percentage = 05
            text       = text-m09.

  SELECT pernr stat2 endda
    INTO TABLE ti_pa0000
    FROM pa0000
    WHERE pernr IN s_pernr AND
          stat2 EQ '3'     AND
          endda EQ '99991231'.

  IF  NOT ti_pa0000[] IS INITIAL.

    SELECT *
      INTO TABLE ti_pa0007
      FROM pa0007
      FOR ALL ENTRIES IN ti_pa0000
      WHERE pernr =  ti_pa0000-pernr AND
            schkz IN s_schkz         AND
            wostd EQ p_wostd.

    IF NOT ti_pa0007[] IS INITIAL.

      SELECT pernr subty objps sprps begda
             endda seqnr viekn
         INTO TABLE ti_pa0003
         FROM pa0003
         FOR ALL ENTRIES IN ti_pa0007
         WHERE pernr = ti_pa0007-pernr AND
               subty = ti_pa0007-subty AND
               objps = ti_pa0007-objps AND
               sprps = ti_pa0007-sprps AND
               begda = ti_pa0007-begda AND
               endda = ti_pa0007-endda AND
               seqnr = ti_pa0007-seqnr.

      SELECT schkz wostd
        INTO TABLE ti_t508a
        FROM t508a
        FOR ALL ENTRIES IN ti_pa0007
        WHERE schkz = ti_pa0007-schkz.

      IF sy-subrc = 0.
        gv_encontrou = 'S'.
      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                    " BUSCA_DADOS
*&---------------------------------------------------------------------*
*&      Form  processa_dados
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM processa_dados.

  DATA: ti_p0002    TYPE STANDARD TABLE OF p0002.

  DATA: st_p0002    TYPE p0002.

  DATA: lv_name     TYPE text100,
        rv_name     TYPE string,
        rv_cpf      TYPE pbr_cpfnr,
        lv_retcode  TYPE sy-subrc.

  CONSTANTS:
            pbr99_molga LIKE t500l-molga VALUE '37'.   " MOLGA

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
       EXPORTING
            percentage = 05
            text       = text-m10.

  LOOP AT ti_pa0007 INTO st_pa0007.

    CLEAR: st_alv, ti_p0002[].
    st_alv-pernr = st_pa0007-pernr.
    st_alv-begda = st_pa0007-begda.
    st_alv-endda = st_pa0007-endda.
    st_alv-subty = st_pa0007-subty.
    st_alv-objps = st_pa0007-objps.
    st_alv-sprps = st_pa0007-sprps.
    st_alv-seqnr = st_pa0007-seqnr.


    CALL FUNCTION 'HR_INITIALIZE_BUFFER'.

    "Seleciona Infotipo 0002 (Dados pessoais)
    CALL FUNCTION 'HR_READ_INFOTYPE'
         EXPORTING
              pernr           = st_alv-pernr
              infty           = '0002'
              begda           = sy-datum
              endda           = sy-datum
         TABLES
              infty_tab       = ti_p0002
         EXCEPTIONS
              infty_not_found = 1
              OTHERS          = 2.

    LOOP AT ti_p0002 INTO st_p0002
      WHERE begda <= sy-datum
        AND endda >= sy-datum.
    ENDLOOP.

    "Nome do empregado
    CALL FUNCTION 'RP_EDIT_NAME'
         EXPORTING
              format    = '01'
              langu     = sy-langu
              molga     = pbr99_molga
              pp0002    = st_p0002
         IMPORTING
              edit_name = st_alv-name
              retcode   = lv_retcode.

    st_alv-schkz    = st_pa0007-schkz.
    st_alv-wostd_de = st_pa0007-wostd.

    READ TABLE ti_t508a INTO st_t508a WITH KEY schkz = st_pa0007-schkz.
    IF sy-subrc = 0.
      st_alv-wostd_para = st_t508a-wostd.
    ENDIF.

    APPEND st_alv TO ti_alv.

  ENDLOOP.


ENDFORM.                    " processa_dados
*&---------------------------------------------------------------------*
*&      Form  monta_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM monta_alv.

  PERFORM f_field.
  PERFORM f_layout.
  PERFORM f_sort.
  PERFORM show_alv.

ENDFORM.                    " monta_alv
*&---------------------------------------------------------------------*
*&      Form  f_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_field.

  PERFORM field_alv USING 'PERNR'      text-001 ' ' ' '.
  PERFORM field_alv USING 'NAME'       text-002 ' ' ' '.
  PERFORM field_alv USING 'BEGDA'      text-007 ' ' ' '.
  PERFORM field_alv USING 'ENDDA'      text-008 ' ' ' '.
  PERFORM field_alv USING 'SCHKZ'      text-003 ' ' ' '.
  PERFORM field_alv USING 'WOSTD_DE'   text-004 ' ' ' '.
  PERFORM field_alv USING 'WOSTD_PARA' text-005 ' ' ' '.

ENDFORM.                    " f_field
*&---------------------------------------------------------------------*
*&      Form  field_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0438   text
*      -->P_TEXT_001  text
*      -->P_0440   text
*      -->P_0441   text
*----------------------------------------------------------------------*
FORM field_alv USING   campo
                       p_texto
                       p_hotspot
                       p_just.

  DATA: p_field TYPE slis_fieldcat_alv.

  CLEAR p_field.
  p_field-fieldname = campo.
  p_field-tabname   = 'TI_ALV'.
  p_field-seltext_s = p_texto.
  p_field-seltext_m = p_texto.
  p_field-seltext_l = p_texto.
  p_field-hotspot   = p_hotspot.
*  p_field-outputlen = p_outputlen.
  p_field-ddictxt   = 'L'.
  p_field-just      = p_just.

  APPEND p_field TO lf_fieldcat.

ENDFORM.                    " field_alv
*&---------------------------------------------------------------------*
*&      Form  f_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_layout.

  lf_layout-zebra               = 'X'.
  lf_layout-colwidth_optimize   = 'X'.

ENDFORM.                    " f_layout
*&---------------------------------------------------------------------*
*&      Form  show_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM show_alv.

  CONSTANTS: lc_user_command(30)      TYPE c VALUE 'F_ALV_USER_COMMAND',
              lc_pf_status_set(30)    TYPE c VALUE 'SET_PF_STATUS',
              lc_top_of_page(30)      TYPE c VALUE 'TOP_OF_PAGE',
              i_callback_pf_status_set TYPE slis_formname VALUE
                                                        'SET_PF_STATUS',
              i_callback_user_command  TYPE slis_formname VALUE
                                                 'F_ALV_USER_COMMAND',
              i_callback_top_of_page   TYPE slis_formname VALUE
                                                          'TOP_OF_PAGE',
              i_default                TYPE c VALUE 'X',
              i_save                   TYPE c VALUE 'A'.


  DATA: et_events                   TYPE slis_t_event WITH HEADER LINE,
        it_fieldcat                 TYPE slis_t_fieldcat_alv,
        is_layout                   TYPE slis_layout_alv,
        is_variant                  LIKE disvariant,
        is_print                    TYPE slis_print_alv,
        i_callback_program          LIKE sy-repid,
        i_interface_check           TYPE c,
        i_buffer_active             TYPE c,
        i_structure_name            TYPE dd02l-tabname,
        it_sort                     TYPE slis_t_sortinfo_alv,
        it_events                   TYPE slis_t_event,
        it_event_exit               TYPE slis_t_event_exit.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
       EXPORTING
            i_list_type     = 0
       IMPORTING
            et_events       = et_events[]
       EXCEPTIONS
            list_type_wrong = 1
            OTHERS          = 2.


  IF sy-subrc IS INITIAL.
    SORT et_events BY name.

    READ TABLE et_events WITH KEY name = lc_user_command BINARY SEARCH.

    IF sy-subrc IS INITIAL.
      MOVE lc_user_command TO et_events-form.
      MODIFY et_events INDEX sy-tabix.
    ENDIF.

    READ TABLE et_events WITH KEY name = lc_pf_status_set BINARY SEARCH.

    IF sy-subrc IS INITIAL.
      MOVE lc_pf_status_set TO et_events-form.
      MODIFY et_events INDEX sy-tabix.
    ENDIF.
  ENDIF.

  MOVE:
*        'X'                         to is_layout-zebra,
     'X'                         TO is_layout-detail_popup,
*        'RELATÓRIO DE IMOBILIZADOS' to is_layout-detail_titlebar,
*        'T_RELAT'                   to is_layout-box_tabname,
*        'MARK'                      to is_layout-box_fieldname,
     sy-repid                    TO is_variant-report,
     'X'                         TO is_print-no_print_listinfos,
     sy-repid                    TO i_callback_program.


  it_events[] = et_events[].


  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
       EXPORTING
******        i_interface_check  = i_interface_check
******            i_buffer_active    = i_buffer_active
******
*******            i_callback_pf_status_set = 'SET_PF_STATUS'
******            i_callback_program       = sy-repid
*******            i_callback_user_command  = 'F_ALV_USER_COMMAND'
******            is_layout                = lf_layout
******            it_fieldcat              = lf_fieldcat
******            it_sort                  = it_sortcat
******            i_save                   = 'X'
******            it_events          = it_events
******            it_event_exit      = it_event_exit
            i_interface_check  = i_interface_check
            i_buffer_active    = i_buffer_active
            i_callback_program = i_callback_program
            i_structure_name   = i_structure_name
            is_layout          = lf_layout
            it_fieldcat        = lf_fieldcat[]
            it_sort            = it_sortcat
            i_default          = i_default
            i_save             = i_save
            is_variant         = is_variant
            it_events          = it_events
            it_event_exit      = it_event_exit
            is_print           = is_print

       TABLES
            t_outtab                 = ti_alv
       EXCEPTIONS
            program_error            = 1
            OTHERS                   = 2.

  IF sy-subrc <> 0.
    MESSAGE e398(00) WITH text-006.
  ENDIF.

ENDFORM.                    " show_alv
*&---------------------------------------------------------------------*
*&      Form  f_sort
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_sort.

  DATA: st_sort LIKE LINE OF it_sortcat.

  CLEAR: st_sort.
  st_sort-spos      = 1.
  st_sort-fieldname = 'PERNR'.
  st_sort-up        = 'X'.
*  wa_sort-SUBTOT    = 'X'. "subtotals any totals column by this field
*  gd_sortcat-tabname
  APPEND st_sort TO it_sortcat.

  CLEAR: st_sort.
  st_sort-spos      = 2.
  st_sort-fieldname = 'NAME'.
  st_sort-up        = 'X'.
*  gd_sortcat-tabname
  APPEND st_sort TO it_sortcat.

  CLEAR: st_sort.
  st_sort-spos      = 3.
  st_sort-fieldname = 'SCHKZ'.
  st_sort-up        = 'X'.
*  wa_sort-SUBTOT    = 'X'. "subtotals any totals column by this field
*  gd_sortcat-tabname
  APPEND st_sort TO it_sortcat.

  CLEAR: st_sort.
  st_sort-spos      = 4.
  st_sort-fieldname = 'BEGDA'.
  st_sort-up        = 'X'.
*  wa_sort-SUBTOT    = 'X'. "subtotals any totals column by this field
*  gd_sortcat-tabname
  APPEND st_sort TO it_sortcat.

  CLEAR: st_sort.
  st_sort-spos      = 5.
  st_sort-fieldname = 'ENDDA'.
  st_sort-up        = 'X'.
*  wa_sort-SUBTOT    = 'X'. "subtotals any totals column by this field
*  gd_sortcat-tabname
  APPEND st_sort TO it_sortcat.

ENDFORM.                    " f_sort


*&---------------------------------------------------------------------*
*&      Form  f_alv_user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UCOMM      text
*      -->SELFIELD   text
*----------------------------------------------------------------------*
FORM f_alv_user_command USING ucomm LIKE sy-ucomm
                           selfield TYPE slis_selfield.
  IF ucomm = 'ALTERAR'.

    PERFORM alterar_horario.

  ENDIF.

ENDFORM. "z_user_command
*&---------------------------------------------------------------------*
*&      Form  alterar_horario
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM alterar_horario.
  DATA: l_linhas     TYPE i,
        l_mens(100)  TYPE c,
        l_answer     TYPE c,
        l_cont       TYPE i.

  DATA: st_p0007  TYPE p0007.


  DESCRIBE TABLE ti_alv LINES l_linhas.
  WRITE l_linhas TO l_mens.
  SHIFT l_mens LEFT DELETING LEADING space.
  CONCATENATE text-m02 l_mens text-m03 INTO l_mens SEPARATED BY space.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
     titlebar                    = 'Alteração de Dados '
*     DIAGNOSE_OBJECT             = ' '
      text_question               = l_mens
     text_button_1               = 'Sim'
*     ICON_BUTTON_1               = ' '
     text_button_2               = 'Não'
*     ICON_BUTTON_2               = ' '
     default_button              = '1'
     display_cancel_button       = ' '
*     USERDEFINED_F1_HELP         = ' '
*     START_COLUMN                = 25
*     START_ROW                   = 6
*     POPUP_TYPE                  =
   IMPORTING
     answer                      = l_answer
*   TABLES
*     PARAMETER                   =
   EXCEPTIONS
     text_not_found              = 1
     OTHERS                      = 2
            .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  CHECK l_answer = '1'.

  l_cont = 0.
  LOOP AT ti_alv INTO st_alv.

    CLEAR: st_pa0007, st_p0007, st_pa0003.

    READ TABLE ti_pa0007 INTO st_pa0007 WITH KEY pernr = st_alv-pernr
                                                 subty = st_alv-subty
                                                 objps = st_alv-objps
                                                 sprps = st_alv-sprps
                                                 endda = st_alv-endda
                                                 begda = st_alv-begda
                                                 seqnr = st_alv-seqnr.

    CHECK sy-subrc = 0.

    MOVE-CORRESPONDING st_pa0007 TO st_p0007.

    st_p0007-wostd = st_alv-wostd_para.
    st_p0007-infty = '0007'.

    READ TABLE ti_pa0003 INTO st_pa0003 WITH KEY pernr = st_alv-pernr
                                                 subty = st_alv-subty
                                                 objps = st_alv-objps
                                                 sprps = st_alv-sprps
                                                 endda = st_alv-endda
                                                 begda = st_alv-begda
                                                 seqnr = st_alv-seqnr.

    CALL FUNCTION 'BAPI_EMPLOYEE_ENQUEUE'
         EXPORTING
              number = st_alv-pernr
         IMPORTING
              return = ti_return.

    IF NOT ti_return IS INITIAL.
      PERFORM monta_mens.
    ENDIF.

    CHECK sy-subrc = 0.

    CALL FUNCTION 'HR_INFOTYPE_OPERATION'
         EXPORTING
              infty         = '0007'
              number        = st_alv-pernr
              subtype       = st_alv-subty
              objectid      = st_alv-objps
              lockindicator = st_alv-sprps
              validityend   = st_alv-endda
              validitybegin = st_alv-begda
              recordnumber  = st_alv-seqnr
              record        = st_p0007
              operation     = 'MOD'
*     TCLAS                  = 'A'
*     DIALOG_MODE            = '0'
*     NOCOMMIT               =
     view_identifier        = st_pa0003-viekn
*     SECONDARY_RECORD       =
    IMPORTING
      return                 = ti_return.
*     KEY                    =

    IF NOT ti_return IS INITIAL.
      PERFORM monta_mens.
    ENDIF.

    CALL FUNCTION 'BAPI_EMPLOYEE_DEQUEUE'
         EXPORTING
              number = st_alv-pernr.

  ENDLOOP.

  PERFORM verifica_alt.

ENDFORM.                    " alterar_horario
*&---------------------------------------------------------------------*
*&      Form  SET_PF_STATUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_pf_status USING p_extab TYPE slis_t_extab.

  SET PF-STATUS 'ALV'.

ENDFORM.                    " SET_PF_STATUS
*&---------------------------------------------------------------------*
*&      Form  verifica_alt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM verifica_alt.

  IF ti_mens[] IS INITIAL.
    MESSAGE s398(00) WITH text-m05.
  ELSE.
    MESSAGE i398(00) WITH text-m08.
    PERFORM relatorio_erro.
  ENDIF.

ENDFORM.                    " verifica_alt
*&---------------------------------------------------------------------*
*&      Form  MONTA_MENS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM monta_mens.

  DATA: st_return  LIKE  bapireturn1.

*  LOOP AT ti_return INTO st_return.
  IF ti_return-type = 'E'.
    CLEAR: st_mens.
    st_mens-pernr = st_alv-pernr.
    st_mens-msg   = ti_return-message.
    st_mens-tipo  = 'E'.
    APPEND st_mens TO ti_mens.
  ENDIF.
*  ENDLOOP.

ENDFORM.                    " MONTA_MENS
*&---------------------------------------------------------------------*
*&      Form  relatorio_erro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM relatorio_erro.

  DELETE ADJACENT DUPLICATES FROM ti_mens.
  WRITE text-m04.
  LOOP AT ti_mens INTO st_mens.
    WRITE:/ text-m06, st_mens-pernr, text-m07, st_mens-msg.
  ENDLOOP.
ENDFORM.                    " relatorio_erro