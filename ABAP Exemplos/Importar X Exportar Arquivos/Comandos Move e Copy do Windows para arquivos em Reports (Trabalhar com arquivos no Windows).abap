REPORT zcomando_move MESSAGE-ID zg .

  CALL FUNCTION 'WS_EXECUTE'
       EXPORTING
            cd                 = 'c:\temp\'
            commandline        = '/c move seudocto.doc c:\novo diretorio\'
            program            = 'cmd'
       EXCEPTIONS
            frontend_error     = 1
            no_batch           = 2
            prog_not_found     = 3
            illegal_option     = 4
            gui_refuse_execute = 5
            OTHERS             = 6.

*commandline        = '/c move seudocto.doc c:\novo diretorio\'

* Aqui voce pode colocar qualquer comando do DOS.
* O /c  move  ----> é o comando, também pode ser    /c rename /c copy