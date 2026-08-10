Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		Form:C1466.lots:=ds:C1482.Lot.query("lotNumber = :1 OR device = :1 OR process = :1"; "@"+Form:C1466.searchBox+"@")
End case 