

Case of 
		
	: (Form event code:C388=On Load:K2:1)
		// Form. is the datasource of the form object
		Form:C1466.bin:=New object:C1471
		Form:C1466.bin.values:=New collection:C1472(1; \
			2; 3; 4; 5; 6; \
			7; 8; 9; 10; 11; \
			12; 13; 14; 15; 16; \
			17; 18; 19; 20; 21; \
			22; 23; 24; 25; 26; \
			27; 28; 29; 30; 31; 32)
		
		
		Form:C1466.binType:=New object:C1471
		Form:C1466.binType.values:=New collection:C1472("Not Used"; "Good"; "Rejects"; "Mechanical Rejects"; "Missing or Excluded")
		
		If (Form:C1466.binDefinition.action="add")
			
			Form:C1466.bin.index:=-1
			Form:C1466.bin.currentValue:="Select a bin Number"
			
			Form:C1466.binType.index:=-1
			Form:C1466.binType.currentValue:="Select a bin Type"
			
			//Form.binDefinition.definition:=""
			OBJECT SET ENABLED:C1123(*; "pup_bin"; True:C214)
			
		Else 
			
			Form:C1466.bin.index:=Form:C1466.bin.values.indexOf(Form:C1466.binDefinition.num)
			Form:C1466.binType.index:=Form:C1466.binType.values.indexOf(Form:C1466.binDefinition.type)
			
			Form:C1466.bin.currentValue:=Form:C1466.binDefinition.num
			Form:C1466.binType.currentValue:=Form:C1466.binDefinition.type
			
			OBJECT SET ENABLED:C1123(*; "pup_bin"; False:C215)
			
		End if 
		
End case 