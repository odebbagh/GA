Case of 
	: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
		
		var $sfwInstance : cs:C1710.sfw
		var $specUUIDs : Collection
		
		$sfwInstance:=cs:C1710.sfw.new()
		
		OBJECT GET COORDINATES:C663(*; "field_specificationControl"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$specUUIDs:=New collection:C1472()
		If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.specificationControl#Null:C1517) && (Form:C1466.current_item.specificationControl.items#Null:C1517)
			For each ($specItem; Form:C1466.current_item.specificationControl.items)
				If ($specItem.UUID_Specification#Null:C1517)
					$specUUIDs.push($specItem.UUID_Specification)
				End if 
			End for each 
		End if 
		
		If ($specUUIDs.length=0)
			return 
		End if 
		
		$form:=New object:C1471("lb_items"; ds:C1482.Specification.query("UUID in :1"; $specUUIDs))
		
		$winRef:=Open form window:C675("selectSpecDocument"; Pop up form window:K39:11; $l; $b-20)
		DIALOG:C40("selectSpecDocument"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (ok=1)
			$sfwInstance.openInANewWindow($form.item; "qualityAssurance"; "specification")
		End if 
	: (FORM Event:C1606.code=On Mouse Move:K2:35)
		SET CURSOR:C469(9000)
End case 
