// the app's calendar (ga_datePicker), opened under this button
If (FORM Event:C1606.code=On Clicked:K2:4)
	cs:C1710.ga_datePicker.me.pickInto(Form:C1466.current_item; "dateOut")
End if 
