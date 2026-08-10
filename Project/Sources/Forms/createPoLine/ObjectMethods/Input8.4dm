Case of
	: (FORM Event:C1606.code=On Clicked:K2:4)
		// no related quote on the PO -> nothing to pick from
		If (Form:C1466.quoteLines=Null:C1517)
			return
		End if
		If (Form:C1466.quoteLines.length=0)
			return
		End if

		Form:C1466.sf_quotesSearch:=New object:C1471(\
			"colName"; "description"; \
			"lb_values"; Form:C1466.quoteLines\
			)
		
		OBJECT SET SUBFORM:C1138(*; "sf_quotesSearch"; "searchOnList")
		OBJECT SET VISIBLE:C603(*; "sf_quotesSearch"; True:C214)
		
	: (FORM Event:C1606.code=On Mouse Enter:K2:33)
		// no hand cursor when the picker is disabled (PO without a related quote)
		SET CURSOR:C469(Choose:C955(OBJECT Get enabled:C1079(*; "Input8"); 9000; 9019))
	: (FORM Event:C1606.code=On Mouse Leave:K2:34)
		SET CURSOR:C469()
End case 