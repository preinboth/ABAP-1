*&---------------------------------------------------------------------*
*& Report  ZRMM0020  
*&         Águas
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zrmm0020.

*&---------------------------------------------------------------------*
* Tables
*&---------------------------------------------------------------------*

TABLES: proj,
        afko,
        zorcamento.

*&---------------------------------------------------------------------*
* Declaração de Constants
*&---------------------------------------------------------------------*
CONSTANTS  c_template TYPE c LENGTH 09 VALUE 'ZORC_SRV'.

*&---------------------------------------------------------------------*
* Declaração de Types
*&---------------------------------------------------------------------*

TYPES : BEGIN OF ty_saida,
          line      TYPE string,
        END OF   ty_saida.


TYPES : BEGIN OF ty_data,
          pspnr     TYPE proj-pspnr ,
          post1     TYPE proj-post1 ,
          postu     TYPE prps-postu ,
          posid     TYPE prps-posid ,
          aufnr     TYPE afko-aufnr ,
          pronr     TYPE afko-pronr ,
          vornr     TYPE afvc-vornr ,
          steus     TYPE afvc-steus , "Data: 08/10/2014 - 2014/1334
          ltxa1     TYPE afvc-ltxa1 ,
          aufpl     TYPE afvc-aufpl ,
          matkl     TYPE esll-matkl ,
          menge     TYPE esll-menge ,
          meins     TYPE esll-meins ,
          tbtwr     TYPE esll-tbtwr ,
          asnum     TYPE asmd-asnum ,
          ktext1    TYPE esll-ktext1 ,
          wgbez60   TYPE t023t-wgbez60 ,
          wgbez     TYPE t023t-wgbez ,
          matkl_02  TYPE t023t-matkl ,
          netwr     TYPE esll-netwr ,
          srvpos    TYPE esll-srvpos ,
          packno    TYPE esll-packno ,
          packno_02 TYPE esll-packno ,
          srvpos_02 TYPE esll-srvpos ,
          banfn     TYPE afvc-banfn,
          orcamento TYPE zorcamento-orcamento,
          zdatabase TYPE zorcamento-zdatabase,
        END OF ty_data.


TYPES : BEGIN OF ty_data_i,
         post1     TYPE proj-post1 ,
         postu     TYPE prps-postu ,
         posid     TYPE prps-posid ,
         aufnr     TYPE afko-aufnr ,
         banfn     TYPE afvc-banfn,
         aufpl     TYPE afvc-aufpl,
         orcamento TYPE zorcamento-orcamento,
         zdatabase TYPE zorcamento-zdatabase,
        END OF ty_data_i.


TYPES : BEGIN OF ty_data_aux,
          vornr     TYPE afvc-vornr ,                       "1-Nível
          ltxa1     TYPE afvc-ltxa1 ,                       "1-Nível
          wgbez60   TYPE t023t-wgbez60,                     "2-Nível,
          asnum     TYPE asmd-asnum ,
          ktext1    TYPE esll-ktext1 ,
          menge     TYPE esll-menge ,
          meins     TYPE esll-meins ,
          netwr     TYPE esll-netwr ,
          tbtwr     TYPE esll-tbtwr ,
          orcamento TYPE zorcamento-orcamento,
        END OF ty_data_aux.


TYPES : BEGIN OF ty_data_1,
         vornr     TYPE afvc-vornr ,                        "1-Nível
         ltxa1     TYPE afvc-ltxa1 ,                        "1-Nível
         total     TYPE esll-netwr ,                        "Total
         steus     TYPE afvc-steus, "08/10/2014
         orcamento TYPE zorcamento-orcamento,
        END OF ty_data_1.

TYPES : BEGIN OF ty_data_2,
         vornr     TYPE afvc-vornr ,                        "1-Nível
         ltxa1     TYPE afvc-ltxa1 ,                        "1-Nível
         wgbez60   TYPE t023t-wgbez60,                      "2-Nível,
         total     TYPE esll-netwr ,                        "Total
         matkl_02  TYPE t023t-matkl ,
         orcamento TYPE zorcamento-orcamento,
        END OF ty_data_2.

TYPES: BEGIN OF y_excel,
         a(300)  TYPE c,
         b(300)  TYPE c,
         c(300)  TYPE c,
         d(300)  TYPE c,
         e(300)  TYPE c,
         f(300)  TYPE c,
         g(300)  TYPE c,
         h(300)  TYPE c,
         i(300)  TYPE c,
         j(300)  TYPE c,
         k(300)  TYPE c,
         l(300)  TYPE c,
         m(300)  TYPE c,
         n(300)  TYPE c,
         o(300)  TYPE c,
         p(300)  TYPE c,
         q(300)  TYPE c,
         r(300)  TYPE c,
         s(300)  TYPE c,
         t(300)  TYPE c,
         u(300)  TYPE c,
         v(300)  TYPE c,
       END OF y_excel.

TYPES: BEGIN OF ty_t023t,
          wgbez60 TYPE t023t-wgbez60,
          wgbez   TYPE t023t-wgbez,
          matkl   TYPE t023t-matkl,
       END   OF ty_t023t.

TYPES: BEGIN OF ty_asmd,
          asnum  TYPE asmd-asnum,
          matkl  TYPE asmd-matkl,
          asktx  TYPE asmdt-asktx,
       END   OF ty_asmd.

TYPES: BEGIN OF ty_caufv,
          aufnr  TYPE caufv-aufnr,
          pronr  TYPE caufv-pronr,
       END   OF ty_caufv.

