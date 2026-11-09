// the staff with the Sales profile (Staff.salesPeople; the team named "Sales" it looked for does not exist)
var $staff : Object
var $menu; $choice : Text

$menu:=Create menu:C408
For each ($staff; ds:C1482.Staff.salesPeople())
	APPEND MENU ITEM:C411($menu; $staff.fullName; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; $staff.UUID)  // the UUID alone: "UUID-name" split on "-" cut names with a "-"
	If ($staff.UUID=String:C10(Form:C1466.UUID_Staff))
		SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		If (Is Windows:C1573)
			SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
		End if 
	End if 
End for each 
$choice:=Dynamic pop up menu:C1006($menu)
RELEASE MENU:C978($menu)

If ($choice#"")
	Form:C1466.UUID_Staff:=$choice
	OBJECT SET TITLE:C194(*; "pup_sales"; String:C10(ds:C1482.Staff.get($choice).fullName))
End if
