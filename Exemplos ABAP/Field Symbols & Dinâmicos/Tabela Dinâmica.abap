*----------------------------------------------------------------------*
* Empresa    : Megawork Consultoria e Sistemas Ltda                    *
* Cliente....: Unimarka                                                *
* Módulo     : SD                                                      *
* Autor......: Luiz Moraes                                             *
* Data.......: 06.11.2013                                              *
* Descrição..: Relatório - Batalha Naval                               *
* Programa...: ZSDR058                                                 *
* Transação..: ZSD114                                                  *
*----------------------------------------------------------------------*
*                     Histórico das modificações                       *
*----------------------------------------------------------------------*
* Autor      :                                        Data:            *
* Observações:                                                         *
*----------------------------------------------------------------------*
REPORT zsdr058.


*----------------------------------------------------------------------*
* Tabelas
*----------------------------------------------------------------------*
TABLES: vbak, "Documento de vendas: dados de cabeçalho
        t151, "Clientes: grupos de clientes
        kna1, "Mestre de clientes (parte geral)
        eina, "Registro info de compras - dados gerais
        vbap. "Documento de vendas: dados de item

*----------------------------------------------------------------------*
* Tipos
*----------------------------------------------------------------------*
TYPES: BEGIN OF ty_vendas,
         vbeln    TYPE vbak-vbeln,
         posnr    TYPE vbap-posnr,
         matnr    TYPE vbap-matnr,
         pstyv    TYPE vbap-pstyv,
         knumv    TYPE vbak-knumv,
         erdat    TYPE vbak-erdat,
         erzet    TYPE vbak-erzet,
         ernam    TYPE vbak-ernam,
         werks    TYPE vbap-werks,
         auart    TYPE vbak-auart,
         vtweg    TYPE vbak-vtweg,
         vkbur    TYPE vbak-vkbur,
         vkgrp    TYPE vbak-vkgrp,
         vend     TYPE vbpa-kunnr,
         kunnr    TYPE vbak-kunnr,
         name1    TYPE kna1-name1,
         ort01    TYPE kna1-ort01,
         regio    TYPE kna1-regio,
         kdgrp    TYPE vbkd-kdgrp,
         bzirk    TYPE vbkd-bzirk,
         zterm    TYPE vbkd-zterm,
         bstkd    TYPE vbkd-bstkd,
         route    TYPE vbap-route,
         augru    TYPE vbak-augru,
         kwmeng   TYPE vbap-kwmeng,
       END OF ty_vendas.

TYPES: BEGIN OF ty_grupo,
         hitgrp   TYPE zsdtb_album_hits-hitgrp,
         matnr    TYPE zsdtb_album_hits-matnr,
         dgrp     TYPE c LENGTH 30,
         ncmp     TYPE c LENGTH 30,
       END OF ty_grupo.

*----------------------------------------------------------------------*
* Tabelas Internas
*----------------------------------------------------------------------*
DATA: lt_album_hits TYPE STANDARD TABLE OF zsdtb_album_hits WITH HEADER LINE,
      lt_vendas     TYPE STANDARD TABLE OF ty_vendas        WITH HEADER LINE,
      lt_vend_t     TYPE STANDARD TABLE OF zst_hit_vendas   WITH HEADER LINE,
      lt_grupo      TYPE STANDARD TABLE OF ty_grupo         WITH HEADER LINE,
      lt_dsc_grp    TYPE STANDARD TABLE OF zsdt052          WITH HEADER LINE,
      lt_qt_falt    TYPE STANDARD TABLE OF zst_hits_qt_falt WITH HEADER LINE,
      lt_qt_hits    TYPE STANDARD TABLE OF zst_hits_qt      WITH HEADER LINE.

*----------------------------------------------------------------------*
* Variáveis
*----------------------------------------------------------------------*
DATA: v_nhits TYPE n LENGTH 4.

*----------------------------------------------------------------------*
* Declarações para tabela dinamica
*----------------------------------------------------------------------*
* Essa tabela armazena o conteúdo de todos os componentes (campos)
DATA: t_comp   TYPE cl_abap_structdescr=>component_table.

* Objeto utilizado para criar a estrutura dinâmica
DATA: o_strtype  TYPE REF TO cl_abap_structdescr.

* Objeto utilizado para criar a tabek dinâmica
DATA: o_tabtype  TYPE REF TO cl_abap_tabledescr.

* O nosso ponto de dados de referência
DATA: wa_data   TYPE REF TO data.

* Área de trabalho para lidar com atributos e o nome de cada campo.
DATA: wa_comp      LIKE LINE OF t_comp.

* Variáveis para construir o nome de cada campo
DATA: v_nome_campo   TYPE txt30.
DATA: v_numero_campo TYPE text10.

* Ponteiro para manipular tabela interna dinâmica
FIELD-SYMBOLS: <t_tab> TYPE table.

* Ponteiro para manipular work área dinâmica
FIELD-SYMBOLS: <wa_tab> TYPE any.

* Ponteiro para manipular campo
FIELD-SYMBOLS: <fs_campo> TYPE any.

