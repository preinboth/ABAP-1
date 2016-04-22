&---------------------------------------------------------------------*
*& Report ZNBCSH_TETRIS *
*&---------------------------------------------------------------------*
*& (c) Sergey Shumakov, 2004 , sshum@mail.ru *
*& Comment: I lost interest, when encounter limit one fps *
*&---------------------------------------------------------------------*

* To install TETRIS:
* 1) Create program and place ALL this text in it.
* 2) Create standart SCREEN 100 and insert this part
*------------------------------------------------------------*
* PROCESS BEFORE OUTPUT.
* MODULE STATUS_0100.
*
* PROCESS AFTER INPUT.
* MODULE EXX AT EXIT-COMMAND.
* MODULE USER_COMMAND_0100.
*------------------------------------------------------------*
* 3) Create GUI-status STATUS_0 and insert
* 3.1) Free functional keys
*------------------------------------------------------------*
* F5 PF21 Drop (F5)
* F6 PF22 Left (F6)
* F7 PF23 Rotate(F7)
* F8 PF24 Right (F8)
* Shift-F1 PF25 Return
* Shift-F6 PF26 Down
*------------------------------------------------------------*
* 3.2) Buttons
*------------------------------------------------------------*
* PF21 PF22 PF23 PF24
* Drop (F5) Left (F6) Rotate(F7) Right (F8)
*------------------------------------------------------------*
* 3.3) And as usual standart functions ;-)
* BACK UP EXIT
*------------------------------------------------------------*
* 4) Activate it and enjoy! ;-)


* 5) If you want to try delays less then one second,
* create functional module like this, and comment/uncomment
* CALLs and RECIEVEs in the forms 'f_call_rfc_wait' and 'f_task_end'.
*------------------------------------------------------------*
* FUNCTION Z_NBCSH_DELAY .
* *"------------------------------------------------------------
* *" IMPORTING
* *" VALUE(DELAY) TYPE F DEFAULT 1
* *"------------------------------------------------------------
* wait up to delay seconds.
* ENDFUNCTION.
*------------------------------------------------------------*

REPORT znbcsh_tetris .

DATA count TYPE i.
DATA scores TYPE i.
TYPES: BEGIN OF outtype ,
line TYPE char20,
END OF outtype.
DATA outtab TYPE outtype OCCURS 1 WITH HEADER LINE.
*---------------------------------------------------------------------*
DATA: stakan TYPE c OCCURS 0,
stakan_fig LIKE stakan,
stakan_fig_old LIKE stakan,
stakan_zad LIKE stakan.
DATA: sz, st, sf,
data0,
data1,
data2,
data3,
data4,
data5,
data6,
data7,
data8,
data9.
DATA: err, fl_new.
DATA: row TYPE i, col TYPE i.

DATA: st_width TYPE i VALUE 12, st_height TYPE i VALUE 20.

TYPES: BEGIN OF figure,
* cur_pos TYPE i,
* start_pos type I,
name(10),
width TYPE i,
height TYPE i,
* nextfig type figure,
body1 TYPE i,
body2 TYPE i,
body3 TYPE i,
body4 TYPE i,
old_body1 TYPE i,
old_body2 TYPE i,
old_body3 TYPE i,
old_body4 TYPE i,
END OF figure.
DATA: square TYPE figure,
line1 TYPE figure,
line2 TYPE figure,
lzz1 TYPE figure,
lzz2 TYPE figure,
rzz1 TYPE figure,
rzz2 TYPE figure,
tri1 TYPE figure,
tri2 TYPE figure,
tri3 TYPE figure,
tri4 TYPE figure,
lgg1 TYPE figure,
lgg2 TYPE figure,
lgg3 TYPE figure,
lgg4 TYPE figure,
rgg1 TYPE figure,
rgg2 TYPE figure,
rgg3 TYPE figure,
rgg4 TYPE figure
.
DATA cur_fig TYPE figure.

START-OF-SELECTION.

PERFORM init_figures.
PERFORM init_stakan.
PERFORM put_next_fig.


SET PF-STATUS 'STATUS_0'.
CALL SCREEN 100.


