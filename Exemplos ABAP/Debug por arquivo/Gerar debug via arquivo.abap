Há determinados momentos em que não é possível fazer /H para iniciar o debugger. O caso mais comum é durante uma janela de diálogo modal (aquilo que os estrangeiros chamam de popup). Mas há uma forma simples, ainda que rocambolesca, para o conseguires:


1. Cria um ficheiro de texto com o seguinte conteúdo:
[FUNCTION]
Command=/H
Title=Debugger
Type=SystemCommand

2. Grava o ficheiro numa pasta ou no ambiente de trabalho;

3. Arrasta (aquilo que os estrangeiros chamam de drag and drop) o ficheiro de onde o gravaste para cima da janela de diálogo ao mesmo tempo que gritas ABRACADABRA.

E assim, desta forma estrambólica, como que por magia, se tiveres gritado, o modo de debug será activado para teu regozijo.

É verdade que provavelmente já toda a gente conhece esta dica, mas é tão fundamental que me pareceu ser obrigação do Abapinho ensiná-la.