*----------------------------------------------------------------------*
* Definições ALV
*----------------------------------------------------------------------*
DATA: t_sort              TYPE slis_t_sortinfo_alv WITH HEADER LINE,
      t_sort1             TYPE slis_t_sortinfo_alv,
      ti_fieldcat         TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      ti_list_top_of_page TYPE slis_t_listheader,
      ls_fieldcat         TYPE slis_fieldcat_alv,
      variante            LIKE disvariant.

DATA: v_pos     TYPE i,
      v_layout  TYPE slis_layout_alv,    "Layout ALV
      v_repid   LIKE sy-repid,           "Programa
      v_selecao TYPE slis_selfield,
      v_indice  LIKE sy-tabix.


*----------------------------------------------------------------------*
* Parâmetros de Seleção
*----------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-004.
SELECTION-SCREEN: BEGIN OF LINE.
PARAMETERS: p_ana RADIOBUTTON GROUP r1.
SELECTION-SCREEN: COMMENT 4(20) text-005 FOR FIELD p_ana.
PARAMETERS: p_sin RADIOBUTTON GROUP r1 DEFAULT 'X'.
SELECTION-SCREEN: COMMENT 70(10) text-006 FOR FIELD p_sin.
SELECTION-SCREEN:END OF LINE.
SELECTION-SCREEN: END OF BLOCK b1.

SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE text-007.
SELECT-OPTIONS: s_erdat FOR vbak-erdat OBLIGATORY NO-EXTENSION,
                s_typvd FOR vbak-auart OBLIGATORY,
                s_typdv FOR vbak-auart OBLIGATORY,
                s_kdgrp FOR t151-kdgrp OBLIGATORY.
SELECTION-SCREEN: END OF BLOCK b2.

SELECTION-SCREEN: BEGIN OF BLOCK b3 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_vkorg FOR vbak-vkorg,
                s_werks FOR vbap-werks,
                s_vtweg FOR vbak-vtweg,
                s_spart FOR vbak-spart,
                s_vkbur FOR vbak-vkbur,
                s_vkgrp FOR vbak-vkgrp,
                s_vend  FOR kna1-kunnr,
                s_kunnr FOR vbak-kunnr,
                s_lifnr FOR eina-lifnr,
                s_matnr FOR vbap-matnr.
SELECTION-SCREEN: END OF BLOCK b3.

SELECTION-SCREEN: BEGIN OF BLOCK b4 WITH FRAME TITLE text-008.
SELECT-OPTIONS: s_nhits FOR v_nhits.
SELECTION-SCREEN: END OF BLOCK b4.



*----------------------------------------------------------------------*
* Inicio do Processamento
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_verifica_periodo.
  PERFORM f_limpa_variavis.
  PERFORM f_busca_dados.
  PERFORM f_monta_dados.

  PERFORM f_monta_alv.


*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
*       Status do processamento
*----------------------------------------------------------------------*
FORM f_status USING p_perc p_text.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = p_perc
      text       = p_text.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_DADOS
*&---------------------------------------------------------------------*
*       Busca dados nas tabelas
*----------------------------------------------------------------------*
FORM f_busca_dados .

* Busca Dados de Power SKU e HITS
  PERFORM f_status USING 15 text-009.
  SELECT *
    INTO TABLE lt_album_hits
    FROM zsdtb_album_hits
   WHERE kdgrp  IN s_kdgrp
     AND matnr  IN s_matnr
     AND vtweg  IN s_vtweg
     AND datini LE s_erdat-low
     AND datfim GE s_erdat-high.

  SORT lt_album_hits BY vtweg kdgrp hitgrp matnr.

  IF lt_album_hits[] IS NOT INITIAL.

* Busca dados Vendas
    PERFORM f_status USING 40 text-002.
    SELECT a~vbeln b~posnr b~matnr b~pstyv a~knumv a~erdat a~erzet a~ernam
           b~werks a~auart a~vtweg a~vkbur a~vkgrp e~kunnr a~kunnr d~name1
           d~ort01 d~regio c~kdgrp c~bzirk c~zterm c~bstkd b~route a~augru
           b~kwmeng
        FROM vbak AS a
       INNER JOIN vbap AS b ON a~vbeln EQ b~vbeln
       INNER JOIN vbkd AS c ON a~vbeln EQ c~vbeln
       INNER JOIN kna1 AS d ON a~kunnr EQ d~kunnr
       INNER JOIN vbpa AS e ON b~vbeln EQ e~vbeln
        INTO TABLE lt_vendas
         FOR ALL ENTRIES IN lt_album_hits
       WHERE a~erdat IN s_erdat
         AND ( a~auart  IN s_typvd   " Venda
          OR   a~auart  IN s_typdv ) " Devolução
         AND a~vtweg EQ lt_album_hits-vtweg
         AND a~vkbur IN s_vkbur
         AND a~vkgrp IN s_vkgrp
         AND a~kunnr IN s_kunnr
         AND a~spart IN s_spart
         AND a~vkorg IN s_vkorg
         AND b~werks IN s_werks
         AND b~matnr EQ lt_album_hits-matnr
         AND c~kdgrp EQ lt_album_hits-kdgrp
         AND e~kunnr IN s_vend
         AND e~parvw EQ 'VE'
         AND c~posnr EQ '000000'.

    IF lt_vendas[] IS INITIAL.

      MESSAGE s000(zsd) WITH 'Nenhum registro Encontrado' DISPLAY LIKE 'E'.
      STOP.

    ENDIF.

    SORT lt_vendas BY vbeln posnr.

  ELSE.

    MESSAGE s000(zsd) WITH 'Nenhum registro Encontrado' DISPLAY LIKE 'E'.
    STOP.

  ENDIF.