AT USER-COMMAND.
CASE sy-ucomm.
WHEN 'BACK' OR 'UP' OR 'EXIT'.
LEAVE PROGRAM.
* PERFORM f_read_data.
* is_selfield-refresh = 'X'.
* SET USER-COMMAND '&OPT'. " Optimize columns width
ENDCASE.

*Drop
AT PF21.
CLEAR: err, count.
DO.
PERFORM fig_move USING 'DOWN' CHANGING err.
IF err EQ 'X'.
EXIT.
ENDIF.
ADD 1 TO count.
ENDDO.
ADD count TO scores.
PERFORM out.
PERFORM f_call_rfc_wait.


AT PF22.
PERFORM fig_move USING 'LEFT' CHANGING err.
PERFORM out.
PERFORM f_call_rfc_wait.

AT PF23.
PERFORM fig_rotate.
PERFORM out.
PERFORM f_call_rfc_wait.

AT PF24.
PERFORM fig_move USING 'RIGHT' CHANGING err.
PERFORM out.
PERFORM f_call_rfc_wait.

AT PF25.
* set user-command 'PF21'.
CALL METHOD cl_gui_cfw=>set_new_ok_code
EXPORTING new_code = 'PF21'.
LEAVE LIST-PROCESSING.

AT PF26.
PERFORM fig_move USING 'DOWN' CHANGING err.
PERFORM out.
IF err = 'X'.
PERFORM fig_append.
PERFORM check_full_line.
PERFORM put_next_fig.
ENDIF.
PERFORM f_call_rfc_wait.


*---------------------------------------------------------------------*
* FORM out *
*---------------------------------------------------------------------*
* ........ *
*---------------------------------------------------------------------*
FORM out.
DATA outstring(100).
DATA: lc TYPE i, otstup TYPE i.
DATA stakan_out LIKE stakan.
DATA so(2).

otstup = st_width * 4.
stakan_out[] = stakan[].
MODIFY stakan_out FROM 'X' INDEX cur_fig-body1.
MODIFY stakan_out FROM 'X' INDEX cur_fig-body2.
MODIFY stakan_out FROM 'X' INDEX cur_fig-body3.
MODIFY stakan_out FROM 'X' INDEX cur_fig-body4.
CLEAR outstring.
WRITE AT 30 'Score: '.
WRITE scores .
LOOP AT stakan_out INTO st.
IF sy-tabix LE otstup. CONTINUE. ENDIF.
lc = sy-tabix MOD st_width .
CASE st.
WHEN ','. so = '::'.
WHEN 'O'. so = 'OO'.
WHEN 'X'. so = '[]'.
ENDCASE.
CONCATENATE outstring so INTO outstring.
IF lc = 0.
NEW-LINE.
TRANSLATE outstring USING ': '.
*WRITE outstring INTENSIFIED ON .
*WRITE outstring COLOR COL_negative." INVERSE ON .
WRITE (24) outstring .

* WRITE outstring+1(st_width) INVERSE ON .
* write: outstring(1).
* WRITE: outstring .
CLEAR outstring.
ENDIF.
ENDLOOP.

ENDFORM.
*---------------------------------------------------------------------*
* Form F_CALL_RFC_WAIT
*---------------------------------------------------------------------*
FORM f_call_rfc_wait.
DATA lv_mssg(80). "#EC NEEDED
* Wait in a task

* You need to create functional module 'Z_NBCSH_DELAY'
* to try delay less then 1 second
* DATA seconds TYPE f.
* seconds = '0.5'.
* CALL FUNCTION 'Z_NBCSH_DELAY' STARTING NEW TASK '001'
* PERFORMING f_task_end ON END OF TASK
* EXPORTING
* delay = seconds
* EXCEPTIONS
* RESOURCE_FAILURE = 1
* communication_failure = 2 MESSAGE lv_mssg
* system_failure = 3 MESSAGE lv_mssg
* OTHERS = 4.

