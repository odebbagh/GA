Class extends DataClass


Function duplicateStepFileFromList()
	var $src : 4D:C1709.Entity
	var $dup : 4D:C1709.Entity
	var $res : Object
	var $indexInEntitySelection : Integer
	
	//If (Form.current_item=Null)
	//cs.sfw_dialog.me.alert("Select a step file in the list first."; "OK")
	//return 
	//End if 
	
	$src:=Form:C1466.current_item
	$dup:=ds:C1482.StepFile.new()
	$dup.name:=""
	$dup.UUID_Customer:=$src.UUID_Customer
	$dup.status:=$src.status
	
	If ($src.stepsDefinition#Null:C1517)
		$dup.stepsDefinition:=$src.stepsDefinition
	Else 
		$dup.stepsDefinition:=New object:C1471("items"; New collection:C1472())
	End if 
	
	$res:=$dup.save()
	If ($res.success=False:C215)
		cs:C1710.sfw_dialog.me.alert("Could not duplicate step file."; "OK")
		return 
	End if 
	
	Form:C1466.sfw.validateTransaction()
	$dup:=ds:C1482.StepFile.get($dup.UUID)
	
	//Needs Check
	If (Form:C1466.sfw.lb_items#Null:C1517) && (OB Class:C1730(Form:C1466.sfw).name#"sfw_item")
		Try
			Form:C1466.sfw.lb_items:=Form:C1466.sfw.lb_items.copy().add($dup)
			Form:C1466.sfw.lb_items_sort()
		Catch
			Form:C1466.sfw.lb_items_search()
		End try
		$indexInEntitySelection:=$dup.indexOf(Form:C1466.sfw.lb_items)
		If ($indexInEntitySelection>=0)
			Case of 
				: (Form:C1466.sfw.view.displayType="recursiveList")
					Form:C1466.sfw._drawRecursiveList()
				Else 
					Form:C1466.sfw.lb_items:=Form:C1466.sfw.lb_items
					LISTBOX SELECT ROW:C912(*; "lb_items"; $indexInEntitySelection+1; lk replace selection:K53:1)
					Form:C1466.current_lb_item:=Form:C1466.sfw.lb_items[$indexInEntitySelection]
					Form:C1466.current_lb_item_pos:=$indexInEntitySelection+1
					Form:C1466.current_item:=Form:C1466.sfw.lb_items[$indexInEntitySelection]
					Form:C1466.subForm:=Form:C1466.subForm
					Form:C1466.sfw.lb_items_selectionChange()
			End case 
			Form:C1466.situation.mode:="Modify"
			Form:C1466.sfw.drawButtons()
		End if 
	End if 
	
	
local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	$entry:=cs:C1710.sfw_definitionEntry.new("stepFile"; ["housekeeping"]; "Step File"; "Step Files")
	$entry.setDataclass("StepFile")
	$entry.setDisplayOrder(-100)
	$entry.setIcon("image/entry/step-white-50x50.png")
	
	$entry.setSearchboxField("name")
	
	$entry.setPanel("panel_stepFile")
	$entry.setPanelPage(1; ""; "Steps")
	
	$entry.setLBItemsColumn("customer.name"; "Customer"; "width:170")
	$entry.setLBItemsColumn("name"; "Step File Name"; "width:190")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	$entry.setItemListAction("-"; "-")
	$entry.setItemListAction("Duplicate"; "duplicateStepFileFromList"; "pathIcon:sfw/image/skin/rainbow/icon/duplicate-24x24.png"; "scope:oneOrMoreListItemsSelected")
	
	$entry.setLBItemsOrderBy("name"; False:C215)
	
	$entry.enableTransaction()
	
	$entry.activateEvent("StepFileEvent"; "UUID_StepFile")
	
	$entry.activateComment()
	
	// MARK: -Filters
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterCustomer")
	$filter.setDefaultTitle("All customers")
	$filter.setFilterByLinkedEntity("Customer"; "UUID_Customer"; ""; "customer")
	$filter.setDynamicTitle("name"; "## Customer")
	$entry.addFilter($filter)
	
	