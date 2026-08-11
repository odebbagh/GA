// Purpose: Resolve validity length in days when assigning a certification to staff (entity helper or legacy duration).
// Parameters:
// $uuid_certification : Text — Certification.UUID
// Returns: Integer — days until expiry (0 = no expiry / one time)
// created by 4D/PS [2026-june-02]
#DECLARE($uuid_certification : Text)->$days : Integer

var $eCert : cs:C1710.CertificationEntity

$days:=0
$eCert:=ds:C1482.Certification.get($uuid_certification)
If ($eCert#Null:C1517)
	$days:=$eCert.expiredInDaysForNewAssignment()
End if 
