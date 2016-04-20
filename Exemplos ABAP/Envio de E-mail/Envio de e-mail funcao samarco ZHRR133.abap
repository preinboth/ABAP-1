*----------------------------------------------------------------------*
*  Transação........: ZHR151                                           *
*  Objetivo.........: Envio de e-mail Regularização CPF Dependentes    *
*  Módulo...........: HR                                               *
*  Autor............: Bruno Barbosa                                    *
*  Data de Criação..: 22.04.2013                                       *
*----------------------------------------------------------------------*
*                       Histórico das Alterações                       *
*----------------------------------------------------------------------*
*  Última mod.   Autor          Motivo                                 *
*  DD/MM/AAAA    XXXXXXXXXX     XXXXXXXXXXXXXXXXXXXXXXXXXXX            *
*----------------------------------------------------------------------*

REPORT  zhrr133.
************************************************************************
*** TABELAS
************************************************************************
TABLES: somlreci1.

************************************************************************
*** TIPOS
************************************************************************
TYPES: BEGIN OF ty_saida,
         pernr    TYPE pa0001-pernr,
         objps    TYPE pa0021-objps,
         fcnam    TYPE pa0021-fcnam,
         mail     TYPE pa0105-usrid_long,
       END OF ty_saida.

TYPES: BEGIN OF ty_log,
         pernr   TYPE pa0001-pernr,
         tipo    TYPE c LENGTH 1,
         fcnam   TYPE pa0021-fcnam,
         msg     TYPE pa0105-usrid,
       END OF ty_log.

************************************************************************
*** TABELAS INTERNAS
************************************************************************
DATA: gt_pa0105 TYPE STANDARD TABLE OF pa0105,    "Comunicação
      gt_pa0021 TYPE STANDARD TABLE OF pa0021,    "Dependentes
      gt_pa0397 TYPE STANDARD TABLE OF pa0397,    "Extensão dependetes
      gt_saida  TYPE STANDARD TABLE OF ty_saida,
      gt_log    TYPE STANDARD TABLE OF ty_log.

************************************************************************
*** ESTRUTURAS
************************************************************************
DATA: gs_pa0105 TYPE pa0105,    "Comunicação
      gs_pa0021 TYPE pa0021,    "Dependentes
      gs_pa0397 TYPE pa0397,    "Extensão dependetes
      gs_saida  TYPE ty_saida,
      gs_log    TYPE ty_log.


************************************************************************
*** VARIÁVEIS E CONSTANTES
************************************************************************
DATA:   gv_data_min      TYPE pa0021-begda,
        gv_data_max      TYPE pa0021-begda.

CONSTANTS: gc_idade_max   TYPE i VALUE 18,                                        "Idade para requerer o CPF
           gc_titulo_mail TYPE sood1-objdes VALUE 'Pendência CPF do Dependente'.  "Assunto do E-mail

************************************************************************
*** RANGES
************************************************************************
RANGES: r_data_aniver  FOR pa0021-begda.

************************************************************************
*** SELECTION-SCREEN
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK a1 WITH FRAME TITLE text-001.
PARAMETERS: p_min   TYPE i.
SELECTION-SCREEN COMMENT 50(10) gv_d_1.
PARAMETERS: p_max   TYPE i.
SELECTION-SCREEN COMMENT 50(10) gv_d_2.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_log   AS CHECKBOX.          "Exibir ou não o Log
SELECTION-SCREEN END OF BLOCK a1.

************************************************************************
*** TOP-OF-PAGE
************************************************************************
TOP-OF-PAGE.

  SKIP.
  WRITE:/ sy-uline(110).
  WRITE:/ '|', 3'TIPO', 8'|',11'MATRÍCULA',22'|',36'DEPENDENTE',60'|',80'MENSAGEM',110'|'.
  WRITE:/ sy-uline(110).

************************************************************************
*** INITIALIZATION
************************************************************************
INITIALIZATION.
  gv_d_1 = 'dias'.
  gv_d_2 = 'dias'.
  p_min = 30.
  p_max = 90.
  p_log = 'X'.

************************************************************************
*** START-OF-SELECTION
************************************************************************
START-OF-SELECTION.

  PERFORM f_buca_data.
  PERFORM f_busca_dependentes.
  IF gt_saida IS INITIAL.
    MESSAGE e208(00) WITH text-002.
  ELSE.
    PERFORM f_envia_mail.
    IF p_log IS NOT INITIAL.
      PERFORM f_exibe_log.
    ENDIF.
  ENDIF.


