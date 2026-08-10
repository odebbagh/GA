//%attributes = {}
#DECLARE($lot : 4D:C1709.Entity)

var $data : Object
var $doc : cs:C1710.dfd_DocumentEntity
var $invalidChar : Text
var $invalidChars : Collection
var $lotNumber : Text
var $opts : Object
var $path : Text
var $docRef : Time
var $pdfName : Text
var $safeLotId : Text
var $steps : cs:C1710.LotStepSelection
var $template : cs:C1710.dfd_TemplateEntity
var $templateName : Text

$templateName:="Lot Traveller"

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
	cs:C1710.sfw_dialog.me.alert("Template not found: "+$templateName+".")
	return 
End if 

//$data:=Planning_buildLotTravData($lot)
$data:=Planning_fillLotTravData($lot)

If ($data=Null:C1517)
	return 
End if 

//$safeLotId:=$lotNumber
//$invalidChars:=New collection("\\"; "/"; ":"; "*"; "?"; "\""; "<"; ">"; "|")
//For each ($invalidChar; $invalidChars)
//$safeLotId:=Replace string($safeLotId; $invalidChar; "-")
//End for each 

//$safeLotId:=Replace string($safeLotId; Char(13); " ")
//$safeLotId:=Replace string($safeLotId; Char(10); " ")
//$safeLotId:=Replace string($safeLotId; Char(9); " ")
//If ($safeLotId="")
//$safeLotId:="unknown"
//End if 

$pdfName:=$lotNumber+"_LotTraveller.pdf"
$path:=System folder:C487(Desktop:K41:16)+$pdfName
$docRef:=Create document:C266($path)
CLOSE DOCUMENT:C267($docRef)

$opts:=New object:C1471("pdfPath"; $path; "printPreview"; False:C215)

$doc:=ds:C1482.dfd_Document.buildFromTemplate("Lot Traveller "+$lotNumber; $template; $data; "pdf"; $opts)

If ($doc#Null:C1517)
	cs:C1710.sfw_dialog.me.alert("Lot traveller exported successfully.")
	OPEN URL:C673($path)
Else 
	cs:C1710.sfw_dialog.me.alert("Failed to generate lot traveller PDF.")
End if 
