*&---------------------------------------------------------------------*
*& Report  ZALV_GRID_MOST_SIMPLE_REPORT
*&
*&---------------------------------------------------------------------*
*& ABAP Sample Code
*& The most simple ALV Grid Report
*&
*& Mauricio Lauffer
*& http://www.linkedin.com/in/mauriciolauffer
*&
*& This sample explains how to create the most simple ALV Grid Report
*& using the standard class CL_SALV_TABLE
*&
*&---------------------------------------------------------------------*

REPORT zalv_grid_most_simple_report.


" Declaration of the global variables
DATA:
  gt_sflight TYPE STANDARD TABLE OF sflight, " Table used into ALV to show data
  go_alv     TYPE REF TO cl_salv_table. " ALV object


" Select data from DB
SELECT *
  FROM sflight
  INTO TABLE gt_sflight.

" Get ALV object instance ready to use
TRY .
    cl_salv_table=>factory(
      IMPORTING
        r_salv_table = go_alv
      CHANGING
        t_table      = gt_sflight
    ).

  CATCH cx_salv_msg.
    WRITE: / 'ALV error'.
ENDTRY.

" Show ALV Grid
go_alv->display( ).
