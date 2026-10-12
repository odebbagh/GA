// ga_demoCheck
// Pre-demo self test, run by _demo_check. Each check returns {ok; detail; fix}; a check that
// raises a 4D error is caught (Try) and reported as failed with the error text, and the
// other checks still run.
// - Data checks only read.
// - Logic checks build throwaway records inside a transaction that is always cancelled, so
//   nothing they create stays in the database (only the lot sequence number moves on).
// Nothing here writes an event, a comment or an NCMN number.
Class constructor
	This:C1470.results:=New collection:C1472
	This:C1470.inTransaction:=False:C215
	This:C1470.d6Steps:=New collection:C1472
	
Function run()->$report : Collection
	var $check : Object
	var $r : Variant
	var $errors : Collection
	var $checks : Collection
	
	$checks:=New collection:C1472(\
		New object:C1471("name"; "checkSequences"; "label"; "Lot, job and inventory numbers: a new record gets a free number"); \
		New object:C1471("name"; "checkStaff"; "label"; "Demo people and their profiles"); \
		New object:C1471("name"; "checkStepFile"; "label"; "Customer Microchip + step file Microchip - Group D6"); \
		New object:C1471("name"; "checkReference"; "label"; "Hold code, step properties, bins"); \
		New object:C1471("name"; "checkTravellers"; "label"; "Traveller print templates"); \
		New object:C1471("name"; "checkGafFile"; "label"; "GAF-1022 file opens (Document Control > View)"); \
		New object:C1471("name"; "checkFormsAndSpecs"; "label"; "Forms & Specs: each step lists its own documents"); \
		New object:C1471("name"; "checkTools"; "label"; "Tools: step 1 asks for a microscope, expired ones hidden"); \
		New object:C1471("name"; "checkQASignoff"; "label"; "QA sign-off required when QSR is ticked in Planning"); \
		New object:C1471("name"; "checkHistory"; "label"; "History lines (punch in, QA, tools, interruptions, holds, SN)"); \
		New object:C1471("name"; "checkMerge"; "label"; "Merge Lot (whole lot, SN, bins, date codes, closing the merged lot)"); \
		New object:C1471("name"; "checkMergeBlocked"; "label"; "Merge Lot refuses a held lot and lots of another job"); \
		New object:C1471("name"; "checkSplit"; "label"; "Split Lot"))
	
	For each ($check; $checks)
		$r:=Try(This:C1470[$check.name].call(This:C1470))
		If (This:C1470.inTransaction)
			ds:C1482.cancelTransaction()
			This:C1470.inTransaction:=False:C215
		End if 
		If (Value type:C1509($r)#Is object:K8:27)
			$errors:=Last errors:C1799
			$r:=This:C1470._r(False:C215; "4D error: "+Choose:C955($errors.length=0; "unknown"; String:C10($errors[0].message)+" (code "+String:C10($errors[0].errCode)+")"); "Send this line to Claude.")
		End if 
		$r.label:=$check.label
		This:C1470.results.push($r)
	End for each 
	$report:=This:C1470.results
	
	
	// ---------------------------------------------------------------------------------
	// data
	// ---------------------------------------------------------------------------------
	
Function checkSequences()->$r : Object
	var $res : Object
	var $t : Object
	var $lines : Collection
	var $ok : Boolean
	
	// the only check that changes something: it repairs the counters (see _fix_sequences)
	$res:=_fix_sequences
	$ok:=True:C214
	$lines:=New collection:C1472
	For each ($t; $res.tables)
		Case of 
			: (Num:C11($t.after)<=Num:C11($t.highest))
				$ok:=False:C215
				$lines.push($t.table+": counter "+String:C10($t.after)+", highest number "+String:C10($t.highest)+" - new records would fail to save")
			: (Bool:C1537($t.changed))
				$lines.push($t.table+" REPAIRED: the counter was "+String:C10($t.before)+" while numbers go up to "+String:C10($t.highest)+" - every new record failed to save (duplicated key). Now "+String:C10($t.after))
			Else 
				$lines.push($t.table+": counter "+String:C10($t.after)+", highest number "+String:C10($t.highest))
		End case 
	End for each 
	$r:=This:C1470._r($ok; $lines.join(" | "); "Send this line to Claude.")
	
Function checkStaff()->$r : Object
	var $expect : Collection
	var $e : Object
	var $ident : Text
	var $res : Object
	var $problems : Collection
	
	$problems:=New collection:C1472
	$expect:=New collection:C1472(\
		New object:C1471("code"; "001730"; "yes"; New collection:C1472("rc"; "pr"); "no"; New collection:C1472("qa")); \
		New object:C1471("code"; "001492"; "yes"; New collection:C1472("cs"); "no"; New collection:C1472("rc")); \
		New object:C1471("code"; "001695"; "yes"; New collection:C1472("qa"); "no"; New collection:C1472); \
		New object:C1471("code"; "001571"; "yes"; New collection:C1472("en"); "no"; New collection:C1472))
	For each ($e; $expect)
		For each ($ident; $e.yes)
			$res:=Staff_isInUserProfile($e.code; $ident)
			If (Not:C34(Bool:C1537($res.success)))
				$problems.push($e.code+": "+String:C10($res.failureReason))
			Else 
				If (Not:C34(Bool:C1537($res.isInProfile)))
					$problems.push($e.code+" is not in profile "+$ident)
				End if 
			End if 
		End for each 
		For each ($ident; $e.no)
			$res:=Staff_isInUserProfile($e.code; $ident)
			If (Bool:C1537($res.isInProfile))
				$problems.push($e.code+" is in profile "+$ident+" (the demo expects a refusal)")
			End if 
		End for each 
	End for each 
	$r:=This:C1470._r($problems.length=0; Choose:C955($problems.length=0; "001730 rc+pr, 001492 cs, 001695 qa, 001571 en - and the refusals work"; $problems.join("; ")); "Run _demo_prepare, then restart 4D.")
	
Function checkStepFile()->$r : Object
	var $customer : 4D:C1709.Entity
	var $stepFile : 4D:C1709.Entity
	var $item : Object
	var $step : 4D:C1709.Entity
	var $template : 4D:C1709.Entity
	var $missing : Integer
	var $names : Collection
	
	$customer:=ds:C1482.Customer.query("name = :1 AND vendor = :2"; "Microchip Technology Inc"; False:C215).first()
	If ($customer=Null:C1517)
		return This:C1470._r(False:C215; "No customer named exactly \"Microchip Technology Inc\""; "Run _demo_prepare.")
	End if 
	$stepFile:=ds:C1482.StepFile.query("name = :1 AND UUID_Customer = :2"; "Microchip - Group D6"; $customer.UUID).first()
	If ($stepFile=Null:C1517)
		return This:C1470._r(False:C215; "Step file \"Microchip - Group D6\" is not linked to the customer"; "Run _import_steps_files.")
	End if 
	$missing:=0
	$names:=New collection:C1472
	This:C1470.d6Steps:=New collection:C1472
	If ($stepFile.stepsDefinition#Null:C1517) && ($stepFile.stepsDefinition.items#Null:C1517)
		For each ($item; $stepFile.stepsDefinition.items)
			// the same lookup as Planning > Add Step from Step File (panel_planning)
			$step:=Null:C1517
			If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($item.UUID_Step))))
				$step:=ds:C1482.Step.query("UUID = :1"; String:C10($item.UUID_Step)).first()
			End if 
			If ($step=Null:C1517) && (Num:C11($item.step_template)>0)
				$template:=ds:C1482.StepTemplate.query("templateNumber = :1"; Num:C11($item.step_template)).first()
				If ($template#Null:C1517)
					$step:=ds:C1482.Step.query("UUID_StepTemplate = :1"; $template.UUID).first()
				End if 
			End if 
			If ($step=Null:C1517)
				$missing+=1
			Else 
				This:C1470.d6Steps.push($step)
				$names.push(This:C1470._firstLine($step.description))
			End if 
		End for each 
	End if 
	Case of 
		: (This:C1470.d6Steps.length=0)
			$r:=This:C1470._r(False:C215; Choose:C955($missing=0; "The step file has no step"; "None of its "+String:C10($missing)+" steps could be found (by step or by template number)"); "Run _import_steps, then _import_steps_files.")
		: ($missing>0)
			$r:=This:C1470._r(False:C215; String:C10($missing)+" step(s) of the file point at no Step"; "Run _import_steps, then _import_steps_files.")
		Else 
			$r:=This:C1470._r(True:C214; String:C10(This:C1470.d6Steps.length)+" steps: "+$names.join(" / "); "")
	End case 
	
Function checkReference()->$r : Object
	var $problems : Collection
	var $name : Text
	var $noBarcode : Integer
	var $bin : 4D:C1709.Entity
	
	$problems:=New collection:C1472
	If (ds:C1482.HoldCode.query("Code = :1"; "3rd Optical").length=0)
		$problems.push("hold code \"3rd Optical\" missing")
	End if 
	For each ($name; New collection:C1472("QSR"; "OCR"; "SNA"; "NSP"))
		If (ds:C1482.StepProperty.query("name = :1"; $name).length=0)
			$problems.push("step property "+$name+" missing")
		End if 
	End for each 
	If (ds:C1482.Bin.query("binLocationPath = :1"; "@CBNT1@").length=0)
		$problems.push("no bin under CBNT1")
	End if 
	$noBarcode:=0
	For each ($bin; ds:C1482.Bin.all())
		If ($bin.moreData=Null:C1517)
			$noBarcode+=1
		Else 
			If (String:C10($bin.moreData.barcodeData)="")
				$noBarcode+=1
			End if 
		End if 
	End for each 
	If ($noBarcode>0)
		$problems.push(String:C10($noBarcode)+" bin(s) without a barcode")
	End if 
	$r:=This:C1470._r($problems.length=0; Choose:C955($problems.length=0; "3rd Optical, QSR / OCR / SNA / NSP, CBNT1 bins with barcodes"; $problems.join("; ")); "Run _demo_prepare.")
	
Function checkTravellers()->$r : Object
	var $problems : Collection
	var $name : Text
	
	$problems:=New collection:C1472
	For each ($name; New collection:C1472("Lot Traveller"; "Production Lot Traveller"))
		If (ds:C1482.dfd_Template.query("name = :1"; $name).length=0)
			$problems.push("\""+$name+"\" missing")
		End if 
	End for each 
	$r:=This:C1470._r($problems.length=0; Choose:C955($problems.length=0; "Lot Traveller and Production Lot Traveller found"; $problems.join("; ")); "Lot Traveller: run _import_lotTraveller. Production Lot Traveller: run _demo_prepare.")
	
Function checkGafFile()->$r : Object
	var $spec : 4D:C1709.Entity
	var $doc : 4D:C1709.Entity
	var $file : 4D:C1709.File
	
	$spec:=ds:C1482.Specification.query("spec = :1 AND suppress = :2"; "GAF-1022"; False:C215).first()
	If ($spec=Null:C1517)
		return This:C1470._r(False:C215; "GAF-1022 not in Document Control"; "Run _import_specControl, then _import_specFiles.")
	End if 
	$doc:=ds:C1482.sfw_Document.query("UUID_target = :1"; $spec.UUID).orderBy("stmp desc").first()
	If ($doc=Null:C1517)
		return This:C1470._r(False:C215; "GAF-1022 has no file attached"; "Run _import_specFiles (not as a dry run).")
	End if 
	$file:=cs:C1710.ga_stepDocuments.me.localFile($doc.UUID)
	Case of 
		: ($file=Null:C1517)
			$r:=This:C1470._r(False:C215; "The file of GAF-1022 is missing on the server (DocumentData)"; "Run _import_specFiles again.")
		: ($file.size=0)
			$r:=This:C1470._r(False:C215; "The file of GAF-1022 is empty"; "Run _import_specFiles again.")
		Else 
			$r:=This:C1470._r(True:C214; "GAF-1022 rev "+String:C10($spec.revision)+": "+String:C10($file.size)+" bytes, "+$file.extension; "")
	End case 
	
Function checkFormsAndSpecs()->$r : Object
	var $step : 4D:C1709.Entity
	var $lotStep : 4D:C1709.Entity
	var $rows : Collection
	var $lists : Collection
	var $lines : Collection
	var $first : Collection
	var $res : Object
	var $i : Integer
	
	If (This:C1470.d6Steps.length=0)
		return This:C1470._r(False:C215; "No step to test (see the step file check)"; "Fix the step file check first.")
	End if 
	// a throwaway lot step per D6 step, saved inside a transaction that run() cancels
	ds:C1482.startTransaction()
	This:C1470.inTransaction:=True:C214
	$lists:=New collection:C1472
	$lines:=New collection:C1472
	$i:=0
	For each ($step; This:C1470.d6Steps)
		$i+=1
		$lotStep:=ds:C1482.LotStep.new()
		$lotStep.UUID:=Generate UUID:C1066
		$lotStep.UUID_Step:=$step.UUID
		$lotStep.order:=$i
		$res:=$lotStep.save()
		$rows:=cs:C1710.ga_stepDocuments.me.listFor($lotStep)
		$lists.push($rows.extract("spec").join(","))
		$lines.push("step "+String:C10($i)+": "+Choose:C955($rows.length=0; "(none)"; $rows.extract("spec").join(" ")))
	End for each 
	$first:=Split string:C1554($lists[0]; ",")
	Case of 
		: ($lists[0]="")
			$r:=This:C1470._r(False:C215; "Step 1 (Incoming QC) lists no document. "+$lines.join(" | "); "Run _import_gafLinks with Apply.")
		: ($first.indexOf("GAF-1022")=-1)
			$r:=This:C1470._r(False:C215; "GAF-1022 is not on step 1. "+$lines.join(" | "); "Run _import_gafLinks with Apply.")
		: ($lists.distinct().length=1) && ($lists.length>1)
			$r:=This:C1470._r(False:C215; "Every step lists the same documents. "+$lines.join(" | "); "Send this line to Claude.")
		Else 
			$r:=This:C1470._r(True:C214; $lines.join(" | "); "")
	End case 
	
Function checkTools()->$r : Object
	var $template : 4D:C1709.Entity
	var $microscope : 4D:C1709.Entity
	var $offered : 4D:C1709.EntitySelection
	var $expired : 4D:C1709.EntitySelection
	var $offeredDated : 4D:C1709.EntitySelection
	var $types : Collection
	
	If (This:C1470.d6Steps.length=0)
		return This:C1470._r(False:C215; "No step to test (see the step file check)"; "Fix the step file check first.")
	End if 
	$template:=This:C1470.d6Steps[0].stepTemplate
	If ($template=Null:C1517)
		return This:C1470._r(False:C215; "Step 1 has no step template"; "Run _import_stepTemplates, then _import_steps.")
	End if 
	$types:=$template.stepTemplateToolTypes.orderBy("order asc").extract("toolType.name")
	$microscope:=ds:C1482.ToolType.query("name = :1"; "Microscope").first()
	Case of 
		: ($types.indexOf("Microscope")=-1)
			return This:C1470._r(False:C215; "Template "+String:C10($template.name)+" asks for: "+Choose:C955($types.length=0; "no tool"; $types.join(", ")); "Housekeeping > Step Templates > "+String:C10($template.name)+": add the Microscope tool type.")
		: ($microscope=Null:C1517)
			return This:C1470._r(False:C215; "No tool type named Microscope"; "Run _demo_prepare.")
	End case 
	// the same query as the tool picker (lb_tools)
	$offered:=ds:C1482.Tool.query("UUID_ToolType = :1 AND (date >= :2 OR date = :3)"; $microscope.UUID; Current date:C33; !00-00-00!)
	$expired:=ds:C1482.Tool.query("UUID_ToolType = :1 AND date < :2 AND date # :3"; $microscope.UUID; Current date:C33; !00-00-00!)
	$offeredDated:=$offered.query("date # :1"; !00-00-00!)
	Case of 
		: ($offeredDated.length=0)
			$r:=This:C1470._r(False:C215; "No microscope with a valid date would be offered ("+String:C10($offered.length)+" offered, all without a date)"; "Run _demo_toolDates.")
		: ($expired.length=0)
			$r:=This:C1470._r(False:C215; "No microscope is expired, so the filter shows nothing"; "Run _demo_toolDates.")
		Else 
			$r:=This:C1470._r(True:C214; "Template "+String:C10($template.name)+" -> Microscope. Offered: "+String:C10($offered.length)+" (e.g. "+cs:C1710.sfw_string.me.trimSpace(String:C10($offeredDated.orderBy("name asc").first().name))+" valid until "+String:C10($offeredDated.orderBy("name asc").first().date)+"), hidden: "+String:C10($expired.length)+" (e.g. "+cs:C1710.sfw_string.me.trimSpace(String:C10($expired.orderBy("name asc").first().name))+")"; "")
	End case 
	
	
	// ---------------------------------------------------------------------------------
	// logic, on throwaway records
	// ---------------------------------------------------------------------------------
	
Function checkQASignoff()->$r : Object
	var $lotStep : 4D:C1709.Entity
	var $on : Boolean
	var $off : Boolean
	
	// Planning ticks write "enabled"; the import writes "enable"
	$lotStep:=ds:C1482.LotStep.new()
	$lotStep.properties:=New object:C1471("items"; New collection:C1472(New object:C1471("name"; "QSR"; "enable"; False:C215; "enabled"; True:C214)))
	$on:=LotStep_hasQASignoff($lotStep)
	$lotStep.properties:=New object:C1471("items"; New collection:C1472(New object:C1471("name"; "QSR"; "enable"; False:C215; "enabled"; False:C215)))
	$off:=LotStep_hasQASignoff($lotStep)
	$r:=This:C1470._r($on & Not:C34($off); "QSR ticked -> sign-off required: "+Choose:C955($on; "yes"; "NO")+"; not ticked -> required: "+Choose:C955($off; "YES"; "no"); "Send this line to Claude.")
	
Function checkHistory()->$r : Object
	var $step : 4D:C1709.Entity
	var $lot : 4D:C1709.Entity
	var $lines : Collection
	var $problems : Collection
	var $text : Text
	var $word : Text
	
	$problems:=New collection:C1472
	$step:=ds:C1482.LotStep.new()
	$step.order:=1
	$step.description:="INCOMING QC INSPECTION"
	$step.dateIn:=Current date:C33
	$step.qtyIn:=80
	$step.inOperator:="001730"
	$step.approvedBy:="001695"
	$step.tools:=New object:C1471("items"; New collection:C1472(New object:C1471("order"; 1; "toolType"; "Microscope"; "toolName"; "LP-2"; "toolDate"; Current date:C33+30)))
	$step.stepInterruptions:=New object:C1471("items"; New collection:C1472(New object:C1471("start_date"; Current date:C33; "start_time"; "09:00:00"; "end_date"; Current date:C33; "end_time"; "09:15:00"; "engineer"; "001571"; "description"; "Microscope recalibration")))
	$lines:=cs:C1710.ga_events.me.stepChanges(New object:C1471; $step).extract("text")
	$text:=$lines.join(" | ")
	For each ($word; New collection:C1472("punched in"; "QA sign-off"; "tool Microscope"; "interruption"))
		If (Position:C15($word; $text)=0)
			$problems.push("no \""+$word+"\" line")
		End if 
	End for each 
	
	$lot:=ds:C1482.Lot.new()
	$lot.lotHold:=New object:C1471("items"; New collection:C1472(New object:C1471("UUID"; Generate UUID:C1066; "action"; "on"; "hold_code"; "3rd Optical"; "hold_reason"; "chipped lid"; "performedBy"; "001730")))
	$lot.snTable:=New object:C1471("items"; New collection:C1472(New object:C1471("id"; 1; "pass"; True:C214); New object:C1471("id"; 2; "pass"; True:C214)))
	$lot.snRangeMin:=1
	$lot.snRangeMax:=2
	$lines:=cs:C1710.ga_events.me.lotChanges(New object:C1471; $lot).extract("text")
	For each ($word; New collection:C1472("Hold ON - 3rd Optical"; "SN table generated"))
		If (Position:C15($word; $lines.join(" | "))=0)
			$problems.push("no \""+$word+"\" line")
		End if 
	End for each 
	$text:=$text+" | "+$lines.join(" | ")
	$r:=This:C1470._r($problems.length=0; Choose:C955($problems.length=0; Substring:C12($text; 1; 300); $problems.join("; ")+". Got: "+Substring:C12($text; 1; 300)); "Send this line to Claude.")
	
Function checkMerge()->$r : Object
	var $t : Object
	var $res : Object
	var $child : 4D:C1709.Entity
	var $step : 4D:C1709.Entity
	var $problems : Collection
	var $rows : Collection
	var $sn : Collection
	
	ds:C1482.startTransaction()
	This:C1470.inTransaction:=True:C214
	$problems:=New collection:C1472
	$t:=This:C1470._testLots()
	
	$rows:=cs:C1710.LotMergeService.me.candidates($t.mother)
	If ($rows.query("UUID = :1 AND allowed = :2"; $t.child.UUID; True:C214).length=0)
		$problems.push("the sublot is not offered as an allowed candidate ("+$rows.extract("message").join("; ")+")")
	End if 
	
	$res:=cs:C1710.LotMergeService.me.executeMerge($t.mother; $t.child.UUID)
	If (Not:C34(Bool:C1537($res.success)))
		return This:C1470._r(False:C215; "Merge refused: "+String:C10($res.message); "Send this line to Claude.")
	End if 
	$res:=$t.mother.save()  // what the panel Save does
	
	If ($t.mother.ourCount#5)
		$problems.push("count "+String:C10($t.mother.ourCount)+" instead of 5")
	End if 
	If (String:C10($t.mother.dateCode)#"2440,2441")
		$problems.push("date codes \""+String:C10($t.mother.dateCode)+"\" instead of 2440,2441")
	End if 
	$sn:=$t.mother.snTable.items.query("split_out = :1"; True:C214)
	If ($sn.length>0)
		$problems.push("SN "+$sn.extract("id").join(",")+" still split out")
	End if 
	$step:=ds:C1482.LotStep.query("UUID_Lot = :1 AND order = :2"; $t.mother.UUID; 2).first()
	If ($step.qtyIn#5)
		$problems.push("current step qty in "+String:C10($step.qtyIn)+" instead of 5")
	End if 
	If (Num:C11($step.bins.items.query("num = :1"; 1).first().quantity)#5)
		$problems.push("bin 1 holds "+String:C10($step.bins.items.query("num = :1"; 1).first().quantity)+" instead of 5")
	End if 
	If ($step.snTable.items.query("id = :1"; 5).length=0)
		$problems.push("SN 5 not back on the current step")
	End if 
	$child:=ds:C1482.Lot.get($t.child.UUID)
	If ($child.ourCount#0) || ($child.location#"merged") || ($child.dateOut#Current date:C33)
		$problems.push("merged lot not closed (count "+String:C10($child.ourCount)+", location "+String:C10($child.location)+", date out "+String:C10($child.dateOut)+")")
	End if 
	If (Position:C15("Acquired by lot#"; String:C10($child.comment))=0)
		$problems.push("merged lot has no \"Acquired by\" comment")
	End if 
	$r:=This:C1470._r($problems.length=0; Choose:C955($problems.length=0; "count 3+2=5, date codes 2440,2441, SN 4-5 back, bins and qty in summed, merged lot closed"; $problems.join("; ")); "Send this line to Claude.")
	
Function checkMergeBlocked()->$r : Object
	var $t : Object
	var $check : Object
	var $other : 4D:C1709.Entity
	var $job : 4D:C1709.Entity
	var $problems : Collection
	var $res : Object
	
	ds:C1482.startTransaction()
	This:C1470.inTransaction:=True:C214
	$problems:=New collection:C1472
	$t:=This:C1470._testLots()
	
	$t.child.onHold:=True:C214
	$res:=$t.child.save()
	$check:=cs:C1710.LotMergeService.me.checkMerge($t.mother; $t.child)
	If ($check.allowed)
		$problems.push("a held lot was allowed")
	End if 
	
	$job:=ds:C1482.Job.new()
	$job.UUID:=Generate UUID:C1066
	$res:=$job.save()
	$other:=ds:C1482.Lot.new()
	$other.UUID:=Generate UUID:C1066
	$other.UUID_Job:=$job.UUID
	$other.lotNumber:="DEMOCHECK-OTHER"
	$other.dateIn:=Current date:C33
	$other.ourCount:=10
	$res:=$other.save()
	If (cs:C1710.LotMergeService.me.candidates($t.mother).query("UUID = :1"; $other.UUID).length>0)
		$problems.push("a lot of another job was offered")
	End if 
	$r:=This:C1470._r($problems.length=0; Choose:C955($problems.length=0; "held lot: \""+String:C10($check.message)+"\"; other job: not listed"; $problems.join("; ")); "Send this line to Claude.")
	
Function checkSplit()->$r : Object
	var $t : Object
	var $gate : Object
	var $res : Object
	var $step : 4D:C1709.Entity
	var $problems : Collection
	
	ds:C1482.startTransaction()
	This:C1470.inTransaction:=True:C214
	$problems:=New collection:C1472
	$t:=This:C1470._testLots()
	
	$gate:=cs:C1710.LotSplitService.me.canSplitAtCurrentStep($t.mother; New object:C1471("inModification"; True:C214))
	If (Not:C34($gate.allowed))
		return This:C1470._r(False:C215; "Split refused: "+String:C10($gate.message); "Send this line to Claude.")
	End if 
	$res:=cs:C1710.LotSplitService.me.executeSplit($t.mother; New object:C1471("quantity"; 1; "selectedSnIds"; New collection:C1472(1)))
	If (Not:C34(Bool:C1537($res.success)))
		return This:C1470._r(False:C215; "Split failed: "+String:C10($res.message); "Send this line to Claude.")
	End if 
	$step:=ds:C1482.LotStep.query("UUID_Lot = :1 AND order = :2"; $t.mother.UUID; 2).first()
	If ($step.qtyIn#2)
		$problems.push("mother step qty in "+String:C10($step.qtyIn)+" instead of 2")
	End if 
	If ($t.mother.ourCount#2)
		$problems.push("mother count "+String:C10($t.mother.ourCount)+" instead of 2")
	End if 
	If ($res.child.ourCount#1)
		$problems.push("sublot count "+String:C10($res.child.ourCount)+" instead of 1")
	End if 
	If (ds:C1482.LotStep.query("UUID_Lot = :1"; $res.child.UUID).length=0)
		$problems.push("sublot has no steps")
	End if 
	$r:=This:C1470._r($problems.length=0; Choose:C955($problems.length=0; "1 unit (SN 1) moved to a sublot with its steps; mother count and step qty reduced"; $problems.join("; ")); "Send this line to Claude.")
	
	
	// ---------------------------------------------------------------------------------
	// helpers
	// ---------------------------------------------------------------------------------
	
	// A job with a mother lot (SN 1-3 active, 4-5 split out) and its sublot (SN 4-5), each with
	// step 1 punched out and step 2 current, with bins. Call inside a transaction.
Function _testLots()->$t : Object
	var $job : 4D:C1709.Entity
	var $res : Object
	
	$job:=ds:C1482.Job.new()
	$job.UUID:=Generate UUID:C1066
	$res:=$job.save()
	$t:=New object:C1471("job"; $job)
	$t.mother:=This:C1470._testLot($job; Null:C1517; 3; "2440"; New collection:C1472(1; 2; 3); New collection:C1472(4; 5))
	$t.child:=This:C1470._testLot($job; $t.mother; 2; "2441"; New collection:C1472(4; 5); New collection:C1472)
	
Function _testLot($job : 4D:C1709.Entity; $parent : 4D:C1709.Entity; $count : Integer; $dateCode : Text; $active : Collection; $splitOut : Collection)->$lot : 4D:C1709.Entity
	var $items : Collection
	var $id : Integer
	var $order : Integer
	var $step : 4D:C1709.Entity
	var $res : Object
	
	$items:=New collection:C1472
	For each ($id; $active)
		$items.push(New object:C1471("id"; $id; "serial_number"; "SN"+String:C10($id); "pass"; True:C214; "split_out"; False:C215))
	End for each 
	For each ($id; $splitOut)
		$items.push(New object:C1471("id"; $id; "serial_number"; "SN"+String:C10($id); "pass"; True:C214; "split_out"; True:C214))
	End for each 
	
	$lot:=ds:C1482.Lot.new()
	$lot.UUID:=Generate UUID:C1066
	$lot.UUID_Job:=$job.UUID
	$lot.lotNumber:="DEMOCHECK"
	$lot.subSequence:=($parent=Null:C1517) ? 0 : 1
	$lot.UUID_LotParent:=($parent=Null:C1517) ? "" : $parent.UUID
	$lot.dateIn:=Current date:C33
	$lot.ourCount:=$count
	$lot.device:="DEMO-DEVICE"
	$lot.dateCode:=$dateCode
	$lot.serialization:=True:C214
	$lot.snTable:=New object:C1471("items"; $items.orderBy("id asc"))
	$res:=$lot.save()
	
	For ($order; 1; 2)
		$step:=ds:C1482.LotStep.new()
		$step.UUID:=Generate UUID:C1066
		$step.UUID_Lot:=$lot.UUID
		$step.order:=$order
		$step.description:="DEMO CHECK STEP "+String:C10($order)
		// SNA: a serial-number step (ga_serialization), so merged units come back on it
		$step.properties:=New object:C1471("items"; New collection:C1472(New object:C1471("name"; "SNA"; "enabled"; True:C214)))
		$step.qtyIn:=$count
		$step.dateIn:=Current date:C33
		If ($order=1)
			$step.qtyOut:=$count
			$step.dateOut:=Current date:C33
		End if 
		$step.bins:=New object:C1471("items"; New collection:C1472(\
			New object:C1471("num"; 1; "definition"; "Pass"; "type"; ""; "quantity"; Choose:C955($order=2; $count; 0)); \
			New object:C1471("num"; 2; "definition"; "Fail"; "type"; ""; "quantity"; 0)))
		$step.snTable:=New object:C1471("items"; $items.query("split_out = :1"; False:C215).copy())
		$res:=$step.save()
	End for 
	
Function _r($ok : Boolean; $detail : Text; $fix : Text)->$r : Object
	$r:=New object:C1471("ok"; $ok; "detail"; $detail; "fix"; Choose:C955($ok; ""; $fix))
	
Function _firstLine($text : Text)->$line : Text
	$line:=Split string:C1554(Replace string:C233($text; "\n"; "\r"); "\r").first() || ""
