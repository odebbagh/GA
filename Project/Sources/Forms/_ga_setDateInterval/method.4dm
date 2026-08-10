

Case of 
		
		
	: (Form event code:C388=On Load:K2:1)
		var formData : Object
		formData:=New object:C1471()
		formData.startDate:=Form:C1466.startDate
		formData.endDate:=Form:C1466.endDate
		formData.interval:=Form:C1466.interval
		
		OBJECT SET TITLE:C194(*; "pup_startDate"; String:C10(Form:C1466.startDate))
		
		OBJECT SET TITLE:C194(*; "pup_endDate"; String:C10(Form:C1466.endDate))
		
		
End case 