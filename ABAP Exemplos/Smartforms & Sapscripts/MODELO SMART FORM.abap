*&---------------------------------------------------------------------*
*  Work Areas
*&---------------------------------------------------------------------*
DATA: ls_cabecalho      LIKE LINE OF zst_cabeçalho,
		  ls_itens      LIKE LINE OF zst_tabela_itens.

DATA: lt_itens			TYPE TABLE OF zst_tabela_itens.
		
* Smart Form ----
DATA: v_control  TYPE ssfctrlop,
			v_name     TYPE rs38l_fnam.
	
		
PERFORM f_open_smart.

LOOP AT lt_documentos INTO ls_documentos.

** >>>> Montar Tabela de Itens....<<<< 
** A cada Cabeçalho, voce irá preencher sua tabela de Itens,
** Assim voce irá passar para o Smart Form a WorkArea do Cabeçalho com a Tabela dos Itens correspondentes.
	PERFORM f_call_smart.

	REFRESH lt_itens.
	CLEAR ls_documentos.

ENDLOOP.

PERFORM f_close_smart.
*&---------------------------------------------------------------------*
*&      Form  F_OPEN_SMART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_open_smart .

	v_control-no_dialog = ' '.
	v_control-preview   = 'X'.
	v_control-no_open   = 'X'.
	v_control-no_close  = 'X'.
*
	CALL FUNCTION 'SSF_OPEN'
		EXPORTING
			control_parameters = v_control
		EXCEPTIONS
			formatting_error   = 1
			internal_error     = 2
			send_error         = 3
			user_canceled      = 4
			OTHERS             = 5.
	.
	IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
	ENDIF.

* Retorna o nome do modulo de função para o Smart Form
	CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
		EXPORTING
			formname           = 'ZFMM_VAL_FINANC_CONTRATOS'
		IMPORTING
			fm_name            = v_name
		EXCEPTIONS
			no_form            = 1
			no_function_module = 2
			OTHERS             = 3.
	IF sy-subrc <> 0.
*    RAISE erro_exec.
		EXIT.
	ENDIF.

ENDFORM.                    " F_OPEN_SMART

*&---------------------------------------------------------------------*
*&      Form  F_CLOSE_SMART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_close_smart .

	CALL FUNCTION 'SSF_CLOSE'
		EXCEPTIONS
			formatting_error = 1
			internal_error   = 2
			send_error       = 3
			OTHERS           = 4.

	IF sy-subrc <> 0.
		MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
		WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
	ENDIF.

ENDFORM.                    " F_CLOSE_SMART

*&---------------------------------------------------------------------*
*&      Form  F_CALL_SMART
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_call_smart .

	DATA: t_erev LIKE erev OCCURS 0.

* Chama o modulo de função que gera o smart form
	CALL FUNCTION v_name
		EXPORTING
			control_parameters = v_control
			ls_cabecalho       = ls_cabecalho
		TABLES
			lt_itens            = lt_itens
		EXCEPTIONS
			formatting_error   = 1
			internal_error     = 2
			send_error         = 3
			user_canceled      = 4
			OTHERS             = 5.
	IF sy-subrc <> 0.
*    MESSAGE e002(zpm01) WITH sy-subrc.
	ENDIF.

ENDFORM.                    " F_CALL_SMART