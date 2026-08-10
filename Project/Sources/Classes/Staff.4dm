Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("staff"; ["qualityAssurance"]; "Staff")
	$entry.setDataclass("Staff")
	$entry.setDisplayOrder(-300)
	$entry.setIcon("image/entry/staffs-white-50x50.png")
	
	$entry.setSearchboxField("firstName")
	$entry.setSearchboxField("lastName")
	$entry.setSearchboxField("assignments.certification.name"; "placeholder:certification")
	
	
	$entry.setPanel("panel_staff")
	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "Certifications Assignment"; "")
	$entry.setPanelPage(3; ""; "Settings"; "allowedProfiles:admin")
	
	
	$entry.setLBItemsColumn("code"; "Code"; "width:50"; "center")
	$entry.setLBItemsColumn("firstName"; "First Name"; "width:190")
	$entry.setLBItemsColumn("lastName"; "Last Name"; "width:190")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	$entry.setLBItemsOrderBy("code")
	
	//$entry.setValidationRule("code"; "entryField_code"; "mandatory"; "trimSpace"; "message:The code is mandatory")
	$entry.setValidationRule("firstName"; "entryField_firstName"; "mandatory"; "message:The first name is mandatory")
	$entry.setValidationRule("lastName"; "entryField_lastName"; "mandatory"; "message:The last name is mandatory")
	
	$view:=cs:C1710.sfw_definitionView.new("terminatedStaff"; "Terminated Staffs"; "derivedFrom:main"; $entry)
	$view.setSubset("terminatedStaff")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/terminated-user-16x16.png")
	$entry.setView($view)
	
	$view:=cs:C1710.sfw_definitionView.new("retrainingStaff"; "Staff retraining in 30 days"; "derivedFrom:main"; $entry)
	$view.setSubset("retrainingStaff")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/terminated-user-16x16.png")
	$entry.setView($view)
	
	$view:=cs:C1710.sfw_definitionView.new("currentStaff"; "Current Staff"; "derivedFrom:main"; $entry)
	$view.setSubset("currentStaff")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/terminated-user-16x16.png")
	$entry.setView($view)
	
	$entry.setAllowedProfiles("qm")
	
	$entry.enableTransaction()
	//$entry.setAllowedProfilesForDeletion("pm")
	
	$entry.setItemListAction("Staff Certifications of the year - CSV"; "Staff_certif_of_the_year_csv")
	$entry.setItemListAction("Staff Certifications of the year - PDF"; "Staff_certif_of_the_year_pdf")
	$entry.setItemListAction("Export Employees - CSV"; "Staff_export_employees_csv")
	$entry.setItemListAction("Export Employees - PDF"; "Staff_export_employees_pdf")
	$entry.setItemListAction("Print Badges"; "Staff_print_badges")
	
	$entry.setItemListAction("print Barcode for the selection"; "_ga_multipleBarcodePrint")
	
	$entry.setItemAction("Print Badge"; "staff_print_badge")
	$entry.setItemAction("Print Certification Training"; "staff_print_cert_training")
	
	
	
	// MARK: -Filters
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterCertification")
	$filter.setDefaultTitle("All Certifications")
	$filter.setFilterByManyToManyEntity("Certification"; "name"; "assignments.certification")
	$filter.setDynamicTitle("name"; "## Certification")
	$filter.setOrderForItems("ref")
	$entry.addFilter($filter)
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterTeamMember")
	$filter.setDefaultTitle("All Teams")
	$filter.setFilterByManyToManyEntity("Team"; "name"; "memberships.team")
	$filter.setDynamicTitle("name"; "## Team")
	$filter.setOrderForItems("name")
	$entry.addFilter($filter)
	
	$filter:=cs:C1710.sfw_definitionFilter.new("filterRole")
	$filter.setDefaultTitle("All Roles")
	$filter.setFilterByManyToManyEntity("Role"; "name"; "roles.role")
	$filter.setDynamicTitle("name"; "## Role")
	$filter.setOrderForItems("name")
	$entry.addFilter($filter)
	
Function currentStaff()->$staffs : cs:C1710.StaffSelection
	$staffs:=ds:C1482.Staff.newSelection()
	$users_es:=ds:C1482.sfw_User.query("login = :1"; Current user:C182)
	
	If ($users_es.length>0)
		If ($users_es[0].staffs.length>0)
			$staffs:=$users_es[0].staffs
		End if 
	End if 
	
Function terminatedStaff()->$staffs : cs:C1710.StaffSelection
	$staffs:=ds:C1482.Staff.query("terminated = :1"; True:C214)
	
	
Function retrainingStaff()->$staffs : cs:C1710.StaffSelection
	$staffs:=ds:C1482.Staff.newSelection()
	
	For each ($staff; ds:C1482.Staff.all())
		$certs:=$staff.getCertiExpiredIn(30)
		
		If ($certs.length>0)
			$staffs.add($staff)
		End if 
	End for each 
	
	
Function checkRetraining($days : Integer)->$retraining : Collection
	var $staff_es : cs:C1710.StaffSelection
	var $staff_e : cs:C1710.StaffEntity
	
	$start:=cs:C1710.sfw_stmp.me.now()
	$end:=cs:C1710.sfw_stmp.me.build(Add to date:C393(Current date:C33(); 0; 0; $days))
	
	$staff_es:=ds:C1482.Staff.query("assignments.expiredIn >= :1 AND assignments.expiredIn <= :2"; $start; $end)
	
	$retraining:=New collection:C1472()
	
	For each ($staff_e; $staff_es)
		// Apr 22, 2026 4DFix: Current date:C33 was missing () — was passing the command reference instead of the date value
		$notif_es:=ds:C1482.sfw_Notification.query("moreData.UUID_Staff = :1 AND moreData.date = :2"; $staff_e.UUID; Current date:C33())
		
		If ($notif_es.length=0)
			CREATE RECORD:C68([sfw_Notification:69])
			// Apr 22, 2026 4DFix: was using .all().first() which returns a random notification type — now queries for the correct "EmployeeRetrainRequired" type
			[sfw_Notification:69]UUID_NotificationType:4:=ds:C1482.sfw_NotificationType.query("ident = :1"; "EmployeeRetrainRequired").first().UUID
			[sfw_Notification:69]UUID_User:3:=cs:C1710.sfw_userManager.me.info.UUID
			[sfw_Notification:69]UUID_target:2:=$staff_e.UUID
			[sfw_Notification:69]comment:5:=$staff_e.firstName+" "+$staff_e.lastName+" :"+"Retraining for "+String:C10($staff_e.getCertiExpiredIn(30).length)+" certifications due within 30 days."
			[sfw_Notification:69]moreData:8:=New object:C1471("targetDataclass"; "Staff"; "UUID_Staff"; $staff_e.UUID; "date"; Current date:C33())
			[sfw_Notification:69]stmp:7:=cs:C1710.sfw_stmp.me.now()
			SAVE RECORD:C53([sfw_Notification:69])
			
			$retraining.push("")
		End if 
	End for each 
	
	If ($retraining.length>0)
		// Apr 22, 2026 4DFix: typo "updateNodifications" corrected to "updateNotifications"
		cs:C1710.sfw_notificationManager.me.updateNotifications()
	End if 
	
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.staffs=Null:C1517)
		$employees:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.staffs:=$employees.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
Function _loadAsCollection()->$employees : Collection
	$employees:=This:C1470.all().toCollection("UUID,firstName,lastName,code").orderBy("code")
	
	
	
	
	
	