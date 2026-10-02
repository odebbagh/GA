// Purpose: Staff dropdown (same people as _ga_staffsAsTeamMember). Single choice; returns fullName. OK=1 if a name was chosen.
// created by 4D/PS [2026-oct-02]
#DECLARE($left : Integer; $bottom : Integer; $currentName : Text)->$fullName : Text

var $menu : Text
var $staff : cs:C1710.StaffEntity
var $label; $choose : Text

$menu:=Create menu:C408
For each ($staff; ds:C1482.Staff.all().orderBy("lastName, firstName"))
	$label:=$staff.fullName
	If (String:C10($staff.role)#"")
		$label:=$label+" — "+String:C10($staff.role)
	End if 
	APPEND MENU ITEM:C411($menu; $label; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; $staff.fullName)
	If ($staff.fullName=$currentName)
		SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
	End if 
End for each 

$choose:=Dynamic pop up menu:C1006($menu; $currentName; $left; $bottom)
RELEASE MENU:C978($menu)

If ($choose="")
	$fullName:=$currentName
	OK:=0
Else 
	$fullName:=$choose
	OK:=1
End if 
