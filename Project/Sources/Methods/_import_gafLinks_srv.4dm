//%attributes = {"executedOnServer":true}
// _import_gafLinks_srv
// Links each GAF form to the steps of the processes the client listed for it, from
// Project/imports/gaf_step_links.json (the client's sheet: GAF / Process per Traveler /
// SPEC REFERENCE). Called by _import_gafLinks, which shows the result on the client.
//
// - A link is a StepSpecification record (the same table Step Templates and Operation
//   Processes edit), tagged moreData.source = "gafSheet" and moreData.mapping:
//   "sure"   the sheet's process name matches an app process, or a clear alias of one
//   "guess"  it went through an alias marked "guess" in the JSON - check those first
//   "rule"   "applies to all production process" (every step) or "steps with QA GATE"
//   (every step whose description contains QA GATE)
// - Process names are compared with _ga_normKey. The sheet's own names go through the
//   "aliases" table of the JSON; edit it there and re-run, no code change needed.
// - The specs in the SPEC REFERENCE column are recorded on the form itself
//   (Specification.moreData.referencedSpecs), not linked to steps: they are the specs that
//   form refers to, and linking them to steps would put them on the traveller.
// - Rows the sheet marks "not related to the traveler", "not process specific", "will
//   review" or leaves blank create no link.
//
// Re-runnable: the previous "gafSheet" links are replaced; links added by hand (source
// "manual") or by _import_steps are never touched, and a pair already linked by either is
// not linked twice. _import_specControl truncates Specification, so run this again after it.
//
// $options: dryRun (default True). A call without options changes nothing.
#DECLARE($options : Object)->$report : Object
	
var $file : 4D:C1709.File
var $data : Object
var $row : Object
var $alias : Object
var $tokens : Collection
var $token : Text
var $key : Text
var $processName : Text
var $confidenceByProcess : Object
var $processByKey : Object
var $processUUIDs : Collection
var $targets : 4D:C1709.EntitySelection
var $esForms : 4D:C1709.EntitySelection
var $esPrevious : 4D:C1709.EntitySelection
var $process : 4D:C1709.Entity
var $step : 4D:C1709.Entity
var $form : 4D:C1709.Entity
var $link : 4D:C1709.Entity
var $res : Object
var $pairs : Object
var $pairKey : Text
var $mapping : Text
var $dryRun : Boolean
var $rowLinked : Boolean
var $ref : Text
var $refsMissing : Collection
var $before : Text
var $formsLinked : Object
	
If ($options=Null:C1517)
	$options:=New object:C1471
End if 
$dryRun:=($options.dryRun=Null:C1517) || Bool:C1537($options.dryRun)
	
$report:=New object:C1471(\
	"dryRun"; $dryRun; \
	"error"; ""; \
	"reportPath"; ""; \
	"rows"; 0; \
	"rowsSkipped"; 0; \
	"formsLinked"; 0; \
	"linksCreated"; 0; \
	"linksGuess"; 0; \
	"linksRule"; 0; \
	"linksAlreadyPresent"; 0; \
	"previousRemoved"; 0; \
	"formsWithReferencedSpecs"; 0; \
	"formNotFound"; New collection:C1472; \
	"formAmbiguous"; New collection:C1472; \
	"unmatched"; New collection:C1472; \
	"refsMissing"; New collection:C1472)
	
$file:=Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("gaf_step_links.json")
If (Not:C34($file.exists))
	$report.error:="File not found: "+$file.platformPath
	return $report
End if 
$data:=JSON Parse:C1218($file.getText())
If ($data.rows=Null:C1517) | ($data.aliases=Null:C1517)
	$report.error:="Unexpected content (rows / aliases missing): "+$file.platformPath
	return $report
End if 
	
// app processes by comparison key
$processByKey:=New object:C1471
For each ($process; ds:C1482.StepProcess.all())
	$processByKey[_ga_normKey($process.name)]:=$process.UUID
End for each 
	
// previous run's links are replaced
$esPrevious:=ds:C1482.StepSpecification.query("moreData.source = :1"; "gafSheet")
$report.previousRemoved:=$esPrevious.length
If (Not:C34($dryRun))
	$esPrevious.drop()
End if 
	
