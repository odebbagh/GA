//%attributes = {}
var $staff_es : cs:C1710.StaffSelection
var $staff_e : cs:C1710.StaffEntity
var $assignment_es : cs:C1710.CertificationAssignmentSelection
var $assignment_e : cs:C1710.CertificationAssignmentEntity

var $count : Integer

$staff_es:=ds:C1482.Staff.all()

PRINT SETTINGS:C106()

OPEN PRINTING JOB:C995

Print form:C5([Staff:135]; "staff_certifications"; Form header:K43:3)

$count:=0

For each ($staff_e; $staff_es)
	$assignment_es:=$staff_e.assignments.query(\
		"certificationDate >= :1 AND certificationDate <= :2"; \
		cs:C1710.sfw_stmp.me.build(Add to date:C393(!00-00-00!; Year of:C25(Current date:C33); 1; 1)); \
		cs:C1710.sfw_stmp.me.build(Add to date:C393(!00-00-00!; Year of:C25(Current date:C33); 12; 31))\
		)
	
	$first:=True:C214
	
	If ($assignment_es.length>0)
		$count:=$count+1
	End if 
	
	For each ($assignment_e; $assignment_es)
		$form:=New object:C1471("employee"; New object:C1471("code"; ""; "firstName"; ""; "lastName"; ""))
		If ($first)
			$form.employee.count:=$count
			$form.employee.code:=$staff_e.code
			$form.employee.firstName:=$staff_e.firstName
			$form.employee.lastName:=$staff_e.lastName
			
			$first:=False:C215
		End if 
		
		
		$form.employee.certificationName:=$assignment_e.certification.name
		$form.employee.certExpitedIn:=String:C10(Add to date:C393(cs:C1710.sfw_stmp.me.getDate($assignment_e.expiredIn); 0; 0; 1); Internal date short:K1:7)
		
		Print form:C5([Staff:135]; "staff_certifications"; $form; Form detail:K43:1)
		
	End for each 
	
End for each 
$form:=New object:C1471(\
"printedBy"; cs:C1710.sfw_userManager.me.info.name; \
"printedDate"; String:C10(Current date:C33(); Internal date short:K1:7)\
)

Print form:C5([Staff:135]; "staff_certifications"; $form; Form footer:K43:2)

CLOSE PRINTING JOB:C996
