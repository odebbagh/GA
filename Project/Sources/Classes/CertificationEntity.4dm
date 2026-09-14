Class extends Entity

// Purpose: Certification type helpers — duration = assignment validity in days; retrain* booleans = reminder milestones (Karla 2.f).
// Ident values: quarterly (90d), halfYear (180d), annually (365d). One time clears validity duration and frequencies.
// modified by 4D/PS [2026-june-08]

local Function itemLoad()
	
	// Purpose: Copy legacy moreData.retrainingFrequencies into scalar fields when opening a record.
	// modified by 4D/PS [2026-june-08]
	This:C1470.ensureLegacyRetrainMigrated()
	
	
// Purpose: Build frequency idents from scalar boolean fields (used by retrain milestones and labels).
// Returns: Collection of Text — quarterly | halfYear | annually
// modified by 4D/PS [2026-june-08]
Function getRetrainingFrequencies()->$frequencies : Collection
	
	This:C1470.ensureLegacyRetrainMigrated()
	$frequencies:=New collection:C1472()
	If (This:C1470.retrainQuarterly)
		$frequencies.push("quarterly")
	End if 
	If (This:C1470.retrainHalfYear)
		$frequencies.push("halfYear")
	End if 
	If (This:C1470.retrainAnnually)
		$frequencies.push("annually")
	End if 
	
	