CALL FUNCTION 'RFC_PING_AND_WAIT' STARTING NEW TASK '001'
PERFORMING f_task_end ON END OF TASK
EXPORTING
seconds = 1 " Refresh time
busy_waiting = space
EXCEPTIONS
RESOURCE_FAILURE = 1
communication_failure = 2 MESSAGE lv_mssg
system_failure = 3 MESSAGE lv_mssg
OTHERS = 4.
SET USER-COMMAND 'PF25'.
ENDFORM. " F_CALL_RFC_WAIT
*---------------------------------------------------------------------*
* Form F_TASK_END
*---------------------------------------------------------------------*
FORM f_task_end USING u_taskname.

DATA lv_mssg(80). "#EC NEEDED

* Receiving task results
* You need to create functional module 'Z_NBCSH_DELAY'
* to try delay less then 1 second
RECEIVE RESULTS FROM FUNCTION 'RFC_PING_AND_WAIT'
* RECEIVE RESULTS FROM FUNCTION 'Z_NBCSH_DELAY'
EXCEPTIONS
RESOURCE_FAILURE = 1
communication_failure = 2 MESSAGE lv_mssg
system_failure = 3 MESSAGE lv_mssg
OTHERS = 4.

CHECK sy-subrc EQ 0.

SET USER-COMMAND 'PF26'. " down

ENDFORM. " F_TASK_END
*************** END OF PROGRAM ZNBCSH_TETRIS *********************
*&---------------------------------------------------------------------*
*& Module STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
* SET PF-STATUS 'STATUS_0'.
*CALL METHOD cl_gui_cfw=>set_new_ok_code
* EXPORTING new_code = 'PF21'.
* WRITE 'Press to begin'.
PERFORM out.
LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 100.
LEAVE SCREEN.

* leave screen.
* SET TITLEBAR 'xxx'.
* DATA lv_mssg(80). "#EC NEEDED

ENDMODULE. " STATUS_0100 OUTPUT
*&---------------------------------------------------------------------*
*& Module USER_COMMAND_0100 INPUT
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.
CASE sy-ucomm.
WHEN 'BACK' OR 'UP' OR 'EXIT'.
LEAVE PROGRAM.
ENDCASE.
ENDMODULE. " USER_COMMAND_0100 INPUT


*---------------------------------------------------------------------*
* MODULE exx INPUT *
*---------------------------------------------------------------------*
* ........ *
*---------------------------------------------------------------------*
MODULE exx INPUT.
LEAVE PROGRAM.
ENDMODULE. " EXX INPUT

*---------------------------------------------------------------------*
* FORM init_figures *
*---------------------------------------------------------------------*
* ........ *
*---------------------------------------------------------------------*
FORM init_figures.
DATA s TYPE i.
DATA w TYPE i.
w = st_width. "
s = w DIV 2. "
square-name = 'SQUARE'.
square-body1 = s.
square-body2 = s + 1.
square-body3 = s + w.
square-body4 = s + w + 1.
square-width = 2.
square-height = 2.

line1-name = 'LINE1'.
line1-body1 = s - 2.
line1-body2 = s - 1.
line1-body3 = s .
line1-body4 = s + 1.
line1-width = 4.
line1-height = 1.

line2-name = 'LINE2'.
line2-body1 = s .
line2-body2 = s + w.
line2-body3 = s + w + w.
line2-body4 = s + w + w + w.
line2-width = 1.
line2-height = 4.

lzz1-name = 'LZZ1'.
lzz1-body1 = s .
lzz1-body2 = s + w.
lzz1-body3 = s + 1 + w.
lzz1-body4 = s + 1 + w + w.
lzz1-width = 2.
lzz1-height = 3.

lzz2-name = 'LZZ2'.
lzz2-body1 = s .
lzz2-body2 = s + 1.
lzz2-body3 = s + w - 1.
lzz2-body4 = s + w.
lzz2-width = 3.
lzz2-height = 2.

rzz1-name = 'RZZ1'.
rzz1-body1 = s + 1.
rzz1-body2 = s + w .
rzz1-body3 = s + w + 1.
rzz1-body4 = s + w + w.
rzz1-width = 2.
rzz1-height = 3.

rzz2-name = 'RZZ2'.
rzz2-body1 = s - 1.
rzz2-body2 = s .
rzz2-body3 = s + w.
rzz2-body4 = s + 1 + w.
rzz2-width = 3.
rzz2-height = 2.

