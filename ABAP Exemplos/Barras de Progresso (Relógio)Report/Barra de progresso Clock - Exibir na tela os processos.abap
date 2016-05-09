"Exibir na tela os processos 

 DESCRIBE TABLE it_placa_a LINES lv_lines.
  lt_lines = lv_lines.
  SHIFT lt_lines LEFT DELETING LEADING space.


   LOOP AT it_placa_a.
    lt_tabix = sy-tabix.
    SHIFT lt_tabix LEFT DELETING LEADING space.

    CONCATENATE 'Posicao' lt_tabix 'de' lt_lines
    INTO lv_texto SEPARATED BY space.
    clock 60 lv_texto.