*&---------------------------------------------------------------------*
* Declaração de Tabelas Internas
*&---------------------------------------------------------------------*
DATA t_saida    TYPE STANDARD TABLE OF ty_saida    WITH HEADER LINE.
DATA t_data     TYPE STANDARD TABLE OF ty_data     WITH HEADER LINE.
DATA t_data_r   TYPE STANDARD TABLE OF ty_data     WITH HEADER LINE.
DATA t_data_r2  TYPE STANDARD TABLE OF ty_data     WITH HEADER LINE.
DATA t_data_i   TYPE STANDARD TABLE OF ty_data_i   WITH HEADER LINE.

DATA t_data_aux TYPE STANDARD TABLE OF ty_data_aux WITH HEADER LINE.
DATA t_data_1   TYPE STANDARD TABLE OF ty_data_1   WITH HEADER LINE.
DATA t_data_2   TYPE STANDARD TABLE OF ty_data_2   WITH HEADER LINE.
DATA t_excel    TYPE STANDARD TABLE OF y_excel     WITH HEADER LINE.

DATA: t_zorcamento       TYPE STANDARD TABLE OF zorcamento.                       "Daniely Santos - Megawork - Projeto Adequação PS - 24.04.2015
DATA: t_zorcamento_fase  TYPE STANDARD TABLE OF zorcamento_fase.                  "Daniely Santos - Megawork - Projeto Adequação PS - 24.04.2015
DATA: t_zorcamento_linha TYPE STANDARD TABLE OF zorcamento_linha.                 "Daniely Santos - Megawork - Projeto Adequação PS - 24.04.2015
DATA: t_asmd             TYPE STANDARD TABLE OF ty_asmd.                          "Daniely Santos - Megawork - Projeto Adequação PS - 24.04.2015
DATA: t_caufv            TYPE STANDARD TABLE OF ty_caufv.                         "Daniely Santos - Megawork - Projeto Adequação PS - 24.04.2015
DATA: t_t023t            TYPE STANDARD TABLE OF ty_t023t.                         "Daniely Santos - Megawork - Projeto Adequação PS - 24.04.2015

DATA: ti_network TYPE bapi_network_exp OCCURS 0 WITH HEADER LINE.
DATA: ti_activity TYPE bapi_network_activity_exp OCCURS 0 WITH HEADER LINE.

*&---------------------------------------------------------------------*
* Declaração de Variáveis
*&---------------------------------------------------------------------*
DATA: vl_fullpath  TYPE string,
      v_result     TYPE i.


*&---------------------------------------------------------------------*
* Parâmetros de Seleção
*&---------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.

SELECT-OPTIONS: p_orcam FOR zorcamento-orcamento MATCHCODE OBJECT zorcamento.   "Daniely Santos - Megawork - Projeto Adequação PS - 23.04.2015
SELECT-OPTIONS: p_aufnr FOR afko-aufnr           MATCHCODE OBJECT auko.         "s_pspnr FOR  proj-pspnr, RAFAEL NESTOR 21.02.2013 2012-1366

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.

PARAMETERS: p_file  TYPE string DEFAULT 'C:\TEMP' OBLIGATORY.

SELECTION-SCREEN END OF BLOCK b2.

*&---------------------------------------------------------------------*
* AT SELECTION-SCREEN ON VALUE-REQUEST FOR
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM f_get_directory CHANGING p_file.

*&---------------------------------------------------------------------*
* START-OF-SELECTION.
*&---------------------------------------------------------------------*

START-OF-SELECTION.

  IF p_orcam IS NOT INITIAL AND
   p_aufnr IS NOT INITIAL.
    WRITE text-m04.
  ELSE.
    PERFORM f_get_dados.
*  PERFORM f_processa_dados.
    PERFORM f_processa_excel.
    PERFORM f_gera_log.
  ENDIF.




*&---------------------------------------------------------------------*
*&      Form  F_GET_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_dados .
  TYPES: BEGIN OF ty_mara,
            matnr TYPE mara-matnr,
            matkl TYPE mara-matkl,
         END   OF ty_mara.

  TYPES: BEGIN OF ty_makt,
            matnr TYPE makt-matnr,
            maktx TYPE makt-maktx,
         END   OF ty_makt.

  TYPES: BEGIN OF ty_t023t,
            matkl    TYPE t023t-matkl,
*            maktx    TYPE t023t-maktx,
            wgbez60  TYPE t023t-wgbez60,
            wgbez    TYPE t023t-wgbez,
         END   OF ty_t023t.

  DATA: t_data_r2_aux       TYPE STANDARD TABLE OF ty_data,
        t_makt              TYPE STANDARD TABLE OF ty_makt,
        t_t023t             TYPE STANDARD TABLE OF ty_t023t,
        t_data_mat_aux      TYPE STANDARD TABLE OF ty_mara,
        t_mara              TYPE STANDARD TABLE OF ty_mara.


  DATA: ls_zorcamento       TYPE zorcamento,
        ls_zorcamento_fase  TYPE zorcamento_fase,
        ls_zorcamento_linha TYPE zorcamento_linha,
        ls_data_r2_aux      TYPE ty_data,
        ls_mara             TYPE ty_mara,
        ls_makt             TYPE ty_makt,
        ls_asmd             TYPE ty_asmd,
        ls_caufv            TYPE ty_caufv,
        ls_t023t            TYPE ty_t023t.

  DATA: vl_matnr            TYPE mara-matnr.

  CLEAR: t_data_r,
         t_data_i.

  REFRESH: t_data_r,
           t_data_i.

  DATA: v_number TYPE bapi_network_list-network.
  DATA: ls_return TYPE bapireturn1.

  CLEAR: v_number, ls_return.
  CLEAR: ti_network, ti_network[], ti_activity, ti_activity[].

