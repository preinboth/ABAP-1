 ABAP OLE - Excel.application
  "  Bom dia galera mais que tri-legal, vou passa hoje pra vocês algo muito
" legal.... Sabe quando o funcional chega em você e fala :  ..... e no final
" essa tabela tem que criar um arquivo excel.... Logo que ele fala isso
" ja pensamos :  .... Sussa, vou cria um alv e exportar, ou no máximo
" usar uma função que exporta pra um excel.... fácil....
"  Mas como a gente sabe a vida de ABAP nunca é tão fácil assim...
" o funcional já com uma cara de ironia fala :   .... o Excel tem que estar
" neste formato ..... e mostra pra você um formulário bunitão cheio de
" bordas, cores, tamanho, linhas e colunas mescladas..... e seu mundo
" desmorona, já começa a pensar que vai ter que sair mais tarde varios dias
" e quem sabe com isso pode até perder a(o) namorada(o). Pois seus problemas
" acabaram pois este post mostra como fazer um com tratativas em suas
" propriedades.
" primeiramente vá na transação se11 e veja na tabela TOLE se existe algum
" APP chamado 'EXCEL.APPLICATION', se tiver ... parabéns você está
" habilitado a prosseguir com este post. ( Pode ser pela transação SOLE tb )
"  Diferentemente neste Post eu não coloquei Break-points espalhados, portanto,
" debbuggem vocês mesmo onde acharem melhor. vamo lá então.
"  Essa é pra fecha o mês com chave de Ouro.

REPORT z_abap_excel.
*----------------------------------------------------------------------*
*  Conjunto de tipos
*----------------------------------------------------------------------*
"  Tem um include que a maioria trabalho mas eu prefiro o Grupo de tipo.
TYPE-POOLS ole2.

*----------------------------------------------------------------------*
*  Tabelas transparentes
*----------------------------------------------------------------------*
TABLES :
  sflight.

*----------------------------------------------------------------------*
*  Tabelas internas
*----------------------------------------------------------------------*
DATA :
 it_spfli   TYPE TABLE OF spfli,
 it_sflight TYPE TABLE OF sflight
.
*----------------------------------------------------------------------*
*  Estruturas
*----------------------------------------------------------------------*
DATA :
 st_spfli   TYPE spfli,
 st_sflight TYPE sflight
.

*----------------------------------------------------------------------*
*  Declarações de variáveis
*----------------------------------------------------------------------*
DATA : linha   TYPE i,      " Atribui Valor Linha
       coluna  TYPE i,
       v_texto TYPE string            " Conteudo das celulas
       .
*----------------------------------------------------------------------*
*  Definições de objetos OLE2
*----------------------------------------------------------------------*
DATA: gs_excel        TYPE ole2_object,       " Objeto Excel
      gs_workbook     TYPE ole2_object,       " Workbook 'Area de trabalho'
      gs_sheet        TYPE ole2_object,       " Planilha
      gs_cell1        TYPE ole2_object,                     " Celula 1
      gs_cell2        TYPE ole2_object,                     " Celula 2
      gs_cells        TYPE ole2_object,       " Células
      gs_range        TYPE ole2_object,       " Grupo de células
      gs_font         TYPE ole2_object,       " Fonte da célula
      gs_column       TYPE ole2_object.       " Coluna da célula


SELECTION-SCREEN BEGIN OF BLOCK b1.
PARAMETERS:
  p_carrid TYPE sflight-carrid OBLIGATORY.
SELECT-OPTIONS:
  s_connid FOR sflight-connid,
  s_fldate FOR sflight-fldate.
SELECTION-SCREEN END OF BLOCK   b1.

START-OF-SELECTION.

* select dos dados
  PERFORM selects.

  IF it_sflight IS NOT INITIAL.

* Cria o objeto Excel com area de trabalho e planilhas.
    PERFORM f_gera_excel.

* Agora com a planilha pronta vamos formatar as colunas do excel.
    PERFORM formata_colunas.

* Eu criei um perform só pra trata o cabeçalho pra fica mais legível.
    PERFORM gera_cabecalho.

* Gera linhas
    PERFORM gera_linhas.

* Encerra planilha Excel
    PERFORM encerra_planilha_excel.

  ELSE.

    MESSAGE 'Não foi encontrado dados na tabela conforme críterios da tela de seleção'
      TYPE 'I'.

  ENDIF.

END-OF-SELECTION.




