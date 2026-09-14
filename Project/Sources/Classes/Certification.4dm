Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	
	// Purpose: Certification catalog under Quality Assurance (Karla 2.f — Option A).
	// modified by 4D/PS [2026-june-02]
	$entry:=cs:C1710.sfw_definitionEntry.new("certifications"; ["qualityAssurance"]; "Certification")
	$entry.setDataclass("Certification")
	$entry.setDisplayOrder(-400)
	$entry.setIcon("image/entry/certification-white-50x50.png")
	
	$entry.setSearchboxField("ref")
	$entry.setSearchboxField("name")
	
	$entry.setPanel("panel_certification")
	$entry.setPanelPage(1; ""; "Main")
	
	
	$entry.setLBItemsColumn("ref"; "Ref #"; "width:50"; "center")
	$entry.setLBItemsColumn("name"; "Name"; "width:400")
	
	$entry.setLBItemsOrderBy("ref")
	
	$entry.enableTransaction()
	
	// Purpose: Only qs, qm, dc may create or edit certification types (aligned with staff cert management).
	// modified by 4D/PS [2026-june-02]
	$entry.setAllowedProfiles(_ga_qaCertModifyProfiles)
	
	$entry.setItemListAction("Import Certifications"; "certification_import")
	$entry.setItemListAction("Export Certifications"; "certification_export")


// Purpose: Find or create a catalog row during legacy staff-training import; set Certification.duration and return validity for assignments.
// Parameters:
// $trainingType : Text — legacy T_Type label (Employees_Training)
// $legacyDuration : Integer — legacy Duration in days (0 → default 365)
// $refCounter : Integer — last Certification.ref; incremented when a new row is created
// Returns: Object — { success : Boolean ; certification : cs.CertificationEntity | Null ; refCounter : Integer ; validityDays : Integer }
// created by 4D/PS [2026-june-02]
Function importForLegacyTraining($trainingType : Text; $legacyDuration : Integer; $refCounter : Integer) -> $result : Object
	
	var $validityDays : Integer
	var $formula : Object
	var $certification_es : cs:C1710.CertificationSelection
	var $certification_e : cs:C1710.CertificationEntity
	var $res : Object
	
	$result:=New object:C1471(\
		"success"; False:C215; \
		"certification"; Null:C1517; \
		"refCounter"; $refCounter; \
		"validityDays"; 0)
	
	$validityDays:=_ga_certificationImportDuration($legacyDuration; False:C215)
	
	$formula:=Formula:C1597(\
		Split string:C1554(This:C1470.name; " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2).join("")=\
		Split string:C1554($trainingType; " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2).join(""))
	
	$certification_es:=This:C1470.query($formula)
	
	If ($certification_es.length>0)
		$certification_e:=$certification_es[0]
		If ($certification_e.duration<=0) && (Not:C34($certification_e.oneTime))
			$certification_e.duration:=_ga_certificationImportDuration($legacyDuration; $certification_e.oneTime)
			$res:=$certification_e.save()
			If (Not:C34($res.success))
				return $result
			End if 
		End if 
	Else 
		$refCounter:=$refCounter+1
		$certification_e:=This:C1470.new()
		$certification_e.ref:=$refCounter
		$certification_e.name:=$trainingType
		$certification_e.duration:=_ga_certificationImportDuration($legacyDuration; False:C215)
		$res:=$certification_e.save()
		If (Not:C34($res.success))
			$result.refCounter:=$refCounter
			return $result
		End if 
	End if 
	
	$result.success:=True:C214
	$result.certification:=$certification_e
	$result.refCounter:=$refCounter
	If ($certification_e.oneTime)
		$result.validityDays:=0
	Else 
		$result.validityDays:=$certification_e.duration
	End if 
	