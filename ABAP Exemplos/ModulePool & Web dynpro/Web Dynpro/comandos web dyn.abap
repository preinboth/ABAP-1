************************************************************************************************************************************************************************
PEGAR DADOS DO NO

    data nd_root TYPE REF TO if_wd_context_node.
    
    nd_root = wd_context->get_child_node( wd_this->wdctx_nd_selecao ).


************************************************************************************************************************************************************************
PEGAR UM ELEMENTO

	data el_root type ref to if_wd_context_element.

	wdevent->get_context_element( EXPORTING name = 'CONTEXT_ELEMENT'
                                      RECEIVING value = el_root ).

************************************************************************************************************************************************************************
GERAR MENSAGEM NA TELA

  data lo_api_controller TYPE REF TO if_wd_controller.
  data lo_message_manager TYPE REF TO if_wd_message_manager.
  data l_string type string.

  l_string = 'Dados Salvos'.

  lo_api_controller ?= wd_this->wd_get_api( ).

  call METHOD lo_api_controller->get_message_manager
  receiving message_manager = lo_message_manager.

* MENSGEM DE SUCESSO

  call METHOD lo_message_manager->report_success      
  EXPORTING message_text = l_string.

* MENSAGEM DE ERRO

      call METHOD lo_message_manager->raise_error_message
      EXPORTING
          message_text = l_string.


***********************************************************************************************************************************************************************
VERICAR CAMPOS OBRIGATORIOS

method WDDOBEFOREACTION .
  data lo_api_controller type ref to if_wd_view_controller.
  data lo_action         type ref to if_wd_action.


  lo_api_controller = wd_this->wd_get_api( ).
  lo_action = lo_api_controller->get_current_action( ).

  if lo_action is bound.
    case lo_action->name.
      when 'SAVE'.
          CALL METHOD cl_wd_dynamic_tool=>check_mandatory_attr_on_view
            EXPORTING
              view_controller = lo_api_controller.
    endcase.
  endif.

endmethod.

************************************************************************************************************************************************************************
CRIAR JANELA DE CONFIRMACAO

DATA lo_window_man    TYPE REF TO if_wd_window_manager.
  DATA lo_api_component TYPE REF TO if_wd_component.
  DATA lo_window        TYPE REF TO if_wd_window.
  DATA lt_string        TYPE string_table.
  DATA l_string         TYPE string.
  DATA lo_api_start_view TYPE REF TO if_wd_view_controller.


  lo_api_component = wd_comp_controller->wd_get_api( ).
  lo_window_man = lo_api_component->get_window_manager( ).

  l_string = 'Deseja realmente eleminar o registro?'.
  APPEND l_string TO lt_string.

  lo_window = lo_window_man->create_popup_to_confirm( text = lt_string
                                                      button_kind = 4
                                                      window_title = 'Requião' ).


  lo_api_start_view = wd_this->wd_get_api( ).

  CALL METHOD lo_window->subscribe_to_button_event
    EXPORTING
      button      = if_wd_window=>co_button_yes
      action_name = 'DELETE'
      action_view = lo_api_start_view.

  lo_window->open( ).
************************************************************************************************************************************************************************
CRIAR ALV

  DATA  lo_cmp_usage           TYPE REF TO if_wd_component_usage.
  DATA  lo_interfacecontroller TYPE REF TO iwci_salv_wd_table.
  DATA  lv_value               TYPE REF TO cl_salv_wd_config_table.
  DATA  lo_drn_key             TYPE REF TO cl_salv_wd_uie_dropdown_by_key.
  DATA  lo_input_field             TYPE REF TO cl_salv_wd_uie_input_field.
  DATA  lo_button             TYPE REF TO cl_salv_wd_uie_button.
  DATA  lo_fe_button           TYPE REF TO cl_salv_wd_fe_button.
  DATA  lo_function            TYPE REF TO cl_salv_wd_function.

  DATA: lo_col_header TYPE REF TO cl_salv_wd_column_header.

  DATA: lr_column_settings TYPE REF TO if_salv_wd_column_settings,
        lt_columns         TYPE        salv_wd_t_column_ref,
        lo_column          TYPE        salv_wd_s_column_ref,
        lo_new_col         TYPE REF TO cl_salv_wd_column.


  DATA  lo_text            TYPE REF TO cl_salv_wd_uie_text_view.
  DATA  l_string           TYPE        string.


  lo_cmp_usage =   wd_this->wd_cpuse_alv( ).
  IF lo_cmp_usage->has_active_component( ) IS INITIAL.
    lo_cmp_usage->create_component( ).
  ENDIF.
  lo_interfacecontroller =   wd_this->wd_cpifc_alv( ).
  lv_value = lo_interfacecontroller->get_model( ).
