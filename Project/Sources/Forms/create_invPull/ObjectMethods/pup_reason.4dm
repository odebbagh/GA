// Reason of a stock correction (the old app's adjustment list): ga_inventoryPulls.reasons
var $menu; $reason; $choice : Text
	
$menu:=Create menu:C408
For each ($reason; cs:C1710.ga_inventoryPulls.me.reasons())
	APPEND MENU ITEM:C411($menu; $reason)
	SET MENU ITEM PARAMETER:C1004($menu; -1; $reason)
	If ($reason=String:C10(Form:C1466.invPull.reason))
		SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
	End if 
End for each 
$choice:=Dynamic pop up menu:C1006($menu)
RELEASE MENU:C978($menu)
If ($choice#"")
	Form:C1466.invPull.reason:=$choice
	OBJECT SET TITLE:C194(*; OBJECT Get name:C1087(Object current:K67:2); $choice)  // pup_reason (pull) or pup_reason2 (put back)
End if 