tri1-name = 'TRI1'.
tri1-body1 = s .
tri1-body2 = s + w - 1.
tri1-body3 = s + w.
tri1-body4 = s + 1 + w.
tri1-width = 3.
tri1-height = 2.

tri2-name = 'TRI2'.
tri2-body1 = s - 1.
tri2-body2 = s + w - 1.
tri2-body3 = s + w.
tri2-body4 = s - 1 + w + w.
tri2-width = 2.
tri2-height = 3.

tri3-name = 'TRI3'.
tri3-body1 = s - 1.
tri3-body2 = s .
tri3-body3 = s + 1.
tri3-body4 = s + w.
tri3-width = 3.
tri3-height = 2.

tri4-name = 'TRI4'.
tri4-body1 = s .
tri4-body2 = s - 1 + w.
tri4-body3 = s + w.
tri4-body4 = s + w + w.
tri4-width = 2.
tri4-height = 3.

lgg1-name = 'LGG1'.
lgg1-body1 = s .
lgg1-body2 = s + w.
lgg1-body3 = s + w + w.
lgg1-body4 = s + w + w + 1.
lgg1-width = 2.
lgg1-height = 3.

lgg2-name = 'LGG2'.
lgg2-body1 = s - 1.
lgg2-body2 = s .
lgg2-body3 = s + 1.
lgg2-body4 = s + w - 1.
lgg2-width = 2.
lgg2-height = 3.

lgg3-name = 'LGG3'.
lgg3-body1 = s .
lgg3-body2 = s + 1.
lgg3-body3 = s + w + 1.
lgg3-body4 = s + w + w + 1.
lgg3-width = 2.
lgg3-height = 3.

lgg4-name = 'LGG4'.
lgg4-body1 = s + 1.
lgg4-body2 = s - 1 + w.
lgg4-body3 = s + w.
lgg4-body4 = s + w + 1.
lgg4-width = 2.
lgg4-height = 3.

rgg1-name = 'RGG1'.
rgg1-body1 = s + 1.
rgg1-body2 = s + w + 1.
rgg1-body3 = s + w + w .
rgg1-body4 = s + w + w + 1.
rgg1-width = 2.
rgg1-height = 3.

rgg2-name = 'RGG2'.
rgg2-body1 = s - 1.
rgg2-body2 = s + w - 1.
rgg2-body3 = s + w.
rgg2-body4 = s + w + 1.
rgg2-width = 2.
rgg2-height = 3.

rgg3-name = 'RGG3'.
rgg3-body1 = s .
rgg3-body2 = s + 1.
rgg3-body3 = s + w .
rgg3-body4 = s + w + w.
rgg3-width = 2.
rgg3-height = 3.

rgg4-name = 'RGG4'.
rgg4-body1 = s - 1.
rgg4-body2 = s .
rgg4-body3 = s + 1.
rgg4-body4 = s + w + 1.
rgg4-width = 2.
rgg4-height = 3.

ENDFORM.
*---------------------------------------------------------------------*
* FORM init_stakan_zad *
*---------------------------------------------------------------------*
* ........ *
*---------------------------------------------------------------------*
FORM init_stakan.
DATA size_v TYPE i.
DATA size_h TYPE i.

size_v = st_height + 4 .
size_h = st_width - 2.
CLEAR stakan.
DO size_v TIMES.
APPEND 'O' TO stakan.
DO size_h TIMES.
APPEND ',' TO stakan.
ENDDO.
APPEND 'O' TO stakan.
ENDDO.
APPEND ',' TO stakan.
DO size_h TIMES.
APPEND 'O' TO stakan.
ENDDO.
APPEND ',' TO stakan.

ENDFORM.

*---------------------------------------------------------------------*
* FORM put_next_fig *
*---------------------------------------------------------------------*
* ........ *
*---------------------------------------------------------------------*
* --> FIG *
*---------------------------------------------------------------------*
FORM put_next_fig.
* DATA rnd LIKE bbseg-wrbtr.
*
* CALL FUNCTION 'RANDOM_AMOUNT'
* EXPORTING
* rnd_min = '1'
* rnd_max = '7'
** VALCURR = 'DEM'
* IMPORTING
* rnd_amount = rnd
* .
DATA rnd TYPE i.
CALL FUNCTION 'QF05_RANDOM_INTEGER'
EXPORTING
ran_int_max = 7
ran_int_min = 1
IMPORTING
ran_int = rnd
* EXCEPTIONS
* INVALID_INPUT = 1
* OTHERS = 2
.
IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
* WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.