ENDFORM.                    " F_BUSCA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_LIMPA_VARIAVIS
*&---------------------------------------------------------------------*
*       Limpa variáveis, tabelas e estruturas
*----------------------------------------------------------------------*
FORM f_limpa_variavis .

  CLEAR: lt_album_hits,
         lt_vendas,
         lt_vend_t,
         lt_grupo,
         lt_dsc_grp,
         lt_qt_falt,
         lt_qt_hits.

  REFRESH: lt_album_hits,
           lt_vendas,
           lt_vend_t,
           lt_grupo,
           lt_dsc_grp,
           lt_qt_falt,
           lt_qt_hits.

ENDFORM.                    " F_LIMPA_VARIAVIS
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_DADOS
*&---------------------------------------------------------------------*
*       Monta dados para saida
*----------------------------------------------------------------------*
FORM f_monta_dados .

  DATA: lv_kwmeng     TYPE vbap-kwmeng.

  PERFORM f_status USING 60 text-010.

  SORT lt_vendas BY vtweg vkbur vkgrp vend kunnr kdgrp matnr.

* Totaliza vendas por Canal de distribuição, Escritório de Vendas,
*Grupo de Vendedores, Vendedor, Cliente, Grupo de Clientes e Material
  LOOP AT lt_vendas.
    MOVE-CORRESPONDING lt_vendas TO lt_vend_t.
    IF lt_vendas-auart IN s_typdv.
      lt_vend_t-kwmeng = lt_vend_t-kwmeng * -1.
    ENDIF.
    COLLECT lt_vend_t.
    CLEAR: lt_vend_t.
  ENDLOOP.

  SORT lt_vend_t BY vtweg vkbur vkgrp vend kunnr kdgrp matnr.

* Prepara Grupos para exibição
  LOOP AT lt_album_hits.
    MOVE: lt_album_hits-hitgrp  TO lt_grupo-hitgrp,
          lt_album_hits-matnr   TO lt_grupo-matnr.

    APPEND lt_grupo.
    CLEAR: lt_grupo.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM lt_grupo COMPARING hitgrp matnr.
  SORT: lt_grupo      BY hitgrp matnr.

  PERFORM f_monta_tabela_saida.

  PERFORM f_popula_tabela_saida.

ENDFORM.                    " F_MONTA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_TABELA_SAIDA
*&---------------------------------------------------------------------*
*       Monta a tabela para saida
*----------------------------------------------------------------------*
FORM f_monta_tabela_saida .

  DATA: lv_grupo     TYPE zsdtb_album_hits-hitgrp,
        lv_matnr_aux TYPE zsdtb_album_hits-matnr,
        lv_matnr     TYPE mara-matnr.

  PERFORM f_busca_desc_grp.

* Adiciona campo Canal de distribuição
  wa_comp-name = 'VTWEG'.
  wa_comp-type = cl_abap_elemdescr=>get_c( p_length = 2 ).
  APPEND wa_comp TO t_comp.
  CLEAR: wa_comp.

* Adiciona campo Escritório de vendas
  wa_comp-name = 'VKBUR'.
  wa_comp-type = cl_abap_elemdescr=>get_c( p_length = 4 ).
  APPEND wa_comp TO t_comp.
  CLEAR: wa_comp.

* Adiciona campo Equipe de vendas
  wa_comp-name = 'VKGRP'.
  wa_comp-type = cl_abap_elemdescr=>get_c( p_length = 3 ).
  APPEND wa_comp TO t_comp.
  CLEAR: wa_comp.

* Adiciona campo Vendedor
  wa_comp-name = 'VEND'.
  wa_comp-type = cl_abap_elemdescr=>get_c( p_length = 10 ).
  APPEND wa_comp TO t_comp.
  CLEAR: wa_comp.

* Adiciona campo Cliente
  wa_comp-name = 'KUNNR'.
  wa_comp-type = cl_abap_elemdescr=>get_c( p_length = 10 ).
  APPEND wa_comp TO t_comp.
  CLEAR: wa_comp.

* Adiciona campo Razão Social
  wa_comp-name = 'NAME1'.
  wa_comp-type = cl_abap_elemdescr=>get_c( p_length = 35 ).
  APPEND wa_comp TO t_comp.
  CLEAR: wa_comp.

* Adiciona campo Grupo de clientes
  wa_comp-name = 'KDGRP'.
  wa_comp-type = cl_abap_elemdescr=>get_c( p_length = 2 ).
  APPEND wa_comp TO t_comp.
  CLEAR: wa_comp.

  CLEAR: lv_grupo.

