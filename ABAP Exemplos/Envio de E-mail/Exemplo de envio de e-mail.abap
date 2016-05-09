"Após pesquisas no Google e auxílio de alguns colegas de trabalho, identifiquei e escolhi a melhor forma, na minha opinião, de mandar emails pelo
"SAP através de códigos de programação. Se você sabe HTML da até pra formatá-lo!

"Neste primeiro momento farei uma demonstração com texto simples para o envio de emails, não utilizando estrutura HTML.

"Segue o código explicativo:
  DATA: lt_text TYPE bcsy_text,"Conterá o conteúdo do email
       ls_text TYPE soli,"Work Area de lt_text
       lv_sent TYPE os_boolean."Receberá a confirmação de envio
 
*Variáveis para enviar o email
  DATA: go_request TYPE REF TO cl_bcs,
       go_document TYPE REF TO cl_document_bcs,
       go_sender TYPE REF TO cl_sapuser_bcs,
       go_recipient TYPE REF TO if_recipient_bcs,
       go_exception TYPE REF TO cx_bcs.
 
*Preenchendo o conteúdo do email
 ls_text = 'Essa é a primeira linha de conteúdo do email'.
  APPEND ls_text TO lt_text.
 ls_text = 'Essa é a segunda linha...'.
  APPEND ls_text TO lt_text.
 
*É necessário o tratamento de erros com try...catch
  TRY.
*Método utilizado para criar um pedido de envio persistente
     go_request = cl_bcs=>create_persistent().
 
*Monta e adiciona a estrutura do e-mail
     co_document = cl_document_bcs=>create_document(
       i_type = 'RAW'
       i_text = lt_text
       i_language = sy-langu"P - Português
       i_subject = 'Assunto do email').
     co_request->set_document(co_document).
 
*Remetente do e-mail
*obs: por default, o envio é feito pelo usuário logado.
*Caso queira alterar, adicione esse método:
     go_sender = cl_sapuser_bcs=>create( 'RISHIDA').
      CALL METHOD go_request->set_sender
        EXPORTING
         i_sender = go_sender.
 
*Adicionando o destinatário ao e-mail
     go_recipient =
     cl_cam_address_bcs=>create_internet_address( 'ab@cd.com').
      CALL METHOD go_request->add_recipient
        EXPORTING
         i_recipient = go_recipient
         i_express   = 'X'.
 
*Marca o envio como imediato ('X') ou não (space)
      CALL METHOD co_request->set_send_immediately( 'X').
 
*Envia email, e retorna true ('X') ou false ('') na lv_sent
      CALL METHOD go_request->send(
        EXPORTING
         i_with_error_screen = 'X'
        RECEIVING
         result = lv_sent).
      COMMIT WORK.
 
    CATCH cx_bcs INTO go_exception.
*Tratamento do erro try... catch
  ENDTRY.

"Se as configurações de envio de email estiverem certas o email será enviado ao destinatário corretamente. Você pode checar o status do email na transação SOST. 