* CONDENSE rnd.
CASE rnd.
WHEN '1'.
cur_fig = square.
WHEN '2'.
cur_fig = line1.
WHEN '3'.
cur_fig = rzz1.
WHEN '4'.
cur_fig = lzz1.
WHEN '5'.
cur_fig = tri1.
WHEN '6'.
cur_fig = lgg1.
WHEN '7'.
cur_fig = rgg1.
ENDCASE.
PERFORM fig_move USING 'INIT' CHANGING err.
IF NOT err IS INITIAL.
DATA result(20).
WRITE scores TO result.
CONDENSE result.
CONCATENATE 'You score:' result INTO result SEPARATED BY space.

DATA answer.
CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_MESSAGE'
EXPORTING
defaultoption = 'Y'
diagnosetext1 = result
diagnosetext2 = 'you_max_result'
diagnosetext3 = 'max_result'
textline1 = 'Play again?'
* TEXTLINE2 = ' '
titel = 'GAME OVER'
* START_COLUMN = 25
* START_ROW = 6
cancel_display = ''
IMPORTING
answer = answer
.
IF answer EQ 'N'.
LEAVE PROGRAM.
ELSE.
PERFORM init_stakan.
PERFORM put_next_fig.
ENDIF.
ENDIF.
ENDFORM.
*---------------------------------------------------------------------*
* FORM fig_move *
*---------------------------------------------------------------------*
* ........ *
*---------------------------------------------------------------------*
* --> DIR *
*---------------------------------------------------------------------*
FORM fig_move USING dir TYPE char5 CHANGING error.
DATA: shft TYPE i.
error = ''.
DATA temp_fig LIKE cur_fig.

temp_fig = cur_fig.
* PERFORM SAVE_POS.

CASE dir.
WHEN 'DOWN'.
shft = st_width.
WHEN 'LEFT'.
shft = -1.
WHEN 'RIGHT'.
shft = 1.
WHEN 'INIT'.
shft = st_width * 4.
ENDCASE.

ADD shft TO cur_fig-body1.
ADD shft TO cur_fig-body2.
ADD shft TO cur_fig-body3.
ADD shft TO cur_fig-body4.

PERFORM check_pos CHANGING error.

IF NOT error IS INITIAL.
cur_fig = temp_fig.
* PERFORM RESTORE_POS.
ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
* FORM check_pos *
*---------------------------------------------------------------------*
* ........ *
*---------------------------------------------------------------------*
* --> ERROR *
*---------------------------------------------------------------------*
FORM check_pos CHANGING error TYPE char1.
DATA: v_pos TYPE i, h_pos TYPE i.

DO 1 TIMES.
READ TABLE stakan INTO st INDEX cur_fig-body1.
IF st NE ','.
error = 'X'. EXIT.
ENDIF.

READ TABLE stakan INTO st INDEX cur_fig-body2.
IF st NE ','.
error = 'X'. EXIT.
ENDIF.

READ TABLE stakan INTO st INDEX cur_fig-body3.
IF st NE ','.
error = 'X'. EXIT.
ENDIF.

READ TABLE stakan INTO st INDEX cur_fig-body4.
IF st NE ','.
error = 'X'. EXIT.
ENDIF.
ENDDO.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form fig_rotate
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
* --> p1 text
* <-- p2 text
*----------------------------------------------------------------------*
FORM fig_rotate.
DATA error.
DATA: start TYPE i, shft TYPE i.
DATA temp_fig LIKE cur_fig.
DATA: w TYPE i, w2 TYPE i.
w = st_width.
w2 = st_width DIV 2.
temp_fig = cur_fig.

