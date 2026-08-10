
Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	//Mark: entry : Equipment
	$entry:=cs:C1710.sfw_definitionEntry.new("equipment"; ["qualityAssurance"]; "Equipments")
	$entry.setDataclass("Equipment")
	$entry.setSearchboxField("assignedID")
	$entry.setDisplayOrder(100)
	$entry.setIcon("image/entry/equipment-white-50x50.png")
	
	$entry.setSearchboxField("assignedID"; "placeholder:ID")
	
	$entry.setPanel("panel_equipment")
	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "Repair Log")
	$entry.setPanelPage(3; ""; "Documents")
	
	$entry.setLBItemsColumn("assignedID"; "Equipment ID"; "width:125")
	$entry.setLBItemsColumn("serialNumber"; "Serial number"; "width:125")
	$entry.setLBItemsColumn("type.name"; "Equipment Type"; "width:200")
	$entry.setLBItemsOrderBy("assignedID")
	
	$entry.setItemListAction("Export equipments list"; "_ga_exportEquipmentList")
	$entry.setItemListAction("-"; "-")
	$entry.setItemListAction("Print equipments list"; "_ga_printEquipmentList")
	$entry.setItemListAction("-"; "-")
	$entry.setItemListAction("Print Cal Sticker"; "_ga_printCalStickers")
	$entry.setItemListAction("-"; "-")
	$entry.setItemListAction("Print PM Sticker"; "_ga_printPMStickers")
	
	$entry.setItemAction("Print Repair Log Report"; "_ga_printRepairLogReport")
	
	$entry.setItemAction("Print Usage Log EquipTraveler"; "_ga_usageLogReport")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	
	$entry.activateEvent("EquipmentEvent"; "UUID_Equipment")
	
	$entry.setLinkManyToOneToTrackInModificationEvent("EquipmentLocation"; "UUID_EquipmentLocation"; "location.name")
	$entry.setLinkManyToOneToTrackInModificationEvent("ToolType"; "UUID_ToolType"; "type.name")
	$entry.setLinkManyToOneToTrackInModificationEvent("Division"; "UUID_Division"; "division.name")
	
	//$entry.setAttributesToTrackInModificationEvent("Equipment"; "reports"; "reports.documents")
	//$entry.setAttributesToTrackInModificationEvent("currentNextStep")
	
	//$entry.setEventOptions("dontCreateModifyEventIfNoTrackingAttribute")
	
	//$entry.setAttributesToTrackInModificationEvent("customerUID"; "name"; "completeName")
	
	$entry.enableTransaction()
	
	
	// MARK: -Filters
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterEquipmentLocation")
	$filter.setDefaultTitle("All locations")
	$filter.setFilterByLinkedEntity("EquipmentLocation"; "UUID_EquipmentLocation"; ""; "location")
	$filter.setDynamicTitle("name"; "## equipment location")
	$entry.addFilter($filter)
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterEquipmentType")
	$filter.setDefaultTitle("All types")
	$filter.setFilterByLinkedEntity("ToolType"; "UUID_ToolType"; ""; "type")
	$filter.setDynamicTitle("name"; "## equipment type")
	$entry.addFilter($filter)
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterEquipmentDivision")
	$filter.setDefaultTitle("All divisions")
	$filter.setFilterByLinkedEntity("Division"; "UUID_Division"; ""; "division")
	$filter.setDynamicTitle("name"; "## equipment division")
	$entry.addFilter($filter)
	
	
	
	// MARK: - Views Definition
	
	// MARK: Equipment out of calibration List
	$view:=cs:C1710.sfw_definitionView.new("equipmentsOutOfCalibration"; "Equipments out of calibration"; "derivedFrom:main"; $entry)  //Calibration Overdue
	$view.setSubset("equipmentsOutOfCalibration")
	$entry.setView($view)
	
	// MARK: List of Equipments to be calibrated in X days
	$view:=cs:C1710.sfw_definitionView.new("dueCalibrationEquipments"; "Equipments to be calibrated in X days"; "derivedFrom:main"; $entry)
	$view.setSubset("dueCalibrationEquipments")
	$entry.setView($view)
	
	// MARK: List of Equipments to be calibrated in X days Exclude NPU
	$view:=cs:C1710.sfw_definitionView.new("dueCalibrationEquipmentsExculeNPU"; "Equipments to be calibrated in X days exclude NPU"; "derivedFrom:main"; $entry)
	$view.setSubset("dueCalibrationEquipmentsExculeNPU")
	$entry.setView($view)
	
	// MARK:  List of equipment not requiring calibration
	$view:=cs:C1710.sfw_definitionView.new("calibrationNotRequiredEquipments"; "Equipments not requiring calibration"; "derivedFrom:main"; $entry)
	$view.setSubset("calibrationNotRequiredEquipments")
	$entry.setView($view)
	
	// MARK: Prevent Maintenance equipments within X days
	$view:=cs:C1710.sfw_definitionView.new("pmEquipments"; "Prevent Maintenance within X days"; "derivedFrom:main"; $entry)
	$view.setSubset("pmEquipments")
	$entry.setView($view)
	
	// MARK: Prevent Maintenance equipments within X days Exlude NPU
	$view:=cs:C1710.sfw_definitionView.new("duePMEquipmentsExcludeNPU"; "Prevent Maintenance within X days exclude NPU"; "derivedFrom:main"; $entry)
	$view.setSubset("duePMEquipmentsExcludeNPU")
	$entry.setView($view)
	
	// MARK: NPU Equipments list
	$view:=cs:C1710.sfw_definitionView.new("NPUEquipments"; "NPU Equipments"; "derivedFrom:main"; $entry)
	$view.setSubset("NPUEquipments")
	$entry.setView($view)
	
	// MARK:  List of equipment down
	$view:=cs:C1710.sfw_definitionView.new("equipmentsDownOrOnHold"; "Equipments down"; "derivedFrom:main"; $entry)
	$view.setSubset("equipmentsDownOrOnHold")
	$entry.setView($view)
	
	
	// MARK:  List of equipment Decommissioned
	$view:=cs:C1710.sfw_definitionView.new("decommissionedEquipment"; "Decommissioned Equipments"; "derivedFrom:main"; $entry)
	$view.setSubset("decommissionedEquipment")
	$entry.setView($view)
	
	// MARK:  PM Required Equipements
	$view:=cs:C1710.sfw_definitionView.new("PMRequiredEquipments"; "PM Required"; "derivedFrom:main"; $entry)
	$view.setSubset("PMRequiredEquipments")
	$entry.setView($view)
	
