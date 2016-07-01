#Remove spaces from character field (CONDENSE)
**The CONDENSE command is used to remove spaces from a character field. See example below.**


**P_field must be of type character**
#Code to demonstrate CONDENSE command
_Código_
<div class><pre>
DATA: ld_field(50) type c.

p_field = 'Welcome to SAPDev'.

CONDENSE p__field NO-GAPS.



"Result of p_field would be: **'WelcometoSAPDev'**
</pre></div class>
_By Gabriel Souza._
