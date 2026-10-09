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
	var $cert_e : cs:C1710.CertificationEntity
	var $certDt : Date
	var $offsets : Collection
	var $offset : Integer
	var $milestoneDate : Date
	
	$due:=New collection:C1472()
	$today:=Current date:C33()
	$limit:=Add to date:C393($today; 0; 0; $days)
	
	If (This:C1470.assignments=Null:C1517)
		return $due
	End if 
	
	For each ($a; This:C1470.assignments)
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
		If ($cert_e#Null:C1517)
			$offsets:=$cert_e.retrainMilestoneDayOffsets()
		Else 
			$offsets:=New collection:C1472(365)
		End if 
		If ($offsets=Null:C1517)
			continue
		End if 
		For each ($offset; $offsets)
			$milestoneDate:=Add to date:C393($certDt; 0; 0; $offset)
			If ($milestoneDate>=$today) && ($milestoneDate<=$limit)
				$due.push(New object:C1471(\
					"assignment"; $a; \
					"milestoneDays"; $offset; \
					"milestoneDate"; $milestoneDate))
			End if 
		End for each 
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
	This:C1470.stmpRetrain:=This:C1470._stampIfDateChanged(This:C1470.stmpRetrain; $date)
	
local Function get hireDate()->$date : Date
	$date:=This:C1470.stmpHire=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpHire; True:C214)
	
local Function set hireDate($date : Date)
	This:C1470.stmpHire:=This:C1470._stampIfDateChanged(This:C1470.stmpHire; $date)
	
local Function get terminationDate()->$date : Date
	$date:=This:C1470.stmpTermination=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpTermination; True:C214)
	
local Function set terminationDate($date : Date)
	This:C1470.stmpTermination:=This:C1470._stampIfDateChanged(This:C1470.stmpTermination; $date)
	
local Function get creationDate()->$date : Date
	$date:=This:C1470.stmpCreation=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpCreation; True:C214)
	
local Function set creationDate($date : Date)
	This:C1470.stmpCreation:=This:C1470._stampIfDateChanged(This:C1470.stmpCreation; $date)
	
	// Purpose: Rewrite a stamp only when the calendar day changes; midnight so event diffs are day-based.
	// created by 4D/PS [2026-october-06]
local Function _stampIfDateChanged($currentStmp : Integer; $date : Date)->$stmp : Integer
	var $currentDate : Date
	
	If ($date=!00-00-00!)
		return 0
	End if 
	$currentDate:=$currentStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate($currentStmp; True:C214)
	If ($currentDate=$date)
		return $currentStmp
	End if 
	return cs:C1710.sfw_stmp.me.build($date; ?00:00:00?)
	
	// Purpose: Format a staff date for event comments (text survives object-field storage).
	// created by 4D/PS [2026-october-06]
local Function _staffDateLabel($date : Date)->$label : Text
	$label:=($date=!00-00-00!) ? "" : String:C10($date; System date short:K1:1)
	
	// Purpose: Compare clone vs current staff dates (and team) as display strings for StaffEvent.
	// created by 4D/PS [2026-october-06]
