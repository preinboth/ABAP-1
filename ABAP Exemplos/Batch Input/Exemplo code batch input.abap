*&---------------------------------------------------------------------*
REPORT zmj_batch.

" Tipos ....
TYPES:
" Dados que serão informados pelo arquivo.
  BEGIN OF ty_arqui,
    cliente TYPE rf02d-kunnr,        " Código do Cliente
    nome    TYPE kna1-name1,         " Nome do cliente
    rua     TYPE kna1-stras,         " Rua do cliente
    end     TYPE kna1-ort01,         " Endereço do cliente
    tel     TYPE kna1-telf1,         " telefone do cliente
  END OF ty_arqui,

" Batch input nova estrutura do campo de tabela
  BEGIN OF ty_bdcdata,
    program   TYPE bdcdata-program,  " Pool de módulos BDC
    dynpro    TYPE bdcdata-dynpro,   " NÚmero de tela BDC
    dynbegin  TYPE bdcdata-dynbegin, " Início BDC de uma tela
    fnam      TYPE bdcdata-fnam,     " Nome do campo
    fval      TYPE bdcdata-fval,     " Valor do campo BDC
  END OF ty_bdcdata,

" Relação informativa do log
  BEGIN OF ty_message,
    cliente TYPE rf02d-kunnr,        " Código do cliente
    msgty   TYPE message-msgty,      " Tipo da mensagem
    msgno   TYPE message-msgno,      " Numero da mensagem
    msgtx   TYPE message-msgtx,      " Descrição da mensagem
  END OF   ty_message
    .

" Tabelas Internas ....
DATA: it_arqui    TYPE TABLE OF ty_arqui,
      it_bdcdata  TYPE TABLE OF ty_bdcdata,
      it_msg      TYPE TABLE OF bdcmsgcoll WITH HEADER LINE,
      it_message  TYPE TABLE OF ty_message
        .
" Tabela que recebe as informações crua do arquivo que será tratado
DATA: BEGIN OF t_line OCCURS 0,
        linha(108) TYPE c,
      END OF t_line
        .

" Estruturas ...
DATA: st_arqui   TYPE ty_arqui,
      st_bdcdata TYPE ty_bdcdata,
      st_message TYPE ty_message
        .

" Variaveis ....
DATA: vg_mode(1) TYPE c VALUE 'N', " informa o Modo do Call Transaction
      vg_texto(100) TYPE c,        " Texto para o Indicator
      vg_s TYPE c VALUE 'S',       " Informa o Update do call Transaction
      mensg LIKE message VALUE IS INITIAL, " variavel que recebe retorno
      msgno LIKE sy-msgno
        .


" Tela de Seleção ....
" texto (
SELECTION-SCREEN BEGIN OF BLOCK a WITH FRAME TITLE text-001.
PARAMETERS:    p_dest TYPE string, " Texto ( Arquivo txt: )
               p_log  TYPE string  " Texto ( Arquivo log: )
                 .
SELECTION-SCREEN END OF BLOCK a.

" Quando for requisitado um valor no 'Parameter faça ...
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_dest.
  PERFORM z_busca_arquivo.

" Quando for requisitado um valor no 'Parameter faça ...
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_log.
  PERFORM z_mostra_local.

"  Começa aki ...
START-OF-SELECTION.
  PERFORM: z_baixa_arquivo,
           z_trata_arquivo,
           z_monta_shdb,
           z_manda_arquivo
           .

*&---------------------------------------------------------------------*
*&      Form  z_busca_arquivo
*&---------------------------------------------------------------------*
  "  Pega o valor contido no parameters e add o texto '.txt' no final assim o
  " o nome do arquivo fica com a extensão desejada.
  FORM z_busca_arquivo.
  CONCATENATE p_dest '.txt' INTO p_dest.
  CALL FUNCTION 'WS_FILENAME_GET'
       EXPORTING
            def_filename = ' '
            def_path     = 'C:\'
            mask         = ',Texto,*.txt,Todos,*.*.'
            mode         = 'O'
            title        = 'Arquivo de Entrada'(004)
       IMPORTING
            filename     = p_dest
       EXCEPTIONS
            OTHERS.

ENDFORM.                    " z_busca_local

*&---------------------------------------------------------------------*
*&      Form  z_mostra_local
*&---------------------------------------------------------------------*
  " Mostra o local onde será gravado o arquivo de Log.