************************************************************************
***                         FORMS UTILIZADOS                         ***
************************************************************************
************************************************************************
*** FORM.......: F_BUCA_DATA
*** DESCRIÇÃO..: Busca Data nas condições abaixo:
***              90 dias antes do dependente completar gc_idade_max
***              30 dias antes do dependente completar gc_idade_max
************************************************************************
FORM f_buca_data.
  DATA: lt_ano(4)  TYPE n.

  CLEAR: r_data_aniver[], gv_data_min, gv_data_max, lt_ano.

  lt_ano = sy-datum(4).
  SUBTRACT gc_idade_max FROM lt_ano.

  r_data_aniver-sign   = 'I'.
  r_data_aniver-option = 'BT'.
  CONCATENATE lt_ano '0101' INTO r_data_aniver-low.
  CONCATENATE lt_ano '1231' INTO r_data_aniver-high.
  APPEND r_data_aniver.

  gv_data_min = sy-datum + p_min.
  gv_data_max = sy-datum + p_max.
ENDFORM.                    "f_buca_data


************************************************************************
*** FORM.......: F_BUSCA_DEPENDENTES
*** DESCRIÇÃO..: Busca os dependentes que estão próximo a completar
***              gc_idade_max e que estão com o CPF vazio.
************************************************************************
FORM f_busca_dependentes.

  DATA: lv_data_aniver  TYPE pa0001-begda,
        lv_exit.

  CLEAR: lv_data_aniver, gs_pa0021, gt_pa0021[], gs_pa0397, gt_pa0397[].

*-- Busca os empregados que tem dependentes Filho e que estão no ano de completar 18 anos.
  SELECT * INTO TABLE gt_pa0021
    FROM pa0021
    WHERE subty EQ '2'
      AND begda LE sy-datum
      AND endda GE sy-datum
      AND fgbdt IN r_data_aniver.

  IF sy-subrc EQ 0.
*-- Busca os dependentes que estão com o CPF vazio
    SELECT * INTO TABLE gt_pa0397
      FROM pa0397
      FOR ALL ENTRIES IN gt_pa0021
      WHERE pernr EQ gt_pa0021-pernr
        AND subty EQ '2'
        AND begda LE sy-datum
        AND endda GE sy-datum
        AND icnum EQ ''.
  ENDIF.

*-- Busca os dependentes cuja data de aniversário antecede 30 dias ou 90 dias
  LOOP AT gt_pa0021 INTO gs_pa0021.
    lv_data_aniver    = gs_pa0021-fgbdt.
    lv_data_aniver(4) = sy-datum(4).

    IF  lv_data_aniver EQ gv_data_min.
      CLEAR lv_exit.
    ELSE.
      lv_data_aniver    = gs_pa0021-fgbdt.
      lv_data_aniver(4) = sy-datum(4).
      IF  lv_data_aniver EQ gv_data_max.
        CLEAR lv_exit.
      ELSE.
        lv_exit = 'X'.
      ENDIF.
    ENDIF.

*-- Preenche a tabela de saída com os e-mails
    IF lv_exit IS INITIAL.
      READ TABLE gt_pa0397 INTO gs_pa0397 WITH KEY pernr = gs_pa0021-pernr
                                                   objps = gs_pa0021-objps.
      IF sy-subrc EQ 0.
        CLEAR gs_saida.

        SELECT SINGLE usrid_long INTO gs_saida-mail
          FROM pa0105
          WHERE pernr EQ gs_pa0397-pernr
            AND subty EQ '0010'
            AND begda LE sy-datum
            AND endda GE sy-datum.

        gs_saida-pernr = gs_pa0397-pernr.
        gs_saida-objps = gs_pa0397-objps.
        gs_saida-fcnam = gs_pa0021-fcnam.
        APPEND gs_saida TO gt_saida.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "f_busca_cpf_vazio

