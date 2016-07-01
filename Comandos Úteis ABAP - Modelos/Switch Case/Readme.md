#Utilização de Switch Case.
__Codigo Exemplo__
<div><pre>
    CASE wa_ativos-status.
      WHEN 'N'.
        wa_ativos-status_descricao = 'Pendente'.
      WHEN 'A'.
        wa_ativos-status_descricao = 'Aprovada'.
      WHEN 'R'.
        wa_ativos-status_descricao = 'Não Aprovada'.
      WHEN 'P'.
        wa_ativos-status_descricao = 'Aprovado Parcialmente'.
      WHEN 'F'.
        wa_ativos-status_descricao = 'Finalizada'.
    ENDCASE. 


  case l_okcode.
    when 'BACK'.
      l_okcode = '&F03'.
    when 'RW'.
      l_okcode = '&F12'.
    when '%EX'.
      l_okcode = '&F15'.
  endcase.

  </pre></div>