//%attributes = {}
#DECLARE($signal : 4D:C1709.Signal)

var $ref : Integer

HIDE PROCESS:C324(Current process:C322)
$ref:=Open form window:C675("dfd_textCalculator")
Use (Storage:C1525)
	Storage:C1525.textCalculator:=New shared object:C1526("window"; $ref)
End use 
If (Count parameters:C259>0)
	$signal.trigger()
End if 
DIALOG:C40("dfd_textCalculator")
CLOSE WINDOW:C154($ref)
Use (Storage:C1525)
	Storage:C1525.textCalculator:=New shared object:C1526("window"; 0)
End use 