************************************************************************
* Programa :  ZFIR014
* Descrição:  Geração de arquivo txt para Contas Retorno SAP
* Autor    :  ARPS - Arnaldo Parente
* Data     :  05/12/2012
* Documento:
************************************************************************
* Histórico das modificações
************************************************************************
* Data       Nome                  Descrição
*05/08/2013   ARPS          DESK902929 - Desenvolvimento Inicial
************************************************************************
REPORT  ZFIR014.

*----------------------------------------------------------------------*
* Include de Variáveis
*----------------------------------------------------------------------*
INCLUDE zfir014top.

*----------------------------------------------------------------------*
* Tela de seleção
*----------------------------------------------------------------------*
* Dados utilizados nas seleções
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_bukrs FOR bsas-bukrs OBLIGATORY,
                s_blart FOR bsis-blart OBLIGATORY,
                s_budat FOR bsas-budat,
                s_bldat FOR bsas-bldat.
SELECTION-SCREEN: END OF BLOCK b1.

*** List Box dinâmica baseada na seleção do usuário
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS:
* Opção por arquivo no servidor
             p_server RADIOBUTTON GROUP rad1  DEFAULT 'X' USER-COMMAND radio,
             p_path   TYPE string NO-DISPLAY,
* Opção por arquivo local
             p_local  RADIOBUTTON GROUP rad1,
             p_path2  TYPE string.
SELECTION-SCREEN END OF BLOCK b2.

*----------------------------------------------------------------------*
* Include de Performs
*----------------------------------------------------------------------*
INCLUDE zfir014f01.

*----------------------------------------------------------------------*
* AT SELECTION-SCREEN
*----------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_path2.
  PERFORM mostra_local USING p_path2.

*-----------------------------------------------------------------------
*-- START-OF-SELECTION
*-----------------------------------------------------------------------
START-OF-SELECTION.
* Verifica a existência do documento na tabela ZFIT003
  PERFORM verifica_existencia.

* Seleciona os dados a partir da tela de seleção
  PERFORM seleciona_dados.

* Monta os dados
  PERFORM monta_dados.

* Cria arquivo TXT
  PERFORM cria_txt.

  *&---------------------------------------------------------------------*
*&  Include           ZFIR014TOP
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*-- Tabelas
*----------------------------------------------------------------------*
TABLES: bsas,
        bsis.

