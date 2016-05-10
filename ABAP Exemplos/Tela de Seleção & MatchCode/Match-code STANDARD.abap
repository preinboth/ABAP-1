Colocar break-point na função HELP_START, para ter as opções da help_info.

PROCESS ON VALUE-REQUEST.
  FIELD ti_zorcamento_fase-PROJN MODULE f4_help_projn.

MODULE f4_help_projn INPUT.
  DATA: help_infos_projn   TYPE  help_info,
        dynpselect_projn   TYPE STANDARD TABLE OF  dselc,
        dynpvaluetab_projn TYPE STANDARD TABLE OF  dval,
        select_value_projn TYPE help_info-fldvalue.


  help_infos_projn-call       = 'T'.
  help_infos_projn-object     = 'F'.
  help_infos_projn-program    = sy-cprog.
  help_infos_projn-dynpro     = sy-dynnr.
*  help_infos-tabname    = 'KOMG'.
*  help_infos-fieldname  = 'SRVPOS'.
  help_infos_projn-tabname    = 'CAUFVD'.
  help_infos_projn-fieldname  = 'PROJN'.
  help_infos_projn-spras      = sy-langu.
  help_infos_projn-title      = vg_titulo.
  help_infos_projn-dynprofld  = 'TI_ZORCAMENTO_FASE-PROJN'.
  help_infos_projn-checktable = 'PRPS'.
  help_infos_projn-checkfield = 'PSPNR'.
  help_infos_projn-tcode      = sy-tcode.
  help_infos_projn-pfkey      =  '02120A*'.     "'00H'.

  CALL FUNCTION 'DD_SHLP_CALL_FROM_DYNP'
    EXPORTING
      help_infos   = help_infos_projn
    IMPORTING
      select_value = select_value_projn
    TABLES
      dynpselect   = dynpselect_projn
      dynpvaluetab = dynpvaluetab_projn.

  ti_zorcamento_fase-projn = select_value_projn.

ENDMODULE.                 " F4_HELP_PROJN  INPUT