//%attributes = {}
// Lot Traveller print fixes (Oct 2026), safe to run again:
// - LT - Step: the QA stamp prints only on the steps QA signed off (it was a fixed picture, on
//   every step); the operator column fits a 6-digit badge (001730 printed as 00173)
// - LT - Header: the lot and job barcodes keep their proportions, so both have the same bar
//   width instead of each being stretched to its box
// - the serial-number section under SN steps: Planning_seedLTTravFix creates and wires it

var $headerLine : cs:C1710.dfd_LineEntity
var $object : Object
var $objectsForm : Object
var $res : Object
var $saved : Integer
var $stepLine : cs:C1710.dfd_LineEntity
var $variableItems : Object

$saved:=0

$stepLine:=ds:C1482.dfd_Line.query("name = :1"; "LT - Step").first()
If ($stepLine=Null:C1517)
	ALERT:C41("LT - Step line not found.")
	return
End if

$objectsForm:=$stepLine.objectsForm
For each ($object; $objectsForm.objects)
	Case of
		: (String:C10($object.properties.picture)="@GA08.png")  // the QA stamp
			$object.properties.visibility:="##this.qaSignoff##"
			$object.properties.top:=8
			$object.properties.left:=541
			$object.properties.width:=32
			$object.properties.height:=32
		: ($object.name="rectangle_9") || ($object.name="rectangle_15")  // operator boxes
			$object.properties.width:=37
		: ($object.name="text_8") || ($object.name="text_14")  // operator, "oper"
			$object.properties.width:=36
	End case
End for each
$stepLine.objectsForm:=$objectsForm

$variableItems:=$stepLine.variableItems
If ($variableItems.tags.query("tag = :1"; "this.qaSignoff").length=0)
	$variableItems.tags.push(New object:C1471("tag"; "this.qaSignoff"; "objects"; New collection:C1472("picture_1")))
End if
$stepLine.variableItems:=$variableItems

$res:=$stepLine.save()
If ($res.success)
	$saved:=$saved+1
End if

$headerLine:=ds:C1482.dfd_Line.query("name = :1"; "LT - Header").first()
If ($headerLine#Null:C1517)
	$objectsForm:=$headerLine.objectsForm
	For each ($object; $objectsForm.objects)
		If (String:C10($object.properties.dataSource)="##lotBarcode##") || (String:C10($object.properties.dataSource)="##jobBarcode##")
			$object.properties.pictureFormat:="proportionalTopLeft"
			$object.properties.width:=170
		End if
	End for each
	$headerLine.objectsForm:=$objectsForm
	$res:=$headerLine.save()
	If ($res.success)
		$saved:=$saved+1
	End if
End if

ALERT:C41(String:C10($saved)+" of 2 Lot Traveller lines updated (QA stamp, operator column, barcodes).\rThe serial-number section is wired next.")

Planning_seedLTTravFix
