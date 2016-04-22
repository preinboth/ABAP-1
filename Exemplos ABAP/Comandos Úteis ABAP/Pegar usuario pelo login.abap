  DATA: v_bname  TYPE usr21-bname,
        v_cname  TYPE pa0002-cname.

FORM f_get_name_user  USING    p_v_bname
                      CHANGING p_v_cname.

  DATA: l_persnumber TYPE usr21-persnumber,
      l_name_first TYPE adrp-name_first,
      l_name_last  TYPE adrp-name_last.

  CLEAR: l_persnumber,
         l_name_first,
         l_name_last.


  SELECT SINGLE persnumber FROM usr21 INTO l_persnumber WHERE bname EQ p_v_bname.

  IF sy-subrc EQ 0.
    SELECT SINGLE name_first name_last FROM adrp INTO (l_name_first,l_name_last)
      WHERE persnumber EQ l_persnumber.

    CONCATENATE l_name_first l_name_last INTO p_v_cname SEPARATED BY space.
  ENDIF.

ENDFORM.                    " F_GET_NAME_USER