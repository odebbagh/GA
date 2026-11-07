//%attributes = {}
var $certification_e : cs:C1710.CertificationEntity
var $certification_es : cs:C1710.CertificationSelection

var $file : 4D:C1709.File
var $data; $line_col : Collection
var $header; $line; $separator_col; $separator_line : Text
var $imported : Integer

$separator_col:=";"
$separator_line:=Char:C90(Carriage return:K15:38)+Char:C90(Line feed:K15:40)

$doc:=Select document:C905(""; "csv"; "Choose file: :"; Allow alias files:K24:10)

If (OK=1)
	$file:=File:C1566(Document; fk platform path:K87:2)
	
	$data:=Split string:C1554($file.getText(); $separator_line)
	If ($data.length>0)
		$header:=$data.shift()
	End if 
	
	$imported:=0
	For each ($line; $data)
		If ($line="")
			continue
		End if 
		$line_col:=Split string:C1554($line; $separator_col)
		If ($line_col.length<2)
			continue
		End if 
		
		$certification_es:=ds:C1482.Certification.query("ref = :1"; Num:C11($line_col[0]))
		
		If ($certification_es.length=0)
			$certification_e:=ds:C1482.Certification.new()
		Else 
			$certification_e:=$certification_es[0]
		End if 
		
		$certification_e.ref:=Num:C11($line_col[0])
		$certification_e.name:=$line_col[1]
		If ($line_col.length>3)
			$certification_e.oneTime:=(Lowercase:C14(String:C10($line_col[3]))="true")
		End if 
		// Purpose: CSV import — duration 0 becomes 365 unless one-time certification.
		// modified by 4D/PS [2026-june-08]
		$certification_e.duration:=_ga_certificationImportDuration(Num:C11($line_col[2]); $certification_e.oneTime)
		If ($line_col.length>6)
			$certification_e.retrainQuarterly:=(Lowercase:C14(String:C10($line_col[4]))="true")
			$certification_e.retrainHalfYear:=(Lowercase:C14(String:C10($line_col[5]))="true")
			$certification_e.retrainAnnually:=(Lowercase:C14(String:C10($line_col[6]))="true")
		End if 
		If ($certification_e.oneTime)
			$certification_e.retrainQuarterly:=False:C215
			$certification_e.retrainHalfYear:=False:C215
			$certification_e.retrainAnnually:=False:C215
		End if 
		
		$res:=$certification_e.save()
		
		If (Not:C34($res.success))
			ALERT:C41($res.statusText)
		Else 
			$imported:=$imported+1
		End if 
	End for each 
	
	// Purpose: Correct catalog rows left with duration 0 from earlier CSV imports.
	// modified by 4D/PS [2026-june-08]
	_ga_certFixZeroDuration()
	cs:C1710.sfw_dialog.me.alert("Import Done !\r"+String:C10($imported)+" certification(s).")
End if 
