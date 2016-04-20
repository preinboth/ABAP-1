  FIELD-SYMBOLS: <fs_table> TYPE table,
                 <st_table> TYPE any,
                 <fs_campo> TYPE any.

 ASSIGN gt_table->* TO <fs_table>.
      IF sy-subrc = 0 .

        DESCRIBE TABLE <fs_table> LINES l_linhas.
        
        LOOP AT <fs_table> ASSIGNING <st_table>."INTO st_table.

           l_index = sy-tabix.
           ASSIGN COMPONENT 'REVOK' OF STRUCTURE <st_table> TO <fs_campo>.
           IF <fs_campo> IS ASSIGNED.
              <fs_campo> = 'X'.
           ENDIF.
           UNASSIGN <fs_campo>.

        ENDLOOP.

 UNASSIGN <fs_table>.