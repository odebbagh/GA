
// Purpose: Search must tolerate a Null source (missing import data).
// modified by 4D/PS [2026-october-05]
Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		
		If (Form:C1466.allData=Null:C1517)
			Form:C1466.lb_items:=New collection:C1472()
		Else 
			If (Form:C1466.words#"")
				Form:C1466.lb_items:=Form:C1466.allData.query(Form:C1466.colName+" == :1"; "@"+Form:C1466.words+"@")
			Else 
				Form:C1466.lb_items:=Form:C1466.allData
			End if 
		End if 
		
End case 
