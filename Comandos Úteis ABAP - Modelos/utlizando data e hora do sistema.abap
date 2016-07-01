*&---------------------------------------------------------------------*
*& Report  ZDARIOTESTE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z__TESTE.


data:
      x type string, y type integer, novaData TYPE date.

*-----------------------------------------------------------------------*
* Utilizando data e hora do Sistema
*-----------------------------------------------------------------------*
novaData = SY-DATUM . "data do sistema no formato YYYYMMDD
write novaData.

if SY-UZEIT > '120000' and SY-UZEIT < '180000'.
  write 'Olá amigo! Boa Tarde'.
elseif SY-UZEIT > '180000' and SY-UZEIT < '240000'.
  write 'Olá amigo! Boa Noite'.
elseif SY-UZEIT > '000000' and SY-UZEIT < '120000'.
  write 'Olá amigo! Bom Dia'.
endif.

do 10 times.

   y = y + 1.

   if y < 6 .
     CONTINUE. "volta o processamento para o topo do loop
   endif.

   WRITE y.
enddo.