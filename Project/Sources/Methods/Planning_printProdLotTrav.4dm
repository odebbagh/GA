//%attributes = {}
#DECLARE($lot : 4D:C1709.Entity)

var $data : Object
var $doc : cs:C1710.dfd_DocumentEntity
var $lotNumber : Text
var $opts : Object
var $path : Text
var $docRef : Time
var $pdfName : Text
var $steps : cs:C1710.LotStepSelection
var $template : cs:C1710.dfd_TemplateEntity
var $templateName : Text

$templateName:="Production Lot Traveller"

If ($lot=Null:C1517)
	return 
End if 

$lotNumber:=String:C10($lot.number)

$steps:=ds:C1482.LotStep.query("UUID_Lot = :1"; $lot.UUID).orderBy("order asc")
If ($steps.length=0)
	cs:C1710.sfw_dialog.me.alert("No steps found for this lot.")
	return 
End if 

$template:=ds:C1482.dfd_Template.query("name = :1"; $templateName).first()
If ($template=Null:C1517)
	cs:C1710.sfw_dialog.me.alert("Template not found: "+$templateName+". Run Planning_seedPLTTemplate first.")
	return 
End if 

$data:=Planning_fillProdLotTrav($lot)
If ($data=Null:C1517)
	return 
End if 

$pdfName:=$lotNumber+"_ProductionLotTraveller.pdf"
$path:=System folder:C487(Desktop:K41:16)+$pdfName
$docRef:=Create document:C266($path)
CLOSE DOCUMENT:C267($docRef)

$opts:=New object:C1471("pdfPath"; $path; "printPreview"; False:C215)
$doc:=ds:C1482.dfd_Document.buildFromTemplate("Production Lot Traveller "+$lotNumber; $template; $data; "pdf"; $opts)

If ($doc#Null:C1517)
	cs:C1710.sfw_dialog.me.alert("Production lot traveller exported successfully.")
	OPEN URL:C673($path)
Else 
	cs:C1710.sfw_dialog.me.alert("Failed to generate production lot traveller PDF.")
End if 
