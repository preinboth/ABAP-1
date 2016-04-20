*&---------------------------------------------------------------------*
*& Report  ZSDR055
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zsdr055.

TABLES: vbrk, zsdt048.

"""""""""""""""""""""""""""""""""""" Tipos """"""""""""""""""""""""""""""""""""
TYPES: BEGIN OF ty_vbrk,
        vbeln TYPE vbrk-vbeln,
        vbtyp TYPE vbrk-vbtyp,
        fkdat TYPE vbrk-fkdat,
        kunag TYPE vbrk-kunag,
        vkorg TYPE vbrk-vkorg,
        vtweg TYPE vbrk-vtweg,
        knumv TYPE vbrk-knumv,
       END OF ty_vbrk,

       BEGIN OF ty_konv,
        knumv TYPE konv-knumv,
        kschl TYPE konv-kschl,
        kawrt TYPE konv-kawrt,
        kwert TYPE konv-kwert,
       END OF ty_konv,
       BEGIN OF ty_nfe,
        docnum TYPE j_1bnflin-docnum,
        itmnum TYPE j_1bnflin-itmnum,
        reftyp TYPE j_1bnflin-reftyp,
        refkey TYPE j_1bnflin-refkey,
        nfenum TYPE j_1bnfdoc-nfenum,
        docdat TYPE j_1bnfdoc-docdat,
       END OF ty_nfe,

       BEGIN OF ty_out,
        order  TYPE i,
        kunag  TYPE vbrk-kunag,
        name1  TYPE kna1-name1,
        ort01  TYPE kna1-ort01,
        regio  TYPE kna1-regio,
        nfenum TYPE j_1bnfdoc-nfenum,
        docdat TYPE j_1bnfdoc-docdat,
        fkdat  TYPE vbrk-fkdat,
        vbtyp  TYPE c LENGTH 40,
        kawrt  TYPE konv-kawrt,
        bonus  TYPE p DECIMALS 2,
        kwert  TYPE konv-kwert,
       END OF ty_out,

       BEGIN OF ty_kna1,
        kunnr TYPE kna1-kunnr,
        name1  TYPE kna1-name1,
        ort01  TYPE kna1-ort01,
        regio  TYPE kna1-regio,
       END OF ty_kna1.

"""""""""""""""""""""""""""""""""""" Tabelas Internas """"""""""""""""""""""""""""""""""""
DATA: it_vbrk     TYPE TABLE OF ty_vbrk WITH HEADER LINE,
      it_konv     TYPE TABLE OF ty_konv WITH HEADER LINE,
      it_nfe      TYPE TABLE OF ty_nfe  WITH HEADER LINE,
      it_zsdt048p TYPE TABLE OF zsdt048 WITH HEADER LINE,
      it_zsdt048s TYPE TABLE OF zsdt048 WITH HEADER LINE,
      it_kna1     TYPE TABLE OF ty_kna1 WITH HEADER LINE,
      it_out      TYPE TABLE OF ty_out  WITH HEADER LINE.

"""""""""""""""""""""""""""""""""""" Ranges """"""""""""""""""""""""""""""""""""
DATA: r_knumv TYPE RANGE OF vbrk-knumv WITH HEADER LINE,
      r_vbeln TYPE RANGE OF vbrk-vbeln WITH HEADER LINE.

"""""""""""""""""""""""""""""""""""" Constantes """"""""""""""""""""""""""""""""""""
CONSTANTS: c_zbon   TYPE konv-kschl       VALUE 'ZBON',
           c_reftyp TYPE j_1bnflin-reftyp VALUE 'BI'.

"""""""""""""""""""""""""""""""""""" ALV """"""""""""""""""""""""""""""""""""
TYPE-POOLS: slis, kkblo.

