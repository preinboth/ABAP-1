*----------------------------------------------------------------------*
*                          “Megawork”                                  *
*----------------------------------------------------------------------*
* Programa   : ZRPP0003                                                *
* Descrição  : Apontamento de Produção                                 *
* Módulo     : PP                                   Transação: ZPP***  *
*                                                                      *
* Objetivo   :                                                         *
*------------------------Logs De Alterações----------------------------*
* Autor      : Filipe Cardoso                        Data: 14/01/2014  *
* Observações: Criação programa ZRPP0003                               *
*----------------------------------------------------------------------*
*------------------------Logs De Alterações----------------------------*
* Autor      : Gabriel Souza                         Data: 28/12/2015  *
* Observações: Alteração programa - f_preenche_batch_input             *
*----------------------------------------------------------------------*

REPORT zrpp0007 LINE-SIZE 120.

*--------------------------------------------------------------------*
* Tables
*--------------------------------------------------------------------*
TABLES: ztbpp0003, edidc, zpdvloginbound, mseg, ztbpp_matnr_mov.

*--------------------------------------------------------------------*
* TYpes
*--------------------------------------------------------------------*

TYPES: BEGIN OF y_mat,
        werks TYPE werks_d,
        matnr TYPE matnr,
        menge TYPE menge_d,
  END OF y_mat.

TYPES: BEGIN OF y_cupom,
        cupom_nr TYPE c LENGTH 70,
        mblnr    TYPE mkpf-mblnr,
        mjahr    TYPE mkpf-mjahr,
        idoc     TYPE c LENGTH 10,
        END OF y_cupom.

TYPES: BEGIN OF y_out,
        idoc       TYPE c LENGTH 15, "Idoc
        loja       TYPE werks_d,     "Loja
        matnr      TYPE mseg-matnr,  "Material
        menge_mat  TYPE menge_d,     "Quantidade do Material
        stats      TYPE c LENGTH 7,  "Status
        componente TYPE mseg-matnr,  "Componente
        menge_comp TYPE menge_d,     "Quantidade do Componente
        menge_dep  TYPE c LENGTH 10,
        message    TYPE c LENGTH 90, "Mensagem
        sucesso    TYPE flag,
       END OF y_out.

" Batch input nova estrutura do campo de tabela
TYPES: BEGIN OF ty_bdcdata,
        program   TYPE bdcdata-program,  " Pool de módulos BDC
        dynpro    TYPE bdcdata-dynpro,   " NÚmero de tela BDC
        dynbegin  TYPE bdcdata-dynbegin, " Início BDC de uma tela
        fnam      TYPE bdcdata-fnam,     " Nome do campo
        fval      TYPE bdcdata-fval,     " Valor do campo BDC
       END OF ty_bdcdata.

TYPES: BEGIN OF y_ztbpp0003,
        mblnr  TYPE mseg-mblnr,
        idoc    TYPE c LENGTH 15,
        loja    TYPE werks_d,
        nrcupom TYPE c LENGTH 15,
        werks   TYPE werks_d,
        matnr   TYPE matnr,
        menge   TYPE mseg-menge,
  END OF y_ztbpp0003.

TYPES:
      BEGIN OF y_stpo,
        flag TYPE c LENGTH 1,
        labst TYPE mard-labst,
        difst TYPE mard-labst,
        lgort TYPE lgort_d.
        INCLUDE STRUCTURE stpo_api02.
TYPES END OF y_stpo.

*--------------------------------------------------------------------*
* Internal Tables
*--------------------------------------------------------------------*
DATA:
      t_ztbpp0003 TYPE TABLE OF y_ztbpp0003,
      t_mat       TYPE TABLE OF y_mat,
      t_mkal      TYPE TABLE OF mkal,
      t_mast      TYPE TABLE OF mast,
      t_edidc     TYPE TABLE OF edidc,
      t_cupom     TYPE TABLE OF y_cupom,
      t_mseg      TYPE TABLE OF mseg,
      t_out       TYPE TABLE OF y_out,
      t_retorno   TYPE TABLE OF y_out,
      it_bdcdata  TYPE TABLE OF ty_bdcdata, "Batch Input
      it_msg      TYPE TABLE OF bdcmsgcoll WITH HEADER LINE, "Batch Input
      t_stpo_aux  TYPE TABLE OF y_stpo,
      t_pdvbound  TYPE TABLE OF zpdvloginbound.

* Tabela de controle de documentos gerados
DATA: BEGIN OF t_mfbf OCCURS 0,
        tpdoc TYPE c, "1 - Lançamento Produção / 2 - Lançamento da qtd "1" / 3 - Estorno da qtd "1"
        matnr TYPE matnr,
        werks TYPE werks_d,
        mblnr TYPE mblnr,
      END OF t_mfbf.

* Cabeçalho da Lista Técnica
DATA t_stko TYPE STANDARD TABLE OF stko_api02.
DATA w_stko TYPE stko_api02.

* Estruturas e Tabelas para BAPI
DATA w_goodsmvt_header LIKE bapi2017_gm_head_01.
DATA w_goodsmvt_code   LIKE bapi2017_gm_code.
DATA w_bflushflags     LIKE bapi_rm_flg.
DATA w_bflushdatagen   LIKE bapi_rm_datgen.
DATA w_bflushdatamts   LIKE bapi_rm_datstock.
DATA w_return          LIKE bapiret2.
DATA t_goodsmvt_item   LIKE bapi2017_gm_item_create OCCURS 0 WITH HEADER LINE.
DATA t_goodsmovements  LIKE bapi2017_gm_item_create OCCURS 0 WITH HEADER LINE.
DATA t_return          LIKE bapiret2 OCCURS 0 WITH HEADER LINE.

*--------------------------------------------------------------------*
* WorkAreas
*--------------------------------------------------------------------*
DATA:
      w_ztbpp0003 TYPE y_ztbpp0003,
      w_ztbpp0003_aux TYPE y_ztbpp0003,
      w_mat       TYPE y_mat,
      w_mkal      TYPE mkal,
      w_mast      TYPE mast,
      w_ztbpp0001 TYPE ztbpp0001,
      w_edidc     TYPE edidc,
      w_cupom     TYPE y_cupom,
      w_mseg      TYPE mseg,
      w_out       TYPE y_out,
      st_bdcdata  TYPE ty_bdcdata, "Batch Inputs
      w_stpo_aux  TYPE y_stpo,
      w_pdvbound  TYPE zpdvloginbound,
      r_datum     TYPE RANGE OF datum WITH HEADER LINE,
      g_mfbf_date TYPE datum.

*--------------------------------------------------------------------*
* Variáveis
*--------------------------------------------------------------------*
DATA: v_alternative TYPE csap_mbom-stlal,
      v_lgort_baixa TYPE lgort_d,
      v_erro_param  TYPE c.

*INI - Megawork - 28/12/2015 - 8000002897 - GS
TYPES: BEGIN OF ty_confirmation,
       l_confirmation TYPE prtnr,
       END OF ty_confirmation.

DATA: it_confirmation TYPE TABLE OF ty_confirmation,
      wa_confirmation TYPE ty_confirmation.
*FIM - Megawork - 28/12/2015 - 8000002897 - GS

*--------------------------------------------------------------------*
* ALV
*--------------------------------------------------------------------*

DATA: lt_fcat TYPE slis_t_fieldcat_alv,
      ls_fcat TYPE slis_fieldcat_alv,
      ls_layout TYPE slis_layout_alv,
      ls_vari TYPE disvariant.

DATA: lt_head_alv TYPE TABLE OF slis_listheader,
      lw_header TYPE slis_listheader.
DATA: gt_exc TYPE TABLE OF alv_s_qinf.

*--------------------------------------------------------------------*
* Constants
*--------------------------------------------------------------------*
CONSTANTS: c_alv_t_out TYPE c LENGTH 5 VALUE 'T_OUT'.

*--------------------------------------------------------------------*
* RANGES
*--------------------------------------------------------------------*
RANGES: r_plant FOR mseg-werks.

*--------------------------------------------------------------------*
* Screen
*--------------------------------------------------------------------*

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECTION-SCREEN SKIP.
PARAMETER p_werks TYPE  zpdvloginbound-codloja OBLIGATORY.
SELECT-OPTIONS:
*               s_cupom  FOR  w_ztbpp0003-nrcupom  NO INTERVALS,
*               s_idoc   FOR  edidc-docnum,
                s_matnr  FOR  mseg-matnr NO INTERVALS.
PARAMETER:      p_monat  TYPE rscalmonth, "OBLIGATORY,
                p_dtprd  TYPE ru_ersda NO-DISPLAY,
                p_qtprd  TYPE ru_gmnga NO-DISPLAY,
                p_submit TYPE c NO-DISPLAY.
*SELECTION-SCREEN SKIP.
PARAMETER p_bapi TYPE c DEFAULT 'X' NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK b1.

"VTD

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_monat.
  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      actual_month               = sy-datum(6)
      factory_calendar           = ' '
      holiday_calendar           = ' '
      language                   = sy-langu
      start_column               = 8
      start_row                  = 5
    IMPORTING
      selected_month             = p_monat
    EXCEPTIONS
      factory_calendar_not_found = 1
      holiday_calendar_not_found = 2
      month_not_found            = 3
      OTHERS                     = 4.


START-OF-SELECTION.

* PERFORM f_busca_deposito.
  PERFORM f_monta_range_mes CHANGING v_erro_param.
  IF v_erro_param = 'X'.
    RETURN.
  ENDIF.

* WIB - INÍCIO ------------------------------ 24/07/2014
* Limpa os registros inconsistentes do pós-processamento
  PERFORM f_limpa_regs_incon_posproc.
* WIB - INÍCIO ------------------------------ 24/07/2014
  PERFORM f_seleciona_dados.
  PERFORM f_processa_dados.
*  PERFORM f_absover_custos. "Absorver Cursto dos processados com SUCESSO - Transação KO88

  "VTD - Ini
   PERFORM f_estorna_ordem_ajst.  "Substituido pelo perform abaixo. ==> PERFORM f_estorna_ordem_ajst2
*  PERFORM f_absover_custos. "Absorver Cursto dos processados com SUCESSO - Transação KO88
  "VTD - End

*INI - Megawork - 28/12/2015 - 8000002897 - GS
*******************  PERFORM f_estorna_ordem_ajst2."Nova transação para efetuar o processo via Batch input
*FIM - Megawork - 28/12/2015 - 8000002897 - GS

  PERFORM f_print_spool.

*&---------------------------------------------------------------------*
*&      Form  F_SELECIONA_DADOS
*&---------------------------------------------------------------------*
FORM f_seleciona_dados .

  DATA: docnum       TYPE edidc-docnum,
        mestyp       TYPE edidc-mestyp,
        t_foldoc     TYPE wpusa_t_foldoc WITH HEADER LINE,
        lw_pp003     TYPE ztbpp0003,
        l_ultimo_doc TYPE mblnr,
        l_count      TYPE i.

* WIB - INÍCIO ------------------------------ 24/07/2014
* Recupera os documentos de material de acordo com os parâmetros de seleção.
* A seleção deve desconsiderar documentos estornados (Tp.Mov. 252)
*  CLEAR: t_mseg, t_mseg[].
*  SELECT * APPENDING CORRESPONDING FIELDS OF TABLE t_mseg
*    FROM mseg AS a
*    JOIN mkpf AS b
*      ON a~mblnr EQ b~mblnr
*    WHERE a~werks      EQ p_werks
*      AND a~mjahr      EQ sy-datum(4)
*      AND a~budat_mkpf IN r_datum
*      AND a~matnr      IN s_matnr
*      AND a~bwart      EQ '251'
**     AND b~zzflgpr    EQ ' '
*      AND NOT EXISTS ( SELECT mblnr
*                        FROM mseg AS a1
*                       WHERE a1~werks = a~werks
*                         AND a1~matnr = a~matnr
*                         AND a1~bwart = '252'
*                         AND a1~smbln = a~mblnr ).
* WIB - FIM --------------------------------- 24/07/2014

