Cliente - João Dias

FUNCTION zdh_document_text.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     VALUE(LINE_BKPF) TYPE  BKPF
*"     VALUE(LINE_BSEG) TYPE  BSEG
*"     VALUE(HLP_TEXT) TYPE  CHAR100
*"----------------------------------------------------------------------
  DATA: v_docnum TYPE j_1bnfdoc-docnum,
        v_nfenum TYPE j_1bnfdoc-nfenum,
        v_sgtxt  TYPE  c LENGTH 50.

  DATA: ls_bseg   TYPE bseg,
        lt_buztab TYPE TABLE OF tpit_buztab,
        ls_buztab TYPE tpit_buztab,
        ls_fldtab TYPE tpit_fname,
        lt_fldtab TYPE TABLE OF tpit_fname,
        it_errtab TYPE tpit_t_errdoc WITH HEADER LINE.

  DATA wa_bkpf TYPE bkpf.
  IF sy-uname EQ 'F9T0064'.
    DO .

    ENDDO.
  ENDIF.
  DO 120 TIMES.
    WAIT UP TO 1 SECONDS.

    SELECT docnum UP TO 1 ROWS
      INTO v_docnum
      FROM j_1bnflin
      WHERE refkey = line_bkpf-belnr.
    ENDSELECT.

    IF NOT v_docnum IS INITIAL.
      SELECT SINGLE nfenum
        INTO v_nfenum
        FROM j_1bnfdoc
        WHERE docnum = v_docnum.
      IF sy-subrc = 0.
        EXIT.
      ENDIF.
    ENDIF.
  ENDDO.

  IF v_nfenum IS NOT INITIAL.

    SELECT SINGLE *
      INTO  wa_bkpf
    FROM bkpf
    WHERE
      awtyp EQ 'VBRK'AND
      awkey EQ line_bkpf-belnr.

    IF sy-subrc EQ 0.
      SELECT SINGLE *
        INTO ls_bseg
      FROM bseg
      WHERE
        bukrs EQ wa_bkpf-bukrs AND
        belnr EQ wa_bkpf-belnr AND
        gjahr EQ wa_bkpf-gjahr AND
*        shkzg EQ line_bseg-shkzg AND
        hkont EQ line_bseg-hkont.
      IF sy-subrc EQ 0.
        CONCATENATE hlp_text v_nfenum INTO ls_bseg-sgtxt SEPARATED BY ' '.

        CLEAR: ls_buztab.
        REFRESH: lt_buztab.

        MOVE-CORRESPONDING ls_bseg TO ls_buztab.
        APPEND ls_buztab TO lt_buztab.

        REFRESH lt_fldtab.
        CLEAR   ls_fldtab.

        MOVE 'SGTXT' TO ls_fldtab-fname. "Campo
        MOVE 'X'     TO ls_fldtab-aenkz. "Flag modificação
        APPEND ls_fldtab TO lt_fldtab.

        "Executa BAPI p/ alteração do item do Doc. Contábil
        CALL FUNCTION 'FI_ITEMS_MASS_CHANGE'
          EXPORTING
            s_bseg     = ls_bseg
          IMPORTING
            errtab     = it_errtab[]
          TABLES
            it_buztab  = lt_buztab
            it_fldtab  = lt_fldtab
          EXCEPTIONS
            bdc_errors = 1
            OTHERS     = 2.

        IF sy-subrc EQ 0.
          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
            EXPORTING
              wait = 'X'.

        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFUNCTION.