*----------------------------------------------------------------------*
*-- Tipos
*----------------------------------------------------------------------*
TYPES:  BEGIN OF ty_bsas_bsis,
          bukrs   TYPE bsas-bukrs,                          "02 Empresa
          hkont   TYPE bsas-hkont,  "03 Conta do Razão da contabilidade geral
          augdt   TYPE bsas-augdt,  "04 Data de compensação
          augbl   TYPE bsas-augbl,  "05 Nº documento de compensação
          zuonr   TYPE bsas-zuonr,  "06 Nº atribuição
          gjahr   TYPE bsas-gjahr,  "07 Exercício
          belnr   TYPE bsas-belnr,  "08 Nº documento de um documento contábil
          buzei   TYPE bsas-buzei,  "09 Nº linha de lançamento no documento contábil
          budat   TYPE bsas-budat,  "10 Data de lançamento no documento
          bldat   TYPE bsas-bldat,  "11 Data no documento
          xblnr   TYPE bsas-xblnr,  "13 Nº documento de referência
          blart   TYPE bsas-blart,  "14 Tipo de documento
          shkzg   TYPE bsas-shkzg,  "17 Código débito/crédito
          dmbtr   TYPE bsas-dmbtr,  "21 Montante em moeda interna
          sgtxt   TYPE bsas-sgtxt,  "25 Texto do item
          kostl   TYPE bsas-kostl,  "29 Centro de custo
          prctr   TYPE bsas-prctr,  "47 Centro de lucro
        END OF ty_bsas_bsis,

        BEGIN OF ty_bkpf,
          bukrs     TYPE bkpf-bukrs,                        "02 Empresa
          belnr     TYPE bkpf-belnr,    "03 Nº documento de um documento contábil
          gjahr     TYPE bkpf-gjahr,    "04 Exercício
          xblnr     TYPE bkpf-xblnr,    "17 Nº documento de referência
          stblg     TYPE bkpf-stblg,    "19 Nº documento de estorno
          xref1_hd  TYPE bkpf-xref1_hd, "67 Chave referência _1 interna para cabeçalho documento
          xref2_hd  TYPE bkpf-xref2_hd, "68 Chave referência _2 interna para cabeçalho documento
        END OF ty_bkpf,

        BEGIN OF ty_bsak_bsik,
          bukrs   TYPE bsak-bukrs,                          "02 Empresa
          lifnr   TYPE bsak-lifnr,  "04 Nº conta do fornecedor
          umsks   TYPE bsak-umsks,  "05 Classe de operação de Razão Especial
          umskz   TYPE bsak-umskz,  "06 Código de Razão Especial
          augdt   TYPE bsak-augdt,  "07 Data de compensação
          augbl   TYPE bsak-augbl,  "08 Nº documento de compensação
          zuonr   TYPE bsak-zuonr,  "09 Nº atribuição
          gjahr   TYPE bsak-gjahr,  "10 Exercício
          belnr   TYPE bsak-belnr,  "11 Nº documento de um documento contábil
          buzei   TYPE bsak-buzei,  "12 Nº linha de lançamento no documento contábil
        END OF ty_bsak_bsik,

        BEGIN OF ty_saida,
          pipe1(1)  TYPE c,
          blart     TYPE bsas-bukrs,
          texto     TYPE zfit003-texto,
          hkont     TYPE bsas-hkont,
          belnr     TYPE bsas-belnr,
          bldat(8)  TYPE c,
          budat(8)  TYPE c,
          prctr     TYPE bsas-prctr,
          kostl     TYPE bsas-kostl,
          lifnr     TYPE bsak-lifnr,
          xblnr     TYPE bkpf-xblnr,
          dmbtr(13) TYPE c,
          sgtxt     TYPE bsas-sgtxt,
          xref1_hd  TYPE bkpf-xref1_hd,
          xref2_hd  TYPE bkpf-xref2_hd,
          pipe2(1)  TYPE c,
         END OF ty_saida.

TYPES truxs_t_text_data(4096) TYPE c OCCURS 0.

*----------------------------------------------------------------------*
*-- Tabelas internas
*----------------------------------------------------------------------*
DATA: gt_bsas_bsis  TYPE TABLE OF ty_bsas_bsis,
      gt_bkpf       TYPE TABLE OF ty_bkpf,
      gt_bsak_bsik  TYPE TABLE OF ty_bsak_bsik,
      gt_zfit003    TYPE TABLE OF zfit003,
      gt_txt        TYPE truxs_t_text_data,
      gt_saida      TYPE TABLE OF ty_saida.

*----------------------------------------------------------------------*
*-- Estruturas
*----------------------------------------------------------------------*
DATA: gs_bsas_bsis  LIKE LINE OF gt_bsas_bsis,
      gs_bkpf       LIKE LINE OF gt_bkpf,
      gs_bsak_bsik  LIKE LINE OF gt_bsak_bsik,
      gs_zfit003    LIKE LINE OF gt_zfit003,
      gs_txt        LIKE LINE OF gt_txt,
      gs_saida      LIKE LINE OF gt_saida.

*----------------------------------------------------------------------*
*-- Variaveis
*----------------------------------------------------------------------*
DATA: gv_h(1)           TYPE c VALUE 'H', "Campo bsas/bsis-shkzg
      gv_vazio(1)       TYPE c VALUE ' ', "Campo bkpf-stblg
      gv_diretorio(12)  TYPE c VALUE 'CTA_RETORNO'.
