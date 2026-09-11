property globalParameters : Object

Class extends sfw_definitionBuilder

Class constructor
	
	Super:C1705()
	This:C1470._visions_definition()
	This:C1470._entries_definition()
	This:C1470._event_definition()
	This:C1470._scheduler_definition()
	This:C1470._notification_definition()
	This:C1470._profiles_definition()
	This:C1470._documentFolders_definition()
	
Function _global_parameters()
	
	This:C1470.globalParameters:=New object:C1471
	This:C1470.globalParameters.toolbar:=New object:C1471("visionsLogo"; "/RESOURCES/image/logo/golden_atos_100x25.png"; "visionsLogoLocal"; "/RESOURCES/image/logo/golden_atos_100x25.png")
	This:C1470.globalParameters.toolbar.entryIconsResize:=True:C214
	This:C1470.globalParameters.panel:=New object:C1471("defaultLogo"; "/RESOURCES/image/logo/logoGATransparent.png"; "defaultLogoLocal"; "/RESOURCES/image/logo/logoGATransparent.png")
	This:C1470.globalParameters.users:=New object:C1471("passwordLength"; 12)
	This:C1470.globalParameters.users.linkedDataclass:="Staff"
	This:C1470.globalParameters.users.linkedObject:="staff"
	This:C1470.globalParameters.users.linkedPathToNameFromUserEntity:="staffs.first().fullName"
	This:C1470.globalParameters.users.linkedPathToEmailFromUserEntity:="staffs.first().email"
	This:C1470.globalParameters.folders:=New object:C1471("projectResources"; "ga")
	This:C1470.globalParameters.address:=New object:C1471("defaultCountry"; "us")
	This:C1470.globalParameters.preferedCountriesInPup:=New collection:C1472("ma"; "fr"; "us")
	
	This:C1470.globalParameters.microsoftGraphAPI:=New object:C1471()
	This:C1470.globalParameters.microsoftGraphAPI.clientId:="08c8a78e-8ad9-4bd7-b24f-73d590be281b"
	This:C1470.globalParameters.microsoftGraphAPI.tenant:="06dc191b-7348-4b66-b0d9-806cb7d9455b"
	This:C1470.globalParameters.microsoftGraphAPI.scope:="offline_access https://graph.microsoft.com/.default"
	This:C1470.globalParameters.microsoftGraphAPI.userId:="noreply.goldenAltos@4d.com"
	This:C1470.globalParameters.mail:=New object:C1471("sender"; "noreply.goldenAltos@4d.com")
	
	
	This:C1470.globalParameters.notifications:=New object:C1471("activate"; True:C214)
	
	This:C1470.globalParameters.documentsStorageOnServer:=New object:C1471
	This:C1470.globalParameters.documentsStorageOnServer.folder:=Folder:C1567(Folder:C1567(fk data folder:K87:12).platformPath; fk platform path:K87:2).parent.folder("DocumentData")
	
	This:C1470.globalParameters.dfd:=New object:C1471
	This:C1470.globalParameters.dfd.visionAllowedProfiles:=["admin"; "pm"]
	This:C1470.globalParameters.dfd.entryDocument:=New object:C1471
	This:C1470.globalParameters.dfd.entryDocument.allowedProfiles:=["admin"; "pm"]
	This:C1470.globalParameters.dfd.entryDocument.allowedProfilesForCreation:=["admin"; "pm"]
	
