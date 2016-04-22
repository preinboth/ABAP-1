Unimarka => ZSDR058



*----------------------------------------------------------------------*
* Declarações para tabela dinamica
*----------------------------------------------------------------------*
* Essa tabela armazena o conteúdo de todos os componentes (campos)
DATA: t_comp   TYPE cl_abap_structdescr=>component_table.

* Objeto utilizado para criar a estrutura dinâmica
DATA: o_strtype  TYPE REF TO cl_abap_structdescr.

* Objeto utilizado para criar a tabek dinâmica
DATA: o_tabtype  TYPE REF TO cl_abap_tabledescr.

* O nosso ponto de dados de referência
DATA: wa_data   TYPE REF TO data.

* Área de trabalho para lidar com atributos e o nome de cada campo.
DATA: wa_comp      LIKE LINE OF t_comp.

* Variáveis para construir o nome de cada campo
DATA: v_nome_campo   TYPE txt30.
DATA: v_numero_campo TYPE text10.

* Ponteiro para manipular tabela interna dinâmica
FIELD-SYMBOLS: <t_tab> TYPE table.

* Ponteiro para manipular work área dinâmica
FIELD-SYMBOLS: <wa_tab> TYPE any.

* Ponteiro para manipular campo
FIELD-SYMBOLS: <fs_campo> TYPE any.