* Verifica se o lançamento da produção será realizado via SUBMIT (chamada externa). Se não
* for chamada externa, então executa a seleção com base no período e realiza a consolidação
* das informações para posterior lançamento
  IF p_submit IS INITIAL.

*   A definição agora é para recuperar o saldo atual do material (independente do tipo
*   de movimento), e apontar a quantidade total caso o saldo em estoque for negativo
    CLEAR: t_mseg, t_mseg[], t_ztbpp0003[], t_mat[].
    SELECT * APPENDING CORRESPONDING FIELDS OF TABLE t_mseg
      FROM mseg AS a
      JOIN mkpf AS b
        ON a~mblnr EQ b~mblnr
      JOIN mara AS c
        ON a~matnr = c~matnr
      WHERE a~matnr IN s_matnr
        AND a~werks EQ p_werks
*       AND a~mjahr EQ sy-datum(4)
        AND a~mjahr EQ p_monat(4)
        AND b~budat IN r_datum
        AND c~mtart EQ 'FERT'.

    SORT t_mseg BY mblnr.
    LOOP AT t_mseg INTO w_mseg.
*     CLEAR w_cupom.
*     READ TABLE t_cupom INTO w_cupom WITH KEY mblnr = w_mseg-mblnr BINARY SEARCH.
*     CHECK sy-subrc IS INITIAL.
*     w_ztbpp0003-nrcupom = w_cupom-cupom_nr.
*     w_ztbpp0003-idoc    = w_cupom-idoc.
      w_ztbpp0003-loja    = w_mseg-werks.
      w_ztbpp0003-werks   = w_mseg-werks.
      w_ztbpp0003-mblnr   = w_mseg-mblnr.
      w_ztbpp0003-matnr   = w_mseg-matnr.
      w_ztbpp0003-menge   = w_mseg-menge.
      APPEND w_ztbpp0003 TO t_ztbpp0003.
    ENDLOOP.

*   Ordena tabela pelo número do doc.material
    SORT t_ztbpp0003 BY mblnr.

    LOOP AT t_ztbpp0003 INTO w_ztbpp0003.

*   WIB - INÍCIO ------------------------------ 24/07/2014
*     Move para estrutura auxiliar pois o comando "AT" insere '*****' nos campos
      CLEAR: w_ztbpp0003_aux, w_mat.
      MOVE-CORRESPONDING w_ztbpp0003 TO w_ztbpp0003_aux.

*  --> Marca o Doc.Material como processado
      AT NEW mblnr.
        UPDATE mkpf SET zzflgpr = 'X'
                  WHERE mblnr = w_ztbpp0003_aux-mblnr.
      ENDAT.
*   WIB - FIM --------------------------------- 24/07/2014

      MOVE-CORRESPONDING w_ztbpp0003_aux TO w_mat.

      COLLECT w_mat INTO t_mat.

    ENDLOOP.

** WIB - INÍCIO ------------------------------ 24/07/2014
* * Rotina para recuperar o saldo do período a lançar
*   LOOP AT t_mat INTO w_mat.
*
* *   Recupera o saldo a lançar para o material/centro no período
*     PERFORM zf_recupera_saldo_periodo USING w_mat-matnr
*                                             w_mat-werks
*                                    CHANGING w_mat-menge.
*
* *   Se a quantidade é zero, então não deve processar este material
*     IF w_mat-menge = 0.
*       DELETE t_mat.
*     ELSE.
* *     Atualiza a quantidade com o saldo do período a ser lançado
*       MODIFY t_mat FROM w_mat TRANSPORTING menge.
*     ENDIF.
*
*   ENDLOOP.
** WIB - FIM --------------------------------- 24/07/2014

** WIB - INÍCIO ------------------------------ 25/07/2014
*    Se a quantidade a lançar for zero, não deve processar este material/centro
    LOOP AT t_mat INTO w_mat.

*     Recupera o saldo atual do FERT, independente do tipo de movimento
      PERFORM zf_recupera_saldo_atual_fert USING w_mat-matnr
                                                 w_mat-werks
                                        CHANGING w_mat-menge.

      IF w_mat-menge = 0.
        DELETE t_mat.
      ELSE.

*       Atualiza tabela interna
        MODIFY t_mat FROM w_mat TRANSPORTING menge.

      ENDIF.

* *   Trata lançamentos indevidos no mês de JUN/2014 para loja H056
*     IF p_monat = '06' AND w_mat-werks = 'H056'.
*
* *     Recupera lançamentos 131 e 132 no período e calcula demanda a produzir
*       PERFORM zf_obtem_saldo_lanc_incorretos CHANGING w_mat.
*
* *     Atualiza tabela interna
*       MODIFY t_mat FROM w_mat TRANSPORTING menge.
*
*     ENDIF.

    ENDLOOP.
** WIB - FIM --------------------------------- 25/07/2014

* A execução será realizada via chamada externa (SUBMIT)
* Quantidade a ser produzida e data de produção foram informadas
  ELSE.

*   LOOP nos materiais a serem produzidos
    LOOP AT s_matnr.

*     Preenche estrutura com dados da produção
      CLEAR w_mat.
      w_mat-werks = p_werks.
      w_mat-matnr = s_matnr-low.
      w_mat-menge = p_qtprd.

*     Grava registro na tabela de produção
      APPEND w_mat TO t_mat.

    ENDLOOP.

  ENDIF.

  IF NOT t_mat[] IS INITIAL.

    CLEAR: t_mkal, t_mkal[].
    SELECT * FROM mkal INTO TABLE t_mkal
      FOR ALL ENTRIES IN t_mat
      WHERE werks EQ t_mat-werks
        AND matnr EQ t_mat-matnr
        AND matnr <> '000000000000106096'
*       Já filtrar pela data de início da validade da versão
        AND adatu <= g_mfbf_date
        AND mdv02 NE '999'.

    CLEAR: t_mast, t_mast[].
    SELECT * FROM mast INTO TABLE t_mast
      FOR ALL ENTRIES IN t_mkal
       WHERE werks EQ t_mkal-werks
         AND matnr EQ t_mkal-matnr
         AND stlan EQ t_mkal-stlan
         AND stlal EQ t_mkal-stlal.

  ENDIF.

ENDFORM.                    " F_SELECIONA_DADOS

*&---------------------------------------------------------------------*
*&      Form  F_PROCESSA_DADOS
*&---------------------------------------------------------------------*
FORM f_processa_dados .

  SORT t_ztbpp0003 BY idoc ASCENDING.
  SORT t_mat BY matnr ASCENDING.

* Inicializa tabela de controle de documentos gerados
  CLEAR: t_mfbf, t_mfbf[].

  SORT t_mkal BY matnr.
  LOOP AT t_mat INTO w_mat.
    READ TABLE t_mkal TRANSPORTING NO FIELDS WITH KEY matnr = w_mat-matnr BINARY SEARCH.
    IF sy-subrc <> 0.
      CLEAR w_stpo_aux.
      PERFORM f_preenche_log USING w_mat text-006 w_stpo_aux '' w_mat-menge '' ' '.
      CONTINUE.
    ELSE.
      PERFORM f_valida_saldo USING w_mat.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " F_PROCESSA_DADOS
*&---------------------------------------------------------------------*
*&      Form  F_VALIDA_SALDO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_ZTBPP0003  text
*----------------------------------------------------------------------*
FORM f_valida_saldo USING p_mat TYPE y_mat.

  DATA: l_cont TYPE n LENGTH 2,
        l_saldo_stats TYPE c LENGTH 15,
        bflushflags           TYPE bapi_rm_flg,
        bflushdatagen         TYPE bapi_rm_datgen,
        confirmation          TYPE bapi_rm_datkey-confirmation,
        return                TYPE bapiret2,
        serialnr              TYPE STANDARD TABLE OF bapi_rm_datserial,
        goodsmovements        TYPE STANDARD TABLE OF bapi2017_gm_item_create WITH HEADER LINE,
        characteristics_batch TYPE STANDARD TABLE OF bapi_char_batch,
        w_mkal                TYPE mkal,
        lt_stpo               TYPE TABLE OF stpo_api02,
        lw_stpo               TYPE stpo_api02,
        l_mode(1)             TYPE c,       " informa o Modo do Call Transaction
        l_s                   TYPE c,       " Informa o Update do call Transaction..
        w_pp0003              TYPE ztbpp0003,
        l_message             TYPE c LENGTH 75,
        l_ultimo              TYPE c,
        l_ok                  TYPE flag,
        l_mblnr_aux           TYPE mseg-mblnr.
*        lw_ztbpp0007          TYPE ztbpp0007.

  CLEAR: l_cont,
         l_ok,
         v_alternative,
         v_lgort_baixa.

  DO 15 TIMES.

    CLEAR l_ultimo.
    ADD 1 TO l_cont.

    PERFORM f_busca_saldo_valido TABLES lt_stpo
                                  USING p_mat
                                        l_cont
                                        l_ultimo
                               CHANGING l_saldo_stats
                                        w_mkal.

*   IF l_saldo_stats = 'ULTIMO'.
*     CLEAR l_cont.
*     ADD 1 TO l_cont.
*     PERFORM f_busca_saldo_valido TABLES lt_stpo USING p_mat l_cont l_ultimo CHANGING l_saldo_stats w_mkal .
*     PERFORM f_trata_log USING p_mat.
*     EXIT.
*   ENDIF.

*   Chama rotina para lançar o estoque faltante para cada componente do material
    PERFORM zf_lanca_diferenca_estoque USING p_mat
                                    CHANGING l_ok.

*    READ TABLE t_stpo_aux TRANSPORTING NO FIELDS WITH KEY flag = '-'.
*    IF sy-subrc IS NOT INITIAL.
*      l_ok = 'X'. "Processar este registro
*      EXIT.
*    ENDIF.

*   NÃO SERÁ NECESSÁRIO PASSAR PELAS 15 POSSÍVEIS VERSÕES
*   Iremos considerar sempre a primeira versão do material (que possua componentes),
*   e iremos lançar os estoques dos componentes desta primeira versão
    IF NOT t_stpo_aux[] IS INITIAL.
      EXIT.
    ENDIF.

  ENDDO.

  "Quando houver falha na determinação de versão do produto.
  IF l_cont = 15.
    l_message = text-006.
    CLEAR w_stpo_aux.
    PERFORM f_preenche_log USING p_mat l_message w_stpo_aux '' p_mat-menge '' ' '.
    EXIT.
  ENDIF.

  IF l_ok IS INITIAL.

    EXIT.

  ELSE.

* WIB - INÍCIO ------------------------- 26/07/2014
*   Verifica se o lançamento deve ser via BAPI ou BatchInput
    IF p_bapi = 'X'.

*     Executa o lançamento da produção usando a BAPI_REPMANCONF1_CREATE_MTS
      PERFORM zf_lancamento_producao TABLES lt_stpo
                                      USING p_mat
                                            w_mkal-elpro
                                            l_cont.

    ELSE.
* WIB - FIM ------------------------- 26/07/2014

      CLEAR l_mblnr_aux .
      "VTD - Ordem ADD 1 - Ini

      PERFORM f_preenche_batch_input TABLES lt_stpo
                                     USING w_mkal
                                           p_mat
                                           l_cont.

      l_mode = 'N'.
      l_s    = 'S'.
      CLEAR: it_msg[], it_msg.
      CALL TRANSACTION 'MFBF' USING  it_bdcdata
                              MODE   l_mode
                              UPDATE l_s
                              MESSAGES INTO it_msg.

      READ TABLE it_msg WITH KEY msgtyp = 'E'.
      IF sy-subrc IS INITIAL.

        CLEAR l_message.
        CALL FUNCTION 'MESSAGE_TEXT_BUILD'
          EXPORTING
            msgid               = it_msg-msgid
            msgnr               = it_msg-msgnr
            msgv1               = it_msg-msgv1
            msgv2               = it_msg-msgv2
            msgv3               = it_msg-msgv3
            msgv4               = it_msg-msgv4
          IMPORTING
            message_text_output = l_message.
        CONCATENATE 'MFBF_ADD1:' l_message INTO l_message SEPARATED BY space.
        CLEAR w_stpo_aux.
        PERFORM f_preenche_log USING p_mat l_message w_stpo_aux '' p_mat-menge '' ''.

      ELSE.