*&---------------------------------------------------------------------*
*&      Form  F_GERA_EXCEL
*&---------------------------------------------------------------------*
FORM f_gera_excel .

  " Criação do objeto Excel.
  CREATE OBJECT gs_excel 'Excel.Application'.

  "  É um parametro do objeto Excel para que seja mostrado o arquivo excel
  " somente quando carregar por completo.
  SET PROPERTY OF gs_excel 'ScreenUpdating'   = 0.

  " Deixa ativo o excel
  SET PROPERTY OF gs_excel 'Visible'   = 1.
  "  Aqui é pego a parametro area de trabalho do Excel e passado para uma
  " variável.
  GET PROPERTY OF gs_excel 'Workbooks' = gs_workbook.
  " Agora com essa variavel você chama um método da classe para que seja
  " adicionado uma área de trabalho.
  CALL METHOD OF gs_workbook 'Add'.
  " Perform para verificação de erros.
  PERFORM err_hdl.
  " Toda essa parte acima é só pra abilitar e abrir o excel.

  " Entrando no nivel planila do excel passada para uma variável.
  CALL METHOD OF gs_excel 'Worksheets' = gs_sheet.
  " Criação de uma aba de planilha para área de trabalho.
  CALL METHOD OF gs_sheet 'Add' = gs_sheet.
  " Modifica a propriedade nome da aba para 'ABA Nova'
  SET PROPERTY OF gs_sheet 'Name' = 'ABA Nova'.
  " Perform para verificação de erros.
  PERFORM err_hdl.


ENDFORM.                    " F_GERA_EXCEL
*&---------------------------------------------------------------------*
*&      Form  ERR_HDL
*&---------------------------------------------------------------------*
FORM err_hdl .

  " Deu problema ?
  IF sy-subrc <> 0.
    " Erro ....
    WRITE: / 'Erro na abertura OLE-Automation(EXCEL):', sy-subrc.
    " Famoso João Kleber ---- Pára, Pára, Pára tuuudo..
    STOP.
  ENDIF.

ENDFORM.                    " ERR_HDL

*&---------------------------------------------------------------------*
*&      Form  FORMATA_COLUNAS
*&---------------------------------------------------------------------*
FORM formata_colunas .

  "  Eu criei um perform para que fique mais facil de trabalhar....
  " Aki estarei trabalhando inteiramente com a coluna 'E' passando o
  " tamanho '33'.
  PERFORM formata_largura USING 'E:E' '33'.

ENDFORM.                    " FORMATA_COLUNAS

*&---------------------------------------------------------------------*
*&      Form  FORMATA_LARGURA
*&---------------------------------------------------------------------*
FORM formata_largura  USING  coluna
                             largura.
  " Uso metodo para fazer um intervalo passando a coluna desejada.
  CALL METHOD OF gs_excel 'Range' = gs_range
    EXPORTING
    #1 = coluna.
  " Estou modificando uma das propriedades deste intervalo e informando a lagura.
  SET PROPERTY OF gs_range 'ColumnWidth' = largura.


ENDFORM.                    " FORMATA_LARGURA

*&---------------------------------------------------------------------*
*&      Form  GERA_CABECALHO
*&---------------------------------------------------------------------*
FORM gera_cabecalho .
*&---------------------------------------------------------------------*
  linha = linha + 1.

  "  Trata a primeira linha da planilha ( Cabeçalho ).
  v_texto = 'Titulo do Excel.'.
  PERFORM preenche_titulo USING linha 1 linha 5  v_texto.

*&---------------------------------------------------------------------*
  linha = linha + 2.

  " Trata um segundo cabeçalho.
  CONCATENATE : 'Dados Denominação breve da companhia aérea :' p_carrid
    INTO v_texto SEPARATED BY space.
  PERFORM preenche_titulo USING linha 1 linha 5  v_texto.


*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
  linha  = linha  + 2.

  coluna = coluna + 1.
  v_texto = 'Carrid'.
  PERFORM preenche_titulo USING linha coluna linha coluna  v_texto.
*&---------------------------------------------------------------------*
  coluna = coluna + 1.
  v_texto = 'Connid'.
  PERFORM preenche_titulo USING linha coluna linha coluna  v_texto.
*&---------------------------------------------------------------------*
  coluna = coluna + 1.
  v_texto = 'Fldate'.
  PERFORM preenche_titulo USING linha coluna linha coluna  v_texto.
*&---------------------------------------------------------------------*
  coluna = coluna + 1.
  v_texto = 'Price'.
  PERFORM preenche_titulo USING linha coluna linha coluna  v_texto.
*&---------------------------------------------------------------------*
  coluna = coluna + 1.
  v_texto = 'Paymentsum'.
  PERFORM preenche_titulo USING linha coluna linha coluna  v_texto.

ENDFORM.                    " GERA_CABECALHO

*&---------------------------------------------------------------------*
*&      Form  PREENCHE_TITULO
*&---------------------------------------------------------------------*
FORM preenche_titulo  USING linha1
                            coluna1
                            linha2
                            coluna2
                            texto.

* Mescla células selecionadas
  " Primeiro seleciona a primeira celula
  PERFORM seleciona_celula USING linha1 coluna1 gs_cell1.
  " Depois seleciona a segunda celula
  PERFORM seleciona_celula USING linha2 coluna2 gs_cell2.
  " Mescla as duas celulas juntamente com seu intervalo caso tenha
  PERFORM mescla_celulas.

* Coloca borda
  PERFORM cria_borda USING gs_cell1 gs_cell2 gs_cells.

* Preenche célula
  PERFORM preenche_celula USING gs_cell1 1 3 0 12 texto.


ENDFORM.                    " PREENCHE_TITULO