Function _event_definition()
	
	//cs.sfw_eventManager.me.createIfNotExist("addSkill"; "Add skill to a staff")
	//cs.sfw_eventManager.me.createIfNotExist("closeSkill"; "Close a skill for a staff")
	//cs.sfw_eventManager.me.createIfNotExist("startSkill"; "Start a skill for a staff")
	
	//// phase
	//cs.sfw_eventManager.me.createIfNotExist("addPhase"; "Add phase to project")
	//cs.sfw_eventManager.me.createIfNotExist("renamePhase"; "Rename a phase of project")
	//cs.sfw_eventManager.me.createIfNotExist("modifyPhase"; "Modify aphase of project")
	//cs.sfw_eventManager.me.createIfNotExist("deletePhase"; "Delete a phase from project")
	
	//// lot
	//cs.sfw_eventManager.me.createIfNotExist("addLot"; "Add lot to phase")
	//cs.sfw_eventManager.me.createIfNotExist("renameLot"; "Rename lot in phase")
	//cs.sfw_eventManager.me.createIfNotExist("modifyLot"; "Modify lot in phase")
	//cs.sfw_eventManager.me.createIfNotExist("deleteLot"; "Delete lot from phase")
	//cs.sfw_eventManager.me.createIfNotExist("moveLotUp"; "Move lot up in phase")
	//cs.sfw_eventManager.me.createIfNotExist("moveLotDown"; "Move lot down in phase")
	
	//// task
	//cs.sfw_eventManager.me.createIfNotExist("addTask"; "Add task to lot")
	//cs.sfw_eventManager.me.createIfNotExist("modifyTask"; "Modify task in lot")
	//cs.sfw_eventManager.me.createIfNotExist("deleteTask"; "Delete task from lot")
	
	//// taskTime
	//cs.sfw_eventManager.me.createIfNotExist("addTaskTime"; "Add task time")
	//cs.sfw_eventManager.me.createIfNotExist("modifyTaskTime"; "Modify task time")
	//cs.sfw_eventManager.me.createIfNotExist("deleteTaskTime"; "Delete task time")
	
	////KeyDate
	//cs.sfw_eventManager.me.createIfNotExist("addKeyDate"; "Add keyDate")
	//cs.sfw_eventManager.me.createIfNotExist("modifyKeyDate"; "Modify keyDate")
	//cs.sfw_eventManager.me.createIfNotExist("deleteKeyDate"; "Delete keyDate")
	
	////progress report
	//cs.sfw_eventManager.me.createIfNotExist("addProgressReport"; "Add progress report")
	//cs.sfw_eventManager.me.createIfNotExist("modifyProgressReport"; "Modify progress report")
	//cs.sfw_eventManager.me.createIfNotExist("deleteProgressReport"; "Delete progress report")
	
	
	//// customerTime
	//cs.sfw_eventManager.me.createIfNotExist("addCustomerTime"; "Add customer time")
	//cs.sfw_eventManager.me.createIfNotExist("modifyCustomerTime"; "Modify customer time")
	//cs.sfw_eventManager.me.createIfNotExist("deleteCustomerTime"; "Delete customer time")
	
	//// meetingTime
	//cs.sfw_eventManager.me.createIfNotExist("addMeetingTime"; "Add meeting time")
	//cs.sfw_eventManager.me.createIfNotExist("modifyMeetingTime"; "Modify meeting time")
	//cs.sfw_eventManager.me.createIfNotExist("deleteMeetingTime"; "Delete meeting time")
	
	//// adminTime
	//cs.sfw_eventManager.me.createIfNotExist("addAdminTime"; "Add administrative time")
	//cs.sfw_eventManager.me.createIfNotExist("modifyAdminTime"; "Modify administrative time")
	//cs.sfw_eventManager.me.createIfNotExist("deleteAdminTime"; "Delete administrative time")
	
	
	//Documents
	cs:C1710.sfw_eventManager.me.createIfNotExist("addDocument"; "Add a document")
	cs:C1710.sfw_eventManager.me.createIfNotExist("modifyDocument"; "Modify a document")
	cs:C1710.sfw_eventManager.me.createIfNotExist("deleteDocument"; "Delete a document")
	
	
	
