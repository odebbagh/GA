//%attributes = {}

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $stepTemplateDataClass : 4D:C1709.DataClass
var $stepTemplateEntity : 4D:C1709.Entity
var $layoutDataClass : 4D:C1709.DataClass
var $layoutEntity : 4D:C1709.Entity
var $certificationDataClass : 4D:C1709.DataClass
var $certificationEntity : 4D:C1709.Entity
var $stepTemplateCertificationDataCl : 4D:C1709.DataClass
var $stepTemplateCertificationEntity : 4D:C1709.Entity
var $result : Object
var $created : Integer
var $linksCreated : Integer
var $failed : Integer
var $certRefs : Collection
var $certPart : Text
var $certRef : Integer
var $parts : Collection
var $seenRefs : Object
var $smallLayoutName : Text
var $largeLayoutName : Text
var $operationDataClass : 4D:C1709.DataClass
var $operationEntity : 4D:C1709.Entity
var $operationName : Text
var $header : Text
var $tableHeaders : Collection
var $bins : Collection
var $i : Integer
var $binDef : Text
var $skillNames : Collection
var $skillParts : Collection
var $toolTypeNames : Collection
var $toolTypeName : Text
var $toolTypeDataClass : 4D:C1709.DataClass
var $toolTypeEntity : 4D:C1709.Entity
var $stepTemplateToolTypeDataClass : 4D:C1709.DataClass
var $stepTemplateToolTypeEntity : 4D:C1709.Entity
var $toolOrder : Integer
var $isBinPlaceholder : Boolean
var $suffix : Text
var $j : Integer
var $char : Text
var $stepTemplateRuleDataClass : 4D:C1709.DataClass
var $ruleMaster : 4D:C1709.Entity
var $containerCodeMask : Integer
var $miscellaneousControlMask : Integer
var $ruleBitMask : Integer
var $ruleLevelID : Integer
var $inOutPars : Collection
var $inOutPar : Object
var $inOutDef : Text
var $inOutOrder : Integer
var $seenCertUUIDs : Object
var $certKey : Text
var $certUUIDsFromJson : Collection
var $certNames : Collection
var $certName : Text
var $uuidItem : Text

$stepTemplateDataClass:=ds:C1482["StepTemplate"]
$layoutDataClass:=ds:C1482["StepTemplateLayout"]
$certificationDataClass:=ds:C1482["Certification"]
$stepTemplateCertificationDataCl:=ds:C1482["StepTemplateCertification"]
$operationDataClass:=ds:C1482["Operation"]
$operationTypeDataClass:=ds:C1482["OperationType"]
$toolTypeDataClass:=ds:C1482["ToolType"]
$stepTemplateToolTypeDataClass:=ds:C1482["StepTemplateToolType"]
$stepTemplateRuleDataClass:=ds:C1482["StepTemplateRule"]

$divisionEntity:=ds:C1482.Division.all().first()

If (($stepTemplateDataClass=Null:C1517) | ($layoutDataClass=Null:C1517) | ($certificationDataClass=Null:C1517) | ($stepTemplateCertificationDataCl=Null:C1517) | ($operationDataClass=Null:C1517) | ($toolTypeDataClass=Null:C1517) | ($stepTemplateToolTypeDataClass=Null:C1517) | ($stepTemplateRuleDataClass=Null:C1517))
	ALERT:C41("Missing DataClass: StepTemplate, StepTemplateLayout, Certification, StepTemplateCertification, Operation, ToolType, StepTemplateToolType or StepTemplateRule.")
