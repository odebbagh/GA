Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		$date:=cs:C1710.ga_datePicker.me.pick(Form:C1466.current_item.orderDate; OBJECT Get name:C1087(Object current:K67:2))  // the app's calendar
		
		If ($date#!00-00-00!)
			Form:C1466.current_item.orderDate:=$date
		End if 
End case 