*       Verifica se o lançamento foi realizado e recupera o número do documento
        READ TABLE it_msg WITH KEY msgid = 'RM'
                                   msgnr = '191'.
        IF sy-subrc IS INITIAL.

*         Verifica se existe número de documento
          IF NOT it_msg-msgv1 IS INITIAL.

            l_mblnr_aux = it_msg-msgv1.
            l_message = text-003.
            REPLACE ALL OCCURRENCES OF '&1' IN l_message WITH l_mblnr_aux .
            CLEAR w_stpo_aux.
            PERFORM f_preenche_log USING p_mat l_message w_stpo_aux '' p_mat-menge '' 'X'.

          ELSE.
            l_message = text-007.
            CONCATENATE 'MFBF_ADD1:' l_message INTO l_message SEPARATED BY space.
            CLEAR w_stpo_aux.
            PERFORM f_preenche_log USING p_mat l_message w_stpo_aux '' p_mat-menge '' ''.
          ENDIF.
*  * WIB - FIM ---------------------------- 25/07/2014

*  * WIB - INÍCIO ------------------------- 25/07/2014
        ELSE.

*         Imprime consistência de tela do batchinput caso documento não tenha sido criado
          READ TABLE it_msg INDEX 1.
          IF sy-subrc = 0.

            CLEAR l_message.
            CALL FUNCTION 'MESSAGE_TEXT_BUILD'
              EXPORTING
                msgid               = it_msg-msgid
                msgnr               = it_msg-msgnr
                msgv1               = it_msg-msgv1
                msgv2               = it_msg-msgv2
                msgv3               = it_msg-msgv3
                msgv4               = it_msg-msgv4
              IMPORTING
                message_text_output = l_message.
            CONCATENATE 'MFBF_ADD1:' l_message INTO l_message SEPARATED BY space.
            CLEAR w_stpo_aux.
            PERFORM f_preenche_log USING p_mat l_message w_stpo_aux '' p_mat-menge '' ''.

          ENDIF.

        ENDIF.
*  * WIB - FIM ---------------------------- 25/07/2014

      ENDIF.

    ENDIF.

** WIB - INÍCIO ------------------------- 25/07/2014
*   Verifica se o lançamento da produção foi realizado
    READ TABLE t_mfbf WITH KEY tpdoc = '1' "Lançamento da Produção
                               matnr = p_mat-matnr
                               werks = p_mat-werks.

*   Não continua caso a Produção não tenha sido lançada
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.
** WIB - FIM ---------------------------- 25/07/2014

    "VTD - Ordem ADD 1 - End

    PERFORM f_preenche_batch_input_add USING  p_mat
                                              l_cont.

    l_mode = 'N'.
    l_s    = 'S'.
    CLEAR: it_msg[], it_msg.
    CALL TRANSACTION 'MFBF' USING  it_bdcdata
                            MODE   l_mode
                            UPDATE l_s
                            MESSAGES INTO it_msg.

    READ TABLE it_msg WITH KEY msgtyp = 'E'.
    IF sy-subrc IS INITIAL.
      CLEAR l_message.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = it_msg-msgid
          msgnr               = it_msg-msgnr
          msgv1               = it_msg-msgv1
          msgv2               = it_msg-msgv2
          msgv3               = it_msg-msgv3
          msgv4               = it_msg-msgv4
        IMPORTING
          message_text_output = l_message.
      CONCATENATE 'MFBF:' l_message INTO l_message SEPARATED BY space.
      CLEAR w_stpo_aux.
      PERFORM f_preenche_log USING p_mat l_message w_stpo_aux '' p_mat-menge '' ''.

    ELSE.

      COMMIT WORK AND WAIT.

** WIB - INÍCIO (Segundo Ceolin, não precisa imprimir o lançamento de quantidade '1') 25/07/2014
*      l_message = text-003.
*      REPLACE ALL OCCURRENCES OF '&1' IN l_message WITH l_mblnr_aux .
*      CLEAR w_stpo_aux.
*      PERFORM f_preenche_log USING p_mat l_message w_stpo_aux '' p_mat-menge '' 'X'.
** WIB - FIM ------------------------ 25/07/2014

** WIB - INÍCIO --------------------- 25/07/2014
*     Verifica se o lançamento foi realizado e recupera o número do documento
      READ TABLE it_msg WITH KEY msgid = 'RM'
                                 msgnr = '190'.
      IF sy-subrc IS INITIAL.

*       Verifica se existe número de documento
        IF NOT it_msg-msgv1 IS INITIAL.

*    INI - Megawork - 11/11/2016 - 8000002897 - GS
     APPEND it_msg-msgv1 TO it_confirmation.
*    FIM - Megawork - 11/11/2016 - 8000002897 - GS

*         Move dados do documento lançado
          CLEAR t_mfbf.
          t_mfbf-tpdoc = '2'. "Lançamento da qtd "1"
          t_mfbf-matnr = p_mat-matnr.
          t_mfbf-werks = p_mat-werks.
          t_mfbf-mblnr = it_msg-msgv1.

*         Grava registro na tabela de controle de documentos
          APPEND t_mfbf.
          CLEAR  t_mfbf.

        ENDIF.

      ENDIF.
** WIB - FIM --------------------- 25/07/2014

*     Absorver Custos dos processados com SUCESSO - Transação KO88
      PERFORM f_absover_custos_direto USING p_mat
                                            l_cont.
    ENDIF.

  ENDIF.
*  w_pp0003-repid = sy-repid.
*  w_pp0003-idoc  = p_ztbpp0003-idoc.
*  MODIFY ztbpp0003 FROM w_pp0003.
ENDFORM.                    " F_VALIDA_SALDO
*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_SALDO_VALIDO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_ZTBPP0003  text
*      -->P_L_CONT  text
*----------------------------------------------------------------------*
FORM f_busca_saldo_valido  TABLES   p_stpo
                           USING    p_mat TYPE y_mat
                                    p_cont
                                    p_ultimo
                           CHANGING p_saldo_stats
                                    p_mkal.

  DATA: material              TYPE csap_mbom-matnr,
        plant                 TYPE csap_mbom-werks,
        bom_usage             TYPE csap_mbom-stlan,
        alternative           TYPE csap_mbom-stlal,
        t_stpo                TYPE STANDARD TABLE OF stpo_api02,
        w_stpo                TYPE stpo_api02,
        l_quant               TYPE labst,
        l_quant_mat           TYPE c LENGTH 15,
        l_quant_comp          TYPE c LENGTH 15,
*        w_mard                TYPE mard,
        l_message             TYPE c LENGTH 60,
        l_saldo_estoque       TYPE labst,
        l_qtd_comp            TYPE kmpmg,
        l_comp_qty            TYPE kmpmg,
        l_base_quan           TYPE basmn.


  CLEAR: p_saldo_stats, t_stpo_aux.

  READ TABLE t_mast INTO w_mast WITH KEY  matnr = p_mat-matnr
                                          werks = p_mat-werks
                                          stlal = p_cont.

  IF sy-subrc IS INITIAL.

    material    = p_mat-matnr.
    plant       = w_mast-werks.
    bom_usage   = '1'.
    alternative = w_mast-stlal.

    CLEAR: t_stpo, t_stko, w_stko.
    CALL FUNCTION 'CSAP_MAT_BOM_READ'
      EXPORTING
        material    = material
        plant       = plant
        bom_usage   = bom_usage
        alternative = alternative
      TABLES
        t_stpo      = t_stpo
        t_stko      = t_stko
      EXCEPTIONS
        error       = 1
        OTHERS      = 2.

    CLEAR p_stpo[].
    p_stpo[] = t_stpo.

*   Recupera informações de cabeçalho
    READ TABLE t_stko INTO w_stko INDEX 1.

    "Componentes do materia
    LOOP AT t_stpo INTO w_stpo.

      CLEAR w_stpo_aux.
      MOVE-CORRESPONDING w_stpo TO w_stpo_aux.
      TRANSLATE w_stpo-comp_qty USING ',.'.
      CONDENSE w_stpo-comp_qty NO-GAPS.
      CONDENSE w_stko-base_quan NO-GAPS.

      CLEAR l_qtd_comp.
      l_qtd_comp = w_stpo-comp_qty.

*     Se for maior que ZERO validar estoque, se menor que ZERO será inclusão de estoque não precisa validar"
      IF l_qtd_comp > 0.

        CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
          EXPORTING
            input  = w_stpo-component
          IMPORTING
            output = w_stpo-component.

        SELECT SINGLE * FROM mkal
          INTO w_mkal
            WHERE werks = p_mat-werks
              AND matnr = p_mat-matnr
*              AND mdv02 NE '999'
              AND stlal = alternative.

        IF sy-subrc IS INITIAL.

*         Move o código da LT alternativa para variável auxiliar
          v_alternative = alternative.

          p_mkal = w_mkal.

*---> ESTOQUE NÃO SERÁ LIDO DA "MARD" (Precisamos recuperar o saldo do Período) <---
*          "Estoque para o componente
*          SELECT SINGLE * FROM mard INTO w_mard
*            WHERE matnr EQ w_stpo-component
*              AND werks EQ w_mast-werks
*              AND lgort EQ w_mkal-elpro.
*---> ESTOQUE NÃO SERÁ LIDO DA "MARD" (Precisamos recuperar o saldo do Período) <---

*         Recupera o saldo do componente no período de execução
          PERFORM zf_recupera_saldo_periodo_comp USING w_stpo-component
                                                       w_mast-werks
                                                       w_mkal-elpro
                                              CHANGING l_saldo_estoque.

          IF l_saldo_estoque <> 0.

*           TRANSLATE w_stpo-comp_qty USING ',.'.
*           TRANSLATE w_stko-base_quan USING ',.'.

            PERFORM zf_convert_char_to_num USING w_stpo-comp_qty CHANGING l_comp_qty.
            PERFORM zf_convert_char_to_num USING w_stko-base_quan CHANGING l_base_quan.

            CLEAR l_quant.
            l_quant = ( l_comp_qty * p_mat-menge ) / l_base_quan.

            "Se a quantidade utilizada para o componente for menor que o estoque, prosseguir com apontamento.
            IF l_quant LE l_saldo_estoque.
              w_stpo_aux-flag  = '+'.
              w_stpo_aux-lgort = w_mkal-elpro.
              APPEND w_stpo_aux TO t_stpo_aux.
            ELSE.
              w_stpo_aux-flag = '-'.
              w_stpo_aux-labst = l_saldo_estoque.
              w_stpo_aux-difst = l_quant - l_saldo_estoque. "Calcula diferença de estoque a lançar (501)
              w_stpo_aux-lgort = w_mkal-elpro.
              APPEND w_stpo_aux TO t_stpo_aux.
            ENDIF.

          ELSE.

*           TRANSLATE w_stpo-comp_qty USING ',.'.
*           TRANSLATE w_stko-base_quan USING ',.'.

            PERFORM zf_convert_char_to_num USING w_stpo-comp_qty CHANGING l_comp_qty.
            PERFORM zf_convert_char_to_num USING w_stko-base_quan CHANGING l_base_quan.

            CLEAR l_quant.
            l_quant = ( l_comp_qty * p_mat-menge ) / l_base_quan.

            w_stpo_aux-flag = '-'.
            w_stpo_aux-labst = '0'.
            w_stpo_aux-difst = l_quant. "Calcula diferença de estoque a lançar (501)
            w_stpo_aux-lgort = w_mkal-elpro.
            APPEND w_stpo_aux TO t_stpo_aux.

          ENDIF.
        ENDIF.
      ELSE.
        w_stpo_aux-flag  = '+'.
        w_stpo_aux-lgort = w_mkal-elpro.
        APPEND w_stpo_aux TO t_stpo_aux.
      ENDIF.
    ENDLOOP.

  ELSE.
    p_saldo_stats = 'ULTIMO'.
  ENDIF.

