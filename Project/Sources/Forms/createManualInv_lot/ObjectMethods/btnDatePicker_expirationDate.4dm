Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		// the framework calendar under this button (ga_datePicker); the expiration date is a timestamp
		var $current : Date
		var $date : Date
		$current:=(Form:C1466.inventory_e.expirationDate=0) ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(Form:C1466.inventory_e.expirationDate)
		$date:=cs:C1710.ga_datePicker.me.pick($current; "btnDatePicker_expirationDate")
		If ($date#!00-00-00!)
			Form:C1466.inventory_e.expirationDate:=cs:C1710.sfw_stmp.me.build($date)
		End if 
End case 
