Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		
		$numTBIcon:=Num:C11(Substring:C12(Form:C1466.tb_currentObjectName; 10))
		$entry:=Form:C1466.entries[$numTBIcon-1]
		Form:C1466.pupTB_entryName:=$entry.label
		
End case 