ENDFORM.                    " F_BUSCA_SALDO_VALIDO
*&---------------------------------------------------------------------*
*&      Form  F_BUSCA_DEPOSITO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_busca_deposito .

*  SELECT SINGLE * FROM ztbpp0001 INTO w_ztbpp0001
*    WHERE repid EQ sy-repid
*      AND field EQ 'LGORT'.

ENDFORM.                    " F_BUSCA_DEPOSITO
*&---------------------------------------------------------------------*
*&      Form  F_PRINT_SPOOL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_spool .
  DATA:
        t_lojas TYPE TABLE OF y_out,
        w_lojas TYPE y_out,
        t_aux   TYPE TABLE OF y_out,
        l_color TYPE n,
        t_out_aux TYPE TABLE OF y_out.

  CLEAR t_out_aux.

  LOOP AT t_out INTO w_out.

    CLEAR w_out-idoc.
    COLLECT w_out INTO t_out_aux.

  ENDLOOP.

  CLEAR t_out[].
  t_out[] = t_out_aux[].
  t_lojas[] = t_out[].

  SORT t_lojas BY loja.
  DELETE ADJACENT DUPLICATES FROM t_lojas COMPARING loja. "Temos todas as Lojas processadas.

* Verifica se a execução foi realizada via SUBMIT e exporta tabela de log
  IF p_submit = 'X'.

    CLEAR t_retorno[].
    LOOP AT t_out INTO w_out WHERE sucesso = space.
      APPEND w_out TO t_retorno.
    ENDLOOP.

    FREE MEMORY ID 'ZSISINVPRD'.
    IF NOT t_retorno[] IS INITIAL.
      EXPORT t_retorno TO MEMORY ID 'ZSISINVPRD'.
    ENDIF.

  ENDIF.

  "Para todas as lojas será impressa uma pagina
  SORT t_lojas.
  LOOP AT t_lojas INTO w_lojas.
    PERFORM f_write_cabecalho USING w_lojas.

    "Auxilar para tratar lojas especificas
    "Eliminando outras lojas da auxiliar
    t_aux[] = t_out[].
    DELETE t_aux WHERE loja NE w_lojas-loja.

    "Só teremos registros referentes a loja do Loop
    LOOP AT t_aux INTO w_out.

      "Definindo uma cor para cada linha.
      IF l_color = 0.
        l_color = 1.
        FORMAT COLOR COL_NORMAL INTENSIFIED ON.
      ELSE.
        FORMAT COLOR COL_NORMAL INTENSIFIED OFF.
        l_color = 0.
      ENDIF.
      "Inserindo linha ao spool.
      PERFORM f_write_line USING w_out.

      DELETE t_out WHERE matnr = w_out-matnr
                     AND loja  = w_out-loja
                     AND componente = w_out-componente.
    ENDLOOP.

    "Ser houver mais registros para processar significar que são outra loja. Logo teremos NOVA PAGINA
    IF t_out IS NOT INITIAL.
      NEW-PAGE. "Pagina Nova
    ENDIF.

  ENDLOOP.

ENDFORM.                    " F_PRINT_SPOOL
*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_FCAT  text
*----------------------------------------------------------------------*
FORM set_fieldcat  CHANGING lt_fcat.
  DATA: l_pos TYPE n LENGTH 2,
        l_name TYPE c LENGTH 25.

  DATA: l_titulo_giro  TYPE c LENGTH 30,
        l_titulo_saldo TYPE c LENGTH 30.
*
*  ADD 1 TO l_pos.
*  PERFORM f_montagrid USING  l_pos  'IDOC'     'Idoc'             'L'   18  '' 'X' ''.

  ADD 1 TO l_pos.
  PERFORM f_montagrid USING  l_pos  'LOJA'     'Loja'             'L'   18  '' 'X' ''.

  ADD 1 TO l_pos.
  PERFORM f_montagrid USING  l_pos  'MATNR'     'Material'             'L'   18  '' 'X' ''.


  ADD 1 TO l_pos.
  PERFORM f_montagrid USING  l_pos  'STATS'     'Status'             'L'   7  '' 'X' ''.

  ADD 1 TO l_pos.
  PERFORM f_montagrid USING  l_pos  'COMPONENTE'     'Componente'             'L'   11  '' 'X' ''.

  ADD 1 TO l_pos.
  PERFORM f_montagrid USING  l_pos  'MESSAGE'     'Mensagem'             'L'   70  '' 'X' ''.


ENDFORM.                    " SET_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  F_MONTAGRID
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_VG_POS  text
*      -->P_0698   text
*      -->P_0699   text
*      -->P_10     text
*      -->P_0701   text
*      -->P_0702   text
*      -->P_0703   text
*      -->P_0704   text
*----------------------------------------------------------------------*
FORM f_montagrid  USING    v_pos
                           v_field
                           v_tit
                           v_just
                           v_tam
                           v_fix
                           v_sum
                           v_out.

  CLEAR ls_fcat.
  ls_fcat-col_pos       = v_pos.
  ls_fcat-fieldname     = v_field.
  ls_fcat-tabname       = c_alv_t_out.
  ls_fcat-reptext_ddic  = v_tit.
  ls_fcat-just          = v_just.
  IF v_tam = 0.
    ls_fcat-outputlen     = strlen( v_tit ).
  ELSE.
    ls_fcat-outputlen     = v_tam.
  ENDIF.
  ls_fcat-fix_column    = v_fix.
  ls_fcat-do_sum        = v_sum.
  ls_fcat-no_out        = v_out.
  APPEND ls_fcat TO lt_fcat.
ENDFORM.                    " F_MONTAGRID
*&---------------------------------------------------------------------*
*&      Form  SET_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_layout CHANGING ls_layout TYPE slis_layout_alv.

  ls_layout-expand_all =  'X'.

ENDFORM.                    " SET_LAYOUT
*&---------------------------------------------------------------------*
*&      Form  F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*       Cabeçalho do relatório
*----------------------------------------------------------------------*
FORM f_top_of_page.                                         "#EC CALLED

  PERFORM print_header.

ENDFORM.                    " F_TOP_OF_PAGE
*&---------------------------------------------------------------------*
*&      Form  PRINT_HEADER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM print_header .

  FREE lt_head_alv.

  CLEAR lw_header.
  lw_header-typ  = 'H'.
  lw_header-info = 'Apontamento de Produção - Log'.
  APPEND lw_header TO lt_head_alv.

  CLEAR lw_header.
  lw_header-typ  = 'S'.
  lw_header-key  = 'Data: '.
  WRITE sy-datum TO lw_header-info.
  APPEND lw_header TO lt_head_alv.

  CLEAR lw_header.
  lw_header-typ  = 'S'.
  lw_header-key  = 'Hora: '.
  WRITE sy-uzeit TO lw_header-info.
  APPEND lw_header TO lt_head_alv.

  CLEAR lw_header.
  lw_header-typ  = 'S'.
  lw_header-key  = 'Usuário: '.
  WRITE sy-uname TO lw_header-info.
  APPEND lw_header TO lt_head_alv.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
*     i_logo             = 'LOGO_CESAN'
      it_list_commentary = lt_head_alv.

ENDFORM.                    " PRINT_HEADER
*&---------------------------------------------------------------------*
*&      Form  F_ABSOVER_CUSTOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_absover_custos.

  DATA:
        t_aux        TYPE TABLE OF y_out,
        t_afko       TYPE TABLE OF afko,
        w_afko       TYPE afko,
        l_mode(1)    TYPE c,       " informa o Modo do Call Transaction
        l_s          TYPE c,       " Informa o Update do call Transaction.
        l_hghf       TYPE c LENGTH 5 VALUE 'HGHF',
        i_id         TYPE bapireturn1-id,
        i_number     TYPE bapireturn1-number,
        i_type       TYPE bapireturn1-type,
        t_return     TYPE STANDARD TABLE OF bapireturn1 WITH HEADER LINE,
        i_message_v1 TYPE c LENGTH 20,
        i_message_v2 TYPE c LENGTH 20,
        i_message_v3 TYPE c LENGTH 20,
        i_message_v4 TYPE c LENGTH 20,
        l_tabix      TYPE sy-tabix,
        l_message    TYPE c LENGTH 75.

  CLEAR: t_aux, it_bdcdata.
  t_aux = t_out.

  LOOP AT t_ztbpp0003 INTO w_ztbpp0003.
    l_tabix = sy-tabix.
    CLEAR w_out.
    READ TABLE t_out INTO w_out WITH KEY  idoc  = w_ztbpp0003-idoc
                                          matnr = w_ztbpp0003-matnr.
    IF sy-subrc IS INITIAL AND w_out-sucesso IS INITIAL.
      DELETE t_ztbpp0003 INDEX l_tabix.
    ENDIF.
  ENDLOOP.

  CHECK  t_ztbpp0003 IS NOT INITIAL.

  SELECT * FROM afko
    INTO TABLE t_afko
    FOR ALL ENTRIES IN t_ztbpp0003
    WHERE plnbez = t_ztbpp0003-matnr.

  SET PARAMETER ID 'CAC' FIELD l_hghf.

  LOOP AT t_mat INTO w_mat.

    READ TABLE t_afko INTO w_afko WITH KEY plnbez = w_mat-matnr.
    IF sy-subrc IS INITIAL.

      PERFORM f_preenche_bdc USING:
      'X'    'SAPLKO71'        '1000',
      ' '    'BDC_OKCODE'      '=AUSF',
      ' '    'LKO74-PERIO'     p_monat+4(2),
      ' '    'LKO74-GJAHR'     p_monat(4),
      ' '    'LKO74-TESTLAUF'  ' ',
      ' '    'CODIA-AUFNR'     w_afko-aufnr.

      l_mode = 'N'.
      l_s    = 'S'.

      CALL TRANSACTION 'KO88' USING it_bdcdata
                            MODE  l_mode
                            UPDATE l_s
                            MESSAGES INTO it_msg.

      IF sy-subrc IS NOT INITIAL.
        READ TABLE it_msg WITH KEY msgtyp = 'E'.
        IF sy-subrc IS INITIAL.

          CLEAR l_message.
          CALL FUNCTION 'MESSAGE_TEXT_BUILD'
            EXPORTING
              msgid               = it_msg-msgid
              msgnr               = it_msg-msgnr
              msgv1               = it_msg-msgv1
              msgv2               = it_msg-msgv2
              msgv3               = it_msg-msgv3
              msgv4               = it_msg-msgv4
            IMPORTING
              message_text_output = l_message.

          PERFORM f_preenche_log USING w_mat l_message w_stpo_aux '' '' '' ''.

        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " F_ABSOVER_CUSTOS
*&---------------------------------------------------------------------*
*&      Form  F_ABSOVER_CUSTOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_absover_custos_direto USING p_mat TYPE y_mat
                                   p_cont TYPE n.

  DATA:
        l_mode(1)    TYPE c,       " informa o Modo do Call Transaction
        l_s          TYPE c,       " Informa o Update do call Transaction.
        l_hghf       TYPE c LENGTH 5 VALUE 'HGHF',
        i_id         TYPE bapireturn1-id,
        i_number     TYPE bapireturn1-number,
        i_type       TYPE bapireturn1-type,
        t_return     TYPE STANDARD TABLE OF bapireturn1 WITH HEADER LINE,
        i_message_v1 TYPE c LENGTH 20,
        i_message_v2 TYPE c LENGTH 20,
        i_message_v3 TYPE c LENGTH 20,
        i_message_v4 TYPE c LENGTH 20,
        l_tabix      TYPE sy-tabix,
        l_message    TYPE c LENGTH 75,
        w_ckmlmv013  TYPE ckmlmv013,
        l_verid      TYPE ckmlmv013-verid.

  CLEAR: w_ckmlmv013, l_verid, it_bdcdata, it_bdcdata[].
  UNPACK p_cont TO l_verid.

  SELECT SINGLE *
    INTO w_ckmlmv013
    FROM ckmlmv013
    WHERE prwrk EQ p_mat-werks
      AND pmatn EQ p_mat-matnr
      AND verid EQ l_verid.

  IF sy-subrc IS INITIAL.

    SET PARAMETER ID 'CAC' FIELD l_hghf.

    PERFORM f_preenche_bdc USING:
    'X'    'SAPLKO71'        '1000',
    ' '    'BDC_OKCODE'      '=AUSF',
    ' '    'LKO74-PERIO'     p_monat+4(2),
    ' '    'LKO74-GJAHR'     p_monat(4),
    ' '    'LKO74-TESTLAUF'  ' ',
    ' '    'CODIA-AUFNR'     w_ckmlmv013-aufnr.

    l_mode = 'N'.
    l_s    = 'S'.

    CALL TRANSACTION 'KO88' USING it_bdcdata
                          MODE  l_mode
                          UPDATE l_s
                          MESSAGES INTO it_msg.

    IF sy-subrc IS NOT INITIAL.
      READ TABLE it_msg WITH KEY msgtyp = 'E'.
      IF sy-subrc IS INITIAL.

        CLEAR l_message.
        CALL FUNCTION 'MESSAGE_TEXT_BUILD'
          EXPORTING
            msgid               = it_msg-msgid
            msgnr               = it_msg-msgnr
            msgv1               = it_msg-msgv1
            msgv2               = it_msg-msgv2
            msgv3               = it_msg-msgv3
            msgv4               = it_msg-msgv4
          IMPORTING
            message_text_output = l_message.

        PERFORM f_preenche_log USING p_mat l_message w_stpo_aux '' '' '' ''.

      ENDIF.
    ENDIF.
  ENDIF.
