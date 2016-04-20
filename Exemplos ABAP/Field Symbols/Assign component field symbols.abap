ASSIGN COMPONENT LV_LINHA OF STRUCTURE w_dados_add TO <fs_linhas>.

      IF sy-subrc EQ 0.
        LOOP AT it_dados_adicionais INTO wa_dados_adicionais.
          IF <fs_linhas> IS INITIAL.

          v_id = v_id + 1.
          t_msg-id = v_id.
          t_msg-txt = wa_dados_adicionais-txt_adicional.
          APPEND t_msg.

          ENDIF.
        ENDLOOP.
       EXIT.
           
      ENDIF.

      UNASSIGN <fs_linhas>.
      CLEAR: lv_linha.

    ENDDO.