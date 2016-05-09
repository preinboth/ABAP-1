*&---------------------------------------------------------------------*
*&      Form  Z_SAVE_ATTCHM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_INPUT  text
*
*Código Fonte Útil - Salvar anexo na MIRO (Ou em qualquer transação Standard) 
* com GOS
*
*
*----------------------------------------------------------------------*
FORM z_save_attchm  USING    p_input  TYPE zmt_elaw_pagamento_req
                             p_output TYPE zmt_elaw_pagamento_resp.

  DATA: lt_anexos TYPE TABLE OF zdt_elaw_pagamento_req_anexo,
        w_anexo   TYPE zdt_elaw_pagamento_req_anexo.

  DATA: lv_nome      TYPE string,
        lv_xregistro TYPE xstring,
        lv_exten(3),
        lv_retorno.

**********************************************************************
* Variáveis para Importação de Arquivos para ANEXO GOS. 
  DATA: v_botype TYPE obl_s_pbor-typeid  VALUE 'BUS2081', ”MIRO
        v_docty  TYPE borident-objtype   VALUE 'MESSAGE',
        v_reltyp TYPE breltyp-reltype    VALUE 'ATTA',
        v_msgtyp TYPE sofm-doctp         VALUE 'EXT'.


  TYPES: BEGIN OF ty_message_key,
           foltp TYPE so_fol_tp,
           folyr TYPE so_fol_yr,
           folno TYPE so_fol_no,
           doctp TYPE so_doc_tp,
           docyr TYPE so_doc_yr,
           docno TYPE so_doc_no,
           fortp TYPE so_for_tp,
           foryr TYPE so_for_yr,
           forno TYPE so_for_no,
        END OF ty_message_key.


  TYPES : BEGIN OF ty_binary,
            binary_field(255) TYPE c,
          END OF ty_binary.


  TYPES: BEGIN OF ty_files,
     file_name TYPE ztbmm096-file_name,
     size      TYPE eps2fili-size,
    END OF ty_files.


  DATA: lt_binary         TYPE TABLE OF ty_binary WITH HEADER LINE,
        lt_brelattr       TYPE TABLE OF brelattr  WITH HEADER LINE,
        w_gbinrel         TYPE gbinrel,
        lv_message_key    TYPE ty_message_key,
        lo_message        TYPE swc_object,
        lv_doc_size       TYPE i,
        lv_dockey         TYPE swo_typeid.


  DATA: lo_is_object_a TYPE borident,
        lo_is_object_b TYPE borident.
**********************************************************************

  " Se documento foi criado
  CHECK gv_invoicedocnumber IS NOT INITIAL.

  lt_anexos = p_input-mt_elaw_pagamento_req-t_anexos-anexo.

  LOOP AT lt_anexos INTO w_anexo.

    CLEAR: lv_nome,
           lv_exten,
           lv_message_key,
           lv_xregistro.

    REFRESH: lt_binary.


* Identifica formato do arquivo (Nome do arquivo)
    SPLIT w_anexo-nome_anexo AT '.' INTO lv_nome lv_exten.
    TRANSLATE lv_exten TO UPPER CASE.

* Create an initial instance of BO 'MESSAGE'
    swc_create_object lo_message 'MESSAGE' lv_message_key.

* define container to pass the parameter values to the method call
    swc_container lt_message_container.


* Populate container with parameters for method
    swc_set_element lt_message_container 'DOCUMENTTITLE' w_anexo-nome_anexo.
    swc_set_element lt_message_container 'DOCUMENTLANGU' 'E'.
    swc_set_element lt_message_container 'NO_DIALOG'     'X'.
    swc_set_element lt_message_container 'DOCUMENTNAME'  v_docty.
    swc_set_element lt_message_container 'DOCUMENTTYPE'  v_msgtyp.
    swc_set_element lt_message_container 'FILEEXTENSION' lv_exten.

    "Converte o Hexadecimal do Anexo para Maiusculo, para compatibildiade no SAP.
    TRANSLATE w_anexo-registro TO UPPER CASE.
    lv_xregistro = w_anexo-registro.

* Convert o Hexadecimal para Binário.
    CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
      EXPORTING
        buffer        = lv_xregistro
      IMPORTING
        output_length = lv_doc_size
      TABLES
        binary_tab    = lt_binary.

    swc_set_table      lt_message_container 'DocumentContent' lt_binary.
    swc_set_element    lt_message_container 'DOCUMENTSIZE'    lv_doc_size.
    swc_refresh_object lo_message.
    swc_call_method    lo_message           'CREATE'          lt_message_container.
    swc_get_object_key lo_message           lv_message_key.

    "Document Key (MIRO = Documento + Ano)
    CONCATENATE: p_output-mt_elaw_pagamento_resp-documento_sap
                 p_output-mt_elaw_pagamento_resp-ano
            INTO lv_dockey.

* Create main BO object_a
    lo_is_object_a-objkey  = lv_dockey.
    lo_is_object_a-objtype = v_botype.
*      lo_is_object_a-logsys  = sy-sysid.


* Create attachment BO object_b
    lo_is_object_b-objkey  = lv_message_key.
    lo_is_object_b-objtype = v_docty.
*      lo_is_object_b-logsys  = sy-sysid.

    "Cria relação Documento x Objeto
    CALL FUNCTION 'BINARY_RELATION_CREATE_COMMIT'
      EXPORTING
        obj_rolea      = lo_is_object_a
        obj_roleb      = lo_is_object_b
        relationtype   = v_reltyp
      IMPORTING
        binrel         = w_gbinrel
      TABLES
        binrel_attrib  = lt_brelattr
      EXCEPTIONS
        no_model       = 1
        internal_error = 2
        unknown        = 3
        OTHERS         = 4.

    IF sy-subrc EQ 0.
      COMMIT WORK AND WAIT.

      CLEAR w_retorno.
      w_retorno-tipo_retorno = 'S'.
      CONCATENATE: 'Anexo:' w_anexo-nome_anexo 'gravado com sucesso.'
             INTO w_retorno-msg_retorno SEPARATED BY space.
      APPEND w_retorno TO p_output-mt_elaw_pagamento_resp-tab_retorno-linha.

    ELSE.

      CLEAR w_retorno.
      w_retorno-tipo_retorno = 'E'.
      CONCATENATE: 'Erro na gravação do Anexo:' w_anexo-nome_anexo
             INTO w_retorno-msg_retorno SEPARATED BY space.
      APPEND w_retorno TO p_output-mt_elaw_pagamento_resp-tab_retorno-linha.

    ENDIF.

  ENDLOOP.


  CLEAR: v_botype,
         v_docty ,
         v_reltyp,
         v_msgtyp,
         lt_binary[],
         lv_message_key,
         lo_message,
         lv_doc_size,
         lo_is_object_a,
         lo_is_object_b.

ENDFORM.                    " Z_SAVE_ATTCHM
