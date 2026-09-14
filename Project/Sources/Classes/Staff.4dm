Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	$entry:=cs:C1710.sfw_definitionEntry.new("staff"; ["qualityAssurance"]; "Staff")
	$entry.setDataclass("Staff")
	$entry.setDisplayOrder(-300)
	$entry.setIcon("image/entry/staffs-white-50x50.png")
	
	$entry.setSearchboxField("firstName")
	$entry.setSearchboxField("lastName")
	// Purpose: Allow searching staff by shift ("1" or "2") and by certification name.
	// modified by 4D/PS [2026-may-21]
	$entry.setSearchboxField("shift"; "placeholder:shift")
	$entry.setSearchboxField("assignments.certification.name"; "placeholder:certification")
	
	
	$entry.setPanel("panel_staff")
	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "Certifications Assignment"; "")
	//$entry.setPanelPage(3; ""; "Settings"; "allowedProfiles:admin")
	
	
	$entry.setLBItemsColumn("code"; "Code"; "width:50"; "center")
	$entry.setLBItemsColumn("firstName"; "First Name"; "width:190")
	$entry.setLBItemsColumn("lastName"; "Last Name"; "width:190")
	// Purpose: Expose Shift ("1"/"2") in the items list for quick scanning by floor managers.
	// modified by 4D/PS [2026-may-21]
	$entry.setLBItemsColumn("shift"; "Shift"; "width:50"; "center")
	
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
	
	// Purpose: Quality profiles plus Document Control (dc) may open and modify Staff records.
	// modified by 4D/PS [2026-june-02]
	$entry.setAllowedProfiles("qs"; "qi"; "qm"; "dc")
	
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
	
	// Purpose: Staff with retrain milestone or calendar validity expiry due within 30 days.
	// modified by 4D/PS [2026-june-08]
	For each ($staff; ds:C1482.Staff.all())
		If ($staff.getRetrainMilestonesDueIn(30).length>0) || ($staff.getCertiExpiredIn(30).length>0)
			$staffs.add($staff)
		End if 
	End for each 
	
	
	// Purpose: Notify the linked sfw_User for each staff member when retrain milestones or validity expiry fall within $days.
	// Uses moreData.retrainNotifiedMilestones (d90, d365, …) and validityExpiryNotified for calendar expiry.
	// Parameters: $days : Integer — lookahead window in days (typically 30)
	// Returns: Collection — one True entry per newly sent notification (drives UI refresh in callers)
	// modified by 4D/PS [2026-june-12]
