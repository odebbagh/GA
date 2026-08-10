//%attributes = {}
var $staff_es : cs:C1710.StaffSelection
var $staff_e : cs:C1710.StaffEntity


var $data : Collection:=[]
var $header; $separator_col; $separator_line : Text

$separator_col:=";"
$separator_line:=Char:C90(Carriage return:K15:38)

$doc:=Select document:C905(System folder:C487(Desktop:K41:16)+"staff_"+String:C10(Year of:C25(Current date:C33()))+".csv"; "csv"; "Staff Export:"; File name entry:K24:17)

If (OK=1)
	$header:="First Name"+$separator_col+"Last Name"+$separator_col+"Employee Code"+$separator_col+"Hire Date"+$separator_col+"Terminated"+$separator_col+"Terminated Date"
	
	$data.push($header)
	
	$staff_es:=Form:C1466.sfw.lb_items
	
	For each ($staff_e; $staff_es)
		$line:=$staff_e.firstName+$separator_col+\
			$staff_e.lastName+$separator_col+\
			$staff_e.code+$separator_col+\
			String:C10($staff_e.hireDate; Internal date short:K1:7)+$separator_col+\
			String:C10($staff_e.terminated)+$separator_col+\
			String:C10($staff_e.terminationDate; Internal date short:K1:7)
		
		$data.push($line)
	End for each 
	
	TEXT TO DOCUMENT:C1237(Document; $data.join($separator_line))
	
	SHOW ON DISK:C922(Document)
End if 
