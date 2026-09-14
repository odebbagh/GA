Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	//Mark: entry : Specification
	$entry:=cs:C1710.sfw_definitionEntry.new("specification"; ["qualityAssurance"]; "Document Control")
	$entry.setDataclass("Specification")
	$entry.setDisplayOrder(-500)
	$entry.setIcon("image/entry/spec-control-white-50x50.png")
	
	$entry.setSearchboxField("spec")
	
	$entry.setPanel("panel_specification")
	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "Documents")
	
	$entry.setLBItemsColumn("spec"; "Spec#"; "width:100")
	$entry.setLBItemsColumn("revision"; "Revision"; "width:50")
	$entry.setLBItemsColumn("title"; "Title")
	$entry.setLBItemsOrderBy("spec")
	//$entry.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:specification"; "unitN:specifications")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	$entry.setItemListAction("Export The List To Excel"; "_ga_exportSpecToExcel")
	$entry.setItemListAction("-"; "-")
	$entry.setItemListAction("Print The List"; "_ga_printSpecList")
	
	
	
	// MARK: -Filters
	
	
	// Purpose: Filter by DocumentCategory via UUID_DocumentCategory (replaced broken SpecCategory / categoryID reference).
	// modified by 4D/PS [2026-june-08]
	$filter:=cs:C1710.sfw_definitionFilter.new("filterSpecDocumentType")
	$filter.setDefaultTitle("All Types")
	$filter.setFilterByLinkedEntity("DocumentCategory"; "UUID_DocumentCategory"; ""; "")
	$filter.setDynamicTitle("name"; "## document type")
	$entry.addFilter($filter)
	
	// Apr 22, 2026 4DFix: duplicate filter ident "filterSpecDocumentType" was colliding with the first filter — renamed to "filterSpecDepartment"
	$filter:=cs:C1710.sfw_definitionFilter.new("filterSpecDepartment")
	$filter.setDefaultTitle("All departments")
	$filter.setFilterByIDInTable("SpecControllingDept"; "departmentID"; "departmentID")
	$filter.setDynamicTitle("name"; "## controlling department")
	$entry.addFilter($filter)
	
	
	
	// MARK: - Views Definition
	
	
	// MARK: Docs late in reviewing
	$view:=cs:C1710.sfw_definitionView.new("docsLateInReviewing"; "Control Docs late in Reviewing")
	$view.setLBItemsColumn("spec"; "Spec#"; "width:100")
	$view.setLBItemsColumn("revision"; "Revision"; "width:50")
	$view.setLBItemsColumn("title"; "Title")
	$view.setLBItemsOrderBy("spec")
	$view.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:specification"; "unitN:specifications")
	$view.setSubset("docsLateInReviewing")
	$entry.setView($view)
	
	// MARK: Docs requiring review in 7 days
	$view:=cs:C1710.sfw_definitionView.new("docsRequiringReviewSoon"; "Control Docs requiring review in X days")
	$view.setLBItemsColumn("spec"; "Spec#"; "width:100")
	$view.setLBItemsColumn("revision"; "Revision"; "width:50")
	$view.setLBItemsColumn("title"; "Title")
	$view.setLBItemsOrderBy("spec")
	$view.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:specification"; "unitN:specifications")
	$view.setSubset("docsRequiringReviewSoon")
	$entry.setView($view)
	
	// MARK: Specs
	$view:=cs:C1710.sfw_definitionView.new("OnlySpecs"; "Specs")
	$view.setLBItemsColumn("spec"; "Spec#"; "width:100")
	$view.setLBItemsColumn("revision"; "Revision"; "width:50")
	$view.setLBItemsColumn("title"; "Title")
	$view.setLBItemsOrderBy("spec")
	$view.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:specification"; "unitN:specifications")
	$view.setSubset("OnlySpecs")
	$entry.setView($view)
	
	// MARK: Forms
	$view:=cs:C1710.sfw_definitionView.new("OnlyForms"; "Forms")
	$view.setLBItemsColumn("spec"; "Spec#"; "width:100")
	$view.setLBItemsColumn("revision"; "Revision"; "width:50")
	$view.setLBItemsColumn("title"; "Title")
	$view.setLBItemsOrderBy("spec")
	$view.setLBItemsCounter("###,###,##0 ^1;;"; "unit1:specification"; "unitN:specifications")
	$view.setSubset("OnlyForms")
	$entry.setView($view)
	
	
	
	
	
	// MARK: - Query Functions
	
	
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
	
	
Function docsLateInReviewing()->$specifications : cs:C1710.SpecificationSelection
	//$specifications:=ds.Specification.query("suppress =:1 & reviewIntervalInDays >0 & eval(reviewDate+reviewIntervalInDays)<Current date(*)"; False)
	$startDate:=Current date:C33()
	$formula_1:=Formula:C1597((This:C1470.reviewDate+This:C1470.reviewIntervalInDays)<$startDate)
	$specifications:=This:C1470.myQuery(False:C215; 0; $formula_1)
	
local Function docsRequiringReviewSoon()->$specifications : cs:C1710.SpecificationSelection
	$title:="Set date interval"
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	Use (Storage:C1525.cache)
		Storage:C1525.cache.startDate:=Current date:C33()
	End use 
	cs:C1710.Util.me.setDateInterval(False:C215; $title)
	$startDate:=Storage:C1525.cache.startDate
	$endDate:=Storage:C1525.cache.endDate
	$formula_1:=Formula:C1597((This:C1470.reviewDate+This:C1470.reviewIntervalInDays)>=$startDate)
	$formula_2:=Formula:C1597((This:C1470.reviewDate+This:C1470.reviewIntervalInDays)<$endDate)
	$specifications:=This:C1470.myQuery(False:C215; 0; $formula_1; $formula_2)  //ds.Specification.query("suppress =:1 & reviewIntervalInDays >0 & :2 & :3"; False; $formula_1; $formula_2)
	
	
	
Function OnlySpecs()->$specifications : cs:C1710.SpecificationSelection
	$specifications:=ds:C1482.Specification.query("isForm=:1"; False:C215)
	
	
Function OnlyForms()->$specifications : cs:C1710.SpecificationSelection
	$specifications:=ds:C1482.Specification.query("isForm=:2"; True:C214)
	
	
Function myQuery($param1 : Boolean; $param2 : Integer;  ...  : Object)->$specifications : cs:C1710.SpecificationSelection
	$nbrsOfParameters:=Count parameters:C259
	Case of 
			
		: ($nbrsOfParameters=3)
			$specifications:=ds:C1482.Specification.query("isForm =:1 & reviewIntervalInDays > :2 & :3"; $1; $2; $3)
			
		: ($nbrsOfParameters=4)
			$specifications:=ds:C1482.Specification.query("isForm =:1 & reviewIntervalInDays > :2 & :3 & :4"; $1; $2; $3; $4)
			
			
		Else 
			
	End case 