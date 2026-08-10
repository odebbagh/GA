//%attributes = {}

// Imports project/imports/steps_files_export.json into StepFile (name, customer link, moreData meta,
// stepsDefinition.items built from record.arrays). Does not create Step or StepSpecification records.

var $projectFolder : 4D:C1709.Folder
var $importsFolder : 4D:C1709.Folder
var $file : 4D:C1709.File
var $records : Collection
var $record : Object
var $arrays : Object
var $customer : 4D:C1709.Entity
var $stepFile : 4D:C1709.Entity
var $items : Collection
var $row : Object
var $i : Integer
var $max : Integer
var $res : Object
var $created : Integer
var $failed : Integer
var $v : Variant
var $abortCustomer : Boolean
var $specificationEntity : 4D:C1709.Entity
var $stepPropertyImportMasks : Collection
var $stepPropItems : Collection
var $flags : Integer
var $spDef : Object
var $spMaster : 4D:C1709.Entity
var $orderedSpecUUIDs : Collection
var $seenSpecUUIDsForStep : Object
var $chunk : Text
var $piece : Text
var $specUUIDKey : Text
var $stepTemplateNumber : Integer
var $stepTemplateEs : 4D:C1709.EntitySelection
var $existingSf : 4D:C1709.Entity
var $defObj : Object
var $defItem : Object
var $stepUUIDs : Collection
var $seenStepUUID : Object
var $sfUUIDs : Collection
var $stepU : Variant
var $ssel : 4D:C1709.EntitySelection
var $job : 4D:C1709.Entity
var $sfUUID : Variant
var $emptyStepFileUUID : Text
var $stepUUIDKey : Text

$projectFolder:=Folder:C1567(fk database folder:K87:14)
$importsFolder:=$projectFolder.folder("project/imports")
$file:=$importsFolder.file("steps_files_export.json")

If (Not:C34($file.exists))
	ALERT:C41("Import file not found: "+$file.platformPath)
