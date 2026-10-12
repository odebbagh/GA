Class extends Entity


Function get amount()->$amount : Real
	// an amount typed in rather than quantity x unit price (legacy lines with a minimum lot charge,
	// quantity 0...) is kept in moreData.amount by __import_data_quote and wins over the product
	If (This:C1470.moreData#Null:C1517) && (This:C1470.moreData.amount#Null:C1517)
		$amount:=Num:C11(This:C1470.moreData.amount)
	Else
		$amount:=This:C1470.unitPrice*This:C1470.quantity
	End if