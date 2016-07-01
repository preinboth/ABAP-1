#Exemplo de Strlen() dentro de código com Loop


<div><pre>
	
Data:  lv_length       TYPE i,
       lv_len_aux      TYPE i,
       lv_destinatario TYPE string,
       lv_aux          TYPE string.

   LOOP AT it_tvarvc INTO wa_tvarvc.
        CONCATENATE lv_destinatario wa_tvarvc-low ';' INTO lv_destinatario.
        CLEAR wa_tvarvc.
      ENDLOOP.
     lv_length       = strlen( lv_destinatario ).
     lv_len_aux      = lv_length - 1.
     lv_aux          = lv_destinatario.

  clear lv_destinatario.

  lv_destinatario = lv_aux(lv_len_aux).

     Clear lv_length,
           lv_len_aux,
           lv_aux,
           lv_destinatario.

</pre></div>