Else 
	// Legacy A_StepProperty bitmask → StepProperty.name (same codes as stepProperties_export / _import_stepProperties).
	$stepPropertyImportMasks:=New collection:C1472(\
		New object:C1471("name"; "HPT"; "mask"; 0x0001); \
		New object:C1471("name"; "FZT"; "mask"; 0x0004); \
		New object:C1471("name"; "SSR"; "mask"; 0x0010); \
		New object:C1471("name"; "QSR"; "mask"; 0x0020); \
		New object:C1471("name"; "SNA"; "mask"; 0x0040); \
		New object:C1471("name"; "SNF"; "mask"; 0x0080); \
		New object:C1471("name"; "SNP"; "mask"; 0x0100); \
		New object:C1471("name"; "NSP"; "mask"; 0x0400); \
		New object:C1471("name"; "OCR"; "mask"; 0x0800); \
		New object:C1471("name"; "FQS"; "mask"; 0x1000); \
		New object:C1471("name"; "WMA"; "mask"; 0x00010000); \
		New object:C1471("name"; "PIT"; "mask"; 0x00020000); \
		New object:C1471("name"; "QFR"; "mask"; 0x00080000); \
		New object:C1471("name"; "CLR"; "mask"; 0x00100000)\
		)
	
	$records:=JSON Parse:C1218($file.getText())
	
	// Full reset: remove existing StepFile data (and definition Steps / StepSpecifications), then import from scratch.
	$emptyStepFileUUID:=16*"00"
	$stepUUIDs:=New collection:C1472()
	$seenStepUUID:=New object:C1471()
	$sfUUIDs:=New collection:C1472()
	For each ($existingSf; ds:C1482.StepFile.all())
		$sfUUIDs.push($existingSf.UUID)
		$defObj:=Choose:C955(Value type:C1509($existingSf.stepsDefinition)=Is object:K8:27; $existingSf.stepsDefinition; New object:C1471())
		If (($defObj.items#Null:C1517) & (Value type:C1509($defObj.items)=Is collection:K8:20))
			For each ($defItem; $defObj.items)
				If (($defItem.UUID_Step#Null:C1517) & (cs:C1710.sfw_string.me.isAnEmptyUUID($defItem.UUID_Step)=False:C215))
					$stepUUIDKey:=String:C10($defItem.UUID_Step)
					If ($seenStepUUID[$stepUUIDKey]#True:C214)
						$seenStepUUID[$stepUUIDKey]:=True:C214
						$stepUUIDs.push($defItem.UUID_Step)
					End if 
				End if 
			End for each 
		End if 
	End for each 
	
	For each ($stepU; $stepUUIDs)
		$ssel:=ds:C1482.StepSpecification.query("UUID_Step = :1"; $stepU)
		If ($ssel.length>0)
			$ssel.drop()
		End if 
	End for each 
	For each ($stepU; $stepUUIDs)
		$ssel:=ds:C1482.Step.query("UUID = :1"; $stepU)
		If ($ssel.length>0)
			$ssel.drop()
		End if 
	End for each 
	
	For each ($sfUUID; $sfUUIDs)
		$ssel:=ds:C1482.Job.query("UUID_StepFile = :1"; $sfUUID)
		For each ($job; $ssel)
			$job.UUID_StepFile:=$emptyStepFileUUID
			$job.save()
		End for each 
	End for each 
	
	If (ds:C1482.StepFile.all().length>0)
		ds:C1482.StepFile.all().drop()
	End if 
	
	$created:=0
	$failed:=0
	
	For each ($record; $records)
		
		If ((String:C10($record.Name)="") | (String:C10($record.Customer)=""))
			$failed:=$failed+1
		Else 
			
			$customer:=ds:C1482.Customer.query("name = :1"; String:C10($record.Customer)).first()
			$abortCustomer:=False:C215
			//If ($customer=Null)
			//$customer:=ds.Customer.new()
			//$customer.name:=String($record.Customer)
			//$res:=$customer.save()
			//If (Not($res.success))
			//$failed:=$failed+1
			//$abortCustomer:=True
			//End if 
		End if 
		
		If (Not:C34($abortCustomer))
			
			$stepFile:=ds:C1482.StepFile.new()
			
			$stepFile.name:=String:C10($record.Name)
			$stepFile.UUID_Customer:=$customer.UUID
			$stepFile.status:=True:C214
			
			If (Undefined:C82($record.Date_made)=False:C215)
				$stepFile.creationDate:=$record.Date_made
			End if 
			
			$stepFile.moreData:=Choose:C955($stepFile.moreData=Null:C1517; New object:C1471(); $stepFile.moreData)
			$stepFile.moreData.Made_by:=String:C10($record.Made_by)
			$stepFile.moreData.Date_mod:=String:C10($record.Date_mod)
			$stepFile.moreData.Mod_by:=String:C10($record.Mod_by)
			$stepFile.moreData.Mod_history:=String:C10($record.Mod_history)
			
			$arrays:=Choose:C955(Value type:C1509($record.arrays)=Is object:K8:27; $record.arrays; New object:C1471())
			
			$max:=0
			If ($arrays.a_tsdesc#Null:C1517)
				If ($arrays.a_tsdesc.length>$max)
					$max:=$arrays.a_tsdesc.length
				End if 
			End if 
			If ($arrays.a_tsnum#Null:C1517)
				If ($arrays.a_tsnum.length>$max)
					$max:=$arrays.a_tsnum.length
				End if 
			End if 
			If ($arrays.a_ttime#Null:C1517)
				If ($arrays.a_ttime.length>$max)
					$max:=$arrays.a_ttime.length
				End if 
			End if 
			If ($arrays.a_tstype#Null:C1517)
				If ($arrays.a_tstype.length>$max)
					$max:=$arrays.a_tstype.length
				End if 
			End if 
			If ($arrays.a_tsalert#Null:C1517)
				If ($arrays.a_tsalert.length>$max)
					$max:=$arrays.a_tsalert.length
				End if 
			End if 
			If ($arrays.a_Area#Null:C1517)
				If ($arrays.a_Area.length>$max)
					$max:=$arrays.a_Area.length
				End if 
			End if 
			If ($arrays.a_tsyield#Null:C1517)
				If ($arrays.a_tsyield.length>$max)
					$max:=$arrays.a_tsyield.length
				End if 
			End if 
			If ($arrays.a_tempC#Null:C1517)
				If ($arrays.a_tempC.length>$max)
					$max:=$arrays.a_tempC.length
				End if 
			End if 
			If ($arrays.a_template_repeat#Null:C1517)
				If ($arrays.a_template_repeat.length>$max)
					$max:=$arrays.a_template_repeat.length
				End if 
			End if 
			If ($arrays.a_planhrs#Null:C1517)
				If ($arrays.a_planhrs.length>$max)
					$max:=$arrays.a_planhrs.length
				End if 
			End if 
			If ($arrays.A_BomForStep#Null:C1517)
				If ($arrays.A_BomForStep.length>$max)
					$max:=$arrays.A_BomForStep.length
				End if 
			End if 
			If ($arrays.A_StepProperty#Null:C1517)
				If ($arrays.A_StepProperty.length>$max)
					$max:=$arrays.A_StepProperty.length
				End if 
			End if 
			If ($arrays.A_StepPropertyinText#Null:C1517)
				If ($arrays.A_StepPropertyinText.length>$max)
					$max:=$arrays.A_StepPropertyinText.length
				End if 
			End if 
			If ($arrays.A_TS_SPEC#Null:C1517)
				If ($arrays.A_TS_SPEC.length>$max)
					$max:=$arrays.A_TS_SPEC.length
				End if 
			End if 
			
			$items:=New collection:C1472()
			
			// JSON arrays parse to 0-based collections: row $i (1..max) → element [$i-1].
			For ($i; 1; $max)
				
				$row:=New object:C1471
				
				$v:=Null:C1517
				If ($arrays.a_tsnum#Null:C1517)
					If ($i<=$arrays.a_tsnum.length)
						$v:=$arrays.a_tsnum[$i-1]
					End if 
				End if 
				$row.order:=Num:C11($v)
				//If ($row.order=0)
				//$row.order:=$i
				//End if 
				
				$v:=Null:C1517
				If ($arrays.a_tsdesc#Null:C1517)
					If ($i<=$arrays.a_tsdesc.length)
						$v:=$arrays.a_tsdesc[$i-1]
					End if 
				End if 
				$row.description:=String:C10($v)
				
				$v:=Null:C1517
				If ($arrays.a_ttime#Null:C1517)
					If ($i<=$arrays.a_ttime.length)
						$v:=$arrays.a_ttime[$i-1]
					End if 
				End if 
				$row.time:=Num:C11($v)
				
				$v:=Null:C1517
				If ($arrays.a_tstype#Null:C1517)
					If ($i<=$arrays.a_tstype.length)
						$v:=$arrays.a_tstype[$i-1]
					End if 
				End if 
				$stepTemplateNumber:=Num:C11($v)
				$row.step_template:=$stepTemplateNumber
				$row.UUID_Step:=16*"00"
				
				$v:=Null:C1517
				If ($arrays.a_tsalert#Null:C1517)
					If ($i<=$arrays.a_tsalert.length)
						$v:=$arrays.a_tsalert[$i-1]
					End if 
				End if 
				$row.alert:=String:C10($v)
				
				$v:=Null:C1517
				If ($arrays.a_Area#Null:C1517)
					If ($i<=$arrays.a_Area.length)
						$v:=$arrays.a_Area[$i-1]
					End if 
				End if 
				$row.area:=String:C10($v)
				
				$v:=Null:C1517
				If ($arrays.a_tsyield#Null:C1517)
					If ($i<=$arrays.a_tsyield.length)
						$v:=$arrays.a_tsyield[$i-1]
					End if 
				End if 
				$row.yield:=Num:C11($v)
				
				$v:=Null:C1517
				If ($arrays.a_tempC#Null:C1517)
					If ($i<=$arrays.a_tempC.length)
						$v:=$arrays.a_tempC[$i-1]
					End if 
				End if 
				$row.temp_c:=Num:C11($v)
				
				$v:=Null:C1517
				If ($arrays.a_template_repeat#Null:C1517)
					If ($i<=$arrays.a_template_repeat.length)
						$v:=$arrays.a_template_repeat[$i-1]
					End if 
				End if 
				$row.template_repeat:=Num:C11($v)
				
				$v:=Null:C1517
				If ($arrays.a_planhrs#Null:C1517)
					If ($i<=$arrays.a_planhrs.length)
						$v:=$arrays.a_planhrs[$i-1]
					End if 
				End if 
				$row.planned_hours:=Num:C11($v)
				
				$v:=Null:C1517
				If ($arrays.A_BomForStep#Null:C1517)
					If ($i<=$arrays.A_BomForStep.length)
						$v:=$arrays.A_BomForStep[$i-1]
					End if 
				End if 
				$row.bom_for_step:=String:C10($v)
				
				$v:=Null:C1517
				If ($arrays.A_StepProperty#Null:C1517)
					If ($i<=$arrays.A_StepProperty.length)
						$v:=$arrays.A_StepProperty[$i-1]
					End if 
				End if 
				$row.step_property:=Num:C11($v)
				
				// Enabled bits → StepProperty entities (UUID, labels, bit); matches panel_step stepProperties.items shape.
				$stepPropItems:=New collection:C1472()
				$flags:=Num:C11($row.step_property)
				For each ($spDef; $stepPropertyImportMasks)
					If (($flags & $spDef.mask)=$spDef.mask)
						$spMaster:=ds:C1482.StepProperty.query("name = :1"; $spDef.name).first()
						If ($spMaster#Null:C1517)
							$stepPropItems.push(New object:C1471(\
								"uuid"; $spMaster.UUID; \
								"name"; $spMaster.name; \
								"title"; $spMaster.description; \
								"enabled"; True:C214\
								))
						End if 
					End if 
				End for each 
				$row.stepProperties:=New object:C1471("items"; $stepPropItems)
				
				$v:=Null:C1517
				If ($arrays.A_StepPropertyinText#Null:C1517)
					If ($i<=$arrays.A_StepPropertyinText.length)
						$v:=$arrays.A_StepPropertyinText[$i-1]
					End if 
				End if 
				$row.step_property_in_text:=String:C10($v)
				
				$v:=Null:C1517
				If ($arrays.A_TS_SPEC#Null:C1517)
					If ($i<=$arrays.A_TS_SPEC.length)
						$v:=$arrays.A_TS_SPEC[$i-1]
					End if 
				End if 
				
				// Multiple catalog specs in one cell: separate with ";" (same as _import_steps ControlSpec); commas allowed within a segment.
				$orderedSpecUUIDs:=New collection:C1472()
				$seenSpecUUIDsForStep:=New object:C1471()
				$specRaw:=String:C10($v)
				If ($specRaw#"")
					For each ($chunk; Split string:C1554($specRaw; ";"))
						$chunk:=cs:C1710.sfw_string.me.trimSpace(String:C10($chunk))
						If ($chunk#"")
							For each ($piece; Split string:C1554($chunk; ","))
								$piece:=cs:C1710.sfw_string.me.trimSpace(String:C10($piece))
								If ($piece#"")
									$specificationEntity:=ds:C1482.Specification.query("spec = :1"; $piece).first()
									If ($specificationEntity#Null:C1517)
										$specUUIDKey:=String:C10($specificationEntity.UUID)
										If ($seenSpecUUIDsForStep[$specUUIDKey]#True:C214)
											$seenSpecUUIDsForStep[$specUUIDKey]:=True:C214
											$orderedSpecUUIDs.push($specificationEntity.UUID)
										End if 
									End if 
								End if 
							End for each 
						End if 
					End for each 
				End if 
				
				$row.specification:=""
				$row.UUID_Specification:=16*"00"
				If ($orderedSpecUUIDs.length>0)
					$row.UUID_Specification:=$orderedSpecUUIDs[0]
					$specificationEntity:=ds:C1482.Specification.query("UUID = :1"; $orderedSpecUUIDs[0]).first()
					If ($specificationEntity#Null:C1517)
						$row.specification:=String:C10($specificationEntity.spec)
					End if 
				End if 
				
				If ($stepTemplateNumber#0)
					$stepTemplateEs:=ds:C1482.StepTemplate.query("templateNumber = :1"; $stepTemplateNumber)
					If ($stepTemplateEs.length>0)
						$row.step_property_rules:=cs:C1710.panel_stepFile.me.newStepPropertyRulesObjectFromTemplate($stepTemplateEs[0])
					Else 
						$row.step_property_rules:=New object:C1471("items"; New collection:C1472())
					End if 
				Else 
					$row.step_property_rules:=New object:C1471("items"; New collection:C1472())
				End if 
				cs:C1710.panel_stepFile.me.mergeStepPropertyRuleEnableFromStepProperties($row)
				
				// Definition only: no Step / StepSpecification table rows (UUID filled when user adds from process or duplicates).
				$row.UUID_Step:=16*"00"
				$row.stepSpecifications:=cs:C1710.panel_stepFile.me.buildStepSpecificationsObjectForRow($row; Null:C1517; $orderedSpecUUIDs)
				cs:C1710.panel_stepFile.me.applyDerivedStepRowColumns($row)
				
				$items.push($row)
				
			End for 
			
			$stepFile.stepsDefinition:=New object:C1471("items"; $items)
			
			$res:=$stepFile.save()
			If ($res.success)
				$created:=$created+1
			Else 
				$failed:=$failed+1
			End if 
			
		End if 
		
	End for each 
	
	ALERT:C41("Import steps files (full replace) — step files imported: "+String:C10($created)+" | failed: "+String:C10($failed))
End if 