Function _scheduler_definition()
	var $periodicity : cs:C1710.sfw_definitionScheduler
	
	$periodicity:=cs:C1710.sfw_definitionScheduler.new("daily")
	$periodicity.setHourToStart(3)
	$periodicity.setMinuteToStart(33)
	$periodicity.setDayNumbers(Monday:K10:13; Tuesday:K10:14; Wednesday:K10:15; Thursday:K10:16; Friday:K10:17)
	cs:C1710.sfw_schedulerManager.me.createIfNotExist("CertificationRetraining"; "Retraining due within 30 days"; $periodicity; "TestSchedule"; "CheckCertificationRetraining"; False:C215)
	
	
	//$periodicity:=cs.sfw_definitionScheduler.new("hourly")
	//$periodicity.setMinuteToStart(5)
	//$periodicity.setHourMinMax(9; 18)
	//cs.sfw_schedulerManager.me.createIfNotExist("test"; "test scheduler"; $periodicity; "testForScheduler"; "HelloIsTime"; False)
	
	//$periodicity:=cs.sfw_definitionScheduler.new("daily")
	//$periodicity.setHourToStart(11)
	//$periodicity.setMinuteToStart(0)
	//$periodicity.setDayNumbers(Monday; Tuesday; Wednesday; Thursday; Friday)
	//cs.sfw_schedulerManager.me.createIfNotExist("test2"; "test scheduler2"; $periodicity; "testForScheduler"; "HelloIsTimeandDay"; False)
	
	//$periodicity:=cs.sfw_definitionScheduler.new("weekly")
	//$periodicity.setHourToStart(11)
	//$periodicity.setMinuteToStart(10)
	//$periodicity.setDayNumber(Tuesday)
	//cs.sfw_schedulerManager.me.createIfNotExist("test3"; "test scheduler3"; $periodicity; "testForScheduler"; "HelloisWeek"; False)
	
	//$periodicity:=cs.sfw_definitionScheduler.new("hourly")
	//$periodicity.setMinutesToStart([0; 15; 30; 45])
	//cs.sfw_schedulerManager.me.createIfNotExist("microsoftAPIGraph_refreshToken"; "Refresh Token of Microsoft API Graph"; $periodicity; "microsoftGraphAPI"; "getToken"; True)
	
	
Function _notification_definition()
	var $definition : cs:C1710.sfw_definitionNotificationType
	
	$definition:=cs:C1710.sfw_definitionNotificationType.new()
	$definition.setDescription("Retraining due within 30 days.")
	$definition.setActive()
	cs:C1710.sfw_notificationManager.me.createTypeIfNotExist("CertificationRetraining"; "Retraining due within 30 days"; $definition)
	
	$definition:=cs:C1710.sfw_definitionNotificationType.new()
	$definition.setDescription("Equipment ##assignedID## is down. Immediate action required.")
	$definition.setActive()
	cs:C1710.sfw_notificationManager.me.createTypeIfNotExist("EquipmentDown"; "Equipment is down"; $definition)
	
	$definition:=cs:C1710.sfw_definitionNotificationType.new()
	$definition.setDescription("Calibration for the equipment ##assignedID## is due in 30 days. Action required")
	$definition.setActive()
	cs:C1710.sfw_notificationManager.me.createTypeIfNotExist("EquipmentSoonDueCalibration"; "Equipment out of calibration in 30 days"; $definition)
	
	$definition:=cs:C1710.sfw_definitionNotificationType.new()
	$definition.setDescription("Equipment ##assignedID## calibration overdue.Immediate action is required")
	$definition.setActive()
	cs:C1710.sfw_notificationManager.me.createTypeIfNotExist("DueEquipmentOutOfCalibration"; "Due Equipment out of calibration"; $definition)
	
	$definition:=cs:C1710.sfw_definitionNotificationType.new()
	$definition.setDescription("Preventive maintenance for the equipment ##assignedID## is due in 30 days. Action required")
	$definition.setActive()
	cs:C1710.sfw_notificationManager.me.createTypeIfNotExist("EquipmentSoonDuePM"; "Equipment out of PM in 30 days"; $definition)
	
	$definition:=cs:C1710.sfw_definitionNotificationType.new()
	$definition.setDescription("Preventive maintenance overdue for equipment ##assignedID##. Immediate action is required")
	$definition.setActive()
	cs:C1710.sfw_notificationManager.me.createTypeIfNotExist("DueEquipmentOutOfPM"; "Due Equipment out of PM"; $definition)
	
	$definition:=cs:C1710.sfw_definitionNotificationType.new()
	// Purpose: Employee-facing — linked sfw_User only (retrain milestone or validity expiry within ##days## days).
	// modified by 4D/PS [2026-june-12]
	$definition.setDescription("Your certification ##certName## is due on ##expiringDate## (within ##days## days). Please schedule re-training.")
	$definition.setActive()
	cs:C1710.sfw_notificationManager.me.createTypeIfNotExist("EmployeeRetrainRequired"; "Certification re-training or expiry reminder"; $definition)
	
	$definition:=cs:C1710.sfw_definitionNotificationType.new()
	$definition.setDescription("Critical supplier ##name## audits pending. Schedule immediately")
	$definition.setActive()
	cs:C1710.sfw_notificationManager.me.createTypeIfNotExist("CriticalSuppliersWithOverdueAudits"; "Critical suppliers with overdue audits"; $definition)
	
	$definition:=cs:C1710.sfw_definitionNotificationType.new()
	$definition.setDescription("With ##Contact## On ##Followupdate## Due To ##Trigger##")
	$definition.setActive()
	cs:C1710.sfw_notificationManager.me.createTypeIfNotExist("InteractionScheduled"; "Interaction Scheduled"; $definition)
	
	$definition:=cs:C1710.sfw_definitionNotificationType.new()
	$definition.setDescription("Specification ##spec## review overdue.Immediate action is required")
	$definition.setActive()
	cs:C1710.sfw_notificationManager.me.createTypeIfNotExist("SpecReviewOverdue"; "Specs review overdue"; $definition)
	
	$definition:=cs:C1710.sfw_definitionNotificationType.new()
	$definition.setDescription("Specification ##spec## QA pending approval.Action required")
	$definition.setActive()
	cs:C1710.sfw_notificationManager.me.createTypeIfNotExist("SpecControlApproval"; "Specs Control Approval"; $definition)
	
	
	//Mark:-Visions defintion
