//%attributes = {}
// LotHoldForm_attachFolder -> the "Hold forms" document folder (ident holdForms), created the first
// time: where LotHoldForm_attach puts the printed GAF-1014 / GAF-1514. Shown on the Documents page
// of Planning only (moreData.allowedEntries); its name and its profiles can be changed in Document
// Management, the ident is what this method looks for.
#DECLARE()->$folder : 4D:C1709.Entity

var $result : Object

$folder:=ds:C1482.sfw_DocumentFolder.query("ident = :1"; "holdForms").first()
If ($folder#Null:C1517)
	return
End if

$folder:=ds:C1482.sfw_DocumentFolder.new()
$folder.UUID:=Generate UUID:C1066
$folder.ident:="holdForms"
$folder.name:="Hold forms"
$folder.UUID_ParentFolder:=""
$folder.moreData:=New object:C1471("allowedEntries"; New collection:C1472("planning"))
$result:=$folder.save()
If (Not:C34($result.success))
	$folder:=Null:C1517
End if
