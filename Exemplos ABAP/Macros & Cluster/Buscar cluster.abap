
FORM f_seleciona_cluster .

  CLEAR: v_tabix, v_data.

  MOVE p_ano TO v_cacsyear.
  MOVE p_mes TO v_cacsmonth.

  LOOP AT it_pa0001 INTO wa_pa0001.

    v_tabix = sy-tabix.

    CLEAR: t_in_rgdir[], t_in_rgdir,
           t_in_rgdir_aux[], t_in_rgdir_aux,
           py_result, py_result_aux.

    CONCATENATE p_ano p_mes INTO v_data.


    tg_out-ename  = wa_pa0001-ename.
    tg_out-pernr  = wa_pa0001-pernr.
    tg_out-kostl  = wa_pa0001-kostl.
    tg_out-dat01  = wa_pa0001-dat01.
    tg_out-begda  = wa_pa0001-begda.
    APPEND tg_out.

    CLEAR: v_relid, v_molga.


    "BUSCA DO INFORMAÇÕES DO FUNCIONÁRIO PARA LEITURA DO CLUSTER
    CALL FUNCTION 'PYXX_GET_RELID_FROM_PERNR'
      EXPORTING
        employee                    = wa_pa0001-pernr
      IMPORTING
        relid                       = v_relid "IDENTIFICAÇÃO DE ÁREA PARA CLUSTER NAS TABELAS PCLX
        molga                       = v_molga "AGRUPAMENTO DE PAÍSES
      EXCEPTIONS
        error_reading_infotype_0001 = 1
        error_reading_molga         = 2
        error_reading_relid         = 3
        OTHERS                      = 4.


    "LEITURA DO RESULTADO DA FOLHA
    CALL FUNCTION 'CU_READ_RGDIR'
      EXPORTING
        persnr          = wa_pa0001-pernr
      IMPORTING
        molga           = v_molga
      TABLES
        in_rgdir        = t_in_rgdir
      EXCEPTIONS
        no_record_found = 1
        OTHERS          = 2.


    SORT t_in_rgdir BY fpbeg DESCENDING.

* Cristiane Borlini - 2012-0242 - Início
*    LOOP AT t_in_rgdir WHERE fpbeg(6)   = v_data
*                       AND   srtza   = 'A'
*                       and   OCRSN = ''.

    LOOP AT t_in_rgdir WHERE fpbeg(6) = v_data
                         AND ocrsn = ''.

      IF t_in_rgdir-fpper = t_in_rgdir-inper.

* Cristiane Borlini - 2012-0242 - Fim
        CALL FUNCTION 'PYXX_READ_PAYROLL_RESULT'
          EXPORTING
            clusterid                    = v_relid
            employeenumber               = wa_pa0001-pernr
            sequencenumber               = t_in_rgdir-seqnr
          CHANGING
            payroll_result               = py_result
          EXCEPTIONS
            illegal_isocode_or_clusterid = 1
            error_generating_import      = 2
            import_mismatch_error        = 3
            subpool_dir_full             = 4
            no_read_authority            = 5
            no_record_found              = 6
            versions_do_not_match        = 7
            error_reading_archive        = 8
            error_reading_relid          = 9
            OTHERS                       = 10.

        IF sy-subrc EQ 0.
          IF p_rb_s13 EQ 'X' OR p_rb_lp EQ 'X' OR p_rb_r13  EQ 'X'.
            PERFORM f_calculo_mes_atual_1.
          ELSEIF p_rb_pf EQ 'X'.
            PERFORM f_calculo_mes_atual_2.
          ELSEIF p_rb_rf EQ 'X'.
            PERFORM f_calculo_3.
          ENDIF.

        ENDIF.

      ENDIF.

    ENDLOOP.
* Cristiane Borlini - 2012-0242 - Fim

    CLEAR: t_in_rgdir_aux, t_in_rgdir_aux[],
           v_cacsmonth, v_dias.

    t_in_rgdir_aux[] = t_in_rgdir[].

    SORT t_in_rgdir_aux BY fpbeg DESCENDING.

** Separando calculo por tipo de provisão
    IF p_rb_s13 EQ 'X' OR p_rb_lp EQ 'X' OR p_rb_r13  EQ 'X'.
      PERFORM f_calculo_mes_anterior_1.
    ELSEIF p_rb_pf EQ 'X'.
      PERFORM f_calculo_mes_anterior_2.
    ENDIF.


    CLEAR: v_lgartmp02_acum,
           v_lgartmp12_acum,
           v_lgartmp22_acum,
           v_lgartmp06_acum,
           v_lgartmp16_acum,
           v_lgartmp62_acum,
           v_lgartmp82_acum,
           v_lgartmp87_acum,
           v_lgartmp72_acum,
           v_lgartmp77_acum,
           v_lgartmp67_acum,
           v_lgartmp26_acum,
           v_lgart4123_acum,
           v_lgart4163_acum,
           v_lgart4153_acum,
           tg_out,
           wa_rt_aux,
           wa_rt,
           v_mf04, v_mf08,
           v_mp81, v_mp82,
           v_mp71, v_mp72.


  ENDLOOP.

ENDFORM.                    " F_SELECIONA_CLUSTER


LOOP AT py_result-inter-rt INTO wa_rt.
