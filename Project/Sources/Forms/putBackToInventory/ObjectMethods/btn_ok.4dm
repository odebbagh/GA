Case of 
	: (Form event code:C388=On Clicked:K2:4)
		If (Form:C1466.selectedInventory=Null:C1517)
			cs:C1710.sfw_dialog.me.alert("Please select an inventory record.")
		Else If (Form:C1466.qtyToPutBack<=0)
			cs:C1710.sfw_dialog.me.alert("Please enter a quantity greater than zero.")
		Else If (Form:C1466.qtyToPutBack>Form:C1466.maxQty)
			cs:C1710.sfw_dialog.me.alert("Quantity cannot exceed pulled quantity not yet returned.")
		Else If (String:C10(Form:C1466.performedBy)="")
			cs:C1710.sfw_dialog.me.alert("Please identify who performed the put back.")
		Else 
			ACCEPT:C269
		End if 
End case 
