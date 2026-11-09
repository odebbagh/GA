Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		// the framework calendar under this button (ga_datePicker); Cancel leaves the date as it is
		var $date : Date
		$date:=cs:C1710.ga_datePicker.me.pick(Form:C1466.inventory_e.dateIn; "btnDatePicker_dateIn")
		If ($date#!00-00-00!)
			Form:C1466.inventory_e.dateIn:=$date
		End if 
End case 