Function _visions_definition()
	var $vision : cs:C1710.sfw_definitionVision
	
	$vision:=cs:C1710.sfw_definitionVision.new("customerService"; "Customer service")
	$vision.setToolbarBackgroundColor("#52ABD8")
	$vision.setFocusRingColor("navy")
	$vision.setIcon("image/vision/customer-service-24x24.png")
	This:C1470._push_vision($vision)
	
	$vision:=cs:C1710.sfw_definitionVision.new("housekeeping"; "Housekeeping")
	$vision.setToolbarBackgroundColor("SlateBlue")
	$vision.setFocusRingColor("darkred")
	$vision.setIcon("image/vision/housekeeping-24x24.png")
	This:C1470._push_vision($vision)
	
	$vision:=cs:C1710.sfw_definitionVision.new("production"; "Production")
	$vision.setToolbarBackgroundColor("OliveDrab")
	$vision.setFocusRingColor("darkred")
	$vision.setIcon("image/vision/production-24x24.png")
	This:C1470._push_vision($vision)
	
	$vision:=cs:C1710.sfw_definitionVision.new("qualityAssurance"; "Quality Assurance")
	$vision.setToolbarBackgroundColor("DarkCyan")
	$vision.setFocusRingColor("darkred")
	$vision.setIcon("image/vision/quality-assurance-24x24.png")
	//$vision.setAllowedProfiles("qm")
	This:C1470._push_vision($vision)
	
	// Purpose: Dedicated vision for Equipment and Repair Logs (moved out of Quality Assurance).
	// modified by 4D/PS [2026-september-11]
	$vision:=cs:C1710.sfw_definitionVision.new("facilities"; "Facilities")
	$vision.setToolbarBackgroundColor("SlateBlue")
	$vision.setFocusRingColor("darkred")
	$vision.setIcon("image/vision/facility-management-24x24.png")
	//$vision.setAllowedProfiles("qm")
	This:C1470._push_vision($vision)
	
	$vision:=cs:C1710.sfw_definitionVision.new("salesAndQuotes"; "Sales & Quotes")
	$vision.setToolbarBackgroundColor("DarkCyan")
	$vision.setFocusRingColor("darkred")
	$vision.setIcon("image/vision/sales-and-quotes-24x24.png")
	//$vision.setAllowedProfiles("qm")
	This:C1470._push_vision($vision)
	
	$vision:=cs:C1710.sfw_definitionVision.new("buying"; "Buying")
	$vision.setToolbarBackgroundColor("SteelBlue")
	$vision.setFocusRingColor("darkred")
	$vision.setIcon("image/vision/buying-24x24.png")
	This:C1470._push_vision($vision)
	
	$vision:=cs:C1710.sfw_definitionVision.new("receiving"; "Receiving")
	$vision.setToolbarBackgroundColor("SteelBlue")
	$vision.setFocusRingColor("darkred")
	$vision.setIcon("image/vision/receiving-24x24.png")
	This:C1470._push_vision($vision)
	
	$vision:=cs:C1710.sfw_definitionVision.new("accounting"; "Accounting")
	$vision.setToolbarBackgroundColor("#20B2AA")
	$vision.setFocusRingColor("navy")
	$vision.setIcon("image/vision/accounting-24x24.png")
	This:C1470._push_vision($vision)
	
	
	
	//Mark:-Entries defintion
