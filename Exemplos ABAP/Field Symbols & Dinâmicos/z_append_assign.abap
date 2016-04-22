REPORT ugabugaugabuga.


DATA: initial TYPE i,
      final   TYPE i.

DATA: gt_mseg TYPE TABLE OF mseg,
      gs_mseg LIKE LINE OF gt_mseg.

DATA: test_tab  LIKE gt_mseg,
      test_line LIKE LINE OF test_tab.

FIELD-SYMBOLS: <test_line> LIKE LINE OF test_tab.


START-OF-SELECTION.

  SELECT * FROM mseg INTO TABLE gt_mseg UP TO 10000 ROWS.
**********************************************************************
  GET RUN TIME FIELD initial.

  LOOP AT gt_mseg INTO gs_mseg.
    MOVE-CORRESPONDING gs_mseg TO test_line.
    APPEND test_line TO test_tab.
  ENDLOOP.

  GET RUN TIME FIELD final.

  final = final - initial.

  WRITE: 'Tempo utilizando append:', final.
**********************************************************************
  FREE test_tab.
  CLEAR: initial, final.

  GET RUN TIME FIELD initial.

  LOOP AT gt_mseg INTO gs_mseg.
    APPEND INITIAL LINE TO test_tab ASSIGNING <test_line>.
    MOVE-CORRESPONDING gs_mseg TO <test_line>.
  ENDLOOP.

  GET RUN TIME FIELD final.

  final = final - initial.

  WRITE: 'Tempo utilizando assign:', final.