form busca_dados .
  data: ls_zmmt002  type zmmt002.

  data: vl_tabela   type c length 10,
        vl_from     type string,
        vl_condicao type string.

  field-symbols: <fs_tabela> type any table,
                 <fs_campo>  type any.
  select *
    into table ti_zmmt002
    from zmmt002.

  check ti_zmmt002[] is not initial.

  perform monta_range.

  clear: vl_tabela, vl_condicao.
  clear: ti_ekpo[], ti_ekpo.

  do 3 times.
    if vl_tabela is initial.
      clear: vl_tabela, vl_condicao.
      vl_tabela = 'TI_EKKO_01'.
      assign ti_ekko_01 to <fs_tabela>.
      check <fs_tabela> is assigned.
      concatenate vl_condicao 'eq_eindt IN r_eq_eindt_01 AND'   into  vl_condicao separated by space.
      concatenate vl_condicao 'bstyp    = c_bstyp        AND'   into  vl_condicao separated by space.
      concatenate vl_condicao '( bsart  = ti_zmmt002-bsart  OR' into  vl_condicao separated by space.
      concatenate vl_condicao 'ebeln  = ti_zmmt002-ebeln )'     into  vl_condicao separated by space.
    elseif vl_tabela = 'TI_EKKO_01'.
      clear: vl_tabela, vl_condicao.
      vl_tabela = 'TI_EKKO_02'.
      assign ti_ekko_02 to <fs_tabela>.
      check <fs_tabela> is assigned.
      concatenate vl_condicao 'eq_eindt IN r_eq_eindt_02 AND'   into  vl_condicao separated by space.
      concatenate vl_condicao 'bstyp    = c_bstyp        AND'   into  vl_condicao separated by space.
      concatenate vl_condicao '( bsart  = ti_zmmt002-bsart  OR' into  vl_condicao separated by space.
      concatenate vl_condicao 'ebeln  = ti_zmmt002-ebeln )'     into  vl_condicao separated by space.
    elseif vl_tabela = 'TI_EKKO_032'.
      clear: vl_tabela, vl_condicao.
      vl_tabela = 'TI_EKKO_03'.
      assign ti_ekko_03 to <fs_tabela>.
      check <fs_tabela> is assigned.
      concatenate vl_condicao 'eq_eindt IN r_eq_eindt_03 AND'   into  vl_condicao separated by space.
      concatenate vl_condicao 'bstyp    = c_bstyp        AND'   into  vl_condicao separated by space.
      concatenate vl_condicao '( bsart  = ti_zmmt002-bsart  OR' into  vl_condicao separated by space.
      concatenate vl_condicao 'ebeln  = ti_zmmt002-ebeln )'     into  vl_condicao separated by space.
    endif.

    select ebeln eq_eindt bsart konnr kdate
      into table <fs_tabela>
      from ekko
      for all entries in ti_zmmt002
      where (vl_condicao).

    if <fs_tabela>[] is not initial.

      clear: vl_from, vl_condicao.
      concatenate 'ekpo FOR ALL ENTRIES IN ' vl_tabela into vl_from      separated by space.
      concatenate 'ebeln = ' ' ' vl_tabela '-ebeln'    into vl_condicao.


      select ebeln ebelp menge
        appending table ti_ekpo
        from (vl_from)
        where (vl_condicao).

    endif.

    unassign <fs_tabela>.

  enddo.

endform.                    " BUSCA_DADOS
