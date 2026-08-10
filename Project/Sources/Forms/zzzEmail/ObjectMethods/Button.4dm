//var $option : Object
//$option:=New object()

//$option[wk visible headers]:=True
//$option[wk visible footers]:=True
//$option[wk visible background]:=True
//$option[wk max picture DPI]:=96
//$option[wk optimized for]:=wk screen
//$option[wk recompute formulas]:=True
//WP EXPORT VARIABLE(WPArea; $pdf; wk pdf; $option)
WP EXPORT VARIABLE:C1319(WPArea; $blob; wk docx:K81:277)

WP EXPORT VARIABLE:C1319(WPArea; $text; wk mime html:K81:1)

$email:=MAIL Convert from MIME:C1681($text)

$email.from:="olivier.deschanels@orange.fr"
$email.to:="olivier.deschanels@orange.fr"
$email.subject:="Your appointment approach"

$email.attachments:=New collection:C1472(MAIL New attachment:C1644($blob; "text.docx"))

$email.textBody:=$text

$smtp:=New object:C1471
$smtp.host:="smtp.orange.fr"
$smtp.port:=465
$smtp.user:="olivier.deschanels"
$smtp.password:="i9r9zVgh8,p."
$smtpTransporter:=SMTP New transporter:C1608($smtp)



$status:=$smtpTransporter.send($email)
