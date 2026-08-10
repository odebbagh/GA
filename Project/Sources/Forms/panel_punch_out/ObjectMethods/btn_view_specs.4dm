Case of 
	: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
		
		var $sfwInstance : cs:C1710.sfw
		$sfwInstance:=cs:C1710.sfw.new()
		
		OBJECT GET COORDINATES:C663(*; "field_specificationControl"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$specs:=Split string:C1554(Form:C1466.specificationControl; ", ")
		$specs:=New collection:C1472("CS-11003"; "DC-11500")
		
		$form:=New object:C1471("lb_items"; ds:C1482.Specification.query("spec in :1"; $specs))
		
		$winRef:=Open form window:C675("selectSpecDocument"; Pop up form window:K39:11; $l; $b-20)
		DIALOG:C40("selectSpecDocument"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (ok=1)
			
			$sfwInstance.openInANewWindow($form.item; "qualityAssurance"; "specification")
			
			//cs.sfw.me.openInANewWindow($form.item; "qualityAssurance"; "Specifications")
			//Form.current_item.job.purchaseOrder.poNum:=$form.item.poNum
			//Form.current_item.job.UUID_PurchaseOrder:=$form.item.UUID
			//$result:=Form.current_item.job.save()
			//If ($result.success)
			//Form.current_item.UUID:=Form.current_item.UUID
			//End if 
		End if 
	: (FORM Event:C1606.code=On Mouse Move:K2:35)
		SET CURSOR:C469(9000)
End case 