Function checkRetraining($days : Integer)->$createdNotificationMarkers : Collection
	
	var $staff_e : cs:C1710.StaffEntity
	var $assignment_e : cs:C1710.CertificationAssignmentEntity
	var $users : Collection
	var $context : Object
	var $dueMilestones : Collection
	var $due : Object
	var $milestoneKey : Text
	var $offsets : Collection
	var $offset : Integer
	var $certDt : Date
	var $milestoneDate : Date
	var $today : Date
	var $limit : Date
	var $res : Object
	
	$createdNotificationMarkers:=New collection:C1472()
	$today:=Current date:C33()
	$limit:=Add to date:C393($today; 0; 0; $days)
	
	For each ($staff_e; ds:C1482.Staff.query("terminated = :1"; False:C215))
		$dueMilestones:=$staff_e.getRetrainMilestonesDueIn($days)
		
		For each ($due; $dueMilestones)
			$assignment_e:=$due.assignment
			$milestoneKey:="d"+String:C10($due.milestoneDays)
			
			If ($assignment_e.moreData=Null:C1517)
				$assignment_e.moreData:=New object:C1471("retrainNotifiedMilestones"; New object:C1471)
			Else 
				If (Not:C34(OB Is defined:C1231($assignment_e.moreData; "retrainNotifiedMilestones")))
					$assignment_e.moreData.retrainNotifiedMilestones:=New object:C1471
				End if 
			End if 
			
			If (Not:C34(Bool:C1537($assignment_e.moreData.retrainNotifiedMilestones[$milestoneKey])))
				// Purpose: Notify only the staff member's linked user account (not qm/qs).
				// modified by 4D/PS [2026-june-12]
				If ($staff_e.user#Null:C1517)
					$users:=New collection:C1472($staff_e.user.UUID)
					$context:=New object:C1471(\
						"target"; $staff_e.UUID; \
						"targetDataclass"; "Staff"; \
						"fullName"; $staff_e.fullName; \
						"certName"; $assignment_e.certification.name; \
						"expiringDate"; String:C10($due.milestoneDate; Null event:K17:1); \
						"milestoneDays"; $due.milestoneDays; \
						"days"; $days\
						)
					cs:C1710.sfw_notificationManager.me.notify("EmployeeRetrainRequired"; $users; $context)
					$assignment_e.moreData.retrainNotifiedMilestones[$milestoneKey]:=True:C214
					$res:=$assignment_e.save()
					If ($res.success)
						$createdNotificationMarkers.push(True:C214)
					End if 
				End if 
			End if 
		End for each 
		
		// Purpose: Notify when assignment calendar expiry (expiringDate) falls within the window.
		// modified by 4D/PS [2026-june-08]
		For each ($assignment_e; $staff_e.getCertiExpiredIn($days))
			If ($assignment_e.moreData=Null:C1517)
				$assignment_e.moreData:=New object:C1471
			End if 
			If (Not:C34(Bool:C1537($assignment_e.moreData.validityExpiryNotified)))
				// Purpose: Notify only the staff member's linked user account (not qm/qs).
				// modified by 4D/PS [2026-june-12]
				If ($staff_e.user#Null:C1517)
					$users:=New collection:C1472($staff_e.user.UUID)
					$context:=New object:C1471(\
						"target"; $staff_e.UUID; \
						"targetDataclass"; "Staff"; \
						"fullName"; $staff_e.fullName; \
						"certName"; $assignment_e.certification.name; \
						"expiringDate"; String:C10($assignment_e.expiringDate; Null event:K17:1); \
						"days"; $days\
						)
					cs:C1710.sfw_notificationManager.me.notify("EmployeeRetrainRequired"; $users; $context)
					$assignment_e.moreData.validityExpiryNotified:=True:C214
					$res:=$assignment_e.save()
					If ($res.success)
						$createdNotificationMarkers.push(True:C214)
					End if 
				End if 
			End if 
		End for each 
		
		// Purpose: Clear validity expiry flag when assignment is outside the notification window.
		// modified by 4D/PS [2026-june-08]
		For each ($assignment_e; $staff_e.assignments)
			If ($assignment_e.moreData#Null:C1517) && (OB Is defined:C1231($assignment_e.moreData; "validityExpiryNotified")) && (Bool:C1537($assignment_e.moreData.validityExpiryNotified))
				If ($assignment_e.expiredIn<=0) || (($assignment_e.expiringDate#!00-00-00!) && (($assignment_e.expiringDate<$today) || ($assignment_e.expiringDate>$limit)))
					$assignment_e.moreData.validityExpiryNotified:=False:C215
					$res:=$assignment_e.save()
				End if 
			End if 
		End for each 
		
		// Purpose: Clear milestone flags outside the notification window so a future cycle can notify again.
		// modified by 4D/PS [2026-june-02]
		For each ($assignment_e; $staff_e.assignments)
			If ($assignment_e.moreData#Null:C1517) && (OB Is defined:C1231($assignment_e.moreData; "retrainNotifiedMilestones"))
				If ($assignment_e.certification#Null:C1517) && ($assignment_e.certificationStmp#0)
					$certDt:=$assignment_e.certificationDate
					If ($certDt#!00-00-00!)
						$offsets:=$assignment_e.certification.retrainMilestoneDayOffsets()
						For each ($offset; $offsets)
							$milestoneKey:="d"+String:C10($offset)
							If (OB Is defined:C1231($assignment_e.moreData.retrainNotifiedMilestones; $milestoneKey)) && (Bool:C1537($assignment_e.moreData.retrainNotifiedMilestones[$milestoneKey]))
								$milestoneDate:=Add to date:C393($certDt; 0; 0; $offset)
								If ($milestoneDate<$today) || ($milestoneDate>$limit)
									$assignment_e.moreData.retrainNotifiedMilestones[$milestoneKey]:=False:C215
									$res:=$assignment_e.save()
								End if 
							End if 
						End for each 
					End if 
				End if 
			End if 
		End for each 
	End for each 
	
	If ($createdNotificationMarkers.length>0)
		cs:C1710.sfw_notificationManager.me.updateNodifications()
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
	$employees:=This:C1470.all().toCollection("UUID,firstName,lastName,fullName,code").orderBy("code")
	
	
	
	
	
	