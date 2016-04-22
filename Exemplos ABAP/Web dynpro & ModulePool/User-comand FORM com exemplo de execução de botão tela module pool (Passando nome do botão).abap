FORM user-command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  DATA: lv_tabix TYPE sy-tabix,
        lv_count TYPE i.

  CASE r_ucomm.
    WHEN '&EXEC'.

      READ TABLE gt_relatorio INTO wa_relatorio WITH KEY sel    = 'X'
                                                         icon   = icon_led_green.

      IF sy-subrc IS INITIAL.

        CLEAR: lv_count.
        LOOP AT gt_relatorio INTO wa_relatorio WHERE sel  = 'X'
                                               AND   icon = icon_led_green.
          lv_count = lv_count + 1.
        ENDLOOP.

        IF lv_count = 1.
          MESSAGE e398(00) WITH 'Item já processado.'.
        ELSE.
          MESSAGE e398(00) WITH 'Existe Item já processado.'.
        ENDIF.

        EXIT.
      ENDIF.

      LOOP AT gt_relatorio INTO wa_relatorio WHERE sel  = 'X'.
        lv_tabix = sy-tabix.
        PERFORM executa_correcao.
        MODIFY gt_relatorio FROM wa_relatorio INDEX lv_tabix.
      ENDLOOP.
      PERFORM atualiza_alv.

  ENDCASE.
ENDFORM. "user-command
