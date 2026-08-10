//%attributes = {}
var $staff_es : cs:C1710.StaffSelection
var $staff_e : cs:C1710.StaffEntity
var $assignment_es : cs:C1710.CertificationAssignmentSelection
var $assignment_e : cs:C1710.CertificationAssignmentEntity

var $data : Collection:=[]
var $header; $separator_col; $separator_line : Text

$separator_col:=";"
$separator_line:=Char:C90(Carriage return:K15:38)

$doc:=Select document:C905(System folder:C487(Desktop:K41:16)+"staff_certifications_"+String:C10(Year of:C25(Current date:C33()))+".csv"; "csv"; "Certification Export:"; File name entry:K24:17)

If (OK=1)
	$header:="First Name"+$separator_col+"Last Name"+$separator_col+"Employee Code"+$separator_col+"Certification"+$separator_col+"Due Date"
	
	$data.push($header)
	
	$staff_es:=ds:C1482.Staff.all()
	
	For each ($staff_e; $staff_es)
		$assignment_es:=$staff_e.assignments.query(\
			"certificationDate >= :1 AND certificationDate <= :2"; \
			cs:C1710.sfw_stmp.me.build(Add to date:C393(!00-00-00!; Year of:C25(Current date:C33); 1; 1)); \
			cs:C1710.sfw_stmp.me.build(Add to date:C393(!00-00-00!; Year of:C25(Current date:C33); 12; 31))\
			)
		
		For each ($assignment_e; $assignment_es)
			$line:=$staff_e.firstName+$separator_col+\
				$staff_e.lastName+$separator_col+\
				$staff_e.code+$separator_col+\
				$assignment_e.certification.name+$separator_col+\
				String:C10(Add to date:C393(cs:C1710.sfw_stmp.me.getDate($assignment_e.expiredIn); 0; 0; 1); Internal date short:K1:7)
			
			$data.push($line)
		End for each 
		
	End for each 
	
	TEXT TO DOCUMENT:C1237(Document; $data.join($separator_line))
	
	SHOW ON DISK:C922(Document)
End if 
