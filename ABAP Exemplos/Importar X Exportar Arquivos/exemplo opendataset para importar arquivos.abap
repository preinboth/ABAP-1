* Carrega o Arquivo do Servidor
        open dataset p_path_r for input in text mode encoding default.
        if sy-subrc ne 0.
          message e000(zsd) with 'Erro ao abrir o arquivo REPASSE de importação'.
        endif.

        do.
          read dataset p_path_r into wa_arq_remessa.
          if sy-subrc ne 0.
            if sy-subrc ne 4.
              exit.
            endif.
            exit.
          else.
            append wa_arq_remessa to ti_arq_remessa.
          endif.
        enddo.

        close dataset p_path_r.
        if sy-subrc ne  0.
          exit.
        endif.
      endif.
    else.
      message i000(zsd) with 'Obrigatório informar o caminho do arquivo de ' 'importação!'.
      stop.
    endif.
  endif.