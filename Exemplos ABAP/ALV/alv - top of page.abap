ALV - Top of Page
  *----------------------------------------------------------------------*
"  Conforme pedido por email estarei falando sobre a inclusão de cabeçalho
" num ALV, basicamente e declarar um form no parametro 'i_callback_top_of_page'
" da função 'REUSE_ALV_GRID_DISPLAY', dentro deste form terá uma outra função
" chamada 'REUSE_ALV_COMMENTARY_WRITE' que é uma função muito simples, vamos lá.

REPORT z_topofpage_alv.

" Tabelas transparentes ....
TABLES : mara
  .
" type-pools .....
" Essa declaração e necessária pois e o grupo de tipos usados no ALV.
TYPE-POOLS: slis
           .

" Tipos .....
TYPES :

  BEGIN OF ty_mara,
    matnr TYPE mara-matnr,  " Nº do material
    ersda TYPE mara-ersda,  " Data de criação
    ernam TYPE mara-ernam,  " Nome do responsável que adicionou o objeto
    pstat TYPE mara-pstat,  " Status de atualização
    mtart TYPE mara-mtart,  " Tipo de material
  END OF   ty_mara .

" Estruturas ....
DATA : st_mara TYPE ty_mara
      .

" Tabelas Internas ....
DATA : it_mara TYPE TABLE OF ty_mara
      .

" Declarações usadas no ALV.
DATA : it_fieldcat TYPE slis_t_fieldcat_alv,
       st_fieldcat TYPE slis_fieldcat_alv,
       st_layout   TYPE slis_layout_alv
      .

" Tela de seleção .....
SELECTION-SCREEN BEGIN OF BLOCK b1.
SELECT-OPTIONS :
    so_matnr FOR mara-matnr NO INTERVALS,   " Nº do material
    so_pstat FOR mara-pstat NO INTERVALS    " Status de atualização
                .

SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.

  PERFORM : z_feed_table,
            z_layout,
            z_fieldcat,
            z_alv
           .

*&---------------------------------------------------------------------*
*&      Form  z_feed_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM z_feed_table .

  SELECT matnr
         ersda
         ernam
         pstat
         mtart
    INTO TABLE it_mara
    FROM mara
    UP TO 100 ROWS
    WHERE matnr IN so_matnr
    AND   pstat IN so_pstat
    .

ENDFORM.                    " Z_feed_table


*&---------------------------------------------------------------------*
*&      Form  Z_LAYOUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM z_layout .

  st_layout-colwidth_optimize = 'X'.
  st_layout-zebra             = 'X'.

ENDFORM.                    " Z_LAYOUT


*&---------------------------------------------------------------------*
*&      Form  Z_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM z_fieldcat .

  PERFORM z_feed_fieldcat USING :
    "Fname  Seltext                 check   Edit  Col_pos
    'MATNR' 'Material'              ' '    ' '    0        ,
    'ERSDA' 'Data de criação'       ' '    ' '    1        ,
    'ERNAM' 'Nome do responsável'   ' '    ' '    2        ,
    'PSTAT' 'Status'                ' '    ' '    3        ,
    'MTART' 'Tipo de material'      ' '    ' '    4
            .

ENDFORM.                    " Z_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  Z_FEED_FIELDCAT
*&---------------------------------------------------------------------*
FORM z_feed_fieldcat  USING    fieldname
                               seltext_m
                               checkbox
                               edit
                               col_pos .

  st_fieldcat-fieldname   = fieldname.      " Nome do campo
  st_fieldcat-seltext_m   = seltext_m.      " texto do campo
  st_fieldcat-checkbox    = checkbox.       " se o campo é do tipo CheckBox
  st_fieldcat-edit        = edit.           " se o campo pode ser editavel
  st_fieldcat-col_pos     = col_pos.        "Em que posição fica a coluna
  " Coloca a estrutura alimentada na Tabela.
  APPEND st_fieldcat TO it_fieldcat.
  " Limpa a estrutura e volta pra poxima linha do form.
  CLEAR  st_fieldcat.
ENDFORM.                    " Z_FEED_FIELDCAT

*&---------------------------------------------------------------------*
*&      Form  Z_ALV
*&---------------------------------------------------------------------*

FORM z_alv .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
     EXPORTING
*   I_INTERFACE_CHECK                 = ' '
*   I_BYPASSING_BUFFER                = ' '
*   I_BUFFER_ACTIVE                   = ' '
      i_callback_program                = sy-repid    " Nome do programa