************************************************************************************************************************************************************************
CONFIGURAR ALV

Configuração do ALV.
METHOD onconfig_alv .


  DATA  lo_cmp_usage           TYPE REF TO if_wd_component_usage.
  DATA  lo_interfacecontroller TYPE REF TO iwci_salv_wd_table.
  DATA  lv_value               TYPE REF TO cl_salv_wd_config_table.
  DATA  lo_drn_key             TYPE REF TO cl_salv_wd_uie_dropdown_by_key.
  DATA  lo_button             TYPE REF TO cl_salv_wd_uie_button.
  DATA  lo_fe_button           TYPE REF TO cl_salv_wd_fe_button.
  DATA  lo_function            TYPE REF TO cl_salv_wd_function.

  DATA: lo_col_header TYPE REF TO cl_salv_wd_column_header.

  DATA: lr_column_settings TYPE REF TO if_salv_wd_column_settings,
        lt_columns         TYPE        salv_wd_t_column_ref,
        lo_column          TYPE        salv_wd_s_column_ref,
        lo_new_col         TYPE REF TO cl_salv_wd_column.


  DATA  lo_text            TYPE REF TO cl_salv_wd_uie_text_view.
  DATA  l_string           TYPE        string.


  lo_cmp_usage =   wd_this->wd_cpuse_alv( ).
  IF lo_cmp_usage->has_active_component( ) IS INITIAL.
    lo_cmp_usage->create_component( ).
  ENDIF.
  lo_interfacecontroller =   wd_this->wd_cpifc_alv( ).
  lv_value = lo_interfacecontroller->get_model( ).

* Definição de Exibição da ALV de Projetos
  lv_value->if_salv_wd_table_settings~set_design( 00 ).
  lv_value->if_salv_wd_std_functions~set_pdf_allowed( abap_false ).
  lv_value->if_salv_wd_table_settings~set_empty_table_text( 'Não existem dados para exibição' ).
  lv_value->if_salv_wd_table_settings~set_on_select_enabled( abap_true ).
  lv_value->if_salv_wd_table_settings~set_visible_row_count( 5 ).
*******************************************


  lt_columns = lv_value->if_salv_wd_column_settings~get_columns( ).

  LOOP AT lt_columns INTO lo_column.

    IF lo_column-id EQ 'STATUS'.

      CREATE OBJECT lo_drn_key
        EXPORTING
          selected_key_fieldname = 'STATUS'.

      lo_column-r_column->set_cell_editor( lo_drn_key ).

    ENDIF.

  ENDLOOP.
  lo_new_col = lv_value->if_salv_wd_column_settings~create_column( id = 'DET' ).

  CREATE OBJECT lo_button.
  lo_button->set_image_source( '~Icon/TbDetail' ).
  lo_new_col->set_cell_editor( lo_button ).
  lo_new_col->set_width( '5px' ).



ENDMETHOD.

************************************************************************************************************************************************************************
Criar icone na alv

METHOD build_alv.
  DATA:
    lr_alv_usage       TYPE REF TO if_wd_component_usage,
    lr_if_controller   TYPE REF TO iwci_salv_wd_table,
    lr_config          TYPE REF TO cl_salv_wd_config_table,
    lr_column_settings TYPE REF TO if_salv_wd_column_settings,
    lt_columns         TYPE        salv_wd_t_column_ref,
    lr_image           type ref to cl_salv_wd_uie_image.
  FIELD-SYMBOLS
    <fs_column> LIKE LINE OF lt_columns.

* Instantiate the ALV Component
  lr_alv_usage = wd_this->wd_cpuse_cmp_alv( ).
  IF lr_alv_usage->has_active_component( ) IS INITIAL.
    lr_alv_usage->create_component( ).
  ENDIF.

* Get reference to model
  lr_if_controller = wd_this->wd_cpifc_cmp_alv( ).
  lr_config        = lr_if_controller->get_model( ).

* Set the UI elements.
  lr_column_settings ?= lr_config.
  lt_columns = lr_column_settings->get_columns( ).

  LOOP AT lt_columns ASSIGNING <fs_column>.
    CASE <fs_column>-id.
      WHEN 'CANCELLED'.
        CREATE OBJECT lr_image.
        lr_image->set_source_fieldname( <fs_column>-id ).
        <fs_column>-r_column->set_cell_editor( lr_image ).
        FREE lr_image.
    ENDCASE.
  ENDLOOP.