*----------------------------------------------------------------------*
*-- Constantes
*----------------------------------------------------------------------*








*&---------------------------------------------------------------------*
*&  Include           ZFIR014F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  MOSTRA_LOCAL
*&---------------------------------------------------------------------*
*       Perform para definir o local onde o arquivo será salvo
*----------------------------------------------------------------------*
FORM mostra_local USING p_path2 TYPE string.
* Mostra o local onde será gravado o arquivo de Log.
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = 'Selecione o local onde o arquivo será salvo!'
      initial_folder       = 'C:\'
    CHANGING
      selected_folder      = p_path2
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
* Nome do Arquivo do Log contendo: Endereço do diretório + Nome do usuário + Data + Hora + .TXT.
  CONCATENATE  p_path2 '\' sy-uname '_' sy-datum '_' sy-uzeit '.TXT' INTO p_path2.

ENDFORM.                    " MOSTRA_LOCAL

*&---------------------------------------------------------------------*
*&      Form  VERIFICA_EXISTENCIA
*&---------------------------------------------------------------------*
*       Verifica se o documento esta cadastrado na tabela ZFIT003
*----------------------------------------------------------------------*
FORM verifica_existencia.
  SELECT *
  FROM  zfit003
  INTO TABLE gt_zfit003
  WHERE blart IN s_blart.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE text-003 TYPE 'S' DISPLAY LIKE 'E'. " Nenhum Tipo de Documento informado está cadastrado na tabela de Parametrização
    LEAVE LIST-PROCESSING.
  ENDIF.
ENDFORM.                    " VERIFICA_EXISTENCIA

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_DADOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM seleciona_dados .
*** Verificando se esta sendo executado via job
  IF sy-batch IS NOT INITIAL.
    CLEAR s_budat.
    s_budat-sign    = 'I'.
    s_budat-option  = 'EQ'.
    s_budat-low     = sy-datum - 1.
    s_budat-high    = sy-datum - 1.

    APPEND s_budat.
  ENDIF.

*** Selecionando itens de partidas compensadas de contas do Razão
  SELECT bukrs
         hkont
         augdt
         augbl
         zuonr
         gjahr
         belnr
         buzei
         budat
         bldat
         xblnr
         blart
         shkzg
         dmbtr
         sgtxt
         kostl
         prctr
  FROM bsas
  INTO CORRESPONDING FIELDS OF TABLE gt_bsas_bsis
  FOR ALL ENTRIES IN gt_zfit003
  WHERE bukrs IN s_bukrs
    AND hkont EQ gt_zfit003-hkont
    AND budat IN s_budat
    AND bldat IN s_bldat
    AND blart EQ gt_zfit003-blart
    AND shkzg EQ gv_h.

*** Selecionando itens de partidas abertas de contas do Razão
  SELECT bukrs
         hkont
         augdt
         augbl
         zuonr
         gjahr
         belnr
         buzei
         budat
         bldat
         xblnr
         blart
         shkzg
         dmbtr
         sgtxt
         kostl
         prctr
  FROM bsis
  APPENDING CORRESPONDING FIELDS OF TABLE gt_bsas_bsis
  FOR ALL ENTRIES IN gt_zfit003
  WHERE bukrs IN s_bukrs
    AND hkont EQ gt_zfit003-hkont
    AND budat IN s_budat
    AND bldat IN s_bldat
    AND blart EQ gt_zfit003-blart
    AND shkzg EQ gv_h.

  IF gt_bsas_bsis IS INITIAL.
    MESSAGE text-004 TYPE 'S' DISPLAY LIKE 'E'. " Não há partidas abertas ou compensadas do Razão para os parâmetros informados
    LEAVE LIST-PROCESSING.

  ELSE.
