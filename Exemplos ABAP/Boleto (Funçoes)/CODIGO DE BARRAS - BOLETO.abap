"Buscar dados da REGUH (Transação ZFI45 Unimarka - é Exemplo)

"Com a REGUH, buscar dados da REGUD, pela função abaixo.

          CALL FUNCTION 'BOLETO_DATA'
            EXPORTING
              line_reguh = reguh
            TABLES
              itab_regup = tab_regup
            CHANGING
              line_regud = regud.


"O Codigo de barras está no campo REGUD-TEXT8