TYPES: BEGIN OF kkblo_layout.
        INCLUDE STRUCTURE alv_s_layo.
        INCLUDE STRUCTURE kkb_s_layo.
        INCLUDE STRUCTURE alv_s_prnt.
        INCLUDE TYPE slis_layout_alv1.
        INCLUDE TYPE slis_print_alv1.
        INCLUDE TYPE kkblo_incl_layout1.
TYPES: END OF kkblo_layout.

CONSTANTS: con_callback_pf TYPE slis_formname VALUE 'SET_PF_STATUS',
           con_callback_user TYPE slis_formname VALUE 'F_USER_COMMAND'.

** Estrutura para ALV
DATA: tg_fieldcat             TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      tg_listheader           TYPE slis_t_listheader,
      vg_listheader           TYPE slis_listheader,    "Estrutura ALV
      st_layout               TYPE kkblo_layout,
      vg_layout               TYPE slis_layout_alv,    "Layout ALV
      vg_print                TYPE slis_print_alv,     "Par. Impressão
      vg_repid                LIKE sy-repid,           "Programa
      vg_pos                  LIKE sy-index,           "Posição coluna ALV
      gt_events               TYPE slis_t_event,
      gs_variant              LIKE disvariant,
      g_save,
      g_top_of_page           TYPE slis_formname VALUE 'TOP_OF_PAGE',
      g_bottom_of_page        TYPE slis_formname VALUE 'BOTTOM_OF_PAGE',
      g_exit_caused_by_caller,
      gs_exit_caused_by_user  TYPE slis_exit_by_user,
      gt_list_top_of_page     TYPE slis_listheader OCCURS 3,
      gt_list_bottom_of_page  TYPE slis_t_listheader,
      gt_event_exit           TYPE STANDARD TABLE OF slis_event_exit,
      t_sort                  TYPE slis_t_sortinfo_alv,
      wa_head_alv             TYPE slis_listheader,
      ti_head_alv             TYPE STANDARD TABLE OF slis_listheader,
      ls_fieldcat             TYPE slis_fieldcat_alv,
      ls_line                 TYPE slis_listheader,
      l_save                  TYPE char1 VALUE 'A',
      xfeld.


"""""""""""""""""""""""""""""""""""" TELA """"""""""""""""""""""""""""""""""""
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-b01.

SELECT-OPTIONS:

  s_fkdat     FOR    vbrk-fkdat NO-EXTENSION OBLIGATORY,
  s_kunag     FOR    vbrk-kunag,
  s_vkorg     FOR    vbrk-vkorg,
  s_vtweg     FOR    vbrk-vtweg.

SELECTION-SCREEN END OF BLOCK block1.

AT SELECTION-SCREEN.

  IF s_fkdat-low IS INITIAL OR s_fkdat-high IS INITIAL.
    MESSAGE e398(00) WITH 'Selecione um periodo.'.
  ENDIF.

START-OF-SELECTION.

  PERFORM f_seleciona_dados.
  PERFORM f_monta_relatorio.
  PERFORM f_monta_alv.

  """""""""""""""""""""""""""""""""""" FORMS """"""""""""""""""""""""""""""""""""

