Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		Form:C1466.poLines:=ds:C1482.PurchaseOrderLine.query("description = :1"; "@"+Form:C1466.searchBox+"@")
		//If (Form.searchBox#"")
		//Form.poLines:=ds.PurchaseOrderLine.query("description = :1"; "@"+Form.searchBox+"@")
		//Else 
		//Form.poLines:=ds.PurchaseOrderLine.all()
		//End if 
End case 