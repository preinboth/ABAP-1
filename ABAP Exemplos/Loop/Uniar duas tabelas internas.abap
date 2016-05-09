
*Exemplo de loop + loop where + read table + move-corresponding + Uniar duas tabelas internas

                          "Inclusão de dados em coluna de saída com base de uma tabela com chaves.

LOOP AT it_zpst027 INTO wa_zpst027.
      CLEAR:wa_zpst032, wa_zpst041, wa_zpst044, wa_zpst050, it_saida.
 
 
        "joga todos os campos da work area pra o cabecalho da tabela de saida
      MOVE-CORRESPONDING wa_zpst027 TO it_saida.
 
        "le os dados da tabela interna que foi usada no select quando  a chave for a mesma da iteração do loop
      READ TABLE it_zpst041 INTO wa_zpst041 WITH KEY num_solicitacao = wa_zpst027-num_doc.
      IF sy-subrc EQ 0.
        "se encontrar algum dado, atribui para a work area passa para a linha de cabecalho da tabela de saida
        it_saida-aprovador = wa_zpst041-aprovador.
      ENDIF.
 
        "loop na tabela que foi lida  e atribui para sua work area  quando a Chave for  a mesma da iteração.
  LOOP AT it_zpst041 INTO wa_zpst041 WHERE num_solicitacao = wa_zpst027-num_doc.
 
        "atribui para cada iteração da tabela interna lida  uma nova linha de aprovador e da um append
        it_saida-aprovador = wa_zpst041-aprovador.
 
        APPEND it_saida.
 
  ENDLOOP.
ENDLOOP.

*______________________________________________________________________________________________________________________________

                                              "Unir duas tabelas internas
  "Unir duas tabelas em uma só.
    it_44_50[] = it_zpst044[].

    LOOP AT it_zpst050 INTO wa_zpst050.
      READ TABLE it_44_50 WITH KEY doc_num = wa_zpst050.
      IF sy-subrc  <> 0.
        APPEND wa_zpst050 TO it_44_50.
      ENDIF.
    ENDLOOP.