*    ENDIF.
*  ENDLOOP.

ENDFORM.                    " F_ABSOVER_CUSTOS
*&---------------------------------------------------------------------*
*&      Form  Z_PREENCHE_BDC
*&---------------------------------------------------------------------*
*&  Se Dynbegin = 'X' ele preenche as informações da tela, senão ele preenche
*&  o campo e o dado dela. prontio.
*&---------------------------------------------------------------------*
FORM f_preenche_bdc  USING dynbegin
                           name
                           value.
  IF dynbegin = 'X'.
    MOVE: name      TO st_bdcdata-program,
          value     TO st_bdcdata-dynpro,
          dynbegin  TO st_bdcdata-dynbegin.
    APPEND st_bdcdata TO it_bdcdata.
  ELSE.

    MOVE: name  TO st_bdcdata-fnam,
          value TO st_bdcdata-fval.
    APPEND st_bdcdata TO it_bdcdata.

  ENDIF.
  "  prepara a estrutura para o Loop.
  CLEAR st_bdcdata.
ENDFORM.                    " Z_PREENCHE_BDC
*&---------------------------------------------------------------------*
*&      Form  F_PREENCHE_BATCH_INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_STPO  text
*      -->P_W_MKAL  text
*      -->P_P_ZTBPP0003  text
*----------------------------------------------------------------------*
*INI - Megawork - 28/12/2015 - 8000002897 - GS
FORM f_preenche_batch_input  TABLES   p_stpo
                             USING    p_mkal TYPE mkal
                                      p_mat TYPE y_mat
                                      p_cont.

  DATA:
        l_verid TYPE verid,
        l_cont  TYPE n LENGTH 2,
        l_field TYPE c LENGTH 20,
        l_data  TYPE c LENGTH 10,
        l_menge TYPE c LENGTH 15,
        l_lines TYPE i.

  CLEAR it_bdcdata[].
  CLEAR it_bdcdata.
  CLEAR l_data.

  WRITE: g_mfbf_date TO l_data,
         p_mat-menge TO l_menge.

  CONDENSE l_menge NO-GAPS.
  UNPACK p_cont TO l_verid.


  PERFORM f_preenche_bdc USING:
                                'X'    'SAPLBARM'        '0800',
                                ' '    'BDC_OKCODE'      '=ISTDA',
                                ' '    'RM61B-BUDAT'     l_data,
                                ' '    'RM61B-BLDAT'     l_data,
                                ' '    'RM61B-MATNR'     p_mat-matnr,
                                ' '    'RM61B-WERKS'     p_mat-werks,
                                ' '    'RM61B-VERID'     l_verid,
                                ' '    'RM61B-ERFMG'     l_menge,
                                ' '    'RM61B-ALORT'     'DP01'.

  CLEAR l_cont.

  CLEAR l_lines.
  DESCRIBE TABLE p_stpo LINES l_lines.

  IF l_lines <= 11.

    PERFORM f_preenche_bdc USING:
                                'X'    'SAPLCOWB'        '0130',
                                ' '    'BDC_OKCODE'      '=WEIT'.

    LOOP AT p_stpo.

      ADD 1 TO l_cont.
      CONCATENATE 'COWB_COMP-LGORT(' l_cont ')' INTO l_field.

      PERFORM f_preenche_bdc USING ' '    l_field     p_mkal-elpro.

    ENDLOOP.

  ELSE.

    LOOP AT p_stpo.

      IF sy-tabix = l_lines.

        PERFORM f_preenche_bdc USING:
                                     'X'    'SAPLCOWB'        '0130',
                                     ' '    'BDC_CURSOR'      'COWB_COMP-LGORT(01)',
                                     ' '    'BDC_OKCODE'      '=WEIT'.

        PERFORM f_preenche_bdc USING ' '    'COWB_COMP-LGORT(01)'  p_mkal-elpro.
        EXIT.

      ENDIF.

      PERFORM f_preenche_bdc USING:
                                   'X'    'SAPLCOWB'        '0130',
                                   ' '    'BDC_CURSOR'      'COWB_COMP-LGORT(01)',
                                   ' '    'BDC_OKCODE'      '/00'.

      PERFORM f_preenche_bdc USING ' '    'COWB_COMP-LGORT(01)'  p_mkal-elpro.

    ENDLOOP.

  ENDIF.

ENDFORM.                    " F_PREENCHE_BATCH_INPUT




*FIM - Megawork - 28/12/2015 - 8000002897 - GS
*&---------------------------------------------------------------------*
*&      Form  F_PREENCHE_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_ZTBPP0003  text
*      -->P_1132   text
*      -->P_L_MESSAGE  text
*----------------------------------------------------------------------*
FORM f_preenche_log  USING    p_mat TYPE y_mat
                              p_message
                              p_stpo TYPE y_stpo
                              p_qnt_com
                              p_qnt_mat
                              p_qnt_dep
                              p_sucesso.
  CLEAR w_out.
  READ TABLE t_out INTO w_out WITH KEY loja = p_mat-werks
                                       matnr = p_mat-matnr.

  w_out-loja        = p_mat-werks.
  w_out-matnr       = p_mat-matnr.

  IF p_stpo IS NOT INITIAL.
    w_out-componente  = p_stpo-component.
  ENDIF.

*  w_out-idoc        = p_ztbpp0003-idoc.
  ADD p_qnt_mat TO w_out-menge_mat.
  w_out-menge_comp  = p_qnt_com.
  w_out-menge_mat   = p_qnt_mat.
  w_out-menge_dep   = p_qnt_dep.
  w_out-message     = p_message.
  w_out-sucesso     = p_sucesso.

*  APPEND w_out TO t_out.
  COLLECT w_out INTO t_out.

ENDFORM.                    " F_PREENCHE_LOG
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_CABECALHO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_cabecalho USING p_loja TYPE y_out.

  FORMAT COLOR COL_HEADING INTENSIFIED OFF.
  WRITE: '|', 3(121)'Log de Apontamento de Produção' CENTERED, 120'|',
        /'|', 3(5)'Data:', 9(10) sy-datum, 120'|',
        /'|', 3(5)'Loja', 9(5) p_loja-loja, 120'|'.
  ULINE.
  FORMAT COLOR COL_HEADING INTENSIFIED ON.
  WRITE:        /'|', 2(10)'Material', 14'|', 15(10)'Quantidade', 26'|', 27(10)'Componente', 39'|', 40(10)'Quantidade', 50'|', 51(11)'QntdEstoque',
           64'|', 65(70)'Mensagem' , 120'|'.
  ULINE.

ENDFORM.                    " F_WRITE_CABECALHO
*&---------------------------------------------------------------------*
*&      Form  F_WRITE_LINE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_W_OUT  text
*----------------------------------------------------------------------*
FORM f_write_line  USING    p_out TYPE y_out.

  WRITE: /'|', 2(10) p_out-matnr, 14'|', 15(10) p_out-menge_mat, 26'|', 27(10) p_out-componente, 39'|', 40(10) p_out-menge_comp, 50'|', 51(11) p_out-menge_dep,
           64'|', 65(70) p_out-message , 120'|'.
  ULINE.

ENDFORM.                    " F_WRITE_LINE
*&---------------------------------------------------------------------*
*&      Form  F_TRATA_LOG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_STPO_AUX  text
*      -->P_P_ZTBPP0003  text
*----------------------------------------------------------------------*
FORM f_trata_log  USING p_mat TYPE y_mat.

  DATA:
          l_quant               TYPE c LENGTH 15,
          l_quant_mat           TYPE c LENGTH 15,
          l_quant_comp          TYPE c LENGTH 15,
          w_mard                TYPE mard,
          l_message             TYPE c LENGTH 60.

  LOOP AT t_stpo_aux INTO w_stpo_aux WHERE flag = '-'.

    CLEAR: l_quant_comp, l_quant, l_message, l_quant_mat.
    TRANSLATE w_stpo_aux-comp_qty USING ',.'.
    CONDENSE w_stpo_aux-comp_qty NO-GAPS.
    l_quant_comp = ( w_stpo_aux-comp_qty * p_mat-menge ). "Quantidade utilizada para o component

    l_quant_mat = p_mat-menge. "Quantidade solicitada para o Produto

    CONDENSE l_quant_mat NO-GAPS.
    CONDENSE l_quant_comp NO-GAPS.

    l_quant = w_stpo_aux-labst. "Quantidade no Estoque
    CONDENSE l_quant NO-GAPS.
    IF w_stpo_aux-labst = 0.
      l_message = 'Componente não encontra no depósito'.
    ELSE.
      l_message = text-002.
    ENDIF.

    PERFORM f_preenche_log USING p_mat l_message w_stpo_aux l_quant_comp l_quant_mat l_quant ''.

  ENDLOOP.

ENDFORM.                    " F_TRATA_LOG

*&---------------------------------------------------------------------*
*&      Form  ZF_LANCA_DIFERENCA_ESTOQUE
*&---------------------------------------------------------------------*
FORM zf_lanca_diferenca_estoque USING p_mat TYPE y_mat
                             CHANGING e_ok.

  DATA: l_quant               TYPE c LENGTH 15,
        l_quant_mat           TYPE c LENGTH 15,
        l_quant_comp          TYPE c LENGTH 15,
        w_mard                TYPE mard,
        l_message             TYPE c LENGTH 60,
        l_materialdocument    TYPE mblnr,
        l_matdocumentyear     TYPE mjahr,
        l_base_quan           TYPE basmn.              " Megawork - 27.01.2015 - Alexandre Britto - 8000001607

  CLEAR e_ok.

  PERFORM zf_convert_char_to_num USING w_stko-base_quan CHANGING l_base_quan.      " Megawork - 27.01.2015 - Alexandre Britto - 8000001607

* Varre tabela contendo os componentes com estoque faltante
  LOOP AT t_stpo_aux INTO w_stpo_aux WHERE flag = '-'.

*   Inicializa variáveis
    CLEAR: l_quant_comp, l_quant, l_message, l_quant_mat,
           l_materialdocument, l_matdocumentyear.

*   Preenche as estruturas e tabelas da BAPI
    PERFORM zf_preenche_dados_bapi USING p_mat.

*   Chama BAPI para gerar a difenrença de estoque para o componente em questão
    CLEAR: t_return, t_return[].
    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header  = w_goodsmvt_header
        goodsmvt_code    = w_goodsmvt_code
      IMPORTING
        materialdocument = l_materialdocument
        matdocumentyear  = l_matdocumentyear
      TABLES
        goodsmvt_item    = t_goodsmvt_item
        return           = t_return.