*&---------------------------------------------------------------------*
*&      Form  SELECIONA_CELULA
*&---------------------------------------------------------------------*
FORM seleciona_celula  USING    linha
                                coluna
                                celula.

* Seleciona célula
  CALL METHOD OF gs_excel 'Cells' = celula
    EXPORTING
    #1 = linha
    #2 = coluna.

ENDFORM.                    " SELECIONA_CELULA

*&---------------------------------------------------------------------*
*&      Form  MESCLA_CELULAS
*&---------------------------------------------------------------------*
FORM mescla_celulas .

* Passa que é um intervalo entre estes dois campos.
  CALL METHOD OF gs_excel 'Range' = gs_cells
    EXPORTING
    #1 = gs_cell1
    #2 = gs_cell2.

* Mescla células do intevalos acima.
  CALL METHOD OF gs_cells 'Merge' = gs_cells.

ENDFORM.                    " MESCLA_CELULAS
*&---------------------------------------------------------------------*
*&      Form  CRIA_BORDA
*&---------------------------------------------------------------------*
FORM cria_borda  USING    celula1
                          celula2
                          celula.

* Seleciona o intervalo de células
  CALL METHOD OF gs_excel 'Range' = celula
    EXPORTING
    #1 = celula1
    #2 = celula2.

* Cria borda e os valores de exportação são cor e intensidade.
  CALL METHOD OF celula 'BorderAround'
    EXPORTING
    #1 = 1
    #2 = 3.


ENDFORM.                    " CRIA_BORDA

*&---------------------------------------------------------------------*
*&      Form  PREENCHE_CELULA
*&---------------------------------------------------------------------*
FORM preenche_celula  USING celula
                            bold
                            alinhamento
                            largura
                            tam
                            valor.

* Formata célula
  GET PROPERTY OF celula  'Font' = gs_font.
  SET PROPERTY OF gs_font 'Bold' = bold.
  SET PROPERTY OF gs_font 'Size' = tam.
  SET PROPERTY OF celula  'HorizontalAlignment' = alinhamento.
  SET PROPERTY OF celula  'NumberFormat' = '@'.
* Preenche célula
  SET PROPERTY OF celula  'Value' = valor.


ENDFORM.                    " PREENCHE_CELULA

*&---------------------------------------------------------------------*
*&      Form  SELECTS
*&---------------------------------------------------------------------*
FORM selects .

  SELECT *
    FROM sflight
    INTO TABLE it_sflight
    WHERE carrid =  p_carrid
      AND connid IN s_connid
      AND fldate IN s_fldate
    .

ENDFORM.                    " SELECTS

*&---------------------------------------------------------------------*
*&      Form  MONTA_LINHAS
*&---------------------------------------------------------------------*
FORM monta_linhas .

  " 1ª coluna de dados da linha correspondente
  PERFORM preenche_detalhe USING linha 1 0 0 7 3 st_sflight-carrid.
  " 2ª coluna de dados da linha correspondente
  PERFORM preenche_detalhe USING linha 2 0 0 7 3 st_sflight-connid.
  " 3ª coluna de dados da linha correspondente
  PERFORM preenche_detalhe USING linha 3 0 0 7 3 st_sflight-fldate.
  " 4ª coluna de dados da linha correspondente
  PERFORM preenche_detalhe USING linha 4 0 0 7 3 st_sflight-price.
  " 5ª coluna de dados da linha correspondente
  PERFORM preenche_detalhe USING linha 5 0 0 7 3 st_sflight-paymentsum.

ENDFORM.                    " MONTA_LINHAS

*&---------------------------------------------------------------------*
*&      Form  PREENCHE_DETALHE
*&---------------------------------------------------------------------*
FORM preenche_detalhe  USING linha
                             coluna
                             bold
                             largura
                             tam
                             alinhamento
                             conteudo.

* Seleciona célula
  PERFORM seleciona_celula USING linha coluna gs_cell1.

* Preenche célula
  PERFORM preenche_celula USING gs_cell1 bold alinhamento
                                largura tam conteudo.

ENDFORM.                    " PREENCHE_DETALHE

*&---------------------------------------------------------------------*
*&      Form  GERA_LINHAS
*&---------------------------------------------------------------------*
FORM gera_linhas .

  LOOP AT it_sflight INTO st_sflight.

    " Cada registro da tabela será uma linha do excel.
    linha = linha + 1.
    PERFORM monta_linhas.

  ENDLOOP.

ENDFORM.                    " GERA_LINHAS

*&---------------------------------------------------------------------*
*&      Form  ENCERRA_PLANILHA_EXCEL
*&---------------------------------------------------------------------*
FORM encerra_planilha_excel .

  " Faz com que a planilha só aparece quando terminar de ser alimentada.
  SET PROPERTY OF gs_excel 'ScreenUpdating'   = 1.

  " Libera os cara aee.
  FREE OBJECT gs_sheet.
  FREE OBJECT gs_workbook.
  FREE OBJECT gs_excel.


ENDFORM.                    " ENCERRA_PLANILHA_EXCEL