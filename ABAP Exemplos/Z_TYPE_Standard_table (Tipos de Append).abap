*&---------------------------------------------------------------------*
*& Report  ZTABELAINTERNA
*&
*&---------------------------------------------------------------------*
*& Desenvolvimento Aberto
*& Tabelas Internas
*&---------------------------------------------------------------------*
 
REPORT  ZTABELAINTERNA.
 
* Tabela Scarr é uma tabela de informações de linhas aéreas
* Utilize SE11 para visualizar a tabela e tipo de dados no ABAP Dictionary.
* Criar uma tabela interna do mesmo tipo que Scarr:
 
DATA i_minhatabela TYPE STANDARD TABLE OF scarr.
 
* Criar uma estrutura que corresponda às colunas contidas na tabela interna
* Abap usa a variavel matriz como uma ARRAY:
 
DATA matriz LIKE LINE OF i_minhatabela.
 
* INSERT - Insere valores aos campos da tabela interna.
 
matriz-mandt        = '001'.
matriz-carrid       = '2002'.
matriz-carrname     = 'Dev. Aberto AirLine.'.
matriz-currcode     = 'Euro'.
matriz-url          = 'http://desenvolvimentoaberto.wordpress.com/'.
INSERT matriz INTO TABLE i_minhatabela.
 
* APPEND - adiciona valores aos campos da tabela interna.
 
APPEND INITIAL LINE TO i_minhatabela.
matriz-mandt        = '001'.
matriz-carrid       = '122'.
matriz-carrname     = 'Aviação DA airlines S/A.'.
matriz-currcode     = 'Real'.
matriz-url          = 'http://desenvolvimentoaberto.wordpress.com/'.
APPEND matriz TO i_minhatabela.
 
* Deleta matriz em branco, comente a linha abaixo para ver o espaço em branco
 
DELETE i_minhatabela WHERE mandt =''.
 
* MODIFY - modifica dados nas tabelas.
 
matriz-currcode = 'Euro'.
MODIFY i_minhatabela FROM matriz TRANSPORTING currcode  WHERE currcode = 'Real'.
 
* Escrever o conteúdo da tabela interna para a tela como uma lista
LOOP AT i_minhatabela INTO matriz.
    WRITE: / 'Mandante', matriz-mandt, / 'Id:', matriz-carrid, / 'Empresa Aerea:', matriz-carrname,
           / 'Código da moeda:', matriz-currcode, / 'Url da empresa:', matriz-url, / .
ENDLOOP.