*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_seleciona_dados .

  SELECT vbeln vbtyp fkdat kunag vkorg vtweg knumv FROM vbrk
    INTO TABLE it_vbrk
    WHERE fkdat IN s_fkdat AND
          kunag IN s_kunag AND
          vkorg IN s_vkorg AND
          vtweg IN s_vtweg.

  IF it_vbrk[] IS NOT INITIAL.

    SELECT knumv kschl kawrt kwert FROM konv
      INTO TABLE it_konv
      FOR ALL ENTRIES IN it_vbrk
      WHERE knumv = it_vbrk-knumv AND
            kschl = c_zbon.

    IF it_konv[] IS NOT INITIAL.

      LOOP AT it_konv.
        r_knumv-sign = 'I'.
        r_knumv-option = 'EQ'.
        r_knumv-low = it_konv-knumv.
        APPEND r_knumv.
      ENDLOOP.

      DELETE it_vbrk WHERE knumv NOT IN r_knumv.

      LOOP AT it_vbrk.
        r_vbeln-sign = 'I'.
        r_vbeln-option = 'EQ'.
        r_vbeln-low = it_vbrk-vbeln.
        APPEND r_vbeln.
      ENDLOOP.

      "número da nota fiscal
      SELECT f~docnum f~itmnum f~reftyp f~refkey d~nfenum d~docdat INTO TABLE it_nfe
        FROM j_1bnflin AS f
        INNER JOIN j_1bnfdoc AS d
        ON f~docnum EQ d~docnum
        WHERE f~reftyp EQ c_reftyp AND
              f~refkey IN r_vbeln.

      "Seleciona os registros referente aos pagamentos feito pelo cliente.
      SELECT * FROM zsdt048 INTO TABLE it_zsdt048p
        FOR ALL ENTRIES IN it_vbrk
        WHERE kunag EQ it_vbrk-kunag AND
              begda GE s_fkdat-low   AND
              endda LE s_fkdat-high.

      "SALDOS dos clientes. Busca os saldos dos clientes. Ultimo registro antes da data especificada.
      SELECT * FROM zsdt048 INTO TABLE it_zsdt048s
        FOR ALL ENTRIES IN it_vbrk
        WHERE kunag EQ it_vbrk-kunag. "AND
      "endda LE s_fkdat-low.

*      IF it_zsdt048s[] IS NOT INITIAL.
*        SORT it_zsdt048s BY kunag endda DESCENDING.
*        DELETE ADJACENT DUPLICATES FROM it_zsdt048s COMPARING kunag.
*      ENDIF.


    ENDIF.

  ENDIF.

*****  IF it_zsdt048p[] IS INITIAL.
*****    MESSAGE e398(00) WITH 'Nenhum registro selecionado.'.
*****  ELSE.

    SELECT kunnr name1 ort01 regio FROM kna1 INTO TABLE it_kna1
      FOR ALL ENTRIES IN it_vbrk
      WHERE kunnr EQ it_vbrk-kunag.

****  ENDIF.

ENDFORM.                    " F_SELECIONA_DADOS

