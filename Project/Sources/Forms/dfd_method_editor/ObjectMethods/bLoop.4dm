var $start; $end : Integer
var $refMenu : Text

$refMenu:=Create menu:C408

APPEND MENU ITEM:C411($refMenu; "Boucle classique")
SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--loop1")

APPEND MENU ITEM:C411($refMenu; "Boucle pour chaque")
SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--loop2")

APPEND MENU ITEM:C411($refMenu; "Boucle repeter")
SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--loop3")

APPEND MENU ITEM:C411($refMenu; "Boucle jusque")
SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--loop4")

$choose:=Dynamic pop up menu:C1006($refMenu)
RELEASE MENU:C978($refMenu)

$toInsert:=""
Case of 
	: ($choose="--loop1")
		$toInsert:="\r\rFor($i;1;10;1)\r\rEnd for\r\r"
		
	: ($choose="--loop2")
		$toInsert:="\r\rFor each($item;$collection)\r\rEnd for each\r\r"
		
	: ($choose="--loop3")
		$toInsert:="\r\rWhile($condition)\r\rEnd while\r\r"
		
	: ($choose="--loop4")
		$toInsert:="\r\rRepeat\r\rUntil($condition)\r\r"
		
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

