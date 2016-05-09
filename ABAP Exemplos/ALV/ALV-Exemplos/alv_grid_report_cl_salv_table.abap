*&---------------------------------------------------------------------*
*& Report  ZALV_GRID_REPORT
*&
*&---------------------------------------------------------------------*
*& ABAP Sample Code
*& ALV Grid Report with some extra functions
*&
*& Mauricio Lauffer
*& http://www.linkedin.com/in/mauriciolauffer
*&
*& This sample explains how to create an ALV Grid Report using the
*& standard class CL_SALV_TABLE with some extra functions such as:
*& color, visibility, alignment, text, position, etc.
*&---------------------------------------------------------------------*

REPORT zalv_grid_report.


" Declaration of the global variables
DATA:
  gt_sflight         TYPE STANDARD TABLE OF sflight, " Table used into ALV to show data
  gv_error_message   TYPE string, " Variable used to get the error message
  go_alv             TYPE REF TO cl_salv_table, " ALV object
  go_display         TYPE REF TO cl_salv_display_settings, " ALV Display object
  go_functions       TYPE REF TO cl_salv_functions_list, " ALV Functions object
  go_columns         TYPE REF TO cl_salv_columns_table, " ALV columns - all columns from your ALV Table
  go_column          TYPE REF TO cl_salv_column, " ALV column - details from one specific column
  gx_salv_msg        TYPE REF TO cx_salv_msg,
  gx_salv_not_found  TYPE REF TO cx_salv_not_found.



START-OF-SELECTION.
  PERFORM select_data.

END-OF-SELECTION.
  PERFORM create_alv_object.
  PERFORM set_alv_functions.
  PERFORM set_alv_display.
  PERFORM format_columns.
  PERFORM show_alv.





*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA
*&---------------------------------------------------------------------*
*       Select data to use and show into the ALV
*----------------------------------------------------------------------*
FORM select_data .

  " Select data from DB
  SELECT *
    FROM sflight
    INTO TABLE gt_sflight.

ENDFORM.                    " SELECT_DATA



*&---------------------------------------------------------------------*
*&      Form  CREATE_ALV_OBJECT
*&---------------------------------------------------------------------*
*       To get an instance of an ALV using the class CL_SALV_TABLE
*       you must call the factory method.
*----------------------------------------------------------------------*
FORM create_alv_object .

  " Get ALV object instance ready to use.
  " You don't need to inform any field detail to the ALV such as Name, Text, Position, Data Type, F1 Help, etc.
  " The ALV will assume all information from the Data Element used in the table and fields.
  TRY .
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table = go_alv
        CHANGING
          t_table      = gt_sflight
      ).

    CATCH cx_salv_msg INTO gx_salv_msg.
      gv_error_message = gx_salv_msg->get_text( ).
      WRITE gv_error_message.
  ENDTRY.

ENDFORM.                    " CREATE_ALV_OBJECT



*&---------------------------------------------------------------------*
*&      Form  SET_ALV_DISPLAY
*&---------------------------------------------------------------------*
*       You can change some details in the ALV display such as
*       title, table style, etc.
*----------------------------------------------------------------------*
FORM set_alv_display .

  DATA:
    lv_title TYPE lvc_title. " Variable which will receive the new ALV title


  "New ALV title
  lv_title = 'That is my new ALV title'.

  " Get the reference for ALV Display Settings object
  go_display = go_alv->get_display_settings( ).

  " Set striped pattern aka Zebra
  go_display->set_striped_pattern( if_salv_c_bool_sap=>true ).

  " Set new ALV title
  go_display->set_list_header( lv_title ).

ENDFORM.                    " SET_ALV_DISPLAY



*&---------------------------------------------------------------------*
*&      Form  set_alv_functions
*&---------------------------------------------------------------------*
*       You can use a standard set of functions for things like sorting,
*       filtering, etc. They are already avaliable with the ALV object.
*       You can add custom events or buttons as well.
*----------------------------------------------------------------------*
FORM set_alv_functions .

  "Get the reference for ALV Functions object
  go_functions = go_alv->get_functions( ).

  "Set all standard functions in toolbar to be used
  go_functions->set_all( if_salv_c_bool_sap=>true ).

ENDFORM.                    "set_alv_functions



