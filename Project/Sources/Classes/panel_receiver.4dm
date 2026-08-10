singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
		This:C1470.drawPup_Job()
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=2)
				This:C1470.loadMaterials()
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function drawPup_XXX()
	//This function updates the dropdown by displaying the name
	Form:C1466.sfw.drawButtonPup("pup_xxx"; $xxxName; "xxxx.png"; (Form:C1466.current_item.xxxx=Null:C1517))
	
	
Function pup_XXX()
	//Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
	End if 
	This:C1470.drawPup_XXX()
	
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	This:C1470.hideDatePickers()
	This:C1470.drawPup_LotStatus()
	This:C1470.drawPup_Job()
	
	OBJECT SET ENTERABLE:C238(*; "entryField_CustomerName"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "entryField_lotNumber"; False:C215)
	
	OBJECT SET ENTERABLE:C238(*; "entryField_poNumber"; False:C215)
	OBJECT SET ENABLED:C1123(*; "pup_job"; Form:C1466.situation.mode="add")
	
	OBJECT SET ENTERABLE:C238(*; "pup_job"; Form:C1466.situation.mode="add")
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	Form:C1466.sfw.drawHTab()
	
	Case of 
		: (FORM Get current page:C276(*)=2)  // Customer Provided Material
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_"+String:C10(FORM Get current page:C276(*)); $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_materials"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT GET COORDINATES:C663(*; "bActionCustProvMat"; $left_bAc; $top_bAc; $right_bAc; $bottom_bAc)
			
			$offset:=4
			$offset_r:=5
			$offset_bAc:=10
			
			$height_bAc:=$bottom_bAc-$top_bAc
			
			
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_"+String:C10(FORM Get current page:C276(*)); $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_materials"; $left_lb; $top_lb; $widthSubform-$offset_r; -$heightSubform-$offset-1)
			OBJECT SET COORDINATES:C1248(*; "bActionCustProvMat"; $left_bAc; $heightSubform-$offset_bAc-$height_bAc; $right_bAc; $heightSubform-$offset_bAc)
			
			
	End case 
	
	
