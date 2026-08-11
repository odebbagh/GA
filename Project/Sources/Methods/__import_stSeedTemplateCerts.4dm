//%attributes = {"executedOnServer":true}

// Purpose: Link StepTemplateCertification rows from legacy export; map skillCode → Certification.ref (catalog QA).
// Parameters:
// $uuid_stepTemplate : Text — StepTemplate.UUID
// $templateNumber : Integer — StepTemplate.templateNumber (legacy Template_num)
// $templateName : Text — StepTemplate.name (for import report)
// $requiredCertifications : Collection — { skillCode : Integer ; name : Text } from step_template_export.json
// $importReport : Collection — appended with unknown / unmapped skill entries (post-import report)
// Returns: Integer — number of StepTemplateCertification links created
// created by 4D/PS [2026-june-09]

#DECLARE($uuid_stepTemplate : Text; $templateNumber : Integer; $templateName : Text; $requiredCertifications : Collection; $importReport : Collection) -> $linkedCount : Integer

var $reqCert : Object
var $certName : Text
var $skillCode : Integer
var $cert_e : cs:C1710.CertificationEntity
var $link_e : cs:C1710.StepTemplateCertificationEntity
var $res : Object
var $reason : Text

$linkedCount:=0

If ($requiredCertifications=Null:C1517) || ($requiredCertifications.length=0)
	return $linkedCount
End if 

For each ($reqCert; $requiredCertifications)
	$skillCode:=Num:C11($reqCert.skillCode)
	$certName:=String:C10($reqCert.name)
	$cert_e:=Null:C1517
	$reason:=""
	
	If ($skillCode>0)
		$cert_e:=ds:C1482.Certification.query("ref = :1"; $skillCode).first()
	End if 
	
	If ($cert_e=Null:C1517) && ($certName#"")
		$cert_e:=ds:C1482.Certification.query("name = :1"; $certName).first()
	End if 
	
	If ($cert_e=Null:C1517)
		If ($skillCode>0)
			$reason:="certification ref "+String:C10($skillCode)+" not found in catalog"
		Else 
			$reason:="invalid skill code"
		End if 
		If ($certName#"")
			$reason:=$reason+" (name: "+$certName+")"
		End if 
		$importReport.push(New object:C1471(\
			"templateNumber"; $templateNumber; \
			"templateName"; $templateName; \
			"skillCode"; $skillCode; \
			"certName"; $certName; \
			"reason"; $reason\
			))
		continue
	End if 
	
	$link_e:=ds:C1482.StepTemplateCertification.new()
	$link_e.UUID_StepTemplate:=$uuid_stepTemplate
	$link_e.UUID_Certification:=$cert_e.UUID
	$res:=$link_e.save()
	If ($res.success)
		$linkedCount:=$linkedCount+1
	Else 
		$importReport.push(New object:C1471(\
			"templateNumber"; $templateNumber; \
			"templateName"; $templateName; \
			"skillCode"; $skillCode; \
			"certName"; $cert_e.name; \
			"reason"; "StepTemplateCertification save failed"\
			))
	End if 
End for each 

return $linkedCount
