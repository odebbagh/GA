Class extends Entity

//local Function beforeSaveCreation()
//This._initCorrectiveActionReport()

local Function loadAfterCreation()
	// Purpose: Assign a unique barcode in moreData for scanner lookup on new records.
	// modified by 4D/PS [2026-oct-05]
	var $maxNumber : Integer
	
	If (This:C1470.moreData=Null:C1517)
		This:C1470.moreData:=New object:C1471
	End if 
	This:C1470.moreData.barcodeData:=String:C10(cs:C1710.Util_ScannerManager.me.getBarcodeData(Form:C1466.sfw.entry.dataclass); "0000000000")
	// Purpose: Safe first CAR number when the table is empty; initialize 8D report and externalParty storage.
	// modified by 4D/PS [2026-june-08]
	$maxNumber:=ds:C1482.Qcar.all().max("qcarNumber")
	This:C1470.qcarNumber:=($maxNumber>0) ? ($maxNumber+1) : 1
	This:C1470._initCorrectiveActionReport()
	If (Not:C34(OB Is defined:C1231(This:C1470.moreData; "externalParty")))
		This:C1470.moreData.externalParty:=""
	End if 
	This:C1470.otherOriginChecked:=False:C215
	This:C1470.UUID_QcarOrigin:=16*"00" 
	
	
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
	
	
	// Purpose: Show the linked customer; fall back to the traveler's customer text for older CARs.
	// created by 4D/PS [2026-oct-05]
Function get customerDisplay()->$name : Text
	If (This:C1470.customer#Null:C1517)
		$name:=String:C10(This:C1470.customer.name)
	Else 
		If (This:C1470.lot#Null:C1517)
			$name:=String:C10(This:C1470.lot.customer)
		End if 
	End if 
	
	
	// Purpose: Prefer the stored CAR device; fall back to the traveler device for older records.
	// created by 4D/PS [2026-oct-05]
Function get deviceDisplay()->$device : Text
	$device:=String:C10(This:C1470.device)
	If ($device="") && (This:C1470.lot#Null:C1517)
		$device:=String:C10(This:C1470.lot.device)
	End if
	
	
local Function _initCorrectiveActionReport()
	This:C1470.correctiveActionReport:=New object:C1471(\
		"teamLeaders"; ""; \
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
	
	
	// Purpose: Prefer teamLeaders; keep reading the old teamLearders key on existing CARs.
	// created by 4D/PS [2026-oct-05]
Function teamLeaderName()->$name : Text
	var $car : Object
	$car:=This:C1470.correctiveActionReport
	If ($car=Null:C1517)
		return 
	End if 
	$name:=String:C10($car.teamLeaders)
	If ($name="")
		$name:=String:C10($car.teamLearders)
	End if
	
	
local Function get closedDate()->$date : Date
	$date:=This:C1470.closedStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.closedStmp; True:C214)
	
local Function set closedDate($date : Date)
	This:C1470.closedStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
	// Purpose: Form and print still use actualCloseDate; persist it on closedStmp like closedDate.
	// created by 4D/PS [2026-oct-05]
local Function get actualCloseDate()->$date : Date
	$date:=This:C1470.closedStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.closedStmp; True:C214)
	
local Function set actualCloseDate($date : Date)
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
	
	
	
