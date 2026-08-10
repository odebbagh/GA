singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())
		
		If (Form:C1466.situation.mode#"add")
			This:C1470.loadAllTabs()
		End if 
		
		If (Form:C1466.current_item.job.lineItem=False:C215)
			This:C1470.salesTaxUpdate()
			This:C1470.chargesCalculation()
		Else 
			This:C1470.pgmTotal()
		End if 
		
	End if 
	
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				
				If (Form:C1466.current_item.job.lineItem=False:C215)
					This:C1470.salesTaxUpdate()
					This:C1470.chargesCalculation()
				Else 
					This:C1470.pgmTotal()
				End if 
				
				
			: (FORM Get current page:C276(*)=2)
				This:C1470.loadLots()
				
			: (FORM Get current page:C276(*)=3)
				
			: (FORM Get current page:C276(*)=4)
				This:C1470.loadJobLineItems()
				This:C1470.pgmTotal()
				
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function redrawAndSetVisible()
	
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	This:C1470.drawPup_job()
	This:C1470.drawPup_status()
	
	Use (Form:C1466.sfw.entry.panel.pages)
		Form:C1466.sfw.entry.panel.pages[1].label:="Lot Qty Amt Based ("+String:C10(Form:C1466.lb_lots.length)+")"
		Form:C1466.sfw.entry.panel.pages[2].label:="PO Items Based ("+String:C10(Form:C1466.lb_poLines.length)+")"
		Form:C1466.sfw.entry.panel.pages[3].label:="Order Items ("+String:C10(Form:C1466.lb_jobLineItems.length)+")"
	End use 
	
	
	OBJECT SET ENABLED:C1123(*; "pup_job"; (Form:C1466.situation.mode="add"))
	OBJECT SET VISIBLE:C603(*; "btnDatePickerInvoiceDate"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "entryField_jobTotalTravBasedCharges"; False:C215)  // Form.current_item.job.lineItem=False)
	OBJECT SET VISIBLE:C603(*; "label_travBasedCharges"; False:C215)  // Form.current_item.job.lineItem=False)
	OBJECT SET VISIBLE:C603(*; "entryField_orderItemsCharges"; False:C215)  //Form.current_item.job.lineItem=True)
	OBJECT SET VISIBLE:C603(*; "label_orderItemsCharge"; False:C215)  //Form.current_item.job.lineItem=True)
	OBJECT SET VISIBLE:C603(*; "entryField_jobTotalPoBasedCharges"; Form:C1466.current_item.job.lineItem=False:C215)
	OBJECT SET VISIBLE:C603(*; "label_poBasedCharges"; Form:C1466.current_item.job.lineItem=False:C215)
	
	OBJECT SET ENTERABLE:C238(*; "entryField_type"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "entryField_job@"; False:C215)
	
	Form:C1466.sfw.drawHTab()
	
	
	//mark:Job
Function drawPup_job()
	///*
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("Job"; "UUID"; "UUID_Job"; "pup_job"; "jobNumber")
	End if 
	//*/
/*
var $jobName : Text
If (Form.current_item#Null)
$jobName:=String(Form.current_item.job.jobNumber) || "Select job"
Form.sfw.drawButtonPup("pup_job"; $jobName; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form.current_item.job=Null))
End if 
*/
	
Function selectJob()
	///*
	Form:C1466.current_item.pup("jobs"; "Job"; "UUID"; "UUID_Job"; "jobNumber")
	This:C1470.drawPup_job()
	//*/
/*
	
If (Form.sfw.checkIsInModification())
	
$selector:=cs.sfw_definitionSelector.new("selectorJob"; "jobs")
$selector.setTitle("Choose a Job")
$selector.setCurrentItem(Form.current_item.job)
$selector.setOptions("noCutLink")
$selector.openSelector()
	
Case of 
: ($selector.isSelected())
$itemSeleted:=$selector.getCurrentItem()
	
Case of 
: ($itemSeleted=Null)
: (cs.sfw_string.me.isAnEmptyUUID($itemSeleted.UUID)=False)
Form.current_item.UUID_Job:=$itemSeleted.UUID
If (cs.sfw_string.me.isAnEmptyUUID(Form.current_item.UUID_Job)=True)
Form.current_item.UUID_Job:=16*"00"
End if 
End case 
This.drawPup_job()
	
: ($selector.needCreation())
//$selector.createANewEntity("cs.panel_jobInvoice.me.callbackAfterCreatioJob($1)")
//This._clearInfoAfterChangingJob()
	
End case 
End if 
*/
	
Function callbackAfterCreatioJob($key : Text)
	Form:C1466.current_item.UUID_Job:=$key
	If (cs:C1710.sfw_string.me.isAnEmptyUUID(Form:C1466.current_item.UUID_Job)=True:C214)
		Form:C1466.current_item.UUID_Job:=16*"00"
	End if 
	EXECUTE METHOD IN SUBFORM:C1085("detail_panel"; Formula:C1597(cs:C1710.panel_lead.me.drawPup_job()); *)
	
	
Function _clearInfoAfterChangingJob()
	Form:C1466.current_item.UUID_Job:=Null:C1517
	
	
Function btnOpenJob()
	$entity:=Form:C1466.current_item.job
	If ($entity#Null:C1517)
		Form:C1466.sfw.openInANewWindow($entity; "customerService"; "jobs")
	End if 
	
	
Function btnOpenPurchaseOrder()
	$es:=ds:C1482.PurchaseOrder.query("poNumber =:1"; Form:C1466.current_item.job.poNumber)
	If ($es.length>0)
		Form:C1466.sfw.openInANewWindow($es[0]; "customerService"; "purchaseOrders")
	End if 
	
	
Function btnOpenCustomer()
	$es:=ds:C1482.Customer.query("name =:1"; Form:C1466.current_item.job.customer.name)  //customerName)
	If ($es.length>0)
		Form:C1466.sfw.openInANewWindow($es[0]; "customerService"; "customer")
	End if 
	
	
	///*
Function drawPup_status()
	If (Form:C1466.current_item#Null:C1517)
		$job:=Form:C1466.current_item
		
		$invoiceStatus:=Form:C1466.current_item.status
		
		$color:=""
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_status"; $invoiceStatus; $pathIcon; ($job=Null:C1517))
	End if 
	
	
Function pup_status()
	//Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		$invoiceStatus:=New collection:C1472(New object:C1471("name"; "paid"))  //; New object("name"; "closed"))  
		For each ($eType; $invoiceStatus)
			APPEND MENU ITEM:C411($menu; $eType.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $eType.name)
			If ($eType.name=Form:C1466.current_item.staus)
				SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
				If (Is Windows:C1573)
					SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
				End if 
			End if 
		End for each 
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		Case of 
			: ($choose#"")
				Form:C1466.current_item.status:=$choose
				This:C1470._activate_save_cancel_button()
		End case 
		
	End if 
	This:C1470.drawPup_status()
	
	//*/
	
Function bActionLot()
	
	$refMenu:=Create menu:C408
	APPEND MENU ITEM:C411($refMenu; "Open in new window"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "openInWindow")
	
	If (Form:C1466.selectedLot=Null:C1517) | (Undefined:C82(Form:C1466.selectedLot))
		
		DISABLE MENU ITEM:C150($refMenu; -1)
		
	End if 
	
	$choice:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	
	Case of 
			
		: ($choice="openInWindow")
			
			Form:C1466.sfw.openInANewWindow(Form:C1466.current_item.job.lots.query("UUID=:1"; Form:C1466.selectedLot.UUID).first(); "customerService"; "lots")
			
	End case 
	
	
Function bActionJobLineItem()
	
	//Manages actions: add, or remove, using dynamic menus and modification checks
	If (Form:C1466.sfw.checkIsInModification())
		$refMenu:=Create menu:C408
		APPEND MENU ITEM:C411($refMenu; "Add Job Line Item")
		SET MENU ITEM PARAMETER:C1004($refMenu; 1; "--create")
		
		
		APPEND MENU ITEM:C411($refMenu; "-")
		APPEND MENU ITEM:C411($refMenu; "Modify")
		SET MENU ITEM PARAMETER:C1004($refMenu; 3; "--modify")
		
		If (Form:C1466.selectedJobLineItem=Null:C1517)\
			 | (Undefined:C82(Form:C1466.selectedJobLineItem))
			
			DISABLE MENU ITEM:C150($refMenu; 3)
		End if 
		
		APPEND MENU ITEM:C411($refMenu; "-")
		APPEND MENU ITEM:C411($refMenu; "Delete")
		SET MENU ITEM PARAMETER:C1004($refMenu; 5; "--delete")
		
		If (Form:C1466.selectedJobLineItem=Null:C1517)\
			 | (Undefined:C82(Form:C1466.selectedJobLineItem))
			
			DISABLE MENU ITEM:C150($refMenu; 5)
			
		End if 
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
		Case of 
				
			: ($choose="--create")
				
				SUSPEND TRANSACTION:C1385
				
				var $eJobLineItem : cs:C1710.JobLineItemEntity
				$eJobLineItem:=ds:C1482.JobLineItem.new()
				
				$form:=New object:C1471("operation"; "create"; \
					"itemNumber"; Form:C1466.lb_jobLineItems.length+1; \
					"jobUUID"; Form:C1466.current_item.job.UUID; \
					"jobTaxRate"; Form:C1466.current_item.job.salesTax#Null:C1517 ? Form:C1466.current_item.job.salesTax.rate : 0; \
					"lineItem"; $eJobLineItem)
				
				$winRef:=Open form window:C675("createJobLineItem"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
				DIALOG:C40("createJobLineItem"; $form)
				CLOSE WINDOW:C154($winRef)
				
				RESUME TRANSACTION:C1386
				
				If (OK=1)
					
					This:C1470.loadJobLineItems()
					
				End if 
				
			: ($choose="--modify")
				
				SUSPEND TRANSACTION:C1385
				
				$form:=New object:C1471("operation"; "modify"; \
					"itemNumber"; Form:C1466.lb_jobLineItems.length+1; \
					"jobUUID"; Form:C1466.current_item.job.UUID; \
					"jobTaxRate"; Form:C1466.current_item.job.salesTax#Null:C1517 ? Form:C1466.current_item.job.salesTax.rate : 0; \
					"lineItem"; Form:C1466.selectedJobLineItem)
				
				$winRef:=Open form window:C675("createJobLineItem"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
				DIALOG:C40("createJobLineItem"; $form)
				CLOSE WINDOW:C154($winRef)
				
				RESUME TRANSACTION:C1386
				
				If (OK=1)
					
					This:C1470.loadJobLineItems()
					
				End if 
				
			: ($choose="--delete")
				SUSPEND TRANSACTION:C1385
				
				$eJobLineItem:=ds:C1482.JobLineItem.get(Form:C1466.lineItem.UUID)
				
				$info:=$eJobLineItem.drop()
				
				If (Not:C34($info.success))
					TRACE:C157
				End if 
				
				RESUME TRANSACTION:C1386
				
		End case 
		
	Else 
		
		
	End if 
	
	
	
Function loadLots()
	
	If (Form:C1466.current_item#Null:C1517)
		
		Form:C1466.lb_lots:=ds:C1482.Lot.query("UUID_Job =:1"; Form:C1466.current_item.UUID_Job)
		
	End if 
	
	
Function loadPoLines()
	
	If (Form:C1466.current_item#Null:C1517)
		
		Form:C1466.lb_poLines:=ds:C1482.PurchaseOrderLine.query("UUID_Job =:1"; Form:C1466.current_item.UUID_Job)  //Form.current_item.job.purchaseOrderLines
		
	End if 
	
	
Function loadJobLineItems()
	
	If (Form:C1466.current_item#Null:C1517)
		
		Form:C1466.lb_jobLineItems:=ds:C1482.JobLineItem.query("UUID_Job =:1"; Form:C1466.current_item.UUID_Job)
		
	End if 
	
	
Function loadAllTabs()
	This:C1470.loadLots()
	This:C1470.loadPoLines()
	This:C1470.loadJobLineItems()
	
	
Function bActionPoLine()
	//Manages actions: add, or remove, using dynamic menus and modification checks
	If (Form:C1466.sfw.checkIsInModification())
		$refMenu:=Create menu:C408
		APPEND MENU ITEM:C411($refMenu; "Attach a PO Line")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--create")
		APPEND MENU ITEM:C411($refMenu; "-")
		APPEND MENU ITEM:C411($refMenu; "(Delete")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
		Case of 
			: ($choose="--create")
				
				$form:=New object:C1471("job"; Form:C1466.current_item.job)
				
				$winRef:=Open form window:C675("createPoLine_jobInvoice"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
				DIALOG:C40("createPoLine_jobInvoice"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (OK=1)
					This:C1470.loadPoLines()
					This:C1470.chargesCalculation()
				End if 
				
			: ($choose="--delete")
				
		End case 
	Else 
		
		
	End if 
	
	
Function salesTaxUpdate()
	If (Form:C1466.current_item.job#Null:C1517)
		$taxRate:=Form:C1466.current_item.job.salesTax#Null:C1517 ? Form:C1466.current_item.job.salesTax.rate : 0
		If (Form:C1466.current_item.job.taxable=True:C214)
			
			Form:C1466.current_item.job.totalTax:=Form:C1466.current_item.job.miscCharges*($taxRate/100)
		Else 
			Form:C1466.current_item.job.totalTax:=0
		End if 
		Form:C1466.current_item.job.totalTax:=Form:C1466.current_item.job.totalTax+Form:C1466.lb_poLines.sum("saleTax")
		
	End if 
	
Function chargesCalculation()  //--> Subr_Total
	
	Form:C1466.current_item.total:=0
	
	//--> Po-Line-Item Charges
	Form:C1466.current_item.poBasedCharges:=Form:C1466.lb_poLines.sum("total")-Form:C1466.lb_poLines.sum("saleTax")
	
	//-->Unit Cost cases
	//TODO : Check if still in use
	
	//--> Total charges
	Form:C1466.current_item.total:=Form:C1466.current_item.total+Form:C1466.current_item.travBasedCharges+Form:C1466.current_item.poBasedCharges
	$total1:=Form:C1466.current_item.total
	
	//MixedDevices:=DoesJobHaveMixedDevices
	// | 
	//-->$MixedDevices:=False
	//SubrRelateRecvrSubLots
	//ORDER BY([Receiver_LotsSubT]; [Receiver_LotsSubT]Device; >)
	//FIRST RECORD([Receiver_LotsSubT])
	//$Device:=[Receiver_LotsSubT]Device
	
	//Case of 
	//: (Records in selection([Receiver_LotsSubT])>1)
	//For ($i; 1; Records in selection([Receiver_LotsSubT]))
	
	//NEXT RECORD([Receiver_LotsSubT])
	//If ($Device#[Receiver_LotsSubT]Device)
	//$MixedDevices:=True
	//End if 
	//End for 
	//End case 
	//SubrRelateRecvrSubLots
	//$0:=$MixedDevices
	
	Case of 
			
		: (Form:C1466.current_item.job.boxStockShipment=True:C214)
			Form:C1466.current_item.total:=Form:C1466.lb_lots.sum("totalCharge")
			
			
			//: [Receiver]Inv_Format=<>a_inv_format{1})  // `Lot_Qty_Amt --> Job.invFormat --> Calculate UnitCost  Lot_Qty_Amt
			
			//Case of 
			//: (Records in selection([Unit_Cost])=1) & ($MixedDevices=False)
			//For ($i; 1; Records in selection([Lotinfo]))
			//[Lotinfo]UnitCost:=[Unit_Cost]Singular_Unit_Price
			//apply_unit_cost_to_lot_qty_out
			//NEXT RECORD([Lotinfo])
			//End for 
			//End case 
			//[Receiver]Total_Charge:=Sum([Lotinfo]TotalCharge)  --> Form.current_item.total:=Form.lb_lots.sum("totalCharge")
			
			
			//Case of 
			//: ($total1#[Receiver]Total_Charge) & ($total1#0) --> ($total1=Form.current_item.total) & ($total1#0)
			//BEEP
			//ALERT("You are changing format but invoice has  unit-cost-per-step and/or setup-charges") --> QUESTION : What is the meaning of invoice has  unit-cost-per-step and/or setup-charges
			//End case 
			
			
			
			//End case 
			
			
		Else 
			
	End case 
	
	
	Form:C1466.current_item.total:=Form:C1466.current_item.total+Form:C1466.current_item.job.miscCharges
	
	//Case of 
	//: (Records in selection([Unit_Cost])=1)
	//If ([Receiver]Total_Charge<[Unit_Cost]MinJobCharge) & ([Receiver]MinimumJobCharge=True)
	//[Receiver]Total_Charge:=[Unit_Cost]MinJobCharge
	//End if 
	//End case 
	
	
	//Has it all
	Form:C1466.current_item.total:=Form:C1466.current_item.total+Form:C1466.current_item.job.totalTax+Form:C1466.current_item.job.freight
	
	This:C1470.IsPOShort()
	
	
Function IsPOShort()
	
	//Check and alert
	$POs:=ds:C1482.PurchaseOrder.query("poNumber =:1"; Form:C1466.current_item.job.poNumber)
	
	Case of 
			
		: ($POs.length=1)
			$po:=$POs[0]
			If ($po.amountBilled>$po.poAmount)
				
				If (Form:C1466.current_item.job.postToPO=True:C214)
					$poAmtBilled:=$po.amountBilled
				Else 
					$poAmtBilled:=Form:C1466.current_item.total+$po[0].amountBilled
				End if 
				
				If ($poAmtBilled>($po.poAmount+0.01)) & (Read only state:C362([Job:117]))
					
					Case of 
							
						: (Form:C1466.current_item.total<=0.01)
							
							$error:="WARNING: "
						: (($poAmtBilled-Form:C1466.current_item.job.totalTax)<$po.poAmount+1)
							
							$error:="WARNING: "
						Else 
							
							$error:="Error: "
					End case 
					
					//If ($error="WARNING@")
					//cs.sfw_dialog.me.info(ds.sfw_readXliff($error; "PO has run over by "+String($po.poAmount-$poAmtBilled; "|money")))
					//Else 
					cs:C1710.sfw_dialog.me.info(ds:C1482.sfw_readXliff($error; "PO has run over by "+String:C10($po.poAmount-$poAmtBilled; "|money")))
					//End if 
					
				End if 
				
			End if 
			
	End case 
	
	
Function UpdateItemTax()  // --> upd_itemstax
	
	For each ($joblineItem; Form:C1466.lb_jobLineItems)
		If (Form:C1466.current_item.job#Null:C1517)
			$taxRate:=Form:C1466.current_item.job.salesTax#Null:C1517 ? Form:C1466.current_item.job.salesTax.rate : 0
			//If() --> Check if time_billing invoice
			Form:C1466.current_item.job.totalTax:=Form:C1466.current_item.job.totalTax+(($joblineItem.quantity*$joblineItem.unitPrice)*($taxRate/100)*Num:C11($joblineItem.taxable))
			$joblineItem.lineTotal:=($joblineItem.quantity*$joblineItem.unitPrice)+(($joblineItem.quantity*$joblineItem.unitPrice)*($taxRate/100)*Num:C11($joblineItem.taxable))
			
			////Else
			//Form.current_item.job.totalTax:=Form.current_item.job.totalTax+(($joblineItem.quantity*$joblineItem.unitPrice)*($taxRate/100)*Num($joblineItem.taxable))
			//$joblineItem.lineTotal:=($joblineItem.hourCount*$joblineItem.unitPrice)+(($joblineItem.hourCount*$joblineItem.unitPrice)*($taxRate/100)*Num($joblineItem.taxable))
			
			//End if
			
			If (Form:C1466.current_item.job.taxable=True:C214)
				Form:C1466.current_item.job.totalTax:=Form:C1466.current_item.job.totalTax+Form:C1466.current_item.job.miscCharges*($taxRate/100)
			End if 
			
			SUSPEND TRANSACTION:C1385
			$job:=ds:C1482.Job.query("UUID =:1"; Form:C1466.current_item.job.UUID).first()
			$job:=Form:C1466.current_item.job
			$info:=$job.save()
			If (Not:C34($info.success))
				TRACE:C157
			End if 
			
			RESUME TRANSACTION:C1386
			
		End if 
	End for each 
	
	
Function pgmTotal()
	
	This:C1470.UpdateItemTax()
	
	Form:C1466.current_item.total:=0
	Form:C1466.current_item.total:=Form:C1466.lb_jobLineItems.sum("lineTotal")
	If (Form:C1466.current_item.job#Null:C1517)
		Form:C1466.current_item.total:=Form:C1466.current_item.total+Form:C1466.current_item.job.miscCharges+Form:C1466.current_item.job.freight
		If (Form:C1466.current_item.job.taxable=True:C214)
			$taxRate:=Form:C1466.current_item.job.salesTax#Null:C1517 ? Form:C1466.current_item.job.salesTax.rate : 0
			Form:C1466.current_item.total:=Form:C1466.current_item.total+(Form:C1466.current_item.job.miscCharges*($taxRate/100))
		End if 
	End if 
	
	
	
	
	
	
	
	
	
	