Function _entries_definition()
	
	//Customer Service - Vendor
	
	$entry:=cs:C1710.sfw_definitionEntry.new("vendor"; ["buying"]; "Vendors")
	$entry.setDataclass("Customer")
	$entry.setDisplayOrder(-390)
	$entry.setIcon("image/entry/customers-white-50x50.png")
	
	$entry.setSubset("vendors")
	
	$entry.setSearchboxField("name")
	
	$entry.setPanel("panel_vendor")
	$entry.setPanelPage(1; ""; "Main")
	
	$entry.setLBItemsColumn("name"; "Lot #"; "width:80")
	
	$entry.setLBItemsOrderBy("name")
	$entry.enableTransaction()
	
	This:C1470._push_entry($entry)
	
	
	//Receiving - Buy Orders
	
	$entry:=cs:C1710.sfw_definitionEntry.new("BuyOrders"; ["receiving"]; "Buy Orders")
	$entry.setDataclass("BuyingOrderLine")
	$entry.setDisplayOrder(200)
	$entry.setIcon("image/entry/punsh-in-50x50.png")

	// vendor + BO number come from the parent BuyingOrder via the buyingOrder link
	$entry.setLBItemsColumn("buyingOrder.customer.name"; "Vendor"; "width:250")
	$entry.setLBItemsColumn("buyingOrder.boNumber"; "BO #"; "width:100"; "center")
	$entry.setLBItemsColumn("order"; "Item #"; "width:100"; "center")

	$entry.setLBItemsOrderBy("buyingOrder.boNumber desc")

	$entry.setSearchboxField("buyingOrder.customer.name"; "placeholder:Vendor")
	// NOTE: no BO# search - boNumber is an integer and the sfw searchbox only does
	// @..@ text-contains, which errors on numeric fields. Supporting it would
	// require changing sfw_ framework methods, which is off-limits.

	// buy items already received (dateIn filled) are shown on a gray background
	$entry.setLBItemsMetaExpression("this.metaColor()")

	// toggle filter to identify buy lines flagged as inventory items
	$filter:=cs:C1710.sfw_definitionFilter.new("filterInventory")
	$filter.setDefaultTitle("Inventory: all")
	$filter.setFilterByBooleanExpression("inventory = :1"; "Inventory items"; "Non-inventory items")
	$entry.addFilter($filter)

	// toggle filter to show buy lines that can still be received (no date in yet)
	// TEMP: disabled - needs a stored boolean field (the framework's boolean
	// filter cannot resolve the computed canBeReceived query against dateIn).
	//$filter:=cs:C1710.sfw_definitionFilter.new("filterReceivable")
	//$filter.setDefaultTitle("Receiving: all")
	//$filter.setFilterByBooleanExpression("canBeReceived = :1"; "Can be received"; "Already received")
	//$entry.addFilter($filter)

	$entry.setPanel("panel_BOReceiving")

	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "Inventories"; "disabled:Form.current_item.inventory=false")
	//$entry.setPanelPage(2; ""; "Step Interruption")
	//$entry.setPanelPage(3; ""; "Hold Info")
	//$entry.setPanelPage(4; ""; "Serialization"; "disabled:Form.hasSnItems=False")
	//$entry.setPanelPage(5; ""; "Inventory Pulls")
	//$entry.setPanelPage(6; ""; "Data Table"; "disabled:Form.current_item.step.stepTemplate.dataTables=Null")
	//$entry.setPanelPage(7; ""; "Binning"; "disabled:Form.current_item.step.stepTemplate.binning=False")

	$entry.enableTransaction()

	$entry.activateComment()
	
	This:C1470._push_entry($entry)
	
	
	//Production - Punch In
	
	$entry:=cs:C1710.sfw_definitionEntry.new("punchIn"; ["production"]; "Punch In")
	$entry.setDataclass("LotStep")
	$entry.setDisplayOrder(200)
	$entry.setIcon("image/entry/punsh-in-50x50.png")
	
	$entry.setSubset("currentSteps")
	
	$entry.setLBItemsColumn("lot.job.customer.name"; "Customer"; "width:125")
	$entry.setLBItemsColumn("lot.job.jobNumber"; "Job Number"; "width:125")
	$entry.setLBItemsColumn("lot.number"; "Lot Number"; "width:110")
	$entry.setLBItemsColumn("lot.subSequence"; "Sub"; "width:50")
	$entry.setLBItemsColumn("order"; "Order"; "width:50")
	
	$entry.setLBItemsOrderBy("lot.number desc")
	
	$entry.setPanel("panel_punch_in")
	
	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "Step Interruption")
	$entry.setPanelPage(3; ""; "Hold Info")
	$entry.setPanelPage(4; ""; "Serialization"; "disabled:Form.hasSnItems=False")
	$entry.setPanelPage(5; ""; "Inventory Pulls")
	$entry.setPanelPage(6; ""; "Data Table"; "disabled:Form.current_item.step.stepTemplate.dataTables=Null")
	$entry.setPanelPage(7; ""; "Binning"; "disabled:Form.current_item.step.stepTemplate.binning=False")
	
	$entry.enableTransaction()
	
	This:C1470._push_entry($entry)
	
	//Production - Punch Out
	
	$entry:=cs:C1710.sfw_definitionEntry.new("punchOut"; ["production"]; "Punch OUT")
	$entry.setDataclass("LotStep")
	$entry.setDisplayOrder(100)
	$entry.setIcon("image/entry/punsh-out-50x50.png")
	
	$entry.setSubset("punchOutSteps")
	
	$entry.setLBItemsColumn("lot.job.customer.name"; "Customer"; "width:125")
	$entry.setLBItemsColumn("lot.job.jobNumber"; "Job Number"; "width:125")
	$entry.setLBItemsColumn("lot.number"; "Lot Number"; "width:110")
	$entry.setLBItemsColumn("lot.subSequence"; "Sub"; "width:50")
	$entry.setLBItemsColumn("order"; "Order"; "width:50")
	
	$entry.setLBItemsOrderBy("lot.number desc")
	
	$entry.setPanel("panel_punch_out")
	
	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "Step Interruption")
	$entry.setPanelPage(3; ""; "Hold Info")
	$entry.setPanelPage(4; ""; "Serialization"; "disabled:Form.hasSnItems=False")
	$entry.setPanelPage(5; ""; "Inventory Pulls")
	$entry.setPanelPage(6; ""; "Data Table"; "disabled:Form.current_item.step.stepTemplate.dataTables=Null")
	$entry.setPanelPage(7; ""; "Binning"; "disabled:Form.current_item.step.stepTemplate.binning=False")
	
	$entry.enableTransaction()
	
	This:C1470._push_entry($entry)
	
	//Customer Service - Receiver
	
