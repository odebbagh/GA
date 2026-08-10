//%attributes = {}

var $records : Collection
var $record : Object
var $resourcesFolder : 4D:C1709.Folder
var $exportsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $parts : Collection
var $certPart : Text
var $certRefs : Collection
var $certRef : Integer
var $headers : Collection
var $header : Text
var $bins : Collection
var $skillNames : Collection
var $skillsParts : Collection
var $skillName : Text
var $toolTypeNames : Collection
var $stepTemplateEntity : 4D:C1709.Entity
var $certificationUUIDs : Collection
var $stcLink : 4D:C1709.Entity

$records:=New collection:C1472()

ALL RECORDS:C47([Template_definitions])

While (Not:C34(End selection:C36([Template_definitions])))
	$certRefs:=New collection:C1472()
	$headers:=New collection:C1472()
	$bins:=New collection:C1472()
	$skillNames:=New collection:C1472()
	$toolTypeNames:=New collection:C1472()
	$parts:=Split string:C1554([Template_definitions]Cert_list; ";")
	
	For each ($certPart; $parts)
		If ($certPart#"")
			$certRef:=Num:C11($certPart)
			If ($certRef>0)
				$certRefs.push($certRef)
			End if 
		End if 
	End for each 
	
	$parts:=Split string:C1554([Template_definitions]TableHeader; "\r")
	For each ($header; $parts)
		If ($header#"")
			$headers.push($header)
		End if 
	End for each 
	
	For each ($skillChunk; Split string:C1554([Template_definitions]SkillTypesRequired; Char:C90(Carriage return:K15:38)))
		$skillChunk:=Replace string:C233(String:C10($skillChunk); Char:C90(Line feed:K15:39); "")
		For each ($skillName; Split string:C1554($skillChunk; ";"))
			$skillName:=cs:C1710.sfw_string.me.trimSpace(String:C10($skillName))
			If ($skillName#"")
				$skillNames.push($skillName)
			End if 
		End for each 
	End for each 
	
	If ([Template_definitions]Tool1#"")
		$toolTypeNames.push([Template_definitions]Tool1)
	End if 
	If ([Template_definitions]Tool2#"")
		$toolTypeNames.push([Template_definitions]Tool2)
	End if 
	If ([Template_definitions]Tool3#"")
		$toolTypeNames.push([Template_definitions]Tool3)
	End if 
	
	$bins.push([Template_definitions]Bin1def)
	$bins.push([Template_definitions]Bin2def)
	$bins.push([Template_definitions]Bin3def)
	$bins.push([Template_definitions]Bin4def)
	$bins.push([Template_definitions]Bin5def)
	$bins.push([Template_definitions]Bin6def)
	$bins.push([Template_definitions]Bin7def)
	$bins.push([Template_definitions]Bin8def)
	$bins.push([Template_definitions]Bin9def)
	$bins.push([Template_definitions]Bin10def)
	$bins.push([Template_definitions]Bin11def)
	$bins.push([Template_definitions]Bin12def)
	$bins.push([Template_definitions]Bin13def)
	$bins.push([Template_definitions]Bin14def)
	$bins.push([Template_definitions]Bin15def)
	$bins.push([Template_definitions]Bin16def)
	$bins.push([Template_definitions]Bin17def)
	$bins.push([Template_definitions]Bin18def)
	$bins.push([Template_definitions]Bin19def)
	$bins.push([Template_definitions]Bin20def)
	$bins.push([Template_definitions]Bin21def)
	$bins.push([Template_definitions]Bin22def)
	$bins.push([Template_definitions]Bin23def)
	$bins.push([Template_definitions]Bin24def)
	$bins.push([Template_definitions]Bin25def)
	$bins.push([Template_definitions]Bin26def)
	$bins.push([Template_definitions]Bin27def)
	$bins.push([Template_definitions]Bin28def)
	$bins.push([Template_definitions]Bin29def)
	$bins.push([Template_definitions]Bin30def)
	$bins.push([Template_definitions]Bin31def)
	$bins.push([Template_definitions]Bin32def)
	
	$record:=New object:C1471(\
		"name"; [Template_definitions]Name; \
		"templateNumber"; [Template_definitions]Template_num; \
		"operation"; [Template_definitions]Operation; \
		"suppress"; [Template_definitions]Suppress; \
		"active"; Not:C34([Template_definitions]Suppress); \
		"miscellaneousControl"; [Template_definitions]MiscellaneousControl; \
		"containerCode"; [Template_definitions]ContainerCode; \
		"binning"; [Template_definitions]IsBinningRequired; \
		"smallLayoutName"; [Template_definitions]S_layout; \
		"largeLayoutName"; [Template_definitions]L_layout; \
		"comment1"; [Template_definitions]Comment1Fmt; \
		"comment2"; [Template_definitions]Comment2Fmt; \
		"tableHeader"; [Template_definitions]TableHeader; \
		"tableHeaders"; $headers; \
		"bins"; $bins; \
		"skillTypesRequired"; [Template_definitions]SkillTypesRequired; \
		"skillName"; $skillNames; \
		"skillNames"; $skillNames; \
		"tool1"; [Template_definitions]Tool1; \
		"tool2"; [Template_definitions]Tool2; \
		"tool3"; [Template_definitions]Tool3; \
		"toolTypeNames"; $toolTypeNames; \
		"certList"; [Template_definitions]Cert_list; \
		"certRefs"; $certRefs\
		)
	
	// Many-to-many StepTemplateCertification → Certification (authoritative links in ORDA).
	$certificationUUIDs:=New collection:C1472()
	$stepTemplateEntity:=ds:C1482.StepTemplate.query("templateNumber = :1"; [Template_definitions]Template_num).first()
	If ($stepTemplateEntity#Null:C1517)
		For each ($stcLink; ds:C1482.StepTemplateCertification.query("UUID_StepTemplate = :1"; $stepTemplateEntity.UUID))
			$certificationUUIDs.push(String:C10($stcLink.UUID_Certification))
		End for each 
	End if 
	$record.certificationUUIDs:=$certificationUUIDs
	
	$records.push($record)
	NEXT RECORD:C51([Template_definitions])
End while 

$resourcesFolder:=Folder:C1567(fk resources folder:K87:11)
$exportsFolder:=$resourcesFolder.folder("exports")

If (Not:C34($exportsFolder.exists))
	$exportsFolder.create()
End if 

$file:=$exportsFolder.file("stepTemplates_export.json")

If (Not:C34($file.exists))
	$file.create()
End if 

$file.setText(JSON Stringify:C1217($records))

ALERT:C41("Export termine: "+$file.platformPath+" | step templates: "+String:C10($records.length))