/*
local Function cacheLoad()
	
If (Storage.cache=Null)
Use (Storage)
Storage.cache:=New shared object
End use 
End if 
If (Storage.cache.startDate=Null)
Use (Storage.cache)
Storage.cache.startDate:=Current date()
End use 
End if 
If (Storage.cache.endDate=Null)
Use (Storage.cache)
Storage.cache.endDate:=Current date()
End use 
End if 
If (Undefined(Storage.cache.interval))
Use (Storage.cache)
Storage.cache.interval:="0"
End use 
End if 
	
	
local Function setDateInterval($pushUp; $title)
This.cacheLoad()
	
$form:=New object
$form.startDate:=Storage.cache.startDate
$form.endDate:=Storage.cache.endDate
$form.interval:=Storage.cache.interval
MOUSE POSITION($mouseX; $mouseY; $mouseButtons)
CONVERT COORDINATES($mouseX; $mouseY; XY Current form; XY Main window)
If ($pushUp)
$mouseY:=$mouseY-190
$mouseX:=$mouseX-100
End if 
$form.pushUp:=$pushUp
$windRef:=Open window($mouseX; $mouseY; $mouseX+270; $mouseY+165; Movable dialog box; "Set date interval")
DIALOG("_ga_setDateInterval"; $form)
CLOSE WINDOW($windRef)
Use (Storage.cache)
Storage.cache.startDate:=$form.startDate
Storage.cache.endDate:=$form.endDate
Storage.cache.interval:=$form.interval
End use 
*/
	
