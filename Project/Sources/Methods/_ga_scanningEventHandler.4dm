//%attributes = {}

var $asciiCode : Integer
var $char : Text

$asciiCode:=KeyCode

Use (Storage:C1525.scanner)
	If ($asciiCode#0)
		$char:=Char:C90($asciiCode)
		
		If (Storage:C1525.scanner.scanBuffer="")
			Storage:C1525.scanner.scanStartTime:=Milliseconds:C459
			
		End if 
		
		If ($asciiCode=Character code:C91("\n")) | ($asciiCode=Character code:C91("\r"))
			$duree:=Milliseconds:C459-Storage:C1525.scanner.scanStartTime
			Storage:C1525.scanner.scanStartTime:=Milliseconds:C459
			If (Length:C16(Storage:C1525.scanner.scanBuffer)>8) & ($duree<500)
				CALL FORM:C1391(Storage:C1525.scanner.currentWindow; "_ga_closeWindow")
			Else 
				Storage:C1525.scanner.scanBuffer:=""
			End if 
			
		Else 
			
			If ($asciiCode>=32)
				
				Storage:C1525.scanner.scanBuffer:=Storage:C1525.scanner.scanBuffer+$char
				
			End if 
		End if 
		
	End if 
	
End use 


