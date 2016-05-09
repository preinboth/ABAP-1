FORM cabecalho_mail.
  WRITE v_data DD/MM/YYYY TO v_data_email.
  CONCATENATE v_email_corpo
        '<b>'
        '<span style="color:#1F497D; font-family:Calibri; font-size:larger">Cotações Atualizadas em'
        v_data_email
        '<br />'
        '</span>'
        '</b>'
        '<hr />'
        '<BR />' INTO v_email_corpo SEPARATED BY space.
ENDFORM.                    "CABECALHO_MAIL





FORM header_cat USING categoria.

  clear: wa_tcurw.
  READ TABLE t_tcurw INTO wa_tcurw WITH TABLE KEY KURST = categoria.

  CONCATENATE v_email_corpo
  '<table border="1" cellpadding="1" cellspacing="0" >'
  '<tr height="20" style="font-size: 11.0pt; color: white; '
  'font-weight: 700; text-decoration: none; text-underline-style: none; text-line-through: none;'
  ' font-family: Calibri; border-top: .5pt solid #95B3D7; border-right: none; border-bottom: .5pt solid #95B3D7;'
  ' border-left: .5pt solid #95B3D7; background: #4F81BD; mso-pattern: #4F81BD none">'
  '<td nowrap="nowrap" style="border-right: windowtext 1pt solid; padding-right: 5.4pt;'
  'border-top: #f0f0f0; padding-left: 5.4pt; background: #4f81bd; padding-bottom: 0in;'
  'border-left: #f0f0f0; width: 170pt; padding-top: 0in; border-bottom: windowtext 1pt solid;'
  'height: 15pt" valign="bottom">'
  '<p class="MsoNormal" style="margin: 0in 0in 0pt">'
                '<b><span style="font-size: 11pt; color: white; font-family: ''Calibri'',''sans-serif''">'
                    'Categoria' categoria
                    '<br />'
                '</span></b><b><span style="font-size: 9pt; color: white; font-family: ''Calibri'',''sans-serif''">'
                    wa_tcurw-curvw
                    '<o:p></o:p>'
                '</span></b>'
            '</p>'
  '</td>'
  '<td style="border-style: none solid solid none;'
  ' border-color: -moz-use-text-color rgb(149, 179, 215) rgb(149, 179, 215) -moz-use-text-color;'
  ' border-width: medium 1pt 1pt medium; padding: 0in 5.4pt; height: 15pt;"'
  ' nowrap="nowrap" valign="bottom" >'
  '    Taxa</td>'
  '</tr>'  INTO v_email_corpo SEPARATED BY space.
ENDFORM.                    "HEADER_CAT

FORM fecha_cat.
  CONCATENATE v_email_corpo
  '</table>' '<br />'
    INTO v_email_corpo SEPARATED BY space.
ENDFORM.                    "FECHA_CAT

*&---------------------------------------------------------------------*
*&      Form  envia_mail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM envia_mail.
  DATA:  lr_mail_data            TYPE REF TO cl_crm_email_data,
         ls_struc_mail           TYPE crms_email_mime_struc,
         lv_send_request         TYPE sysuuid_x,
         lv_to                   TYPE crms_email_recipient,
         v_dt_rod(16) TYPE c,
         v_hr_rod(5).

  WRITE sy-datum TO v_dt_rod DD/MM/YYYY.
  CONCATENATE sy-uzeit(2) ':' sy-uzeit+2(2) INTO v_hr_rod.
  CONCATENATE v_dt_rod v_hr_rod INTO v_dt_rod SEPARATED BY space.

*   Cria a Mensagem de E-mail
  CREATE OBJECT lr_mail_data.

*   Preenche o Remetente.
  lr_mail_data->from-address = 'Integração de cotação de moedas <postmaster@samarco.com>'.
  lr_mail_data->from-name    = lr_mail_data->from-address.
  lr_mail_data->from-id      = lr_mail_data->from-address.

**   Preenche os Destinatários.
  LOOP AT s_email.
    lv_to-address = s_email-low.
    lv_to-name    = sy-tabix.
    APPEND lv_to TO lr_mail_data->to.
  ENDLOOP.


*   Define o Assunto do E-mail
  CONCATENATE 'COTAÇÃO DE MOEDAS -' sy-datum INTO  lr_mail_data->subject SEPARATED BY space.

*   Define o Assunto do E-mail
  IF sy-sysid EQ 'R6Q'.
    CONCATENATE lr_mail_data->subject 'Ambiente Qualidade' INTO lr_mail_data->subject SEPARATED BY space.
  ELSEIF sy-sysid EQ 'R3P'.
    CONCATENATE lr_mail_data->subject 'Ambiente Produção' INTO lr_mail_data->subject SEPARATED BY space.
  ENDIF.

*  if v_diautil = 'X'.
  v_urlbcb = '<a href="http://www4.bcb.gov.br/pec/taxas/port/ptaxnpesq.asp?id=txcotacao&id=txcotacao">http://www4.bcb.gov.br/pec/taxas/port/ptaxnpesq.asp?id=txcotacao&id=txcotacao</a>'.
  v_urlbce = '<a href="http://www.ecb.int/stats/exchange/eurofxref/html/eurofxref-graph-usd.en.html">http://www.ecb.int/stats/exchange/eurofxref/html/eurofxref-graph-usd.en.html</a>'.
*  else.
*    v_urlbcb = 'SAP - OB08'.
*    v_urlbce = 'SAP - OB08'.
*  endif.

  CONCATENATE v_email_corpo
      '<p class="MsoNormal">'
      '    <span style="font-family:&quot;Calibri&quot;,&quot;sans-serif&quot;;'
      'color:#1F497D" class="style1">Fontes: </span>&nbsp;</p>'
      '<div align="center" class="MsoNormal" style="text-align:center">'
      '    <hr align="center" size="2" width="100%" />'
      '</div>'
      '            <p class="MsoNormal" style="mso-margin-top-alt:auto;mso-margin-bottom-alt:auto">'
      '                <span lang="PT-BR" style="font-size:11.0pt;font-family:&quot;Calibri&quot;,&quot;sans-serif&quot;;'
      '  color:black;mso-ansi-language:PT-BR">Banco Central do Brasil - ' v_dt_rod ' - ' v_urlbcb '<br></br>'
      'Banco Central Europeu - ' v_dt_rod ' - ' v_urlbce '</span><span style="color:'
      '  black"><o:p></o:p></span>'
      '            </p>'
 INTO v_email_corpo SEPARATED BY space.


*   Mensagem no Corpo do E-mail.
  ls_struc_mail-mime_type     = 'text/html'.
  ls_struc_mail-file_name     = 'body.htm'.
  ls_struc_mail-content_ascii =  v_email_corpo.
  APPEND ls_struc_mail TO lr_mail_data->body.


*   Prepara os Anexos
*  ls_struc_mail-is_attachment = 'X'.
*    ls_struc_mail-mime_type     = 'application/pdf'.
*  MOVE 'application/textedit' TO ls_struc_mail-mime_type.

*   Envia o E-mail
  lv_send_request = cl_crm_email_utility_base=>send_email( iv_mail_data = lr_mail_data ).

* Processa o Envio Imediato
  SUBMIT rsconn01 AND RETURN.
ENDFORM.                    "envia_mail