*   Verifica ocorrência de erro no lançamento de estoque para o componente
    READ TABLE t_return WITH KEY type = 'E'.
    IF sy-subrc = 0.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      TRANSLATE w_stpo_aux-comp_qty USING ',.'.
      CONDENSE w_stpo_aux-comp_qty NO-GAPS.

      "INI - " Megawork - 27.01.2015 - Alexandre Britto - 8000001607
*     l_quant_comp = ( w_stpo_aux-comp_qty * p_mat-menge ) .               "Quantidade utilizada para o component
      l_quant_comp = ( w_stpo_aux-comp_qty * p_mat-menge ) / l_base_quan . "Quantidade utilizada para o component
      " FIM - Megawork - 27.01.2015 - Alexandre Britto - 8000001607

      l_quant_mat = p_mat-menge.                                           "Quantidade solicitada para o Produto
      CONDENSE l_quant_mat NO-GAPS.                                        "Retirar espaços em branco
      CONDENSE l_quant_comp NO-GAPS.                                       "Retirar espaços em branco

*     l_quant = w_stpo_aux-labst.                                          "Quantidade no Estoque
      l_quant = w_stpo_aux-difst.                                          "Quantidade no Estoque (diferença)
      CONDENSE l_quant NO-GAPS.                                            "Retirar espaços em branco

*     Move mensagem de erro
      l_message = t_return-message.

*     Grava mensagem na tabela de LOG
      PERFORM zf_grava_erro_estoque USING p_mat
                                          l_message
                                          w_stpo_aux
                                          l_quant_comp
                                          l_quant_mat
                                          l_quant
                                          ''.
*     Abandona a rotina
      CLEAR e_ok.
      EXIT.

    ELSE.

      CLEAR ztbpp_matnr_mov.
      ztbpp_matnr_mov-mblnr = l_materialdocument.
      ztbpp_matnr_mov-mjahr = l_matdocumentyear.
      INSERT ztbpp_matnr_mov.

*     Execução operações de banco
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

*     Marca registro como OK
      e_ok = 'X'.
      COMMIT WORK.

    ENDIF.

  ENDLOOP.

  IF NOT t_stpo_aux[] IS INITIAL.
    READ TABLE t_stpo_aux TRANSPORTING NO FIELDS WITH KEY flag = '-'.
    IF sy-subrc <> 0.
*     Marca registro como OK
      e_ok = 'X'.
    ENDIF.
  ENDIF.

ENDFORM.                    " ZF_LANCA_DIFERENCA_ESTOQUE

*&---------------------------------------------------------------------*
*&      Form  F_PREENCHE_BATCH_INPUT_ADD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_STPO  text
*      -->P_MKAL  text
*      -->P_ZTBPP0003  text
*      -->P_CONT  text
*----------------------------------------------------------------------*
FORM f_preenche_batch_input_add  USING    p_mat TYPE y_mat
                                          p_cont.

  DATA: l_verid TYPE verid,
        l_data  TYPE c LENGTH 10.

  CLEAR it_bdcdata[].
  CLEAR it_bdcdata.
  CLEAR l_data.

  WRITE: g_mfbf_date TO l_data.

  UNPACK '0001' TO l_verid.

  PERFORM f_preenche_bdc USING:
                                'X'    'SAPLBARM'        '0800',
                                ' '    'BDC_OKCODE'      '=ISTDA',
                                ' '    'RM61B-BUDAT'     l_data,
                                ' '    'RM61B-BLDAT'     l_data,
                                ' '    'RM61B-MATNR'     p_mat-matnr,
                                ' '    'RM61B-WERKS'     p_mat-werks,
                                ' '    'RM61B-VERID'     l_verid,
                                ' '    'RM61B-ERFMG'     '1',
                                ' '    'RM61B-ALORT'     'DP01'.

  PERFORM f_preenche_bdc USING:
                              'X'    'SAPLCOWB'        '0130',
                              ' '    'BDC_OKCODE'      '=MALL'.

  PERFORM f_preenche_bdc USING:
                              'X'    'SAPLCOWB'        '0130',
                              ' '    'BDC_OKCODE'      '=DELE'.

  PERFORM f_preenche_bdc USING:
                              'X'    'SAPLCOWB'        '0130',
                              ' '    'BDC_OKCODE'      '=WEIT'.


ENDFORM.                    " F_PREENCHE_BATCH_INPUT_ADD
*&---------------------------------------------------------------------*
*&      Form  F_ESTORNA_ORDEM_AJST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_estorna_ordem_ajst .

  DATA: l_verid TYPE verid,
        l_data  TYPE c LENGTH 10,
        l_message             TYPE c LENGTH 75,
        l_mode(1)             TYPE c,       " informa o Modo do Call Transaction
        l_s                   TYPE c,       " Informa o Update do call Transaction.
        w_stpo TYPE y_stpo.

  SORT t_ztbpp0003 BY idoc ASCENDING.

  LOOP AT t_mat INTO w_mat.

    READ TABLE t_mkal TRANSPORTING NO FIELDS WITH KEY matnr = w_mat-matnr.
    CHECK sy-subrc IS INITIAL.

** WIB - INÍCIO ------------------------- 25/07/2014
*   Verifica se o lançamento da produção foi realizado
    READ TABLE t_mfbf WITH KEY tpdoc = '2' "Lançamento da qtd "1"
                               matnr = w_mat-matnr
                               werks = w_mat-werks.

*   Não continua caso o Lançamento da qtd "1" não tenha sido realizada
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.
** WIB - FIM ---------------------------- 25/07/2014

    CLEAR it_bdcdata[].
    CLEAR it_bdcdata.
    CLEAR l_data.

    WRITE: g_mfbf_date TO l_data.

    UNPACK '0001' TO l_verid.

    PERFORM f_preenche_bdc USING:
                                  'X'    'SAPLBARM'        '0800',
                                  ' '    'BDC_OKCODE'      '=REVR',
                                  ' '    'RM61B-BUDAT'     l_data,
                                  ' '    'RM61B-BLDAT'     l_data,
                                  ' '    'RM61B-MATNR'     w_mat-matnr,
                                  ' '    'RM61B-WERKS'     w_mat-werks,
                                  ' '    'RM61B-VERID'     l_verid,
                                  ' '    'RM61B-ERFMG'     '1',
                                  ' '    'RM61B-ALORT'     'DP01'.

    PERFORM f_preenche_bdc USING:
                                  'X'    'SAPLBARM'        '0800',
                                  ' '    'BDC_OKCODE'      '=ISTDA',
                                  ' '    'RM61B-BUDAT'     l_data,
                                  ' '    'RM61B-BLDAT'     l_data,
                                  ' '    'RM61B-MATNR'     w_mat-matnr,
                                  ' '    'RM61B-WERKS'     w_mat-werks,
                                  ' '    'RM61B-VERID'     l_verid,
                                  ' '    'RM61B-ERFMG'     '1',
                                  ' '    'RM61B-ALORT'     'DP01'.

    PERFORM f_preenche_bdc USING:
                                'X'    'SAPLCOWB'        '0130',
                                ' '    'BDC_OKCODE'      '=MALL'.

    PERFORM f_preenche_bdc USING:
                                'X'    'SAPLCOWB'        '0130',
                                ' '    'BDC_OKCODE'      '=DELE'.

    PERFORM f_preenche_bdc USING:
                                'X'    'SAPLCOWB'        '0130',
                                ' '    'BDC_OKCODE'      '=WEIT'.

    l_mode = 'N'.
    l_s    = 'S'.
    CLEAR: it_msg[], it_msg.

    CALL TRANSACTION 'MFBF' USING  it_bdcdata
                            MODE   l_mode
                            UPDATE l_s
                            MESSAGES INTO it_msg.

    READ TABLE it_msg WITH KEY msgtyp = 'E'.
    IF sy-subrc IS INITIAL.
      CLEAR l_message.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = it_msg-msgid
          msgnr               = it_msg-msgnr
          msgv1               = it_msg-msgv1
          msgv2               = it_msg-msgv2
          msgv3               = it_msg-msgv3
          msgv4               = it_msg-msgv4
        IMPORTING
          message_text_output = l_message.
      CONCATENATE 'MFBF_EST:' l_message INTO l_message SEPARATED BY space.
      CLEAR w_stpo_aux.
      PERFORM f_preenche_log USING w_mat l_message w_stpo '' w_ztbpp0003-menge '' ''.
    ELSE.

      COMMIT WORK AND WAIT.

** WIB - INÍCIO --------------------- 25/07/2014
*     Grava o documento na tabela de controle caso se queira consultá-lo em tempo de execução (DEBUG)
*     Verifica se o lançamento foi realizado e recupera o número do documento
      READ TABLE it_msg WITH KEY msgid = 'RM'
                                 msgnr = '190'.
      IF sy-subrc IS INITIAL.

*       Verifica se existe número de documento
        IF NOT it_msg-msgv1 IS INITIAL.

*         Move dados do documento lançado
          CLEAR t_mfbf.
          t_mfbf-tpdoc = '3'. "Estorno do lançamento da qtd "1"
          t_mfbf-matnr = w_mat-matnr.
          t_mfbf-werks = w_mat-werks.
          t_mfbf-mblnr = it_msg-msgv1.

*         Grava registro na tabela de controle de documentos
          APPEND t_mfbf.
          CLEAR  t_mfbf.

        ENDIF.

      ENDIF.
** WIB - FIM --------------------- 25/07/2014

    ENDIF.

  ENDLOOP.

ENDFORM.                    " F_ESTORNA_ORDEM_AJST
*&---------------------------------------------------------------------*
*&      Form  F_MONTA_RANGE_MES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_monta_range_mes CHANGING e_erro_param.

  DATA: i_date TYPE sy-datum,
        e_date TYPE sy-datum.

  CLEAR: r_datum, r_datum[],
         i_date,
         e_date,
         e_erro_param,
         g_mfbf_date.

* Verifica se a data de produção foi passada como parâmetro
  IF NOT p_dtprd IS INITIAL.

*   Move mês e ano para parâmetro de período
    p_monat = p_dtprd(6).

*   Grava data no RANGE de período
    r_datum-low    = p_dtprd.
    r_datum-option = 'EQ'.
    r_datum-sign   = 'I'.
    APPEND r_datum.

*   Verifica se o usuário informou data no futuro
    IF sy-datum < p_dtprd.

*     Não é permitido realizar lançamentos em período futuro
      MESSAGE s005(zpp) DISPLAY LIKE 'E'.
      e_erro_param = 'X'.

    ELSE.
      g_mfbf_date = p_dtprd.
    ENDIF.

* Seleção com base no período informado
  ELSE.

*   Monta data inicial e recupera o último dia do período
    CONCATENATE p_monat '01' INTO i_date.
    CALL FUNCTION 'DATE_GET_MONTH_LASTDAY'
      EXPORTING
        i_date = i_date
      IMPORTING
        e_date = e_date.

    r_datum-low    = i_date.
    r_datum-high   = e_date.
    r_datum-option = 'BT'.
    r_datum-sign   = 'I'.
    APPEND r_datum.

*   Verifica se o usuário informou um período futuro
    IF sy-datum(6) < p_monat.

*     Não é permitido realizar lançamentos em período futuro
      MESSAGE s005(zpp) DISPLAY LIKE 'E'.
      e_erro_param = 'X'.

*   Verifica se a data atual está no mesmo período informado pelo usuário
    ELSEIF sy-datum(6) = p_monat.

      g_mfbf_date = sy-datum.

*   Se não estiver no mesmo período, então recupera o último dia do período
*   informado pelo usuário na tela
    ELSE.

      g_mfbf_date = e_date.

    ENDIF.

  ENDIF.

ENDFORM.                    " F_MONTA_RANGE_MES

*&---------------------------------------------------------------------*
*&      Form  ZF_RECUPERA_SALDO_PERIODO
*&---------------------------------------------------------------------*
FORM zf_recupera_saldo_periodo USING p_matnr
                                     p_werks
                            CHANGING p_menge.

  DATA: lv_menge       TYPE menge_d,
        lv_menge_pos   TYPE menge_d,
        lv_menge_neg   TYPE menge_d.

  CLEAR: lv_menge_pos.
  SELECT SUM( a~menge )
    INTO lv_menge_pos
    FROM mseg AS a
    JOIN mkpf AS b
      ON a~mblnr EQ b~mblnr
     AND a~mjahr EQ b~mjahr
   WHERE a~matnr EQ p_matnr
     AND a~werks EQ p_werks
     AND a~shkzg EQ 'S' "Débito
