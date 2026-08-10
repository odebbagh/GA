Case of
	: (FORM Event:C1606.code=On Load:K2:1)
		OBJECT SET VISIBLE:C603(*; "sf_quotesSearch"; False:C215)

		// The quote line picker only makes sense when the PO has a related quote
		var $hasQuoteLines : Boolean
		$hasQuoteLines:=False:C215
		If (Form:C1466.quoteLines#Null:C1517)
			$hasQuoteLines:=(Form:C1466.quoteLines.length>0)
		End if
		OBJECT SET ENABLED:C1123(*; "Input8"; $hasQuoteLines)
		If (Not:C34($hasQuoteLines))
			Form:C1466.searchQuoteLine:=""
			// grey the value cell out so the field reads as unavailable
			OBJECT SET RGB COLORS:C628(*; "header_bkgd27"; 0x00D9D9D9; 0x00D9D9D9)
			OBJECT SET RGB COLORS:C628(*; "Input8"; 0x00909090; Background color none:K23:10)
		End if

		// Same for the Shipping Job picker: it lists the jobs attached to this PO
		var $hasPoJobs : Boolean
		$hasPoJobs:=False:C215
		If (Form:C1466.poJobs#Null:C1517)
			$hasPoJobs:=(Form:C1466.poJobs.length>0)
		End if
		OBJECT SET ENABLED:C1123(*; "Field_shipJob"; $hasPoJobs)
		If (Not:C34($hasPoJobs))
			OBJECT SET RGB COLORS:C628(*; "header_bkgd30"; 0x00D9D9D9; 0x00D9D9D9)
			OBJECT SET RGB COLORS:C628(*; "Field_shipJob"; 0x00909090; Background color none:K23:10)
		End if

		// Shipping address of the line: defaulted from the purchase order's shipping
		// address (deep copy, so editing the line never touches the PO record) and
		// editable from here through the address subform.
		var $address : Object

		$address:=Form:C1466.poLine.address
		If ($address=Null:C1517)
			$address:=New object:C1471()
		End if

		If ($address.detail=Null:C1517)
			// nothing stored on the line yet -> start from the PO shipping address
			If (Form:C1466.poShippingAddress#Null:C1517)
				$address:=OB Copy:C1225(Form:C1466.poShippingAddress)
			End if
			If ($address.detail=Null:C1517)
				$address.detail:=New object:C1471()
			End if
		End if

		$address.type:="shipping"
		Form:C1466.poLine.address:=$address

		// the subform edits Form.subFormAddress.address in place, and that is the very
		// object held by poLine.address, so the changes land on the line
		Form:C1466.subFormAddress:=New object:C1471(\
			"address"; Form:C1466.poLine.address; \
			"situation"; New object:C1471("mode"; "modify")\
			)
End case