* Alteração - Daniely Santos - Megawork - Projeto Adequação PS - 23.04.2015
* Inicio

  IF p_orcam[] IS NOT INITIAL.

    CLEAR: t_data_r,  t_data_r[].
    CLEAR: t_data_r2, t_data_r2[].

    SELECT *
      INTO TABLE t_zorcamento
      FROM zorcamento
      WHERE orcamento IN p_orcam.

    SORT t_zorcamento BY aufnr.

    IF t_zorcamento[] IS NOT INITIAL.

      SELECT aufnr pronr
        INTO TABLE t_caufv
        FROM caufv
        FOR ALL ENTRIES IN t_zorcamento
        WHERE aufnr = t_zorcamento-aufnr.

      SELECT *
        INTO TABLE t_zorcamento_fase
        FROM zorcamento_fase
        FOR ALL ENTRIES IN t_zorcamento
        WHERE orcamento = t_zorcamento-orcamento.

      SELECT *
        INTO TABLE t_zorcamento_linha
        FROM zorcamento_linha
        FOR ALL ENTRIES IN t_zorcamento
        WHERE orcamento = t_zorcamento-orcamento.

      IF t_zorcamento_linha[] IS NOT INITIAL.

        SELECT asmd~asnum asmd~matkl asmdt~asktx
          INTO TABLE t_asmd
          FROM asmd
          INNER JOIN asmdt ON
              asmd~asnum = asmdt~asnum
          FOR ALL ENTRIES IN t_zorcamento_linha
          WHERE asmd~asnum = t_zorcamento_linha-srvpos.

        IF t_asmd[] IS NOT INITIAL.

          SELECT matkl wgbez60 wgbez
            INTO TABLE t_t023t
            FROM t023t
            FOR ALL ENTRIES IN t_asmd
            WHERE matkl = t_asmd-matkl.

        ENDIF.

      ENDIF.

      SORT t_zorcamento       BY orcamento.
      SORT t_zorcamento_fase  BY orcamento fase.
      SORT t_zorcamento_linha BY orcamento fase.
      SORT t_asmd             BY asnum.
      SORT t_t023t            BY matkl.
      SORT t_caufv            BY aufnr.

      LOOP AT t_zorcamento_linha INTO ls_zorcamento_linha.
        CLEAR: ls_zorcamento_fase.
        READ TABLE t_zorcamento_fase INTO ls_zorcamento_fase WITH KEY orcamento = ls_zorcamento_linha-orcamento
                                                                      fase      = ls_zorcamento_linha-fase      BINARY SEARCH.

        CLEAR: ls_zorcamento.
        READ TABLE t_zorcamento      INTO ls_zorcamento      WITH KEY orcamento = ls_zorcamento_linha-orcamento BINARY SEARCH.

        CLEAR: ls_asmd.
        READ TABLE t_asmd            INTO ls_asmd            WITH KEY asnum     = ls_zorcamento_linha-srvpos    BINARY SEARCH.

        CLEAR: ls_t023t.
        READ TABLE t_t023t           INTO ls_t023t           WITH KEY matkl     = ls_asmd-matkl                 BINARY SEARCH.

        CLEAR: ls_caufv.
        READ TABLE t_caufv           INTO ls_caufv           WITH KEY aufnr     = ls_zorcamento-aufnr           BINARY SEARCH.

        CLEAR: t_data_r.

        t_data_r-post1     = ls_zorcamento-descricao.
        t_data_r-postu     = ls_zorcamento-descricao.
        t_data_r-aufnr     = ls_zorcamento-aufnr.
        t_data_r-orcamento = ls_zorcamento-orcamento.
        t_data_r-zdatabase = ls_zorcamento-zdatabase.

        t_data_r-ltxa1     = ls_zorcamento_fase-descricao.
        IF ls_zorcamento_fase-tipo = 'I'.
          t_data_r-steus     = 'PS01'.
        ENDIF.

        CALL FUNCTION 'CONVERSION_EXIT_KONPD_OUTPUT'
          EXPORTING
            input  = ls_caufv-pronr
          IMPORTING
            output = t_data_r-posid.

        t_data_r-pspnr     = ls_zorcamento_linha-orcamento+10(08).
        t_data_r-pronr     = ls_zorcamento_linha-orcamento+10(08).
        t_data_r-vornr     = ls_zorcamento_linha-fase+1(04).
        t_data_r-menge     = ls_zorcamento_linha-qtd.
        t_data_r-meins     = ls_zorcamento_linha-meins.
        t_data_r-tbtwr     = ls_zorcamento_linha-preco.
        t_data_r-asnum     = ls_zorcamento_linha-srvpos.
        t_data_r-srvpos    = ls_zorcamento_linha-srvpos.
        t_data_r-srvpos_02 = ls_zorcamento_linha-srvpos.
        t_data_r-netwr     = ls_zorcamento_linha-total.

        t_data_r-matkl     = ls_asmd-matkl.
        t_data_r-ktext1    = ls_asmd-asktx.

        t_data_r-wgbez60   = ls_t023t-wgbez60.
        t_data_r-wgbez     = ls_t023t-wgbez.
        t_data_r-matkl_02  = ls_t023t-matkl.

        APPEND t_data_r.

      ENDLOOP.