* Adiciona campos para Grupos
  LOOP AT lt_grupo.
    CASE 'X'.
      WHEN p_sin. "Para relatório Sintético, cria colunas soment para o grupo
        IF lv_grupo EQ lt_grupo-hitgrp.
          CONTINUE.
        ENDIF.
      WHEN p_ana. "Para relatório Analitico, cria colunas para Grupo e Material
        IF lv_grupo EQ lt_grupo-hitgrp AND lv_matnr_aux EQ lt_grupo-matnr.
          CONTINUE.
        ENDIF.
      WHEN OTHERS.
    ENDCASE.

    lv_grupo     = lt_grupo-hitgrp.
    lv_matnr_aux = lt_grupo-matnr.

    CLEAR: v_nome_campo.
    WRITE sy-tabix TO v_numero_campo.
    CONDENSE v_numero_campo.
    CONCATENATE 'GRUPO' v_numero_campo INTO v_nome_campo.
*   Nome para cada campo
    wa_comp-name = v_nome_campo.

    wa_comp-type = cl_abap_elemdescr=>get_p( p_length = 7 p_decimals = 3 ).
    APPEND wa_comp TO t_comp.
    CLEAR: wa_comp.

    lt_grupo-ncmp = v_nome_campo.
    READ TABLE lt_dsc_grp WITH KEY hitgrp = lt_grupo-hitgrp
                            BINARY SEARCH.
    CASE 'X'.
      WHEN p_ana.
        CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
          EXPORTING
            input  = lt_grupo-matnr
          IMPORTING
            output = lv_matnr.

        CONCATENATE lt_dsc_grp-desc_grp '-' lv_matnr INTO lt_grupo-dgrp
                                                SEPARATED BY space.
      WHEN p_sin.
        lt_grupo-dgrp = lt_dsc_grp-desc_grp.
      WHEN OTHERS.
    ENDCASE.

    MODIFY lt_grupo.
  ENDLOOP.

  DELETE lt_grupo WHERE ncmp IS INITIAL.

* Adiciona campo Contador de Hits
  wa_comp-name = 'HITCONT'.
  wa_comp-type = cl_abap_elemdescr=>get_n( p_length = 3 ).
  APPEND wa_comp TO t_comp.
  CLEAR: wa_comp.


*&---------------------------------------------------------------------
* cria uma estrutura com todos os campos carregados na t_comp
*&---------------------------------------------------------------------
  o_strtype = cl_abap_structdescr=>create( t_comp ).

* Nesta etapa, é criada uma tabela utilizando o_strtype,
* E passando dois parâmetros adicionais:
*     p_table_kind (Standard, Hashed, Ordenado)
* P_unique (esta para indicar se tem chave única ou não)
  o_tabtype =
  cl_abap_tabledescr=>create( p_line_type  = o_strtype
                              p_table_kind = cl_abap_tabledescr=>tablekind_std
                              p_unique     = abap_false ).

*&---------------------------------------------------------------------
* Dados para lidar com o novo tipo de tabela.
*&---------------------------------------------------------------------
  TRY.
      CREATE DATA wa_data  TYPE HANDLE o_tabtype.
    CATCH cx_sy_create_data_error.
  ENDTRY.

*&---------------------------------------------------------------------
*& Armazena tabela interna no ponteiro(field symbol)
*&---------------------------------------------------------------------
  TRY.
      ASSIGN wa_data->* TO <t_tab>.
    CATCH cx_sy_assign_cast_illegal_cast.
    CATCH cx_sy_assign_cast_unknown_type.
    CATCH cx_sy_assign_out_of_range.
  ENDTRY.

*&---------------------------------------------------------------------
* Dados para lidar com a nova work area.
*&---------------------------------------------------------------------
  TRY.
      CREATE DATA wa_data  TYPE HANDLE o_strtype.
    CATCH cx_sy_create_data_error.
  ENDTRY.

*&---------------------------------------------------------------------
*&  Armazena nova work area no ponteiro
*&---------------------------------------------------------------------
  TRY.
      ASSIGN wa_data->* TO <wa_tab>.
    CATCH cx_sy_assign_cast_illegal_cast.
    CATCH cx_sy_assign_cast_unknown_type.
    CATCH cx_sy_assign_out_of_range.
  ENDTRY.

ENDFORM.                    " F_MONTA_TABELA_SAIDA
*&---------------------------------------------------------------------*
*&      Form  F_POPULA_TABELA_SAIDA
*&---------------------------------------------------------------------*
*       Popula tabela de saida
*----------------------------------------------------------------------*
FORM f_popula_tabela_saida .

  DATA: lv_add TYPE c LENGTH 1.

  PERFORM f_status USING 80 text-010.

  CLEAR: <wa_tab>.
  REFRESH: <t_tab>.

  SORT lt_album_hits BY kdgrp matnr vtweg.

  LOOP AT lt_vend_t.
    CLEAR: lv_add.

* Canal de distribuição
    ASSIGN COMPONENT 'VTWEG' OF STRUCTURE <wa_tab> TO <fs_campo>.
    IF <fs_campo> IS ASSIGNED.
      <fs_campo> = lt_vend_t-vtweg.
      UNASSIGN <fs_campo>.
    ENDIF.