local Function equipmentsOutOfCalibration()->$equipments : cs:C1710.EquipmentSelection  //Calibration Overdue
	$equipments:=ds:C1482.Equipment.query("nextCalDate<=:1 & calibrationNotRequired=:2 & notAtSite=:3"; Current date:C33(*); False:C215; False:C215)  // Storage.cache.endDate
	
local Function dueCalibrationEquipments()->$equipments : cs:C1710.EquipmentSelection  //List of equip to be calibrated within X days
	cs:C1710.Util.me.setDateInterval(False:C215)
	$equipments:=ds:C1482.Equipment.query("nextCalDate<=:1  & nextCalDate>:2 & notAtSite=:3"; Storage:C1525.cache.endDate; Current date:C33(*); False:C215)
	
local Function dueCalibrationEquipmentsExculeNPU()->$equipments : cs:C1710.EquipmentSelection  //List of equip to be calibrated within X days exclude NPU 
	cs:C1710.Util.me.setDateInterval(False:C215)
	$equipments:=ds:C1482.Equipment.query("nextCalDate<=:1 & nextCalDate>:2 & notAtSite=:3 & engg=:4"; Storage:C1525.cache.endDate; Current date:C33(*); False:C215; False:C215)
	
local Function calibrationNotRequiredEquipments()->$equipments : cs:C1710.EquipmentSelection
	$equipments:=ds:C1482.Equipment.query("calibrationNotRequired=:1"; True:C214)
	
local Function PMRequiredEquipments()->$equipments : cs:C1710.EquipmentSelection  //PM Required Equipments
	$equipments:=ds:C1482.Equipment.query("nextPMDate<=:1 & nextPMDate#:2 & notAtSite=:3"; Current date:C33(*); !00-00-00!; False:C215)  // Storage.cache.endDate
	
local Function pmEquipments()->$equipments : cs:C1710.EquipmentSelection  //Prevent Maintenance equipments within X days
	cs:C1710.Util.me.setDateInterval(False:C215)
	// Apr 22, 2026 4DFix: placeholder :3 was used twice for both nextPMDate# and notAtSite — notAtSite now uses :4
	$equipments:=ds:C1482.Equipment.query("nextPMDate<=:1 & nextPMDate>:2 & nextPMDate#:3 & notAtSite=:4"; Storage:C1525.cache.endDate; Current date:C33(*); !00-00-00!; False:C215)
	
local Function duePMEquipmentsExcludeNPU()->$equipments : cs:C1710.EquipmentSelection  //Prevent Maintenance equipments within X days exclude NPU
	cs:C1710.Util.me.setDateInterval(False:C215)
	// Apr 22, 2026 4DFix: placeholder :2 was used twice for nextPMDate>:2 and nextPMDate#:2 with different intended values
	// (Current date vs !00-00-00!). Added :3 for !00-00-00!, shifted notAtSite to :4 and engg to :5
	$equipments:=ds:C1482.Equipment.query("nextPMDate<=:1 & nextPMDate>:2 & nextPMDate#:3 & notAtSite=:4 & engg=:5"; Storage:C1525.cache.endDate; Current date:C33(*); !00-00-00!; False:C215; False:C215)
	
local Function NPUEquipments()->$equipments : cs:C1710.EquipmentSelection  //NPU List
	$equipments:=ds:C1482.Equipment.query("notAtSite=:1 & engg=:2"; False:C215; True:C214)
	
local Function equipmentsDownOrOnHold()->$equipments : cs:C1710.EquipmentSelection
	$equipments:=ds:C1482.Equipment.query("down=:1"; True:C214)
	
local Function decommissionedEquipment()->$equipments : cs:C1710.EquipmentSelection
	$equipments:=ds:C1482.Equipment.query("decommissioned=:1"; True:C214)
	
	
	
	