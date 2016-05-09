*&---------------------------------------------------------------------*
*& Report  Z_TESTE_MW
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT z_teste_mw.

DATA: lt_tab TYPE TABLE OF tline.
DATA: fault   TYPE REF TO cx_ai_system_fault.
DATA: fault2  TYPE REF TO cx_sy_rmc_system_failure.
DATA: fault3  TYPE REF TO cx_wrf_pbas_system_failure.

DATA l_rfcmsg     TYPE c LENGTH 120.

TRY .
    CALL FUNCTION 'ZPI_QUADREM_START_RFQ'
      DESTINATION 'SAPPI'
      EXPORTING
        t_proxy               = lt_tab
      EXCEPTIONS			"è só adiconar essas excetions na chamda. Elas nao precisam existir na função
        system_failure        = 1  MESSAGE l_rfcmsg
        communication_failure = 2  MESSAGE l_rfcmsg
        OTHERS                = 3.

    WRITE: / l_rfcmsg.

  CATCH cx_ai_system_fault INTO fault.
    DATA: l_erro_exec TYPE string.
    CREATE OBJECT fault.
    l_erro_exec = fault->get_text( ).

    WRITE: / l_erro_exec.

  CATCH cx_sy_rmc_system_failure INTO fault2.
    DATA: l_erro_exec2 TYPE string.
    CREATE OBJECT fault2.
    l_erro_exec2 = fault2->get_text( ).

    WRITE: / l_erro_exec2.

  CATCH cx_wrf_pbas_system_failure INTO fault3.
    DATA: l_erro_exec3 TYPE string.
    CREATE OBJECT fault3.
    l_erro_exec3 = fault3->get_text( ).

    WRITE: / l_erro_exec3.

ENDTRY.