//	$entry:=cs:C1710.sfw_definitionEntry.new("receiver"; ["customerService"]; "Receiver")
//	$entry.setDataclass("Lot")
//	$entry.setDisplayOrder(-400)
//	$entry.setIcon("image/entry/receiver-50x50.png")
//	
//	$entry.setSearchboxField("lotNumber")
//	
//	
//	$entry.setPanel("panel_receiver")
//	$entry.setPanelPage(1; ""; "Main")
//	$entry.setPanelPage(2; ""; "Customer Provided Material")
//	
//	$entry.setLBItemsColumn("lotNumber"; "Lot #"; "width:450")
//	
//	$entry.setLBItemsOrderBy("lotNumber")
//	$entry.enableTransaction()
//	
//	$entry.setItemAction("Sample Lot Traveler TAG"; "Receiver_travelerTag")
//	
//	This:C1470._push_entry($entry)
	
	//Customer Service - Planning
	
	$entry:=cs:C1710.sfw_definitionEntry.new("planning"; ["customerService"]; "Planning")
	$entry.setDataclass("Lot")
	$entry.setDisplayOrder(-390)
	$entry.setIcon("image/entry/planning-white-50x50.png")
	
	$entry.setSearchboxField("lotNumber")
	
	$entry.setPanel("panel_planning")
	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "Step")
	$entry.setPanelPage(3; ""; "Lot Holds")
	$entry.setPanelPage(4; ""; "Serialization"; "disabled:Form.current_item.serialization=false")
	
	$entry.setLBItemsColumn("number"; "Lot #"; "width:80")
	$entry.setLBItemsColumn("subSequence"; "Sub #"; "width:40"; "format:##")
	$entry.setLBItemsColumn("job.po"; "PO"; "width:80")
	$entry.setLBItemsColumn("job.jobNumber"; "Job #"; "width:80")
	$entry.setLBItemsColumn("job.customer.name"; "Customer"; "width:250")
	
	$entry.setLBItemsOrderBy("lotNumber")
	$entry.enableTransaction()
	$entry.setItemListAction("Split Lot"; "planning_splitLot"; "scope:oneOrMoreListItemsSelected")

	$entry.activateEvent("LotEvent"; "UUID_Lot")

	$entry.activateComment()

	This:C1470._push_entry($entry)
	
	//Receiving - Customer Received Material
	
	$entry:=cs:C1710.sfw_definitionEntry.new("customerReceivedMaterial"; ["receiving"]; "Customer Received Material")
	$entry.setDataclass("Lot")
	$entry.setDisplayOrder(-400)
	$entry.setIcon("image/entry/receiver-50x50.png")
	
	$entry.setSearchboxField("lotNumber")
	
	$entry.setPanel("panel_customerReceivedMaterial")
	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "Customer Provided Material")
	
	$entry.setLBItemsColumn("job.customer.name"; "Customer"; "width:200")
	$entry.setLBItemsColumn("job.jobNumber"; "Job #"; "width:120")
	$entry.setLBItemsColumn("number"; "Lot #"; "width:120")
	//$entry.setLBItemsColumn("subSequence"; ""; "width:20"; "format:")
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterCustomer")
	$filter.setDefaultTitle("All customers")
	// Filter lots by linked customer through job relation.
	$filter.setFilterByLinkedEntity("Customer"; "job.customer.UUID"; "uuidCustomer"; "job.customer")
	$filter.setDynamicTitle("name"; "## customers")
	$filter.setOrderForItems("name")
	$filter.setAttributeLabelForItem("name")
	$entry.addFilter($filter)
	
	$entry.setLBItemsOrderBy("lotNumber")
	$entry.enableTransaction()
	
	This:C1470._push_entry($entry)
	