Else 
	// Keep only migrated links/templates.
	$stepTemplateToolTypeDataClass.all().drop()
	$stepTemplateCertificationDataCl.all().drop()
	$stepTemplateDataClass.all().drop()
	
	$projectFolder:=Folder:C1567(fk database folder:K87:14)
	$importsFolder:=$projectFolder.folder("project/imports")
	$file:=$importsFolder.file("stepTemplates_export.json")
	
	If (Not:C34($file.exists))
		ALERT:C41("Import file not found: "+$file.platformPath)
	Else 
		$records:=JSON Parse:C1218($file.getText())
		
		$created:=0
		$linksCreated:=0
		$failed:=0
		
		$division_uuid:=ds:C1482.Division.query("name = :1"; "GAC")[0].UUID
		
		For each ($record; $records)
			$stepTemplateEntity:=$stepTemplateDataClass.new()
			$containerCodeMask:=Num:C11($record.containerCode)
			$miscellaneousControlMask:=Num:C11($record.miscellaneousControl)
			
			$stepTemplateEntity.name:=String:C10($record.name)
			$stepTemplateEntity.templateNumber:=Num:C11($record.templateNumber)
			$operationName:=String:C10($record.operation)
			$stepTemplateEntity.comment1:=String:C10($record.comment1)
			$stepTemplateEntity.comment2:=String:C10($record.comment2)
			$stepTemplateEntity.binning:=($record.binning=True:C214)
			
			// Required fields kept with safe defaults.
			$stepTemplateEntity.areas:=""
			$stepTemplateEntity.status:=($record.active=True:C214)
			$stepTemplateEntity.UUID_Operation:="00"*16
			$stepTemplateEntity.UUID_Division:="00"*16
			$stepTemplateEntity.settings:=New object:C1471()
			$stepTemplateEntity.dataTables:=New object:C1471("items"; New collection:C1472())
			$stepTemplateEntity.parametricMeasurements:=New object:C1471("items"; New collection:C1472())
			$stepTemplateEntity.bins:=New object:C1471("items"; New collection:C1472())
			$stepTemplateEntity.rules:=New object:C1471("items"; New collection:C1472())
			$stepTemplateEntity.InOutParsDef:=New object:C1471("items"; New collection:C1472())
			For each ($ruleMaster; $stepTemplateRuleDataClass.all().orderBy("levelID"))
				$ruleBitMask:=Num:C11($ruleMaster.bit)
				Case of 
					: ($ruleMaster.bit="0x0001")
						$ruleBitMask:=0x0001
					: ($ruleMaster.bit="0x0002")
						$ruleBitMask:=0x0002
					: ($ruleMaster.bit="0x0004")
						$ruleBitMask:=0x0004
					: ($ruleMaster.bit="0x0008")
						$ruleBitMask:=0x0008
					: ($ruleMaster.bit="0x0010")
						$ruleBitMask:=0x0010
					: ($ruleMaster.bit="0x0020")
						$ruleBitMask:=0x0020
					: ($ruleMaster.bit="0x0040")
						$ruleBitMask:=0x0040
					: ($ruleMaster.bit="0x0080")
						$ruleBitMask:=0x0080
					: ($ruleMaster.bit="0x0100")
						$ruleBitMask:=0x0100
					: ($ruleMaster.bit="0x0800")
						$ruleBitMask:=0x0800
					: ($ruleMaster.bit="0x1000")
						$ruleBitMask:=0x1000
					: ($ruleMaster.bit="0x00010000")
						$ruleBitMask:=0x00010000
					: ($ruleMaster.bit="0x00020000")
						$ruleBitMask:=0x00020000
					: ($ruleMaster.bit="0x00100000")
						$ruleBitMask:=0x00100000
					: ($ruleMaster.bit="0x00200000")
						$ruleBitMask:=0x00200000
					: ($ruleMaster.bit="0x00400000")
						$ruleBitMask:=0x00400000
				End case 
				$ruleLevelID:=Num:C11($ruleMaster.levelID)
				$stepTemplateEntity.rules.items.push(New object:C1471(\
					"id"; $ruleMaster.UUID; \
					"name"; $ruleMaster.name; \
					"description"; $ruleMaster.description; \
					"bit"; $ruleMaster.bit; \
					"enable"; (($ruleLevelID=1) & (($containerCodeMask & $ruleBitMask)=$ruleBitMask)) | (($ruleLevelID=2) & (($miscellaneousControlMask & $ruleBitMask)=$ruleBitMask))\
					))
				
				$stepTemplateEntity.UUID_Division:=$division_uuid
				
			End for each 
			$stepTemplateEntity.containerCodes:=New object:C1471("items"; New collection:C1472())
			$inOutPars:=New collection:C1472(\
				New object:C1471("type"; "in"; "order"; 1; "definition"; $record.In_par1Def); \
				New object:C1471("type"; "in"; "order"; 2; "definition"; $record.In_par2Def); \
				New object:C1471("type"; "in"; "order"; 3; "definition"; $record.In_par3Def); \
				New object:C1471("type"; "out"; "order"; 1; "definition"; $record.Out_par1Def); \
				New object:C1471("type"; "out"; "order"; 2; "definition"; $record.Out_par2Def); \
				New object:C1471("type"; "out"; "order"; 3; "definition"; $record.Out_par3Def)\
				))
			
			For each ($inOutPar; $inOutPars)
				$inOutDef:=String:C10($inOutPar.definition)
				$inOutOrder:=Num:C11($inOutPar.order)
				If (($inOutDef#"") & (($inOutOrder>=1) & ($inOutOrder<=3)))
					$stepTemplateEntity.InOutParsDef.items.push(New object:C1471(\
						"order"; $inOutOrder; \
						"type"; String:C10($inOutPar.type); \
						"definition"; $inOutDef\
						))
				End if 
			End for each 
			
			//If ($operationName#"")
			//$operationEntity:=$operationDataClass.query("name = :1"; $operationName).first()
			//If ($operationEntity#Null)
			//$stepTemplateEntity.UUID_Operation:=$operationEntity.UUID
			//End if 
			//End if 
			
			If ($operationName#"")
				$operationTypeEntity:=$operationTypeDataClass.query("name = :1"; $operationName).first()
				If ($operationTypeEntity#Null:C1517)
					$stepTemplateEntity.UUID_OperationType:=$operationTypeEntity.UUID
				End if 
			End if 
			
			If ($divisionEntity#Null:C1517)
				$stepTemplateEntity.UUID_Division:=$divisionEntity.UUID
			End if 
			
			$tableHeaders:=New collection:C1472()
			If ($record.tableHeaders#Null:C1517)
				$tableHeaders:=$record.tableHeaders
			Else 
				$parts:=Split string:C1554(String:C10($record.tableHeader); "\r")
				For each ($header; $parts)
					If ($header#"")
						$tableHeaders.push($header)
					End if 
				End for each 
			End if 
			$tableOrder:=1
			For each ($header; $tableHeaders)
				If ($header#"")
					If (Position:C15("L: L:"; $header)#1)
						$stepTemplateEntity.dataTables.items.push(New object:C1471(\
							"UUID"; Generate UUID:C1066; \
							"name"; $header; \
							"order"; $tableOrder; \
							"key"; $header; \
							"value"; ""\
							))
						$tableOrder:=$tableOrder+1
					End if 
				End if 
			End for each 
			
			$bins:=New collection:C1472()
			If ($record.bins#Null:C1517)
				$bins:=$record.bins
			End if 
			For ($i; 0; 31)
				$binDef:=""
				If ($bins.length>$i)
					$binDef:=String:C10($bins[$i])
					$isBinPlaceholder:=False:C215
					If (Length:C16($binDef)>=4)
						If (Uppercase:C13(Substring:C12($binDef; 1; 3))="BIN")
							$suffix:=Substring:C12($binDef; 4)
							If ($suffix#"")
								If (Substring:C12($suffix; 1; 1)="[")
									$suffix:=Substring:C12($suffix; 2)
								End if 
								If (($suffix#"") & (Substring:C12($suffix; Length:C16($suffix); 1)="]"))
									$suffix:=Substring:C12($suffix; 1; Length:C16($suffix)-1)
								End if 
								If ($suffix#"")
									$isBinPlaceholder:=True:C214
									For ($j; 1; Length:C16($suffix))
										$char:=Substring:C12($suffix; $j; 1)
										If (($char<"0") | ($char>"9"))
											$isBinPlaceholder:=False:C215
										End if 
									End for 
								End if 
							End if 
						End if 
					End if 
					If ($isBinPlaceholder)
						$binDef:=""
					End if 
				End if 
				$stepTemplateEntity.bins.items.push(New object:C1471("num"; $i+1; "definition"; $binDef; "type"; "Not Used"))
			End for 
			
			$smallLayoutName:=String:C10($record.smallLayoutName)
			$layoutEntity:=$layoutDataClass.query("name = :1"; $smallLayoutName).first()
			If ($layoutEntity#Null:C1517)
				$stepTemplateEntity.smallLayout_UUID:=$layoutEntity.UUID
			Else 
				$stepTemplateEntity.smallLayout_UUID:="00"*16
			End if 
			
			$largeLayoutName:=String:C10($record.largeLayoutName)
			$layoutEntity:=$layoutDataClass.query("name = :1"; $largeLayoutName).first()
			If ($layoutEntity#Null:C1517)
				$stepTemplateEntity.largeLayout_UUID:=$layoutEntity.UUID
			Else 
				$stepTemplateEntity.largeLayout_UUID:="00"*16
			End if 
			
			$result:=$stepTemplateEntity.save()
			If ($result.success)
				$created:=$created+1
				
				$certRefs:=New collection:C1472()
				If ($record.certRefs#Null:C1517)
					$certRefs:=$record.certRefs
				Else 
					$parts:=Split string:C1554(String:C10($record.certList); ";")
					For each ($certPart; $parts)
						If ($certPart#"")
							$certRef:=Num:C11($certPart)
							If ($certRef>0)
								$certRefs.push($certRef)
							End if 
						End if 
					End for each 
				End if 
				
				$seenCertUUIDs:=New object:C1471()
				
				// Legacy: Certification.ref from cert list (may not match after certification re-import).
				For each ($certRef; $certRefs)
					$certificationEntity:=$certificationDataClass.query("ref = :1"; Num:C11($certRef)).first()
					If ($certificationEntity#Null:C1517)
						$certKey:=String:C10($certificationEntity.UUID)
						If ($seenCertUUIDs[$certKey]#True:C214)
							$seenCertUUIDs[$certKey]:=True:C214
							$stepTemplateCertificationEntity:=$stepTemplateCertificationDataCl.new()
							$stepTemplateCertificationEntity.moreData:=New object:C1471()
							$stepTemplateCertificationEntity.UUID_StepTemplate:=$stepTemplateEntity.UUID
							$stepTemplateCertificationEntity.UUID_Certification:=$certificationEntity.UUID
							
							$result:=$stepTemplateCertificationEntity.save()
							If ($result.success)
								$linksCreated:=$linksCreated+1
							Else 
								$failed:=$failed+1
							End if 
						End if 
					End if 
				End for each 
				
				// Authoritative: UUIDs from StepTemplateCertification M2M (see _export_stepTemplates).
				$certUUIDsFromJson:=New collection:C1472()
				If ($record.certificationUUIDs#Null:C1517)
					$certUUIDsFromJson:=$record.certificationUUIDs
				End if 
				For each ($uuidItem; $certUUIDsFromJson)
					$certKey:=String:C10($uuidItem)
					If (($certKey#"") & (cs:C1710.sfw_string.me.isAnEmptyUUID($certKey)=False:C215))
						If ($seenCertUUIDs[$certKey]#True:C214)
							$seenCertUUIDs[$certKey]:=True:C214
							$certificationEntity:=$certificationDataClass.get($certKey)
							If ($certificationEntity#Null:C1517)
								$stepTemplateCertificationEntity:=$stepTemplateCertificationDataCl.new()
								$stepTemplateCertificationEntity.moreData:=New object:C1471()
								$stepTemplateCertificationEntity.UUID_StepTemplate:=$stepTemplateEntity.UUID
								$stepTemplateCertificationEntity.UUID_Certification:=$certificationEntity.UUID
								
								$result:=$stepTemplateCertificationEntity.save()
								If ($result.success)
									$linksCreated:=$linksCreated+1
								Else 
									$failed:=$failed+1
								End if 
							End if 
						End if 
					End if 
				End for each 
				
				// Optional explicit certification names (same catalog as skills).
				$certNames:=New collection:C1472()
				If ($record.certNames#Null:C1517)
					$certNames:=$record.certNames
				End if 
				For each ($certName; $certNames)
					If ($certName#"")
						$certificationEntity:=$certificationDataClass.query("name = :1"; $certName).first()
						If ($certificationEntity#Null:C1517)
							$certKey:=String:C10($certificationEntity.UUID)
							If ($seenCertUUIDs[$certKey]#True:C214)
								$seenCertUUIDs[$certKey]:=True:C214
								$stepTemplateCertificationEntity:=$stepTemplateCertificationDataCl.new()
								$stepTemplateCertificationEntity.moreData:=New object:C1471()
								$stepTemplateCertificationEntity.UUID_StepTemplate:=$stepTemplateEntity.UUID
								$stepTemplateCertificationEntity.UUID_Certification:=$certificationEntity.UUID
								
								$result:=$stepTemplateCertificationEntity.save()
								If ($result.success)
									$linksCreated:=$linksCreated+1
								Else 
									$failed:=$failed+1
								End if 
							End if 
						End if 
					End if 
				End for each 
				
				If ($record.skillNames.length>0)
					$skillNames:=Split string:C1554($record.skillNames[0]; "\r")
				End if 
				
				
				If ($record.skillName#Null:C1517)
					Case of 
						: (Value type:C1509($record.skillName)=Is collection:K8:32)
							$skillNames:=$record.skillName
						: (Value type:C1509($record.skillName)=Is text:K8:3)
							For each ($skillChunk; Split string:C1554(String:C10($record.skillName); Char:C90(Carriage return:K15:38)))
								$skillChunk:=Replace string:C233(String:C10($skillChunk); Char:C90(Escape:K15:39); "")
								For each ($header; Split string:C1554($skillChunk; ";"))
									$header:=cs:C1710.sfw_string.me.trimSpace(String:C10($header))
									If ($header#"")
										$skillNames.push($header)
									End if 
								End for each 
							End for each 
					End case 
				End if 
				If ($skillNames.length=0)
					If ($record.skillNames#Null:C1517)
						Case of 
							: (Value type:C1509($record.skillNames)=Is collection:K8:32)
								$skillNames:=$record.skillNames
							: (Value type:C1509($record.skillNames)=Is text:K8:3)
								For each ($skillChunk; Split string:C1554(String:C10($record.skillNames); Char:C90(Carriage return:K15:38)))
									$skillChunk:=Replace string:C233(String:C10($skillChunk); Char:C90(Escape:K15:39); "")
									For each ($header; Split string:C1554($skillChunk; ";"))
										$header:=cs:C1710.sfw_string.me.trimSpace(String:C10($header))
										If ($header#"")
											$skillNames.push($header)
										End if 
									End for each 
								End for each 
						End case 
					End if 
				End if 
				If ($skillNames.length=0)
					For each ($skillChunk; Split string:C1554(String:C10($record.skillTypesRequired); Char:C90(Carriage return:K15:38)))
						$skillChunk:=Replace string:C233(String:C10($skillChunk); Char:C90(Escape:K15:39); "")
						For each ($header; Split string:C1554($skillChunk; ";"))
							$header:=cs:C1710.sfw_string.me.trimSpace(String:C10($header))
							If ($header#"")
								$skillNames.push($header)
							End if 
						End for each 
					End for each 
				End if 
				
				For each ($toolTypeName; $skillNames)
					If ($toolTypeName#"")
						$certificationEntity:=$certificationDataClass.query("name = :1"; $toolTypeName).first()
						If ($certificationEntity#Null:C1517)
							$certKey:=String:C10($certificationEntity.UUID)
							If ($seenCertUUIDs[$certKey]#True:C214)
								$seenCertUUIDs[$certKey]:=True:C214
								$stepTemplateCertificationEntity:=$stepTemplateCertificationDataCl.new()
								$stepTemplateCertificationEntity.moreData:=New object:C1471()
								$stepTemplateCertificationEntity.UUID_StepTemplate:=$stepTemplateEntity.UUID
								$stepTemplateCertificationEntity.UUID_Certification:=$certificationEntity.UUID
								
								$result:=$stepTemplateCertificationEntity.save()
								If ($result.success)
									$linksCreated:=$linksCreated+1
								Else 
									$failed:=$failed+1
								End if 
							End if 
						End if 
					End if 
				End for each 
				
				$toolTypeNames:=New collection:C1472()
				If ($record.toolTypeNames#Null:C1517)
					$toolTypeNames:=$record.toolTypeNames
				Else 
					If (String:C10($record.tool1)#"")
						$toolTypeNames.push(String:C10($record.tool1))
					End if 
					If (String:C10($record.tool2)#"")
						$toolTypeNames.push(String:C10($record.tool2))
					End if 
					If (String:C10($record.tool3)#"")
						$toolTypeNames.push(String:C10($record.tool3))
					End if 
				End if 
				
				$toolOrder:=1
				For each ($toolTypeName; $toolTypeNames)
					If ($toolTypeName#"")
						$toolTypeEntity:=$toolTypeDataClass.query("name = :1"; $toolTypeName).first()
						If ($toolTypeEntity#Null:C1517)
							$stepTemplateToolTypeEntity:=$stepTemplateToolTypeDataClass.new()
							$stepTemplateToolTypeEntity.UUIDStepTemplate:=$stepTemplateEntity.UUID
							$stepTemplateToolTypeEntity.UUID_ToolType:=$toolTypeEntity.UUID
							$stepTemplateToolTypeEntity.order:=$toolOrder
							
							$result:=$stepTemplateToolTypeEntity.save()
							If ($result.success)
								$toolOrder:=$toolOrder+1
							Else 
								$failed:=$failed+1
							End if 
						End if 
					End if 
				End for each 
			Else 
				$failed:=$failed+1
			End if 
		End for each 
		
		ALERT:C41("Import termine - step templates: "+String:C10($created)+" | cert links: "+String:C10($linksCreated)+" | failed: "+String:C10($failed))
	End if 
End if 
