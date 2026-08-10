//%attributes = {}

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $stepDataClass : 4D:C1709.DataClass
var $stepTemplateDataClass : 4D:C1709.DataClass
var $stepAreaDataClass : 4D:C1709.DataClass
var $processDataClass : 4D:C1709.DataClass
var $stepPropertyDataClass : 4D:C1709.DataClass
var $stepEntity : 4D:C1709.Entity
var $templateEntity : 4D:C1709.Entity
var $areaEntity : 4D:C1709.Entity
var $processEntity : 4D:C1709.Entity
var $stepPropertyMaster : 4D:C1709.Entity
var $result : Object
var $created : Integer
var $failed : Integer
var $templateNumber : Integer
var $processName : Text
var $areaName : Text
var $propertyMask : Integer
var $propertyBit : Text
var $propertyBitMask : Integer
var $stepSpecificationDataClass : 4D:C1709.DataClass
var $stepSpecificationLinkEntity : 4D:C1709.Entity
var $specificationEntity : 4D:C1709.Entity
var $controlSpecRaw : Text
var $specParts : Collection
var $specKeyPart : Text
var $specUUIDsToLink : Collection
var $seenSpecUUIDs : Object
var $specUUID : Text
var $specControlItems : Collection
var $fullTitle : Text

$stepDataClass:=ds:C1482["Step"]
$stepTemplateDataClass:=ds:C1482["StepTemplate"]
$stepAreaDataClass:=ds:C1482["StepArea"]
$processDataClass:=ds:C1482["StepProcess"]
$stepPropertyDataClass:=ds:C1482["StepProperty"]
$stepSpecificationDataClass:=ds:C1482["StepSpecification"]

If (($stepDataClass=Null:C1517) | ($stepTemplateDataClass=Null:C1517) | ($stepAreaDataClass=Null:C1517) | ($processDataClass=Null:C1517) | ($stepPropertyDataClass=Null:C1517) | ($stepSpecificationDataClass=Null:C1517))
	ALERT:C41("Missing DataClass: Step, StepTemplate, StepArea, StepProcess, StepProperty or StepSpecification.")
