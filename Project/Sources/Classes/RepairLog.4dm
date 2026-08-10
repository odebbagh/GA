Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	//Mark: entry : Contact
	$entry:=cs:C1710.sfw_definitionEntry.new("repairLog"; ["qualityAssurance"]; "Repair Logs")
	$entry.setDataclass("RepairLog")
	
	$entry.setDisplayOrder(100)
	$entry.setIcon("image/entry/repairLog-50x50.png")
	
	$entry.setSearchboxField("equipment.assignedID"; "placeholder:equipmentID")
	
	$entry.setPanel("panel_repairLog")
	$entry.setPanelPage(1; ""; "Main")
	
	$entry.setLBItemsColumn("equipment.assignedID"; "Equipment ID"; "width:200")
	$entry.setLBItemsColumn("reportID"; "Report ID"; "width:150")
	$entry.setLBItemsColumn("fixedDate#!00-00-00-!"; "Fixed"; "type:boolean"; "orderByFormula:Bool(this.fixedDate#!00-00-00-!)"; "width:100")
	$entry.setLBItemsOrderBy("equipment.assignedID")
	$entry.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:repairLog"; "unitN:repairLogs")
	
	$entry.enableTransaction()
	
	$entry.setItemListAction("Export the list"; "_ga_exportRepairLogList")
	$entry.setItemListAction("-"; "-")
	$entry.setItemListAction("Print the list"; "_ga_printRepairLogList")
	$entry.setItemListAction("-"; "-")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	
	// MARK: -Filters
	
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterFixOperator")
	$filter.setDefaultTitle("All Fix Operators")
	$filter.setFilterByLinkedEntity("Staff"; "UUID_Fixer"; "uuidStaff"; "")
	$filter.setDynamicTitle("code"; "## Fixed by")
	$filter.setOrderForItems("code")
	$filter.setAttributeLabelForItem("code")
	$entry.addFilter($filter)
	
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterReportOperator")
	$filter.setDefaultTitle("All Report Operators")
	$filter.setFilterByLinkedEntity("Staff"; "UUID_Reporter"; "uuidStaff"; "")
	$filter.setDynamicTitle("code"; "## Reported by")
	$filter.setOrderForItems("code")
	$filter.setAttributeLabelForItem("code")
	$entry.addFilter($filter)
	
	
	// Apr 22, 2026 4DFix: duplicate filter ident "filterReportOperator" was causing the second filter to collide/overwrite the first
	$filter:=cs:C1710.sfw_definitionFilter.new("filterEquipment")
	$filter.setDefaultTitle("All Equipments")
	$filter.setFilterByLinkedEntity("Equipment"; "UUID_Equipment"; "uuidEquipment"; "")
	$filter.setDynamicTitle("assignedID"; "## equipments")
	$filter.setOrderForItems("assignedID")
	$filter.setAttributeLabelForItem("assignedID")
	$entry.addFilter($filter)
	
	
	
	// MARK: - Views Definition
	
	// MARK: Cuurent problem - Not yet solved problems
	$view:=cs:C1710.sfw_definitionView.new("currentProblems"; "Open problems")
	$view.setLBItemsColumn("equipment.assignedID"; "Equipment ID"; "width:200")
	$view.setLBItemsColumn("reportID"; "Report ID"; "width:150")
	$view.setLBItemsColumn("fixedDate#!00-00-00-!"; "Fixed"; "type:boolean"; "orderByFormula:Bool(this.fixedDate#!00-00-00-!)"; "width:100")
	$view.setLBItemsOrderBy("equipment.assignedID")
	$view.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:repairLog"; "unitN:repairLogs")
	$view.setSubset("currentProblems")
	$entry.setView($view)
	
	// MARK: Problems by interval
	$view:=cs:C1710.sfw_definitionView.new("problemsByInterval"; "Problems by interval")
	$view.setLBItemsColumn("equipment.assignedID"; "Equipment ID"; "width:200")
	$view.setLBItemsColumn("reportID"; "Report ID"; "width:150")
	$view.setLBItemsColumn("fixedDate#!00-00-00-!"; "Fixed"; "type:boolean"; "orderByFormula:Bool(this.fixedDate#!00-00-00-!)"; "width:100")
	$view.setLBItemsOrderBy("equipment.assignedID")
	$view.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:repairLog"; "unitN:repairLogs")
	$view.setSubset("problemsByInterval")
	$entry.setView($view)
	
	// MARK: Due calibration List
	$view:=cs:C1710.sfw_definitionView.new("repairsByInterval"; "Repairs by interval")
	$view.setLBItemsColumn("equipment.assignedID"; "Equipment ID"; "width:200")
	$view.setLBItemsColumn("reportID"; "Report ID"; "width:150")
	$view.setLBItemsColumn("fixedDate#!00-00-00-!"; "Fixed"; "type:boolean"; "orderByFormula:Bool(this.fixedDate#!00-00-00-!)"; "width:100")
	$view.setLBItemsOrderBy("equipment.assignedID")
	$view.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:repairLog"; "unitN:repairLogs")
	$view.setSubset("repairsByInterval")
	$entry.setView($view)
	
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.startDate=Null:C1517)
		Use (Storage:C1525.cache)
			Storage:C1525.cache.startDate:=Current date:C33()
		End use 
	End if 
	If (Storage:C1525.cache.endDate=Null:C1517)
		Use (Storage:C1525.cache)
			Storage:C1525.cache.endDate:=Current date:C33()
		End use 
	End if 
	If (Undefined:C82(Storage:C1525.cache.interval))
		Use (Storage:C1525.cache)
			Storage:C1525.cache.interval:="0"
		End use 
	End if 
	
	