*&---------------------------------------------------------------------*
*&      Form  F_MONTA_RELATORIO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_monta_relatorio .

  DATA: v_indice TYPE i VALUE 0,
        v_char   TYPE c LENGTH 30,
        it_vbrk_aux TYPE TABLE OF ty_vbrk WITH HEADER LINE.

  SORT it_zsdt048s BY kunag begda DESCENDING.

  APPEND LINES OF it_vbrk TO it_vbrk_aux.
  SORT it_vbrk_aux BY kunag ASCENDING.
  DELETE ADJACENT DUPLICATES FROM it_vbrk_aux COMPARING kunag.

  LOOP AT it_vbrk_aux.

    READ TABLE it_zsdt048p WITH KEY kunag = it_vbrk_aux-kunag.
    IF sy-subrc EQ 0.

      LOOP AT it_zsdt048p WHERE kunag EQ it_vbrk_aux-kunag.

        CLEAR: it_kna1, it_out.

        it_out-kunag = it_zsdt048p-kunag.

        READ TABLE it_kna1 WITH KEY kunnr = it_zsdt048p-kunag.
        IF sy-subrc EQ 0.
          it_out-name1 = it_kna1-name1.
          it_out-regio = it_kna1-regio.
          it_out-ort01 = it_kna1-ort01.
        ENDIF.

        it_out-order = v_indice.
        it_out-vbtyp = text-t04.
        it_out-fkdat = it_zsdt048p-begda - 1.
        LOOP AT it_zsdt048s WHERE kunag EQ it_zsdt048p-kunag AND endda LE it_zsdt048p-begda.
          it_out-kwert = it_zsdt048s-saldo.
          EXIT.
        ENDLOOP.

        "APPEND DA LINHA SALDO INICIAL COM INDICE 0
        APPEND it_out.

        ADD 1 TO v_indice.

        LOOP AT it_vbrk WHERE kunag EQ it_zsdt048p-kunag AND fkdat GE it_zsdt048p-begda AND fkdat LE it_zsdt048p-endda.

          READ TABLE it_nfe WITH KEY refkey = it_vbrk-vbeln.
          IF sy-subrc EQ 0.
            it_out-order = v_indice.
            it_out-nfenum = it_nfe-nfenum.
            it_out-docdat = it_nfe-docdat.
            it_out-fkdat = it_vbrk-fkdat.

            CASE it_vbrk-vbtyp.

              WHEN 'M'.
                v_char = text-t01. "Venda
              WHEN 'O'.
                v_char = text-t02. "Devoluçao
              WHEN 'N'.
                v_char = text-t03. "Estorno
              WHEN OTHERS.
            ENDCASE.

            READ TABLE it_konv WITH KEY knumv = it_vbrk-knumv.
            " Valor Base
            IF sy-subrc EQ 0.
              IF it_vbrk-vbtyp EQ 'M'.
                it_out-kawrt = it_konv-kawrt.
              ELSE.
                it_out-kawrt = it_konv-kawrt * -1.
              ENDIF.
            ENDIF.

            " Valor Bonus
            it_out-kwert = it_konv-kwert.

            "Descriçao do tipo de movimento
            it_out-vbtyp = v_char.

            " %Bonus = 100 * Valor bônus / Valor Base
            it_out-bonus = 100 * it_out-kwert / it_out-kawrt.

            APPEND it_out.

            ADD 1 TO v_indice.
          ENDIF.

        ENDLOOP.

        "Limpando o cabeçalho para que ao appendar a linha de Pagamento os campos abaixos fiquem em branco.
        CLEAR: it_out-nfenum, it_out-docdat, it_out-kawrt, it_out-bonus.

        it_out-order = v_indice.
        it_out-fkdat = it_zsdt048p-dt_pgto.
        it_out-vbtyp = text-t05. "Pagamento
        it_out-kwert = it_zsdt048p-valor_pgto * -1.
        " APPEND PARA A LINHA DE PAGAMENTO
        APPEND it_out.
      ENDLOOP.


    ELSE.


      CLEAR: it_kna1, it_out.

      it_out-kunag = it_vbrk_aux-kunag.

      READ TABLE it_kna1 WITH KEY kunnr = it_vbrk_aux-kunag.
      IF sy-subrc EQ 0.
        it_out-name1 = it_kna1-name1.
        it_out-regio = it_kna1-regio.
        it_out-ort01 = it_kna1-ort01.
      ENDIF.

      it_out-order = v_indice.
      it_out-vbtyp = text-t04.

      "APPEND DA LINHA SALDO INICIAL COM INDICE 0
      APPEND it_out.

      ADD 1 TO v_indice.

      LOOP AT it_vbrk WHERE kunag EQ it_vbrk_aux-kunag.

        READ TABLE it_nfe WITH KEY refkey = it_vbrk-vbeln.
        IF sy-subrc EQ 0.
          it_out-order = v_indice.
          it_out-nfenum = it_nfe-nfenum.
          it_out-docdat = it_nfe-docdat.
          it_out-fkdat = it_vbrk-fkdat.

          CASE it_vbrk-vbtyp.

            WHEN 'M'.
              v_char = text-t01. "Venda
            WHEN 'O'.
              v_char = text-t02. "Devoluçao
            WHEN 'N'.
              v_char = text-t03. "Estorno
            WHEN OTHERS.
          ENDCASE.

          READ TABLE it_konv WITH KEY knumv = it_vbrk-knumv.
          " Valor Base
          IF sy-subrc EQ 0.
            IF it_vbrk-vbtyp EQ 'M'.
              it_out-kawrt = it_konv-kawrt.
            ELSE.
              it_out-kawrt = it_konv-kawrt * -1.
            ENDIF.
          ENDIF.

          " Valor Bonus
          it_out-kwert = it_konv-kwert.

          "Descriçao do tipo de movimento
          it_out-vbtyp = v_char.

          " %Bonus = 100 * Valor bônus / Valor Base
          it_out-bonus = 100 * it_out-kwert / it_out-kawrt.

          APPEND it_out.

          ADD 1 TO v_indice.
        ENDIF.

      ENDLOOP.

    ENDIF.

  ENDLOOP.