*&---------------------------------------------------------------------*
*&      Form  format_columns
*&---------------------------------------------------------------------*
*       Usually the table includes all data element for the fields.
*       The column will automatically assume all details from the Data
*       Element (Data Type, all Texts, etc.). If you don't want to use
*       the information which come from the Data Element you can edit it
*       using some methods from the class CL_SALV_COLUMNS.
*       With this class you can edit all your ALV.
*       For example: hide an specific field, set field as key, change
*       column color, change texts, etc.
*----------------------------------------------------------------------*
FORM format_columns.

  " Get the reference for ALV Columns, all columns from your ALV Table
  go_columns = go_alv->get_columns( ).

  " ALV will open with all columns adjusted to show the data
  " You can do the same per column, instead for all table, using GO_COLUMN->SET_OPTIMIZED( if_salv_c_bool_sap=>true )
  go_columns->set_optimize( if_salv_c_bool_sap=>true ).


  PERFORM set_column_alignment.
  PERFORM set_column_color.
  PERFORM set_column_checkbox.
  PERFORM set_column_key.
  PERFORM set_column_position.
  PERFORM set_column_text.
  PERFORM set_column_tooltip.
  PERFORM set_column_visibility.
  PERFORM set_column_zero.

ENDFORM.                    "format_columns



*&---------------------------------------------------------------------*
*&      Form  set_column_alignment
*&---------------------------------------------------------------------*
*       Change column alignment
*----------------------------------------------------------------------*
FORM set_column_alignment .

  TRY.
      " Get reference for ALV column object
      go_column = go_columns->get_column( columnname = 'PLANETYPE' ).

      " Set new alignment (centralized)
      go_column->set_alignment( 3 ).

    CATCH cx_salv_not_found INTO gx_salv_not_found.
      gv_error_message = gx_salv_not_found->get_text( ).
      WRITE gv_error_message.
  ENDTRY.

ENDFORM.                    "set_column_alignment



*&---------------------------------------------------------------------*
*&      Form  SET_COLUMN_COLOR
*&---------------------------------------------------------------------*
*       Change column color
*----------------------------------------------------------------------*
FORM set_column_color .

  DATA:
    ls_color  TYPE lvc_s_colo, " Structure with color informations
    lo_column TYPE REF TO cl_salv_column_table. " To set the column color we must use another class


  " Define a color. For the field LVC_S_COLO-COL you can choose the following colors:
  " 1 = Blue (#A5E4F2) / 2 = Purple (#D3DEED) / 3 = Yellow (#FCF342) /
  " 4 = Light Blue (#A5E4F2) / 5 = Green (#95D690) / 6 = Red (#FC6658) / 7 = Orange (#FAB770)
  ls_color-col = 3. " Color
  ls_color-int = 0. " Intensity
  ls_color-inv = 0. " Inverted

  TRY .
      " Get reference for ALV column object.
      " Observe that we use another class to manipulate the column color
      lo_column ?= go_columns->get_column( 'PLANETYPE' ).

      " Set color for a single column
      lo_column->set_color( ls_color ).

    CATCH cx_salv_not_found INTO gx_salv_not_found.
      gv_error_message = gx_salv_not_found->get_text( ).
      WRITE gv_error_message.
  ENDTRY.

ENDFORM.                    " SET_COLUMN_COLOR



*&---------------------------------------------------------------------*
*&      Form  SET_COLUMN_CHECKBOX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM set_column_checkbox .
*gr_column->set_cell_type( if_salv_c_cell_type=>checkbox ).
ENDFORM.                    " SET_COLUMN_CHECKBOX



*&---------------------------------------------------------------------*
*&      Form  SET_COLUMN_KEY
*&---------------------------------------------------------------------*
*       Change the table key
*----------------------------------------------------------------------*
FORM set_column_key .

  DATA:
    lo_column TYPE REF TO cl_salv_column_table. " To set the column as key we must use another class


  TRY .
      " Get reference for ALV column object.
      lo_column ?= go_columns->get_column( 'PRICE' ).

      " Set new key to the table. PRICE is not key in SFLIGHT, but will appear as one now (it's just for test, ok?)
      " Observe that we use another class to manipulate the table key
      lo_column->set_key( if_salv_c_bool_sap=>true ).

    CATCH cx_salv_not_found INTO gx_salv_not_found.
      gv_error_message = gx_salv_not_found->get_text( ).
      WRITE gv_error_message.
  ENDTRY.

ENDFORM.                    " SET_COLUMN_KEY