*** Selecionando o cabeçalho de documentos gerais de FI
    SELECT bukrs
           belnr
           gjahr
           xblnr
           stblg
           xref1_hd
           xref2_hd
    FROM bkpf
    INTO CORRESPONDING FIELDS OF TABLE gt_bkpf
    FOR ALL ENTRIES IN gt_bsas_bsis
    WHERE bukrs EQ gt_bsas_bsis-bukrs
      AND belnr EQ gt_bsas_bsis-belnr
      AND stblg EQ gv_vazio.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE text-005 TYPE 'S' DISPLAY LIKE 'E'. " Não há documentos gerais de FI
      LEAVE LIST-PROCESSING.

    ELSE.
*** Selecionando itens de partidas compensadas de contas de Fornecedores
      SELECT bukrs
             lifnr
             umsks
             umskz
             augdt
             augbl
             zuonr
             gjahr
             belnr
             buzei
      FROM bsak
      INTO CORRESPONDING FIELDS OF TABLE gt_bsak_bsik
      FOR ALL ENTRIES IN gt_bkpf
      WHERE bukrs EQ gt_bkpf-bukrs
        AND belnr EQ gt_bkpf-belnr.

*** Selecionando itens de partidas abertas de contas de Fornecedores
      SELECT bukrs
             lifnr
             umsks
             umskz
             augdt
             augbl
             zuonr
             gjahr
             belnr
             buzei
      FROM bsik
      APPENDING CORRESPONDING FIELDS OF TABLE gt_bsak_bsik
      FOR ALL ENTRIES IN gt_bkpf
      WHERE bukrs EQ gt_bkpf-bukrs
        AND belnr EQ gt_bkpf-belnr.

      IF sy-subrc IS NOT INITIAL.
        MESSAGE text-006 TYPE 'S' DISPLAY LIKE 'E'. " Não há partidas abertas ou compensadas de Fornecedores para os parâmetros informados
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " SELECIONA_DADOS

*&---------------------------------------------------------------------*
*&      Form  MONTA_DADOS
*&---------------------------------------------------------------------*
*       Monta os dados que serão gravados no documento
*----------------------------------------------------------------------*
FORM monta_dados .
  CLEAR gs_bsas_bsis.
  LOOP AT gt_bsas_bsis INTO gs_bsas_bsis.

    CLEAR gs_zfit003.
    READ TABLE gt_zfit003 INTO gs_zfit003 WITH KEY hkont = gs_bsas_bsis-hkont
                                                   blart = gs_bsas_bsis-blart.

    CLEAR gs_bkpf.
    READ TABLE gt_bkpf INTO gs_bkpf WITH KEY bukrs = gs_bsas_bsis-bukrs
                                             belnr = gs_bsas_bsis-belnr.

    CLEAR gs_bsak_bsik.
    READ TABLE gt_bsak_bsik INTO gs_bsak_bsik WITH KEY bukrs = gs_bkpf-bukrs
                                                       belnr = gs_bkpf-belnr.

    gs_saida-pipe1  = ''.
    gs_saida-blart  = gs_bsas_bsis-blart.
    gs_saida-texto  = gs_zfit003-texto.
    gs_saida-hkont  = gs_bsas_bsis-hkont.
    gs_saida-belnr  = gs_bsas_bsis-belnr.

*** Tratando datas (bldat e budat)
    CONCATENATE gs_bsas_bsis-bldat+6(02) gs_bsas_bsis-bldat+4(02) gs_bsas_bsis-bldat(04) INTO gs_saida-bldat.
    CONCATENATE gs_bsas_bsis-budat+6(02) gs_bsas_bsis-budat+4(02) gs_bsas_bsis-budat(04) INTO gs_saida-budat.

    gs_saida-prctr  = gs_bsas_bsis-prctr.
    gs_saida-kostl  = gs_bsas_bsis-kostl.
    gs_saida-lifnr  = gs_bsak_bsik-lifnr.
    gs_saida-xblnr  = gs_bkpf-xblnr.

