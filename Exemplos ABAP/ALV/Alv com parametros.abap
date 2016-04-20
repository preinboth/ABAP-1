*&---------------------------------------------------------------------*
*& Report  ZSK_ABAP105
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZSK_ABAP105.

DATA: IT_SFLIGHT  TYPE TABLE OF SFLIGHT,
      IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      WA_FIELDCAT LIKE LINE OF IT_FIELDCAT.

INITIALIZATION.

  SELECT * FROM SFLIGHT INTO TABLE IT_SFLIGHT
    UP TO 50 ROWS.

  PERFORM MONTA_FIELDCAT.
  PERFORM MOSTRA_ALV.

*&---------------------------------------------------------------------*
*&      Form  monta_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MONTA_FIELDCAT.


  PERFORM ADD_FCAT USING:  1 'CARRID' 'X' 'X' 5  'Companhia Aйrea' 'Comp. Aйrea' 'C.Aйrea',
                           2 'CONNID' 'X' 'X' 5  'Conexгo de Voo'  'Conex. Voo'  'C. Voo',
                           3 'FLDATE' 'X' 'X' 10 'Data do Voo'     'Data. Voo'   'Data',
                           4 'PRICE'  ''  ''  15  'Preзo do Voo'    'Preзo. Voo'  'Preзo'.

ENDFORM.                    "MONTA_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  ADD_FCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM ADD_FCAT USING in_col_pos
                    in_fieldname
                    in_emphasize
                    in_fix_column
                    in_outputlen
                    in_seltext_l
                    in_seltext_m
                    in_seltext_s.


  CLEAR WA_FIELDCAT.
  WA_FIELDCAT-COL_POS    = in_col_pos. "Posiзгo Coluna
  WA_FIELDCAT-FIELDNAME  = in_fieldname. "Sempre maiusculo
  WA_FIELDCAT-EMPHASIZE  = in_emphasize. "Enfase
  WA_FIELDCAT-FIX_COLUMN = in_fix_column. "Fixar Coluna
  WA_FIELDCAT-OUTPUTLEN  = in_outputlen. "Comprimento de Saida
  WA_FIELDCAT-SELTEXT_L  = in_seltext_l. "Descriзгo Long
  WA_FIELDCAT-SELTEXT_M  = in_seltext_m. "Descriзгo Medium
  WA_FIELDCAT-SELTEXT_S  = in_seltext_s. "Descriзгo Short
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

ENDFORM.                    "ADD_FCAT

*&---------------------------------------------------------------------*
*&      Form  mostra_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM MOSTRA_ALV.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      IT_FIELDCAT   = IT_FIELDCAT
    TABLES
      T_OUTTAB      = IT_SFLIGHT
    EXCEPTIONS
      PROGRAM_ERROR = 1
      OTHERS        = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.

ENDFORM.                    "mostra_alv