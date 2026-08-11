//%attributes = {"executedOnServer":true}

// Purpose: Snapshot StepTemplateCertification onto LotStep.skills and LotStep.requitedCertifications (punch-in gate).
// Uses LotStep.type as legacy Step_Type / StepTemplate.templateNumber.
// Parameters:
// $lotStep_e : cs.LotStepEntity — entity to update in place (not saved by this method)
// created by 4D/PS [2026-june-09]

#DECLARE($lotStep_e : cs:C1710.LotStepEntity)

var $template_e : cs:C1710.StepTemplateEntity
var $stCert_e : cs:C1710.StepTemplateCertificationEntity
var $skills : Collection
var $reqCerts : Collection

$skills:=New collection:C1472()
$reqCerts:=New collection:C1472()

If ($lotStep_e.type>0)
	$template_e:=ds:C1482.StepTemplate.query("templateNumber = :1"; $lotStep_e.type).first()
	If ($template_e#Null:C1517)
		For each ($stCert_e; ds:C1482.StepTemplateCertification.query("UUID_StepTemplate = :1"; $template_e.UUID))
			If ($stCert_e.certification#Null:C1517)
				$skills.push(New object:C1471(\
					"UUID"; $stCert_e.certification.UUID; \
					"name"; $stCert_e.certification.name; \
					"ref"; $stCert_e.certification.ref\
					))
				$reqCerts.push(New object:C1471(\
					"UUID_Certification"; $stCert_e.certification.UUID; \
					"name"; $stCert_e.certification.name\
					))
			End if 
		End for each 
	End if 
End if 

$lotStep_e.skills:=New object:C1471("items"; $skills)
$lotStep_e.requitedCertifications:=New object:C1471("items"; $reqCerts)