*** Tratando valores (dmbtr)
    gs_saida-dmbtr  = gs_bsas_bsis-dmbtr.
    REPLACE ALL OCCURRENCES OF '.' IN gs_saida-dmbtr WITH ''.
    REPLACE ALL OCCURRENCES OF ',' IN gs_saida-dmbtr WITH ''.
    UNPACK gs_saida-dmbtr TO gs_saida-dmbtr.

    gs_saida-sgtxt    = gs_bsas_bsis-sgtxt.
    gs_saida-xref1_hd = gs_bkpf-xref1_hd.
    gs_saida-xref2_hd = gs_bkpf-xref2_hd.
    gs_saida-pipe2    = ''.

    APPEND gs_saida TO gt_saida.
    CLEAR gs_saida.

  ENDLOOP.
ENDFORM.                    " MONTA_DADOS

*&---------------------------------------------------------------------*
*&      Form  CONVERTE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM converte_data USING p_data.
  CALL FUNCTION 'CONVERSION_EXIT_PDATE_INPUT'
    EXPORTING
      input         = p_data
   	IMPORTING
      output        = p_data
            .
ENDFORM.                    " CONVERTE_DATA

*&---------------------------------------------------------------------*
*&      Form  CRIA_TXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM cria_txt .
*** Caso o usuário tenha optado por salvar no servidor
  IF p_server IS NOT INITIAL.
    PERFORM salva_server.
  ELSE.
*** Caso o usuário tenha optado por salvar localmente
    PERFORM salva_local.
  ENDIF.
ENDFORM.                    " CRIA_TXT

*&---------------------------------------------------------------------*
*&      Form  SALVA_SERVER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM salva_server .
  DATA: lv_msg TYPE string.

  PERFORM seleciona_diretorio.

  IF p_path IS INITIAL.
    MESSAGE text-007 TYPE 'S' DISPLAY LIKE 'E'. " Cadastrar endereço do servidor na transação Z_DIR_INTERFACE no diretório CTA_RETORNO
    LEAVE LIST-PROCESSING.
  ENDIF.

  CONCATENATE  p_path sy-uname '_' sy-datum '_' sy-uzeit '.TXT' INTO p_path.

* Converte dados para txt
  PERFORM convert_txt.

  OPEN DATASET p_path FOR OUTPUT IN TEXT MODE ENCODING NON-UNICODE.

  LOOP AT gt_txt INTO gs_txt.
    TRANSFER gs_txt TO p_path.
  ENDLOOP.

  IF sy-subrc = 0.
    CONCATENATE text-008 p_path INTO lv_msg. " Arquivo gerado com sucesso no diretório p_path
    MESSAGE lv_msg TYPE 'I'.
  ELSE.
    MESSAGE text-009 TYPE 'I'. " Arquivo Não Gerado
  ENDIF.

  CLOSE DATASET p_path.

ENDFORM.                    " SALVA_SERVER

*&---------------------------------------------------------------------*
*&      Form  SALVA_LOCAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM salva_local .
* Converte dados para txt
  PERFORM convert_txt.

* Gerando arquivo localmente...
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = p_path2
      filetype                = 'ASC'
    TABLES
      data_tab                = gt_txt
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.                    " SALVA_LOCAL

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_DIRETORIO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM seleciona_diretorio .
  SELECT SINGLE caminho FROM ztint001 INTO p_path WHERE diretorio = gv_diretorio.

ENDFORM.                    " SELECIONA_DIRETORIO

*&---------------------------------------------------------------------*
*&      Form  CONVERT_TXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM convert_txt .
  CALL FUNCTION 'SAP_CONVERT_TO_TEX_FORMAT'
   EXPORTING
    i_field_seperator          = '|'
*   I_LINE_HEADER              =
*   I_FILENAME                 =
*   I_APPL_KEEP                = ' '
   TABLES
     i_tab_sap_data             = gt_saida
   CHANGING
     i_tab_converted_data       = gt_txt
* EXCEPTIONS
*   CONVERSION_FAILED          = 1
*   OTHERS                     = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " CONVERT_TXT