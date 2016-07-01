 
*COMANDOS UTILIZADOS
  "DO '' TIMES
  "Concatenate
  "Translate
  "Field Symbols Component
  "Exit

 DO 16 TIMES.
      lv_id = lv_id + 1.

      CONCATENATE 'linha' lv_id INTO lv_linha.

      TRANSLATE lv_linha TO UPPER CASE.

      ASSIGN COMPONENT LV_LINHA OF STRUCTURE w_dados_add TO <fs_linhas>.

      IF sy-subrc EQ 0.
        IF <fs_linhas> IS INITIAL.

          LOOP AT it_dados_adicionais INTO wa_dados_adicionais.
            v_id = v_id + 1.
            t_msg-id = v_id.
            t_msg-txt = wa_dados_adicionais-txt_adicional.
            APPEND t_msg.
          ENDLOOP.
          EXIT.
        ENDIF.
      ENDIF.

      UNASSIGN <fs_linhas>.
      CLEAR: lv_linha.

 ENDDO.