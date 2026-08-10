//%attributes = {}


var $template : Object
var $context : Object:=New object:C1471()
var $eSupplier : cs:C1710.SupplierEntity
var $eContact : cs:C1710.ContactEntity

$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/auditReportPrint.4wp")
$template:=WP Import document:C1318($file.platformPath)

$eSupplier:=Form:C1466.current_item.supplier

If ($eSupplier#Null:C1517)
	
	$eSupplierAdress:=$eSupplier.contactDetails.addresses.query("type =:1"; "main").first()
	$eContact:=ds:C1482.Contact.query("UUID_Company =:1 & title =:2"; $eSupplier.UUID; "Primary").first()
	
	$context.company:=$eSupplier#Null:C1517 ? $eSupplier.name : ""
	$context.address:=$eSupplierAdress
	If ($eContact#Null:C1517)
		$context.contact:=$eContact.fullName
		$eContactEmail:=$eContact.contactDetails.communications.query("type =:1"; "email")
		If ($eContactEmail.length>0)
			$context.emailAddress:=$eContactEmail[0].contact
		End if 
		
	End if 
	
Else 
	
	$section:=WP Get section:C1581($template; 2)
	$range:=WP Text range:C1341($template; $section.start; $section.end)
	WP SET TEXT:C1574($range; Char:C90(Carriage return:K15:38); wk replace:K81:177)
	
End if 

$context.item:=Form:C1466.current_item
$context.user:=Current machine:C483

SET PRINT OPTION:C733(Orientation option:K47:2; 1)

WP SET DATA CONTEXT:C1786($template; $context)

WP COMPUTE FORMULAS:C1707($template)
WP FREEZE FORMULAS:C1708($template; wk do not recompute expressions:K81:312)

Form:C1466.current_item.auditReport:=$template
