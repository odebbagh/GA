//%attributes = {}
// Purpose: Set Certification.duration to 365 for existing catalog rows where duration is 0 and not one-time.
// Returns: Integer — number of rows updated
// created by 4D/PS [2026-june-08]
#DECLARE->$updated : Integer

var $certification_e : cs:C1710.CertificationEntity
var $res : Object

$updated:=0

For each ($certification_e; ds:C1482.Certification.query("duration = :1"; 0))
	If (Not:C34($certification_e.oneTime))
		$certification_e.duration:=365
		$res:=$certification_e.save()
		If ($res.success)
			$updated:=$updated+1
		End if 
	End if 
End for each 