local Function setDateInterval($pushUp; $title)
	This:C1470.cacheLoad()
	
	$form:=New object:C1471
	$form.startDate:=Storage:C1525.cache.startDate
	$form.endDate:=Storage:C1525.cache.endDate
	$form.interval:=Storage:C1525.cache.interval
	MOUSE POSITION:C468($mouseX; $mouseY; $mouseButtons)
	CONVERT COORDINATES:C1365($mouseX; $mouseY; XY Current form:K27:5; XY Main window:K27:8)
	If ($pushUp)
		$mouseY:=$mouseY-190
		$mouseX:=$mouseX-100
	End if 
	$form.pushUp:=$pushUp
	$windRef:=Open window:C153($mouseX; $mouseY; $mouseX+270; $mouseY+165; Movable dialog box:K34:7; $title)
	DIALOG:C40("_ga_setDateInterval"; $form)
	CLOSE WINDOW:C154($windRef)
	Use (Storage:C1525.cache)
		Storage:C1525.cache.startDate:=$form.startDate
		Storage:C1525.cache.endDate:=$form.endDate
		Storage:C1525.cache.interval:=$form.interval
	End use 
	
	
	
local Function currentProblems()->$selection : cs:C1710.RepairLogSelection
	$selection:=ds:C1482.RepairLog.query("reportDate#:1 & fixedDate=:2"; !00-00-00!; !00-00-00!)
	
	
local Function problemsByInterval()->$selection : cs:C1710.RepairLogSelection
	$title:="Set date interval"
	cs:C1710.Util.me.setDateInterval(False:C215; $title)
	$selection:=ds:C1482.RepairLog.query("reportDate>=:1 & reportDate<=:2"; Storage:C1525.cache.startDate; Storage:C1525.cache.endDate)
	
	
local Function repairsByInterval()->$selection : cs:C1710.RepairLogSelection
	$title:="Set date interval"
	cs:C1710.Util.me.setDateInterval(False:C215; $title)
	$selection:=ds:C1482.RepairLog.query("fixedDate>=:1 & fixedDate<=:2"; Storage:C1525.cache.startDate; Storage:C1525.cache.endDate)
	
	
	
	
	
	