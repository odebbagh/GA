// Purpose: Staff picker (same people as _ga_staffsAsTeamMember). Single choice; returns fullName. OK=1 if a name was chosen.
// created by 4D/PS [2026-oct-02]
// Purpose: Use the short searchable selectNto1 listbox instead of a full-screen popup menu.
// modified by 4D/PS [2026-october-05]
#DECLARE($left : Integer; $bottom : Integer; $currentName : Text)->$fullName : Text

var $staffs : Collection
var $staff : cs:C1710.StaffEntity
var $form : Object
var $winRef : Integer
var $row : Object

$staffs:=New collection:C1472
For each ($staff; ds:C1482.Staff.all().orderBy("lastName, firstName"))
	$row:=New object:C1471("fullName"; $staff.fullName; "role"; String:C10($staff.role))
	$staffs.push($row)
End for each 

$form:=New object:C1471(\
	"colName"; "fullName"; \
	"lb_items"; $staffs; \
	"allData"; $staffs; \
	"dataclass"; "Staff"; \
	"words"; ""\
	)

$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $left; $bottom+1)
DIALOG:C40("selectNto1"; $form)
CLOSE WINDOW:C154($winRef)

If (OK=1) && ($form.item#Null:C1517)
	$fullName:=String:C10($form.item.fullName)
Else 
	$fullName:=$currentName
	OK:=0
End if 

/* var $menu : Text
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
End if */
