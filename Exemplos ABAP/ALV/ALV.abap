http://www.ricardobhz.com.br/search/label/REUSE_ALV_GRID_DISPLAY

http://www.consolut.com/en/s/sap-ides-access/d/s/doc/F-REUSE_ALV_GRID_DISPLAY~~~~~~~~I_SCREEN_START_COLUMN

hot_spot


Parametros:

EXPORTING

*************************************************************************************************************************************************************

	I_INTERFACE_CHECK - Na execução aparece varias telas com os parametros da ALV (http://saptechnical.com/Tutorials/ALV/Interface/check.htm)

		Descrição

		Assim que o desempenho da saída da lista não é reduzido devido a um controlo de consistência da interface, estas verificações são realizadas 
		em modo de chamada especial.

		Se esse parâmetro está definido para 'X', a consistência da interface é verificada quando o módulo de função é chamado e um log de erro é 
		exibida.

		Você só deve definir este parâmetro para fins de teste durante o processo de desenvolvimento (por exemplo, para depuração).

		Você também pode executar a verificação de interface na lista de resultados, introduzindo o código de função e &SOS.

		Este parâmetro não está suportado no modo de tela cheia! Como alternativa, ir para a visualização de impressão a partir da lista e introduza 
		o código de função e &SOS lá.

		faixa de valor
	
		Default

		ESPAÇO

*************************************************************************************************************************************************************

	*   I_BYPASSING_BUFFER                = ' '
 
*************************************************************************************************************************************************************
 
	*   I_BUFFER_ACTIVE                   = ' '
 
*************************************************************************************************************************************************************
 	
	i_callback_program - Programa que chamou a ALV
		
		Descrição

		Programa a partir do qual o módulo de função é chamado e que contém o programa routines.The saída deve ser sempre um relatório, o grupo de 			função, piscina módulo ou piscina rotina formulário (que não deve ser um include).

		Atenção: Nunca passe SY-repid diretamente na interface. Se o campo SY-repid contém o nome do programa desejado, você deve absolutamente 			atribuir este nome para uma variável auxiliar e passar esta variável para a interface.

		faixa de valor
	
		Default
 
*************************************************************************************************************************************************************
 
	I_CALLBACK_PF_STATUS_SET - Para criar botões - Configurar o status gui igual na se80

		Descrição

		Passando uma rotina de saída indica ao ALV que o interlocutor quer definir um status do usuário auto-definida.

		Como resultado, o estado padrão da ALV não está definido.

		A interface da rotina de forma especificada deve ser definida da seguinte forma:

		FORM set_pf_status USAR rt_extab TYPE slis_t_extab

		Tabela RT_EXTAB contém os códigos de função que estaria escondido na interface de usuário padrão.

		Se o chamador deseja usar uma interface de usuário auto-definida (por exemplo, a fim de fornecer funções adicionais da lista ou usar funções
		existentes), recomendamos que você copie STANDARD_FULLSCREEN estado padrão da função SLVC_FULLSCREEN grupo e modificá-lo de acordo. Códigos 
		de função padrão ALV sempre começam com '&'.

		Veja também a documentação sobre parâmetro I_CALLBACK_USER_COMMAND.

		Se uma interface de usuário auto-definido é usado, que inclui códigos de função de interface de usuário padrão, devem ser tidos em conta os 
		códigos de função da exclusão tabela passada.

		Isto significa que o estado do utilizador deve ser geralmente definido como se segue:

		SET PF-STATUS user status EXCLUDING rt_extab.
		Funções do aplicativo pode ser adicionado a exclusão rt_extab mesa para que possam ser desativados.

		A rotina é chamado sempre que a interface de usuário padrão seria definido com SET PF-STATUS.

		Default

		Se nenhuma rotina de saída for especificado, o ALV define um status que corresponde a STANDARD_FULLSCREEN estado da função SLVC_FULLSCREEN 
		grupo.
 
*************************************************************************************************************************************************************
 
	I_CALLBACK_USER_COMMAND - Quando o usuário faz alguma coisa (okcode)

		Descrição

		Passando uma rotina de saída indica ao ALV que a aplicação pretende responder a certos códigos de função.

		Geralmente, estes são os códigos de função que são desconhecidos para a ALV (isto é, não são funções normais ALV) e que foram definidos e por 		um estado de utilizador.

		Veja também a documentação sobre parâmetro I_CALLBACK_PF_STATUS_SET.

		A interface da rotina de forma especificada deve ser definida da seguinte forma:

		FORM user_command USING r_ucomm LIKE sy-ucomm 
					rs_selfield TYPE slis_selfield.

		Parâmetro R_UCOMM contém o código de função desencadeada.

		Estrutura RS_SELFIELD contém as seguintes informações:

		tabname: Nome da tabela de saída interna
		tabindex: Índice da tabela de saída interna
		fieldname: Nome do campo
		endsum: Cursor está localizado na linha de totais
		sumindex: Se> 0, o cursor está localizado em uma linha de subtotais
		value: Valor do campo na lista
		refresh: (Exportação) Lista deve ser criado novamente
		col_stable: (exportador) Mantenha a posição da coluna quando a lista é criada novamente
		row_stable: (exportador) Manter posição da linha quando a lista é criada novamente
		exit: (exportador) lista Exit (e ALV)
		before_action: Call antes da execução da ação padrão
		after_action: Call após a execução da ação padrão, antes de configuração lista
		ignore_multi:Uso interno
		sel_tab_field: uso interno
		A rotina de saída é chamado sempre uma função desconhecida do ALV é desencadeada ou se a chamada de rotina antes / após a execução de um 			código de dunção padrão foi definido pela interface do parâmetro IT_EVENT_EXIT.

		Veja também a documentação sobre parâmetro IT_EVENT_EXIT.
	
		O código de função e posição atual do cursor são, então, transferidos para o programa de chamada por meio da rotina de saída.

		Se o usuário tiver selecionado várias linhas selecionando caixas de seleção, o campo da tabela de saída designada como a caixa contém o 			estado atual da caixa de seleção na lista.

		faixa de valor

		Default
 
*************************************************************************************************************************************************************
 
	*   I_CALLBACK_TOP_OF_PAGE       
		
		Descrição

		Se o chamador especifica uma rotina de saída, essa rotina deve ter o seguinte formato:

		FORM top_of_page.

		REUSE_ALV_COMMENTARY_WRITE módulo pode então ser chamado dentro da rotina EXIT. Este módulo é responsável pela formatação da informação do 			cabeçalho e também garante formatação HTML online. Na visualização de impressão ou em lote, o texto passou então a saída é no formato normal.

		Se REUSE_ALV_COMMENTARY_WRITE módulo não pode ser usado, você deve usar dois parâmetros em seu lugar. Em I_CALLBACK_TOP_OF_PAGE você passar a 		rotina de forma que é responsável pela formatação normal em modo batch ou no modo de visualização de impressão. A rotina de forma que é 			responsável pela formatação on-line, é passada no parâmetro I_CALLBACK_HTML_TOP_OF_PAGE. Se um desses parâmetros não é preenchida, top-of-			page não é emitido no modo respectivo.

		faixa de valor

		Default
 
*************************************************************************************************************************************************************
 
	*   I_CALLBACK_HTML_TOP_OF_PAGE 
		Descrição

		Se o módulo de função REUSE_ALV_COMMENTARY_WRITE não é utilizado sob a forma de I_CALLBACK_TOP_OF_PAGE, a rotina de forma deve ser passado no 		parâmetro I_CALLBACK_HTML_TOP_OF_PAGE para o modo on-line. O formulário deve então ter o seguinte formato:

		form top_of_page using cl_dd type ref to cl_dd_document.

		No formulário, você pode, por exemplo, usar métodos de classe CL_DD_DOCUMENT para exibir o texto em formato HTML.

 
*************************************************************************************************************************************************************
 
	*   I_CALLBACK_HTML_END_OF_LIST    

		Descrição

		Neste parâmetro, você pode passar um form on-line para o tratamento de fim-de-lista. O form deve ter o formato followiong:

		form end_of_list using cl_dd type ref to cl_dd_document.
 
*************************************************************************************************************************************************************
 
	*   I_STRUCTURE_NAME     
		Descrição

		Se a tabela de saída interna é definida através de uma estrutura Dicionário ABAP (INCLUIR struct ESTRUTURA Ou como struct), você pode 				configurar automaticamente o catálogo de campos, passando o nome da estrutura.

		O catálogo de campo é, então, definida internamente para essa estrutura da seguinte maneira:

		Todos os campos estão na lista (NO_OUT = SPACE) exceto os campos de CLNT tipo de dados.
		Os campos-chave da estrutura Dicionário são adoptados no catálogo de campos como campos-chave.
		As referências a campos de unidades armazenadas no dicionário são adotadas desde que os campos de referência estão contidas na estrutura.
		Se, além disso passar um catálogo de campos como parâmetro, a informação estrutura é mesclado com este catálogo de campos.
		Para mais informações sobre como configurar o catálogo de campos automaticamente, consulte a documentação sobre a função módulo 				REUSE_ALV_FIELDCATALOG_MERGE.

		faixa de valor

		Default
 
*************************************************************************************************************************************************************
 
	*   I_BACKGROUND_ID       
		
		Descrição

		Você pode usar esse parâmetro para passar um papel de parede para a saída no topo de página.

		Atenção: Uma vez que a formatação baseada em papel de parede, não garante uma exposição baseada em padrões da área de página no novo design, 			você só deve usar este parâmetro em casos excepcionais....
 
*************************************************************************************************************************************************************
 
	I_GRID_TITLE - Titulo da ALV

		Descrição

		Especifica o título do controlo. Esse texto é exibido acima da grade.

*************************************************************************************************************************************************************
 
	*   I_GRID_SETTINGS 

		Descrição

		Se Top-of-página ou fim-de-lista são enviados on-line, estas áreas são exibidos em um divisor acima ou abaixo na lista. Usando 				I_GRID_SETTINGS você pode reduzir o tamanho padrão para 0%. Para fazer isso, você pode usar dois campos:

		COLL_TOP_P: Define topo de página para 0%

		COLL_END_L: Conjuntos de fim-de-lista para 0%
 
*************************************************************************************************************************************************************

	is_layout - Configurações de layout

		Descrição

		Estrutura para descrever a lista de saída .

		Os parâmetros são descritos e agrupados com base nas seguintes categorias:

		As opções de exibição
		exceções
		totais
		interação
		tela de detalhes
		cor
		outro
		Observe a seção de configurações pré-definidas .

		As opções de exibição

		colwidth_optimize
			Faixa de valor : SPACE , 'X'
			'X ' = optimiza a largura da coluna para assegurar que o conteúdo seja mostrado por completo .
		no_colhead
			Faixa de valor : SPACE , 'X'
			'X' = Não emitir títulos de coluna .
		zebra
			Faixa de valor : SPACE , 'X'
			'X' = padrão listrado ( para listas de largura, por exemplo)
		no_vline
			Faixa de valor : SPACE , 'X'
			'X' = colunas separadas pelo espaço.
		exceções

		lights_fieldname
			Faixa de valor : SPACE , o nome do campo da tabela de saída interna
			
			Campo da tabela de saída interna que contém a codificação das excepções a ser emitido
			Codificação no campo da tabela de saída :
			'1 ' = Semáforo vermelho
			'2 ' = semáforo amarelo
			'3 ' = Semáforo verde
		lights_tabname
			Faixa de valor : SPACE , o nome da tabela da tabela de saída interna
			O nome da tabela da tabela de saída interna que contém o campo especificado no parâmetro LIGHTS_FIELDNAME .
		lights_rollname
			Faixa de valor : SPACE , o nome do elemento de dados
			A documentação definida para esse elemento de dados é exibido quando a ajuda F1 para uma coluna exceção é chamado.
		lights_condense
			Faixa de valor : SPACE , 'X'
			'X' = O sistema emite a exceção 'máximo' dos itens incluídos no total a nível subtotal.
			Exemplo: Se uma linha da lista é a saída com um ' sinal vermelho ' , cada um subtotal incluído nesta linha lista também é exibido com 			um " sinal vermelho " .
		totais

		no_sumchoice
			Faixa de valor : SPACE , 'X'
			'X' = campos de valor para o qual são calculados os totais são comunicadas pelo programa de chamada ( FIELDCAT - DO_SUM = 'X' ) . O 			usuário não deve ter permissão para alterar essa configuração pré-definida de forma interativa.
		no_totalline
			Faixa de valor : SPACE , 'X'
			'X' = Nenhuma linha de total geral deve ser exibido. Se necessário, subtotais pode , contudo, ser calculados e exibidos . Os campos 				que são utilizados para o cálculo dos subtotais são para ser marcada com DO_SUM = 'X' no catálogo de campos .
		no_subchoice
			Faixa de valor : SPACE , 'X'
			'X' = Características em cujo subtotais nível de controle deve ser calculado são comunicadas pelo programa de chamada .
			O usuário não deve ter permissão para alterar essa configuração pré-definida de forma interativa.
			Veja também a documentação sobre a importação de parâmetro IT_SORT .
		no_subtotals
			Faixa de valor : SPACE , 'X'
			'X' = Calculando subtotais não deve ser permitido.
		totals_only
			Faixa de valor : SPACE , 'X'
			'X' = Os dados são enviados em formato compactado apenas com os totais de nível de linha .
			Pré-requisito: IMPORTAR parâmetro IT_SORT é preenchido de acordo com os critérios de classificação eo indicador subtotais .
			Veja também a documentação sobre a importação de parâmetro IT_SORT .
		totals_text
			Faixa de valor : SPACE , string ( não superior a 60 )
			' ' = Na primeira coluna , o sistema padrão indica o nível totais , exibindo um número adequado de '*' para o total global . Após os 				asteriscos , o sistema exibe a string 'total' , desde que a largura da coluna da primeira coluna de saída é grande o suficiente . Se 				a largura da coluna não é suficiente , somente os asteriscos são exibidos .
			'string' = Após a nível totais indicados visualmente por meio de "*" , o sistema exibirá a string passada , desde que a largura da 				coluna é suficiente.
		subtotals_text
			Faixa de valor : SPACE , string ( não superior a 60 )
			' ' = Na primeira coluna , o sistema padrão indica o nível totais , exibindo um número adequado de '*' para a linha de subtotais . 				Após os asteriscos , o sistema apresenta a cadeia total * *, desde que a largura da coluna da primeira coluna de saída é 					suficientemente grande e a característica de a primeira coluna não é um critério subtotal. Se a largura da coluna não é suficiente , 				somente os asteriscos são exibidos .
			' cadeia' = Após o nível total indicada por meio de '*' , o sistema apresenta a cadeia passou desde que a largura da coluna é 					suficiente e com a característica de a primeira coluna não é um critério subtotal.
			Se a característica é um critério subtotal , o sistema retoma o valor da característica para o qual subtotais foram calculados após o 			nível total , desde que a largura da coluna é suficiente.
		numc_sum
			Faixa de valor : SPACE , 'X'
			' ' = No sistema padrão , não é possível calcular os totais para campos NUMC .
			'X' = Em geral, é possível calcular os totais para campos NUMC . Se este código estiver definido, você pode usar o parâmetro FIELDCAT 			- NO_SUM para controlar cada coluna NUMC se totais pode ser calculada ou não.
		interação

		box_fieldname
			Faixa de valor : SPACE , o nome do campo da tabela de saída interna
			Se a lista deve ter caixas no início de cada linha da lista (para permitir ao usuário selecionar várias linhas de uma só vez ) , você 			deve preencher este parâmetro com o nome do campo da tabela de saída interna, que representa a coluna de seleção para selecionar 				linhas com o ajuda de caixas de seleção .
			O campo é sempre exibido como uma caixa de seleção no início de cada linha da lista sem título lista.
		box_tabname
			Faixa de valor : SPACE , o nome da tabela da tabela de saída interna
		f2code
			Faixa de valor : SPACE , o código de função
			Ou seja, quando a interface padrão ALV é usado :
			Se você quiser atribuir um código de função ALV padrão para um clique duplo (F2) , você deve atribuir este código de função para esse 			parâmetro.
			Exemplo: Você deseja atribuir a função ALV standard ' Detalhe ' ('& ETA ') para F2.
		=> LAYOUT- F2CODE = ' & ETA '
			Ou seja, se uma interface de auto -definido é usado :
			Caso 1:
			Você deixa o código de função ALV padrão para F2 'e IC1 ' na interface copiada da aplicação. No entanto, você quer ter uma função 				executada com F2 que não é atribuída a F2 na interface (função ALV padrão ou função da aplicação). Você deve comunicar este código de 			função para a ALV através do parâmetro F2CODE .
			Caso 2:
			Você remove o código de função ALV padrão para F2 'e IC1 ' a partir da interface do aplicativo e usar outro código de função em vez 				(função ALV padrão ou função da aplicação). Você deve comunicar este código de função para a ALV através do parâmetro F2CODE . Isso é 			necessário se você quiser permitir que as colunas a serem selecionados.
		confirmation_prompt
			Faixa de valor : SPACE , 'X'
			'X' = Se um dos ' Back ( F03 ) " as funções , ' Exit ( F15 ) 'ou' Cancelar ( F12) " é acionado , o sistema pergunta ao usuário se ele 			quer sair da lista.
		key_hotspot
			Faixa de valor : SPACE , 'X'
			As colunas definidas como campos-chave no catálogo de campos ( FIELDCAT -KEY = 'X' ) são emitidos como um hotspot. Isso significa que 			um único clique em um campo de chave ( em destaque na cor na lista ) aciona a função atribuída a F2.
		reprep
			Faixa de valor : SPACE , 'X'
			'X' interface = Ativar relatório / relatório
			Pré-requisito : Sistema de Aplicação ( => relatório RKKBRSTI existe).
			O módulo lista funciona como um emissor potencial na interface relatório / relatório ( inicialização da interface , se necessário).
			O relatório / módulo piscina chamando entrou em I_CALLBACK_PROGRAM é declarado para a interface relatório / relatório quanto o 			relatório remetente com o tipo de RT = Relatório .
			Se o relatório remetente é atribuído ao receptor relatórios na tabela TRSTI , código de função BEBx está definido como ativo.
			(X = classe de código de função)
			Exemplo:
			Se o remetente RKTFGS15 tem uma atribuição receptor para Report Writer 7KOI grupo de relatórios com código de função de classe '3 ' 			(configuração SAP ), este grupo relatório receptor é chamado através da interface relatório / relatório de código de função ' BEB3 . 				As seleções do passado para a interface relatório / relatório são as seleções relatório e as informações -chave da linha selecionada.
			Para mais informações sobre a interface relatório / relatório, consulte a documentação no grupo de funções " RSTI .
		tela de detalhes

		detail_initial_lines
			Faixa de valor : SPACE , 'X'
			' ' = Na vista de detalhes , o sistema exibe somente os campos , cujo conteúdo não está definido como inicial.
			'X' = conteúdo do campo iniciais também são exibidos na tela detalhe .
		detail_titlebar
			Faixa de valor : SPACE , string ( não superior a 30 )
			' ' = O sistema exibe' Detalhe: Display ' como o título da tela de detalhes .
			'string' = O sistema exibe a string passada como o título da tela de detalhes .
		cor

		info_fieldname
			Faixa de valor : SPACE , o nome do campo da tabela de saída interna
			Você pode colorir toda uma linha da lista individualmente, usando um código de cor que está definido para cada linha em uma coluna da 			tabela de saída interna. Você deve atribuir o nome do campo do campo com o código de cores para este parâmetro .
			O campo da tabela de saída interna deve ser do tipo CHAR ( 3).
			O código deve obedecer a seguinte sintaxe: ' Cxy ':
				C = Color ( cada código deve começar com 'C' )
				x = número de cores ( '1 ' - '9' )
				y = Intensificação ( '0 ' = off , 1 = on)
			Nota: A cor da coluna de chave não é afetado. Se você também quiser colorir a coluna de chave em linha ou nível celular, você pode 				usar corante complexo que é descrito abaixo para o parâmetro COLTAB_FIELDNAME .
			Para obter informações sobre colunas de coloração , consulte a documentação do parâmetro catálogo de campos FIELDCAT a ênfase de 			importar parâmetro 		IT_FIELDCAT .
		coltab_fieldname
			Faixa de valor : SPACE , o nome do campo da tabela de saída interna
			Você pode colorir as células individualmente, usando um código de cor que está definido para a linha de células em uma coluna da 			tabela de saída interna.
			Você deve atribuir o nome do campo do campo com o código de cores para este parâmetro .
			O campo da tabela de saída interno deve ser do tipo SLIS_T_SPECIALCOL_ALV .
			Princípio: O campo do código de cor é enchida na linha em que as células a serem corados estão localizados. O campo contém então uma 			tabela interna da estrutura acima , que inclui os nomes dos campos das células de ser colorido com o código de cores . As coordenadas 			de células são , por conseguinte, derivados a partir da posição de linha no qual o código de cor é escrito e a informação contida na 			coluna da tabela de cores .
			A estrutura da linha da mesa de cor interna de tipo SLIS_T_SPECIALCOL_ALV é como se segue :
			Farbtabelle -name = Nome do campo de célula para ser colorido
			Farbtabelle -COLOR -COL = Número Cor ( 1-9 )
			Farbtabelle -COLOR -INT = Intensificação (0 = off, 1 = on )
			Farbtabelle - COLOR- INV = Inverse (0 = off, 1 = on )
			Farbtabelle - NOKEYCOL = Ignorar coloração chave ( 'X' = yes ',' = não)
			Se o parâmetro Farbtabelle -NAME não é preenchido , todas as especificações de cores referem-se a todos os campos. Como resultado, 			toda a linha é colorida .
		faixa de valor

		Default

		Em muitos casos, as configurações padrão de layout pode ser mantido para que você muitas vezes não precisa passar essa estrutura com 		bandeiras modificados .

		Nota:

		Todos os outros campos não especificados aqui explicitamente não são relevantes para o uso com REUSE_ALV_GRID_DISPLAY ou não são liberados.
 
*************************************************************************************************************************************************************

	it_fieldcat - Campos que serão listados

		Descrição

		Campo catálogo contendo as descrições de campo dos campos a serem considerados para a saída da lista (normalmente , isto é um subconjunto dos 		campos na tabela de saída interno).

		Basicamente, você precisa de um catálogo de campos para cada saída da lista que usa o ALV .

		O catálogo campo associado com a mesa de saída é gerado no código do chamador. Você pode gerar o catálogo de campos de forma automática ou 			semi- automaticamente chamando a função módulo REUSE_ALV_FIELDCATALOG_MERGE .

		Veja também a documentação sobre a função módulo REUSE_ALV_FIELDCATALOG_MERGE .

		Os valores mínimos exigidos para o catálogo de campos estão documentadas na seção 'Default' . O chamador pode, opcionalmente, usar todos os 			outros parâmetros para atribuir atributos de saída não-padrão para um campo.

		É somente nos seguintes casos que não são necessários para gerar o catálogo de campos e passá-lo explicitamente :

		A estrutura da tabela interna para ser a saída corresponde a uma estrutura armazenada no dicionário de dados e é referenciado com gosto ou 			incluem a estrutura na declaração da tabela interna.
		Todos os campos dessa estrutura deve ser a saída da lista.
		O nome da estrutura é declarada a ALV através do parâmetro I_STRUCTURE_NAME .
		Veja também a documentação sobre IMPORTNG parâmetro I_STRUCTURE_NAME .
		posicionamento

		col_pos ( posição da coluna )
			Faixa de valores : 0, 1 - 60
			Só é relevante se as posições relativas das colunas por padrão não deve ser idêntica à seqüência dos campos no catálogo de campos .
			O parâmetro determina a posição da coluna relativa do campo na saída da lista . A seqüência de coluna pode ser alterada de forma 				interativa pelo usuário. Se esse parâmetro está definido para seu valor inicial para cada entrada do catálogo de campos , as colunas 				são organizadas na ordem dos campos no catálogo de campos .
			identificação

		nome do campo ( nome do campo)
			Faixa de valor : Nome do campo da tabela de saída interna ( parâmetro obrigatório)
			Nome do campo do campo na tabela de saída interno que é descrito por esta entrada catálogo campo .
			Referência ao Dicionário de Dados

		ref_fieldname ( nome do campo do campo de referência)
			Faixa de valor : SPACE , o nome de um campo no Dicionário de Dados
			Nome do campo referenciado no Dicionário de Dados.
			Este parâmetro é necessário apenas se o campo na tabela de saída interno que é descrito pela entrada de corrente no catálogo campo 			tem uma referência para o dicionário de dados ( isto é, não é um campo de programa) e, se o nome do campo na saída interno mesa não é 			idêntico ao nome de campo do campo no dicionário de dados . Se ambos os nomes dos campos são idênticos , é suficiente para 			especificar a estrutura dicionário de dados ou tabela de parâmetro FIELDCAT - REF_TABNAME .

		ref_tabname ( nome do campo da tabela / estrutura de referência)
			Faixa de valor : SPACE , o nome de uma estrutura ou uma tabela no Dicionário de Dados
			Estrutura ou na tabela nome do campo referenciado no Dicionário de Dados.
			Este parâmetro é necessário apenas se o campo na tabela de saída interno que é descrito pela entrada de corrente no catálogo campo 			tem uma referência para o dicionário de dados ( isto é, não é um campo de programa).
			Referência para campos com unidades monetárias / unidades de medida

		Cada valor ou campo quantidade da tabela de saída interna cujo casas decimais devem ser exibidos com a unidade adequada na saída da lista , 		devem estar em conformidade com as seguintes convenções:
		O campo é do tipo de dados QUAN ou CURR (tipo P interno).
( Fisicamente, o campo deve , na verdade, pertencem a este tipo de dados. Substituindo o tipo físico de dados com o parâmetro FIELDCAT - DATATYPE não tem nenhum efeito . )
Existe um campo na tabela de saída interna que contém a unidade relevante.
Há também uma entrada para o campo de unidade no catálogo de campos .
(Se a unidade não deve ser exibido como uma coluna na lista e que o usuário não deve ser capaz de mostrar a unidade de forma interativa , por exemplo, porque a unidade é sempre único e, portanto, explicitamente saída pelo chamador no cabeçalho da lista , então você pode atribuir parâmetro FIELDCAT -TECH = 'X' para a entrada do catálogo de campo para o campo da unidade.
Se um campo tem um valor de referência de uma unidade, isto apresenta os seguintes efeitos , quando a lista de saída é :
As casas decimais são exibidas com a unidade adequada.
Um campo de valor inicial , com referência a uma unidade de não- inicial é apresentada como '0 '( desde que FIELDCAT - NO_ZERO é inicial). Se totais específicos de unidade são calculadas para este campo de valor , a unidade é considerada na análise de se existem unidades homogéneos.
Um campo de valor inicial , com referência a uma unidade inicial é exibida como um espaço . Se totais específicos de unidade são calculadas para este campo de valor , o espaço da unidade não tem efeito sobre a homogeneidade da unidade, se o campo de valor é inicial.
Para os campos de valor não- iniciais com a unidade inicial , o espaço da unidade é considerada como uma unidade, quando os totais específicos de unidade são calculados.
Referência à unidade de moeda

cfieldname ( nome de campo de campo unidade da moeda )
Faixa de valor : SPACE , o nome de um campo da tabela de saída
Só é relevante para atingir colunas com referência unidade.
Nome do campo do campo na tabela de saída interna que contém a unidade de moeda para o campo quantidade FIELDCAT - FIELDNAME .
Deve haver uma entrada de catálogo campo separado para o campo especificado no FIELDCAT - CFIELDNAME .
Referência para a unidade de medida

qfieldname ( nome do campo da unidade do campo de medida)
Faixa de valor : SPACE , o nome de um campo da tabela de saída
Só é relevante para as colunas de quantidade , com referência unidade.
Nome do campo do campo na tabela de saída interna que contém a unidade de medida para o campo quantidade FIELDCAT - FIELDNAME .
Deve haver uma entrada de catálogo campo separado para o campo especificado no FIELDCAT - QFIELDNAME .
Opções de saída para uma coluna

outputlen ( largura da coluna )
Escala: 0 (inicial ), n
Para os campos com referência ao Dicionário de Dados você pode deixar esse parâmetro definido como inicial.
Para os campos sem referência ao Dicionário de Dados (campos do programa) você deve definir o parâmetro para o comprimento desejado campo de saída na lista ( largura da coluna ) .
= iniciais A largura da coluna é derivada a partir do comprimento do campo referenciado ( domínio) no dicionário de dados de saída.
n = A largura da coluna é n caracteres.
chave ( coluna de chave )
Faixa de valor : SPACE , 'X'
'X' = campo chave ( saída de cor para os campos -chave)
Campos-chave não pode ser escondido de forma interativa pelo usuário.
Parâmetro FIELDCAT - NO_OUT deve ser deixado para definir inicial.
Para exceções , consulte a documentação do parâmetro FIELDCAT - KEY_SEL .
key_sel ( coluna de chave que pode ser escondido )
Faixa de valor : SPACE , 'X'
Só é relevante se FIELDCAT -KEY = 'X'
Campo de chave que pode ser escondido de forma interativa pelo usuário.
O usuário não pode interativamente alterar a sequência das colunas de chave .
Como em campos não-chave , controle de saída é realizada através do parâmetro FIELDCAT - NO_OUT .
no_out ( campo na lista de campos disponíveis )
Faixa de valor : SPACE , 'X'
'X' = campo não é exibido na lista atual .
O campo está disponível para o usuário na lista de campos e pode ser interativamente selecionado como um campo de exibição .
Ao nível da linha , o usuário pode utilizar a função de detalhe para exibir o conteúdo desses campos .
Veja também a documentação na seção "tela Detalhe ' de parâmetro IS_LAYOUT .
tecnologia ( área técnica )
Faixa de valor : SPACE , 'X'
'X ' = Campo técnico
O campo não pode ser a saída da lista e não podem ser mostrados de forma interativa pelo usuário.
O campo pode ser utilizado apenas no catálogo de campo ( não em IT_SORT , ... ) .
enfatizar ( destacar coluna na cor)
Faixa de valor : SPACE , 'X ' ou ' Cxyz ' (x : '1 ' - '9' , y, z: '0 ' = desligado 1 = ligado)
'X' = A coluna é destaque na cor padrão para realce de cores .
' Cxyz ' = A coluna é destaque na cor codificado :
C : Cor (codificação deve começar com C)
x: número de cores
y: Intensificação
z: Inverse
hotspot ( coluna como hotspot )
Faixa de valor : SPACE , 'X'
'X ' = As células da coluna são de saída como um ponto de acesso .
do_sum ( calcular totais por coluna)
Faixa de valor : SPACE , 'X'
'X' = totais são calculadas para este campo da tabela de saída interno.
Esta função também pode ser utilizada interactivamente pelo utilizador.
no_sum ( cálculo de totais não é permitido)
Faixa de valor : SPACE , 'X'
'X ' = Sem totais podem ser calculadas para este campo , embora o tipo de campo de dados , totalizando permite .
Formatar o conteúdo da coluna

icon (ícone)
Faixa de valor : SPACE , 'X'
'X' = O conteúdo da coluna são exibidos como um ícone.
O conteúdo da tabela de saída interna de coluna deve consistir de ícone cordas válidos ( xx @ @ ) .
O chamador deve considerar o problema dos ícones de impressão.
símbolo (símbolo)
Faixa de valor : SPACE , 'X'
'X ' = O conteúdo de coluna são produzidos como um símbolo.
O conteúdo da tabela de saída interno de coluna deve consistir de caracteres de símbolo válidos.
O chamador deve considerar o problema de impressão de símbolos .
Embora os símbolos podem geralmente ser impressos , eles não são sempre apresentados correctamente, dependendo da configuração da impressora .
apenas (justificação)
Faixa de valor : SPACE , 'R ', ' L' , 'C'
Relevante apenas para campos do tipo de dados CHAR ou NUMC
' = Justificativa padrão de acordo com o tipo de dados
'R' = saída justificado à direita
'L' = saída justificado à esquerda
'C' = saída Centered
A justificativa do cabeçalho da coluna depende da justificativa do conteúdo da coluna. Você não pode justificar o cabeçalho da coluna , independentemente do conteúdo das colunas.
lzero ( zeros à esquerda )
Faixa de valor : SPACE , 'X'
Relevante apenas para campos do tipo de dados NUMC
Por padrão , os campos NUMC são emitidos no ALV alinhado à direita , sem zeros à esquerda .
'X' = saída com zeros à esquerda
no_sign (sem sinal + / - )
Faixa de valor : SPACE , 'X'
Relevante apenas para campos de valor
'X' = saída Valor sem sinais + / - .
no_zero ( suprimir zeros)
Faixa de valor : SPACE , 'X'
Relevante apenas para campos de valor
'X ' = suprimir zeros
edit_mask (formatação de campo)
Faixa de valor : SPACE , máscara
mask = Consulte a documentação sobre a opção de formatação WRITE
Usando máscara máscara de edição
Usando máscara = ' == conv ' você pode forçar um conv conversão de saída.
textos

Os parâmetros a seguir para textos são sempre necessários para os campos do programa sem referência ao Dicionário de Dados.
Para os campos com referência ao Dicionário de Dados , os textos são recuperados a partir do Dicionário de Dados. Se você não quer isso, você pode preencher os parâmetros de texto também para campos com referência ao Dicionário de Dados. Se você fizer isso , os textos correspondentes do dicionário de dados será ignorado.
Se o usuário alterar a largura da coluna de forma interativa, o texto com o comprimento adequado é sempre usado como cabeçalho da coluna.
Se o usuário otimiza a largura da coluna de forma interativa, tanto o conteúdo do campo e os títulos de coluna são consideradas para a saída da lista :
Se todos os conteúdos do campo são menores do que a menor coluna , a largura da coluna é definida com base no título da coluna .
O campo de etiqueta longa é também utilizado nas caixas de diálogo para definir a variante de exibição, a ordem de classificação , e assim por diante .
seltext_l ( rótulo de campo de comprimento)
seltext_m ( rótulo de campo médio)
seltext_s ( rótulo do campo short)
reptext_ddic (posição )
Mesmo que o ' título ' para a manutenção elemento de dados.
Quando a lista estiver de saída, o sistema não necessariamente recuperar o texto armazenado aqui, mas usa o texto que se encaixa melhor .
ddictxt ( determinar texto )
Faixa de valor : SPACE , 'L' , 'M' , 'S' , 'R'
Usando os valores possíveis ' L' , 'M' , 'S' , 'R' você pode predefinir a palavra-chave que deve ser sempre recuperado como o cabeçalho da coluna. Se a largura da coluna for alterado, o sistema tenta encontrar um título que se encaixa a nova largura de saída.
Parâmetro para os campos do programa sem referência ao Dicionário de Dados

Veja também o parâmetro na seção "textos" .
tipo de dados (tipo de dados )
Faixa de valor : SPACE , tipo de dados a partir do Dicionário de Dados (CHAR , NUMC , ... )
Só é relevante para os campos sem referência ao Dicionário de Dados.
Tipo de campo de dados do programa
ddic_outputlen ( comprimento de saída externo)
Escala: 0 (inicial ), n
Só é relevante para os campos sem referência ao Dicionário de Dados , cujo resultado , no entanto, ser modificado usando uma saída de conversão.
Pré-requisitos:
FIELDCAT - EDIT_MASK = ' == conv '
Veja também a documentação sobre parâmetro FIELDCAT - EDIT_MASK
FIELDCAT - INTLEN = n
Consulte a documentação do parâmetro FIELDCAT - INTLEN
n = Campo comprimento do display externo de saída
A largura da coluna FIELDCAT - OUTPUTLEN não deve ser equivalente ao comprimento de saída do monitor externo ( FIELDCAT - DDIC_OUTPUTLEN ) .
intlen ( comprimento de saída interna)
Escala: 0 (inicial ), n
Só é relevante para os campos sem referência ao Dicionário de Dados , cujo resultado , no entanto, ser modificado usando uma saída de conversão.
Pré-requisitos:
FIELDCAT - EDIT_MASK = ' == conv '
Veja também a documentação sobre parâmetro FIELDCAT - EDIT_MASK
FIELDCAT - DDIC_OUTPUTLEN = n
Veja também a documentação sobre parâmetro FIELDCAT - DDIC_OUTPUTLEN
n = Campo comprimento do display interno de saída
rollname ( elemento de dados )
Faixa de valor : SPACE , o nome de um elemento de dados a partir do Dicionário de Dados
Você pode usar esse parâmetro para fornecer uma ajuda F1 para um campo de programa sem referência ao Dicionário de Dados ou para fornecer uma ajuda de F1 que não seja do dicionário de dados para um campo com referência ao Dicionário de Dados.
Quando a ajuda F1 é chamado para este campo , a documentação para o elemento de dados atribuído é exibida.
Se, por campos com referência ao Dicionário de Dados , FIELDCAT - rollname é inicial , a documentação para o elemento de dados do campo referenciado no Dicionário de Dados é exibida.
outro

sp_group (key grupo de campos )
Faixa de valor : SPACE , CHAR (1 )
Chave para campos de agrupamento
Você atribui a chave para a descrição do grupo usando IT_SPECIAL_GROUPS parâmetros ( ver também a documentação sobre IT_SPECIAL_GROUPS parâmetros) .
Se você definir como uma atribuição no catálogo de campos usando IT_SPECIAL_GROUPS , os campos na lista de campos da caixa de diálogo variante de exibição são agrupados em conformidade.
reprep ( critério de seleção da interface relatório / relatório )
Faixa de valor : SPACE , 'X'
Pré-requisitos:
A interface relatório / relatório existe no sistema .
(grupo de funções RSTI , mesa TRSTI )
Parâmetro LAYOUT- REPREP = 'X'
(Veja também a documentação do parâmetro
LAYOUT- REPREP de importação de parâmetro
IS_LAYOUT )
'X ' = Se a interface de relatório / relatório é chamado, o valor deste campo é transmitido como um critério de selecção de linha da interface ramo seleccionado.
faixa de valor

omissão

Para os campos da tabela interna com referência a um campo definido no Dicionário de Dados , que é normalmente suficiente para fazer as seguintes especificações:
nome do campo
ref_tabname
Nota:

Todos os campos que não são explicitamente mencionados aqui são ou não relevantes neste contexto ou não são liberados !

Todas as outras informações são recuperados pela ALV do Dicionário de Dados.

Se você não especificar a posição da coluna relativa ( COL_POS ) , os campos estão de saída na lista na ordem em que foram adicionados ao catálogo de campos .

REF_FIELDNAME só deve ser especificado se o nome do campo do campo de tabela interna não é idêntico ao nome do campo do campo referenciado no Dicionário de Dados.

Regra de prioridade :
Especificações feitas no catálogo de campos têm prioridade sobre as especificações do Dicionário de Dados.
Para os campos de tabela interna sem referência ao Dicionário de Dados (campos do programa) , que é normalmente suficiente para fazer as seguintes especificações:
nome do campo
outputlen
tipo de dados (sem tipo de dados , o caráter é o padrão)
seltext_s
seltext_l
Nota:

Se você atribuir um elemento de dados de parâmetro rollname , você pode , por exemplo, implementar uma ajuda F1 para os campos do programa.

*************************************************************************************************************************************************************

	*   IT_EXCLUDING                      =
 
*************************************************************************************************************************************************************

	*   IT_SPECIAL_GROUPS                 =

*************************************************************************************************************************************************************

	it_sort - Ordenar 
 
*************************************************************************************************************************************************************
 
	*   IT_FILTER                         =
 
*************************************************************************************************************************************************************
 
	*   IS_SEL_HIDE                       =
 
*************************************************************************************************************************************************************

	*   I_DEFAULT                         = 'X'
 
*************************************************************************************************************************************************************

	I_SAVE - salvar configuração feita pelo usuário - Colocar X.
 
*************************************************************************************************************************************************************
 
	*   IS_VARIANT                        =
 
*************************************************************************************************************************************************************
 
*   IT_EVENTS                         =
 
*************************************************************************************************************************************************************
 
	IT_EVENT_EXIT

		Descrição

		Esta tabela é usada para passar os códigos de função ALV padrão para a qual o usuário deseja obter o controle antes e / ou após a sua 
		execução por meio do evento callback USER_COMMAND .

		Veja também a documentação sobre a importação de parâmetro I_CALLBACK_USER_COMMAND .

		Portanto, só faz sentido para passar esta tabela se o aplicativo também quer responder à execução de funções padrão , sob qualquer forma .

		Este poderia ser o caso, por exemplo, se as autorizações de uma função de padrão devem ser verificados ou se novos dados é para ser 
		seleccionado com base na variante visor actual.

		Nota: Funções 'Voltar (F3) " ", Exit ( F15 ) ' e ' Cancelar ( F12) " há funções padrão ALV , mas funções do sistema. Se a aplicação quer 
		para responder a essas funções ( por exemplo, para executar um prompt antes de sair a lista de confirmação) , estas funções devem ser 
		atribuídos os códigos de funções específicas do aplicativo .

		Você deve preencher os campos da tabela da seguinte forma:

		ucomm - Código de função padrão que também deve ser transmitida por meio de evento de retorno de chamada USER_COMMAND .
		Exemplo:
		ucomm = ' & OL0 ' significa que o aplicativo também obtém o controle para o código de função para definir a variante de exibição .
		antes
		'X' = O aplicativo obtém o controle antes da ALV executa a função .
		depois
		'X ' = O pedido recebe controlo após a ALV executou a função , mas antes de a lista é a saída.
		Exemplo:
		ucomm = ' & OL0 ' e depois = ' X'.
		O aplicativo obtém o controle após o usuário ter deixado a caixa de diálogo para definir a variante de exibição.
		Na rotina formulário correspondente para o processamento dos códigos de função comunicadas à ALV através do parâmetro 
		I_CALLBACK_USER_COMMAND , o aplicativo pode agora usar a função módulo REUSE_ALV_LIST_LAYOUT_INFO_GET para obter o catálogo de campos que 
		podem ter sido modificados como resultado da interação do usuário e , em seguida, selecionar os dados para o campos de saída recentemente 
		adicionado na tabela de saída interno.
		Se, após a seleção, o aplicativo define o indicador = SELFIELD -refresh 'X' ( parâmetro de referência da interface de rotina de forma 
		USER_COMMAND ), a lista é a saída novamente. O sistema exibe os campos de saída adicionados pelo usuário e os dados recém-selecionados .
		faixa de valor

		Default
 
*************************************************************************************************************************************************************

	*   IS_PRINT                          =
 
*************************************************************************************************************************************************************

	*   IS_REPREP_ID                      =
 
*************************************************************************************************************************************************************

	I_SCREEN_START_COLUMN             = 0
 
*************************************************************************************************************************************************************

	*   I_SCREEN_START_LINE               = 0
 
*************************************************************************************************************************************************************

	*   I_SCREEN_END_COLUMN               = 0
 
*************************************************************************************************************************************************************

	*   I_SCREEN_END_LINE                 = 0
 
*************************************************************************************************************************************************************

	*   I_HTML_HEIGHT_TOP                 = 0
 
*************************************************************************************************************************************************************

	*   I_HTML_HEIGHT_END                 = 0
 
*************************************************************************************************************************************************************

	*   IT_ALV_GRAPHICS                   =
 
*************************************************************************************************************************************************************
 
	*   IT_HYPERLINK                      =
 
*************************************************************************************************************************************************************
 
	*   IT_ADD_FIELDCAT                   =
 
*************************************************************************************************************************************************************
 
	*   IT_EXCEPT_QINFO                   =
 
*************************************************************************************************************************************************************
 
	*   IR_SALV_FULLSCREEN_ADAPTER        =
 
*************************************************************************************************************************************************************
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

* IMPORTING
 
*************************************************************************************************************************************************************
 
	*   E_EXIT_CAUSED_BY_CALLER           =
 
*************************************************************************************************************************************************************

	*   ES_EXIT_CAUSED_BY_USER            =
 
*************************************************************************************************************************************************************
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

TABLES
 
*************************************************************************************************************************************************************
 
	t_outtab - Nome da tabela que contem os campos a serem impressos
 
*************************************************************************************************************************************************************
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 

EXCEPTIONS

*************************************************************************************************************************************************************

	PROGRAM_ERROR                     = 1
 
*************************************************************************************************************************************************************
 
	OTHERS                            = 2.