* Escritório de vendas
    ASSIGN COMPONENT 'VKBUR' OF STRUCTURE <wa_tab> TO <fs_campo>.
    IF <fs_campo> IS ASSIGNED.
      <fs_campo> = lt_vend_t-vkbur.
      UNASSIGN <fs_campo>.
    ENDIF.

* Equipe de vendas
    ASSIGN COMPONENT 'VKGRP' OF STRUCTURE <wa_tab> TO <fs_campo>.
    IF <fs_campo> IS ASSIGNED.
      <fs_campo> = lt_vend_t-vkgrp.
      UNASSIGN <fs_campo>.
    ENDIF.

* Vendedor
    ASSIGN COMPONENT 'VEND' OF STRUCTURE <wa_tab> TO <fs_campo>.
    IF <fs_campo> IS ASSIGNED.
      <fs_campo> = lt_vend_t-vend.
      UNASSIGN <fs_campo>.
    ENDIF.

* Cliente
    ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <wa_tab> TO <fs_campo>.
    IF <fs_campo> IS ASSIGNED.
      <fs_campo> = lt_vend_t-kunnr.
      UNASSIGN <fs_campo>.
    ENDIF.

* Razão Social
    ASSIGN COMPONENT 'NAME1' OF STRUCTURE <wa_tab> TO <fs_campo>.
    IF <fs_campo> IS ASSIGNED.
      <fs_campo> = lt_vend_t-name1.
      UNASSIGN <fs_campo>.
    ENDIF.

* Grupo de clientes
    ASSIGN COMPONENT 'KDGRP' OF STRUCTURE <wa_tab> TO <fs_campo>.
    IF <fs_campo> IS ASSIGNED.
      <fs_campo> = lt_vend_t-kdgrp.
      UNASSIGN <fs_campo>.
    ENDIF.

    READ TABLE lt_album_hits WITH KEY kdgrp = lt_vend_t-kdgrp
                                      matnr = lt_vend_t-matnr
                                      vtweg = lt_vend_t-vtweg
                               BINARY SEARCH.
    IF sy-subrc EQ 0.
      IF p_sin EQ 'X'. "Para sintético usa somente o grupo de Hits
        READ TABLE lt_grupo WITH KEY hitgrp = lt_album_hits-hitgrp.
      ELSE.
        READ TABLE lt_grupo WITH KEY hitgrp = lt_album_hits-hitgrp
                                     matnr  = lt_vend_t-matnr.
      ENDIF.
      IF sy-subrc EQ 0.
* Quantidade por material e grupo
        ASSIGN COMPONENT lt_grupo-ncmp OF STRUCTURE <wa_tab> TO <fs_campo>.
        IF <fs_campo> IS ASSIGNED.
          IF p_sin EQ 'X'. " Para sintético soma todos os materiais do grupo
            <fs_campo> = <fs_campo> + lt_vend_t-kwmeng.
          ELSE.
            <fs_campo> = lt_vend_t-kwmeng.
          ENDIF.
          UNASSIGN <fs_campo>.
        ENDIF.
*** BEGIN - COMENTADO - Para uso da Função ZSD_CALC_HITS - Fim deste FORM. ---*
**        CLEAR: lt_qt_falt.
*** Guarda quantidades faltantes do Grupo
**        READ TABLE lt_qt_falt WITH KEY vtweg  = lt_vend_t-vtweg
**                                       vkbur  = lt_vend_t-vkbur
**                                       vkgrp  = lt_vend_t-vkgrp
**                                       vend   = lt_vend_t-vend
**                                       kunnr  = lt_vend_t-kunnr
**                                       kdgrp  = lt_vend_t-kdgrp
**                                       hitgrp = lt_album_hits-hitgrp.
**        IF sy-subrc EQ 0.
**          lt_qt_falt-kwmeng = lt_qt_falt-kwmeng - lt_vend_t-kwmeng.
**          MODIFY lt_qt_falt INDEX sy-tabix.
**        ELSE.
**          lt_qt_falt-vtweg  = lt_vend_t-vtweg.
**          lt_qt_falt-vkbur  = lt_vend_t-vkbur.
**          lt_qt_falt-vkgrp  = lt_vend_t-vkgrp.
**          lt_qt_falt-vend   = lt_vend_t-vend.
**          lt_qt_falt-kunnr  = lt_vend_t-kunnr.
**          lt_qt_falt-kdgrp  = lt_vend_t-kdgrp.
**          lt_qt_falt-hitgrp = lt_album_hits-hitgrp.
**          lt_qt_falt-kwmeng = lt_album_hits-qtdhit - lt_vend_t-kwmeng.
**          APPEND lt_qt_falt.
**        ENDIF.
*** END - COMENTADO - Para uso da Função ZSD_CALC_HITS - Fim deste FORM. ---*

      ENDIF.
    ENDIF.

    AT END OF kdgrp.
      lv_add = 'X'.
    ENDAT.

    AT END OF kunnr.
      lv_add = 'X'.
    ENDAT.

    AT END OF vend.
      lv_add = 'X'.
    ENDAT.

    AT END OF vkgrp.
      lv_add = 'X'.
    ENDAT.

    AT END OF vkbur.
      lv_add = 'X'.
    ENDAT.

    AT END OF vtweg.
      lv_add = 'X'.
    ENDAT.

    IF lv_add IS NOT INITIAL.