*      LOOP AT t_zorcamento INTO ls_zorcamento.
*        CLEAR: p_aufnr.
*        p_aufnr-sign    = 'I'.
*        p_aufnr-option  = 'EQ'.
*        p_aufnr-low     = ls_zorcamento-aufnr.
*        APPEND p_aufnr.
*      ENDLOOP.
    ENDIF.

    IF t_data_r[] IS INITIAL.
*    MESSAGE e398(00) WITH 'Dados não encontrados'.
      MESSAGE e398(00) WITH text-m01.
    ENDIF.
*
*    CHECK p_aufnr IS NOT INITIAL.

  ELSE.


* Fim da Alteração - Daniely Santos - Megawork - 02.04.2015

    SELECT  proj~pspnr
            proj~post1
            prps~postu
            prps~posid
            afko~aufnr
            afko~pronr
            afvc~vornr
            afvc~steus "Data: 08/10/2014 - 2014/1334
            afvc~ltxa1
            afvc~aufpl
            esll~matkl
            esll1~menge
            esll1~meins
            esll1~tbtwr
            asmd~asnum
            esll1~ktext1
            t023t~wgbez60
            t023t~wgbez
            t023t~matkl
            esll1~netwr
            esll~srvpos
            esll~packno
            esll1~packno
            esll1~srvpos
            INTO TABLE t_data_r  FROM  proj  INNER JOIN prps  AS prps  ON prps~posid   EQ proj~pspid
                                                        INNER JOIN afko  AS afko  ON afko~pronr   EQ prps~psphi
                                                        INNER JOIN afvc  AS afvc  ON afvc~aufpl   EQ afko~aufpl
                                                        INNER JOIN esll  AS esll  ON esll~packno  EQ afvc~packno
                                                        INNER JOIN esll  AS esll1 ON esll1~packno EQ esll~sub_packno
                                                        INNER JOIN asmd  AS asmd  ON asmd~asnum   EQ esll1~srvpos
                                                        INNER JOIN t023t AS t023t ON t023t~matkl  EQ asmd~matkl

                WHERE afko~aufnr IN p_aufnr. "proj~pspnr IN s_pspnr RAFAEL NESTOR 21.02.2013 2012-1366


    DELETE t_data_r WHERE steus = 'PS01'.


******************* BUSCA MATERIAIS - ABA 2 DO EXCEL ****************************

    " INI - IR105574 - 19.01.2016

*    SELECT  proj~pspnr  proj~post1  prps~postu    prps~posid  afko~aufnr  afko~pronr  afvc~vornr
*            afvc~steus  afvc~ltxa1  afvc~aufpl    resb~matkl  resb~bdmng  resb~meins  resb~gpreis
*            makt~maktx  mara~matnr  t023t~wgbez60 t023t~wgbez t023t~matkl
*     INTO TABLE t_data_r2
*     FROM  proj
*        INNER JOIN prps AS prps
*          ON  prps~posid EQ proj~pspid
*        INNER JOIN afko AS afko
*          ON  afko~pronr EQ prps~psphi
*        INNER JOIN afvc AS afvc
*          ON  afvc~aufpl EQ afko~aufpl
*        INNER JOIN resb AS resb
*          ON  resb~aufpl EQ afvc~aufpl
*          AND resb~vornr EQ afvc~vornr
*          AND resb~xloek EQ ''
*        INNER JOIN mara AS mara
*          ON mara~matnr EQ resb~matnr
*        INNER JOIN makt AS makt
*          ON  makt~matnr EQ mara~matnr
*          AND makt~spras EQ 'PT'
*        INNER JOIN t023t AS t023t
*          ON t023t~matkl  EQ mara~matkl
*     WHERE afko~aufnr IN p_aufnr.

    SELECT  proj~pspnr  proj~post1  prps~postu    prps~posid  afko~aufnr  afko~pronr  afvc~vornr
            afvc~steus  afvc~ltxa1  afvc~aufpl    resb~matkl  resb~bdmng  resb~meins  resb~gpreis
            resb~matnr
     INTO TABLE t_data_r2
     FROM  proj
        INNER JOIN prps AS prps
          ON  prps~posid EQ proj~pspid
        INNER JOIN afko AS afko
          ON  afko~pronr EQ prps~psphi
        INNER JOIN afvc AS afvc
          ON  afvc~aufpl EQ afko~aufpl
        LEFT JOIN resb AS resb
          ON  resb~aufpl EQ afvc~aufpl
          AND resb~vornr EQ afvc~vornr
          AND resb~xloek EQ ''
     WHERE afko~aufnr IN p_aufnr.

**********************************************************************
    IF sy-subrc NE 0.
