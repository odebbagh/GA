var $qty : Integer

Case of
	: (Form event code:C388=On Clicked)
		$qty:=Num:C11(Form:C1466.quantity)

		If (Bool:C1537(Form:C1466.serialized))
			$qty:=Form:C1466.snItems.query("selected = :1"; True:C214).length
			Form:C1466.quantity:=$qty
		End if

		Case of
			: ($qty<=0)
				If (Bool:C1537(Form:C1466.serialized))
					cs:C1710.sfw_dialog.me.alert("Select at least one serial number to move into the sublot.")
				Else
					cs:C1710.sfw_dialog.me.alert("Enter a quantity greater than zero.")
				End if
			: ($qty>=Num:C11(Form:C1466.availableQty))
				cs:C1710.sfw_dialog.me.alert("The sublot must take fewer than the available quantity ("+String:C10(Form:C1466.availableQty)+") - the rest stays in the mother lot.")
			Else
				ACCEPT:C269
		End case
End case
