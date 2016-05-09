DATA: l_curto TYPE timestamp,
      l_longo TYPE timestampl.
  
GET TIME STAMP FIELD l_curto.
GET TIME STAMP FIELD l_longo.
DATA :
  timestamp like TZONREF-TSTAMPS,
  time      like sy-uzeit,
  date      like sy-datum.
CALL FUNCTION 'IB_CONVERT_FROM_TIMESTAMP'
  EXPORTING
    i_timestamp       = timestamp
    I_TZONE           = 'BRAZIL'
 IMPORTING
    E_DATLO           = date
    E_TIMLO           = time.