ENDFORM.                    " F_MONTA_RELATORIO

*&---------------------------------------------------------------------*
*&      Form  F_MONTA_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_monta_alv .
  IF it_out[] IS INITIAL.
    MESSAGE e398(00) WITH 'Não foram encontrados registros para '
                           'esta seleção!'.
    STOP.
  ELSE.

    PERFORM: f_monta_fieldcat USING tg_fieldcat[],
             f_sort_build USING t_sort,
             f_monta_cabecalho,
             f_print_alv_local.

  ENDIF.
ENDFORM.                    " F_MONTA_ALV

*&---------------------------------------------------------------------*

*&      Form  F_MONTAGRID

*&---------------------------------------------------------------------*

*----------------------------------------------------------------------*

FORM f_montagrid  USING v_pos v_field v_tit v_tam v_just v_fix v_sum v_out.
  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos       = v_pos.
  ls_fieldcat-fieldname     = v_field.
  ls_fieldcat-tabname       = 'it_out'.
  ls_fieldcat-reptext_ddic  = v_tit.
  ls_fieldcat-just          = v_just.
  IF v_tam = 0.
    ls_fieldcat-outputlen     = strlen( v_tit ).
  ELSE.
    ls_fieldcat-outputlen     = v_tam.
  ENDIF.
  ls_fieldcat-fix_column    = v_fix.
  ls_fieldcat-do_sum        = v_sum.
  ls_fieldcat-no_out        = v_out.
ENDFORM.                    " F_MONTAGRID

*&---------------------------------------------------------------------*

*&      Form  F_MONTA_FIELDCAT

*&---------------------------------------------------------------------*

*       text

*----------------------------------------------------------------------*

*      -->P_TG_FIELDCAT[]  text

*----------------------------------------------------------------------*

FORM f_monta_fieldcat  USING lt_fieldcat TYPE slis_t_fieldcat_alv.

  CLEAR: ls_fieldcat.
  PERFORM f_montagrid USING  1 'KUNAG'
                               'Cliente'
                               12 'L' '' '' ''.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR: ls_fieldcat.
  PERFORM f_montagrid USING  2 'NAME1'
                               'Razão Social'
                               40 'L' '' '' ''.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR: ls_fieldcat.
  PERFORM f_montagrid USING  3 'ORT01'
                               'Cidade'
                               40 'L' '' '' ''.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR: ls_fieldcat.
  PERFORM f_montagrid USING  4 'REGIO'
                               'UF'
                               4 'L' '' '' ''.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR: ls_fieldcat.
  PERFORM f_montagrid USING  5 'NFENUM'
                               'Nota Fiscal'
                               30 'L' '' '' ''.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR: ls_fieldcat.
  PERFORM f_montagrid USING  6 'DOCDAT'
                               'Data emissão'
                               10 'L' '' '' ''.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR: ls_fieldcat.
  PERFORM f_montagrid USING  7 'FKDAT'
                               'Data faturamento'
                               10 'L' '' '' ''.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR: ls_fieldcat.
  PERFORM f_montagrid USING  8 'VBTYP'
                               'Tipo'
                               30 'L' '' '' ''.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR: ls_fieldcat.
  PERFORM f_montagrid USING  9 'KAWRT'
                               'Valor base'
                               20 'L' '' '' ''.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR: ls_fieldcat.
  PERFORM f_montagrid USING  10 'BONUS'
                               '%Bonus'
                               20 'L' '' '' ''.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR: ls_fieldcat.
  PERFORM f_montagrid USING  11 'KWERT'
                               'Valor Bonus/Pagamento'
                               20 'L' '' 'X' ''.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR: ls_fieldcat.
  PERFORM f_montagrid USING  12 'ORDER'
                               'Ordem'
                               20 'L' '' '' 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.


