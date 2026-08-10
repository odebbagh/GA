singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
		//OBJECT SET VISIBLE(*; "wr30_@"; (Form.current_item.getCertiExpiredIn(30).length>0))
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
	End case 
	
	//Form.sfw.drawHTab()
	
	
Function loadAllTabs()
	// Apr 22, 2026 4DFix: loadCommunications() was missing — communications could be stale when switching records while staying on tab 1
	This:C1470.loadCommunications()
	This:C1470.loadCertifications()
	
Function loadCommunications()
	Form:C1466.subFormCommunication:=New object:C1471(\
		"communications"; Form:C1466.current_item.contactDetails.communications; \
		"situation"; Form:C1466.situation\
		)
	
	Form:C1466.subFormCommunication:=Form:C1466.subFormCommunication
	
Function loadCertifications()
	GOTO OBJECT:C206(*; "lb_assignments")
	Form:C1466.selectedCertification:=Form:C1466.selectedCertification
	Form:C1466.lb_assignments:=New collection:C1472()
	
	For each ($certification; ds:C1482.Certification.all().orderBy("ref asc"))
		Form:C1466.lb_assignments.push(New object:C1471(\
			"UUID"; $certification.UUID; \
			"name"; $certification.name; \
			"duration"; $certification.duration; \
			"oneTime"; $certification.oneTime; \
			"expiredIn"; Form:C1466.current_item.getExpiredDate($certification.UUID); \
			"certifiedAt"; Form:C1466.current_item.getCertificationDate($certification.UUID); \
			"certified"; Form:C1466.current_item.hasCertification($certification.UUID)\
			))
	End for each 
	
	$find:=""
	
	$find:=cs:C1710.sfw_userManager.me.authorizedProfiles.find(Formula:C1597((Value type:C1509($1.value)=Is text:K8:3) && ($1.value=$2)); "qm")
	
	If ($find#"")
		//TRACE
		$nb_cols:=LISTBOX Get number of columns:C831(*; "lb_assignments")
		
		If ($nb_cols=2)
			var $NilPtr : Pointer
			var $width_new_col : Integer:=70
			
			LISTBOX INSERT COLUMN FORMULA:C970(*; "lb_assignments"; 2; "col_expired_in"; "This.expiredIn"; Is date:K8:7; "hd_expiredIn"; $NilPtr)
			LISTBOX INSERT COLUMN FORMULA:C970(*; "lb_assignments"; 2; "col_certified_at"; "This.certifiedAt"; Is date:K8:7; "hd_certifiedAt"; $NilPtr)
			
			$width:=LISTBOX Get column width:C834(*; "header_certifName")
			
			$width:=LISTBOX SET COLUMN WIDTH:C833(*; "header_certifName"; $width-($width_new_col*2))
			$width:=LISTBOX SET COLUMN WIDTH:C833(*; "col_certified_at"; $width_new_col)
			$width:=LISTBOX SET COLUMN WIDTH:C833(*; "col_expired_in"; $width_new_col)
			
			OBJECT SET TITLE:C194(*; "hd_certifiedAt"; "Certified At")
			OBJECT SET TITLE:C194(*; "hd_expiredIn"; "Expired In")
			
			OBJECT SET FONT STYLE:C166(*; "hd_certifiedAt"; Bold:K14:2)
			OBJECT SET FONT STYLE:C166(*; "hd_expiredIn"; Bold:K14:2)
			
			OBJECT SET FORMAT:C236(*; "col_certified_at"; "dd/MM/yyyy blankIfNull")
			OBJECT SET FORMAT:C236(*; "col_expired_in"; "dd/MM/yyyy blankIfNull")
			
			OBJECT SET HORIZONTAL ALIGNMENT:C706(*; "col_certified_at"; Align center:K42:3)
			OBJECT SET HORIZONTAL ALIGNMENT:C706(*; "col_expired_in"; Align center:K42:3)
		End if 
	End if 
	
Function manageCertification()
	Case of 
		: (FORM Event:C1606.code=On Data Change:K2:15)
			If (Form:C1466.selectedCertification.certified)
				Form:C1466.current_item.createCertification(Form:C1466.selectedCertification.UUID; (Not:C34(Form:C1466.selectedCertification.oneTime)) ? Form:C1466.selectedCertification.duration : 0)
				This:C1470.loadCertifications()
			Else 
				Form:C1466.current_item.deleteCertification(Form:C1466.selectedCertification.UUID)
				This:C1470.loadCertifications()
			End if 
			
			This:C1470._activate_save_cancel_button()
			
		: (FORM Event:C1606.code=On Clicked:K2:4)
			$find:=cs:C1710.sfw_userManager.me.authorizedProfiles.find(Formula:C1597((Value type:C1509($1.value)=Is text:K8:3) && ($1.value=$2)); "qm")
			
			If ($find#"")
				
			End if 
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
	//If (Form.sfw.checkIsInModification())
	If (Form:C1466.selectedCertification#Null:C1517)
		$refMenu:=Create menu:C408
		APPEND MENU ITEM:C411($refMenu; "Print Certificate of Completion")
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--print")
		If (Not:C34(Form:C1466.current_item.hasCertification(Form:C1466.selectedCertification.UUID)))
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
		
		$choose:=Dynamic pop up menu:C1006($refMenu)
		
		Case of 
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
	Else 
		cs:C1710.sfw_dialog.me.alert("No Certification Selected !")
	End if 
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
	
/*
Function pup_division()
	
// Create pop up menu
If (Form.sfw.checkIsInModification())
	
$menu:=Create menu
	
If (Storage.cache=Null) || (Storage.cache.divisions=Null)
	
ds.Division.cacheLoad()
	
End if 
	
For each ($equipmentDivision; Storage.cache.divisions)
	
APPEND MENU ITEM($menu; $equipmentDivision.name; *)
SET MENU ITEM PARAMETER($menu; -1; $equipmentDivision.UUID)
	
If ($equipmentDivision.UUID=Form.current_item.UUID_Division)
	
SET MENU ITEM MARK($menu; -1; Char(18))
	
If (Is Windows)
	
SET MENU ITEM STYLE($menu; -1; Bold)
	
End if 
End if 
End for each 
	
$choose:=Dynamic pop up menu($menu)
RELEASE MENU($menu)
	
Case of 
	
//________________________________________
: (Length($choose)#0)
	
$equipmentDivision:=ds.Division.get($choose)
Form.current_item.UUID_Division:=$equipmentDivision.UUID
This._activate_save_cancel_button()
//________________________________________
End case 
End if 
	
This.drawPup_Division()
*/
	
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
				
				//________________________________________
			: (Length:C16($choose)#0)
				
				$team:=ds:C1482.Team.get($choose)
				//START TRANSACTION
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
				//VALIDATE TRANSACTION
				This:C1470._activate_save_cancel_button()
				
				//________________________________________
		End case 
	End if 
	
	This:C1470.drawPup_Department()
	
	//*/