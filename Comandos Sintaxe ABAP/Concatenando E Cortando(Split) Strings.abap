REPORT YPROGRAMA06.

write:/ 'CONCATENANDO STRINGS'.

data: a(10) value 'teste1',
      b(10) value 'teste2',
      c(10) value 'teste3',
      d(10) value 'teste4',

nome_completo(40),
nome_separado(40).

concatenate a b c d into nome_completo.
concatenate a b c d into nome_separado separated by ' '.

write:/ nome_completo.
write:/ nome_separado.

write:/.

write:/'DIVIDINDO STRING COM SPLIT'.

data: e(10),f(10),g(10),conjunto(30) value 'dividindo-string-split'.

split conjunto at '-' into e f g.

write:/ 'e:',e.
write:/ 'f:',f.
write:/ 'g:',g.

write:/.

write:/'PESQUISANDO STRING'.

data: texto(50) value 'Pesquisa de string',
      palavra(50) value 'Pesquisa'.

search texto for palavra.

if sy-SUBRC = 0.

  write: / 'Encontrado'.

  else.

    write: / 'Não encontrado'.

    endif.

    write:/.

    write:/ 'SUBSTINTUINDO STRINGS'.

    data: outro_texto(50) value 'Substituição de Strings na Linguagem',
          texto_subst(50) value 'no ABAP'.

    replace 'na Linguagem' with texto_subst into outro_texto.

    write: / outro_texto.