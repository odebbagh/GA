//%attributes = {}
var $certification_es : cs:C1710.CertificationSelection
var $certification_e : cs:C1710.CertificationEntity


var $data : Collection:=[]
var $header; $separator_col; $separator_line : Text

$separator_col:=";"
$separator_line:=Char:C90(Carriage return:K15:38)+Char:C90(Line feed:K15:40)

$doc:=Select document:C905(System folder:C487(Desktop:K41:16)+"certifications_"+String:C10(Year of:C25(Current date:C33()))+".csv"; "csv"; "Certifications Export:"; File name entry:K24:17)

If (OK=1)
	$header:="Ref #"+$separator_col+\
		"Name"+$separator_col+\
		"Duration"+$separator_col+\
		"One Time"
	
	$data.push($header)
	
	$certification_es:=ds:C1482.Certification.all()
	
	For each ($certification_e; $certification_es)
		$line:=String:C10($certification_e.ref)+$separator_col+\
			$certification_e.name+$separator_col+\
			String:C10($certification_e.duration)+$separator_col+\
			String:C10($certification_e.oneTime)
		
		$data.push($line)
	End for each 
	
	TEXT TO DOCUMENT:C1237(Document; $data.join($separator_line))
	
	SHOW ON DISK:C922(Document)
End if 