*     AND b~budat BETWEEN '20140601' AND '20140630'.
     AND b~budat IN r_datum.

  CLEAR: lv_menge_neg.
  SELECT SUM( a~menge )
    INTO lv_menge_neg
    FROM mseg AS a
    JOIN mkpf AS b
      ON a~mblnr EQ b~mblnr
     AND a~mjahr EQ b~mjahr
   WHERE a~matnr EQ p_matnr
     AND a~werks EQ p_werks
     AND a~shkzg EQ 'H' "Crédito
*     AND b~budat BETWEEN '20140601' AND '20140630'.
     AND b~budat IN r_datum.

* Calcula o saldo
  lv_menge = lv_menge_pos - lv_menge_neg.
  IF lv_menge < 0.
    p_menge = lv_menge * -1.
  ELSE.
    p_menge = 0. "Não deverá processar
  ENDIF.

ENDFORM.                    " ZF_RECUPERA_SALDO_PERIODO

*&---------------------------------------------------------------------*
*&      Form  ZF_RECUPERA_SALDO_PERIODO_COMP
*&---------------------------------------------------------------------*
FORM zf_recupera_saldo_periodo_comp USING p_matnr
                                          p_werks
                                          p_lgort
                                 CHANGING e_saldo_estoque.

* Inicializa parâmetro de retorno
  CLEAR e_saldo_estoque.

  DATA: lv_menge       TYPE menge_d,
        lv_menge_pos   TYPE menge_d,
        lv_menge_neg   TYPE menge_d.

  CLEAR: lv_menge_pos.
  SELECT SUM( a~menge )
    INTO lv_menge_pos
    FROM mseg AS a
    JOIN mkpf AS b
      ON a~mblnr EQ b~mblnr
     AND a~mjahr EQ b~mjahr
   WHERE a~matnr EQ p_matnr
     AND a~werks EQ p_werks
     AND a~lgort EQ p_lgort
     AND a~shkzg EQ 'S' "Débito
     AND b~budat IN r_datum.

  CLEAR: lv_menge_neg.
  SELECT SUM( a~menge )
    INTO lv_menge_neg
    FROM mseg AS a
    JOIN mkpf AS b
      ON a~mblnr EQ b~mblnr
     AND a~mjahr EQ b~mjahr
   WHERE a~matnr EQ p_matnr
     AND a~werks EQ p_werks
     AND a~lgort EQ p_lgort
     AND a~shkzg EQ 'H' "Crédito
     AND b~budat IN r_datum.

* Calcula o saldo
  CLEAR lv_menge.
  lv_menge = lv_menge_pos - lv_menge_neg.

  IF lv_menge < 0.
    e_saldo_estoque = lv_menge * -1.
  ELSE.
    e_saldo_estoque = lv_menge.
  ENDIF.

ENDFORM.                    " ZF_RECUPERA_SALDO_PERIODO_COMP

*&---------------------------------------------------------------------*
*&      Form  ZF_GRAVA_ERRO_ESTOQUE
*&---------------------------------------------------------------------*
FORM zf_grava_erro_estoque USING p_mat TYPE y_mat
                                 p_message
                                 p_stpo TYPE y_stpo
                                 p_qnt_com
                                 p_qnt_mat
                                 p_qnt_dep
                                 p_sucesso.

  CLEAR w_out.
  READ TABLE t_out INTO w_out WITH KEY loja = p_mat-werks
                                       matnr = p_mat-matnr.

  w_out-loja        = p_mat-werks.
  w_out-matnr       = p_mat-matnr.

  IF p_stpo IS NOT INITIAL.
    w_out-componente = p_stpo-component.
  ENDIF.

  ADD p_qnt_mat TO w_out-menge_mat.
  w_out-menge_comp  = p_qnt_com.
  w_out-menge_mat   = p_qnt_mat.
  w_out-menge_dep   = p_qnt_dep.
  w_out-message     = p_message.
  w_out-sucesso     = p_sucesso.

*  APPEND w_out TO t_out.
  COLLECT w_out INTO t_out.

ENDFORM.                    " ZF_GRAVA_ERRO_ESTOQUE

*&---------------------------------------------------------------------*
*&      Form  ZF_PREENCHE_DADOS_BAPI
*&---------------------------------------------------------------------*
FORM zf_preenche_dados_bapi USING p_mat TYPE y_mat.

* Variáveis locais
  DATA: l_componente TYPE matnr.

* Cabeçalho
  CLEAR w_goodsmvt_header.
  w_goodsmvt_header-doc_date   = g_mfbf_date.
  w_goodsmvt_header-pstng_date = g_mfbf_date.
  w_goodsmvt_header-header_txt = text-008.
  w_goodsmvt_header-pr_uname   = sy-uname.

* Atribuição code a transação para movimento mercadorias
  CLEAR w_goodsmvt_code.
* w_goodsmvt_code-gm_code = '05'. "Entrada de mercadoria
  w_goodsmvt_code-gm_code = '04'. "Transferência MB1B

* Converte código do material para formato interno
  CLEAR l_componente.
  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      input  = w_stpo_aux-component
    IMPORTING
      output = l_componente.

* Itens
  CLEAR: t_goodsmvt_item, t_goodsmvt_item[].
  t_goodsmvt_item-material   = l_componente.     "Material/Componente
  t_goodsmvt_item-plant      = p_mat-werks.      "Centro
* t_goodsmvt_item-stge_loc   = w_stpo_aux-lgort. "Depósito
  t_goodsmvt_item-stge_loc   = 'DP01'.           "Depósito Origem
  t_goodsmvt_item-move_stloc = w_stpo_aux-lgort. "Depósito Destino
* t_goodsmvt_item-move_type  = 'Z51'.            "Tipo de movimento
  t_goodsmvt_item-mvt_ind    = ' '.              "Movimento de mercadoria sem referência
  t_goodsmvt_item-entry_qnt  = w_stpo_aux-difst. "Saldo a transferir

* Recupera da parametrização o tipo de movimento
  SELECT SINGLE bwart INTO t_goodsmvt_item-move_type
    FROM ztbpp0002
    WHERE werks        = p_werks
      AND lgord_origem = 'DP01'.

* Recupera unidade de medida do material
  SELECT SINGLE meins INTO t_goodsmvt_item-entry_uom
    FROM mara
   WHERE matnr = l_componente.

* Grava registro na tabela de itens
  APPEND t_goodsmvt_item.
  CLEAR  t_goodsmvt_item.

ENDFORM.                    " ZF_PREENCHE_DADOS_BAPI

*&---------------------------------------------------------------------*
*&      Form  ZF_OBTEM_SALDO_LANC_INCORRETOS
*&---------------------------------------------------------------------*
FORM zf_obtem_saldo_lanc_incorretos CHANGING w_mat STRUCTURE w_mat.

** Verifica se existe Doc. do tipo 132 lançado no dia 24/07/2014. Se existir,
** devemos considerar esta demanda pois ela foi gerada pela execução incorreta
** deste programa (antes das correções)...
*  CLEAR l_count.
*  SELECT COUNT(*) INTO l_count
*    FROM mkpf AS a
*    JOIN mseg AS b
*      ON a~mblnr = b~mblnr
*     AND a~mjahr = b~mjahr
*    WHERE a~cpudt      EQ '20140724'
*      AND b~werks      EQ w_mat-werks
*      AND b~mjahr      EQ sy-datum(4)
*      AND b~matnr      EQ w_mat-matnr
*      AND b~bwart      EQ '132'.
*
*  IF sy-dbcnt > 0.
*    ADD 1 TO w_mat-menge.
*    MODIFY t_mat FROM w_mat TRANSPORTING menge.
*  ENDIF.

* Variáveis locais
  DATA: lv_saldo       TYPE menge_d,
        lv_menge_131   TYPE menge_d,
        lv_menge_132   TYPE menge_d.

* Recupera movimentos 131
  CLEAR: lv_menge_131.
  SELECT SUM( a~menge )
    INTO lv_menge_131
    FROM mseg AS a
    JOIN mkpf AS b
      ON a~mblnr EQ b~mblnr
     AND a~mjahr EQ b~mjahr
   WHERE a~matnr EQ w_mat-matnr
     AND a~werks EQ w_mat-werks
     AND a~bwart EQ '131'
     AND b~budat IN r_datum.

* Recupera movimentos 132
  CLEAR: lv_menge_132.
  SELECT SUM( a~menge )
    INTO lv_menge_132
    FROM mseg AS a
    JOIN mkpf AS b
      ON a~mblnr EQ b~mblnr
     AND a~mjahr EQ b~mjahr
   WHERE a~matnr EQ w_mat-matnr
     AND a~werks EQ w_mat-werks
     AND a~bwart EQ '132'
     AND b~budat IN r_datum.

* Transforma a demanda em valor negativo
  MULTIPLY lv_menge_132 BY -1.

* Calcula a diferença entre os lançamentos para apontar na produção
  CLEAR lv_saldo.
  lv_saldo = lv_menge_132 + lv_menge_131.

  IF lv_saldo < 0.
    w_mat-menge = w_mat-menge + ( lv_saldo * -1 ).
  ELSE.
    w_mat-menge = w_mat-menge - lv_saldo.
  ENDIF.

ENDFORM.                    " ZF_OBTEM_SALDO_LANC_INCORRETOS

*&---------------------------------------------------------------------*
*&      Form  ZF_LANCAMENTO_PRODUCAO
*&---------------------------------------------------------------------*
FORM zf_lancamento_producao TABLES t_stpo STRUCTURE stpo_api02
                             USING p_mat TYPE y_mat
                                   p_lgort
                                   p_cont.

* Variáveis locais
  DATA: w_stpo         LIKE stpo_api02,
        l_confirmation TYPE prtnr,
        l_doc_material TYPE mblnr,
        l_message      TYPE c LENGTH 75,
        l_qtd_comp     TYPE kmpmg,
        l_qtd_basica   TYPE basmn,
        l_qtd_baixa    TYPE erfmg,
        l_meins        TYPE meins,
        l_verid        TYPE verid.

* Inicializa tabela
  CLEAR: t_goodsmovements, t_goodsmovements[].

* Inicializa estruturas
  CLEAR: w_bflushflags,
         w_bflushdatagen,
         w_return,
         w_stpo.

* Inicializa variáveis
  CLEAR: l_confirmation,
         l_doc_material,
         l_verid,
         l_meins,
         l_message.

* Recupera a unidade de medida do material
  SELECT SINGLE meins INTO l_meins
    FROM mara
   WHERE matnr = p_mat-matnr.

* Converte unidade de medida
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING
      input  = l_meins
    IMPORTING
      output = l_meins.

* Versão da produção
  UNPACK p_cont TO l_verid.

* Move dados para estrutura da BAPI
  w_bflushflags-bckfltype       = '01'.
  w_bflushflags-activities_type = '1'.
  w_bflushflags-components_type = '1'.

* Move dados para estrutura da BAPI
  w_bflushdatagen-materialnr    = p_mat-matnr.
  w_bflushdatagen-prodplant     = p_mat-werks.
  w_bflushdatagen-planplant     = p_mat-werks.
  w_bflushdatagen-storageloc    = 'DP01'.
  w_bflushdatagen-prodversion   = l_verid.
  w_bflushdatagen-postdate      = g_mfbf_date.
  w_bflushdatagen-docdate       = g_mfbf_date.
  w_bflushdatagen-backflquant   = p_mat-menge.
  w_bflushdatagen-unitofmeasure = l_meins.
  w_bflushdatagen-docheadertxt  = text-009.