*    MESSAGE e398(00) WITH 'Dados não encontrados'.
      MESSAGE e398(00) WITH text-m01.
    ENDIF.

    t_data_r2_aux[] = t_data_r2[].

    DELETE t_data_r2_aux WHERE asnum IS INITIAL.
    SORT t_data_r2_aux BY asnum.
    DELETE ADJACENT DUPLICATES FROM t_data_r2_aux COMPARING asnum.

    IF t_data_r2_aux[] IS NOT INITIAL.

      LOOP AT t_data_r2_aux INTO ls_data_r2_aux.
        CLEAR: ls_mara.
        ls_mara-matnr = ls_data_r2_aux-asnum.
        APPEND ls_mara TO t_data_mat_aux.
      ENDLOOP.

      SELECT  matnr matkl
       INTO TABLE t_mara
       FROM  mara
        FOR ALL ENTRIES IN t_data_mat_aux
       WHERE matnr = t_data_mat_aux-matnr.

      IF t_mara[] IS NOT INITIAL.
        SELECT  matnr maktx
          INTO TABLE t_makt
          FROM  makt
          FOR ALL ENTRIES IN t_mara
          WHERE  matnr EQ t_mara-matnr AND
                 spras EQ 'PT'.

        SELECT  matkl wgbez60 wgbez
          INTO TABLE t_t023t
          FROM  t023t
          FOR ALL ENTRIES IN t_mara
          WHERE  matkl  EQ t_mara-matkl.

      ENDIF.

      LOOP AT t_data_r2.

        CLEAR: vl_matnr.
        vl_matnr = t_data_r2-asnum.

        CLEAR: ls_makt.
        READ TABLE t_makt INTO ls_makt WITH KEY matnr = vl_matnr.

        CLEAR: ls_mara.
        READ TABLE t_mara INTO ls_mara WITH KEY matnr = vl_matnr.

        CLEAR: ls_t023t.
        IF ls_mara IS NOT INITIAL.
          READ TABLE t_t023t INTO ls_t023t WITH KEY matkl = ls_mara-matkl.
        ENDIF.

        t_data_r2-ktext1   = ls_makt-maktx.
        t_data_r2-wgbez60  = ls_t023t-wgbez60.
        t_data_r2-wgbez    = ls_t023t-wgbez.
        t_data_r2-matkl_02 = ls_t023t-matkl.

        MODIFY t_data_r2 TRANSPORTING ktext1 wgbez60 wgbez matkl_02.

      ENDLOOP.

    ENDIF.

    " FIM - IR105574 - 19.01.2016

  ENDIF.

**********************************************************************
  LOOP AT t_data_r2.

    CLEAR t_data_r.
    MOVE-CORRESPONDING t_data_r2 TO t_data_r.

    t_data_r-netwr =  t_data_r-menge * t_data_r-tbtwr.
    IF t_data_r-netwr > 0.
      APPEND t_data_r.
    ENDIF.

  ENDLOOP.
**********************************************************************


  LOOP AT t_data_r.

    CLEAR t_data_i.
    MOVE-CORRESPONDING t_data_r TO t_data_i.

    IF t_data_i-post1 IS INITIAL.
      t_data_i-post1 = t_data_i-postu.
    ENDIF.

    CONDENSE: t_data_i-post1,
              t_data_i-postu.

    APPEND t_data_i.

  ENDLOOP.

  SORT t_data_i.
  DELETE ADJACENT DUPLICATES FROM t_data_i.

  LOOP AT t_data_i.
    SELECT SINGLE banfn INTO t_data_i-banfn FROM afvc WHERE aufpl = t_data_i-aufpl AND banfn <> ''.
    MODIFY t_data_i.
  ENDLOOP.


ENDFORM.                    " F_GET_DADOS


*&---------------------------------------------------------------------*
*&      Form  F_PROCESSA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_processa_dados .

  DATA: l_tabix1 TYPE sy-tabix,
        l_tabix2 TYPE sy-tabix.

  CLEAR: t_data_aux,
         t_data_1,
         t_data_2,
         t_data.

  REFRESH: t_data_aux,
           t_data_1,
           t_data_2,
           t_data.


  t_data[] = t_data_r[].

  DELETE t_data WHERE aufnr NE t_data_i-aufnr AND posid NE t_data_i-posid.
  IF p_orcam[] IS NOT INITIAL.
    DELETE t_data WHERE orcamento NE t_data_i-orcamento.
  ENDIF.

  SORT t_data.
*  DELETE ADJACENT DUPLICATES FROM t_data.

  LOOP AT t_data.

    CLEAR: t_data_aux,
           t_data_1,
           t_data_2.


    MOVE-CORRESPONDING t_data TO t_data_aux.
    APPEND t_data_aux.

    MOVE-CORRESPONDING t_data TO t_data_1.
    APPEND t_data_1.

    MOVE-CORRESPONDING t_data TO t_data_2.
    APPEND t_data_2.

  ENDLOOP.


  SORT: t_data_aux,
        t_data_1 BY vornr ltxa1,
        t_data_2 BY vornr matkl_02 ltxa1 wgbez60.

  DELETE ADJACENT DUPLICATES FROM  t_data_1.
  DELETE ADJACENT DUPLICATES FROM  t_data_2.


  LOOP AT t_data_1.

    l_tabix1 = sy-tabix.

    LOOP AT t_data_2 WHERE vornr EQ t_data_1-vornr.

      l_tabix2 = sy-tabix.

*      WRITE :/ t_data_2-wgbez60.

      LOOP AT t_data_aux WHERE vornr EQ t_data_1-vornr AND wgbez60 EQ t_data_2-wgbez60.

        ADD t_data_aux-netwr TO t_data_1-total.
        ADD t_data_aux-netwr TO t_data_2-total.

      ENDLOOP.

      MODIFY t_data_2 INDEX l_tabix2.
      CLEAR t_data_2-total.

    ENDLOOP.

    MODIFY t_data_1 INDEX l_tabix1.

  ENDLOOP.

  SORT: t_data_aux,
        t_data_1 BY ltxa1,
        t_data_2 BY matkl_02 ltxa1 wgbez60.


ENDFORM.                    " F_PROCESSA_DADOS



