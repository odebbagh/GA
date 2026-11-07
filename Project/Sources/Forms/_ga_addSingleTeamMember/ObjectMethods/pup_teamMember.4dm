
Form:C1466.role:=""
Form:C1466.fullName:=""

OBJECT GET COORDINATES:C663(*; "pup_teamMember"; $l; $t; $r; $b)
CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)

$col:=New collection:C1472()
For each ($staff; ds:C1482.Staff.all().orderBy("lastName, firstName"))
	$col.push(New object:C1471(\
		"fullName"; $staff.fullName; \
		"role"; String:C10($staff.role)\
		))
End for each 

$form:=New object:C1471(\
	"role"; "role"; \
	"fullName"; "fullName"; \
	"lb_items"; $col; \
	"allData"; $col; \
	"words"; ""; \
	"dataclass"; "Staff"\
	)

$winRef:=Open form window:C675("selectStaff_2"; Pop up form window:K39:11; $l; $b+1)
DIALOG:C40("selectStaff_2"; $form)
CLOSE WINDOW:C154($winRef)

If (OK=1) && ($form.item#Null:C1517)
	Form:C1466.role:=$form.item.role
	Form:C1466.fullName:=$form.item.fullName
End if 


OBJECT SET TITLE:C194(*; "pup_teamMember"; Form:C1466.fullName)