* Adiciona registro a tabela
      APPEND <wa_tab> TO <t_tab>.
      CLEAR: <wa_tab>.
    ENDIF.
  ENDLOOP.

*** BEGIN - COMENTADO - Para uso da Função ZSD_CALC_HITS - Fim deste FORM. ---*
*** Conta a quandidade de Hits por cliente
***  LOOP AT lt_qt_falt.
***    IF lt_qt_falt-kwmeng LE 0.
***      READ TABLE lt_qt_hits WITH KEY vtweg  = lt_qt_falt-vtweg
***                                     vkbur  = lt_qt_falt-vkbur
***                                     vkgrp  = lt_qt_falt-vkgrp
***                                     vend   = lt_qt_falt-vend
***                                     kunnr  = lt_qt_falt-kunnr
***                                     kdgrp  = lt_qt_falt-kdgrp.
***      ADD 1 TO lt_qt_hits-nhits.
***      IF sy-subrc EQ 0.
***        MODIFY lt_qt_hits INDEX sy-tabix.
***      ELSE.
***        MOVE-CORRESPONDING lt_qt_falt TO lt_qt_hits.
***        APPEND lt_qt_hits.
***      ENDIF.
***      CLEAR: lt_qt_hits.
***    ENDIF.
***  ENDLOOP.
*** END - COMENTADO - Para uso da Função ZSD_CALC_HITS - Fim deste FORM. ---*

* Calulo dos HITS
  CALL FUNCTION 'ZSD_CALC_HITS'
    TABLES
      lt_album_hits = lt_album_hits
      lt_vend_t     = lt_vend_t
      lt_qt_hits    = lt_qt_hits.

* Elimina registros que estão fora do intervalo de nº de grupo
*de hits (parâmetro da tela de seleção)
  IF s_nhits[] IS NOT INITIAL.
    DELETE lt_qt_hits WHERE nhits NOT IN s_nhits.
  ENDIF.

  PERFORM f_popula_contador_hits.

ENDFORM.                    " F_POPULA_TABELA_SAIDA
*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_DESC_GRP
*&---------------------------------------------------------------------*
*       Busca descrição dos grupos de Hits
*----------------------------------------------------------------------*
FORM f_busca_desc_grp .

  SELECT *
    INTO TABLE lt_dsc_grp
    FROM zsdt052
     FOR ALL ENTRIES IN lt_grupo
   WHERE hitgrp EQ lt_grupo-hitgrp.

  SORT lt_dsc_grp BY hitgrp.

ENDFORM.                    " F_BUSCA_DESC_GRP
*&---------------------------------------------------------------------*
*&      Form  F_POPULA_CONTADOR_HITS
*&---------------------------------------------------------------------*
*       Popula campo contador de hits
*----------------------------------------------------------------------*
FORM f_popula_contador_hits .

  DATA: BEGIN OF lt_dele OCCURS 0,
          idx TYPE sy-tabix,
        END OF lt_dele.

  DATA: lv_vtweg  TYPE vbak-vtweg,
        lv_vkbur  TYPE vbak-vkbur,
        lv_vkgrp  TYPE vbak-vkgrp,
        lv_vend   TYPE vbpa-kunnr,
        lv_kunnr  TYPE vbak-kunnr,
        lv_kdgrp  TYPE vbkd-kdgrp.

  CLEAR: lt_dele.
  REFRESH: lt_dele.

  LOOP AT <t_tab> ASSIGNING <wa_tab>.
    lt_dele-idx = sy-tabix.
    CLEAR: lv_vtweg,
           lv_vkbur,
           lv_vkgrp,
           lv_vend,
           lv_kunnr,
           lv_kdgrp,
           lt_qt_hits.

    ASSIGN COMPONENT 'VTWEG' OF STRUCTURE <wa_tab> TO <fs_campo>.
    IF <fs_campo> IS ASSIGNED.
      lv_vtweg = <fs_campo>.
      UNASSIGN <fs_campo>.
    ENDIF.

    ASSIGN COMPONENT 'VKBUR' OF STRUCTURE <wa_tab> TO <fs_campo>.
    IF <fs_campo> IS ASSIGNED.
      lv_vkbur = <fs_campo>.
      UNASSIGN <fs_campo>.
    ENDIF.

    ASSIGN COMPONENT 'VKGRP' OF STRUCTURE <wa_tab> TO <fs_campo>.
    IF <fs_campo> IS ASSIGNED.
      lv_vkgrp = <fs_campo>.
      UNASSIGN <fs_campo>.
    ENDIF.

    ASSIGN COMPONENT 'VEND' OF STRUCTURE <wa_tab> TO <fs_campo>.
    IF <fs_campo> IS ASSIGNED.
      lv_vend = <fs_campo>.
      UNASSIGN <fs_campo>.
    ENDIF.

    ASSIGN COMPONENT 'KUNNR' OF STRUCTURE <wa_tab> TO <fs_campo>.
    IF <fs_campo> IS ASSIGNED.
      lv_kunnr = <fs_campo>.
      UNASSIGN <fs_campo>.
    ENDIF.

    ASSIGN COMPONENT 'KDGRP' OF STRUCTURE <wa_tab> TO <fs_campo>.
    IF <fs_campo> IS ASSIGNED.
      lv_kdgrp = <fs_campo>.
      UNASSIGN <fs_campo>.
    ENDIF.

    READ TABLE lt_qt_hits WITH KEY vtweg  = lv_vtweg
                                   vkbur  = lv_vkbur
                                   vkgrp  = lv_vkgrp
                                   vend   = lv_vend
                                   kunnr  = lv_kunnr
                                   kdgrp  = lv_kdgrp.
    IF sy-subrc NE 0.
      APPEND lt_dele.
      CONTINUE.
    ENDIF.

