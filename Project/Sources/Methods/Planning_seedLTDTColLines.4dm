//%attributes = {}
// Creates LT - DT3Col .. LT - DT6Col row lines and matching header lines in dfd_Line.

var $colCount : Integer
var $headerLine : cs:C1710.dfd_LineEntity
var $lineName : Text
var $okCount : Integer
var $res : Object
var $rowLine : cs:C1710.dfd_LineEntity

$okCount:=0

For ($colCount; 1; 6)
	$rowLine:=Planning_travLTDTColLine($colCount; False:C215)
	$res:=$rowLine.save()
	If ($res.success)
		$okCount:=$okCount+1
	End if 
	
	$headerLine:=Planning_travLTDTColLine($colCount; True:C214)
	$res:=$headerLine.save()
	If ($res.success)
		$okCount:=$okCount+1
	End if 
End for 

ALERT:C41(String:C10($okCount)+" LT data-table line(s) created or updated (DT3Col through DT6Col).")
