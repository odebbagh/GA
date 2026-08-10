//Case of 
//: (FORM Event.code=On Getting Focus) | (FORM Event.code=On Clicked)

//OBJECT GET COORDINATES(*; "entryField_lotNumber"; $l; $t; $r; $b)
//CONVERT COORDINATES($l; $b; XY Current form; XY Main window)

//$form:=New object(\
"colName"; "poNum"; \
"allData"; ds.PurchaseOrder.query("UUID_Customer = :1"; Form.current_item.job.UUID_Customer); \
"dataclass"; "PurchaseOrder"\
)

//$winRef:=Open form window("selectNto1"; Pop up form window; $l; $b-20)
//DIALOG("selectNto1"; $form)
//CLOSE WINDOW($winRef)

//If (ok=1)
////Form.current_item.job.purchaseOrder.poNum:=$form.item.poNum
//Form.current_item.job.UUID_PurchaseOrder:=$form.item.UUID
//$result:=Form.current_item.job.save()
//If ($result.success)
//Form.current_item.UUID:=Form.current_item.UUID
//End if 
//End if 
//: (FORM Event.code=On Mouse Move)
//SET CURSOR(9000)
//End case 