*&---------------------------------------------------------------------*
*&      Form  SET_COLUMN_POSITION
*&---------------------------------------------------------------------*
*       Change the original position where a column will appear
*----------------------------------------------------------------------*
FORM set_column_position .

  " Set new position for a column
  " Plane type will appear at the end of the table, the last column position
  go_columns->set_column_position(
    columnname = 'PLANETYPE'
    position   = 14
  ).

ENDFORM.                    " SET_COLUMN_POSITION



*&---------------------------------------------------------------------*
*&      Form  SET_COLUMN_TEXT
*&---------------------------------------------------------------------*
*       Change a column text (short / medium / long).
*       The texts (short, medium or long) are shown depending on the
*       physical width of the column on your screen.
*----------------------------------------------------------------------*
FORM set_column_text .

  TRY.
      " Get reference for ALV column object
      go_column = go_columns->get_column( columnname = 'PLANETYPE' ).

      " Set new text
      go_column->set_short_text( 'NewTxtPlTy' ).
      go_column->set_medium_text( 'New Txt PlaneType').
      go_column->set_long_text( 'New Text for Plane Type' ).

    CATCH cx_salv_not_found INTO gx_salv_not_found.
      gv_error_message = gx_salv_not_found->get_text( ).
      WRITE gv_error_message.
  ENDTRY.

ENDFORM.                    " SET_COLUMN_TEXT



*&---------------------------------------------------------------------*
*&      Form  SET_COLUMN_TOOLTIP
*&---------------------------------------------------------------------*
*       Change the tooltip for a column header. Tooltip is the text
*       which is shown when your mouse is over the column header.
*----------------------------------------------------------------------*
FORM set_column_tooltip .

  TRY.
      " Get reference for ALV column object
      go_column = go_columns->get_column( columnname = 'PLANETYPE' ).

      " Set new tooltip
      go_column->set_tooltip( 'New tooltip for this column header' ).

    CATCH cx_salv_not_found INTO gx_salv_not_found.
      gv_error_message = gx_salv_not_found->get_text( ).
      WRITE gv_error_message.
  ENDTRY.

ENDFORM.                    " SET_COLUMN_TOOLTIP



*&---------------------------------------------------------------------*
*&      Form  SET_COLUMN_VISIBILITY
*&---------------------------------------------------------------------*
*       Change column visibility. There are two ways to change columns'
*       visibility: either setting as technical or as invisible.
*       The difference is when you set a column as technical you cannot
*       show this column again. Normally used to hide MANDT field.
*       Using the option to turn the column visible/invisible you can
*       edit the visibility whenever you want. You just need to modify
*       the layout (Crtl + F8). You can hide or show the field as you
*       need.
*----------------------------------------------------------------------*
FORM set_column_visibility .

  TRY.
      " Get reference for ALV column object
      go_column = go_columns->get_column( columnname = 'MANDT' ).

      " Set column as technical means that this column won't be visible in your ALV (never)
      go_column->set_technical( if_salv_c_bool_sap=>true ).


      " Get reference for ALV column object
      go_column = go_columns->get_column( columnname = 'FLDATE' ).

      " Set column as invisible, but you can edit the layout on the fly to show it whenever you want
      go_column->set_visible( if_salv_c_bool_sap=>false ).

    CATCH cx_salv_not_found INTO gx_salv_not_found.
      gv_error_message = gx_salv_not_found->get_text( ).
      WRITE gv_error_message.
  ENDTRY.

ENDFORM.                    " SET_COLUMN_VISIBILITY



*&---------------------------------------------------------------------*
*&      Form  SET_COLUMN_ZERO
*&---------------------------------------------------------------------*
*       Change the way how field value = ZERO is shown
*----------------------------------------------------------------------*
FORM set_column_zero .

  TRY.
      " Get reference for ALV column object
      go_column = go_columns->get_column( columnname = 'PAYMENTSUM' ).

      " If a field from this column has value = ZERO (0), it will shown as SPACE
      go_column->set_zero( if_salv_c_bool_sap=>false ).

    CATCH cx_salv_not_found INTO gx_salv_not_found.
      gv_error_message = gx_salv_not_found->get_text( ).
      WRITE gv_error_message.
  ENDTRY.

ENDFORM.                    " SET_COLUMN_ZERO



*&---------------------------------------------------------------------*
*&      Form  SHOW_ALV
*&---------------------------------------------------------------------*
*       Show the ALV Grid in a new window
*----------------------------------------------------------------------*
FORM show_alv .

  " Show ALV Grid
  go_alv->display( ).

ENDFORM.                    " SHOW_ALV