************************************************************************
*** FORM.......: F_ENVIA_MAIL
*** DESCRIÇÃO..: Envia e-mail para o empregado
************************************************************************
FORM f_envia_mail.
  DATA: lt_mail_conteudo  TYPE STANDARD TABLE OF   soli,
        lt_destinatario    TYPE STANDARD TABLE OF  somlreci1.

  DATA: ls_destinatario    TYPE somlreci1.

  LOOP AT gt_saida INTO gs_saida.
    CLEAR: ls_destinatario, lt_destinatario[], gs_log, gs_pa0021.
    ls_destinatario-rec_type = 'U'.
    ls_destinatario-receiver = gs_saida-mail.
    APPEND ls_destinatario TO lt_destinatario.

    PERFORM f_conteudo_mail TABLES lt_mail_conteudo
                             USING  gs_saida-pernr gs_saida-fcnam.

    CALL FUNCTION 'ZHR_ENVIA_EMAIL'
      EXPORTING
        titulo        = gc_titulo_mail
        deliver       = space
        read          = space
      TABLES
        objcont       = lt_mail_conteudo
        t_email       = lt_destinatario
      EXCEPTIONS
        error_message = 1
        OTHERS        = 2.

    IF sy-subrc EQ 0.
      gs_log-tipo = 'S'.
      gs_log-msg = 'E-mail enviado com sucesso.'.
    ELSE.
      gs_log-tipo = 'E'.
      gs_log-msg  = 'Problema no envio do e-mail.'.
    ENDIF.
    gs_log-pernr = gs_saida-pernr.
    gs_log-fcnam = gs_saida-fcnam.
    APPEND gs_log TO gt_log.
  ENDLOOP.
ENDFORM.                    "f_envia_mail

************************************************************************
*** FORM.......: F_CONTEUDO_MAIL
*** DESCRIÇÃO..: Monta o conteúdo do corpo do e-mail
************************************************************************
FORM f_conteudo_mail TABLES pt_mail_conteudo STRUCTURE soli
                      USING pu_pernr         TYPE ty_saida-pernr
                            pu_fcnam         TYPE pa0021-fcnam.

  DATA: ls_email_conteudo  TYPE soli,
        lv_nome            TYPE pa0001-ename.

  CLEAR: pt_mail_conteudo[], ls_email_conteudo.

  SELECT SINGLE ename INTO lv_nome
    FROM pa0001
    WHERE pernr EQ pu_pernr
      AND begda LE sy-datum
      AND endda GE sy-datum.

  ls_email_conteudo = 'Prezado (a),'.
  APPEND ls_email_conteudo TO pt_mail_conteudo.

  CLEAR ls_email_conteudo.
  APPEND ls_email_conteudo TO pt_mail_conteudo.

  TRANSLATE pu_fcnam TO UPPER CASE.
  TRANSLATE lv_nome TO UPPER CASE.

  CONCATENATE 'Informamos ao empregado' pu_pernr INTO ls_email_conteudo SEPARATED BY space.
  CONCATENATE ls_email_conteudo '(' lv_nome ')'  INTO ls_email_conteudo.
  CONCATENATE ls_email_conteudo 'que o(a) dependente' INTO ls_email_conteudo.
  CONCATENATE ls_email_conteudo pu_fcnam INTO ls_email_conteudo SEPARATED BY space.
  CONCATENATE ls_email_conteudo 'está completando 18 anos e que é necessário cadastrar o seu CPF nos seus dados de RH.' INTO ls_email_conteudo SEPARATED BY space.
  APPEND ls_email_conteudo TO pt_mail_conteudo.

  ls_email_conteudo = 'Gentileza comparecer à Administração de Pessoal para sanar essa pendência.'.
  APPEND ls_email_conteudo TO pt_mail_conteudo.

  CLEAR ls_email_conteudo.
  APPEND ls_email_conteudo TO pt_mail_conteudo.

  ls_email_conteudo = 'Atenciosamente'.
  APPEND ls_email_conteudo TO pt_mail_conteudo.

  ls_email_conteudo = 'Equipe RH'.
  APPEND ls_email_conteudo TO pt_mail_conteudo.

ENDFORM.                    "f_conteudo_mail

************************************************************************
*** FORM.......: F_EXIBE_LOG
*** DESCRIÇÃO..: Exibe Log de Saída
************************************************************************
FORM f_exibe_log.

  LOOP AT gt_log INTO gs_log.
    IF gs_log-tipo EQ 'E'.
      FORMAT COLOR COL_NEGATIVE INTENSIFIED OFF.
    ELSE.
      FORMAT COLOR COL_POSITIVE INTENSIFIED OFF.
    ENDIF.

    WRITE:/ '|',4 gs_log-tipo,  8'|',
              10 gs_log-pernr,22'|',
              24 gs_log-fcnam,60'|',
              62 gs_log-msg ,110'|'.
  ENDLOOP.
  WRITE:/ sy-uline(110).

ENDFORM.                    "f_exibe_log