*   i_callback_pf_status_set          = ' '
*   i_callback_user_command           = ' '

" Declare o form!!!!
     i_callback_top_of_page            = 'TOP-OF-PAGE'

*   I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*   I_CALLBACK_HTML_END_OF_LIST       = ' '
*   I_STRUCTURE_NAME                  =
*   I_BACKGROUND_ID                   = ' '
*   I_GRID_TITLE                      =
*   I_GRID_SETTINGS                   =
"  Post sobre Layout ALV -
" http://abapjuniores.blogspot.com/2011/07/alv-layout_14.html
      is_layout                         = st_layout
"  Post Sobre Fieldcat ALV -
" http://abapjuniores.blogspot.com/2011/06/alv-parte-1.html
      it_fieldcat                       = it_fieldcat
*   IT_EXCLUDING                      =
*   IT_SPECIAL_GROUPS                 =
*   IT_SORT                           =
*   IT_FILTER                         =
*   IS_SEL_HIDE                       =
*   I_DEFAULT                         = 'X'
*   i_save                            = 'X'
*   IS_VARIANT                        =
*   IT_EVENTS                         =
*   IT_EVENT_EXIT                     =
*   IS_PRINT                          =
*   IS_REPREP_ID                      =
*   I_SCREEN_START_COLUMN             = 0
*   I_SCREEN_START_LINE               = 0
*   I_SCREEN_END_COLUMN               = 0
*   I_SCREEN_END_LINE                 = 0
*   I_HTML_HEIGHT_TOP                 = 0
*   I_HTML_HEIGHT_END                 = 0
*   IT_ALV_GRAPHICS                   =
*   IT_HYPERLINK                      =
*   IT_ADD_FIELDCAT                   =
*   IT_EXCEPT_QINFO                   =
*   IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER           =
*   ES_EXIT_CAUSED_BY_USER            =
      TABLES
        t_outtab                          = it_mara   " Tabela com os dados
     EXCEPTIONS
       program_error                     = 1
       OTHERS                            = 2
              .
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

ENDFORM.                    " Z_ALV

*&---------------------------------------------------------------------*
*&      Form  TOP-OF-PAGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM top-of-page.
* Declarações locais do cabeçalho do ALV
  DATA:
        it_header TYPE slis_t_listheader,
        st_header TYPE slis_listheader,
        t_line    LIKE st_header-info,
        ld_lines  TYPE i,
        ld_linesc(10) TYPE c.

"  Entrando no tipo da estrutura do header (slis_listheader), você verá
" que esta estrutura tem 3 tipos e eu explicarei cada um deles abaixo.

"  Titulo ( H )
" Vai ser a linha que mais chama a atenção dentro do Cabeçalho, pois será
" maior e em negrito.
  st_header-typ  = 'H'.
  st_header-info = 'Titulo do ALV'.
  APPEND st_header TO it_header.
  CLEAR st_header.

" Informações ( S )
"  Como se fosse o texto para comentários, descrição de algo, somente no
" tipo 'S' o campo 'KEY' faz algo, ele serve como inicio da sua frase e fica
" em negrito se diferenciando do resto da linha.
  st_header-typ  = 'S'.
  st_header-key = 'Usuáio: '.
  st_header-info = sy-uname." User name
  APPEND st_header TO it_header.
  CLEAR: st_header.


* Total de linhas
  DESCRIBE TABLE it_mara LINES ld_lines.
  ld_linesc = ld_lines.
  CONCATENATE 'Total de linhas : ' ld_linesc
     INTO t_line SEPARATED BY space.


" Ação ( A )
"  Como se fosse informações extras, tem o tamanho menor que os outros e
" está em itálico, veja que o campo 'KEY' foi informado mas no final não
" servir´pa para nada pois não é do tipo  ( S ).

  st_header-typ  = 'A'.
  st_header-key  = 'Teste'.
  st_header-info = t_line.
  APPEND st_header TO it_header.
  CLEAR: st_header, t_line.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary       = it_header
*     I_LOGO                   =
*     I_END_OF_LIST_GRID       =
*     i_alv_form               = 'X'
            .

"  Ai está a função que vai junta tudo isso e mostra no inicio da página,
" podemos até adicionar uma imagem que esteja no banco SAP ( OAER ), Mas
" isso é assunto para um próximo Post,
" Qualquer dúvida estamos aih.