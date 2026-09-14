Class extends Entity

Function hasCertification($uuid_certification : Text)->$certified : Boolean
	
	var $assignment_es : cs:C1710.CertificationAssignmentSelection
	var $assignment_e : cs:C1710.CertificationAssignmentEntity
	
	// Purpose: CertificationAssignment.expiredIn is a day-count validity period; validity uses certificationDate + expiredIn, not a stored expiry stmp.
	// modified by 4D/PS [2026-may-12]
	$certified:=False:C215
	$assignment_es:=ds:C1482.CertificationAssignment.query("UUID_Staff = :1 AND UUID_Certification = :2"; This:C1470.UUID; $uuid_certification).orderBy("certificationStmp desc")
	
	For each ($assignment_e; $assignment_es)
		If ($assignment_e.validityActive)
			$certified:=True:C214
			// Purpose: QA override allows punch-in when certification is expired (Karla 2.d).
			// modified by 4D/PS [2026-june-02]
		Else 
			If ($assignment_e.moreData#Null:C1517) && (Bool:C1537($assignment_e.moreData.overrideCertExpired))
				$certified:=True:C214
			End if 
		End if 
	End for each 
	
// Purpose: Optional $certificationDate for backdated assignment (Karla UAT); !00-00-00! → today.
// Parameters:
// $uuid_certification : Text — Certification.UUID
// $duration : Integer — validity days (0 = resolve from catalog)
// $certificationDate : Date — certification date (!00-00-00! → today; future dates rejected)
// Returns: Boolean — True when the assignment was saved
// modified by 4D/PS [2026-july-27]
Function createCertification($uuid_certification : Text; $duration : Integer; $certificationDate : Date)->$certified : Boolean
	
	var $certificationAssignment : cs:C1710.CertificationAssignmentEntity
	var $cert_e : cs:C1710.CertificationEntity
	var $res : Object
	var $today : Date
	
	$today:=Current date:C33(*)
	If ($certificationDate=!00-00-00!)
		$certificationDate:=cs:C1710.sfw_stmp.me.getDate(cs:C1710.sfw_stmp.me.now(); True:C214)
	End if 
	If ($certificationDate>$today)
		return False:C215
	End if 
	
	$certificationAssignment:=ds:C1482.CertificationAssignment.new()
	
	$certificationAssignment.UUID_Staff:=This:C1470.UUID
	$certificationAssignment.UUID_Certification:=$uuid_certification
	
	$certificationAssignment.certificationDate:=$certificationDate
	
	// Purpose: Persist catalog Certification.duration on assignment (display/validity also read live from catalog).
	// modified by 4D/PS [2026-june-09]
	$cert_e:=ds:C1482.Certification.get($uuid_certification)
	If ($duration>0)
		$certificationAssignment.expiredIn:=$duration
	Else 
		If ($cert_e#Null:C1517)
			$certificationAssignment.expiredIn:=$cert_e.expiredInDaysForNewAssignment()
		Else 
			$certificationAssignment.expiredIn:=_ga_certificationExpiredInDays($uuid_certification)
		End if 
	End if 
	//Else 
	//$certificationAssignment.expiredIn:=0
	//End if 
	
	// Purpose: Reset per-milestone notification flags on new assignment (Karla 2.f — multiple frequencies).
	// modified by 4D/PS [2026-june-02]
	$certificationAssignment.moreData:=New object:C1471(\
		"retrainNotified"; False:C215; \
		"retrainNotifiedMilestones"; New object:C1471; \
		"overrideCertExpired"; False:C215)
	
	$res:=$certificationAssignment.save()
	
	// Purpose: Return save success to callers (createCertification had no return before).
	// modified by 4D/PS [2026-june-09]
	If ($res.success)
		// Purpose: Sync Staff.stmpRetrain after new assignment (retrain milestones, not validity expiry).
		// modified by 4D/PS [2026-june-12]
		This:C1470.recomputeRetrainDate()
	End if 
	
	return $res.success
	
	
// Purpose: Update certification date on the latest assignment (correction / backdate without unchecking).
// Parameters:
// $uuid_certification : Text — Certification.UUID
// $certificationDate : Date — new certification date (must not be in the future)
// Returns: Boolean — True when saved
// created by 4D/PS [2026-july-27]
Function updateCertificationDate($uuid_certification : Text; $certificationDate : Date)->$ok : Boolean
	
	var $assignment_e : cs:C1710.CertificationAssignmentEntity
	var $res : Object
	
	$ok:=False:C215
	If ($certificationDate=!00-00-00!) || ($certificationDate>Current date:C33(*))
		return $ok
	End if 
	
	$assignment_e:=ds:C1482.CertificationAssignment\
		.query("UUID_Staff = :1 AND UUID_Certification = :2"; This:C1470.UUID; $uuid_certification)\
		.orderBy("certificationStmp desc").first()
	
	If ($assignment_e#Null:C1517)
		$assignment_e.certificationDate:=$certificationDate
		If ($assignment_e.moreData=Null:C1517)
			$assignment_e.moreData:=New object:C1471()
		End if 
		// Purpose: Milestone reminders must follow the new certification date.
		// modified by 4D/PS [2026-july-27]
		$assignment_e.moreData.retrainNotified:=False:C215
		$assignment_e.moreData.retrainNotifiedMilestones:=New object:C1471()
		$res:=$assignment_e.save()
		$ok:=$res.success
		If ($ok)
			This:C1470.recomputeRetrainDate()
		End if 
	End if 
	
	
	// Purpose: Grant or revoke punch-in override for an expired certification assignment (qm, qs, dc only at UI).
	// Parameters:
	// $uuid_certification : Text — Certification.UUID
	// $override : Boolean — when True, punch-in allowed despite expired validity
	// Returns: Boolean — True when an assignment was updated and saved
	// modified by 4D/PS [2026-june-02]
Function setCertificationOverride($uuid_certification : Text; $override : Boolean)->$ok : Boolean
	
	var $assignment_e : cs:C1710.CertificationAssignmentEntity
	var $info : Object
	
	$ok:=False:C215
	$assignment_e:=ds:C1482.CertificationAssignment\
		.query("UUID_Staff = :1 AND UUID_Certification = :2"; This:C1470.UUID; $uuid_certification)\
		.orderBy("certificationStmp desc").first()
	
	If ($assignment_e#Null:C1517)
		If ($assignment_e.moreData=Null:C1517)
			$assignment_e.moreData:=New object:C1471
		End if 
		$assignment_e.moreData.overrideCertExpired:=$override
		$assignment_e.moreData.overrideBy:=cs:C1710.sfw_userManager.me.info.login
		$assignment_e.moreData.overrideStmp:=cs:C1710.sfw_stmp.me.now()
		$info:=$assignment_e.save()
		$ok:=$info.success
	End if 
	
	
Function deleteCertification($uuid_certification : Text)->$certified : Boolean
	
	var $assignment_e : cs:C1710.CertificationAssignmentEntity
	var $res : Object
	
	// Purpose: Remove the latest assignment for this certification type (Re-New history — uncheck drops most recent row only).
	// modified by 4D/PS [2026-june-12]
	$certified:=False:C215
	$assignment_e:=ds:C1482.CertificationAssignment\
		.query("UUID_Staff = :1 AND UUID_Certification = :2"; This:C1470.UUID; $uuid_certification)\
		.orderBy("certificationStmp desc").first()
	
	If ($assignment_e#Null:C1517)
		$res:=$assignment_e.drop()
		
		// Purpose: Return True when drop succeeded — aligned with createCertification ($certified := $res.success).
		// Returns: Boolean — True if the assignment was removed successfully
		// modified by 4D/PS [2026-may-21]
		$certified:=$res.success
		If ($certified)
			// Purpose: Refresh Staff.stmpRetrain when an assignment is removed.
			// modified by 4D/PS [2026-june-12]
			This:C1470.recomputeRetrainDate()
		End if 
	End if 
	
Function getCertificationDate($uuid_certification : Text)->$certifiedAt : Date
	$assignment_es:=ds:C1482.CertificationAssignment\
		.query("UUID_Staff = :1 AND UUID_Certification = :2"; This:C1470.UUID; $uuid_certification)\
		.orderBy("certificationStmp desc")
	
	If ($assignment_es.length>0)
		$certifiedAt:=$assignment_es[0].certificationDate  //cs.sfw_stmp.me.getDate($assignment_es[0].certificationDate)
	End if 
	
	// Purpose: Renamed from getExpiredDate — returns the calendar expiry date (expiringDate) for the
	// staff member's most recent assignment of the given certification. Parameter is Certification UUID.
	// Parameters: $uuid_certification : Text — UUID of the Certification dataclass record
	// Returns: Date — expiringDate of the latest assignment, or !00-00-00! when none exists
	// modified by 4D/PS [2026-may-21]
Function getCertiExpiredDate($uuid_certification : Text)->$expiringDate : Date
	$assignment_es:=ds:C1482.CertificationAssignment\
		.query("UUID_Staff = :1 AND UUID_Certification = :2"; This:C1470.UUID; $uuid_certification)\
		.orderBy("certificationStmp desc")
	
	If ($assignment_es.length>0)
		// Purpose: Return calendar lapse date from certification date + duration days (expiredIn).
		// modified by 4D/PS [2026-may-12]
		$expiringDate:=$assignment_es[0].expiringDate
	End if 
	
Function getCertiExpiredIn($days : Integer)->$assignment_es : cs:C1710.CertificationAssignmentSelection
	
	var $today : Date
	var $limit : Date
	var $expiry : Date
	var $a : cs:C1710.CertificationAssignmentEntity
	
	// Purpose: Assignments whose calendar expiry falls between today and today+$days (expiredIn is duration in days).
	// modified by 4D/PS [2026-may-12]
	$today:=Current date:C33()
	$limit:=Add to date:C393($today; 0; 0; $days)
	
	$assignment_es:=ds:C1482.CertificationAssignment.newSelection()
	
	For each ($a; This:C1470.assignments)
		If ($a.expiredIn>0)
			$expiry:=$a.expiringDate
			If ($expiry#!00-00-00!) && ($expiry>=$today) && ($expiry<=$limit)
				$assignment_es.add($a)
			End if 
		End if 
	End for each 
	
	
	// Purpose: Retrain reminders due within $days for each certification frequency milestone (Karla 2.f).
	// Parameters: $days : Integer — lookahead window in days
	// Returns: Collection of objects — { assignment; milestoneDays; milestoneDate }
	// modified by 4D/PS [2026-june-02]
Function getRetrainMilestonesDueIn($days : Integer)->$due : Collection
	
	var $today : Date
	var $limit : Date
	var $a : cs:C1710.CertificationAssignmentEntity
	var $certDt : Date
	var $offsets : Collection
	var $offset : Integer
	var $milestoneDate : Date
	
	$due:=New collection:C1472()
	$today:=Current date:C33()
	$limit:=Add to date:C393($today; 0; 0; $days)
	
	For each ($a; This:C1470.assignments)
		If ($a.certification#Null:C1517) && ($a.certification.oneTime)
			continue
		End if 
		If ($a.certificationStmp=0)
			continue
		End if 
		$certDt:=$a.certificationDate
		// Purpose: Run milestone math only when certification date is set (guard was inverted).
		// modified by 4D/PS [2026-june-08]
		If ($certDt#!00-00-00!)
			$offsets:=$a.certification.retrainMilestoneDayOffsets()
			For each ($offset; $offsets)
				$milestoneDate:=Add to date:C393($certDt; 0; 0; $offset)
				If ($milestoneDate>=$today) && ($milestoneDate<=$limit)
					$due.push(New object:C1471(\
						"assignment"; $a; \
						"milestoneDays"; $offset; \
						"milestoneDate"; $milestoneDate))
				End if 
			End for each 
		End if 
	End for each 
	
	
	// Purpose: Recompute Staff.stmpRetrain (retrainDate) from re-training milestone frequencies on the catalog —
	// earliest upcoming milestone across latest assignment per certification type (not expiringDate / validity).
	// Legacy fallback when no future milestone: most recent certification date + 365 days (v18 Retrain_Date).
	// Returns: Boolean — True when save succeeded or stmpRetrain unchanged
	// modified by 4D/PS [2026-june-12]
Function recomputeRetrainDate()->$ok : Boolean
	
	var $today : Date
	var $next : Date
	var $a : cs:C1710.CertificationAssignmentEntity
	var $cert_e : cs:C1710.CertificationEntity
	var $certDt : Date
	var $offsets : Collection
	var $offset : Integer
	var $milestoneDate : Date
	var $seenCert : Object
	var $latestCertDt : Date
	var $fallback : Date
	var $newStmp : Integer
	var $res : Object
	
	$ok:=True:C214
	$today:=Current date:C33()
	$next:=!00-00-00!
	$latestCertDt:=!00-00-00!
	$seenCert:=New object:C1471
	
	For each ($a; ds:C1482.CertificationAssignment\
		.query("UUID_Staff = :1"; This:C1470.UUID)\
		.orderBy("certificationStmp desc"))
		
		If ($seenCert[$a.UUID_Certification]#Null:C1517)
			continue
		End if 
		$seenCert[$a.UUID_Certification]:=True:C214
		
		$cert_e:=$a.certification
		If ($cert_e=Null:C1517) && ($a.UUID_Certification#"")
			$cert_e:=ds:C1482.Certification.get($a.UUID_Certification)
		End if 
		If ($cert_e#Null:C1517) && ($cert_e.oneTime)
			continue
		End if 
		If ($a.certificationStmp=0)
			continue
		End if 
		$certDt:=$a.certificationDate
		If ($certDt=!00-00-00!)
			continue
		End if 
		
		If ($latestCertDt=!00-00-00!) || ($certDt>$latestCertDt)
			$latestCertDt:=$certDt
		End if 
		
		If ($cert_e#Null:C1517)
			$offsets:=$cert_e.retrainMilestoneDayOffsets()
		Else 
			$offsets:=New collection:C1472(365)
		End if 
		
		For each ($offset; $offsets)
			$milestoneDate:=Add to date:C393($certDt; 0; 0; $offset)
			If ($milestoneDate>=$today)
				If ($next=!00-00-00!) || ($milestoneDate<$next)
					$next:=$milestoneDate
				End if 
			End if 
		End for each 
	End for each 
	
	If ($next=!00-00-00!) && ($latestCertDt#!00-00-00!)
		$fallback:=Add to date:C393($latestCertDt; 0; 0; 365)
		$next:=$fallback
	End if 
	
	$newStmp:=$next=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($next)
	If (This:C1470.stmpRetrain#$newStmp)
		This:C1470.stmpRetrain:=$newStmp
		$res:=This:C1470.save()
		$ok:=$res.success
	End if 
	
	
local Function get email()->$email : Text
	If (This:C1470.contactDetails#Null:C1517) && (This:C1470.contactDetails.communications#Null:C1517)
		$communication:=This:C1470.contactDetails.communications.query("type = :1"; "mail").first()
		If ($communication#Null:C1517)
			$email:=$communication.contact
		End if 
	End if 
	
	
local Function _initCommunication()
	If (This:C1470.contactDetails=Null:C1517)
		This:C1470.contactDetails:=New object:C1471()
	End if 
	
	If (This:C1470.contactDetails.communications=Null:C1517)
		This:C1470.contactDetails.communications:=New collection:C1472
	End if 
	
Function get fullName()->$fullName : Text
	$fullName:=[This:C1470.firstName; This:C1470.lastName].join(" ")
	
	
Function get role()->$role : Text
	
	$roles:=ds:C1482.StaffRole.query("UUID_Staff = :1"; This:C1470.UUID)
	If ($roles.length>0)
		$role:=$roles[0].role.name
	End if 
	
	// Purpose: Employee retrain due date (v18 Retrain_Date). Auto-synced via recomputeRetrainDate() on cert assign/remove/Re-New.
	// Uses catalog re-training milestone offsets (90/180/365 from certification date), not assignment expiringDate.
	// modified by 4D/PS [2026-june-12]
local Function get retrainDate()->$date : Date
	$date:=This:C1470.stmpRetrain=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpRetrain; True:C214)
	
local Function set retrainDate($date : Date)
	This:C1470.stmpRetrain:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get hireDate()->$date : Date
	$date:=This:C1470.stmpHire=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpHire; True:C214)
	
local Function set hireDate($date : Date)
	This:C1470.stmpHire:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get terminationDate()->$date : Date
	$date:=This:C1470.stmpTermination=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpTermination; True:C214)
	
local Function set terminationDate($date : Date)
	This:C1470.stmpTermination:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get creationDate()->$date : Date
	$date:=This:C1470.stmpCreation=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpCreation; True:C214)
	
local Function set creationDate($date : Date)
	This:C1470.stmpCreation:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
	
local Function itemLoad()
	// This callback is called when the item is selected in the itemList
	This:C1470._initCommunication()
	
local Function afterCreation()
	// This callback is called after saving the new item
	//This.code:=String(This.codeID; "00000#")
	
local Function loadAfterCreation()
	// Purpose: Assign a unique barcode in moreData for scanner lookup on new records.
	// modified by 4D/PS [2026-june-29]
	This:C1470.moreData.barcodeData:=String:C10(cs:C1710.Util_ScannerManager.me.getBarcodeData(Form:C1466.sfw.entry.dataclass); "0000000000")
	// This callback is called after creating the new item but before displaying the panel.
	This:C1470.codeID:=ds:C1482.Staff.all().max("codeID")+1
	This:C1470.code:=String:C10(This:C1470.codeID; "00000#")
	
	