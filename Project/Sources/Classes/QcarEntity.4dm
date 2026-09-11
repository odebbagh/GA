Class extends Entity

//local Function beforeSaveCreation()
//This._initCorrectiveActionReport()

local Function loadAfterCreation()
	// Purpose: Assign a unique barcode in moreData for scanner lookup on new records.
	// modified by 4D/PS [2026-june-29]
	This:C1470.moreData.barcodeData:=String:C10(cs:C1710.Util_ScannerManager.me.getBarcodeData(Form:C1466.sfw.entry.dataclass); "0000000000")
	// This callback is called after creating the new item but before displaying the panel.
	var $maxNumber : Integer
	
	// Purpose: Safe first CAR number when the table is empty; initialize 8D report and externalParty storage.
	// modified by 4D/PS [2026-june-08]
	$maxNumber:=ds:C1482.Qcar.all().max("qcarNumber")
	This:C1470.qcarNumber:=($maxNumber>0) ? ($maxNumber+1) : 1
	This:C1470._initCorrectiveActionReport()
	If (This:C1470.moreData=Null:C1517)
		This:C1470.moreData:=New object:C1471
	End if 
	If (Not:C34(OB Is defined:C1231(This:C1470.moreData; "externalParty")))
		This:C1470.moreData.externalParty:=""
	End if 
	
	
// Purpose: Computed attribute used by the listbox column / search-box on the CAR entry.
// Returns the item name when a sub-level is selected, otherwise the root category name.
// Returns: Text — display label of the reject-criteria assignment
// modified by 4D/PS [2026-may-19]
Function get categoryLabel()->$label : Text
	
	If (cs:C1710.sfw_string.me.isAnEmptyUUID(This:C1470.UUID_RejectCriteriaItem)=False:C215)
		$label:=String:C10(This:C1470.rejectCriteriaItem.name)
	Else 
		If (cs:C1710.sfw_string.me.isAnEmptyUUID(This:C1470.UUID_RejectCriteriaCategory)=False:C215)
			$label:=String:C10(This:C1470.rejectCriteriaCategory.name)
		Else 
			$label:=""
		End if 
	End if 
	
	
// Purpose: Expose externalParty stored in moreData for the CAR Main tab EntryField.
// Returns: Text — external party name when CAR is external
// modified by 4D/PS [2026-june-08]
Function get externalParty()->$value : Text
	
	If (This:C1470.moreData#Null:C1517) && (OB Is defined:C1231(This:C1470.moreData; "externalParty"))
		$value:=String:C10(This:C1470.moreData.externalParty)
	End if 
	
	
// Purpose: Persist externalParty in moreData for the CAR Main tab EntryField.
// Parameters: $value : Text — external party name
// modified by 4D/PS [2026-june-08]
Function set externalParty($value : Text)
	
	If (This:C1470.moreData=Null:C1517)
		This:C1470.moreData:=New object:C1471
	End if 
	This:C1470.moreData.externalParty:=$value
	
	
local Function _initCorrectiveActionReport()
	This:C1470.correctiveActionReport:=New object:C1471(\
		"teamLearders"; ""; \
		"supervisor"; ""; \
		"teamMembers"; ""; \
		"d2"; ""; \
		"d3"; ""; \
		"d3TargetDate"; !00-00-00!; \
		"d3ActualDate"; !00-00-00!; \
		"d4"; ""; \
		"d5"; ""; \
		"d6"; ""; \
		"d6TargetDate"; !00-00-00!; \
		"d6ActualDate"; !00-00-00!; \
		"d7"; ""; \
		"d7TargetDate"; !00-00-00!; \
		"d7ActualDate"; !00-00-00!; \
		"controlPlan"; False:C215; \
		"training"; False:C215; \
		"flowchart"; False:C215; \
		"procWork"; False:C215; \
		"addToInternalAudit"; False:C215; \
		"others"; False:C215; \
		"othersText"; ""\
		)
	
	
local Function get closedDate()->$date : Date
	$date:=This:C1470.closedStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.closedStmp; True:C214)
	
local Function set closedDate($date : Date)
	This:C1470.closedStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get verifiedDate()->$date : Date
	$date:=This:C1470.verifiedStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.verifiedStmp; True:C214)
	
local Function set verifiedDate($date : Date)
	This:C1470.verifiedStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get issuedDate()->$date : Date
	$date:=This:C1470.issuedStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.issuedStmp; True:C214)
	
local Function set issuedDate($date : Date)
	This:C1470.issuedStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get submitDate()->$date : Date
	$date:=This:C1470.submitStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.submitStmp; True:C214)
	
local Function set submitDate($date : Date)
	This:C1470.submitStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get targetCloseDate()->$date : Date
	$date:=This:C1470.targetCloseStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.targetCloseStmp; True:C214)
	
local Function set targetCloseDate($date : Date)
	This:C1470.targetCloseStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
	
	