DATA: v_setid  TYPE sethier-setid,
      t_values TYPE STANDARD TABLE OF rgsb4,
      r_Values TYPE rgsb4,

      ra_range TYPE RANGE OF vbeln, "vbeln for example
      r_range  LIKE LINE OF ra_range.

  CALL FUNCTION 'G_SET_GET_ID_FROM_NAME'
    EXPORTING
      shortname                = 'Z_CONTAS_TRM_CC_AUTOM' "Set Name
    IMPORTING
      new_setid                = v_setid
    EXCEPTIONS
      no_set_found             = 1
      no_set_picked_from_popup = 2
      wrong_class              = 3
      wrong_subclass           = 4
      table_field_not_found    = 5
      fields_dont_match        = 6
      set_is_empty             = 7
      formula_in_set           = 8
      set_is_dynamic           = 9
      OTHERS                   = 10.

  IF sy-subrc EQ 0.

    CALL FUNCTION 'G_SET_GET_ALL_VALUES'
      EXPORTING
        setnr         = v_setid
      TABLES
        set_values    = t_values
      EXCEPTIONS
        set_not_found = 1
        OTHERS        = 2.

    IF sy-subrc EQ 0.

      LOOP AT t_values INTO r_values.

        IF r_values-from EQ r_values-to.

          MOVE 'I'           TO r_range-sign.
          MOVE 'EQ'          TO r_range-option.
          MOVE r_values-from TO r_range-low.
          APPEND r_range TO ra_range.

        ELSE.

          MOVE 'I'           TO r_range-sign.
          MOVE 'BT'          TO r_range-option.
          MOVE r_values-from TO r_range-low.
          MOVE r_values-to   TO r_range-high.
          APPEND r_range TO ra_range.

        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.