Function btnOpenCustomer()
	If (Form:C1466.current_item.purchaseOrder.customer#Null:C1517)
		$es:=ds:C1482.Customer.query("name = :1"; Form:C1466.current_item.job.purchaseOrder.customer.name)
		
		If ($es.length>0)
			Form:C1466.sfw.openInANewWindow($es[0]; "customerService"; "customer")
		End if 
	End if 
	
Function btnOpenPurchaseOrder()
	If (Form:C1466.current_item.job.purchaseOrder#Null:C1517)
		$es:=ds:C1482.PurchaseOrder.query("poNumber = :1"; Form:C1466.current_item.job.purchaseOrder.poNumber)
		
		If ($es.length>0)
			Form:C1466.sfw.openInANewWindow($es[0]; "customerService"; "purchaseOrders")
		End if 
	End if 
	
Function btnOpenJob()
	$entity:=Form:C1466.current_item.job
	Form:C1466.sfw.openInANewWindow($entity; "customerService"; "jobs")
	
Function hideDatePickers()
	OBJECT SET VISIBLE:C603(*; "dp_@"; Form:C1466.sfw.checkIsInModification())
	
Function drawPup_LotStatus()
	If (Form:C1466.current_item#Null:C1517)
		Case of 
			: (Form:C1466.current_item.status=1)
				$color:="SeaGreen"
				$statusName:="Accepted"
				
			: (Form:C1466.current_item.status=2)
				$color:="Crimson"
				$statusName:="Rejected"
				
			Else 
				$color:=""
				$statusName:=" "
		End case 
		
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_lotStatus"; $statusName; $pathIcon; False:C215)
	End if 
	
Function pup_status()
	//Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		
		APPEND MENU ITEM:C411($menu; " "; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; "--nothing")
		
		If (Form:C1466.current_item.status=0)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
			If (Is Windows:C1573)
				SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
			End if 
		End if 
		
		APPEND MENU ITEM:C411($menu; "Accepted"; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; "--accepted")
		
		If (Form:C1466.current_item.status=1)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
			If (Is Windows:C1573)
				SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
			End if 
		End if 
		
		APPEND MENU ITEM:C411($menu; "Rejected"; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; "--rejected")
		
		If (Form:C1466.current_item.status=2)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
			If (Is Windows:C1573)
				SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
			End if 
		End if 
		
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		Case of 
			: ($choose="--accepted")
				Form:C1466.current_item.status:=1
				
			: ($choose="--rejected")
				Form:C1466.current_item.status:=2
				
			Else 
				Form:C1466.current_item.status:=0
		End case 
		
	End if 
	This:C1470.drawPup_LotStatus()
	
	//Function selectJob()
	//If (Form.sfw.checkIsInModification())
	//Case of 
	//: (FORM Event.code=On Getting Focus) | (FORM Event.code=On Clicked)
	//OBJECT GET COORDINATES(*; "Field_customerName"; $l; $t; $r; $b)
	//CONVERT COORDINATES($l; $b; XY Current form; XY Main window)
	
	//$form:=New object(\
		"colName"; "jobNumber"; \
		"lb_items"; ds.Job.all().orderBy("jobNumber"); \
		"allData"; ds.Job.all().orderBy("jobNumber"); \
		"dataclass"; "Job"\
		)
	
Function bActionCustProvMat()
	$refMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($refMenu; "Receive Material")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--receive_material")
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	
	Case of 
		: ($choose="--receive_material")
			$form:=New object:C1471(\
				"inventory_e"; ds:C1482.Inventory.new()\
				)
			
			$form.inventory_e.vendor:=Form:C1466.current_item.job.customerName
			//$form.inventory_e.UUID_Lot:=Form.current_item.UUID
			$form.inventory_e.stockNum:="man_"+String:C10(ds:C1482.Inventory.all().length)+String:C10(Milliseconds:C459)
			$form.inventory_e.inventoryID:=(ds:C1482.Inventory.all().length>0) ? ds:C1482.Inventory.all().max("inventoryID")+1 : 1
			$form.inventory_e.code:="INV"+String:C10($form.inventory_e.inventoryID; "00000#")
			
			$winRef:=Open form window:C675("createManualInv_lot"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("createManualInv_lot"; $form)
			CLOSE WINDOW:C154($winRef)
			
			If (ok=1)
				$form.inventory_e.initialQty:=$form.inventory_e.qtyInStock
				$form.inventory_e.availableQty:=$form.inventory_e.qtyInStock
				
				$res:=$form.inventory_e.save()
				
				If ($res.success)
					This:C1470.loadMaterials()
					$form.inventory_e.afterCreation()
					This:C1470._activate_save_cancel_button()
				End if 
			End if 
	End case 
	
Function loadMaterials()
	Form:C1466.lb_materials:=ds:C1482.Inventory.query("UUID_Job = :1"; Form:C1466.current_item.UUID)
	
Function btnOpenLotParent()
	$entity:=Form:C1466.current_item.lotParent
	Form:C1466.sfw.openInANewWindow($entity; "customerService"; "lots")
	
Function splitLot()
	var $splitGate : Object
	
	If (Form:C1466.sfw.checkIsInModification())
		$splitGate:=cs:C1710.LotSplitService.me.canSplit(Form:C1466.current_item; New object:C1471("inModification"; Form:C1466.sfw.checkIsInModification()))
		If (Not:C34(Bool:C1537($splitGate.allowed)))
			cs:C1710.sfw_dialog.me.alert(String:C10($splitGate.message))
			return 
		End if 
		
		If (Undefined:C82(Form:C1466.current_item.lotParent))
			
			$newLot:=ds:C1482.Lot.new()
			
			$dataclassObject:=ds:C1482.Lot
			
			$id:=Form:C1466.current_item.subLots.length+1
			
			$newLotNumber:=Form:C1466.current_item.lotNumber+"-"+String:C10($id)
			
			$lot_es:=ds:C1482.Lot.query("lotNumber = :1"; $newLotNumber)
			
			While ($lot_es.length>0)
				$id:=$id+1
				
				$newLotNumber:=(Form:C1466.current_item.lotNumber)+"-"+String:C10($id)
				
				$lot_es:=ds:C1482.Lot.query("lotNumber = :1"; $newLotNumber)
			End while 
			
			For each ($attributeName; $dataclassObject)
				$attribute:=$dataclassObject[$attributeName]
				
				If ($attribute.kind="storage")
					Case of 
						: ($attributeName="UUID") & ($attribute.type="string")
							$newLot[$attributeName]:=Generate UUID:C1066
						: ($attributeName="UUID_LotParent") & ($attribute.type="string")
							$newLot.UUID_LotParent:=Form:C1466.current_item.UUID
						: ($attributeName="lotNumber")
							$newLot.lotNumber:=$newLotNumber
						Else 
							$newLot[$attributeName]:=Form:C1466.current_item[$attributeName]
					End case 
				End if 
			End for each 
			
			$res:=$newLot.save()
			
			If ($res.success)
				This:C1470._activate_save_cancel_button()
			End if 
			
		Else 
			//Sub Lot
			ALERT:C41("sub lot")
		End if 
	End if 
	
Function drawPup_Job()
	
	If (Form:C1466.current_item#Null:C1517)
		$jobNumber:=String:C10(Form:C1466.current_item.job.jobNumber) || " "
		Form:C1466.sfw.drawButtonPup("pup_job"; $jobNumber; ""; (Form:C1466.current_item.job=Null:C1517))
	End if 
	
Function selectJob()
	
	If (Form:C1466.sfw.checkIsInModification())
		
		$selector:=cs:C1710.sfw_definitionSelector.new("selectorJob"; "jobs")
		$selector.setTitle("Choose a Job")
		$selector.setCurrentItem(Form:C1466.current_item.job)
		$selector.setOptions("noCutLink")
		$selector.openSelector()
		
		Case of 
			: ($selector.isSelected())
				$itemSeleted:=$selector.getCurrentItem()
				
				Case of 
					: ($itemSeleted=Null:C1517)
					: (cs:C1710.sfw_string.me.isAnEmptyUUID($itemSeleted.UUID)=False:C215)
						Form:C1466.current_item.UUID_Job:=$itemSeleted.UUID
						If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_Job)=True:C214)
							Form:C1466.current_item.UUID_Job:=16*"00"
						End if 
				End case 
				This:C1470.drawPup_Job()
				
			: ($selector.asCutTheLink())
				Form:C1466.current_item.UUID_Job:=16*"00"
				
		End case 
	End if 
	
	