ENDMETHOD.






************************************************************************************************************************************************************************
CRIAR POPUP DE CONFIRMAÇÃO

DATA lo_window_man    TYPE REF TO if_wd_window_manager.
  DATA lo_api_component TYPE REF TO if_wd_component.
  DATA lo_window        TYPE REF TO if_wd_window.
  DATA lt_string        TYPE string_table.
  DATA l_string         TYPE string.
  DATA lo_api_start_view TYPE REF TO if_wd_view_controller.


  lo_api_component = wd_comp_controller->wd_get_api( ).
  lo_window_man = lo_api_component->get_window_manager( ).

  l_string = 'Deseja realmente eleminar o registro?'.
  APPEND l_string TO lt_string.

  lo_window = lo_window_man->create_popup_to_confirm( text = lt_string
                                                      button_kind = 4
                                                      window_title = 'Requião' ).


  lo_api_start_view = wd_this->wd_get_api( ).

  CALL METHOD lo_window->subscribe_to_button_event
    EXPORTING
      button      = if_wd_window=>co_button_yes
      action_name = 'DELETE'
      action_view = lo_api_start_view.

  lo_window->open( ).

************************************************************************************************************************************************************************
CRIAR SELECT OPTIONS

  DATA: lt_range TYPE REF TO data,
        read_only TYPE wdy_boolean,
        type_name TYPE string.

  DATA: lr_componentcontroller TYPE REF TO ig_componentcontroller,
        l_ref_cmp_usage TYPE REF TO if_wd_component_usage.

  l_ref_cmp_usage = wd_this->wd_cpuse_<NOME DO COMPONENT USE>( ).
  IF l_ref_cmp_usage->has_active_component( ) IS INITIAL.
    l_ref_cmp_usage->create_component( ).

  ENDIF.

  wd_this->m_wd_select_options = wd_this->wd_cpifc_<NOME DO COMPONENT USE>( ).
  wd_this->m_handler = wd_this->m_wd_select_options->init_selection_screen( ).

  lt_range = wd_this->m_handler->create_range_table( i_typename = 'MATNR' ).

  wd_this->m_handler->add_selection_field( i_id = 'S_MATNR'
                                           it_result = lt_range
                                           i_read_only = read_only ).

  wd_this->m_handler->set_global_options( i_display_btn_cancel = abap_false
                                          i_display_btn_check = abap_false
                                          i_display_btn_reset = abap_false
                                          i_display_btn_execute = abap_false ).

method ONACTIONONEXECUTE .

  DATA rt_matnr TYPE REF TO data.
  FIELD-SYMBOLS <fs_range> TYPE table.

  rt_matnr = wd_this->m_handler->get_range_table_of_sel_field( i_id = 'S_MANTR' ).

  ASSIGN rt_matnr->* to <fs_range>.

endmethod.

METHOD CLEAR_FIELDS .
	Wd_this->m_handler->reset_selection_field( ‘S_MATNR’ )
	Wd_this->m_handler->reset_selection_field( ‘S_MTART’ )
ENDMETHOD.

	
************************************************************************************************************************************************************************
CRIAR TELA DINAMICA

  DATA lo_tpc TYPE REF TO cl_wd_transparent_container.
  DATA lo_input_field TYPE REF TO cl_wd_input_field.
  DATA lo_gridlayout_data TYPE REF TO cl_wd_grid_data.


  DATA lo_BUTTON TYPE REF TO CL_WD_BUTTON.



  lo_tpc ?= inview->get_element( 'TCP1' ).
  lo_input_field = cl_wd_input_field=>new_input_field( ID = 'IPF' ).
  lo_gridlayout_data = cl_wd_grid_data=>new_grid_data( lo_input_field ).
  lo_input_field->set_layout_data( lo_gridlayout_data ).
  lo_input_field->bind_value( 'ND_FIELD.VALOR' ).
  lo_tpc->ADD_CHILD( lo_input_field ).

  lo_BUTTON = CL_WD_BUTTON=>NEW_BUTTON( ID = 'BTN' ).
  lo_gridlayout_data = cl_wd_grid_data=>new_grid_data( lo_BUTTON ).
  lo_BUTTON->set_layout_data( lo_gridlayout_data ).
  LO_BUTTON->SET_TEXT( 'TESTE' ).
  lo_tpc->add_child( lo_BUTTON ).

************************************************************************************************************************************************************************
