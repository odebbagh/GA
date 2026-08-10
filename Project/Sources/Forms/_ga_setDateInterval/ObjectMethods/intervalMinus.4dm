

Case of 
		
	: (Form event code:C388=On Clicked:K2:4)
		
		If (Num:C11(Form:C1466.interval)>0)
			Form:C1466.interval:=String:C10(Num:C11(Form:C1466.interval)-1)
			$date:=Date:C102(OBJECT Get title:C1068(*; "pup_startDate"))+Num:C11(Form:C1466.interval)
			OBJECT SET TITLE:C194(*; "pup_endDate"; String:C10($date))
			Form:C1466.endDate:=$date
		End if 
		
End case 
