FUNCTION HRVE_LAST_DAY_OF_MONTH.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(I_DATUM) LIKE  P0001-BEGDA
*"  EXPORTING
*"     VALUE(E_KZ_ULT)
*"     VALUE(E_TT)
*"----------------------------------------------------------------------

  DATA: DATMM TYPE I,
        DATJJ TYPE I,
        REST  TYPE I,
        ZW_TT TYPE I.

  CLEAR: E_KZ_ULT, E_TT.

  DATMM = I_DATUM+4(2).

  CASE DATMM.
    WHEN 1.  ZW_TT = 31.
    WHEN 2.  ZW_TT = 28.
    WHEN 3.  ZW_TT = 31.
    WHEN 4.  ZW_TT = 30.
    WHEN 5.  ZW_TT = 31.
    WHEN 6.  ZW_TT = 30.
    WHEN 7.  ZW_TT = 31.
    WHEN 8.  ZW_TT = 31.
    WHEN 9.  ZW_TT = 30.
    WHEN 10. ZW_TT = 31.
    WHEN 11. ZW_TT = 30.
    WHEN 12. ZW_TT = 31.
  ENDCASE.

  IF DATMM = 2.
    DATJJ = I_DATUM+0(4).
    REST  = DATJJ MOD 4.
    IF REST = 0.
      ZW_TT = 29.
    ENDIF.
  ENDIF.

  IF NOT ZW_TT IS INITIAL.
    IF I_DATUM+6(2) = ZW_TT.
      E_KZ_ULT = 'X'.
    ENDIF.
  ENDIF.

  E_TT = ZW_TT.

ENDFUNCTION.