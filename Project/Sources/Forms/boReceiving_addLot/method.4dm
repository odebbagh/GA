Case of
	: (Form event code:C388=On Load:K2:1)
		GOTO OBJECT:C206(*; "inputLotNumber")

	: (Form event code:C388=On Validate:K2:27)
		If (Length:C16(Form:C1466.inventory_e.partLotNumber)=0)
			cs:C1710.sfw_dialog.me.alert("Please enter a Vendor Lot #.")
			CANCEL:C270
		Else
			If (Num:C11(Form:C1466.inventory_e.qtyInStock)<=0)
				cs:C1710.sfw_dialog.me.alert("Please enter a Qty greater than zero.")
				CANCEL:C270
			End if
		End if
End case
