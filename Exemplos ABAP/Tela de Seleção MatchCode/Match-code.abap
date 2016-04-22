
TYPES: BEGIN OF ty_f4,
         DESCR     TYPE zhr_conta_adia-DESCR,
         ID_ADIANT TYPE zhr_conta_adia-ID_ADIANT,
         SEQ       TYPE zhr_conta_adia-SEQ,
         RUB_CRED  TYPE zhr_conta_adia-RUB_CRED,
         RUB_DEB   TYPE zhr_conta_adia-RUB_DEB,
       END OF ty_f4.
DATA: t_f4  TYPE STANDARD TABLE OF ty_f4 WITH HEADER LINE,
      t_ret TYPE STANDARD TABLE OF ty_f4 WITH HEADER LINE.

PARAMETER: p_descr TYPE zhr_conta_adia-descr.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_descr.
    t_f4-ID_ADIANT  = 01.
    t_f4-SEQ        = 003.
    t_f4-DESCR      = 'Teste teste etestete'.
    t_f4-RUB_CRED   = '9541'.
    t_f4-RUB_DEB    = '0021'.
  DO 9 TIMES.
    APPEND t_f4.
  ENDDO.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
*     DDIC_STRUCTURE         = ' '
      retfield               = 'DESCR'
*     PVALKEY                = ' '
      DYNPPROG               = SY-REPID
      DYNPNR                 = SY-DYNNR
      DYNPROFIELD            = 'P_DESCR'
*     STEPL                  = 0
*     WINDOW_TITLE           =
*     VALUE                  = ' '
      VALUE_ORG              = 'S'
*     MULTIPLE_CHOICE        = ' '
*     DISPLAY                = ' '
*     CALLBACK_PROGRAM       = ' '
*     CALLBACK_FORM          = ' '
*     MARK_TAB               =
*   IMPORTING
*     USER_RESET             =
    tables
      value_tab              = t_f4
*     FIELD_TAB              =
*      RETURN_TAB             = t_ret
*     DYNPFLD_MAPPING        =
    EXCEPTIONS
      PARAMETER_ERROR        = 1
      NO_VALUES_FOUND        = 2
      OTHERS                 = 3
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