* Popula Contador de Hits
    ASSIGN COMPONENT 'HITCONT' OF STRUCTURE <wa_tab> TO <fs_campo>.
    IF <fs_campo> IS ASSIGNED.
      <fs_campo> = lt_qt_hits-nhits.
      UNASSIGN <fs_campo>.
    ENDIF.
  ENDLOOP.

* Elimina registros que estão fora do intervalo de nº de grupo
*de hits (parâmetro da tela de seleção)
  IF s_nhits[] IS NOT INITIAL.
    SORT lt_dele BY idx DESCENDING.
    LOOP AT lt_dele.
      DELETE <t_tab> INDEX lt_dele-idx.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " F_POPULA_CONTADOR_HITS
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_ALV
*&---------------------------------------------------------------------*
*       Monta ALV
*----------------------------------------------------------------------*
FORM f_monta_alv .

  PERFORM f_status USING 90 text-011.

  PERFORM f_ordena_colunas.
  PERFORM f_preenche_catalogo.
  PERFORM f_cabecalho.
  PERFORM f_imprime_alv.

ENDFORM.                    " F_MONTA_ALV
*&---------------------------------------------------------------------*
*&      Form  F_ORDENA_COLUNAS
*&---------------------------------------------------------------------*
*       Ordenação
*----------------------------------------------------------------------*
FORM f_ordena_colunas .

  CLEAR :  t_sort , t_sort1.
  REFRESH : t_sort , t_sort1.

  PERFORM: f_sort USING 'VTWEG'  1  'X' space space space.
  PERFORM: f_sort USING 'VKBUR'  2  'X' space space space.
  PERFORM: f_sort USING 'VKGRP'  3  'X' space space space.
  PERFORM: f_sort USING 'VEND'   4  'X' space space space.
  PERFORM: f_sort USING 'KUNNR'  5  'X' space space space.
  PERFORM: f_sort USING 'NAME1'  6  'X' space space space.
  PERFORM: f_sort USING 'KDGRP'  7  'X' space space space.

ENDFORM.                    " F_ORDENA_COLUNAS
*&---------------------------------------------------------------------*
*&      Form  F_SORT
*&---------------------------------------------------------------------*
*       Adiciona ordenação
*----------------------------------------------------------------------*
*      -->P_NAME    Nome do campo
*      -->P_POS     Possição
*      -->P_UP      Crescente
*      -->P_DOWN    Decrescente
*      -->P_SUBTOT  Subtotal
*      -->P_EXPA    text
*----------------------------------------------------------------------*
FORM f_sort  USING    p_name p_pos p_up p_down p_subtot p_expa.

  CLEAR: t_sort.

  t_sort-fieldname = p_name.
  t_sort-spos      = p_pos.
  t_sort-up        = p_up.
  t_sort-down      = p_down.
  t_sort-subtot    = p_subtot.
  t_sort-expa      = p_expa.
  APPEND t_sort TO t_sort1.

ENDFORM.                    " F_SORT
*&---------------------------------------------------------------------*
*&      Form  F_PREENCHE_CATALOGO
*&---------------------------------------------------------------------*
*       Preenche Catalogo de campos
*----------------------------------------------------------------------*
FORM f_preenche_catalogo .

  CLEAR v_pos.
  REFRESH: ti_fieldcat.

  PERFORM add_field USING:
        '<t_tab>' 'VTWEG'   'Canal'         '02' 'L' ' ' ' ' ' ' ' ',
        '<t_tab>' 'VKBUR'   'EV'            '04' 'L' ' ' ' ' ' ' ' ',
        '<t_tab>' 'VKGRP'   'GV'            '03' 'L' ' ' ' ' ' ' ' ',
        '<t_tab>' 'VEND'    'Vendedor'      '10' 'L' ' ' ' ' ' ' ' ',
        '<t_tab>' 'KUNNR'   'Cliente'       '10' 'L' ' ' ' ' ' ' ' ',
        '<t_tab>' 'NAME1'   'Razão Social'  '35' 'L' ' ' ' ' ' ' ' ',
        '<t_tab>' 'KDGRP'   'Grp.Cl.'       '02' 'L' ' ' ' ' ' ' ' '.

  LOOP AT lt_grupo.
    PERFORM add_field USING:
          '<t_tab>' lt_grupo-ncmp lt_grupo-dgrp     '13' ' ' ' ' ' ' ' ' ' '.
  ENDLOOP.

  PERFORM add_field USING:
        '<t_tab>' 'HITCONT' 'Cont.Hits'     '03' ' ' ' ' ' ' ' ' ' '.

