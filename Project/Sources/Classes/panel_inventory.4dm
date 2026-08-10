singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
		This:C1470.loadAllTabs()
		Form:C1466.currentPath:=""
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=2)
				This:C1470.loadInventoryPulls()
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
	
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	
	Use (Form:C1466.sfw.entry.panel.pages)
		Form:C1466.sfw.entry.panel.pages[1].label:="Inventory Pulls ("+String:C10(Form:C1466.lb_pulls.length)+")"
	End use 
	
	This:C1470.drawPup_customer()
	This:C1470.drawPup_status_IQA()
	This:C1470.drawPup_staff()
	This:C1470.drawPup_binLocation()
	
	
	OBJECT SET ENABLED:C1123(*; "dp_locations"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET ENABLED:C1123(*; "dp_units"; Form:C1466.sfw.checkIsInModification())
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	Case of 
		: (FORM Get current page:C276(*)=2)  // po lines
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_2"; $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_pulls"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT GET COORDINATES:C663(*; "bActionPulls"; $left_bAc; $top_bAc; $right_bAc; $bottom_bAc)
			
			$offset:=4
			$offset_bAc:=10
			
			$height_bAc:=$bottom_bAc-$top_bAc
			
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_2"; $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_pulls"; $left_lb; $top_lb; $right_lb; $heightSubform-$offset-1)
			OBJECT SET COORDINATES:C1248(*; "bActionPulls"; $left_bAc; $heightSubform-$offset_bAc-$height_bAc; $right_bAc; $heightSubform-$offset_bAc)
	End case 
	
	OBJECT SET ENABLED:C1123(*; "btnOpenCustomer"; (Form:C1466.current_item.customer#Null:C1517))
	
	OBJECT SET VISIBLE:C603(*; "btnOpenCustomer"; (Form:C1466.current_item.customer#Null:C1517) & Not:C34(Form:C1466.current_item.customerSpecific))
	OBJECT SET VISIBLE:C603(*; "entryField_vendor"; (Form:C1466.current_item.customerSpecific))
	OBJECT SET VISIBLE:C603(*; "pup_customer"; Not:C34(Form:C1466.current_item.customerSpecific))
	
	
	Form:C1466.sfw.drawHTab()
	
	
	
Function loadAllTabs()
	This:C1470.loadInventoryPulls()
	
Function loadInventoryPulls()
	Form:C1466.lb_pulls:=ds:C1482.InventoryPull.query("UUID_Inventory = :1"; Form:C1466.current_item.UUID).orderBy("date desc")
	
Function bActionInvPull()
	$refMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($refMenu; "Put Back")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--put-back")
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	APPEND MENU ITEM:C411($refMenu; "-")
	
	APPEND MENU ITEM:C411($refMenu; "Pull")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--pull")
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	
	If ($choose#"")
		$form:=New object:C1471(\
			"invPull"; New object:C1471(\
			"order"; Form:C1466.lb_pulls.length+1; \
			"isPull"; ($choose="--pull") ? True:C214 : False:C215; \
			"date"; Current date:C33(); \
			"currentQty"; Form:C1466.current_item.availableQty; \
			"qtyToPull"; 0; \
			"pulledBy"; ""; \
			"note"; ""\
			))
		
		$user_es:=ds:C1482.sfw_User.query("login = :1"; Current user:C182)
		
		$form.invPull.pulledBy:=($user_es.length>0) ? $user_es[0].fullName : ""
		
		$winRef:=Open form window:C675("create_invPull"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
		DIALOG:C40("create_invPull"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (OK=1)
			$pull_e:=ds:C1482.InventoryPull.new()
			$pull_e.type:=($form.invPull.isPull) ? "Pull" : "Put Back"
			$pull_e.date:=cs:C1710.sfw_stmp.me.build($form.invPull.date)
			$pull_e.qty:=$form.invPull.qtyToPull
			$pull_e.remaining:=$form.invPull.currentQty-$form.invPull.qtyToPull
			$pull_e.performedBy:=$form.invPull.pulledBy
			$pull_e.lotNumber:="N/A"
			$pull_e.statusIQA:="N/A"
			
			$pull_e.UUID_Inventory:=Form:C1466.current_item.UUID
			
			$res:=$pull_e.save()
			
			If ($res.success)
				Form:C1466.current_item.availableQty:=$pull_e.remaining
				
				This:C1470.loadInventoryPulls()
				This:C1470._activate_save_cancel_button()
			End if 
		End if 
	End if 
	
Function selectCustomer()
	If (Form:C1466.sfw.checkIsInModification())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				
				OBJECT GET COORDINATES:C663(*; "pup_customer"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				$form:=New object:C1471(\
					"colName"; "name"; \
					"lb_items"; ds:C1482.Customer.all(); \
					"allData"; ds:C1482.Customer.all(); \
					"dataclass"; "Customer"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					Form:C1466.current_item.UUID_Customer:=$form.item.UUID
					This:C1470._activate_save_cancel_button()
				End if 
		End case 
	End if 
	This:C1470.drawPup_customer()
	
Function drawPup_customer()
	If (Form:C1466.current_item#Null:C1517)
		$name:=Form:C1466.current_item.customer.name || "Select Customer"
		Form:C1466.sfw.drawButtonPup("pup_customer"; $name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.customer=Null:C1517))
	End if 
	
Function drawPup_status_IQA()
	If (Form:C1466.current_item#Null:C1517)
		$name:=Form:C1466.current_item.IQA_status || "Select Status"
		Form:C1466.sfw.drawButtonPup("pup_IQAstatus"; $name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.IQA_status=Null:C1517))
	End if 
	
Function drawPup_staff()
	If (Form:C1466.current_item#Null:C1517)
		$name:=Form:C1466.current_item.staff.fullName || "Select Customer"
		Form:C1466.sfw.drawButtonPup("pup_staff"; $name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.staff=Null:C1517))
	End if 
	
Function manageLocation()
	Case of 
		: (FORM Event:C1606.code=On Data Change:K2:15)
			$locations:=ds:C1482.Location.query("name = :1"; "@"+Form:C1466.current_item.location+"@")
			
			If ($locations.length>0)
				OBJECT GET COORDINATES:C663(*; "entryField_location"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				$form:=New object:C1471(\
					"colName"; "name"; \
					"lb_items"; $locations; \
					"allData"; ds:C1482.Location.all(); \
					"dataclass"; "Location"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					If ($form.item#Null:C1517)
						Form:C1466.current_item.location:=$form.item.name
						This:C1470._activate_save_cancel_button()
					Else 
						Form:C1466.current_item.location:=""
					End if 
				Else 
					Form:C1466.current_item.location:=""
				End if 
			Else 
				$ok:=cs:C1710.sfw_dialog.me.confirm("No Location found !!\rWould you like to create a new one?"; "yes"; "no")
				
				If ($ok)
					$location_e:=ds:C1482.Location.new()
					$location_e.name:=Form:C1466.current_item.location
					$res:=$location_e.save()
					
					If (Not:C34($res.success))
						Form:C1466.current_item.location:=""
					End if 
				Else 
					Form:C1466.current_item.location:=""
				End if 
			End if 
	End case 
	
Function manageUnit()
	Case of 
		: (FORM Event:C1606.code=On Data Change:K2:15)
			$units:=ds:C1482.Unit.query("name = :1"; "@"+Form:C1466.current_item.units+"@")
			
			If ($units.length>0)
				OBJECT GET COORDINATES:C663(*; "entryField_location"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				$form:=New object:C1471(\
					"colName"; "name"; \
					"lb_items"; $units; \
					"allData"; ds:C1482.Unit.all(); \
					"dataclass"; "Unit"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					If ($form.item#Null:C1517)
						Form:C1466.current_item.units:=$form.item.name
						This:C1470._activate_save_cancel_button()
					Else 
						Form:C1466.current_item.units:=""
					End if 
				Else 
					Form:C1466.current_item.units:=""
				End if 
			Else 
				$ok:=cs:C1710.sfw_dialog.me.confirm("No Unit found !!\rWould you like to create a new one?"; "yes"; "no")
				
				If ($ok)
					$unit_e:=ds:C1482.Unit.new()
					$unit_e.name:=Form:C1466.current_item.units
					$res:=$unit_e.save()
					
					If (Not:C34($res.success))
						Form:C1466.current_item.units:=""
					End if 
				Else 
					Form:C1466.current_item.units:=""
				End if 
			End if 
	End case 
	
Function manageClassification()
	Case of 
		: (FORM Event:C1606.code=On Data Change:K2:15)
			$classifications:=ds:C1482.Classification.query("name = :1"; "@"+Form:C1466.current_item.classification+"@")
			
			If ($classifications.length>0)
				OBJECT GET COORDINATES:C663(*; "entryField_classification"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				$form:=New object:C1471(\
					"colName"; "name"; \
					"lb_items"; $classifications; \
					"allData"; ds:C1482.Classification.all(); \
					"dataclass"; "Classification"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					If ($form.item#Null:C1517)
						Form:C1466.current_item.classification:=$form.item.name
						This:C1470._activate_save_cancel_button()
					Else 
						Form:C1466.current_item.classification:=""
					End if 
				Else 
					Form:C1466.current_item.classification:=""
				End if 
			Else 
				$ok:=cs:C1710.sfw_dialog.me.confirm("No Classification found !!\rWould you like to create a new one?"; "yes"; "no")
				
				If ($ok)
					$location_e:=ds:C1482.Classification.new()
					$location_e.name:=Form:C1466.current_item.classification
					$res:=$location_e.save()
					
					If (Not:C34($res.success))
						Form:C1466.current_item.classification:=""
					End if 
				Else 
					Form:C1466.current_item.classification:=""
				End if 
			End if 
	End case 
	
Function selectStatus_IQA()
	If (Form:C1466.sfw.checkIsInModification())
		$refMenu:=Create menu:C408
		
		APPEND MENU ITEM:C411($refMenu; " ")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--empty")
		
		APPEND MENU ITEM:C411($refMenu; "In Progress")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--in-progress")
		
		APPEND MENU ITEM:C411($refMenu; "Done")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--done")
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
		Case of 
			: ($choose="--empty")
				Form:C1466.current_item.IQA_status:=""
				
			: ($choose="--in-progress")
				Form:C1466.current_item.IQA_status:="In Progress"
				
			: ($choose="--done")
				Form:C1466.current_item.IQA_status:="Done"
		End case 
	End if 
	This:C1470.drawPup_status_IQA()
	
Function selectStaff()
	If (Form:C1466.sfw.checkIsInModification())
		Case of 
			: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
				
				OBJECT GET COORDINATES:C663(*; "pup_staff"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				$form:=New object:C1471(\
					"colName"; "fullName"; \
					"lb_items"; ds:C1482.Staff.all().orderBy("fullName asc"); \
					"allData"; ds:C1482.Staff.all().orderBy("fullName asc"); \
					"dataclass"; "Staff"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b+1)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					Form:C1466.current_item.UUID_Staff:=$form.item.UUID
					This:C1470._activate_save_cancel_button()
				End if 
		End case 
	End if 
	This:C1470.drawPup_staff()
	
Function btnOpenCustomer()
	$entity:=Form:C1466.current_item.customer
	If ($entity#Null:C1517)
		Form:C1466.sfw.openInANewWindow($entity; "customerService"; "customer")
	End if 
	
	
Function drawPup_binLocation()
	If (Form:C1466.current_item#Null:C1517)
		
		$binLocation:=ds:C1482.Bin.query("UUID= :1"; Form:C1466.current_item.UUID_Location).first() || New object:C1471()
		$locationName:=$binLocation.binLocationPath
		If ($locationName=Null:C1517)
			$locationName:=""
		End if 
		cs:C1710.Util_binLocationPicker.me.draw("pup_binLocation"; $locationName)
		
	End if 
	
Function pup_binLocation()
	
	If (Form:C1466.sfw.checkIsInModification())
		
		$result:=cs:C1710.Util_binLocationPicker.me.pickReadOnly("pup_binLocation"; Form:C1466.currentPath; "")
		If ($result#"")
			Form:C1466.currentPath:=$result
			Form:C1466.selectedBins:=Storage:C1525.cache.bins.query("binLocationPath = :1"; Form:C1466.currentPath)
			If (Form:C1466.selectedBins#Null:C1517)
				If (Form:C1466.selectedBins.length>0)
					// Link inventory to the selected Bin record.
					Form:C1466.current_item.UUID_Location:=Form:C1466.selectedBins.first().UUID
					Form:C1466.current_item.location:=Form:C1466.selectedBins.first().binLocationPath
					This:C1470._activate_save_cancel_button()
				End if 
			End if 
			This:C1470.drawPup_binLocation()
			
		End if 
		
	End if 
	