*&---------------------------------------------------------------------*
*&      Form  F_BAIXAR_TEMPLATE_LOCAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_C_TEMPLATE  text
*----------------------------------------------------------------------*
FORM f_baixar_template_local  USING    p_c_template.

  DATA:  lt_query        TYPE STANDARD TABLE OF w3query WITH HEADER LINE,
         lt_html         TYPE STANDARD TABLE OF w3html,
         lt_mime         TYPE STANDARD TABLE OF w3mime,
         lt_param        TYPE w3param.

  DATA: ls_zorcamento TYPE zorcamento.

  DATA: vl_orcamento TYPE c LENGTH 18.

  CLEAR: lt_html[],
         lt_mime[],
         lt_query[],
         lt_query,
         lt_param,
         vl_fullpath.

  DATA: l_filename TYPE rlgrap-filename.

  lt_query-name  = '_OBJECT_ID'.
  lt_query-value = p_c_template.
  APPEND lt_query.

  CALL FUNCTION 'WWW_GET_MIME_OBJECT'
    TABLES
      query_string   = lt_query
      html           = lt_html
      mime           = lt_mime
    CHANGING
      return_code    = lt_param-ret_code
      content_type   = lt_param-cont_type
      content_length = lt_param-cont_len
    EXCEPTIONS
      OTHERS         = 1.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE i208(00) WITH text-003.
    STOP.
  ENDIF.

* Alteração - Daniely Santos - Megawork - Projeto Adequação PS - 23.04.2015
* Inicio

*  CONCATENATE p_file '\' 'Planilha' '_' 'Ord_' t_data_i-aufnr '_' 'Def_' t_data_i-posid '.XLS' INTO vl_fullpath.

  IF p_orcam[] IS NOT INITIAL.
    CLEAR: ls_zorcamento, vl_orcamento.
    READ TABLE t_zorcamento INTO ls_zorcamento WITH KEY orcamento = t_data_i-orcamento BINARY SEARCH.
    PACK ls_zorcamento-orcamento TO vl_orcamento.
    CONCATENATE p_file '\' 'Planilha' '_' 'Orc_' vl_orcamento '_' 'Ord_' t_data_i-aufnr '_' 'Def_' t_data_i-posid '.XLS' INTO vl_fullpath.
  ELSE.
    CONCATENATE p_file '\' 'Planilha' '_' 'Ord_' t_data_i-aufnr '_' 'Def_' t_data_i-posid '.XLS' INTO vl_fullpath.
  ENDIF.

* Fim da Alteração - Daniely Santos - Megawork - 23.04.2015

  CONDENSE vl_fullpath NO-GAPS.


  " Verifica se o Template já existe. Se existir, apaga.
  CLEAR: v_result.

  l_filename = vl_fullpath.
  CALL FUNCTION 'WS_QUERY'
    EXPORTING
      query    = 'FE'
      filename = l_filename
    IMPORTING
      return   = v_result.

  IF v_result NE '0'.

    CALL FUNCTION 'GUI_DELETE_FILE'
      EXPORTING
        file_name = l_filename
      EXCEPTIONS
        failed    = 1
        OTHERS    = 2.
  ENDIF.


  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      bin_filesize = lt_param-cont_len
      filename     = vl_fullpath
      filetype     = 'BIN'
    TABLES
      data_tab     = lt_mime
    EXCEPTIONS
      OTHERS       = 1.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE i208(00) WITH text-005.
    STOP.
  ENDIF.


ENDFORM.                    " F_BAIXAR_TEMPLATE_LOCAL


*&---------------------------------------------------------------------*
*&      Form  add_excel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->A          text
*      -->B          text
*      -->C          text
*      -->D          text
*      -->E          text
*      -->F          text
*      -->G          text
*      -->H          text
*      -->I          text
*      -->J          text
*      -->K          text
*      -->L          text
*      -->M          text
*      -->N          text
*      -->O          text
*      -->P          text
*      -->Q          text
*      -->R          text
*      -->S          text
*----------------------------------------------------------------------*
FORM add_excel USING a b c d e f g h i j k l m n o p q r s t u v.

  CLEAR t_excel.
  t_excel-a = a.
  t_excel-b = b.
  t_excel-c = c.
  t_excel-d = d.
  t_excel-e = e.
  t_excel-f = f.
  t_excel-g = g.
  t_excel-h = h.
  t_excel-i = i.
  t_excel-j = j.
  t_excel-k = k.
  t_excel-l = l.
  t_excel-m = m.
  t_excel-n = n.
  t_excel-o = o.
  t_excel-p = p.
  t_excel-q = q.
  t_excel-r = r.
  t_excel-s = s.
  t_excel-t = t.
  t_excel-u = u.
  t_excel-v = v.
  APPEND t_excel.

ENDFORM.                    "add_excel


*&---------------------------------------------------------------------*
*&      Form  F_EXPORTAR_EXCEL_FAST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_VL_FULLPATH  text
*----------------------------------------------------------------------*
FORM f_exportar_excel_fast  USING    p_vl_fullpath.

  DATA l_filename TYPE rlgrap-filename.
  CLEAR l_filename.

  l_filename = p_vl_fullpath.

  CALL FUNCTION 'SAP_CONVERT_TO_XLS_FORMAT'
    EXPORTING
      i_field_seperator = 'X'
      i_filename        = l_filename
    TABLES
      i_tab_sap_data    = t_excel
    EXCEPTIONS
      conversion_failed = 1
      OTHERS            = 2.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " F_EXPORTAR_EXCEL_FAST

