//%attributes = {}
var $staff_es : cs:C1710.StaffSelection
var $staff_e : cs:C1710.StaffEntity
var $count : Integer

$staff_es:=Form:C1466.sfw.lb_items

PRINT SETTINGS:C106()

OPEN PRINTING JOB:C995

Print form:C5([Staff:135]; "print_list"; Form header:K43:3)

$count:=1

For each ($staff_e; $staff_es)
	$form:=New object:C1471("employee"; New object:C1471(\
		"count"; $count; \
		"code"; $staff_e.code; \
		"firstName"; $staff_e.firstName; \
		"lastName"; $staff_e.lastName; \
		"department"; $staff_e.department; \
		"hireDate"; String:C10($staff_e.hireDate; Internal date short:K1:7); \
		"terminated"; $staff_e.terminated; \
		"terminationDate"; String:C10($staff_e.terminationDate; Internal date short:K1:7)\
		))
	
	Print form:C5([Staff:135]; "print_list"; $form; Form detail:K43:1)
	
	$count:=$count+1
End for each 

$form:=New object:C1471(\
"printedBy"; cs:C1710.sfw_userManager.me.info.name; \
"printedDate"; String:C10(Current date:C33(); Internal date short:K1:7)\
)

Print form:C5([Staff:135]; "print_list"; $form; Form footer:K43:2)

CLOSE PRINTING JOB:C996


//If (OK=1)
//OPEN PRINTING JOB

//FORM SET OUTPUT([Staff]; "print_list")
//PRINT SELECTION([Staff])

//CLOSE PRINTING JOB
//End if 