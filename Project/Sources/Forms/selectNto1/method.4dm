Case of 
		
	: (Form event code:C388=On Load:K2:1)
		// Purpose: Empty or Null source must not leave lb_items undefined.
		// modified by 4D/PS [2026-october-05]
		If (Form:C1466.allData=Null:C1517)
			Form:C1466.allData:=New collection:C1472()
		End if 
		Form:C1466.lb_items:=Form:C1466.allData
		
	Else 
		
		
End case 
