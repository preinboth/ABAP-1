*&---------------------------------------------------------------------*
*& Report  ZMMARIANO4
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zmmariano4.


INFOTYPES: 0000,
           0001,
           0002.




TABLES: pernr.


INITIALIZATION.



*RP-SET-DATA-INTERVAL 'P0001 SY-DATUM SY-DATUM    - Fixar data válida para um Infotipo específico
*RP-SET-DATA-INTERVAL 'ALL' SY-DATUM SY-DATUM   - Fixar data válida para todos os Infotipos
*
*RP-PROVIDE-FROM-FRST P0001 SPACE PN-BEGDA PN-ENDDA   - Primeiro registro do Infotipo
*RP-PROVIDE-FROM-LAFRSTST P0001 SPACE PN-BEGDA PN-ENDDA	-	Ultimo registro do Infotipo
*
*PNP-SW-FOUND                 -   Se diferente de 0 encontrou algum registro
*
*REJECT.     "como se fosse o continue
*
*PROVIDE * FROM P0001 BETWEEN PN-BEGDA AND PN-ENDDA	-	Loop em um Infotipo

*ENDPROVIDE.

  PARAMETERS: p_teste AS CHECKBOX.

START-OF-SELECTION.
  rp-set-data-interval 'P0001' pn-begda pn-endda.


GET  pernr.


  rp-provide-from-frst p0001 space pn-begda pn-endda.
  IF pnp-sw-found EQ 0.
    REJECT.     "como se fosse o continue
  ENDIF.


  BREAK-POINT.

END-OF-SELECTION.