ENDFORM.                    " F_PREENCHE_CATALOGO
*&---------------------------------------------------------------------*
*&      Form  ADD_FIELD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->p_table     Tabela
*      -->p_field     Campo
*      -->p_tit       Titulo
*      -->p_tam       Tamanho
*      -->p_just      Justificado
*      -->p_fix       Coluna fixa
*      -->p_sum       Somatório
*      -->p_hotspot   Hotspot
*      -->p_no_out    Não exibir
*----------------------------------------------------------------------*
FORM add_field  USING    p_table
                         p_field
                         p_tit
                         p_tam
                         p_just
                         p_fix
                         p_sum
                         p_hotspot
                         p_no_out.

  CLEAR ls_fieldcat.
  ADD 1 TO v_pos.
  ls_fieldcat-col_pos       = v_pos.
  ls_fieldcat-fieldname     = p_field.
  ls_fieldcat-tabname       = p_table.
  ls_fieldcat-reptext_ddic  = p_tit.
  ls_fieldcat-just          = p_just.
  ls_fieldcat-outputlen     = p_tam.
  ls_fieldcat-fix_column    = p_fix.
  ls_fieldcat-do_sum        = p_sum.
  ls_fieldcat-hotspot       = p_hotspot.
  ls_fieldcat-no_zero       = 'X'.
  ls_fieldcat-no_out        = p_no_out.

  APPEND ls_fieldcat TO ti_fieldcat.

ENDFORM.                    " ADD_FIELD
*&---------------------------------------------------------------------*
*&      Form  F_CABECALHO
*&---------------------------------------------------------------------*
*       Cabeçalho do relatório
*----------------------------------------------------------------------*
FORM f_cabecalho .

  DATA: ls_line        TYPE slis_listheader,
      lv_linhas      TYPE i,
      lv_lin(10)     TYPE c,
      vl_dataini(10) TYPE c,
      vl_datafin(10) TYPE c.

  CLEAR: ls_line, lv_linhas.
  REFRESH ti_list_top_of_page.

  DESCRIBE TABLE <t_tab> LINES lv_linhas.
  lv_lin = lv_linhas.

  WRITE: s_erdat-low  TO vl_dataini.
  WRITE: s_erdat-high TO vl_datafin.

* Título do Relatório
  ls_line-typ  = 'H'.
  ls_line-info = 'Batalha Naval'.
  APPEND ls_line TO ti_list_top_of_page.

* Periodo
  ls_line-typ = 'S'.
  CONCATENATE 'Período: ' vl_dataini ' à ' vl_datafin
         INTO ls_line-info SEPARATED BY space.
  APPEND ls_line TO ti_list_top_of_page.

* Total de Clientes
  CONCATENATE: 'Número de Clientes: ' lv_lin INTO ls_line-info SEPARATED BY space.
  APPEND ls_line TO ti_list_top_of_page.

ENDFORM.                    " F_CABECALHO
*&---------------------------------------------------------------------*
*&      Form  F_IMPRIME_ALV
*&---------------------------------------------------------------------*
*       Exibe relatório
*----------------------------------------------------------------------*
FORM f_imprime_alv .

  v_layout-expand_all        = ''.
  v_layout-zebra             = 'X'.
  v_layout-colwidth_optimize = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program      = sy-repid
      i_callback_user_command = 'USER_COMMAND'
      i_callback_top_of_page  = 'TOP_OF_PAGE'
      is_layout               = v_layout                        "gs_layout
      it_fieldcat             = ti_fieldcat[]                   "gt_fieldcat
      it_sort                 = t_sort1                         "gt_sort
      i_save                  = 'A'
    TABLES
      t_outtab                = <t_tab>
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " F_IMPRIME_ALV
*----------------------------------------------------------------------*
*       FORM AT_USER_COMMAND                                           *
*----------------------------------------------------------------------*
*      Trata o que irá ser feito quando o usuário clicar nas colunas   *
*----------------------------------------------------------------------*
FORM user_command USING ucomm LIKE sy-ucomm
                           selfield TYPE kkblo_selfield.
  selfield = selfield.   "Selfield contem a coluna selecionada
  CASE ucomm.
    WHEN '&IC1'.
      READ TABLE <t_tab> ASSIGNING <wa_tab> INDEX selfield-tabindex.
      IF sy-subrc EQ 0.
      ENDIF.
    WHEN OTHERS.
  ENDCASE.

ENDFORM.                    "user_command
*&---------------------------------------------------------------------*
*&      Form  top_of_page
*&---------------------------------------------------------------------*
*       Função para exibição do cabeçalho
*----------------------------------------------------------------------*
FORM top_of_page.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = ti_list_top_of_page.

ENDFORM. "top_of_page
*&---------------------------------------------------------------------*
*&      Form  F_VERIFICA_PERIODO
*&---------------------------------------------------------------------*
*       Validações do periodo
*----------------------------------------------------------------------*
FORM f_verifica_periodo .

  IF s_erdat-low IS INITIAL OR
     s_erdat-high IS INITIAL.
    MESSAGE s000(zsd) WITH 'Preencher período corretamente.' DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.                    " F_VERIFICA_PERIODO