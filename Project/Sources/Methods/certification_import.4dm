//%attributes = {}
var $certification_e : cs:C1710.CertificationEntity
var $certification_es : cs:C1710.CertificationSelection

var $file : 4D:C1709.File
var $data; $line_col : Collection
var $header; $line; $separator_col; $separator_line : Text

$separator_col:=";"
$separator_line:=Char:C90(Carriage return:K15:38)+Char:C90(Line feed:K15:40)

$doc:=Select document:C905(""; "csv"; "Choose file: :"; Allow alias files:K24:10)

//$header:="Ref #;Name;Duration;One Time"

If (OK=1)
	$file:=File:C1566(Document; fk platform path:K87:2)
	
	$data:=Split string:C1554($file.getText(); $separator_line)
	
	$header:=$data.shift()
	
	For each ($line; $data)
		$line_col:=Split string:C1554($line; $separator_col)
		
		$certification_es:=ds:C1482.Certification.query("ref = :1"; Num:C11($line_col[0]))
		
		If ($certification_es.length=0)
			$certification_e:=ds:C1482.Certification.new()
		Else 
			$certification_e:=$certification_es[0]
		End if 
		
		$certification_e.ref:=Num:C11($line_col[0])
		$certification_e.name:=$line_col[1]
		$certification_e.duration:=Num:C11($line_col[2])
		$certification_e.oneTime:=($line_col[3]="true" ? True:C214 : False:C215)
		
		$res:=$certification_e.save()
		
		If (Not:C34($res.success))
			ALERT:C41($res.statusText)
		End if 
	End for each 
End if 

cs:C1710.sfw_dialog.me.alert("Import Done !")
