//Case of 
//: (FORM Event.code=On Getting Focus) | (FORM Event.code=On Clicked)

//var $sfwInstance : cs.sfw
//$sfwInstance:=cs.sfw.new()

//OBJECT GET COORDINATES(*; "field_specificationControl"; $l; $t; $r; $b)
//CONVERT COORDINATES($l; $b; XY Current form; XY Main window)

//$specs:=Split string(Form.specificationControl; ", ")
//$specs:=New collection("CS-11003"; "DC-11500")

//$form:=New object("lb_items"; ds.Specification.query("spec in :1"; $specs))

//$winRef:=Open form window("selectSpecDocument"; Pop up form window; $l; $b-20)
//DIALOG("selectSpecDocument"; $form)
//CLOSE WINDOW($winRef)

//If (ok=1)

//$sfwInstance.openInANewWindow($form.item; "qualityAssurance"; "specification")

////cs.sfw.me.openInANewWindow($form.item; "qualityAssurance"; "Specifications")
////Form.current_item.job.purchaseOrder.poNum:=$form.item.poNum
////Form.current_item.job.UUID_PurchaseOrder:=$form.item.UUID
////$result:=Form.current_item.job.save()
////If ($result.success)
////Form.current_item.UUID:=Form.current_item.UUID
////End if 
//End if 
//: (FORM Event.code=On Mouse Move)
//SET CURSOR(9000)
//End case 