// Purpose: One-time migration from moreData.retrainingFrequencies to retrainQuarterly / retrainHalfYear / retrainAnnually.
// modified by 4D/PS [2026-june-08]
Function ensureLegacyRetrainMigrated()
	
	var $freqs : Collection
	
	If (This:C1470.retrainQuarterly) || (This:C1470.retrainHalfYear) || (This:C1470.retrainAnnually)
		return 
	End if 
	If (This:C1470.moreData=Null:C1517) || (This:C1470.moreData.retrainingFrequencies=Null:C1517)
		return 
	End if 
	$freqs:=This:C1470.moreData.retrainingFrequencies
	If ($freqs.length=0)
		return 
	End if 
	This:C1470.retrainQuarterly:=($freqs.indexOf("quarterly")#-1)
	This:C1470.retrainHalfYear:=($freqs.indexOf("halfYear")#-1)
	This:C1470.retrainAnnually:=($freqs.indexOf("annually")#-1)
	
	
// Purpose: Drop deprecated moreData.retrainingFrequencies after migration to scalar fields.
// modified by 4D/PS [2026-june-08]
Function clearLegacyRetrainFromMoreData()
	
	var $md : Object
	
	If (This:C1470.moreData=Null:C1517) || (This:C1470.moreData.retrainingFrequencies=Null:C1517)
		return 
	End if 
	$md:=This:C1470.moreData
	OB REMOVE:C1223($md; "retrainingFrequencies")
	This:C1470.moreData:=$md
	
	
// Purpose: Normalize oneTime vs retraining booleans before save.
// Returns: Object — { success : Boolean }
// modified by 4D/PS [2026-june-08]
Function validateSave($event : Object)->$result : Object
	
	This:C1470.ensureLegacyRetrainMigrated()
	If (This:C1470.oneTime)
		This:C1470.retrainQuarterly:=False:C215
		This:C1470.retrainHalfYear:=False:C215
		This:C1470.retrainAnnually:=False:C215
	End if 
	This:C1470.clearLegacyRetrainFromMoreData()
	$result:=New object:C1471("success"; True:C214)
	
	
// Purpose: Enable or disable one retraining frequency ident on this certification type.
// Parameters:
// $ident : Text — quarterly | halfYear | annually
// $enabled : Boolean — when True, adds the ident; when False, removes it
// modified by 4D/PS [2026-june-08]
Function setRetrainingFrequency($ident : Text; $enabled : Boolean)
	
	Case of 
		: ($ident="quarterly")
			This:C1470.retrainQuarterly:=$enabled
		: ($ident="halfYear")
			This:C1470.retrainHalfYear:=$enabled
		: ($ident="annually")
			This:C1470.retrainAnnually:=$enabled
	End case 
	If ($enabled) && (This:C1470.oneTime)
		This:C1470.oneTime:=False:C215
	End if 
	
	
// Purpose: When oneTime is set, clear retraining frequencies and validity duration (no expiry window).
// modified by 4D/PS [2026-june-08]
Function applyOneTimeRule($oneTime : Boolean)
	
	This:C1470.oneTime:=$oneTime
	If ($oneTime)
		This:C1470.retrainQuarterly:=False:C215
		This:C1470.retrainHalfYear:=False:C215
		This:C1470.retrainAnnually:=False:C215
		This:C1470.duration:=0
	End if 
	
	
// Purpose: Validity length in days for new staff assignments (Certification.duration — not re-training frequencies).
// Returns: Integer — 0 when oneTime; otherwise duration, shortest retraining frequency, or 365-day legacy default
// modified by 4D/PS [2026-june-08]
Function expiredInDaysForNewAssignment()->$days : Integer
	
	var $ident : Text
	var $candidate : Integer
	var $map : Object
	
	$days:=0
	If (This:C1470.oneTime)
		return 
	End if 
	
	If (This:C1470.duration>0)
		$days:=This:C1470.duration
		return 
	End if 
	
	// Purpose: Legacy records may have duration 0 while frequencies were previously used to fill validity.
	// modified by 4D/PS [2026-june-02]
	$map:=New object:C1471(\
		"quarterly"; 90; \
		"halfYear"; 180; \
		"annually"; 365)
	
	For each ($ident; This:C1470.getRetrainingFrequencies())
		$candidate:=$map[$ident]
		If ($candidate#Null:C1517)
			If ($days=0) || ($candidate<$days)
				$days:=$candidate
			End if 
		End if 
	End for each 
	
	// Purpose: Catalog import often leaves duration at 0; align with legacy staff training default (365 days).
	// modified by 4D/PS [2026-june-08]
	If ($days=0)
		$days:=365
	End if 
	
	
// Purpose: Day offsets from certification date for each retraining reminder (Karla 2.f — multiple frequencies).
// Returns: Collection of Integer — e.g. [90, 365]; empty when oneTime; falls back to duration when no frequencies set.
// modified by 4D/PS [2026-june-02]
Function retrainMilestoneDayOffsets()->$offsets : Collection
	
	var $ident : Text
	var $map : Object
	var $candidate : Integer
	
	$offsets:=New collection:C1472()
	If (This:C1470.oneTime)
		return $offsets
	End if 
	
	$map:=New object:C1471(\
		"quarterly"; 90; \
		"halfYear"; 180; \
		"annually"; 365)
	
	For each ($ident; This:C1470.getRetrainingFrequencies())
		$candidate:=$map[$ident]
		If ($candidate#Null:C1517) && ($offsets.indexOf($candidate)=-1)
			$offsets.push($candidate)
		End if 
	End for each 
	
	If ($offsets.length=0) && (This:C1470.duration>0)
		$offsets.push(This:C1470.duration)
	End if 
	
	
// Purpose: Human-readable summary of selected re-training reminder periods (for panel display).
// Returns: Text — e.g. "Reminders at: 90, 180, 365 days" or empty when one time / none
// modified by 4D/PS [2026-june-02]
Function retrainFrequencySummaryLabel()->$label : Text
	
	var $parts : Collection
	var $ident : Text
	var $map : Object
	
	$parts:=New collection:C1472()
	If (This:C1470.oneTime)
		$label:="One time — no re-training reminders"
		return $label
	End if 
	
	$map:=New object:C1471(\
		"quarterly"; "90"; \
		"halfYear"; "180"; \
		"annually"; "365")
	
	For each ($ident; This:C1470.getRetrainingFrequencies())
		If ($map[$ident]#Null:C1517)
			$parts.push($map[$ident])
		End if 
	End for each 
	
	If ($parts.length=0)
		$label:="No re-training frequency selected"
	Else 
		$label:="Reminders at: "+$parts.join(", ")+" days (from certification date)"
	End if 
	
	
// Purpose: Days used when assigning this cert to staff (from Certification.duration).
// Returns: Integer — same as expiredInDaysForNewAssignment; 0 when one time
// modified by 4D/PS [2026-june-02]
Function assignmentValidityDays()->$days : Integer
	
	$days:=This:C1470.expiredInDaysForNewAssignment()

// Purpose: Initialize barcode data when a new record is created in the entry panel.
// created by 4D/PS [2026-june-29]
local Function loadAfterCreation()
	// Purpose: Assign a unique barcode in moreData for scanner lookup on new records.
	// modified by 4D/PS [2026-june-29]
	This:C1470.moreData.barcodeData:=String:C10(cs:C1710.Util_ScannerManager.me.getBarcodeData(Form:C1466.sfw.entry.dataclass); "0000000000")
