Case of 
		
	: (Form event code:C388=On Load:K2:1)
		Form:C1466.lb_items:=Form:C1466.allData
		If (Not:C34(Undefined:C82(Form:C1466.initialUUID)) & (Form:C1466.initialUUID#Null:C1517))
			If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.initialUUID)=False:C215)
				Form:C1466.item:=Form:C1466.allData.query("UUID = :1"; Form:C1466.initialUUID).first()
			End if 
		End if 
		
	Else 
		
		
End case 
