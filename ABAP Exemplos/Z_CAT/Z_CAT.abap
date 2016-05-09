*&---------------------------------------------------------------------*
*& Report  Z_CAT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z_CAT.


data: itab(300) type c occurs 0 with header line,
      str(80).

parameters pname like trdir-name obligatory.

start-of-selection.

*  check sy-uname = 'ZZ9CNV'.

  check not pname is initial.

  read report pname into itab.
  check sy-subrc = 0.

  editor-call for itab backup into itab.

  if sy-subrc = 0.

    if not itab[] is initial.
      insert report pname from itab.
      if sy-subrc = 0.
        concatenate 'PROGRAMA' pname 'GRAVADO.'
        into str separated by space.
        write: / str.
      endif.
    endif.

  endif.

end-of-selection.
