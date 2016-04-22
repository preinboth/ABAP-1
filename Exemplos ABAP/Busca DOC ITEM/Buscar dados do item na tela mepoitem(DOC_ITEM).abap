    DATA: ls_item               TYPE mepoitem.


CALL METHOD im_item->get_data( RECEIVING re_data = ls_item ).

ls_item = im_item->get_data( ).

         CALL FUNCTION 'MEPO_DOC_ITEM_GET'
          EXPORTING
            im_ebelp = im_item-po_item_number (ebelp)
          IMPORTING
            ex_item  = lt_mepoitem
          EXCEPTIONS
            failure  = 01.

=========================================================================

      CALL METHOD l_header->get_data
        IMPORTING
          ex_data = l_data.

      mepo_topline_pbo = build_topline( l_data ).
