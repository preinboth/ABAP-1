**Uma dúvida comum para desenvolvedores ABAP Juniores é: quais variáveis de sistema podemos utilizar e quais são suas funcionalidades.**
#Segue abaixo uma relação das principais variáveis e descrição das mesmas:

• SY-SUBRC – Retorna 0 se foi bem sucedido ou diferente de 0 se falhou, usada após uma pesquisa, condição.

• SY-UNAME – Retorna o nome do usuário

• SY-DATUM – Retorna a data do sistema

• SY-UZEIT – Retorna a hora, minuto, segundo do sistema

• SY-TCODE – Retorna código da transação atual

• SY-TABIX – Retorna o numero da linha da tabela atual (Normalmente usando dentro de loop.)

• SY-LANGU – Retorna o idioma de logon do usuário

• SY-DYNNR – Retorna o numero da tela atual

• SY-UCOMM – Retorna o nome de um botão pressionado (OKCODE)

• SY-REPID – Retorna o nome do programa

• SY-CPROG – Nome do programa principal

• SY-FDPOS – Utilizado na comparação de Strings, ver comparação strings acima.

• SY-BATCH – Indica a execução de um programa em background

• SY-LINNO – Retorna a linha corrente de um relatório

• SY-LISEL – Retorna a linha selecionada em relatórios interativos

• SY-MANDT – Retorna o mandante do sistema

• SY-PAGNO – Retorna a pagina atual de um relatório

• SY-TVAR0 .. SY-TVAR9 – Retorna elementos de textos ou títulos de relatórios

• SY-VLINE – Efetua a fechamento de bordas em um relatório

• SY-ULINE(n) – Imprime uma linha com n posições

• SY-TCODE – Código da transação

• SY-DBCNT – Dentro de SELECT, contém o contador de interação