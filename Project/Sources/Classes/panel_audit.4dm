singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
		
		Form:C1466.allIssuesClosed:=Num:C11(Form:C1466.current_item.overallStatus=OBJECT Get title:C1068(*; "entryField_rb_allIssuesClosed"))
		Form:C1466.someOpen:=Num:C11(Form:C1466.current_item.overallStatus=OBJECT Get title:C1068(*; "entryField_rb_someOpen"))
		Form:C1466.furtherAction:=Num:C11(Form:C1466.current_item.overallStatus=OBJECT Get title:C1068(*; "entryField_rb_furtherAction"))
		
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				
				This:C1470.loadTeam()
				This:C1470.loadActivities()
				
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
	// Purpose: Require supplier company when audit type is External (no conditional rule in setValidationRule).
	// modified by 4D/PS [2026-may-26]
	This:C1470.applyConditionalValidationRules()
	
	
Function applyConditionalValidationRules()
	
	If (Form:C1466.current_item=Null:C1517) || (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return 
	End if 
	
	If (Form:C1466.current_item.type="External")
		If (cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10(Form:C1466.current_item.UUID_Company)))
			Form:C1466.canValidate:=False:C215
			Form:C1466.validationRulesPassedWithSuccess:=False:C215
			If (Form:C1466.validationRulesMessages=Null:C1517)
				Form:C1466.validationRulesMessages:=New collection:C1472
			End if 
			If (Form:C1466.validationRulesMessages.indexOf("Company is mandatory for external audits")=-1)
				Form:C1466.validationRulesMessages.push("Company is mandatory for external audits")
			End if 
			OBJECT SET RGB COLORS:C628(*; "pup_company"; "black"; 0x00FAA9AB)
		End if 
	End if 
	
	
Function drawPup_XXX()
	//This function updates the dropdown by displaying the name
	Form:C1466.sfw.drawButtonPup("pup_xxx"; $xxxName; "xxxx.png"; (Form:C1466.current_item.xxxx=Null:C1517))
	
	
Function pup_XXX()
	//Create pop up menu
	
