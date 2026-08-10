var $start; $end : Integer
var $refMenu : Text

$refMenu:=Create menu:C408

APPEND MENU ITEM:C411($refMenu; "Condition Si")
SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--branch1")

APPEND MENU ITEM:C411($refMenu; "Cas")
SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--branch2")

$choose:=Dynamic pop up menu:C1006($refMenu)
RELEASE MENU:C978($refMenu)

$toInsert:=""
Case of 
	: ($choose="--branch1")
		$toInsert:="\r\rIf($condition)\r\rElse\r\rEnd if\r"
		
	: ($choose="--branch2")
		$toInsert:="\r\rCase of\r\t:($cas1)\r\r\t:($cas2)\r\r\tElse\r\rEnd case\r"
		
End case 

If ($toInsert#"")
	GET HIGHLIGHT:C209(*; "inputMethod"; $start; $end)
	If ($start>1)
		Form:C1466.method:=Substring:C12(Form:C1466.method; 1; $start-1)+$toInsert+Substring:C12(Form:C1466.method; $end)
		HIGHLIGHT TEXT:C210(*; "inputMethod"; $start; $start+Length:C16($toInsert))
	Else 
		Form:C1466.method:=$toInsert+Form:C1466.method
	End if 
End if 