local Function _staffCollectTrackedDiffs()->$diffs : Object
	var $clone : cs:C1710.StaffEntity
	var $oldName; $newName : Text
	
	$diffs:=New object:C1471
	$clone:=Form:C1466.current_clone
	If ($clone=Null:C1517)
		return $diffs
	End if 
	If ($clone.hireDate#This:C1470.hireDate)
		$diffs.hireDate:=New object:C1471("old"; This:C1470._staffDateLabel($clone.hireDate); "new"; This:C1470._staffDateLabel(This:C1470.hireDate))
	End if 
	If ($clone.terminationDate#This:C1470.terminationDate)
		$diffs.terminationDate:=New object:C1471("old"; This:C1470._staffDateLabel($clone.terminationDate); "new"; This:C1470._staffDateLabel(This:C1470.terminationDate))
	End if 
	If ($clone.retrainDate#This:C1470.retrainDate)
		$diffs.retrainDate:=New object:C1471("old"; This:C1470._staffDateLabel($clone.retrainDate); "new"; This:C1470._staffDateLabel(This:C1470.retrainDate))
	End if 
	If ($clone.creationDate#This:C1470.creationDate)
		$diffs.creationDate:=New object:C1471("old"; This:C1470._staffDateLabel($clone.creationDate); "new"; This:C1470._staffDateLabel(This:C1470.creationDate))
	End if 
	$oldName:=This:C1470._staffTeamName($clone)
	$newName:=This:C1470._staffTeamName(This:C1470)
	If ($oldName#$newName)
		$diffs.Department:=New object:C1471("old"; $oldName; "new"; $newName)
	End if 
	$oldName:=This:C1470._staffCommunicationsLabel($clone.contactDetails)
	$newName:=This:C1470._staffCommunicationsLabel(This:C1470.contactDetails)
	If ($oldName#$newName)
		$diffs.contactDetails:=New object:C1471("old"; $oldName; "new"; $newName)
	End if 
	$oldName:=This:C1470._staffBarcodeLabel($clone.moreData)
	$newName:=This:C1470._staffBarcodeLabel(This:C1470.moreData)
	If ($oldName#$newName)
		$diffs.barcode:=New object:C1471("old"; $oldName; "new"; $newName)
	End if 
	
	// Purpose: Readable communications list for event comments (type: value; ...).
	// created by 4D/PS [2026-october-06]
local Function _staffCommunicationsLabel($details : Object)->$label : Text
	var $parts : Collection
	var $comm : Object
	var $type; $value : Text
	
	$parts:=New collection:C1472
	If ($details#Null:C1517) && ($details.communications#Null:C1517)
		For each ($comm; $details.communications)
			If ($comm#Null:C1517)
				$type:=String:C10($comm.type)
				$value:=String:C10($comm.contact)
				If ($type+" "+$value#"")
					$parts.push($type+": "+$value)
				End if 
			End if 
		End for each 
	End if 
	$label:=$parts.join("; ")
	
	// Purpose: Barcode stored in moreData for event comments.
	// created by 4D/PS [2026-october-06]
local Function _staffBarcodeLabel($moreData : Object)->$label : Text
	$label:=""
	If ($moreData#Null:C1517)
		$label:=String:C10($moreData.barcodeData)
	End if 
	
	// Purpose: Latest CertificationAssignment for this staff and catalog certification.
	// created by 4D/PS [2026-october-06]
local Function _staffLatestAssignment($uuidCertification : Text)->$assignment : cs:C1710.CertificationAssignmentEntity
	$assignment:=ds:C1482.CertificationAssignment.query("UUID_Staff = :1 AND UUID_Certification = :2"; This:C1470.UUID; $uuidCertification).orderBy("certificationStmp desc").first()
	
	// Purpose: Current punch-in override label for event comments.
	// created by 4D/PS [2026-october-06]
local Function _staffOverrideLabel($uuidCertification : Text)->$label : Text
	var $assignment : cs:C1710.CertificationAssignmentEntity
	
	$label:="override off"
	$assignment:=This:C1470._staffLatestAssignment($uuidCertification)
	If ($assignment#Null:C1517) && ($assignment.moreData#Null:C1517) && (Bool:C1537($assignment.moreData.overrideCertExpired))
		$label:="override on"
	End if 
	
	// Purpose: Read queued cert date from stamp (survives Form.sfw copy); Date/text are fallbacks.
	// created by 4D/PS [2026-october-06]
local Function _staffPendingOpDate($op : Object)->$date : Date
	$date:=!00-00-00!
	If ($op=Null:C1517)
		return 
	End if 
	If (Num:C11($op.dateStmp)#0)
		$date:=cs:C1710.sfw_stmp.me.getDate(Num:C11($op.dateStmp); True:C214)
		return 
	End if 
	Case of 
		: (Value type:C1509($op.date)=Is date:K8:7)
			$date:=$op.date
		: (Value type:C1509($op.date)=Is text:K8:3) && ($op.date#"")
			$date:=Date:C102($op.date)
	End case 
	
	// Purpose: Build text diffs from queued certification actions before they are committed and cleared.
	// created by 4D/PS [2026-october-06]
	// Purpose: Fold create/delete/updateDate per certification so a date change is not overwritten; stamp not Date.
	// modified by 4D/PS [2026-october-06]
local Function _staffCollectCertificationDiffs()->$diffs : Object
	var $op; $net; $byUuid : Object
	var $cert : cs:C1710.CertificationEntity
	var $assignment : cs:C1710.CertificationAssignmentEntity
	var $actions : Collection
	var $uuid; $name; $old; $new : Text
	var $date : Date
	
	$diffs:=New object:C1471
	$actions:=This:C1470._staffPendingCertActions()
	If ($actions=Null:C1517) || ($actions.length=0)
		return $diffs
	End if 
	$byUuid:=New object:C1471
	For each ($op; $actions)
		$uuid:=String:C10($op.uuid)
		If ($uuid="")
			continue
		End if 
		If ($byUuid[$uuid]=Null:C1517)
			$byUuid[$uuid]:=New object:C1471("create"; False:C215; "delete"; False:C215; "updateDate"; False:C215; "renew"; False:C215; "hasOverride"; False:C215; "override"; False:C215; "dateStmp"; 0)
		End if 
		$net:=$byUuid[$uuid]
		$date:=This:C1470._staffPendingOpDate($op)
		Case of 
			: (String:C10($op.action)="create")
				$net.create:=True:C214
				$net.delete:=False:C215
				$net.renew:=Bool:C1537($op.renew)
				If ($date#!00-00-00!)
					$net.dateStmp:=cs:C1710.sfw_stmp.me.build($date; ?00:00:00?)
				End if 
			: (String:C10($op.action)="delete")
				$net.delete:=True:C214
				$net.create:=False:C215
				$net.updateDate:=False:C215
			: (String:C10($op.action)="updateDate")
				$net.updateDate:=True:C214
				If ($date#!00-00-00!)
					$net.dateStmp:=cs:C1710.sfw_stmp.me.build($date; ?00:00:00?)
				End if 
			: (String:C10($op.action)="override")
				$net.hasOverride:=True:C214
				$net.override:=Bool:C1537($op.override)
		End case 
	End for each 
	For each ($uuid; OB Keys:C1719($byUuid))
		$net:=$byUuid[$uuid]
		$cert:=ds:C1482.Certification.get($uuid)
		$name:=($cert#Null:C1517) ? $cert.name : $uuid
		$assignment:=This:C1470._staffLatestAssignment($uuid)
		$date:=(Num:C11($net.dateStmp)#0) ? cs:C1710.sfw_stmp.me.getDate(Num:C11($net.dateStmp); True:C214) : !00-00-00!
		If ($date=!00-00-00!) && (Bool:C1537($net.create) || Bool:C1537($net.updateDate))
			$date:=Current date:C33(*)
		End if 
		Case of 
			: (Bool:C1537($net.delete)) && (Not:C34(Bool:C1537($net.create)))
				$old:=($assignment#Null:C1517) ? "assigned "+This:C1470._staffDateLabel($assignment.certificationDate) : "assigned"
				$diffs["certification "+$name]:=New object:C1471("old"; $old; "new"; "removed")
			: (Bool:C1537($net.create))
				If (Bool:C1537($net.renew)) && ($assignment#Null:C1517)
					$old:=This:C1470._staffDateLabel($assignment.certificationDate)
					$new:="renewed "+This:C1470._staffDateLabel($date)
				Else 
					$old:=""
					$new:="assigned "+This:C1470._staffDateLabel($date)
				End if 
				$diffs["certification "+$name]:=New object:C1471("old"; $old; "new"; $new)
			: (Bool:C1537($net.updateDate))
				$old:=($assignment#Null:C1517) ? This:C1470._staffDateLabel($assignment.certificationDate) : ""
				$new:=This:C1470._staffDateLabel($date)
				$diffs["certification "+$name+" date"]:=New object:C1471("old"; $old; "new"; $new)
		End case 
		If (Bool:C1537($net.hasOverride))
			$diffs["certification "+$name+" override"]:=New object:C1471("old"; This:C1470._staffOverrideLabel($uuid); "new"; (Bool:C1537($net.override) ? "override on" : "override off"))
		End if 
	End for each 
	
	// Purpose: Resolve the cert pending queue from panel Form, parent Form.subForm, or Form.sfw.
	// created by 4D/PS [2026-october-06]
local Function _staffPendingCertActions()->$actions : Collection
	$actions:=cs:C1710.panel_staff.me._pendingCertActions() 
	
	// Purpose: Certification names from the pending queue, for retrainDate event labels.
	// created by 4D/PS [2026-october-06]
local Function _staffPendingCertNames()->$label : Text
	var $op : Object
	var $cert : cs:C1710.CertificationEntity
	var $names : Collection
	var $actions : Collection
	var $uuid; $name : Text
	
	$label:=""
	$names:=New collection:C1472
	$actions:=This:C1470._staffPendingCertActions()
	If ($actions=Null:C1517)
		return 
	End if 
	For each ($op; $actions)
		$uuid:=String:C10($op.uuid)
		If ($uuid="")
			continue
		End if 
		$cert:=ds:C1482.Certification.get($uuid)
		$name:=($cert#Null:C1517) ? $cert.name : $uuid
		If ($names.indexOf($name)=-1)
			$names.push($name)
		End if 
	End for each 
	$label:=$names.join(", ")
	
	// Purpose: Team name from the first membership; empty when none.
	// created by 4D/PS [2026-october-06]
local Function _staffTeamName($staff : cs:C1710.StaffEntity)->$name : Text
	$name:=""
	If ($staff#Null:C1517) && ($staff.memberships#Null:C1517) && ($staff.memberships.length>0) && ($staff.memberships[0].team#Null:C1517)
		$name:=$staff.memberships[0].team.name
	End if 
	
	// Purpose: Write date/department string diffs onto the StaffEvent created by SFW on this Accept.
	// created by 4D/PS [2026-october-06]
local Function _staffMergeTrackedDiffsIntoLastEvent()
	var $diffs : Object
	var $eEvent : 4D:C1709.Entity
	var $name : Text
	
	$diffs:=Form:C1466.staffEventTrackedDiffs
	If ($diffs=Null:C1517) && (Form:C1466.sfw#Null:C1517)
		$diffs:=Form:C1466.sfw.staffEventTrackedDiffs
	End if 
	Form:C1466.staffEventTrackedDiffs:=Null:C1517
	If (Form:C1466.sfw#Null:C1517)
		Form:C1466.sfw.staffEventTrackedDiffs:=Null:C1517
	End if
	If ($diffs=Null:C1517) || (OB Keys:C1719($diffs).length=0)
		return 
	End if 
	If (ds:C1482["StaffEvent"]=Null:C1517)
		return 
	End if 
	$eEvent:=ds:C1482.StaffEvent.query("UUID_Staff = :1"; This:C1470.UUID).orderBy("stmp desc").first()
	If ($eEvent=Null:C1517) || ((cs:C1710.sfw_stmp.me.now()-$eEvent.stmp)>5)
		If (Form:C1466.sfw#Null:C1517) && (Form:C1466.sfw.entry.event#Null:C1517)
			cs:C1710.sfw_eventManager.me.addEvent(Form:C1466.sfw.entry; "modifRecord"; This:C1470.UUID; New object:C1471("modifiedFields"; $diffs))
			cs:C1710.sfw_eventManager.me.refresh(This:C1470.UUID; Form:C1466.sfw.entry)
		End if 
		return 
	End if 
	If ($eEvent.moreData=Null:C1517)
		$eEvent.moreData:=New object:C1471
	End if 
	If ($eEvent.moreData.modifiedFields=Null:C1517)
		$eEvent.moreData.modifiedFields:=New object:C1471
	End if 
	For each ($name; $diffs)
		$eEvent.moreData.modifiedFields[$name]:=$diffs[$name]
	End for each 
	If (Form:C1466.sfw#Null:C1517) && (Bool:C1537(Form:C1466.sfw.staffRetrainDateRelabeled))
		OB REMOVE:C1226($eEvent.moreData.modifiedFields; "retrainDate")
		Form:C1466.sfw.staffRetrainDateRelabeled:=False:C215
	End if 
	$eEvent.save()
	If (Form:C1466.sfw#Null:C1517)
		cs:C1710.sfw_eventManager.me.refresh(This:C1470.UUID; Form:C1466.sfw.entry)
	End if 
	
	// Purpose: String() in sfw_eventManager only accepts scalar old/new; rewrite object/date pairs already stored.
	// created by 4D/PS [2026-october-06]
local Function _staffSanitizeEventModifiedFields()
	var $eEvent : 4D:C1709.Entity
	var $name : Text
	var $pair : Object
	var $changed : Boolean
	var $oldText; $newText : Text
	
	If (ds:C1482["StaffEvent"]=Null:C1517)
		return 
	End if 
	For each ($eEvent; ds:C1482.StaffEvent.query("UUID_Staff = :1"; This:C1470.UUID))
		If ($eEvent.moreData=Null:C1517) || ($eEvent.moreData.modifiedFields=Null:C1517)
			continue
		End if 
		$changed:=False:C215
		For each ($name; $eEvent.moreData.modifiedFields)
			$pair:=$eEvent.moreData.modifiedFields[$name]
			If (Value type:C1509($pair)#Is object:K8:27)
				continue
			End if 
			$oldText:=This:C1470._staffEventValueAsText($pair.old)
			$newText:=This:C1470._staffEventValueAsText($pair.new)
			If (Value type:C1509($pair.old)#Is text:K8:3) || (Value type:C1509($pair.new)#Is text:K8:3)
				$eEvent.moreData.modifiedFields[$name]:=New object:C1471("old"; $oldText; "new"; $newText)
				$changed:=True:C214
			End if 
		End for each 
		If ($changed)
			$eEvent.save()
		End if 
	End for each 
	
	// Purpose: Convert an event old/new value to text for String() in the Events panel.
	// created by 4D/PS [2026-october-06]
local Function _staffEventValueAsText($value : Variant)->$text : Text
	Case of 
		: ($value=Null:C1517)
			$text:=""
		: (Value type:C1509($value)=Is text:K8:3)
			$text:=$value
		: (Value type:C1509($value)=Is date:K8:7)
			$text:=($value=!00-00-00!) ? "" : String:C10($value; System date short:K1:1)
		: (Value type:C1509($value)=Is object:K8:27) || (Value type:C1509($value)=Is collection:K8:32)
			$text:=JSON Stringify:C1217($value)
		Else 
			$text:=String:C10($value)
	End case 
	
	
local Function itemLoad()
	// Purpose: Convert object/date values in existing StaffEvent comments so the Events panel can String() them.
	// created by 4D/PS [2026-october-06]
	This:C1470._staffSanitizeEventModifiedFields()
	
	
local Function itemReload()
	var $hasDetailPanel : Boolean
	
	// Purpose: After Accept/Cancel, drop Staff certification drafts and refresh the assignment list.
	// created by 4D/PS [2026-oct-05]
	// modified by 4D/PS [2026-october-09]
	If (Form:C1466.sfw#Null:C1517) && (String:C10(Form:C1466.sfw.entry.ident)="staff")
		cs:C1710.panel_staff.me.discardPendingCertifications()
		ARRAY TEXT:C222($names; 0)
		FORM GET OBJECTS:C898($names)
		$hasDetailPanel:=(Find in array:C230($names; "detail_panel")>0)
		If ($hasDetailPanel)
			EXECUTE METHOD IN SUBFORM:C1085("detail_panel"; Formula:C1597(cs:C1710.panel_staff.me.discardPendingCertifications()); *)
			EXECUTE METHOD IN SUBFORM:C1085("detail_panel"; Formula:C1597(cs:C1710.panel_staff.me.loadCertifications(True:C214)); *)
			EXECUTE METHOD IN SUBFORM:C1085("detail_panel"; Formula:C1597(cs:C1710.panel_staff.me.loadCertificationHistory()); *)
		Else 
			cs:C1710.panel_staff.me.loadAllTabs()
		End if 
	End if 
	
	
local Function beforeSave()
	var $certDiffs; $diffs : Object
	var $name; $certNames : Text
	
	// Purpose: Persist queued certification assignment changes only when the user accepts the Staff record.
	// created by 4D/PS [2026-oct-05]
	If (Form:C1466.sfw#Null:C1517) && (String:C10(Form:C1466.sfw.entry.ident)="staff")
		This:C1470._staffSanitizeEventModifiedFields()
		$certNames:=This:C1470._staffPendingCertNames()
		$certDiffs:=This:C1470._staffCollectCertificationDiffs()
		cs:C1710.panel_staff.me.commitPendingCertifications()
		// Purpose: Snapshot field diffs after cert commit (retrain date) and merge certification lines.
		// modified by 4D/PS [2026-october-06]
		$diffs:=This:C1470._staffCollectTrackedDiffs()
		If ($certDiffs#Null:C1517)
			For each ($name; $certDiffs)
				$diffs[$name]:=$certDiffs[$name]
			End for each 
		End if 
		Form:C1466.sfw.staffRetrainDateRelabeled:=False:C215
		If ($certNames#"") && ($diffs.retrainDate#Null:C1517)
			$diffs["retrainDate ("+$certNames+")"]:=$diffs.retrainDate
			OB REMOVE:C1226($diffs; "retrainDate")
			Form:C1466.sfw.staffRetrainDateRelabeled:=True:C214
		End if 
		Form:C1466.staffEventTrackedDiffs:=$diffs
		If (Form:C1466.sfw#Null:C1517)
			Form:C1466.sfw.staffEventTrackedDiffs:=$diffs
		End if
	End if 
	
	
local Function afterSave()
	// Purpose: Put readable date, department, and contact values into the StaffEvent.
	// created by 4D/PS [2026-october-06]
	If (Form:C1466.sfw#Null:C1517) && (String:C10(Form:C1466.sfw.entry.ident)="staff")
		This:C1470._staffSanitizeEventModifiedFields()
		This:C1470._staffMergeTrackedDiffsIntoLastEvent()
	End if  
	
	
local Function beforeSaveCreation()
	If (Form:C1466.sfw#Null:C1517) && (String:C10(Form:C1466.sfw.entry.ident)="staff")
		cs:C1710.panel_staff.me.commitPendingCertifications()
	End if 
	
	
local Function afterCreation()
	// This callback is called after saving the new item
	//This.code:=String(This.codeID; "00000#")
	
local Function loadAfterCreation()
	// Purpose: Assign a unique barcode in moreData for scanner lookup on new records.
	// modified by 4D/PS [2026-june-29]
	// modified by 4D/PS [2026-october-09]
	If (This:C1470.moreData=Null:C1517)
		This:C1470.moreData:=New object:C1471
	End if 
	This:C1470.moreData.barcodeData:=String:C10(cs:C1710.Util_ScannerManager.me.getBarcodeData(Form:C1466.sfw.entry.dataclass); "0000000000")
	// This callback is called after creating the new item but before displaying the panel.
	This:C1470.codeID:=ds:C1482.Staff.all().max("codeID")+1
	This:C1470.code:=String:C10(This:C1470.codeID; "00000#")
	This:C1470._initCommunication()
	
	