*&---------------------------------------------------------------------*
*&      Form  F_PROCESSA_EXCEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_processa_excel .
  DATA v_j TYPE c LENGTH 3.
  DATA: l_quantidade TYPE c LENGTH 50,
        l_valor      TYPE c LENGTH 50,
        l_total      TYPE c LENGTH 50,
        l_text       TYPE c LENGTH 300,
        l_pep        TYPE prps-posid,
        l_valor_aba1 TYPE ekpo-netwr,
        l_valor_aba2 TYPE ekpo-netwr,
        l_valor_full TYPE ekpo-netwr.

  CLEAR:  t_saida, l_quantidade, l_valor, l_total, l_text,
          l_valor_full , l_valor_aba1, l_valor_aba2.


  REFRESH t_saida.

  LOOP AT t_data_i.

    PERFORM f_processa_dados.

    REFRESH t_excel.

    PERFORM f_baixar_template_local USING c_template.

    PERFORM add_excel USING '' t_data_i-post1 '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.

    CLEAR: l_text,
           l_pep.

    WRITE t_data_i-posid TO l_pep.

*    CONCATENATE 'PEP:' l_pep INTO l_text SEPARATED BY space.
    CONCATENATE text-t01 l_pep INTO l_text SEPARATED BY space.
*    CONCATENATE 'PEP:' t_data_i-posid INTO l_text SEPARATED BY space.
    PERFORM add_excel USING '' l_text '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.

    CLEAR: l_text.
*    CONCATENATE 'DIAGRAMA DE REDE:' t_data_i-aufnr INTO l_text SEPARATED BY space.
    IF t_data_i-aufnr IS NOT INITIAL.
      PACK t_data_i-aufnr TO l_text.
      CONDENSE l_text NO-GAPS.
    ENDIF.
    CONCATENATE text-t02 l_text INTO l_text SEPARATED BY space.
    PERFORM add_excel USING '' l_text '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.

*    CONCATENATE 'REQUISIÇÃO DE COMPRAS:' t_data_i-banfn INTO l_text SEPARATED BY space.
    CLEAR: l_text.
    CONCATENATE text-t03 t_data_i-banfn INTO l_text SEPARATED BY space.
    PERFORM add_excel USING '' l_text '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.

*    PERFORM add_excel USING '' 'REQUISIÇÃO DE COMPRAS:' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
*    PERFORM add_excel USING '' 'DATA BASE:' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    IF p_orcam[] IS NOT INITIAL.
      CLEAR: l_text.
      CONCATENATE t_data_i-zdatabase+06(02) '.'  t_data_i-zdatabase+04(02) '.' t_data_i-zdatabase(04) INTO l_text.
      CONCATENATE text-t04 l_text INTO l_text SEPARATED BY space.
      PERFORM add_excel USING '' l_text '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    ELSE.
      PERFORM add_excel USING '' text-t04 '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    ENDIF.


    PERFORM add_excel USING '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.


*    PERFORM add_excel USING 'SERVIÇO/MATERIAL' 'TXT.BREVE' 'QTD.' 'UMB' 'CUSTO UNITÁRIO' 'CUSTO TOTAL' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    PERFORM add_excel USING text-t05 text-t06 text-t07 text-t08 text-t09 text-t10 '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.


    PERFORM f_exportar_excel_fast USING vl_fullpath.

    REFRESH t_excel.

    PERFORM add_excel USING '' t_data_i-post1 '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.

    CLEAR: l_text.
*    CONCATENATE 'PEP:' l_pep INTO l_text SEPARATED BY space.
    CONCATENATE text-t01 l_pep INTO l_text SEPARATED BY space.
*    CONCATENATE 'PEP:' t_data_i-posid INTO l_text SEPARATED BY space.
    PERFORM add_excel USING '' l_text '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.

    CLEAR: l_text.
*    CONCATENATE 'DIAGRAMA DE REDE:' t_data_i-aufnr INTO l_text SEPARATED BY space.
    IF t_data_i-aufnr IS NOT INITIAL.
      PACK t_data_i-aufnr TO l_text.
      CONDENSE l_text NO-GAPS.
    ENDIF.
    CONCATENATE text-t02 l_text INTO l_text SEPARATED BY space.

    PERFORM add_excel USING '' l_text '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.

*    CONCATENATE 'REQUISIÇÃO DE COMPRAS:' t_data_i-banfn INTO l_text SEPARATED BY space.
    CONCATENATE text-t03 t_data_i-banfn INTO l_text SEPARATED BY space.
    PERFORM add_excel USING '' l_text '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.

*    PERFORM add_excel USING '' 'REQUISIÇÃO DE COMPRAS:' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.

*    PERFORM add_excel USING '' 'DATA BASE:' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    IF p_orcam[] IS NOT INITIAL.
      CLEAR: l_text.
      CONCATENATE t_data_i-zdatabase+06(02) '.'  t_data_i-zdatabase+04(02) '.' t_data_i-zdatabase(04) INTO l_text.
      CONCATENATE text-t04 l_text INTO l_text SEPARATED BY space.
      PERFORM add_excel USING '' l_text '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    ELSE.
      PERFORM add_excel USING '' text-t04 '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    ENDIF.

    PERFORM add_excel USING '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.

