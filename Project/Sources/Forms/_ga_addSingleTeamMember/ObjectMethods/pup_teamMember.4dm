
Form:C1466.role:=""
Form:C1466.fullName:=""

OBJECT GET COORDINATES:C663(*; "pup_teamMember"; $l; $t; $r; $b)
CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)

$form:=New object:C1471(\
"role"; "role"; \
"fullName"; "fullName"; \
"lb_items"; ds:C1482.Staff.all(); \
"allData"; ds:C1482.Staff.all(); \
"dataclass"; "Staff"\
)

$winRef:=Open form window:C675("selectStaff_2"; Pop up form window:K39:11; $l; $b+1)
DIALOG:C40("selectStaff_2"; $form)
CLOSE WINDOW:C154($winRef)

If (ok=1)
	Form:C1466.role:=$form.item.role
	Form:C1466.fullName:=$form.item.fullName  //Storage.cache.staffs.query("UUID = :1"; $form.item.UUID).first().fullName
	
End if 


OBJECT SET TITLE:C194(*; "pup_teamMember"; Form:C1466.fullName)