Function _profiles_definition()
	$eQM:=ds:C1482.sfw_UserProfile.getAndCreateIfNotExist("qm"; "Quality Manager"; "autoCreation")
	$eDC:=ds:C1482.sfw_UserProfile.getAndCreateIfNotExist("dc"; "Document Controller"; "autoCreation")
	$eQI:=ds:C1482.sfw_UserProfile.getAndCreateIfNotExist("qi"; "Quality Inspector"; "autoCreation")  // modified by 4D/PS [2026-may-21]
	$eQS:=ds:C1482.sfw_UserProfile.getAndCreateIfNotExist("qs"; "Quality Supervisor"; "autoCreation")
	$ePM:=ds:C1482.sfw_UserProfile.getAndCreateIfNotExist("pm"; "Production Manager"; "autoCreation")
	$ePS:=ds:C1482.sfw_UserProfile.getAndCreateIfNotExist("ps"; "Production Supervisor"; "autoCreation")
	$eVP:=ds:C1482.sfw_UserProfile.getAndCreateIfNotExist("vp"; "VP"; "autoCreation")
	$eGM:=ds:C1482.sfw_UserProfile.getAndCreateIfNotExist("gm"; "General Manager"; "autoCreation")
	$eSR:=ds:C1482.sfw_UserProfile.getAndCreateIfNotExist("sr"; "Shipper & receiver"; "autoCreation")
	
Function _documentFolders_definition()
	
	$eContract:=ds:C1482.sfw_DocumentFolder.getAndCreateIfNotExist("contract"; "Contract")
	$eContract:=ds:C1482.sfw_DocumentFolder.getAndCreateIfNotExist("sales"; "Sales")
	$eContract:=ds:C1482.sfw_DocumentFolder.getAndCreateIfNotExist("quote"; "Quote"; "subFolderOf:sales")
	$eContract:=ds:C1482.sfw_DocumentFolder.getAndCreateIfNotExist("invoice"; "Invoice"; "subFolderOf:sales")
	$eLegal:=ds:C1482.sfw_DocumentFolder.getAndCreateIfNotExist("legal"; "Legal")
	$eNda:=ds:C1482.sfw_DocumentFolder.getAndCreateIfNotExist("nda"; "NDA"; "subFolderOf:legal")
	