FORM z_mostra_local .
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = 'Informar o caminho para gerar o arquivo'
      initial_folder       = 'C:\'
    CHANGING
      selected_folder      = p_log
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  " Nome do Arquivo do Log contendo o endereço+NOME1+HORA+.TXT.
  CONCATENATE  p_log '\' sy-uname '_' sy-uzeit '.TXT' INTO p_log
          .

ENDFORM.                    " Z_MOSTRA_LOCAL

*&---------------------------------------------------------------------*
*&      Form  Z_MONTA_ARQUIVO
*&---------------------------------------------------------------------*
"  Pega o arquivo externo relacionado e coloca os dados na 'T_LINE
FORM z_baixa_arquivo.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename = p_dest
    TABLES
      data_tab = t_line
    EXCEPTIONS
      OTHERS   = 17.

ENDFORM.                    " Z_MONTA_ARQUIVO

*&---------------------------------------------------------------------*
*&      Form  Z_TRATA_ARQUIVO
*&---------------------------------------------------------------------*
"  Será os dados conforme sequencia de campos e add na tabela principal
FORM z_trata_arquivo.
  LOOP AT t_line.
    " o Split quebra a linha e separa por delimitador ';' colocando cada dado
    " em cada campo sequencialmente.
    SPLIT t_line AT ';' INTO: st_arqui-cliente
                              st_arqui-nome
                              st_arqui-rua
                              st_arqui-end
                              st_arqui-tel
                              .
    " Add registro na tabela.
    APPEND st_arqui TO it_arqui.

  ENDLOOP.
ENDFORM.                    " Z_TRATA_ARQUIVO
*&---------------------------------------------------------------------*
*&      Form  z_monta_shdb
*&---------------------------------------------------------------------*
FORM z_monta_shdb.

  LOOP AT it_arqui INTO st_arqui.
    " cria uma variavel pra informar qual cliente está porcessando no
    " perform z_sapgui_progress_indicator.
    CONCATENATE 'Processando o Cliente -' st_arqui-cliente
    INTO vg_texto SEPARATED BY space.
    "  informa o processo atual
    PERFORM z_sapgui_progress_indicator USING vg_texto.
    " É aki que o bixo pega, lembra dakele arquivo SHDB que enviaram pra vc
    " é aki que ele começa a faze sentido, oq nós estamos fazendo aki e criando
    " uma tabela com as informações conforme o SHDB só mundando a informação
    " que vc quer que mude conforme o registro.
    "  Depois de terminar os performs z_preenche_bdc vc vai dar uma olhada
    " na tabela it_bdcdata pq ela vai estar igualzinha com o SHDB que
    " enviaram pra vc.
    " Crie um 'Perform pra cada tela que tiver no SHDB.
    PERFORM z_preenche_bdc USING:

      'X'    'SAPMF02D'       '0101',
      ' '    'BDC_CURSOR'     'RF02D-D0110',
      ' '    'BDC_OKCODE'     '/00',
      ' '    'RF02D-KUNNR'    st_arqui-cliente,
      ' '    'RF02D-D0110'    'X'.

    PERFORM z_preenche_bdc USING:

      'X'    'SAPMF02D'        '0110',
      ' '    'BDC_CURSOR'      'KNA1-TELF1',
      ' '    'BDC_OKCODE'      '/00',
      ' '    'KNA1-NAME1'     st_arqui-nome,
      ' '    'KNA1-STRAS'     st_arqui-rua,
      ' '    'KNA1-ORT01'     st_arqui-end,
      ' '    'KNA1-TELF1'      st_arqui-tel.

    PERFORM z_carrega_transacao.
    PERFORM z_imprime_mensagem.

    CLEAR it_bdcdata.

  ENDLOOP.
ENDFORM.                    " z_monta_shdb
*&---------------------------------------------------------------------*
*&      Form  Z_PREENCHE_BDC
*&---------------------------------------------------------------------*
"  Se Dynbegin = 'X' ele preenche as informações da tela, senão ele preenche
" o campo e o dado dela. prontio.
FORM z_preenche_bdc  USING dynbegin
                           name
                           value.
  IF dynbegin = 'X'.
    MOVE: name      TO st_bdcdata-program,
          value     TO st_bdcdata-dynpro,
          dynbegin  TO st_bdcdata-dynbegin.
    APPEND st_bdcdata TO it_bdcdata.
  ELSE.

    MOVE: name  TO st_bdcdata-fnam,
          value TO st_bdcdata-fval.
    APPEND st_bdcdata TO it_bdcdata.

  ENDIF.