Function redrawAndSetVisible()
	
	var $eAttach : cs:C1710.sfw_DocumentEntity
	var $caption : Text
	var $uuidDoc : Text
	var $normalized : Text
	var $parts : Collection
	
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	
	This:C1470.drawPup_docType()
	
	// Purpose: Keep file name label aligned with framework attachment metadata or legacy sourcePath (no embedded blob dependency).
	// modified by 4D/PS [2026-may-26]
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.document#Null:C1517)
		$caption:=""
		$uuidDoc:=String:C10(Form:C1466.current_item.document.UUID_sfwDocument)
		If ($uuidDoc#"") && (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($uuidDoc)))
			$eAttach:=ds:C1482.sfw_Document.get($uuidDoc)
			If ($eAttach#Null:C1517)
				$caption:=String:C10($eAttach.name)
				If (String:C10($eAttach.extension)#"")
					If (Position:C15("."; $caption)=0)
						$caption:=$caption+"."+Lowercase:C14(String:C10($eAttach.extension))
					End if 
				End if 
			End if 
		End if 
		If ($caption="")
			$normalized:=Replace string:C233(String:C10(Form:C1466.current_item.document.sourcePath); "\\"; "/")
			$parts:=Split string:C1554($normalized; "/"; sk trim spaces:K86:2)
			If ($parts.length>0)
				$caption:=String:C10($parts[$parts.length-1])
			Else 
				$caption:=String:C10(Form:C1466.current_item.document.sourcePath)
			End if 
		End if 
		OBJECT SET TITLE:C194(*; "fileName"; $caption)
	End if 
	
	This:C1470.drawPup_company()
	This:C1470.drawPup_departement()
	This:C1470.drawPup_status()
	This:C1470.drawPup_auditType()
	This:C1470.drawPup_process()
	
	OBJECT SET VISIBLE:C603(*; "bUploadDocument"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "btnDatePicker@"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "btnTimePick@"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET VISIBLE:C603(*; "@_company"; (Form:C1466.current_item.type="External"))
	
	OBJECT SET ENABLED:C1123(*; "entryField_rb_@"; Form:C1466.sfw.checkIsInModification())
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$offset:=4
	
	Case of 
			
		: (FORM Get current page:C276(*)=1)
			OBJECT GET COORDINATES:C663(*; "lb_activities"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "lb_activities"; $g; $h; $widthSubform-5; $b)
			
			OBJECT GET COORDINATES:C663(*; "entryField_scope"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "entryField_scope"; $g; $h; $d; $heightSubform-15)
			
			OBJECT GET COORDINATES:C663(*; "entryField_objectives"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "entryField_objectives"; $g; $h; $widthSubform-30; $heightSubform-15)
			
		: (FORM Get current page:C276(*)=2)
			
			OBJECT GET COORDINATES:C663(*; "entryField_comments"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "entryField_comments"; $g; $h; $d; $heightSubform-15)
			
		: (FORM Get current page:C276(*)=3)
			
			OBJECT GET COORDINATES:C663(*; "entryField_findings"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "entryField_findings"; $g; $h; $d; $heightSubform-15)
			
		: (FORM Get current page:C276(*)=4)
			
			OBJECT GET COORDINATES:C663(*; "entryField_recommendations"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "entryField_recommendations"; $g; $h; $d; $heightSubform-15)
			
			OBJECT GET COORDINATES:C663(*; "entryField_remainingGaps"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "entryField_remainingGaps"; $g; $h; $widthSubform-30; $heightSubform-15)
			
		: (FORM Get current page:C276(*)=5)
			
			OBJECT GET COORDINATES:C663(*; "entryField_wpDoc"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "entryField_wpDoc"; $g; $h; $d; $heightSubform)
			
	End case 
	
	If (FORM Get current page:C276(*)#5) & (FORM Get current page:C276(*)#6)
		_ga_buildAuditReport()
		
	Else 
		If (Split string:C1554(WP Get text:C1575(Form:C1466.current_item.auditReport); ";"; sk ignore empty strings:K86:1+sk trim spaces:K86:2).join(";")="")
			_ga_buildAuditReport()
			
		End if 
		
	End if 
	
	Form:C1466.sfw.drawHTab()
	
	
Function drawPup_docType()
	
	// Purpose: Avoid dereferencing a missing embedded document object when drawing the category picker.
	// modified by 4D/PS [2026-may-26]
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.document#Null:C1517)
		$documentCategory:=ds:C1482.DocumentCategory.query("name =:1"; Form:C1466.current_item.document.code).first() || New object:C1471()
		
		$documentCategoryName:=$documentCategory.name
		If ($documentCategoryName=Null:C1517)
			$documentCategoryName:=""
		End if 
		$color:="#FFFFFF"
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_docType"; $documentCategoryName; $pathIcon; ($documentCategory=Null:C1517))
	End if 
	
	
Function pup_docType()
	//Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
		var $hListItems : Collection
		var $hSousListItems : Collection
		
		$hListItems:=ds:C1482.DocumentCategory.all().toCollection().extract("name")
		
		$hList:=Create menu:C408
		
		$hListItemsLength:=$hListItems.length
		
		For ($i; 0; $hListItemsLength-1)
			
			APPEND MENU ITEM:C411($hList; $hListItems[$i]; *)
			SET MENU ITEM PARAMETER:C1004($hList; -1; $hListItems[$i])
			
		End for 
		
		$choose:=Dynamic pop up menu:C1006($hList)
		RELEASE MENU:C978($hList)
		Case of 
			: ($choose#"")
				Form:C1466.current_item.document.code:=$choose
		End case 
		
	End if 
	
	This:C1470.drawPup_docType()
	
	
Function drawPup_company()
	If (Form:C1466.current_item#Null:C1517)
		$company:=ds:C1482.Supplier.query("UUID= :1"; Form:C1466.current_item.UUID_Company).first() || New object:C1471()
		$companyName:=$company.name
		If ($companyName=Null:C1517)
			$companyName:=""
		End if 
		$color:=""
		$pathIcon:=""
		Form:C1466.sfw.drawButtonPup("pup_company"; $companyName; $pathIcon; ($company=Null:C1517))
		
	End if 
	
	
Function pup_company()
	//Create pop up menu
	
	If (Form:C1466.sfw.checkIsInModification())
		
		OBJECT GET COORDINATES:C663(*; "pup_company"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		$allSuppliers:=ds:C1482.Supplier.all()
		$form:=New object:C1471(\
			"colName"; "name"; \
			"allData"; $allSuppliers; \
			"dataclass"; "Supplier"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (ok=1)
			Form:C1466.current_item.UUID_Company:=$form.item.UUID
			cs:C1710.panel_audit.me._activate_save_cancel_button()
		End if 
	End if 
	
	This:C1470.drawPup_company()
	
	
Function btnOpenCompany()
	
	$es:=ds:C1482.Supplier.query("UUID =:1"; Form:C1466.current_item.UUID_Company)
	
	If ($es.length>0)
		Form:C1466.sfw.openInANewWindow($es[0]; "qualityAssurance"; "Supplier")
	End if 
	
	
Function drawPup_departement()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("Team"; "UUID"; "UUID_Team"; "pup_departement")
	End if 
	
	
Function pup_departement()
	//Create pop up menu
	Form:C1466.current_item.pup("teams"; "Team"; "UUID"; "UUID_Team")
	This:C1470.drawPup_departement()
	
	
Function drawPup_status()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("AuditStatus"; "UUID"; "UUID_AuditStatus"; "pup_status")
	End if 
	
	
Function pup_status()
	//Create pop up menu
	Form:C1466.current_item.pup("auditStatus"; "AuditStatus"; "UUID"; "UUID_AuditStatus")
	This:C1470.drawPup_status()
	
	
Function drawPup_process()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("ProcessType"; "UUID"; "UUID_ProcessType"; "pup_process")
	End if 
	
	
Function pup_process()
	//Create pop up menu
	Form:C1466.current_item.pup("processTypes"; "ProcessType"; "UUID"; "UUID_ProcessType")
	This:C1470.drawPup_process()
	
	
Function drawPup_auditType()
	If (Form:C1466.current_item#Null:C1517)
		$auditTypeName:=Form:C1466.current_item.type  //$customer.name
		If ($auditTypeName=Null:C1517)
			$auditTypeName:=""
		End if 
		$color:="#FFFFFF"  //cs.sfw_htmlColor.me.getName($customer.color)
		$pathIcon:=($color#"") ? "sfw/colors/"+$color+"-circle.png" : "sfw/image/skin/rainbow/icon/spacer-1x24.png"
		Form:C1466.sfw.drawButtonPup("pup_auditType"; $auditTypeName; $pathIcon; (Form:C1466.current_item=Null:C1517))
	End if 
	
	
Function pup_auditType()
	//Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
		var $hListItems : Collection
		var $hSousListItems : Collection
		
		$hListItems:=New collection:C1472("External"; "Internal")
		
		$hList:=Create menu:C408
		
		$hListItemsLength:=$hListItems.length
		$k:=1
		For ($i; 0; $hListItemsLength-1)
			
			APPEND MENU ITEM:C411($hList; $hListItems[$i]; *)
			SET MENU ITEM PARAMETER:C1004($hList; -1; $hListItems[$i])
			$k:=$k+1
		End for 
		
		$choose:=Dynamic pop up menu:C1006($hList)
		RELEASE MENU:C978($hList)
		Case of 
			: ($choose#"")
				If ($choose="Internal")
					Form:C1466.current_item.UUID_Company:=""
				End if 
				Form:C1466.current_item.type:=$choose
				cs:C1710.panel_audit.me._activate_save_cancel_button()
		End case 
		
	End if 
	
	This:C1470.drawPup_auditType()
	
	
Function btnTimePickerCreate($object; $attribut)
	If (Form:C1466.sfw.checkIsInModification())
		
		$form:=New object:C1471
		$form.timeStamp:=Form:C1466.current_item.stmpCreationDate
		OBJECT GET COORDINATES:C663(Self:C308->; $left; $top; $rigth; $bottom)
		
		CONVERT COORDINATES:C1365($left; $bottom; XY Current form:K27:5; XY Main window:K27:8)
		Open window:C153($left; $bottom+30; $left+237; $bottom+206; Movable dialog box:K34:7; "Enter Time")
		DIALOG:C40("_ga_TimePicker"; $form)
		
		If (OK=1)
			
			$object[$attribut]:=$form.timeStamp
			This:C1470._activate_save_cancel_button()
			
		End if 
		
	End if 
	
	
Function loadTeam()
	
	Form:C1466.lb_team:=New collection:C1472()
	
	If (Form:C1466.current_item#Null:C1517)
		
		Form:C1466.lb_team:=Form:C1466.current_item.rebuidTeam()
		
	End if 
	
	
Function loadActivities()
	
	Form:C1466.lb_activities:=New collection:C1472()
	
	If (Form:C1466.current_item#Null:C1517)
		
		Form:C1466.lb_activities:=Form:C1466.current_item.rebuidActivities()
		
	End if 
	
	
Function bActionTeam()
	
	$refMenus:=New collection:C1472
	$mainMenu:=Create menu:C408
	$refMenus.push($mainMenu)
	
	APPEND MENU ITEM:C411($mainMenu; "Add a team member"; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--add")
	If (sfw_checkIsInModification)=False:C215
		DISABLE MENU ITEM:C150($mainMenu; -1)
	End if 
	
	APPEND MENU ITEM:C411($mainMenu; "Delete a team member"; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--delete")
	If (sfw_checkIsInModification)=False:C215
		DISABLE MENU ITEM:C150($mainMenu; -1)
	Else 
		If (Form:C1466.auditMember=Null:C1517)
			DISABLE MENU ITEM:C150($mainMenu; -1)
		End if 
	End if 
	
	APPEND MENU ITEM:C411($mainMenu; "modify a team member"; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--update")
	
	If (sfw_checkIsInModification)=False:C215
		DISABLE MENU ITEM:C150($mainMenu; -1)
	Else 
		If (Form:C1466.auditMember=Null:C1517)
			DISABLE MENU ITEM:C150($mainMenu; -1)
		End if 
	End if 
	
	OBJECT GET COORDINATES:C663(*; "bActionTeam"; $g; $h; $d; $b)
	CONVERT COORDINATES:C1365($g; $b; XY Current form:K27:5; XY Current window:K27:6)
	$choose:=Dynamic pop up menu:C1006($mainMenu; ""; $g; $b)
	For each ($refMenu; $refMenus)
		RELEASE MENU:C978($refMenu)
	End for each 
	
	Case of 
		: ($choose="")
		: ($choose="--delete")
			Form:C1466.lb_team.remove(Form:C1466.auditMemberPosition-1)
			Form:C1466.current_item.auditTeam.teamMembers:=Form:C1466.lb_team
			cs:C1710.panel_audit.me._activate_save_cancel_button()
			
		: ($choose="--add")
			
			$form:=New object:C1471()
			
			$winRef:=Open form window:C675("_ga_auditTeamSingle"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("_ga_auditTeamSingle"; $form)
			CLOSE WINDOW:C154($winRef)
			
			If (OK=1)
				
				Form:C1466.current_item.auditTeam.teamMembers.push($form)
				cs:C1710.panel_audit.me._activate_save_cancel_button()
				
			End if 
			
			
		: ($choose="--update")
			
			$form:=New object:C1471
			
			$form:=OB Copy:C1225(Form:C1466.lb_team[Form:C1466.auditMemberPosition-1])
			
			$winRef:=Open form window:C675("_ga_auditTeamSingle"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("_ga_auditTeamSingle"; $form)
			
			If (OK=1)
				Form:C1466.lb_team[Form:C1466.auditMemberPosition-1]:=$form
				Form:C1466.current_item.auditTeam.teamMembers:=Form:C1466.lb_team
				cs:C1710.panel_audit.me._activate_save_cancel_button()
			End if 
			
			
	End case 
	
	
Function bActionActivities()
	
	$refMenus:=New collection:C1472
	$mainMenu:=Create menu:C408
	$refMenus.push($mainMenu)
	
	APPEND MENU ITEM:C411($mainMenu; "Add audit activity"; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--add")
	If (sfw_checkIsInModification)=False:C215
		DISABLE MENU ITEM:C150($mainMenu; -1)
	End if 
	
	APPEND MENU ITEM:C411($mainMenu; "Delete audit activity"; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--delete")
	If (sfw_checkIsInModification)=False:C215
		DISABLE MENU ITEM:C150($mainMenu; -1)
	Else 
		If (Form:C1466.selectedActivity=Null:C1517)
			DISABLE MENU ITEM:C150($mainMenu; -1)
		End if 
	End if 
	
	APPEND MENU ITEM:C411($mainMenu; "modify audit activity"; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--update")
	
	If (sfw_checkIsInModification)=False:C215
		DISABLE MENU ITEM:C150($mainMenu; -1)
	Else 
		If (Form:C1466.selectedActivity=Null:C1517)
			DISABLE MENU ITEM:C150($mainMenu; -1)
		End if 
	End if 
	
	OBJECT GET COORDINATES:C663(*; "bActionActivity"; $g; $h; $d; $b)
	CONVERT COORDINATES:C1365($g; $b; XY Current form:K27:5; XY Current window:K27:6)
	$choose:=Dynamic pop up menu:C1006($mainMenu; ""; $g; $b)
	For each ($refMenu; $refMenus)
		RELEASE MENU:C978($refMenu)
	End for each 
	
	Case of 
		: ($choose="")
		: ($choose="--delete")
			Form:C1466.lb_activities.remove(Form:C1466.selectedActivityPosition-1)
			Form:C1466.current_item.activities.collection:=Form:C1466.lb_activities
			cs:C1710.panel_audit.me._activate_save_cancel_button()
			
		: ($choose="--add")
			
			$form:=New object:C1471()
			$form.date:=Current date:C33(*)
			$winRef:=Open form window:C675("_ga_auditActivitySingle"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("_ga_auditActivitySingle"; $form)
			CLOSE WINDOW:C154($winRef)
			
			If (OK=1)
				
				Form:C1466.current_item.activities.collection.push($form)
				cs:C1710.panel_audit.me._activate_save_cancel_button()
				
			End if 
			
			
		: ($choose="--update")
			
			
			$form:=New object:C1471
			
			$form:=OB Copy:C1225(Form:C1466.lb_activities[Form:C1466.selectedActivityPosition-1])
			
			$winRef:=Open form window:C675("_ga_auditActivitySingle"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("_ga_auditActivitySingle"; $form)
			
			If (OK=1)
				Form:C1466.lb_activities[Form:C1466.selectedActivityPosition-1]:=$form
				Form:C1466.current_item.activities.collection:=Form:C1466.lb_activities
				cs:C1710.panel_audit.me._activate_save_cancel_button()
			End if 
			
			
	End case 
	
	