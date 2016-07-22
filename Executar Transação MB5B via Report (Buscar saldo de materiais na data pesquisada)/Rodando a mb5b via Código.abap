*&---------------------------------------------------------------------*
*& Report  ZRMB5B
*&
*&---------------------------------------------------------------------*
*&
*&Buscar dados para relatório, chamado a mb5b (Preciso buscar a data de um material na data pesquisada)
*&---------------------------------------------------------------------*

REPORT zrmb5b.

TYPES: BEGIN OF ty_saida,
        werks TYPE bseg-werks,
        matnr TYPE mara-matnr,
        labst TYPE c LENGTH 40,
       END OF ty_saida.

DATA t_saida TYPE STANDARD TABLE OF ty_saida WITH HEADER LINE.


TYPES:  BEGIN OF y_asci,
          linha TYPE c LENGTH 1024,
        END OF y_asci.


DATA: t_asci      TYPE STANDARD TABLE OF y_asci     WITH HEADER LINE,
      t_abaplist  TYPE STANDARD TABLE OF abaplist   WITH HEADER LINE.

DATA: vc_labst    TYPE c LENGTH 50,
      v_labst     TYPE mard-labst.

DATA t_mbew TYPE STANDARD TABLE OF mbew WITH HEADER LINE.

REFRESH: t_mbew, t_saida.

data lc_date type sy-datum.

lc_date = '20160630'.


PARAMETERS p_teste type c.



START-OF-SELECTION.

*BREAK-POINT .

  SELECT * FROM mbew INTO TABLE t_mbew WHERE bwkey = 'H006'.

  LOOP AT t_mbew.

    SUBMIT  rm07mlbd
          WITH  matnr       EQ t_mbew-matnr
          WITH  burks       EQ '1000'
          WITH  werks       EQ 'H006'
*        WITH  lgort       EQ 'DP01'
          WITH  datum-low       EQ  lc_date
          WITH  datum-high       EQ  lc_date
          WITH  p_value1    EQ  space
          WITH  p_value2    EQ 'X' EXPORTING LIST TO MEMORY AND RETURN.

    CALL FUNCTION 'LIST_FROM_MEMORY'
      TABLES
        listobject = t_abaplist
      EXCEPTIONS
        not_found  = 1
        OTHERS     = 2.

    IF NOT t_abaplist[] IS INITIAL.

      CALL FUNCTION 'LIST_TO_ASCI'
        TABLES
          listasci           = t_asci
          listobject         = t_abaplist
        EXCEPTIONS
          empty_list         = 1
          list_index_invalid = 2
          OTHERS             = 3.

      CALL FUNCTION 'LIST_FREE_MEMORY'
        TABLES
          listobject = t_abaplist
        EXCEPTIONS
          OTHERS     = 99.

      READ TABLE t_asci INDEX 6.
      IF sy-subrc EQ 0.
        CLEAR vc_labst.
*        vc_labst = t_asci+29(20).
        vc_labst = t_asci+29(37).
        CONDENSE vc_labst.
      ENDIF.

    ENDIF.

    CLEAR t_saida.
    t_saida-werks = 'H006'.
    t_saida-matnr = t_mbew-matnr.
    t_saida-labst = vc_labst.

    APPEND t_saida.

    FREE: t_abaplist,
          t_asci.

  ENDLOOP.

  end-of-SELECTION.

LOOP AT t_saida.

  write:/ t_saida-werks, t_saida-matnr, t_saida-labst.

ENDLOOP.