*    PERFORM add_excel USING 'SERVIÇO/MATERIAL' 'TXT.BREVE' 'QTD.' 'UMB' 'CUSTO UNITÁRIO' 'CUSTO TOTAL' '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.
    PERFORM add_excel USING text-t05 text-t06 text-t07 text-t08 text-t09 text-t10 '' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.


    LOOP AT t_data_1.

      CLEAR l_valor.
      WRITE t_data_1-total TO l_valor.
      CONDENSE l_valor.

      "Data 08/10/2014
      IF t_data_1-steus EQ 'PS01'.
        v_j = 'EXT'.
      ELSE.
        CLEAR v_j.
      ENDIF.



      PERFORM add_excel USING t_data_1-ltxa1 '' '' '' '' l_valor 'M1' '' '' v_j '' '' '' '' '' '' '' '' '' '' '' ''.

      LOOP AT t_data_2 WHERE vornr EQ t_data_1-vornr.

        CLEAR l_valor.
        WRITE t_data_2-total TO l_valor.
        CONDENSE l_valor.

        PERFORM add_excel USING t_data_2-wgbez60 '' '' '' '' l_valor '' 'M2' '' v_j '' '' '' '' '' '' '' '' '' '' '' ''.

        LOOP AT t_data_aux WHERE vornr EQ t_data_1-vornr AND wgbez60 EQ t_data_2-wgbez60.

          CLEAR: l_quantidade,
                 l_valor,
                 l_total.

          WRITE t_data_aux-menge TO l_quantidade.
          WRITE t_data_aux-netwr TO l_valor.
          WRITE t_data_aux-tbtwr TO l_total.

          CONDENSE: l_quantidade,
                    l_valor,
                    l_total.

          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
            EXPORTING
              input          = t_data_aux-meins
              language       = sy-langu
            IMPORTING
              output         = t_data_aux-meins
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.
          IF sy-subrc <> 0.
* Implement suitable error handling here
          ENDIF.


          PERFORM add_excel USING t_data_aux-asnum t_data_aux-ktext1 l_quantidade t_data_aux-meins l_total l_valor '' '' 'M3' v_j '' '' '' '' '' '' '' '' '' '' '' ''.

        ENDLOOP.

      ENDLOOP.

    ENDLOOP.

    "INICIO - Valor Total - Rodapé

    CLEAR: l_valor, l_valor_full, l_valor_aba1, l_valor_aba2.

    LOOP AT t_data_1.

      ADD t_data_1-total TO l_valor_full.

      IF t_data_1-steus EQ 'PS01'.
        ADD t_data_1-total TO l_valor_aba2.
      ELSE.
        ADD t_data_1-total TO l_valor_aba1.
      ENDIF.
    ENDLOOP.

    "SUB TOTAL ABA 1
    WRITE l_valor_aba1 TO l_valor.
    CONCATENATE t_data_i-post1 '-' t_data_i-posid INTO l_text SEPARATED BY space.
    PERFORM add_excel USING l_text '' '' '' '' l_valor 'M1' '' '' '' '' '' '' '' '' '' '' '' '' '' '' ''.

    "SUBTOTAL ABA 2
    WRITE l_valor_aba2 TO l_valor.
    CONCATENATE t_data_i-post1 '-' t_data_i-posid INTO l_text SEPARATED BY space.
    PERFORM add_excel USING l_text '' '' '' '' l_valor 'M1' '' '' 'EXT' '' '' '' '' '' '' '' '' '' '' '' ''.

    "TOTAL GERAL
    WRITE l_valor_full TO l_valor.
    CONCATENATE t_data_i-post1 '-' t_data_i-posid INTO l_text SEPARATED BY space.
    PERFORM add_excel USING l_text '' '' '' '' l_valor 'M1' '' '' 'EXT' '' '' '' '' '' '' '' '' '' '' '' ''.
    " FIM


    DESCRIBE TABLE t_excel LINES sy-tfill.
    "Data 08/10/2014
    DATA v_contador TYPE i.
    v_contador = sy-tfill.


    READ TABLE t_excel INDEX 1.
    IF sy-subrc EQ 0.
      t_excel-o = sy-tfill.
      t_excel-p = v_contador. "Data 08/10/2014
      MODIFY t_excel INDEX sy-tabix.
    ENDIF.

    PERFORM f_exportar_excel_fast USING vl_fullpath.

    IF sy-subrc EQ 0.

      CLEAR t_saida.
      t_saida-line = vl_fullpath.
      APPEND t_saida.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " F_PROCESSA_EXCEL


*&---------------------------------------------------------------------*
*&      Form  F_GET_DIRECTORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_P_FILE  text
*----------------------------------------------------------------------*
FORM f_get_directory  CHANGING p_p_file.

  cl_gui_frontend_services=>directory_browse(
    EXPORTING
      window_title         = 'Selecionar Diretório'
    CHANGING
      selected_folder      = p_p_file
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4
         ).

ENDFORM.                    " F_GET_DIRECTORY


*&---------------------------------------------------------------------*
*&      Form  F_GERA_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_gera_log .

  DESCRIBE TABLE t_saida LINES sy-tfill.

  IF sy-tfill GT 0.

    FORMAT COLOR COL_KEY INTENSIFIED OFF.
    ULINE AT /1(100).
    WRITE: / '|', 5  text-m02, 100 '|'.
    WRITE: / '|', 5  text-m03, 100 '|'.
    ULINE AT /1(100).

    LOOP AT t_saida.

      WRITE: / '|', 5  sy-tabix , t_saida-line, 100 '|'.

    ENDLOOP.

    ULINE AT /1(100).

  ENDIF.

ENDFORM.                    " F_GERA_LOG