REPORT Z_TESTE_STRINGS.
*Neste exemplo procuramos a palavra “Github" dentro de outro campo string, contamos o numero de ocorrências e usamos parâmetros de caso sensitivo e insensitivo.
*&---------------------------------------------------------------------*
*& Report  ZENCONTRAR
*&
*&---------------------------------------------------------------------*
*& Desenvolvimento Aberto
*& Encontrar Strings
*&---------------------------------------------------------------------*

*REPORT  ZENCONTRAR.

DATA : desc   TYPE c LENGTH 30,
       campo1 TYPE c LENGTH 50,
       campo2 TYPE c LENGTH 50,
       campo3 TYPE c LENGTH 100,
       x      TYPE i.

campo1 = 'Github'.
campo2 = 'github'.
campo3 = 'Você deve encontrar a string Github dentro deste campo Github, Github, Github'.

WRITE : / campo3.

desc = 'Valor default da constante:'.
WRITE : / 'A Constante sy-subrc determina o resultado do comando Find encontrou=0 não encontrou =4',
        / desc, 'sy-subrc = ', sy-subrc.

desc = 'Primeira ocorrencia '.
FIND FIRST OCCURRENCE OF campo1 IN campo3 MATCH COUNT x.
PERFORM resultadoFind USING campo1 x.

desc = 'Todas as ocorrencias'.
FIND ALL OCCURRENCES OF  campo1 IN campo3 MATCH COUNT x.
PERFORM resultadoFind USING campo1 x.

desc = 'Ignora Case'.
FIND campo2 IN campo3 IGNORING CASE MATCH COUNT x.
PERFORM resultadoFind USING campo2 x.

desc = 'Respeita Case'.
FIND campo2 IN campo3 RESPECTING CASE MATCH COUNT x.
PERFORM resultadoFind USING campo2 x.

REPLACE ALL OCCURRENCES OF campo1 IN campo3 With 'Banana'.
WRITE : / 'O campo3 foi modificado para:',
        / campo3.

FORM resultadoFind USING VALUE(X1) VALUE(X2).
   IF sy-subrc EQ 0.
      WRITE : / sy-subrc, X1, desc, ' encontrou', X2, 'strings'.
   ELSE.
      WRITE : / sy-subrc, X1, desc, ' não encontrou', X2, 'strings'.
   ENDIF.
ENDFORM.