// every other existing link, so a pair is never linked twice
$pairs:=New object:C1471
For each ($link; ds:C1482.StepSpecification.all())
	If ($link.moreData=Null:C1517)
		$pairs[$link.UUID_Step+"|"+$link.UUID_Specification]:=True:C214
	Else 
		If (String:C10($link.moreData.source)#"gafSheet")
			$pairs[$link.UUID_Step+"|"+$link.UUID_Specification]:=True:C214
		End if 
	End if 
End for each 
	
$formsLinked:=New object:C1471
	
For each ($row; $data.rows)
	$report.rows+=1
	
	$esForms:=ds:C1482.Specification.query("spec = :1 AND suppress = :2"; String:C10($row.gaf); False:C215)
	Case of 
		: ($esForms.length=0)
			$report.formNotFound.push(String:C10($row.gaf))
			continue
		: ($esForms.length>1)
			$report.formAmbiguous.push(String:C10($row.gaf))
			continue
	End case 
	$form:=$esForms.first()
	
	// specs this form refers to, kept on the form
	If ($row.specRefs#Null:C1517) && ($row.specRefs.length>0)
		$refsMissing:=New collection:C1472
		For each ($ref; $row.specRefs)
			If (ds:C1482.Specification.query("spec = :1"; $ref).length=0)
				$refsMissing.push($ref)
				$report.refsMissing.push(New object:C1471("gaf"; $row.gaf; "spec"; $ref))
			End if 
		End for each 
		$report.formsWithReferencedSpecs+=1
		If (Not:C34($dryRun))
			$form.moreData:=$form.moreData || New object:C1471
			// undefined on a form never imported: JSON Stringify would raise an error on it
			$before:=""
			If ($form.moreData.referencedSpecs#Null:C1517)
				$before:=JSON Stringify:C1217($form.moreData.referencedSpecs)
			End if 
			If ($before#JSON Stringify:C1217($row.specRefs))
				$form.moreData.referencedSpecs:=$row.specRefs.copy()
				$form.moreData.referencedSpecsMissing:=$refsMissing
				$res:=$form.save()
				If (Not:C34($res.success))
					$report.unmatched.push(New object:C1471("gaf"; $row.gaf; "process"; ""; "reason"; "referenced specs not saved: "+JSON Stringify:C1217($res)))
				End if 
			End if 
		End if 
	End if 
	
	If (String:C10($row.skip)#"")
		$report.rowsSkipped+=1
		continue
	End if 
	
	// target steps
	$confidenceByProcess:=New object:C1471
	Case of 
		: ($row.rule="allSteps")
			$targets:=ds:C1482.Step.all()
			$mapping:="rule"
	
		: ($row.rule="qaGate")
			$targets:=ds:C1482.Step.query("description = :1"; "@QA GATE@")
			$mapping:="rule"
	
		Else 
			$processUUIDs:=New collection:C1472
			$tokens:=Split string:C1554(String:C10($row.process); ","; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
			For each ($token; $tokens)
				If (Substring:C12($token; 1; 1)="*")
					$token:=cs:C1710.sfw_string.me.trimSpace(Substring:C12($token; 2))
				End if 
				$key:=_ga_normKey($token)
				$alias:=$data.aliases[$key]
				Case of 
					: ($alias#Null:C1517)
						For each ($processName; $alias.processes)
							If ($processByKey[_ga_normKey($processName)]#Null:C1517)
								$processUUIDs.push($processByKey[_ga_normKey($processName)])
								// a process reached by a sure name once is sure
								If (String:C10($confidenceByProcess[$processByKey[_ga_normKey($processName)]])#"sure")
									$confidenceByProcess[$processByKey[_ga_normKey($processName)]]:=String:C10($alias.confidence)
								End if 
							Else 
								$report.unmatched.push(New object:C1471("gaf"; $row.gaf; "process"; $token; "reason"; "alias target not found: "+$processName))
							End if 
						End for each 
					: ($processByKey[$key]#Null:C1517)
						$processUUIDs.push($processByKey[$key])
						$confidenceByProcess[$processByKey[$key]]:="sure"
					Else 
						$report.unmatched.push(New object:C1471("gaf"; $row.gaf; "process"; $token; "reason"; "no matching process"))
				End case 
			End for each 
	
			If ($processUUIDs.length=0)
				continue
			End if 
			$targets:=ds:C1482.Step.query("UUID_StepProcess IN :1"; $processUUIDs.distinct())
			$mapping:=""
	End case 
	
	$rowLinked:=False:C215
	For each ($step; $targets)
		$pairKey:=$step.UUID+"|"+$form.UUID
		If (Bool:C1537($pairs[$pairKey]))
			$report.linksAlreadyPresent+=1
			continue
		End if 
		$pairs[$pairKey]:=True:C214
	
		Case of 
			: ($mapping="rule")
				$report.linksRule+=1
			: (String:C10($confidenceByProcess[$step.UUID_StepProcess])="guess")
				$report.linksGuess+=1
		End case 
	
		If (Not:C34($dryRun))
			$link:=ds:C1482.StepSpecification.new()
			$link.UUID_Step:=$step.UUID
			$link.UUID_Specification:=$form.UUID
			$link.moreData:=New object:C1471(\
				"source"; "gafSheet"; \
				"mapping"; Choose:C955($mapping="rule"; "rule"; Choose:C955(String:C10($confidenceByProcess[$step.UUID_StepProcess])="guess"; "guess"; "sure")); \
				"sheetRow"; $row.row; \
				"sheetProcess"; String:C10($row.process))
			$res:=$link.save()
			If (Not:C34($res.success))
				$report.unmatched.push(New object:C1471("gaf"; $row.gaf; "process"; String:C10($step.description); "reason"; "link not saved: "+JSON Stringify:C1217($res)))
				continue
			End if 
		End if 
		$report.linksCreated+=1
		$rowLinked:=True:C214
	End for each 
	
	If ($rowLinked)
		$formsLinked[$form.UUID]:=True:C214
	End if 
End for each 
	
$report.formsLinked:=OB Keys:C1719($formsLinked).length
	
$file:=Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("gaf_step_links_report.json")
$report.reportPath:=$file.platformPath
$file.setText(JSON Stringify:C1217($report; *))
