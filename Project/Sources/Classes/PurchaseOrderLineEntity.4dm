Class extends Entity

// The line's shipping address, rendered on a single line for the PO line items
// list. The address itself lives in the `address` object field: it is defaulted
// from the purchase order's shipping address when the line is created, and can
// then be edited per line.
Function get shippingAddress()->$shippingAddress : Text
	$shippingAddress:=Address_toSingleLine(This:C1470.address)