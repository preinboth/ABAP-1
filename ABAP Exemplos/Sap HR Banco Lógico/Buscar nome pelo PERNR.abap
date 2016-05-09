Função ZHRF_DIRF_EMPLOYEE_READ => Cesan



function zhrf_dirf_employee_read.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(I_PERNR) TYPE  PERNR_D
*"     REFERENCE(I_BEGDA) TYPE  BEGDA
*"     REFERENCE(I_ENDDA) TYPE  ENDDA
*"  EXPORTING
*"     REFERENCE(E_HOLDER) TYPE  HRPAYBR_S_DIRF_2010_HOLDER_PSE
*"----------------------------------------------------------------------


  data: p0002       type standard table of p0002,
        p0465       type standard table of p0465.

  data: ls_p0002    type p0002,
        ls_p0465    type p0465.

  data: lv_name     type text100,
        rv_name     type string,
        rv_cpf      type pbr_cpfnr,
        lv_retcode  type sy-subrc.

  call function 'HR_INITIALIZE_BUFFER'.

  "Seleciona Infotipo 0002 (Dados pessoais)
  clear p0002[].
  call function 'HR_READ_INFOTYPE'
    exporting
      pernr           = i_pernr
      infty           = '0002'
      begda           = i_begda
      endda           = i_endda
    tables
      infty_tab       = p0002
    exceptions
      infty_not_found = 1
      others          = 2.

  loop at p0002 into ls_p0002
    where begda <= i_endda
      and endda >= i_begda.
  endloop.

  "Seleciona Infotipo 0465 (Documentos)
  clear p0465[].
  call function 'HR_READ_INFOTYPE'
    exporting
      pernr           = i_pernr
      infty           = '0465'
      begda           = i_begda
      endda           = i_endda
    tables
      infty_tab       = p0465
    exceptions
      infty_not_found = 1
      others          = 2.

  "Nome do empregado
  call function 'RP_EDIT_NAME'
    exporting
      format    = '01'
      langu     = sy-langu
      molga     = pbr99_molga
      pp0002    = ls_p0002
    importing
      edit_name = lv_name
      retcode   = lv_retcode.

  if lv_retcode = 0.
    "Converte acentos de texto para caracteres normais
    rv_name = lv_name.
    call function 'HR_BR_CONVERT_ACCENTS'
      exporting
        in_text             = lv_name
        sw_strip_colon      = 'X'
      importing
        out_text            = rv_name
      exceptions
        cannot_convert      = 1
        langu_not_supported = 2
        others              = 3.
  endif.

  "Seleciona o CPF
  loop at p0465 into ls_p0465
    where subty  = '0001'
      and begda <= i_endda
      and endda >= i_begda.
    rv_cpf = ls_p0465-cpf_nr.
  endloop.

  e_holder-holder-rec_id = 'TPSE'.
  e_holder-holder-cpf    = rv_cpf.
  e_holder-holder-name   = rv_name.

endfunction.