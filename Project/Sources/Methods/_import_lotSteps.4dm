//%attributes = {}

// Import project/imports/lotsteps_export.json into LotStep.
// Rules:
// - Link LotStep to Lot by Lotnum -> Lot.lotNumber
// - Skip rows when no matching Lot exists
// - Import only requested fields for now

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $lot : 4D:C1709.Entity
var $lotStep : 4D:C1709.Entity
var $res : Object
var $created : Integer
var $updated : Integer
var $skipped : Integer
var $failed : Integer
var $rules : Collection
var $rule : 4D:C1709.Entity
var $ruleRow : Object
var $propertyMask : Integer
var $enabledRuleUUIDs : Collection
var $enabledRuleNames : Collection
var $enabledLegacyRuleNames : Collection
var $legacyRules : Collection
var $legacyRule : Object
var $legacyNameNorm : Text
var $legacyAlias : Text
var $legacyAliases : Collection
var $ruleNameNorm : Text
var $ruleDescNorm : Text
var $matched : Boolean
var $seenUUIDs : Object

TRUNCATE TABLE:C1051([LotStep:5])

$projectFolder:=Folder:C1567(fk database folder:K87:14)
$importsFolder:=$projectFolder.folder("project/imports")
$file:=$importsFolder.file("lotsteps_export.json")

If (Not:C34($file.exists))
	ALERT:C41("Import file not found: "+$file.platformPath)
