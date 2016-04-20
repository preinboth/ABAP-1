Adicionando botões em relatório ALV

*Adicionando botões em relatório ALV
*criar uma função para realizar a execução do botão dentro da alv:
FORM user_command USING r_ucomm TYPE sy-ucomm
r_refresh
r_exit
rs_stable TYPE lvc_s_stbl.
DATA: ls_selfield TYPE slis_selfield.
ENDFORM. "user_command
*criar uma função para ativar a status gui com os novos botões :
FORM f_set_status USING pf_tab TYPE slis_t_extab.
SET PF-STATUS ‘STATUS001'. " excluding pf_tab.
ENDFORM. "f_set_status

*copiar o status gui: STANDARD_FULLSCREEN
*do programa (grupo de funções): ‘SLVC_FULLSCREEN e adicionar os botões desejados.
*adicionar a chamada destas funções na chamada da alv:
call function ‘reuse_alv_grid_display’
exporting
i_callback_program = v_repid
i_callback_pf_status_set = ‘f_set_status’
i_callback_user_command = ‘f_user_command’