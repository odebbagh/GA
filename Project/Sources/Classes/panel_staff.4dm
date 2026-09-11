singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
		//OBJECT SET VISIBLE(*; "wr30_@"; (Form.current_item.getCertiExpiredIn(30).length>0))
		// Purpose: Mirror boolean drives the "Shift 1 / Shift 2" radio group; written back to current_item.shift on click (see ObjectMethods/entryField_shift.4dm).
		// modified by 4D/PS [2026-may-21]
		Form:C1466.shift1:=(Form:C1466.current_item.shift="1")
		This:C1470.loadAllTabs()
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		ds:C1482.Staff.checkRetraining(30)
		
		Case of 
			: (FORM Get current page:C276(*)=1)
				This:C1470.loadCommunications()
			: (FORM Get current page:C276(*)=2)
				This:C1470.loadCertifications()
			: (FORM Get current page:C276(*)=3)
				This:C1470.userSetting()
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	
	OBJECT SET VISIBLE:C603(*; "dp_terminationDate"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "dp_retrainDate"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "dp_hireDate"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "dp_creationDate"; Form:C1466.sfw.checkIsInModification())
	
	//This.hideDatePickers()
	This:C1470.drawPup_citizenshipStatus()
	This:C1470.drawPup_Department()
	This:C1470.drawPup_Division()
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	Use (Form:C1466.sfw.entry.panel.pages)
		Form:C1466.sfw.entry.panel.pages[1].label:="Certifications Assignment ("+String:C10(Form:C1466.lb_assignments.length)+")"
	End use 
	
	
	Case of 
		: (FORM Get current page:C276(*)=2)  // assignments
			OBJECT GET COORDINATES:C663(*; "rec_bkgd_1"; $left; $top; $right; $bottom)
			OBJECT GET COORDINATES:C663(*; "lb_assignments"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT GET COORDINATES:C663(*; "bActionCertifications"; $left_bAc; $top_bAc; $right_bAc; $bottom_bAc)
			
			$offset:=4
			$offset_bAc:=10
			$height_bAc:=$bottom_bAc-$top_bAc
			
			OBJECT SET COORDINATES:C1248(*; "rec_bkgd_1"; $left; $top; $right; $heightSubform-$offset)
			OBJECT SET COORDINATES:C1248(*; "lb_assignments"; $left_lb; $top_lb; $right_lb; $heightSubform-$offset-1)
			OBJECT SET COORDINATES:C1248(*; "bActionCertifications"; $left_bAc; $heightSubform-$offset_bAc-$height_bAc; $right_bAc; $heightSubform-$offset_bAc)
			This:C1470._configureCertAssignmentColumns()
	End case 
	
	//Form.sfw.drawHTab()
	
	
Function loadAllTabs()
	// Apr 22, 2026 4DFix: loadCommunications() was missing — communications could be stale when switching records while staying on tab 1
	This:C1470.loadCommunications()
	This:C1470.loadCertifications()
	
Function loadCommunications()
	If (Form:C1466.current_item.contactDetails=Null:C1517)
		Form:C1466.current_item.contactDetails:=New object:C1471
	End if 
	If (Form:C1466.current_item.contactDetails.communications=Null:C1517)
		Form:C1466.current_item.contactDetails.communications:=New collection:C1472
	End if 
	Form:C1466.subFormCommunication:=New object:C1471(\
		"communications"; Form:C1466.current_item.contactDetails.communications; \
		"situation"; Form:C1466.situation\
		)
	
	Form:C1466.subFormCommunication:=Form:C1466.subFormCommunication
	
	// Purpose: True when the current user may manage staff certifications (qs, qm, dc per Karla 2.d).
	// Returns: Boolean
	// modified by 4D/PS [2026-june-02]
Function _hasQaProfile()->$allowed : Boolean
	
	var $qaProfiles : Collection
	
	$qaProfiles:=_ga_qaCertModifyProfiles
	$allowed:=cs:C1710.sfw_userManager.me.authorizedProfiles.find(Formula:C1597((Value type:C1509($1.value)=Is text:K8:3) && ($qaProfiles.indexOf($1.value)#-1)))#Null:C1517
	
	
	// Purpose: True when the latest assignment has overrideCertExpired (punch-in allowed while expired).
	// Parameters: $uuid_certification : Text — Certification.UUID
	// Returns: Boolean
	// modified by 4D/PS [2026-june-02]
Function _assignmentOverrideActive($uuid_certification : Text)->$active : Boolean
	
	var $assignment_e : cs:C1710.CertificationAssignmentEntity
	
	$active:=False:C215
	$assignment_e:=ds:C1482.CertificationAssignment\
		.query("UUID_Staff = :1 AND UUID_Certification = :2"; Form:C1466.current_item.UUID; $uuid_certification)\
		.orderBy("certificationStmp desc").first()
	If ($assignment_e#Null:C1517) && ($assignment_e.moreData#Null:C1517)
		$active:=Bool:C1537($assignment_e.moreData.overrideCertExpired)
	End if 
	
	
Function loadCertifications()
	
	var $assignmentByCert : Object
	var $assignment_e : cs:C1710.CertificationAssignmentEntity
	var $uuidCert : Text
	var $certDt : Date
	var $expDt : Date
	var $daysUntilExpiry : Integer
	var $selectedUuid : Text
	var $row : Object
	
	GOTO OBJECT:C206(*; "lb_assignments")
	$selectedUuid:=""
	If (Form:C1466.selectedCertification#Null:C1517)
		$selectedUuid:=Form:C1466.selectedCertification.UUID
	End if 
	Form:C1466.lb_assignments:=New collection:C1472()
	
	// Purpose: Keep latest CertificationAssignment entity per cert UUID (do not store Date values inside a plain Object).
	// modified by 4D/PS [2026-june-09]
	$assignmentByCert:=New object:C1471()
	For each ($assignment_e; ds:C1482.CertificationAssignment.query("UUID_Staff = :1"; Form:C1466.current_item.UUID))
		$uuidCert:=$assignment_e.UUID_Certification
		If ($assignmentByCert[$uuidCert]=Null:C1517)
			$assignmentByCert[$uuidCert]:=$assignment_e
		Else 
			If ($assignment_e.certificationStmp>Num:C11($assignmentByCert[$uuidCert].certificationStmp))
				$assignmentByCert[$uuidCert]:=$assignment_e
			End if 
		End if 
	End for each 
	
	For each ($certification; ds:C1482.Certification.all().orderBy("ref asc"))
		$assignment_e:=$assignmentByCert[$certification.UUID]
		$certDt:=!00-00-00!
		$expDt:=!00-00-00!
		$daysUntilExpiry:=99999
		If ($assignment_e#Null:C1517)
			$certDt:=$assignment_e.certificationDate
			$expDt:=This:C1470._staffCertExpiringDate($certDt; $certification; $assignment_e)
			// Purpose: Precompute days until lapse for listbox rowFillSource (Date props in collection rows are unreliable there).
			// modified by 4D/PS [2026-june-08]
			If (Not:C34($certification.oneTime)) && ($expDt#!00-00-00!)
				$daysUntilExpiry:=$expDt-Current date:C33()
			End if 
		End if 
		Form:C1466.lb_assignments.push(New object:C1471(\
			"UUID"; $certification.UUID; \
			"name"; $certification.name; \
			"duration"; $certification.duration; \
			"oneTime"; $certification.oneTime; \
			"hasAssignment"; ($assignment_e#Null:C1517); \
			"expiringDate"; $expDt; \
			"daysUntilExpiry"; $daysUntilExpiry; \
			"certifiedAt"; This:C1470._formatStaffCertDate($certDt); \
			"expiredIn"; This:C1470._formatStaffCertDate($expDt); \
			"certified"; Form:C1466.current_item.hasCertification($certification.UUID); \
			"overrideExpired"; This:C1470._assignmentOverrideActive($certification.UUID)\
			))
		
	End for each 
	
	Form:C1466.lb_assignments:=Form:C1466.lb_assignments.orderBy("certified desc")
	
	// Purpose: Re-bind selectedCertification to the new collection so history list and columns stay in sync after reload/save.
	// modified by 4D/PS [2026-june-09]
	Form:C1466.selectedCertification:=Null:C1517
	If ($selectedUuid#"")
		For each ($row; Form:C1466.lb_assignments)
			If ($row.UUID=$selectedUuid)
				Form:C1466.selectedCertification:=$row
				break
			End if 
		End for each 
	End if 
	
	This:C1470._configureCertAssignmentColumns()
	This:C1470.loadCertificationHistory()
	
	REDISPLAY:C113
	
	
Function _formatStaffCertDate($date : Date) -> $text : Text
	// Purpose: Format certification dates for listbox text columns (Certified At / Expired In).
	// Parameters: $date : Date — calendar date (!00-00-00! when empty)
	// Returns: Text — short date string or empty
	// created by 4D/PS [2026-june-09]
	
	$text:=""
	If ($date#Null:C1517) && ($date#!00-00-00!)
		$text:=String:C10($date; System date short:K1:1)
	End if 
	
	
Function _staffCertExpiringDate($certificationDate : Date; $certification_e : cs:C1710.CertificationEntity; $assignment_e : cs:C1710.CertificationAssignmentEntity) -> $expiringDate : Date
	// Purpose: Expired In = Certified At + catalog duration (or assignment snapshot when catalog has no duration).
	// Parameters:
	// $certificationDate : Date — assignment certification date
	// $certification_e : cs.CertificationEntity — catalog row (duration / oneTime)
	// $assignment_e : cs.CertificationAssignmentEntity — optional; expiredIn used when catalog resolves to 0 days
	// Returns: Date — lapse date, or !00-00-00! when one-time or no validity window
	// modified by 4D/PS [2026-june-08]
	
	var $validityDays : Integer
	
	$expiringDate:=!00-00-00!
	If ($certificationDate=Null:C1517) || ($certificationDate=!00-00-00!)
		return $expiringDate
	End if 
	If ($certification_e=Null:C1517) || ($certification_e.oneTime)
		return $expiringDate
	End if 
	
	$validityDays:=$certification_e.expiredInDaysForNewAssignment()
	If ($validityDays<=0) && ($assignment_e#Null:C1517) && ($assignment_e.expiredIn>0)
		$validityDays:=$assignment_e.expiredIn
	End if 
	If ($validityDays>0)
		$expiringDate:=Add to date:C393($certificationDate; 0; 0; $validityDays)
	End if 
	
	
Function _configureCertAssignmentColumns()
	
	var $canEditCerts : Boolean
	
	// Purpose: Columns are static in form.4DForm — only toggle enterable (checkbox) and Re-New by profile/mode.
	// modified by 4D/PS [2026-june-08]
	If (FORM Get current page:C276(*)#2)
		return 
	End if 
	
	$canEditCerts:=This:C1470._hasQaProfile() && Form:C1466.sfw.checkIsInModification()
	
	OBJECT SET ENTERABLE:C238(*; "col_certified_at"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "col_expired_in"; False:C215)
	OBJECT SET ENTERABLE:C238(*; "entryField_hasCertif"; $canEditCerts)
	
	OBJECT SET VISIBLE:C603(*; "col_certified_at"; True:C214)
	OBJECT SET VISIBLE:C603(*; "col_expired_in"; True:C214)
	OBJECT SET VISIBLE:C603(*; "hd_certifiedAt"; True:C214)
	OBJECT SET VISIBLE:C603(*; "hd_expiredIn"; True:C214)
	OBJECT SET HORIZONTAL ALIGNMENT:C706(*; "col_certified_at"; Align center:K42:3)
	OBJECT SET HORIZONTAL ALIGNMENT:C706(*; "col_expired_in"; Align center:K42:3)
	
	OBJECT SET ENABLED:C1123(*; "bRenewCertification"; $canEditCerts && (Form:C1466.selectedCertification#Null:C1517))
	
	
// Purpose: Open _ga_calendar centered for Staff certification listbox actions (GET MOUSE coords fail on this page).
// Parameters:
// $defaultDate : Date — initial selection (!00-00-00! → today)
// Returns: Date — selected date, or !00-00-00! when cancelled
// created by 4D/PS [2026-july-27]
Function _pickCertificationDate($defaultDate : Date)->$date : Date
	
	var $form : Object
	var $winRef : Integer
	
	If ($defaultDate=!00-00-00!)
		$defaultDate:=Current date:C33(*)
	End if 
	
	$form:=New object:C1471()
	$form.date:=$defaultDate
	
	$winRef:=Open form window:C675("_ga_calendar"; Movable dialog box:K34:7; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40("_ga_calendar"; $form)
	
	If (OK=1)
		$date:=$form.calendar.display.date
	Else 
		$date:=!00-00-00!
	End if 
	
	
Function renewCertification()
	// Purpose: Re-New — append a CertificationAssignment with a chosen date (keeps history).
	// Requires qs/qm/dc profile, modification mode, and a selected certification row.
	// modified by 4D/PS [2026-july-27]
	
	var $certDate : Date
	
	If (Form:C1466.selectedCertification=Null:C1517) || (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	If (Not:C34(This:C1470._hasQaProfile()))
		cs:C1710.sfw_dialog.me.info("Only Quality Manager, Quality Supervisor, or Document Control can renew certifications")
		return 
	End if 
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		cs:C1710.sfw_dialog.me.info("Open the employee record in modification mode to renew a certification")
		return 
	End if 
	
	$certDate:=This:C1470._pickCertificationDate(Current date:C33(*))
	If ($certDate=!00-00-00!)
		return 
	End if 
	If ($certDate>Current date:C33(*))
		cs:C1710.sfw_dialog.me.info("Certification date cannot be in the future.")
		return 
	End if 
	
	If (Not:C34(Form:C1466.current_item.createCertification(Form:C1466.selectedCertification.UUID; 0; $certDate)))
		cs:C1710.sfw_dialog.me.alert("Could not renew this certification")
		return 
	End if 
	
	This:C1470._activate_save_cancel_button()
	This:C1470.loadCertifications()
	This:C1470.loadCertificationHistory()
	
	
// Purpose: Assign or update certification date via Actions menu (backdate / correction — Karla UAT).
// modified by 4D/PS [2026-july-27]
Function setCertificationDateFromPicker()
	
	var $uuidCert : Text
	var $defaultDate : Date
	var $certDate : Date
	var $saved : Boolean
	
	If (Form:C1466.selectedCertification=Null:C1517) || (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	If (Not:C34(This:C1470._hasQaProfile()))
		cs:C1710.sfw_dialog.me.info("Only Quality Manager, Quality Supervisor, or Document Control can modify certifications")
		return 
	End if 
	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		cs:C1710.sfw_dialog.me.info("Open the employee record in modification mode to set a certification date")
		return 
	End if 
	
	$uuidCert:=Form:C1466.selectedCertification.UUID
	If (Form:C1466.current_item.hasCertification($uuidCert))
		$defaultDate:=Form:C1466.current_item.getCertificationDate($uuidCert)
	Else 
		$defaultDate:=Current date:C33(*)
	End if 
	
	$certDate:=This:C1470._pickCertificationDate($defaultDate)
	If ($certDate=!00-00-00!)
		return 
	End if 
	If ($certDate>Current date:C33(*))
		cs:C1710.sfw_dialog.me.info("Certification date cannot be in the future.")
		return 
	End if 
	
	If (Form:C1466.current_item.hasCertification($uuidCert))
		$saved:=Form:C1466.current_item.updateCertificationDate($uuidCert; $certDate)
	Else 
		$saved:=Form:C1466.current_item.createCertification($uuidCert; 0; $certDate)
	End if 
	
	If (Not:C34($saved))
		cs:C1710.sfw_dialog.me.alert("Could not save the certification date")
		return 
	End if 
	
	This:C1470._activate_save_cancel_button()
	This:C1470.loadCertifications()
	This:C1470.loadCertificationHistory()
	
	
Function loadCertificationHistory()
	// Purpose: Assignment history for the selected certification (all past renewals — row 0 = latest).
	// Main list shows the same latest dates for every cert; this list is the audit trail when one row is selected.
	// modified by 4D/PS [2026-june-08]
	
	var $assignment_e : cs:C1710.CertificationAssignmentEntity
	var $cert_e : cs:C1710.CertificationEntity
	
	Form:C1466.certifications:=New collection:C1472()
	
	If (Form:C1466.selectedCertification=Null:C1517) || (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	
	$cert_e:=ds:C1482.Certification.get(Form:C1466.selectedCertification.UUID)
	
	For each ($assignment_e; ds:C1482.CertificationAssignment\
		.query("UUID_Staff = :1 AND UUID_Certification = :2"; Form:C1466.current_item.UUID; Form:C1466.selectedCertification.UUID)\
		.orderBy("certificationStmp desc"))
		Form:C1466.certifications.push(New object:C1471(\
			"certifiedAt"; This:C1470._formatStaffCertDate($assignment_e.certificationDate); \
			"expiredIn"; This:C1470._formatStaffCertDate(This:C1470._staffCertExpiringDate($assignment_e.certificationDate; $cert_e; $assignment_e))\
			))
	End for each 
	
	Form:C1466.certifications:=Form:C1466.certifications
	
	OBJECT SET HORIZONTAL ALIGNMENT:C706(*; "Column2"; Align center:K42:3)
	OBJECT SET HORIZONTAL ALIGNMENT:C706(*; "Column3"; Align center:K42:3)
	This:C1470._configureCertAssignmentColumns()
	
	
Function manageCertification()
	Case of 
		: (FORM Event:C1606.code=On Data Change:K2:15)
			
			// Purpose: Only qs, qm, dc may assign or remove certifications on staff.
			// modified by 4D/PS [2026-june-02]
			If (Not:C34(This:C1470._hasQaProfile()))
				cs:C1710.sfw_dialog.me.info("Only Quality Manager, Quality Supervisor, or Document Control can modify certifications")
				This:C1470.loadCertifications()
				
			Else 
				
				If (Form:C1466.selectedCertification.certified)
					// Purpose: expiredIn from certification type frequencies / one time (_ga_certificationExpiredInDays).
					// modified by 4D/PS [2026-june-02]
					Form:C1466.current_item.createCertification(Form:C1466.selectedCertification.UUID; 0)
					This:C1470.loadCertifications()
				Else 
					Form:C1466.current_item.deleteCertification(Form:C1466.selectedCertification.UUID)
					This:C1470.loadCertifications()
				End if 
				
				This:C1470.loadCertificationHistory()
				This:C1470._activate_save_cancel_button()
				
			End if 
			
		: ((FORM Event:C1606.code=On Clicked:K2:4) || (FORM Event:C1606.code=On Selection Change:K2:29))
			This:C1470.loadCertificationHistory()
			
	End case 
	
	//Function manageDataPicker($objectName : Text)
	//If (Form.sfw.checkIsInModification() && ((FORM Event.code=On Clicked) || (FORM Event.code=On Getting Focus)))
	//Case of 
	//: (OBJECT Get visible(*; "dp_terminationDate"))
	//OBJECT SET VISIBLE(*; "dp_terminationDate"; False)
	//: (OBJECT Get visible(*; "dp_retrainDate"))
	//OBJECT SET VISIBLE(*; "dp_retrainDate"; False)
	//: (OBJECT Get visible(*; "dp_hireDate"))
	//OBJECT SET VISIBLE(*; "dp_hireDate"; False)
	//: (OBJECT Get visible(*; "dp_creationDate"))
	//OBJECT SET VISIBLE(*; "dp_creationDate"; False)
	//: (FORM Event.code=On Clicked) | (FORM Event.code=On Getting Focus)
	//OBJECT Get pointer(Object named; *; "SelectedDate"; "dp_creationDate")->:=Form.current_item[$objectName]
	
	//OBJECT SET VALUE("dp_creationDate"; Form.current_item[$objectName])
	//cs.panel_staff.me.hideDatePickers()
	
	//OBJECT GET COORDINATES(*; "entryField_"+$objectName; $ob_left; $ob_top; $ob_right; $ob_bottom)
	
	//OBJECT GET COORDINATES(*; "dp_"+$objectName; $dp_left; $dp_top; $dp_right; $dp_bottom)
	
	//$dp_width:=$dp_right-$dp_left
	//$dp_height:=$dp_bottom-$dp_top
	
	//OBJECT SET COORDINATES(*; "dp_"+$objectName; $ob_right-$dp_width; $ob_bottom; $ob_right; $ob_bottom+$dp_height)
	
	//OBJECT SET VISIBLE(*; "dp_"+$objectName; True)
	//End case 
	
	//If (FORM Event.code=On Clicked)
	//Case of 
	//: (OBJECT Get visible(*; "dp_terminationDate"))
	//OBJECT SET VISIBLE(*; "dp_terminationDate"; False)
	//: (OBJECT Get visible(*; "dp_retrainDate"))
	//OBJECT SET VISIBLE(*; "dp_retrainDate"; False)
	//: (OBJECT Get visible(*; "dp_hireDate"))
	//OBJECT SET VISIBLE(*; "dp_hireDate"; False)
	//: (OBJECT Get visible(*; "dp_creationDate"))
	//OBJECT SET VISIBLE(*; "dp_creationDate"; False)
	//End case 
	//End if 
	//End if 
	
Function hideDatePickers()
	OBJECT SET VISIBLE:C603(*; "dp_@"; False:C215)
	
	//mark:- setting page
	
Function userSetting()
	
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.user#Null:C1517)
		OBJECT SET TITLE:C194(*; "pup_user"; Form:C1466.current_item.user.login)
	Else 
		OBJECT SET TITLE:C194(*; "pup_user"; "Select a Golden Altos account")
	End if 
	
Function pup_user()
	var $isInModification : Boolean
	var $esUsers : cs:C1710.sfw_UserSelection
	var $eUser : cs:C1710.sfw_UserEntity
	
	$isInModification:=sfw_checkIsInModification
	
	If ($isInModification)
		$refMenu:=Create menu:C408
		
		// non affected users
		$affectedUsers:=ds:C1482.Staff.all().extract("UUID_User")
		$esUsers:=ds:C1482.sfw_User.query(" (NOT(UUID IN :1) AND (isInactive = :2) )  OR UUID = :3 ORDER BY login"; $affectedUsers; False:C215; Form:C1466.current_item.UUID_User)
		
		For each ($eUser; $esUsers)
			APPEND MENU ITEM:C411($refMenu; $eUser.login; *)
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; $eUser.UUID)
			If ($eUser.UUID=Form:C1466.current_item.UUID_User)
				SET MENU ITEM MARK:C208($refMenu; -1; "-")
			End if 
		End for each 
		If ($esUsers.length>0)
			APPEND MENU ITEM:C411($refMenu; "-")
		End if 
		APPEND MENU ITEM:C411($refMenu; "Create a user based on staff information")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "createUser")
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		RELEASE MENU:C978($refMenu)
		
		Case of 
			: ($choose="")
				
			: ($choose="createUser")
				$eUser:=ds:C1482.sfw_User.new()
				$eUser.firstName:=Form:C1466.current_item.firstName
				$eUser.lastName:=Form:C1466.current_item.lastName
				
				$eUser.moreData:=New object:C1471()
				$recodNumber:=ds:C1482.sfw_Counter.getNextValue("sfw_User")
				$eUser.moreData.barcodeData:=String:C10($recodNumber; "0000000000")
				
				$info:=$eUser.save()
				$eUser.setLogin()
				$info:=$eUser.save()
				//If ($info.success)
				//$context:=New object
				//$context.target:=Form.current_item.UUID
				//$context.targetDataclass:="Staff"
				//$context.userName:=$eUser.fullName
				//$staff:=ds.Staff.query("UUID_User = :1"; cs.sfw_userManager.me.info.UUID).first()
				//$context.staffName:=$staff.fullName
				//$users:=New collection($staff.user.UUID)
				
				//$users:=$users.distinct()
				//cs.sfw_notificationManager.me._notify("UserAccountCreated"; $users; $context)
				//End if 
				
				
				Form:C1466.current_item.UUID_User:=$eUser.UUID
				OBJECT SET TITLE:C194(*; "pup_user"; $eUser.login)
			Else 
				Form:C1466.current_item.UUID_User:=$choose
				OBJECT SET TITLE:C194(*; "pup_user"; Form:C1466.current_item.user.login)
		End case 
	End if 
	
	
Function bActionCertifications()
	
	//var $refMenu : Integer
	var $choose : Text
	var $assignment_e : cs:C1710.CertificationAssignmentEntity
	
	$refMenu:=Create menu:C408
	
	// Purpose: Full employee training record (all valid + expired certifications) — available
	// from the Certifications tab Actions menu as requested in client feedback.
	// modified by 4D/PS [2026-may-21]
	APPEND MENU ITEM:C411($refMenu; "Print Certification Training")
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--printCertTraining")
	
	If (Form:C1466.selectedCertification#Null:C1517)
		APPEND MENU ITEM:C411($refMenu; "-")
		APPEND MENU ITEM:C411($refMenu; "Print Certificate of Completion")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--print")
		If (Not:C34(Form:C1466.current_item.hasCertification(Form:C1466.selectedCertification.UUID)))
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
		
		// Purpose: Backdate or correct certification date (Karla UAT — checkbox still uses today).
		// modified by 4D/PS [2026-july-27]
		If (This:C1470._hasQaProfile()) && (Form:C1466.sfw.checkIsInModification())
			APPEND MENU ITEM:C411($refMenu; "-")
			APPEND MENU ITEM:C411($refMenu; "Set certification date...")
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--setCertDate")
		End if 
		
		// Purpose: QA punch-in override for expired certification (Karla 2.d — qs, qm, dc).
		// modified by 4D/PS [2026-june-02]
		If (This:C1470._hasQaProfile()) && (Form:C1466.sfw.checkIsInModification())
			$assignment_e:=ds:C1482.CertificationAssignment\
				.query("UUID_Staff = :1 AND UUID_Certification = :2"; Form:C1466.current_item.UUID; Form:C1466.selectedCertification.UUID)\
				.orderBy("certificationStmp desc").first()
			If ($assignment_e#Null:C1517) && (Not:C34($assignment_e.validityActive))
				APPEND MENU ITEM:C411($refMenu; "-")
				If (Bool:C1537($assignment_e.moreData.overrideCertExpired))
					APPEND MENU ITEM:C411($refMenu; "Revoke punch-in override (expired cert)")
					SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--revokeOverride")
				Else 
					APPEND MENU ITEM:C411($refMenu; "Allow punch-in despite expired certification")
					SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--grantOverride")
				End if 
			End if 
		End if 
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	
	Case of 
		: ($choose="--printCertTraining")
			staff_print_cert_training
		: ($choose="--setCertDate")
			This:C1470.setCertificationDateFromPicker()
		: ($choose="--grantOverride")
			If (Form:C1466.selectedCertification#Null:C1517)
				Form:C1466.current_item.setCertificationOverride(Form:C1466.selectedCertification.UUID; True:C214)
				This:C1470.loadCertifications()
			End if 
		: ($choose="--revokeOverride")
			If (Form:C1466.selectedCertification#Null:C1517)
				Form:C1466.current_item.setCertificationOverride(Form:C1466.selectedCertification.UUID; False:C215)
				This:C1470.loadCertifications()
			End if 
		: ($choose="--print")
			PRINT SETTINGS:C106()
			
			OPEN PRINTING JOB:C995
			
			SET PRINT OPTION:C733(Orientation option:K47:2; 2)
			
			$form:=New object:C1471(\
				"staffName"; Form:C1466.current_item.fullName; \
				"certificationName"; Form:C1466.selectedCertification.name; \
				"issuedBy"; "GOLDEN ALTOS CORPORATION"; \
				"date"; String:C10(Form:C1466.selectedCertification.expiredIn; System date long:K1:3)\
				)
			
			Print form:C5([Certification:124]; "certification_of_completion"; $form; Form detail:K43:1)
			
			CLOSE PRINTING JOB:C996
	End case 
	//End if 
	
	///*
Function pup_division()  //selectDivision()
	Case of 
		: (FORM Event:C1606.code=On Clicked:K2:4)
			If (Form:C1466.sfw.checkIsInModification())
				OBJECT GET COORDINATES:C663(*; "pup_division"; $l; $t; $r; $b)
				CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
				
				$form:=New object:C1471(\
					"colName"; "name"; \
					"lb_items"; ds:C1482.Division.all(); \
					"allData"; ds:C1482.Division.all(); \
					"dataclass"; "Division"\
					)
				
				$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b)
				DIALOG:C40("selectNto1"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (ok=1)
					If ($form.item#Null:C1517)
						Form:C1466.current_item.UUID_Division:=$form.item.UUID
					Else 
						Form:C1466.current_item.UUID_Division:=16*"00"
					End if 
					
					This:C1470._activate_save_cancel_button()
				End if 
			End if 
			This:C1470.drawPup_Division()
			
		: (FORM Event:C1606.code=On Mouse Move:K2:35)
			SET CURSOR:C469(9000)
	End case 
	
	//*/
	
	
Function drawPup_Division()
	
	If (Form:C1466.current_item#Null:C1517)
		
		$division:=ds:C1482.Division.query("UUID= :1"; Form:C1466.current_item.UUID_Division).first() || New object:C1471()
		$divisionName:=$division.name || ""
		
		//If ($divisionName=Null)
		
		//$divisionName:=""
		
		//End if 
		
		$color:=""
		$pathIcon:=(Length:C16($color)#0) ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_division"; $divisionName; $pathIcon; ($division=Null:C1517))
		
	End if 
	
	
Function pup_citizenshipStatus()
	If (Form:C1466.sfw.checkIsInModification())
		$menu:=Create menu:C408
		
		APPEND MENU ITEM:C411($menu; "US Citizen"; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; "--us-citizen")
		
		If (Form:C1466.current_item.citizenShipStatus="US Citizen")
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
			If (Is Windows:C1573)
				SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
			End if 
		End if 
		
		APPEND MENU ITEM:C411($menu; "US Permanent Resident"; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; "--us-permanent-resident")
		
		If (Form:C1466.current_item.citizenShipStatus="US Permanent Resident")
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
			If (Is Windows:C1573)
				SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
			End if 
		End if 
		
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		Case of 
			: ($choose="--us-citizen")
				Form:C1466.current_item.citizenShipStatus:="US Citizen"
				
			: ($choose="--us-permanent-resident")
				Form:C1466.current_item.citizenShipStatus:="US Permanent Resident"
				
			Else 
				Form:C1466.current_item.citizenShipStatus:=""
		End case 
		
	End if 
	This:C1470.drawPup_citizenshipStatus()
	
Function drawPup_citizenshipStatus()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.sfw.drawButtonPup("pup_citizenshipStatus"; Form:C1466.current_item.citizenShipStatus; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.citizenShipStatus=Null:C1517))
	End if 
	
	
	//TODO - Check the logic and fix the data Structure 
Function drawPup_Department()
	
	If (Form:C1466.current_item#Null:C1517)
		
		$memberships:=ds:C1482.Membership.query("UUID_Staff= :1"; Form:C1466.current_item.UUID)  //.first() || New object()
		If ($memberships.length>0)
			$team:=$memberships[0].team
			If ($team#Null:C1517)
				$teamName:=$team.name
			Else 
				$teamName:=""
			End if 
		Else 
			$teamName:=""
		End if 
		
		$color:=""
		$pathIcon:=(Length:C16($color)#0) ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_department"; $teamName; $pathIcon; ($team=Null:C1517))
		
	End if 
	
	///*
Function pup_department()
	
	// Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
		
		$menu:=Create menu:C408
		
		If (Storage:C1525.cache=Null:C1517) || (Storage:C1525.cache.teams=Null:C1517)
			
			ds:C1482.Team.cacheLoad()
			
		End if 
		
		For each ($team; Storage:C1525.cache.teams)
			
			APPEND MENU ITEM:C411($menu; $team.name; *)
			SET MENU ITEM PARAMETER:C1004($menu; -1; $team.UUID)
			If (Form:C1466.current_item.memberships.length>0)
				If ($team.UUID=Form:C1466.current_item.memberships[0].UUID_Team)
					
					SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
					
					If (Is Windows:C1573)
						
						SET MENU ITEM STYLE:C425($menu; -1; Bold:K14:2)
						
					End if 
				End if 
			End if 
		End for each 
		
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		Case of 
				
			: (Length:C16($choose)#0)
				
				$team:=ds:C1482.Team.get($choose)
				
				If (Form:C1466.current_item.memberships.length>0)
					
					$memberShip:=ds:C1482.Membership.get(Form:C1466.current_item.memberships[0].UUID)
					$memberShip.UUID_Team:=$team.UUID
					$res:=$memberShip.save()
					
				Else 
					$memberShip:=ds:C1482.Membership.new()
					$memberShip.UUID_Team:=$team.UUID
					$memberShip.UUID_Staff:=Form:C1466.current_item.UUID
					$res:=$memberShip.save()
					
				End if 
				
				This:C1470._activate_save_cancel_button()
				
		End case 
	End if 
	
	This:C1470.drawPup_Department()
	
	//*/