Else 
	$stepSpecificationDataClass.all().drop()
	If (ds:C1482["StepSpec"]#Null:C1517)
		ds:C1482["StepSpec"].all().drop()
	End if 
	$stepDataClass.all().drop()
	
	$projectFolder:=Folder:C1567(fk database folder:K87:14)
	$importsFolder:=$projectFolder.folder("project/imports")
	$file:=$importsFolder.file("steps_export.json")
	
	If (Not:C34($file.exists))
		ALERT:C41("Import file not found: "+$file.platformPath)
	Else 
		$records:=JSON Parse:C1218($file.getText())
		
		$created:=0
		$failed:=0
		
		For each ($record; $records)
			$stepEntity:=$stepDataClass.new()
			
			$templateNumber:=Num:C11($record.Template)
			$templateEntity:=$stepTemplateDataClass.query("templateNumber = :1"; $templateNumber).first()
			If ($templateEntity#Null:C1517)
				$stepEntity.UUID_StepTemplate:=$templateEntity.UUID
			Else 
				$stepEntity.UUID_StepTemplate:=16*"00"
			End if 
			
			$areaName:=$record.Area
			$areaEntity:=$stepAreaDataClass.query("name = :1"; $areaName).first()
			If ($areaEntity#Null:C1517)
				$stepEntity.UUID_StepArea:=$areaEntity.UUID
			Else 
				$stepEntity.UUID_StepArea:=16*"00"
			End if 
			
			$stepEntity.description:=$record.Description
			$stepEntity.alert:=$record.Step_Alert
			
			$controlSpecRaw:=String:C10($record.ControlSpec)
			$specUUIDsToLink:=New collection:C1472()
			$seenSpecUUIDs:=New object:C1471()
			$specControlItems:=New collection:C1472()
			If ($controlSpecRaw#"")
				$specParts:=Split string:C1554($controlSpecRaw; ";")
				For each ($specKeyPart; $specParts)
					$specKeyPart:=cs:C1710.sfw_string.me.trimSpace(String:C10($specKeyPart))
					If ($specKeyPart#"")
						$specificationEntity:=ds:C1482.Specification.query("spec = :1"; $specKeyPart).first()
						If ($specificationEntity#Null:C1517)
							$specUUID:=String:C10($specificationEntity.UUID)
							If ($seenSpecUUIDs[$specUUID]#True:C214)
								$seenSpecUUIDs[$specUUID]:=True:C214
								// Table approach: create StepSpecification record
								$stepSpecification:=ds:C1482.StepSpecification.new()
								$stepSpecification.UUID_Step:=$stepEntity.UUID
								$stepSpecification.UUID_Specification:=$specificationEntity.UUID
								$result:=$stepSpecification.save()
								If (Not:C34($result.success))
									TRACE:C157
								End if
								// Object approach: accumulate item for specificationControl
								$fullTitle:=String:C10($specificationEntity.title)
								If ($fullTitle="")
									$fullTitle:=String:C10($specificationEntity.spec)
								End if
								$specControlItems.push(New object:C1471(\
									"enable"; True:C214; \
									"UUID_Specification"; $specificationEntity.UUID; \
									"fullTitle"; $fullTitle; \
									"spec"; String:C10($specificationEntity.spec); \
									"revision"; String:C10($specificationEntity.revision)\
									))
							End if
						End if
					End if
				End for each
			End if
			If ($stepEntity.moreData=Null:C1517)
				$stepEntity.moreData:=New object:C1471()
			End if
			$stepEntity.moreData.specificationControl:=New object:C1471("items"; $specControlItems)
			
			//$stepEntity.UUID_Specification:=16*"00"
			//If ($specUUIDsToLink.length>0)
			//$stepEntity.UUID_Specification:=$specUUIDsToLink[0]
			//End if 
			
			//$stepEntity.moreData:=New object()
			//If (($controlSpecRaw#"") & ($specUUIDsToLink.length=0))
			//$stepEntity.moreData.controlSpecText:=$controlSpecRaw
			//End if 
			
			$processName:=$record.Process
			//$stepEntity.moreData.Process:=$processName
			$processEntity:=$processDataClass.query("name = :1"; $processName).first()
			If ($processEntity#Null:C1517)
				$stepEntity.UUID_StepProcess:=$processEntity.UUID
				//$stepEntity.moreData.processName:=$processEntity.name
			Else 
				$stepEntity.UUID_StepProcess:=16*"00"
				$stepEntity.moreData.processName:=""
			End if 
			
			$propertyMask:=Num:C11($record.StepProperty)
			$stepEntity.stepProperties:=New object:C1471("items"; New collection:C1472())
			For each ($stepPropertyMaster; $stepPropertyDataClass.all().orderBy("levelID"))
				$propertyBit:=String:C10($stepPropertyMaster.moreData.bit)
				$propertyBitMask:=Num:C11($propertyBit)
				Case of 
					: ($propertyBit="0x0001")
						$propertyBitMask:=0x0001
					: ($propertyBit="0x0002")
						$propertyBitMask:=0x0002
					: ($propertyBit="0x0004")
						$propertyBitMask:=0x0004
					: ($propertyBit="0x0008")
						$propertyBitMask:=0x0008
					: ($propertyBit="0x0010")
						$propertyBitMask:=0x0010
					: ($propertyBit="0x0020")
						$propertyBitMask:=0x0020
					: ($propertyBit="0x0040")
						$propertyBitMask:=0x0040
					: ($propertyBit="0x0080")
						$propertyBitMask:=0x0080
					: ($propertyBit="0x0100")
						$propertyBitMask:=0x0100
					: ($propertyBit="0x0200")
						$propertyBitMask:=0x0200
					: ($propertyBit="0x0400")
						$propertyBitMask:=0x0400
					: ($propertyBit="0x0800")
						$propertyBitMask:=0x0800
					: ($propertyBit="0x1000")
						$propertyBitMask:=0x1000
					: ($propertyBit="0x2000")
						$propertyBitMask:=0x2000
					: ($propertyBit="0x4000")
						$propertyBitMask:=0x4000
					: ($propertyBit="0x8000")
						$propertyBitMask:=0x8000
					: ($propertyBit="0x00010000")
						$propertyBitMask:=0x00010000
					: ($propertyBit="0x00020000")
						$propertyBitMask:=0x00020000
					: ($propertyBit="0x00040000")
						$propertyBitMask:=0x00040000
					: ($propertyBit="0x00080000")
						$propertyBitMask:=0x00080000
					: ($propertyBit="0x00100000")
						$propertyBitMask:=0x00100000
				End case 
				
				$stepEntity.stepProperties.items.push(New object:C1471(\
					"id"; $stepPropertyMaster.UUID; \
					"name"; $stepPropertyMaster.name; \
					"description"; $stepPropertyMaster.description; \
					"bit"; $propertyBit; \
					"enable"; (($propertyMask & $propertyBitMask)=$propertyBitMask)\
					))
			End for each 
			
			$result:=$stepEntity.save()
			If ($result.success)
				$created:=$created+1
				For each ($specUUID; $specUUIDsToLink)
					$stepSpecificationLinkEntity:=$stepSpecificationDataClass.new()
					$stepSpecificationLinkEntity.UUID_Step:=$stepEntity.UUID
					$stepSpecificationLinkEntity.UUID_Specification:=$specUUID
					$result:=$stepSpecificationLinkEntity.save()
				End for each 
			Else 
				$failed:=$failed+1
			End if 
		End for each 
		
		ALERT:C41("Import termine - steps: "+String:C10($created)+" | failed: "+String:C10($failed))
	End if 
End if 