ENDFORM.                    " F_MONTA_FIELDCAT

*&---------------------------------------------------------------------*

*&      Form  F_SORT_BUILD

*&---------------------------------------------------------------------*

*       text

*----------------------------------------------------------------------*

*      -->P_T_SORT  text

*----------------------------------------------------------------------*

FORM f_sort_build  USING lt_sort TYPE slis_t_sortinfo_alv.

  DATA: ls_sort TYPE slis_sortinfo_alv.
  CLEAR: lt_sort[],
         vg_pos.

  DEFINE def_sort.
    add 1 to vg_pos.
    ls_sort-fieldname = &1.
    ls_sort-spos      = vg_pos.
    ls_sort-up        = &2.
    ls_sort-subtot    = &3.
    ls_sort-subtot    = &4.
    append ls_sort to lt_sort.

  END-OF-DEFINITION.
  def_sort 'KUNAG'  'X' '' 'X'.
  def_sort 'NAME1'  'X' '' ''.
  def_sort 'ORT01'  'X' '' ''.
  def_sort 'REGIO'  'X' '' ''.

ENDFORM.                    " F_SORT_BUILD

*&---------------------------------------------------------------------*

*&      Form  F_MONTA_CABECALHO

*&---------------------------------------------------------------------*

*       text

*----------------------------------------------------------------------*

*  -->  p1        text

*  <--  p2        text

*----------------------------------------------------------------------*

FORM f_monta_cabecalho .

  DATA:  v_data(10) TYPE c,
         v_hora(08) TYPE c,
         v_peri(07) TYPE c.

  CLEAR ti_head_alv[].
  WRITE sy-datum TO v_data.
  WRITE sy-uzeit TO v_hora.

  wa_head_alv-typ  = 'H'.
  wa_head_alv-key  = 'Relatório Sobretaxa'.
  wa_head_alv-info = 'Relatório Sobretaxa'.
  APPEND wa_head_alv TO ti_head_alv.
  CLEAR wa_head_alv.

  wa_head_alv-typ  = 'S'.
  CONCATENATE 'Data: ' v_data INTO wa_head_alv-key RESPECTING BLANKS.
  APPEND wa_head_alv TO ti_head_alv.
  CLEAR wa_head_alv.

  wa_head_alv-typ  = 'S'.
  CONCATENATE 'Hora: ' v_hora INTO wa_head_alv-key RESPECTING BLANKS.
  APPEND wa_head_alv TO ti_head_alv.
  CLEAR wa_head_alv.

ENDFORM.                    " F_MONTA_CABECALHO

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_ALV_LOCAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM f_print_alv_local .

  vg_layout-colwidth_optimize = 'X'.

  SORT it_out BY order kunag ASCENDING.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_buffer_active        = 'X'
      i_callback_program     = sy-repid
      i_callback_top_of_page = 'F_TOP_OF_PAGE'
      is_layout              = vg_layout        "gs_layout
      it_fieldcat            = tg_fieldcat[]    "gt_fieldcat
      it_sort                = t_sort         "gt_sort
    TABLES
      t_outtab               = it_out
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.


  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " F_PRINT_ALV_LOCAL

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_header .

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      i_logo             = 'PS_LOGO'
      it_list_commentary = ti_head_alv.

ENDFORM.                    " F_PRINT_HEADER



*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*

FORM f_top_of_page.
  PERFORM f_print_header.
ENDFORM.                    "F_TOP_OF_PAGE