*-----------------------------------------------------------------------------*
* Entrada em estoque do Material de Produção
*****  t_goodsmovements-material  = p_mat-matnr.      "Material de Produção
*****  t_goodsmovements-plant     = p_mat-werks.      "Centro
*****  t_goodsmovements-stge_loc  = 'DP01'.           "Depósito
*****  t_goodsmovements-move_type = '131'.            "Tipo de movimento
*****  t_goodsmovements-entry_qnt = p_mat-menge.      "Quantidade produção
*****
****** Unidade de medida
*****  t_goodsmovements-entry_uom = l_meins.
*****  t_goodsmovements-base_uom  = l_meins.
*****
****** Grava os dados do componente na tabela
*****  APPEND t_goodsmovements.
*****  CLEAR  t_goodsmovements.
*-----------------------------------------------------------------------------*

* Componentes do material
  LOOP AT t_stpo INTO w_stpo.

*   Inicializa variáveis
    CLEAR: l_qtd_baixa, l_qtd_comp.

    TRANSLATE w_stpo-comp_qty USING ',.'.
    CONDENSE  w_stpo-comp_qty NO-GAPS.
    TRANSLATE w_stko-base_quan USING ',.'.
    CONDENSE  w_stko-base_quan NO-GAPS.

    CLEAR: l_qtd_comp, l_qtd_basica.
    l_qtd_comp   = w_stpo-comp_qty.
    l_qtd_basica = w_stko-base_quan.

*   Calcula a quantidade a ser consumida
    l_qtd_baixa = ( l_qtd_comp * p_mat-menge ) / l_qtd_basica.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = w_stpo-component
      IMPORTING
        output = w_stpo-component.

    t_goodsmovements-material  = w_stpo-component. "Componente de lista técnica
    t_goodsmovements-plant     = p_mat-werks.      "Centro
    t_goodsmovements-stge_loc  = p_lgort.          "Depósito
    t_goodsmovements-move_type = '261'.            "Tipo de movimento
*   t_goodsmovements-quantity  = w_stpo-comp_qty.  "Quantidade do componente
*   t_goodsmovements-base_uom  = w_stpo-comp_unit. "Unidade de medida do componente
    t_goodsmovements-entry_qnt = l_qtd_baixa.      "Quantidade do componente

*   Converte unidade de medida
    CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
      EXPORTING
        input  = w_stpo-comp_unit
      IMPORTING
        output = l_meins.

*   Unidade de medida do componente
    t_goodsmovements-entry_uom = l_meins.
    t_goodsmovements-base_uom  = l_meins.

*   Grava os dados do componente na tabela
    APPEND t_goodsmovements.
    CLEAR  t_goodsmovements.

  ENDLOOP.

* Chama BAPI para realizar o apontamento da produção
  CLEAR: t_return, t_return[].
  CALL FUNCTION 'BAPI_REPMANCONF1_CREATE_MTS'
    EXPORTING
      bflushflags    = w_bflushflags
      bflushdatagen  = w_bflushdatagen
*     bflushdatamts  = w_bflushdatamts
    IMPORTING
      confirmation   = l_confirmation
      return         = w_return
    TABLES
      goodsmovements = t_goodsmovements.

* Salvar número da Confirmação para posterior ajuste
  IF l_confirmation IS NOT INITIAL.

    CLEAR ztbpp_matnr_mov.
    ztbpp_matnr_mov-prtnr    = l_confirmation.
    ztbpp_matnr_mov-flg_conf = abap_true.
    INSERT ztbpp_matnr_mov.
  ENDIF.

*******************************************************
* Verifica ocorrência de erro no lançamento da produção
*----------------------------------*
* Produção realizada com ERRO
*----------------------------------*
  IF w_return-type = 'E'.

*   Desfaz operações de banco
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*   Grava mensagem de erro na tabela de LOG
    l_message = w_return-message.
    CONCATENATE 'MFBF_ADD1:' l_message INTO l_message SEPARATED BY space.
    CLEAR w_stpo_aux.
    PERFORM f_preenche_log USING p_mat l_message w_stpo_aux '' p_mat-menge '' ''.

*----------------------------------*
* Produção realizada com SUCESSO
*----------------------------------*
  ELSE.

*   Execução operações de banco
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    l_doc_material = l_confirmation.

*   Grava mensagem de sucesso na tabela de LOG
    l_message = text-003.
    REPLACE ALL OCCURRENCES OF '&1' IN l_message WITH l_doc_material.
    CLEAR w_stpo_aux.
    PERFORM f_preenche_log USING p_mat l_message w_stpo_aux '' p_mat-menge '' 'X'.

*-------------------------------------------------------*
*   Move dados do documento lançado
    CLEAR t_mfbf.
    t_mfbf-tpdoc = '1'. "Lançamento da Produção
    t_mfbf-matnr = p_mat-matnr.
    t_mfbf-werks = p_mat-werks.
    t_mfbf-mblnr = l_doc_material.

*   Grava registro na tabela de controle de documentos
    APPEND t_mfbf.
    CLEAR  t_mfbf.
*-------------------------------------------------------*
*   Commit para evitar estouro de memória
    COMMIT WORK.

  ENDIF.

ENDFORM.                    " ZF_LANCAMENTO_PRODUCAO

*&---------------------------------------------------------------------*
*&      Form  ZF_RECUPERA_SALDO_ATUAL_FERT
*&---------------------------------------------------------------------*
FORM zf_recupera_saldo_atual_fert USING p_matnr
                                        p_werks
                               CHANGING e_saldo_fert.

  DATA: lv_menge       TYPE menge_d,
        lv_menge_pos   TYPE menge_d,
        lv_menge_neg   TYPE menge_d,
        lbkum          TYPE mbew-lbkum,
        datum          TYPE sy-datum.

  CLEAR e_saldo_fert.

  CLEAR: lv_menge_pos.
  SELECT SUM( a~menge )
    INTO lv_menge_pos
    FROM mseg AS a
    JOIN mkpf AS b
      ON a~mblnr EQ b~mblnr
     AND a~mjahr EQ b~mjahr
   WHERE a~matnr EQ p_matnr
     AND a~werks EQ p_werks
     AND a~shkzg EQ 'S' "Débito
     AND b~budat IN r_datum.

  CLEAR: lv_menge_neg.
  SELECT SUM( a~menge )
    INTO lv_menge_neg
    FROM mseg AS a
    JOIN mkpf AS b
      ON a~mblnr EQ b~mblnr
     AND a~mjahr EQ b~mjahr
   WHERE a~matnr EQ p_matnr
     AND a~werks EQ p_werks
     AND a~shkzg EQ 'H' "Crédito
     AND b~budat IN r_datum.

* Calcula o saldo
  CLEAR lv_menge.
  lv_menge = lv_menge_pos - lv_menge_neg.

* CHPS - 24.06.2015 - Solicitação André

  CLEAR: lbkum,
         datum.

  CONCATENATE p_monat '01' INTO datum.

  CALL FUNCTION 'ZPM_GET_STOCK_IN_DATE'
    EXPORTING
      matnr = p_matnr
      werks = p_werks
      datum = datum
    IMPORTING
      lbkum = lbkum.

  ADD lbkum TO lv_menge.

* CHPS - 24.06.2015 - Solicitação André




  IF lv_menge < 0.
    e_saldo_fert = lv_menge * -1.
  ELSE.
    e_saldo_fert = 0.
  ENDIF.

ENDFORM.                    " ZF_RECUPERA_SALDO_ATUAL_FERT

*&---------------------------------------------------------------------*
*&      Form  ZF_CONVERT_CHAR_TO_NUM
*&---------------------------------------------------------------------*
FORM zf_convert_char_to_num  USING p_char
                          CHANGING p_number.

  DATA l_tam TYPE i.

  CLEAR p_number.

  l_tam = strlen( p_char ).

  IF l_tam > 7.
    TRANSLATE p_char USING '. '.
    CONDENSE  p_char NO-GAPS.
  ENDIF.

  TRANSLATE p_char USING ',.'.

  p_number = p_char.

ENDFORM.                    " ZF_CONVERT_CHAR_TO_NUM

*&---------------------------------------------------------------------*
*&      Form  F_LIMPA_REGS_INCON_POSPROC
*&---------------------------------------------------------------------*
FORM f_limpa_regs_incon_posproc .

* Inicializa RANGE auxiliar
  CLEAR: r_plant, r_plant[].

* Verifica se a Loja foi informada
  IF NOT p_werks IS INITIAL.
    r_plant-sign   = 'I'.
    r_plant-option = 'EQ'.
    r_plant-low    = p_werks.
    APPEND r_plant.
    CLEAR  r_plant.
  ENDIF.

* Executa programa para limpar registros inconsistentes de proc. posterior
  SUBMIT zincon_reproc TO SAP-SPOOL AND RETURN
    WITH del_upd  EQ 'X'
    WITH plant    IN r_plant
    WITH material IN s_matnr
    WITHOUT SPOOL DYNPRO.

ENDFORM.                    " F_LIMPA_REGS_INCON_POSPROC
*&---------------------------------------------------------------------*
*&      Form  F_ESTORNA_ORDEM_AJST2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_estorna_ordem_ajst2 .
*  DATA: l_verid TYPE verid,
*        l_data  TYPE c LENGTH 10,
  DATA:   l_mode(1)             TYPE c,       " informa o Modo do Call Transaction
          l_message             TYPE c LENGTH 75,
          l_s                   TYPE c,       " Informa o Update do call Transaction.
          w_stpo TYPE y_stpo.

  LOOP AT it_confirmation INTO wa_confirmation.

    PERFORM f_preenche_bdc USING:
         'X'   'SAPLBARM'     '0400',
         ' '   'BDC_CURSOR'   'BLPK-PRTNR',
         ' '   'BDC_OKCODE'   '=EXEC',
         ' '   'RM61B-BUDAT'  sy-datum,
         ' '   'RM61A-RTYPS'  'X',
         ' '   'BLPK-PRTNR'   wa_confirmation,
         ' '   'MAX_RECORDS'  '800'.

    PERFORM f_preenche_bdc USING:
         'X'   'SAPMSSY0'     '0120',
         ' '   'BDC_CURSOR'   '06/12',
         ' '   'BDC_OKCODE'   '=CANC'.

    l_mode = 'N'.
    l_s    = 'S'.
    CLEAR: it_msg[], it_msg.

    CALL TRANSACTION 'MF41' USING it_bdcdata
                            MODE   l_mode
                            UPDATE l_s
                            MESSAGES INTO it_msg.

    READ TABLE it_msg WITH KEY msgtyp = 'E'.
    IF sy-subrc IS INITIAL.
      CLEAR l_message.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = it_msg-msgid
          msgnr               = it_msg-msgnr
          msgv1               = it_msg-msgv1
          msgv2               = it_msg-msgv2
          msgv3               = it_msg-msgv3
          msgv4               = it_msg-msgv4
        IMPORTING
          message_text_output = l_message.
      CONCATENATE 'MFBF_EST:' l_message INTO l_message SEPARATED BY space.
      CLEAR w_stpo_aux.
      PERFORM f_preenche_log USING w_mat l_message w_stpo '' w_ztbpp0003-menge '' ''.
    ELSE.
      COMMIT WORK AND WAIT.
*     Grava o documento na tabela de controle caso se queira consultá-lo em tempo de execução (DEBUG)
*     Verifica se o lançamento foi realizado e recupera o número do documento
      READ TABLE it_msg WITH KEY msgid = 'RM'
                                 msgnr = '190'.
      IF sy-subrc IS INITIAL.

*       Verifica se existe número de documento
        IF NOT it_msg-msgv1 IS INITIAL.
*         Move dados do documento lançado
          CLEAR t_mfbf.
          t_mfbf-tpdoc = '3'. "Estorno do lançamento da qtd "1"
          t_mfbf-matnr = w_mat-matnr.
          t_mfbf-werks = w_mat-werks.
          t_mfbf-mblnr = it_msg-msgv1.
*         Grava registro na tabela de controle de documentos
          APPEND t_mfbf.
          CLEAR  t_mfbf.
        ENDIF.
      ENDIF.
** WIB - FIM --------------------- 25/07/2014
    ENDIF.
*    ENDLOOP.
  ENDLOOP."LOOP NOVO
ENDFORM.                    " F_ESTORNA_ORDEM_AJST2