Else 
	$records:=JSON Parse:C1218($file.getText())
	
	$created:=0
	$updated:=0
	$skipped:=0
	$failed:=0
	
	// Existing rules in the new table (targets to link).
	$rules:=New collection:C1472()
	For each ($rule; ds:C1482.StepTemplateRule.all().orderBy("levelID"))
		$ruleRow:=New object:C1471()
		$ruleRow.UUID:=$rule.UUID
		$ruleRow.name:=$rule.name
		$ruleRow.description:=$rule.description
		$ruleRow.nameNorm:=Lowercase:C14(cs:C1710.sfw_string.me.trimSpace($rule.name))
		$ruleRow.descNorm:=Lowercase:C14(cs:C1710.sfw_string.me.trimSpace($rule.description))
		$rules.push($ruleRow)
	End for each 
	
	// Legacy Property bit dictionary provided by user (source system).
	$legacyRules:=New collection:C1472(New object:C1471("mask"; 1; "name"; "Hold Point")\
		; New object:C1471("mask"; 2; "name"; "Reserved")\
		; New object:C1471("mask"; 4; "name"; "Reserved (Freeze Traveler)")\
		; New object:C1471("mask"; 8; "name"; "Reserved")\
		; New object:C1471("mask"; 16; "name"; "Supervisor's Signoff is required")\
		; New object:C1471("mask"; 32; "name"; "QA signoff is required")\
		; New object:C1471("mask"; 64; "name"; "SN logging for all units in current-step")\
		; New object:C1471("mask"; 128; "name"; "SN logging for current-step fails")\
		; New object:C1471("mask"; 256; "name"; "SN logging at Punch-IN")\
		; New object:C1471("mask"; 512; "name"; "Reserved")\
		; New object:C1471("mask"; 1024; "name"; "Step may be performed non-sequentially")\
		; New object:C1471("mask"; 2048; "name"; "Outside of Count Rules")\
		; New object:C1471("mask"; 4096; "name"; "Final QA Approval with Stamp")\
		; New object:C1471("mask"; 8192; "name"; "Reserved")\
		; New object:C1471("mask"; 16384; "name"; "Reserved")\
		; New object:C1471("mask"; 32768; "name"; "Reserved")\
		; New object:C1471("mask"; 65536; "name"; "Reserved")\
		; New object:C1471("mask"; 131072; "name"; "Pareto in Traveler")\
		; New object:C1471("mask"; 262144; "name"; "Reserved")\
		; New object:C1471("mask"; 524288; "name"; "QA Final Review")\
		; New object:C1471("mask"; 1048576; "name"; "Clear"))
	
	For each ($record; $records)
		
		If ($created>=6000)
			break
		End if 
		
		$lot:=Null:C1517
		
		If (Undefined:C82($record.Lotnum)=False:C215)
			$lot:=ds:C1482.Lot.query("lotNumber = :1"; String:C10($record.Lotnum)).first()
		End if 
		
		// If no linked lot, do not import this row.
		If ($lot=Null:C1517)
			$skipped:=$skipped+1
		Else 
			$order:=Num:C11($record.LotStepNumber)
			If ($order<=0)
				$order:=1
			End if 
			
			// Upsert by lot + order to allow re-import safely.
			$lotStep:=ds:C1482.LotStep.query("UUID_Lot = :1 AND order = :2"; $lot.UUID; $order).first()
			If ($lotStep=Null:C1517)
				$lotStep:=ds:C1482.LotStep.new()
				$created:=$created+1
			Else 
				$updated:=$updated+1
			End if 
			
			$lotStep.UUID_Lot:=$lot.UUID
			$lotStep.order:=$order
			$lotStep.description:=String:C10($record.StepDesc)
			$lotStep.qtyIn:=Num:C11($record.QtyIn)
			$lotStep.qtyOut:=Num:C11($record.QtyOut)
			$lotStep.yield:=Num:C11($record.Yield)
			$lotStep.minYield:=Num:C11($record.Step_Accyld)
			$lotStep.type:=Num:C11($record.Step_Type)
			$lotStep.dateIn:=$record.DateIn
			$lotStep.timeIn:=$record.Timein
			$lotStep.dateOut:=$record.DateOut
			$lotStep.timeOut:=$record.TimeOut
			$lotStep.actualHours:=$record.ActualHours
			$lotStep.plannedHours:=$record.Planned_hrs
			$lotStep.sample:=$record.Sample
			$lotStep.area:=$record.Step_Area
			
			$propertyMask:=Num:C11($record.Property)
			$enabledRuleUUIDs:=New collection:C1472()
			$enabledRuleNames:=New collection:C1472()
			$enabledLegacyRuleNames:=New collection:C1472()
			$seenUUIDs:=New object:C1471()
			
			$lotStep.properties:=New object:C1471
			$lotStep.properties.items:=New collection:C1472()
			
			For each ($legacyRule; $legacyRules)
				
				$uuid_step:=""
				
				If (($legacyRule.mask>0) & (($propertyMask & $legacyRule.mask)=$legacyRule.mask))
					
					Case of 
						: ($legacyNameNorm="SN logging for all units in current-step")
							$uuid_step:=ds:C1482.StepProperty.query("description = :1"; "SN Table For All Units").first().UUID
						: ($legacyNameNorm="SN logging for current-step fails")
							$uuid_step:=ds:C1482.StepProperty.query("description = :1"; "SN Table For Fails Only").first().UUID
						: ($legacyNameNorm="SN logging at Punch-IN")
							$uuid_step:=ds:C1482.StepProperty.query("description = :1"; "SN Table At Punchin").first().UUID
					End case 
					
					If ($uuid_step#"")
						$lotStep.properties.items.push(New object:C1471("uuid"; $uuid_step; "enabled"; True:C214))
					End if 
					
					//If (False)
					$enabledLegacyRuleNames.push($legacyRule.name)
					$legacyNameNorm:=Lowercase:C14(cs:C1710.sfw_string.me.trimSpace($legacyRule.name))
					$legacyAliases:=New collection:C1472($legacyNameNorm)
					Case of 
						: ($legacyNameNorm="outside of count rules")
							$legacyAliases.push("out side of count rules")
						: ($legacyNameNorm="final qa approval with stamp")
							$legacyAliases.push("final qa approval with stamp")
							$legacyAliases.push("fqa")
						: ($legacyNameNorm="qa final review")
							$legacyAliases.push("final qa approval with stamp")
							$legacyAliases.push("fqa")
						: ($legacyNameNorm="step may be performed non-sequentially")
							$legacyAliases.push("step may be performed non sequentially")
					End case 
					
					For each ($ruleRow; $rules)
						$matched:=False:C215
						$ruleNameNorm:=$ruleRow.nameNorm
						$ruleDescNorm:=$ruleRow.descNorm
						For each ($legacyAlias; $legacyAliases)
							If (($legacyAlias=$ruleNameNorm) | ($legacyAlias=$ruleDescNorm))
								$matched:=True:C214
							End if 
						End for each 
						If ($matched & ($seenUUIDs[$ruleRow.UUID]#True:C214))
							$seenUUIDs[$ruleRow.UUID]:=True:C214
							$enabledRuleUUIDs.push($ruleRow.UUID)
							$enabledRuleNames.push($ruleRow.name)
						End if 
					End for each 
					//End if 
					
				Else 
					
					Case of 
						: ($legacyNameNorm="SN logging for all units in current-step")
							$uuid_step:=ds:C1482.StepProperty.query("description = :1"; "SN Table For All Units").first().UUID
						: ($legacyNameNorm="SN logging for current-step fails")
							$uuid_step:=ds:C1482.StepProperty.query("description = :1"; "SN Table For Fails Only").first().UUID
						: ($legacyNameNorm="SN logging at Punch-IN")
							$uuid_step:=ds:C1482.StepProperty.query("description = :1"; "SN Table At Punchin").first().UUID
					End case 
					
					If ($uuid_step#"")
						$lotStep.properties.items.push(New object:C1471("uuid"; $uuid_step; "enabled"; False:C215))
					End if 
					
				End if 
			End for each 
			$lotStep.properties:=Choose:C955($lotStep.properties=Null:C1517; New object:C1471(); $lotStep.properties)
			$lotStep.properties.enabledRuleUUIDs:=$enabledRuleUUIDs
			$lotStep.properties.enabledRuleNames:=$enabledRuleNames
			$lotStep.properties.enabledLegacyPropertyRules:=$enabledLegacyRuleNames
			$lotStep.properties.legacyPropertyMask:=$propertyMask
			
			$res:=$lotStep.save()
			If (Not:C34($res.success))
				$failed:=$failed+1
			End if 
		End if 
	End for each 
	
	ALERT:C41("Import lotSteps — created: "+String:C10($created)+" | updated: "+String:C10($updated)+" | skipped(no lot): "+String:C10($skipped)+" | failed: "+String:C10($failed))
End if 
