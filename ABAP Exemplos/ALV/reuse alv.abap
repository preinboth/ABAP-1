    PERFORM f_busca_dados.
    PERFORM f_monta_header_alv.
    PERFORM f_monta_catalogo_alv.
    PERFORM f_sort_build.
    PERFORM f_set_layout_alv USING v_layout_lvc.
    PERFORM f_set_callback_forms.

    ASSIGN (v_alv_table) TO <fs_alv_table>.
    CHECK sy-subrc IS INITIAL.

    SORT <fs_alv_table> BY ('BOLNR').
    IF p_flag IS NOT INITIAL.
      DELETE ADJACENT DUPLICATES FROM <fs_alv_table> COMPARING ('BOLNR').
    ENDIF.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
      EXPORTING
        i_buffer_active          = c_x
        i_callback_program       = sy-repid
        i_callback_top_of_page   = v_top_of_page
        i_callback_pf_status_set = v_pf_status_set
        i_callback_user_command  = v_user_command
        is_layout_lvc            = v_layout_lvc
        it_fieldcat_lvc          = t_fieldcat_lvc
        it_sort_lvc              = t_sort_lvc
        i_save                   = c_a
      TABLES
        t_outtab                 = <fs_alv_table>
      EXCEPTIONS
        program_error            = 1
        OTHERS                   = 2.
    IF sy-subrc NE 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    FREE: v_layout_lvc.
*
    LEAVE LIST-PROCESSING.



*    PERFORM f_monta_alv.

