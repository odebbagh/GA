
singleton Class constructor
	//It's a singleton class
	
Function formMethod()
	Form:C1466.sfw.panelFormMethod()
	OBJECT SET ENTERABLE:C238(*; "entryField_ref"; False:C215)
	If (Form:C1466.sfw.updateOfPanelNeeded())
		This:C1470.loadAssignedStaff()
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())
		This:C1470.loadAssignedStaff()
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function redrawAndSetVisible()
	
	var $inModification : Boolean
	var $canEditFreq : Boolean
	
	$inModification:=Form:C1466.sfw.checkIsInModification()
	$canEditFreq:=$inModification && (Form:C1466.current_item#Null:C1517) && (Not:C34(Form:C1466.current_item.oneTime))
	OBJECT SET ENTERABLE:C238(*; "entryField_ref"; False:C215)
	OBJECT SET ENABLED:C1123(*; "entryField_name"; $inModification)
	// Purpose: Duration is assignment validity in days (editable); independent of re-training frequency checkboxes.
	// modified by 4D/PS [2026-june-02]
	OBJECT SET ENABLED:C1123(*; "entryField_duration"; $canEditFreq)
	OBJECT SET ENTERABLE:C238(*; "entryField_duration"; $canEditFreq)
	OBJECT SET ENABLED:C1123(*; "cb_freqQuarterly"; $canEditFreq)
	OBJECT SET ENABLED:C1123(*; "cb_freqHalfYear"; $canEditFreq)
	OBJECT SET ENABLED:C1123(*; "cb_freqAnnually"; $canEditFreq)
	OBJECT SET ENTERABLE:C238(*; "cb_freqQuarterly"; $canEditFreq)
	OBJECT SET ENTERABLE:C238(*; "cb_freqHalfYear"; $canEditFreq)
	OBJECT SET ENTERABLE:C238(*; "cb_freqAnnually"; $canEditFreq)
	OBJECT SET ENABLED:C1123(*; "entryField_oneTime"; $inModification)
	OBJECT SET ENTERABLE:C238(*; "entryField_oneTime"; $inModification)
	If (Form:C1466.current_item#Null:C1517)
		OBJECT SET TITLE:C194(*; "lbl_freqSummary"; Form:C1466.current_item.retrainFrequencySummaryLabel())
	Else 
		OBJECT SET TITLE:C194(*; "lbl_freqSummary"; "")
	End if 
	OBJECT SET ENABLED:C1123(*; "btnForwardAssignedStaff"; Form:C1466.selectedAssignedStaff#Null:C1517)
	
	
// Purpose: One time clears frequencies; selecting a frequency clears one time (Karla 2.f).
// modified by 4D/PS [2026-june-02]
Function cb_oneTime()
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	
	Form:C1466.current_item.applyOneTimeRule(Form:C1466.current_item.oneTime)
	This:C1470.redrawAndSetVisible()
	This:C1470._activate_save_cancel_button()
	
	
// Purpose: Keep duration and oneTime in sync when a re-training frequency checkbox is edited.
// created by 4D/PS [2026-oct-05]
Function cb_retrainFrequency()
	
	var $ident : Text
	var $enabled : Boolean
	
	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	
	Case of 
		: (FORM Event:C1606.objectName="cb_freqQuarterly")
			$ident:="quarterly"
			$enabled:=Form:C1466.current_item.retrainQuarterly
		: (FORM Event:C1606.objectName="cb_freqHalfYear")
			$ident:="halfYear"
			$enabled:=Form:C1466.current_item.retrainHalfYear
		: (FORM Event:C1606.objectName="cb_freqAnnually")
			$ident:="annually"
			$enabled:=Form:C1466.current_item.retrainAnnually
		Else 
			return 
	End case 
	
	Form:C1466.current_item.setRetrainingFrequency($ident; $enabled)
	If (Not:C34(Form:C1466.current_item.oneTime)) && (Form:C1466.current_item.duration<=0)
		Form:C1466.current_item.duration:=365
	End if 
	This:C1470.redrawAndSetVisible()
	This:C1470._activate_save_cancel_button()
	
	
Function loadAssignedStaff()
	var $assignment_e : cs:C1710.CertificationAssignmentEntity
	var $staff_e : cs:C1710.StaffEntity
	var $seen : Object
	var $selectedUuid : Text
	var $row : Object
	
	$selectedUuid:=""
	If (Form:C1466.selectedAssignedStaff#Null:C1517)
		$selectedUuid:=Form:C1466.selectedAssignedStaff.UUID
	End if 
	Form:C1466.lb_assignedStaff:=New collection:C1472
	Form:C1466.selectedAssignedStaff:=Null:C1517
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	
	$seen:=New object:C1471
	For each ($assignment_e; ds:C1482.CertificationAssignment.query("UUID_Certification = :1"; Form:C1466.current_item.UUID))
		If ($seen[$assignment_e.UUID_Staff]#Null:C1517)
			continue
		End if 
		$seen[$assignment_e.UUID_Staff]:=True:C214
		$staff_e:=$assignment_e.staff
		If ($staff_e=Null:C1517) && ($assignment_e.UUID_Staff#"")
			$staff_e:=ds:C1482.Staff.get($assignment_e.UUID_Staff)
		End if 
		If ($staff_e#Null:C1517)
			Form:C1466.lb_assignedStaff.push(New object:C1471(\
				"UUID"; $staff_e.UUID; \
				"code"; $staff_e.code; \
				"name"; $staff_e.fullName\
				))
		End if 
	End for each 
	Form:C1466.lb_assignedStaff:=Form:C1466.lb_assignedStaff.orderBy("name")
	If ($selectedUuid#"")
		For each ($row; Form:C1466.lb_assignedStaff)
			If ($row.UUID=$selectedUuid)
				Form:C1466.selectedAssignedStaff:=$row
				break
			End if 
		End for each 
	End if 
	
	
Function lb_assignedStaff()
	This:C1470.redrawAndSetVisible()
	If (FORM Event:C1606.code=On Double Clicked:K2:5)
		This:C1470.openSelectedAssignedStaff()
	End if 
	
	
Function openSelectedAssignedStaff()
	var $staff_e : cs:C1710.StaffEntity
	
	If (Form:C1466.selectedAssignedStaff=Null:C1517)
		return 
	End if 
	$staff_e:=ds:C1482.Staff.get(Form:C1466.selectedAssignedStaff.UUID)
	If ($staff_e=Null:C1517)
		cs:C1710.sfw_dialog.me.info("This staff record could not be found.")
		return 
	End if 
	Form:C1466.sfw.openInANewWindow($staff_e; "qualityAssurance"; "staff")
	
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	Form:C1466.sfw.redrawButtons()
	
