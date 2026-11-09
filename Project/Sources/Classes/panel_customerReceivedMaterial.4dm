singleton Class constructor
	// It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	// Minimal independent panel lifecycle for SFW pages/tabs.
	Form:C1466.sfw.panelFormMethod()
	If (Form:C1466.sfw.updateOfPanelNeeded())
		// Preload materials on item selection so tab count updates immediately.
		This:C1470.loadMaterials()
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())
		Case of 
			: (FORM Get current page:C276(*)=2)
				This:C1470.loadMaterials()
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if 
	This:C1470._checkMandatoryCustomer()  // the customer is on the job: no framework rule can check it
	
Function redrawAndSetVisible()
	Use (Form:C1466.sfw.entry.panel.pages)
		If (Form:C1466.sfw.entry.panel.pages.length>1)
			Form:C1466.sfw.entry.panel.pages[1].label:="Customer Provided Material ("+String:C10(Form:C1466.lb_materials.length)+")"
		End if 
	End use 
	
	OBJECT SET VISIBLE:C603(*; "dp_@"; Form:C1466.sfw.checkIsInModification())
	$isInModification:=Form:C1466.sfw.checkIsInModification()
	
	// Match standard entryField styling behavior for editable inputs in modification mode.
	If ($isInModification)
		OBJECT SET RGB COLORS:C628(*; "entryField_@"; "black"; Background color:K23:2)
		OBJECT SET BORDER STYLE:C1262(*; "entryField_@"; Border System:K42:33)
	Else 
		OBJECT SET RGB COLORS:C628(*; "entryField_@"; 0x00333333; Background color none:K23:10)
		OBJECT SET BORDER STYLE:C1262(*; "entryField_@"; Border None:K42:27)
	End if 
	
	OBJECT SET ENTERABLE:C238(*; "entryField_lotNumber"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "entryField_dateIn"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "entryField_packageType"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET ENABLED:C1123(*; "entryField_packageType"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET ENTERABLE:C238(*; "pup_customer"; Form:C1466.sfw.checkIsInModification())
	
	// Keep read-only fields visually neutral even in modification mode.
	OBJECT SET RGB COLORS:C628(*; "entryField_lotNumber"; 0x00333333; Background color none:K23:10)
	OBJECT SET RGB COLORS:C628(*; "entryField_dateIn"; 0x00333333; Background color none:K23:10)
	OBJECT SET BORDER STYLE:C1262(*; "entryField_lotNumber"; Border None:K42:27)
	OBJECT SET BORDER STYLE:C1262(*; "entryField_dateIn"; Border None:K42:27)
	
	Form:C1466.sfw.drawHTab()
	This:C1470.drawPup_job()
	This:C1470.drawPup_customer()
	
	Case of 
		: (FORM Get current page:C276(*)=2)
			OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_2"; $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_materials"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT GET COORDINATES:C663(*; "bActionCustProvMat"; $left_bAc; $top_bAc; $right_bAc; $bottom_bAc)
			
			$offset:=4
			$offset_r:=5
			$offset_bAc:=10
			$height_bAc:=$bottom_bAc-$top_bAc
			
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_2"; $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_materials"; $left_lb; $top_lb; $widthSubform; $heightSubform)
			OBJECT SET COORDINATES:C1248(*; "bActionCustProvMat"; $left_bAc; $heightSubform-$offset_bAc-$height_bAc; $right_bAc; $heightSubform-$offset_bAc)
	End case 
	
Function selectCustomer()
	var $job : cs:C1710.JobEntity
	var $form : Object
	var $lotsForJob : cs:C1710.LotSelection
	var $lot : cs:C1710.LotEntity
	var $confirm : Boolean
	var $resLot : Object
	
	If (Form:C1466.sfw.checkIsInModification())
		$job:=Form:C1466.current_item.job
		If ($job=Null:C1517)
			$job:=ds:C1482.Job.get(Form:C1466.current_item.UUID_Job)
		End if 
		
		If ($job#Null:C1517)
			$form:=New object:C1471()
			$form.lb_items:=ds:C1482.Customer.all().orderBy("name")
			$form.words:=""
			
			OBJECT GET COORDINATES:C663(*; "pup_customer"; $l; $t; $r; $b)
			CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
			
			$winRef:=Open form window:C675("selectCustomer"; Pop up form window:K39:11; $l; $b+1)
			DIALOG:C40("selectCustomer"; $form)
			CLOSE WINDOW:C154($winRef)
			
			If (OK=1) && ($form.item#Null:C1517)
				$lotsForJob:=ds:C1482.Lot.query("UUID_Job = :1"; $job.UUID)
				$confirm:=True:C214
				If ($lotsForJob.length>1)
					$confirm:=cs:C1710.sfw_dialog.me.confirm(\
						"This job is linked to "+String:C10($lotsForJob.length)+" lots.\rChanging the customer will apply to all these lots.\rDo you want to continue?"; \
						"yes"; \
						"no"\
						)
				End if 
				
				If ($confirm)
					$job.UUID_Customer:=$form.item.UUID
					$job.customerName:=$form.item.name
					
					$res:=$job.save()
					If ($res.success)
						For each ($lot; $lotsForJob)
							$lot.customer:=$form.item.name
							If ($lot.UUID#Form:C1466.current_item.UUID)
								$lot.copyShipToFromCustomer($form.item)  // the job's other lots ship to the new customer too (this one just below)
							End if
							$resLot:=$lot.save()
						End for each 
						
						Form:C1466.current_item.copyShipToFromCustomer($form.item)  // the lot's ship-to follows the new customer
						This:C1470._activate_save_cancel_button()
						This:C1470.drawPup_customer()
					End if 
				End if 
			End if 
		End if 
	End if 
	
Function selectJob()
	// Job picker: the small searchable list of the Customer pop-up, for jobs (receiving_selectJob).
	// When the lot's job already has a customer, only the jobs of that customer are listed.
	// A job of the lot's own comes back with the "+" button (newJob).
	var $form : Object
	var $jobs : 4D:C1709.EntitySelection
	var $customerUUID : Text
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return 
	End if 
	$customerUUID:=""
	If (Form:C1466.current_item.job#Null:C1517)
		$customerUUID:=Form:C1466.current_item.job.UUID_Customer
	End if 
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($customerUUID))
		$jobs:=ds:C1482.Job.all()
	Else 
		$jobs:=ds:C1482.Job.query("UUID_Customer = :1"; $customerUUID)
	End if 
	$form:=New object:C1471("allJobs"; $jobs.orderBy("jobNumber desc"); "lb_items"; Null:C1517; "item"; Null:C1517; "words"; "")
	
	OBJECT GET COORDINATES:C663(*; "pup_job"; $l; $t; $r; $b)
	CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
	$winRef:=Open form window:C675("receiving_selectJob"; Pop up form window:K39:11; $l; $b+1)
	DIALOG:C40("receiving_selectJob"; $form)
	CLOSE WINDOW:C154($winRef)
	
	If (OK=1) && ($form.item#Null:C1517)
		Form:C1466.current_item.job:=$form.item
		Form:C1466.current_item.followCustomerShipTo()  // the ship-to follows the job's customer
		This:C1470.drawPup_job()
		This:C1470.drawPup_customer()
		This:C1470._activate_save_cancel_button()
	End if 
	
Function newJob()
	// "+" next to the job: the lot leaves the existing job picked with selectJob and gets a job of
	// its own again - the one it had (created with the lot), or a new one if that one is gone.
	// A new job keeps the customer of the job being left.
	var $job : 4D:C1709.Entity
	var $previous : 4D:C1709.Entity
	var $res : Object
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return 
	End if 
	$previous:=Form:C1466.current_item.job
	If (Form:C1466.crmOwnJob#Null:C1517)
		If (Form:C1466.crmOwnJob.lot=Form:C1466.current_item.UUID) && (String:C10(Form:C1466.crmOwnJob.job)#"")
			$job:=ds:C1482.Job.get(Form:C1466.crmOwnJob.job)
		End if 
	End if 
	If ($job#Null:C1517)
		// still the lot's own only if no other lot took it meanwhile
		If (ds:C1482.Lot.query("UUID_Job = :1 AND UUID # :2"; $job.UUID; Form:C1466.current_item.UUID).length>0)
			$job:=Null:C1517
		End if 
	End if 
	If ($job=Null:C1517)
		// the same creation as LotEntity.loadAfterCreation: the job number is automatic
		$job:=ds:C1482.Job.new()
		$job.UUID:=Generate UUID:C1066
		$job.dateCreated:=Current date:C33(*)
		If ($previous#Null:C1517)
			If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($previous.UUID_Customer))))
				$job.UUID_Customer:=$previous.UUID_Customer
				$job.customerName:=String:C10($previous.customer.name)
			End if 
		End if 
		$res:=$job.save()
		If (Not:C34($res.success))
			cs:C1710.sfw_dialog.me.alert("A new job could not be created"+Choose:C955(String:C10($res.statusText)=""; "."; ": "+String:C10($res.statusText)))
			return 
		End if 
	End if 
	Form:C1466.crmOwnJob:=New object:C1471("lot"; Form:C1466.current_item.UUID; "job"; $job.UUID)
	Form:C1466.current_item.job:=$job
	Form:C1466.current_item.followCustomerShipTo()  // the ship-to follows the job's customer
	This:C1470.drawPup_job()
	This:C1470.drawPup_customer()
	This:C1470._activate_save_cancel_button()
	
Function drawPup_job()
	
	var $jobNumber : Text
	var $isOwn : Boolean
	
	$jobNumber:=""
	$isOwn:=True:C214
	If (Form:C1466.current_item#Null:C1517)
		If (Form:C1466.current_item.job#Null:C1517)
			$jobNumber:=String:C10(Form:C1466.current_item.job.jobNumber)
		End if 
		If (Form:C1466.crmOwnJob=Null:C1517) || (String:C10(Form:C1466.crmOwnJob.lot)#String:C10(Form:C1466.current_item.UUID))
			Form:C1466.crmOwnJob:=New object:C1471("lot"; Form:C1466.current_item.UUID; "job"; "")
			If (ds:C1482.Lot.query("UUID_Job = :1 AND UUID # :2"; Form:C1466.current_item.UUID_Job; Form:C1466.current_item.UUID).length=0)
				Form:C1466.crmOwnJob.job:=Form:C1466.current_item.UUID_Job
			End if 
		End if 
		$isOwn:=(String:C10(Form:C1466.current_item.UUID_Job)=String:C10(Form:C1466.crmOwnJob.job))
	End if 
	Form:C1466.sfw.drawButtonPup("pup_job"; $jobNumber; ""; ($jobNumber=""))
	OBJECT SET VISIBLE:C603(*; "bNewJob"; Form:C1466.sfw.checkIsInModification() & Not:C34($isOwn))
	
Function pickDateIn()
	// Date In: the framework calendar, under the calendar button (ga_datePicker)
	var $date : Date
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return 
	End if 
	$date:=cs:C1710.ga_datePicker.me.pick(Form:C1466.current_item.dateIn; "dp_dateIn")
	If ($date#!00-00-00!) && ($date#Form:C1466.current_item.dateIn)
		Form:C1466.current_item.dateIn:=$date
		This:C1470._activate_save_cancel_button()
	End if 
	
Function drawPup_customer()
	var $customerName : Text
	var $disabled : Boolean
	
	$customerName:=""
	$disabled:=True:C214
	If (Form:C1466.current_item#Null:C1517)
		If (Form:C1466.current_item.job#Null:C1517)
			$customerName:=Form:C1466.current_item.job.customer.name || " "
			$disabled:=(Form:C1466.current_item.job.customer=Null:C1517)
		End if 
	End if 
	Form:C1466.crmCustomerOk:=Not:C34($disabled)  // read by _checkMandatoryCustomer
	// red while no customer is chosen (the framework's look for a mandatory pop-up left empty)
	Form:C1466.sfw.drawButtonPup("pup_customer"; $customerName; ""; $disabled)
	
Function _checkMandatoryCustomer()
	// The customer is mandatory, but it is stored on the lot's job, not on the lot: a framework
	// validation rule only reads the lot's own fields, so this does what a "mandatory" rule does,
	// with the same flags: Save / Create stay disabled and their tooltip says why.
	// Runs at the end of formMethod; drawPup_customer sets Form.crmCustomerOk.
	// This entry has no validation rule: when it has none, the framework only resets these flags
	// on load / data change, so they are reset here on every event.
	var $message : Text
	
	$message:="The customer is mandatory"
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	If (Form:C1466.sfw.entry.validationRules=Null:C1517)
		Form:C1466.canValidate:=True:C214
		Form:C1466.validationRulesPassedWithSuccess:=True:C214
		Form:C1466.validationRulesMessages:=New collection:C1472
	End if 
	If (Form:C1466.sfw.checkIsInModification()) && (Not:C34(Bool:C1537(Form:C1466.crmCustomerOk)))
		Form:C1466.canValidate:=False:C215
		Form:C1466.validationRulesPassedWithSuccess:=False:C215
		If (Form:C1466.validationRulesMessages=Null:C1517)
			Form:C1466.validationRulesMessages:=New collection:C1472
		End if 
		If (Form:C1466.validationRulesMessages.indexOf($message)=-1)
			Form:C1466.validationRulesMessages.push($message)
		End if 
	End if 
	
Function bActionCustProvMat()
	$refMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($refMenu; "Receive Material")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--receive_material")
	APPEND MENU ITEM:C411($refMenu; "Edit Material")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--edit_material")
	
	// both actions change the lot's materials: Modify mode only (the selection test below also applies to Edit)
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		DISABLE MENU ITEM:C150($refMenu; 1)
		DISABLE MENU ITEM:C150($refMenu; 2)
	End if 
	If ((Form:C1466.selectedMaterial=Null:C1517) | Undefined:C82(Form:C1466.selectedMaterial))
		DISABLE MENU ITEM:C150($refMenu; 2)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	
	Case of 
		: ($choose="--receive_material")
			$continueBatch:=True:C214
			Repeat 
				$form:=New object:C1471(\
					"inventory_e"; ds:C1482.Inventory.new(); \
					"saveAndNew"; False:C215\
					)
				
				$form.inventory_e.UUID_Staff:="0"*32
				$form.inventory_e.UUID_Lot:=Form:C1466.current_item.UUID
				$form.inventory_e.vendor:=Form:C1466.current_item.job.customerName
				// customer material: the lot's customer and job (the Customer filter and the customer's
				// material tab read these links)
				$form.inventory_e.customerSpecific:=True:C214
				$form.inventory_e.customer_provided:=True:C214
				If (Form:C1466.current_item.job#Null:C1517)
					$form.inventory_e.UUID_Job:=Form:C1466.current_item.job.UUID
					If (Form:C1466.current_item.job.customer#Null:C1517)
						$form.inventory_e.UUID_Customer:=Form:C1466.current_item.job.customer.UUID
						$form.inventory_e.vendor:=String:C10(Form:C1466.current_item.job.customer.name)
					End if 
				End if 
				$form.inventory_e.inventoryID:=Sequence number:C244([Inventory:126])  // the table's counter: never given twice ("highest + 1" could be)
				$form.inventory_e.code:="INV"+String:C10($form.inventory_e.inventoryID; "00000#")
				
				$winRef:=Open form window:C675("createManualInv_lot"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
				DIALOG:C40("createManualInv_lot"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					// the quantity received (Qty Received in the dialog) is the stock it starts with (ga_stock)
					$form.inventory_e.availableQty:=$form.inventory_e.initialQty
					cs:C1710.ga_stock.me.syncFigures($form.inventory_e)
					
					$res:=$form.inventory_e.save()
					
					If ($res.success)
						This:C1470.loadMaterials()
						$form.inventory_e.afterCreation()
						This:C1470._activate_save_cancel_button()
						$continueBatch:=$form.saveAndNew
					Else 
						$continueBatch:=False:C215
					End if 
				Else 
					$continueBatch:=False:C215
				End if 
			Until (Not:C34($continueBatch))
		: ($choose="--edit_material")
			This:C1470.editSelectedMaterial()
	End case 
	
Function loadMaterials()
	Form:C1466.lb_materials:=ds:C1482.Inventory.query("UUID_Lot = :1"; Form:C1466.current_item.UUID)
	
Function editSelectedMaterial()
	var $selectedMaterial : cs:C1710.InventoryEntity
	var $form : Object
	var $winRef : Integer
	var $readOnly : Boolean
	var $res : Object
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return   // materials change only in Modify mode, as the Actions menu
	End if 
	
	$selectedMaterial:=Form:C1466.selectedMaterial
	
	If (($selectedMaterial#Null:C1517) & Not:C34(Undefined:C82($selectedMaterial)))
		$form:=New object:C1471(\
			"inventory_e"; $selectedMaterial; \
			"readOnly"; Not:C34(Form:C1466.sfw.checkIsInModification())\
			)
		
		$winRef:=Open form window:C675("createManualInv_lot"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
		DIALOG:C40("createManualInv_lot"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If ((ok=1) & Not:C34($form.readOnly))
			// the description, part, bin, dates... only: the stock moves through Inventories > Pulls & History
			// (ga_stock), never here - this used to set it back to the quantity received, undoing every pull
			$res:=$form.inventory_e.save()
			If ($res.success)
				This:C1470.loadMaterials()
				This:C1470._activate_save_cancel_button()
			End if 
		End if 
	End if 
	