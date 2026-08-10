// Quantity Ordered changed -> recompute Amount Paid = Quantity x Unit Price
// (auto-filled; the Amount Paid field stays editable so it can be overridden)
If (FORM Event:C1606.code=On Data Change:K2:11)
	Form:C1466.details.amountPaid:=Num:C11(Form:C1466.details.qty)*Num:C11(Form:C1466.details.unitPrice)
End if
