CALL FUNCTION 'STATUS_READ'
  EXPORTING
    client           = sy-mandt
    objnr            = wa_equi-objnr
    only_active      = 'X'
  TABLES
    status           = it_status
  EXCEPTIONS
    object_not_found = 1
    OTHERS           = 2.
  READ TABLE it_status WITH KEY stat = 'I0320'. "INACT
      CALL FUNCTION 'STATUS_READ'
        EXPORTING
          client           = sy-mandt
          objnr            = wa_equi-objnr
          only_active      = 'X'
        TABLES
          status           = it_status
        EXCEPTIONS
          object_not_found = 1
          OTHERS           = 2.
        READ TABLE it_status WITH KEY stat = 'I0320'. "INACT