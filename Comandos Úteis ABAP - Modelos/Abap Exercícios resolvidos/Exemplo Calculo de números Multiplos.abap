********************************************************************************************
*Escrever um programa executável que conta de 1 a 100 e para cada múltiplo de 8 , escrever *
*mensagem: "O número [ número ] é um múltiplo de 8".									   *
*																						   *
*Solution:																				   *
********************************************************************************************
REPORT z_abap101_050.

DATA v_current_number TYPE i VALUE 1.

START-OF-SELECTION.

WHILE v_current_number <= 100.

IF ( v_current_number MOD 8 ) = 0.
WRITE: 'The number', v_current_number, ' is a multiple of 8'.

NEW-LINE.
ENDIF.

ADD 1 TO v_current_number.

ENDWHILE.

