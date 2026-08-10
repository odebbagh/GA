//%attributes = {}
var $lead_es : cs:C1710.LeadSelection
var $lead_e : cs:C1710.LeadEntity


var $data : Collection:=[]
var $header; $separator_col; $separator_line : Text

$separator_col:=";"
$separator_line:=Char:C90(Carriage return:K15:38)

$doc:=Select document:C905(System folder:C487(Desktop:K41:16)+"lead_"+String:C10(Year of:C25(Current date:C33()))+".csv"; "csv"; "Lead Export:"; File name entry:K24:17)

If (OK=1)
	$header:="Lead ID"+$separator_col+"Customer"+$separator_col+"Owner"+$separator_col+"stage"+$separator_col+"Amount"  //+$separator_col+"Terminated Date"
	
	$data.push($header)
	
	$lead_es:=Form:C1466.sfw.lb_items
	
	For each ($lead_e; $lead_es)
		$line:=$lead_e.leadCode+$separator_col+\
			$lead_e.customerName+$separator_col+\
			$lead_e.staff.fullName+$separator_col+\
			$lead_e.stage+$separator_col+\
			String:C10($lead_e.amount)
		
		$data.push($line)
	End for each 
	
	TEXT TO DOCUMENT:C1237(Document; $data.join($separator_line))
	
	SHOW ON DISK:C922(Document)
End if 