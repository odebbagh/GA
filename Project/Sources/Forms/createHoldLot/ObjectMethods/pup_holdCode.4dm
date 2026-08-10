//%attributes = {}

var $menuRef : Integer
var $codes : 4D:C1709.EntitySelection
var $code : 4D:C1709.Entity
var $choice : Text
var $selected : 4D:C1709.EntitySelection

$menuRef:=Create menu:C408
$codes:=ds:C1482.HoldCode.all().orderBy("Code asc")
For each ($code; $codes)
	APPEND MENU ITEM:C411($menuRef; $code.Code)
	SET MENU ITEM PARAMETER:C1004($menuRef; -1; String:C10($code.UUID))
End for each 

$choice:=Dynamic pop up menu:C1006($menuRef)
If ($choice#"")
	$selected:=ds:C1482.HoldCode.query("UUID = :1"; $choice)
	If ($selected.length>0)
		Form:C1466.holdCode:=$selected[0]
		Form:C1466.holdCodeDisplay:=Form:C1466.holdCode.Code
	End if 
End if 
