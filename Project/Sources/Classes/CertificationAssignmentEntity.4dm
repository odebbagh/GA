Class extends Entity


local Function get certificationDate()->$date : Date
	$date:=This:C1470.certificationStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.certificationStmp; True:C214)
	
local Function set certificationDate($date : Date)
	This:C1470.certificationStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
	
// Purpose: Calendar lapse date = certification date + Certification catalog duration (live, not stale assignment.expiredIn).
// Returns: Date — empty date when no stamp, one-time cert, or no finite duration.
// modified by 4D/PS [2026-june-09]
local Function get expiringDate()->$date : Date
	
	var $certDt : Date
	var $validityDays : Integer
	var $cert_e : cs:C1710.CertificationEntity
	
	$date:=!00-00-00!
	If (This:C1470.certificationStmp=0)
		return 
	End if 
	$certDt:=This:C1470.certificationDate
	If ($certDt=!00-00-00!)
		return 
	End if 
	
	$cert_e:=This:C1470.certification
	If ($cert_e=Null:C1517) && (This:C1470.UUID_Certification#"")
		$cert_e:=ds:C1482.Certification.get(This:C1470.UUID_Certification)
	End if 
	
	If ($cert_e#Null:C1517)
		If ($cert_e.oneTime)
			return 
		End if 
		$validityDays:=$cert_e.expiredInDaysForNewAssignment()
	Else 
		$validityDays:=This:C1470.expiredIn
	End if 
	
	If ($validityDays<=0)
		return 
	End if 
	$date:=Add to date:C393($certDt; 0; 0; $validityDays)
	
	
// Purpose: Persist lapse date by adjusting expiredIn (days after certificationDate). Empty date clears finite validity (expiredIn:=0).
// Parameters: $date — calendar lapse date (!00-00-00! = no expiry window from duration).
// modified by 4D/PS [2026-may-12]
local Function set expiringDate($date : Date)
	
	var $certDt : Date
	var $delta : Integer
	
	If ($date=!00-00-00!)
		This:C1470.expiredIn:=0
		return 
	End if 
	If (This:C1470.certificationStmp=0)
		return 
	End if 
	$certDt:=This:C1470.certificationDate
	If ($certDt=!00-00-00!)
		return 
	End if 
	$delta:=$date-$certDt
	If ($delta<=0)
		This:C1470.expiredIn:=0
	Else 
		This:C1470.expiredIn:=$delta
	End if 
	
	
// Purpose: True when valid today — uses expiringDate (catalog Certification.duration when relation is loaded).
// modified by 4D/PS [2026-june-09]
local Function get validityActive()->$active : Boolean
	
	var $expiry : Date
	
	If (This:C1470.certificationStmp=0)
		$active:=False:C215
		return 
	End if 
	
	$expiry:=This:C1470.expiringDate
	If ($expiry=!00-00-00!)
		$active:=True:C214
	Else 
		$active:=($expiry>=Current date:C33())
	End if 
	
	
// Purpose: Align stored duration with a desired validity flag — True clears finite expiry (expiredIn:=0); False sets expiredIn so lapse is on or before yesterday when certification predates yesterday (otherwise expiredIn:=1; lapse may still be on/after today if certificationDate is very recent).
// Parameters: $active : Boolean — target validity regarding calendar lapse vs today.
// modified by 4D/PS [2026-may-12]
local Function set validityActive($active : Boolean)
	
	var $certDt : Date
	var $yesterday : Date
	var $delta : Integer
	
	If ($active)
		This:C1470.expiredIn:=0
		return 
	End if 
	If (This:C1470.certificationStmp=0)
		return 
	End if 
	$certDt:=This:C1470.certificationDate
	If ($certDt=!00-00-00!)
		return 
	End if 
	$yesterday:=Add to date:C393(Current date:C33(); 0; 0; -1)
	$delta:=$yesterday-$certDt
	If ($delta>0)
		This:C1470.expiredIn:=$delta
	Else 
		This:C1470.expiredIn:=1
	End if 
	