"  prepara a estrutura para o Loop.
  CLEAR st_bdcdata.
ENDFORM.                    " Z_PREENCHE_BDC
*&---------------------------------------------------------------------*
*&      Form  Z_CARREGA_TRANSACAO
*&---------------------------------------------------------------------*
FORM z_carrega_transacao .
"  Chama a trasação informada usando a tabela 'IT_BDCDATA que na verdade
" é um shdb que vai automátiza o processo até o ultimo registro, existe
" dois metodos de ver o processo, no 'MODE se colocar 'N' vc não visualiza
" o processo, agora se vc coloca 'A' no 'MODE vc terá que apertar 'Enter
" por processo e depois de efetuar o processo por registro ele popula a
" tabela 'IT_MSG com os dados de retorno,se foi realizado com exito, ou se
" deu algum problema.
  CALL TRANSACTION 'XD02' USING it_bdcdata
                          MODE  vg_mode
                          UPDATE vg_s
                          MESSAGES INTO it_msg
                            .

ENDFORM.                    " Z_CARREGA_TRANSACAO

*&---------------------------------------------------------------------*
*&      Form  Z_IMPRIME_MENSAGEM
*&---------------------------------------------------------------------*
FORM z_imprime_mensagem.
"  Dá 'Loop na tabela de retorno da chamada da transação e alimenta outra
" tabela com a retorno referenciado com o Cliente
  LOOP AT it_msg.
    msgno = it_msg-msgnr.
    "  Function que faz mostrar a mensagem
    CALL FUNCTION 'WRITE_MESSAGE'
      EXPORTING
        msgid         = it_msg-msgid
        msgno         = msgno
        msgty         = it_msg-msgtyp
        msgv1         = it_msg-msgv1
        msgv2         = it_msg-msgv2
        msgv3         = it_msg-msgv3
        msgv4         = it_msg-msgv4
        msgv5         = ' '
     IMPORTING
*       ERROR         =
        messg         = mensg
*       MSGLN         =
              .
  ENDLOOP.

  st_message-cliente = st_arqui-cliente.
  st_message-msgty   = mensg-msgty.
  st_message-msgno   = mensg-msgno.
  st_message-msgtx   = mensg-msgtx.
" popula a tabela principal de mensagem que será o Log de erro.
  APPEND st_message TO it_message.

*   WRITE: / , st_arqui-cliente ,
*              mensg-msgtx,
*              mensg-msgty
*           .

ENDFORM.                    " Z_IMPRIME_MENSAGEM

*&---------------------------------------------------------------------*
*&      Form  Z_MANDA_ARQUIVO
*&---------------------------------------------------------------------*
FORM z_manda_arquivo .
"  Cria um arquivo externo conforme 'Filename com as informações da 'Data_tab
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename = p_log
    TABLES
      data_tab = it_message
    EXCEPTIONS
      OTHERS   = 17.
ENDFORM.                    " Z_MANDA_ARQUIVO

*&---------------------------------------------------------------------*
*&      Form  Z_SAPGUI_PROGRESS_INDICATOR
*&---------------------------------------------------------------------*
FORM z_sapgui_progress_indicator  USING texto.

  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 10
      text       = texto.

ENDFORM.                    " Z_SAPGUI_PROGRESS_INDICATOR

"  Debugem isso, estudem, façam de outra forma pois não eh tão facil assim,
" apertem F1, muda o 'MODE no 'CALL TRANSACTION pra ver processo por processo
" abusem deste programa, olhem abaixo o SHDB possivel para este Batch input,
" provavelmente deve ter mais campo mostrando valores mas nós não precisavamos
" cadatrar outros campos, e qualquer dúvida e soh fala, t+.


"                                               T XD02  BS AA X   F
"SAPMF02D 0101  X
"                                                 BDC_CURSOR  RF02D-D0110
"                                                 BDC_OKCODE  /00
"                                                 RF02D-KUNNR 8000000001
"                                                 RF02D-D0110 X
"SAPMF02D 0110  X
"                                                 BDC_CURSOR  KNA1-TELF1
"                                                 BDC_OKCODE  /00
"                                                 KNA1-NAME1  teste
"                                                 KNA1-STRAS  rua teste
"                                                 KNA1-ORT01  São Paulo
"                                                 KNA1-TELF1  12345678