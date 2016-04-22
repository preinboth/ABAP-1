REPORT  Zw4nd3r_TREE.

TYPE-POOLS : fibs, stree.

DATA : t_node TYPE snodetext.

DATA : node_tab LIKE t_node OCCURS 0 WITH HEADER LINE.
DATA: w_tabix TYPE  sy-tabix.

CLEAR : node_tab, node_tab[].

DEFINE zmcr_add_node.
node_tab-type     = &1. "Tipo
node_tab-name     = &2. "Nome Principal
node_tab-tlevel   = &3. "Nível
node_tab-nlength  = &4. "Tamanho do campo
node_tab-color    = &5. "Cor
node_tab-text     = &6. "Descrição do Campo
node_tab-tlength  = &7. "Tamano da Descrição
node_tab-tcolor   = &8. "Cor da Descrição

append node_tab.
END-OF-DEFINITION.

DATA: BEGIN OF  it_mara OCCURS 0,
matnr TYPE  mara-matnr,
END OF it_mara,

BEGIN OF it_makt OCCURS 0,
matnr TYPE makt-matnr,
spras TYPE makt-spras,
maktx TYPE makt-maktx,
END OF it_makt.

SELECT matnr
FROM mara
INTO TABLE it_mara.

SELECT matnr spras maktx
FROM makt
INTO TABLE it_makt
FOR ALL ENTRIES IN it_mara
WHERE matnr EQ it_mara-matnr.

SORT: it_mara BY matnr,
it_makt BY matnr spras.

sy-tleng = STRLEN( text-000 ).

zmcr_add_node: 'T' text-000 '01' sy-tleng '7' space space space.

LOOP AT it_mara.
w_tabix = sy-tabix.

zmcr_add_node: 'P' it_mara-matnr '02' '18' sy-tabix space space space.

READ TABLE it_makt WITH KEY matnr = it_mara-matnr BINARY SEARCH.

LOOP AT it_makt FROM sy-tabix.
IF it_makt-matnr NE it_mara-matnr.
EXIT.
ENDIF.
zmcr_add_node: 'P' it_makt-spras '03' '02' sy-tabix it_makt-maktx '50' sy-tabix.
ENDLOOP.
ENDLOOP.

CALL FUNCTION 'RS_TREE_CONSTRUCT'
TABLES
nodetab            = node_tab
EXCEPTIONS
tree_failure       = 1
id_not_found       = 2
wrong_relationship = 3
OTHERS             = 4.

IF sy-subrc <> 0.
MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

CALL FUNCTION 'RS_TREE_LIST_DISPLAY'
EXPORTING
use_control = 'L'.

**********end of program           .