start = cur_fig-body1.
CASE temp_fig-name.
WHEN 'LINE1'.
cur_fig = line2.
shft = - ( w * 2 + w2 - 2 ) .
WHEN 'LINE2'.
cur_fig = line1.
shft = w * 2 - w2 .
WHEN 'LZZ1'.
cur_fig = lzz2.
shft = w - w2 .
WHEN 'LZZ2'.
cur_fig = lzz1.
shft = w2 - w - w .
WHEN 'RZZ1'.
cur_fig = rzz2.
shft = w - w2 - 1 .
WHEN 'RZZ2'.
cur_fig = rzz1.
shft = w2 - w - w + 1.
WHEN 'TRI1'.
cur_fig = tri2.
shft = - w2 + 1 .
WHEN 'TRI2'.
cur_fig = tri3.
shft = w - w2 .
WHEN 'TRI3'.
cur_fig = tri4.
shft = - w - w2 + 1 .
WHEN 'TRI4'.
cur_fig = tri1.
shft = - w2 .
WHEN 'LGG1'.
cur_fig = lgg2.
shft = - w2 + 1 .
WHEN 'LGG2'.
cur_fig = lgg3.
shft = - w2 .
WHEN 'LGG3'.
cur_fig = lgg4.
shft = - w2 .
WHEN 'LGG4'.
cur_fig = lgg1.
shft = - w2 - 1 .
WHEN 'RGG1'.
cur_fig = rgg2.
shft = - w2 .
WHEN 'RGG2'.
cur_fig = rgg3.
shft = - w2 .
WHEN 'RGG3'.
cur_fig = rgg4.
shft = - w2 + 1 .
WHEN 'RGG4'.
cur_fig = rgg1.
shft = - w2 .
WHEN 'SQUARE'.
cur_fig = square.
shft = - st_width DIV 2 .
ENDCASE.
cur_fig-body1 = start + cur_fig-body1 + shft. "- temp_fig-body1.
cur_fig-body2 = start + cur_fig-body2 + shft. "- temp_fig-body2.
cur_fig-body3 = start + cur_fig-body3 + shft. "- temp_fig-body3.
cur_fig-body4 = start + cur_fig-body4 + shft. "- temp_fig-body4.

PERFORM check_pos CHANGING error.
IF error = 'X'.
cur_fig = temp_fig.
ENDIF.
ENDFORM. " fig_rotate
*&---------------------------------------------------------------------*
*& Form fig_append
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
* --> p1 text
* <-- p2 text
*----------------------------------------------------------------------*
FORM fig_append.
MODIFY stakan FROM 'X' INDEX cur_fig-body1.
MODIFY stakan FROM 'X' INDEX cur_fig-body2.
MODIFY stakan FROM 'X' INDEX cur_fig-body3.
MODIFY stakan FROM 'X' INDEX cur_fig-body4.
ENDFORM. " fig_append
*&---------------------------------------------------------------------*
*& Form check_full_line
*&---------------------------------------------------------------------*
* text
*----------------------------------------------------------------------*
* --> p1 text
* <-- p2 text
*----------------------------------------------------------------------*
FORM check_full_line.
DATA count_line TYPE i.
DATA: n1 TYPE i, n2 TYPE i.
DATA outstring(20).
DATA: s TYPE i, s10 TYPE i, sw TYPE i.
DATA lc TYPE i.
sw = st_width - 2.
CLEAR outstring.
LOOP AT stakan INTO st.
lc = sy-tabix MOD st_width .
IF lc = 1.
s = sy-tabix.
s10 = s + st_width - 1.
ENDIF.
CONCATENATE outstring st INTO outstring.
IF lc = 0.
SEARCH outstring FOR ','.
IF sy-subrc NE 0.
DELETE stakan FROM s TO s10.
ADD 1 TO count_line.
ENDIF.
CLEAR outstring.
ENDIF.
ENDLOOP.

CLEAR: n1, n2.
DO count_line TIMES.
ADD 10 TO n1.
ADD n1 TO n2.
* 10 for one line, 10+20 for two, 10+20+30 for three...
INSERT 'O' INTO stakan INDEX 1.
DO sw TIMES.
INSERT ',' INTO stakan INDEX 1.
ENDDO.
INSERT 'O' INTO stakan INDEX 1.
ENDDO.
ADD n2 TO scores.
ENDFORM. " check_full_line