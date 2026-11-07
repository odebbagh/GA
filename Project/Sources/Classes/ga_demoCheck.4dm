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
	This:C1470.step:=""
	
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
		New object:C1471("name"; "checkSplit"; "label"; "Split Lot"); \
		New object:C1471("name"; "checkQuoteRevision"; "label"; "Quote New revision: frozen copy kept when the quote and its terms change"); \
		New object:C1471("name"; "checkQuoteLines"; "label"; "Quote lines: minimum lot charge, move up / down with renumbering"); \
		New object:C1471("name"; "checkQuotePriceFloor"; "label"; "Quote line unit price below its floor, or a missing zero"); \
		New object:C1471("name"; "checkQuoteMinCharge"; "label"; "Quote line minimum lot charge from the price list, force and block modes"); \
		New object:C1471("name"; "checkDefaultAssumptions"; "label"; "New quote: only the default assumptions attached"); \
		New object:C1471("name"; "checkSalesLifecycle"; "label"; "Lead to quote: create quote, sent, PO and job on the lead, won, reopen, void, follow-ups"); \
		New object:C1471("name"; "checkSalesViews"; "label"; "Lead columns (pipeline, next follow-up, open) and the lead / quote views"); \
		New object:C1471("name"; "checkJobCosts"; "label"; "Job costs (subcon, actual, markup), roll-up and the To Ship view"); \
		New object:C1471("name"; "checkProcessTime"; "label"; "Standard processing time: process value, step override, time per unit"); \
		New object:C1471("name"; "checkProjectedCompletion"; "label"; "Estimated completion: remaining hours from now or from the punch-in, late flag"))
	
	For each ($check; $checks)
		This:C1470.step:=""  // a check may name where it is, for the error line
		$r:=Try(This:C1470[$check.name].call(This:C1470))
		If (This:C1470.inTransaction)
			ds:C1482.cancelTransaction()
			This:C1470.inTransaction:=False:C215
		End if 
		cs:C1710.ga_quoteMinCharge.me._testMode:=""  // a check that stopped on an error leaves no test mode
		If (Value type:C1509($r)#Is object:K8:27)
			$errors:=Last errors:C1799
			$r:=This:C1470._r(False:C215; "4D error"+Choose:C955(String:C10(This:C1470.step)=""; ""; " ("+This:C1470.step+")")+": "+Choose:C955($errors.length=0; "unknown"; This:C1470._errorStack($errors)); "Send this line to Claude.")
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
	This:C1470.step:=""
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
	
	
	// A quote with one line and one assumption is frozen by QuoteEntity.newRevision, then the line,
	// the Assumption record and the quote change: the revision must still hold the old values, and
	// the quote must be at the next revision level. Uses the Revision levels of the data file (two
	// test ones when there are fewer than two).
Function checkQuoteRevision()->$r : Object
	var $levels : 4D:C1709.EntitySelection
	var $level; $assumption; $line : 4D:C1709.Entity
	var $quote : cs:C1710.QuoteEntity
	var $revision : cs:C1710.QuoteRevisionEntity
	var $res : Object
	var $problems : Collection
	var $i : Integer

	ds:C1482.startTransaction()
	This:C1470.inTransaction:=True:C214
	$problems:=New collection:C1472

	This:C1470.step:="revision levels"
	$levels:=ds:C1482.Revision.all().orderBy("levelID asc")
	If ($levels.length<2)
		For ($i; 1; 2)
			$level:=ds:C1482.Revision.new()
			$level.levelID:=Num:C11(ds:C1482.Revision.all().max("levelID"))+1
			$level.code:="DC"+String:C10($i)
			$level.name:="DEMOCHECK "+String:C10($i)
			$res:=$level.save()
		End for
		$levels:=ds:C1482.Revision.all().orderBy("levelID asc")
	End if

	This:C1470.step:="test quote"
	$assumption:=ds:C1482.Assumption.new()
	$assumption.code:="DEMOCHECK"
	$assumption.value:="Original assumption text"
	$res:=$assumption.save()

	$quote:=ds:C1482.Quote.new()
	$quote.code:="DEMOCHECK"
	$quote.subject:="Demo check quote"
	$quote.UUID_Revision:=$levels[0].UUID
	$quote.assumptions:=New object:C1471("UUIDs"; New collection:C1472($assumption.UUID))
	$quote.termsConditions:=New object:C1471("UUIDs"; New collection:C1472)
	$res:=$quote.save()

	$line:=ds:C1482.QuoteLine.new()
	$line.UUID_Quote:=$quote.UUID
	$line.num:=1
	$line.description:="Electrical test"
	$line.quantity:=10
	$line.unitPrice:=5
	$res:=$line.save()

	This:C1470.step:="newRevision"
	$res:=$quote.newRevision($levels[0].UUID; $levels[1].UUID; "demo check")
	If (Not:C34(Bool:C1537($res.success)))
		return This:C1470._r(False:C215; "New revision failed: "+String:C10($res.message); "Send this line to Claude.")
	End if

	This:C1470.step:="changes after the revision"
	// later changes, which the frozen copy must not see
	$assumption.value:="Changed assumption text"
	$res:=$assumption.save()
	$line.quantity:=20
	$res:=$line.save()
	$quote.reload()
	$quote.subject:="Changed subject"
	$res:=$quote.save()

	This:C1470.step:="reading the revision"
	$revision:=ds:C1482.QuoteRevision.query("UUID_Quote = :1"; $quote.UUID).first()
	Case of
		: ($revision=Null:C1517)
			$problems.push("no QuoteRevision record")
		Else
			If ($revision.num#1)
				$problems.push("revision # "+String:C10($revision.num)+" instead of 1")
			End if
			If (String:C10($revision.snapshot.assumptions[0].value)#"Original assumption text")
				$problems.push("frozen assumption \""+String:C10($revision.snapshot.assumptions[0].value)+"\"")
			End if
			If (Num:C11($revision.snapshot.quoteLines[0].amount)#50)
				$problems.push("frozen line amount "+String:C10($revision.snapshot.quoteLines[0].amount)+" instead of 50")
			End if
			If (String:C10($revision.snapshot.quoteSubject)#"Demo check quote")
				$problems.push("frozen subject \""+String:C10($revision.snapshot.quoteSubject)+"\"")
			End if
			If (String:C10($revision.snapshot.quoteRevision)#String:C10($levels[0].name))
				$problems.push("frozen as \""+String:C10($revision.snapshot.quoteRevision)+"\" instead of \""+String:C10($levels[0].name)+"\"")
			End if
	End case
	If ($quote.UUID_Revision#$levels[1].UUID)
		$problems.push("the quote did not move to the next revision")
	End if
	$r:=This:C1470._r($problems.length=0; Choose:C955($problems.length=0; "revision "+String:C10($levels[0].name)+" kept with its line, subject and assumption text after they changed; quote moved to "+String:C10($levels[1].name); $problems.join("; ")); "Send this line to Claude.")


	// A quote with three lines: the amount is quantity x unit price, or the minimum lot charge when
	// it is higher; Move up / down swaps two lines and leaves them numbered 1..n (QuoteEntity.moveLine).
Function checkQuoteLines()->$r : Object
	var $quote : cs:C1710.QuoteEntity
	var $line : cs:C1710.QuoteLineEntity
	var $res : Object
	var $problems : Collection
	var $i : Integer
	var $order : Text

	ds:C1482.startTransaction()
	This:C1470.inTransaction:=True:C214
	$problems:=New collection:C1472

	This:C1470.step:="test quote"
	$quote:=ds:C1482.Quote.new()
	$quote.code:="DEMOCHECK"
	$quote.subject:="Demo check quote lines"
	$res:=$quote.save()
	// numbered 1, 3, 7 as after deletes or a legacy import
	For ($i; 1; 3)
		$line:=ds:C1482.QuoteLine.new()
		$line.UUID_Quote:=$quote.UUID
		$line.num:=Choose:C955($i-1; 1; 3; 7)
		$line.description:="L"+String:C10($i)
		$line.quantity:=10
		$line.unitPrice:=5
		$line.minLotCharge:=Choose:C955($i-1; 0; 200; 20)  // above, then below quantity x unit price
		$res:=$line.save()
	End for

	This:C1470.step:="amounts"
	cs:C1710.ga_quoteMinCharge.me._testMode:="force"  // whatever the QuoteMinLotChargeMode setting
	If ($quote.amountNumber#(50+200+50))
		$problems.push("quote total "+String:C10($quote.amountNumber)+" instead of 300 (50 + minimum 200 + 50)")
	End if
	cs:C1710.ga_quoteMinCharge.me._testMode:=""

	This:C1470.step:="move"
	$line:=$quote.lines.query("description = :1"; "L3").first()
	If (Not:C34($quote.moveLine($line.UUID; -1)))
		$problems.push("L3 not moved up")
	End if
	$line:=$quote.lines.query("description = :1"; "L1").first()
	If ($quote.moveLine($line.UUID; -1))
		$problems.push("the first line moved up")
	End if
	$order:=""
	For each ($line; $quote.lines.orderBy("num asc"))
		$order+=$line.description+"="+String:C10($line.num)+" "
	End for each
	If ($order#"L1=1 L3=2 L2=3 ")
		$problems.push("order after the moves \""+$order+"\" instead of \"L1=1 L3=2 L2=3\"")
	End if
	$r:=This:C1470._r($problems.length=0; Choose:C955($problems.length=0; "minimum lot charge applied only when higher; lines moved and renumbered 1..n"; $problems.join("; ")); "Send this line to Claude.")


	// ga_quoteMinCharge on lines that are never saved: force and block amounts, an imported minimum
	// kept, then (in a cancelled transaction) a price list row for a step's process filling the
	// minimum of a line built from that step. No dialog.
Function checkQuoteMinCharge()->$r : Object
	var $min : cs:C1710.ga_quoteMinCharge
	var $line : cs:C1710.QuoteLineEntity
	var $step : cs:C1710.StepEntity
	var $item : cs:C1710.PriceListItemEntity
	var $problems : Collection
	var $res : Object
	var $detail : Text

	$problems:=New collection:C1472
	$min:=cs:C1710.ga_quoteMinCharge.me
	$line:=ds:C1482.QuoteLine.new()
	$line.num:=1
	$line.quantity:=10
	$line.unitPrice:=5
	$line.minLotCharge:=200

	This:C1470.step:="modes"
	$min._testMode:="force"
	If ($line.amount#200)
		$problems.push("force: amount "+String:C10($line.amount)+" instead of 200")
	End if
	$min._testMode:="block"
	If ($line.amount#50)
		$problems.push("block: amount "+String:C10($line.amount)+" instead of 50 (10 x 5)")
	End if
	If (Not:C34($min.isUnder($line)))
		$problems.push("10 x 5 under 200 not flagged")
	End if
	$min._testMode:=""

	This:C1470.step:="legacy kept"
	If ($min.sourceOf($line)#"legacy")
		$problems.push("a minimum without a source is \""+$min.sourceOf($line)+"\" instead of \"legacy\"")
	End if
	If ($min.applyDefault($line)) || ($line.minLotCharge#200)
		$problems.push("an imported minimum was replaced by "+String:C10($line.minLotCharge))
	End if

	This:C1470.step:="price list"
	$detail:="force raises the amount, block flags it; an imported minimum is kept"
	$step:=ds:C1482.Step.query("UUID_StepProcess # :1"; "0"*32).first()
	If ($step=Null:C1517) || ($step.stepProcess=Null:C1517)
		$detail+="; price list not tested: no step has a process"
	Else
		ds:C1482.startTransaction()
		This:C1470.inTransaction:=True:C214
		$item:=ds:C1482.PriceListItem.new()
		$item.code:="DEMOCHECK"
		$item.description:="Demo check minimum lot charge"
		$item.UUID_StepProcess:=$step.UUID_StepProcess
		$item.UUID_Customer:="0"*32
		$item.minLotCharge:=987654
		$item.active:=True:C214
		$res:=$item.save()
		$line:=ds:C1482.QuoteLine.new()
		$line.num:=1
		$line.quantity:=10
		$line.unitPrice:=5
		$line.moreData:=New object:C1471("build"; New object:C1471("steps"; New collection:C1472(New object:C1471("UUID"; $step.UUID))))
		If (Not:C34($min.applyDefault($line))) || ($line.minLotCharge#987654) || ($min.sourceOf($line)#"priceList")
			$problems.push("built line: minimum "+String:C10($line.minLotCharge)+" ("+$min.sourceOf($line)+") instead of 987654 from the price list")
		End if
		If ($line.moreData.build=Null:C1517)
			$problems.push("applyDefault dropped moreData.build")
		End if
		$detail+="; a line built from "+$step.stepProcess.name+" gets the price list minimum"
	End if
	$r:=This:C1470._r($problems.length=0; Choose:C955($problems.length=0; $detail; $problems.join("; ")); "Send this line to Claude.")


	// ga_quotePriceFloor.check on a line that is never saved: a test floor of 100, then no floor
	// (the typo check). No dialog, nothing written.
Function checkQuotePriceFloor()->$r : Object
	var $floor : cs:C1710.ga_quotePriceFloor
	var $line : cs:C1710.QuoteLineEntity
	var $problems : Collection
	var $test : Object
	var $detail : Text

	$problems:=New collection:C1472
	$floor:=cs:C1710.ga_quotePriceFloor.me
	$line:=ds:C1482.QuoteLine.new()
	$line.num:=1
	$line.quantity:=10

	This:C1470.step:="floor 100"
	$floor._testFloor:=100
	For each ($test; New collection:C1472(\
		New object:C1471("price"; 0; "kind"; ""); \
		New object:C1471("price"; 120; "kind"; ""); \
		New object:C1471("price"; 100; "kind"; ""); \
		New object:C1471("price"; 90; "kind"; "floor")))
		$line.unitPrice:=$test.price
		If ($floor.check($line; 0).kind#$test.kind)
			$problems.push(String:C10($test.price)+" with a floor of 100: \""+$floor.check($line; 0).kind+"\" instead of \""+$test.kind+"\"")
		End if
	End for each
	$line.moreData:=New object:C1471("priceFloor"; New object:C1471("price"; 90; "floor"; 100))
	If (Not:C34($floor.isKept($line; $floor.check($line; 0))))
		$problems.push("90 kept below 100 not recognised as kept")
	End if
	$line.clearPriceFloorNote()
	If ($line.moreData.priceFloor#Null:C1517)
		$problems.push("clearPriceFloorNote left the note")
	End if
	$floor._testFloor:=0

	This:C1470.step:="no floor"
	$detail:="below the floor flagged, kept price recognised"
	If ($floor.floorFor($line).value>0)
		$detail+="; typo check not tested: the QuotePriceFloorDemo setting gives every line a floor"
	Else
		For each ($test; New collection:C1472(\
			New object:C1471("price"; 10; "previous"; 100; "kind"; "typo"); \
			New object:C1471("price"; 30; "previous"; 100; "kind"; ""); \
			New object:C1471("price"; 10; "previous"; 0; "kind"; "")))
			$line.unitPrice:=$test.price
			If ($floor.check($line; $test.previous).kind#$test.kind)
				$problems.push(String:C10($test.price)+" after "+String:C10($test.previous)+": \""+$floor.check($line; $test.previous).kind+"\" instead of \""+$test.kind+"\"")
			End if
		End for each
		$detail+=", a price under a fifth of the previous one flagged"
	End if
	$r:=This:C1470._r($problems.length=0; Choose:C955($problems.length=0; $detail; $problems.join("; ")); "Send this line to Claude.")


	// Assumption.isDefault: some are marked, and a new quote gets exactly those (QuoteEntity.addAssumptions,
	// run by initDefaults). The quote is not saved, so nothing is written.
Function checkDefaultAssumptions()->$r : Object
	var $quote : cs:C1710.QuoteEntity
	var $defaults : Collection
	var $nbAll : Integer
	var $same : Boolean
	var $uuid : Text

	$nbAll:=ds:C1482.Assumption.all().length
	$defaults:=ds:C1482.Assumption.query("isDefault = :1"; True:C214).distinct("UUID")
	If ($defaults.length=0)
		$r:=This:C1470._r(False:C215; "no default assumption among "+String:C10($nbAll)+": a new quote gets none"; "Run _fix_assumptionDefaults (Apply), or tick Default in Administration > Assumptions.")
		return
	End if

	This:C1470.step:="new quote"
	$quote:=ds:C1482.Quote.new()
	$quote.addAssumptions()
	$same:=($quote.assumptions.UUIDs.length=$defaults.length)
	For each ($uuid; $quote.assumptions.UUIDs)
		$same:=$same && ($defaults.indexOf($uuid)#-1)
	End for each
	If ($same)
		$r:=This:C1470._r(True:C214; String:C10($defaults.length)+" of "+String:C10($nbAll)+" assumptions are default, and a new quote gets those"; "")
	Else
		$r:=This:C1470._r(False:C215; "a new quote gets "+String:C10($quote.assumptions.UUIDs.length)+" assumptions instead of the "+String:C10($defaults.length)+" default ones"; "Send this line to Claude.")
	End if


	// The sales lifecycle (ga_sales, ga_followUps, QuoteEntity "Lifecycle") on a throwaway customer,
	// lead and quote: a secondary contact made main; "Create quote" (customer, contacts, 30 days'
	// validity, the lead linked); a quote follow-up listed on the lead; "Mark as sent" (UCR, lead at
	// "Quote Sent"); a PO and its job filling the lead; the PO closing the quote as won
	// (ga_quoteStatus), a second PO changing nothing, the message when the quote loses its PO;
	// "Close as won" (RO, lead won with the reason, follow-up cancelled); "Reopen"; "Void".
	// Inside a cancelled transaction (the lifecycle
	// history lines go with it; a new event type may stay, as at first real use)
Function checkSalesLifecycle()->$r : Object
	var $customer; $contact1; $contact2; $po; $po2; $job : 4D:C1709.Entity
	var $lead : cs:C1710.LeadEntity
	var $quote : cs:C1710.QuoteEntity
	var $followUp : cs:C1710.InteractionEntity
	var $stage : cs:C1710.LeadStageEntity
	var $res; $statusChange : Object
	var $problems : Collection

	ds:C1482.startTransaction()
	This:C1470.inTransaction:=True:C214
	$problems:=New collection:C1472

	This:C1470.step:="test customer and lead"
	$customer:=ds:C1482.Customer.new()
	$customer.name:="DEMOCHECK customer"
	$res:=$customer.save()
	$contact1:=ds:C1482.Contact.new()
	$contact1.UUID_Company:=$customer.UUID
	$contact1.lastName:="DEMOCHECK one"
	$res:=$contact1.save()
	$contact2:=ds:C1482.Contact.new()
	$contact2.UUID_Company:=$customer.UUID
	$contact2.lastName:="DEMOCHECK two"
	$res:=$contact2.save()
	$lead:=ds:C1482.Lead.new()
	$lead.leadCode:="DEMOCHECK"
	$lead.UUID_Customer:=$customer.UUID
	$stage:=ds:C1482.LeadStage.query("code == :1"; "NE").first()
	$lead.currentStageID:=($stage=Null:C1517) ? 0 : $stage.stageID
	$lead.moreData:=New object:C1471("mainContact"; New object:C1471("UUID"; $contact1.UUID); "secondaryContacts"; New collection:C1472($contact2.UUID))
	$res:=$lead.save()

	This:C1470.step:="make main contact"
	If (Not:C34(cs:C1710.ga_sales.me.makeMainContact($lead; $contact2.UUID)))
		$problems.push("Make main contact refused")
	End if
	$res:=$lead.save()
	If (String:C10($lead.moreData.mainContact.UUID)#$contact2.UUID) || ($lead.moreData.secondaryContacts.join(",")#$contact1.UUID)
		$problems.push("contacts not swapped")
	End if

	This:C1470.step:="create quote"
	$res:=cs:C1710.ga_sales.me.createQuoteFromLead($lead)
	If (Not:C34(Bool:C1537($res.success)))
		return This:C1470._r(False:C215; "Create quote failed: "+String:C10($res.message); "Send this line to Claude.")
	End if
	$quote:=$res.quote
	$lead.reload()
	If ($lead.UUID_Quote#$quote.UUID)
		$problems.push("the lead is not linked to its new quote")
	End if
	If ($quote.UUID_Customer#$customer.UUID) || (String:C10($quote.moreData.mainContact.UUID)#$contact2.UUID)
		$problems.push("the quote did not get the lead's customer and main contact")
	End if
	If ($quote.validUntil#Add to date:C393(Current date:C33; 0; 0; $quote.defaultValidityDays()))
		$problems.push("valid until "+String:C10($quote.validUntil)+" instead of today + "+String:C10($quote.defaultValidityDays())+" days")
	End if
	If (String:C10($quote.status.code)#"A")
		$problems.push("new quote status "+String:C10($quote.status.code)+" instead of A")
	End if

	This:C1470.step:="quote follow-up"
	$followUp:=cs:C1710.ga_followUps.me._new(cs:C1710.ga_followUps.me.context($quote); "SCHEDULED")
	$followUp.stmpCreation:=cs:C1710.sfw_stmp.me.now()
	$followUp.stmpFollowUp:=cs:C1710.sfw_stmp.me.build(Current date:C33+7)
	$res:=$followUp.save()
	If (cs:C1710.ga_followUps.me.list($lead).query("UUID = :1"; $followUp.UUID).length#1)
		$problems.push("the quote's follow-up is not listed on its lead")
	End if

	This:C1470.step:="mark as sent"
	$res:=$quote.markAsSent()
	$lead.reload()
	$stage:=cs:C1710.ga_sales.me.stageFor("sent")
	Case of
		: (Not:C34(Bool:C1537($res.success)))
			$problems.push("Mark as sent: "+String:C10($res.message))
		: (String:C10($quote.status.code)#"UCR") || ($quote.stmpSent=0)
			$problems.push("sent quote status "+String:C10($quote.status.code)+", sent stamp "+String:C10($quote.stmpSent))
		: ($stage#Null:C1517) && ($lead.currentStageID#$stage.stageID)
			$problems.push("the lead did not move to Quote Sent")
	End case

	This:C1470.step:="PO and job"
	$po:=ds:C1482.PurchaseOrder.new()
	$po.UUID_Customer:=$customer.UUID
	$po.UUID_Quote:=$quote.UUID
	$po.poNum:="DEMOCHECK"
	$res:=$po.save()
	$job:=ds:C1482.Job.new()
	$job.UUID:=Generate UUID:C1066
	$job.UUID_PurchaseOrder:=$po.UUID
	$res:=$job.save()
	cs:C1710.ga_sales.me.syncLeadsFromPurchaseOrder($po)
	$lead.reload()
	If ($lead.UUID_PurchaseOrder#$po.UUID) || ($lead.UUID_Job#$job.UUID)
		$problems.push("the PO did not fill the lead's PO and job")
	End if

	This:C1470.step:="PO closes the quote"
	$statusChange:=cs:C1710.ga_quoteStatus.me.onPurchaseOrderSaved($po; "0"*32)
	$quote.reload()
	$lead.reload()
	$followUp.reload()
	$stage:=cs:C1710.ga_sales.me.stageFor("won")
	Case of
		: (Not:C34($statusChange.changed))
			$problems.push("the PO did not close the quote: "+$statusChange.messages.join(" "))
		: ($quote.outcome#"won") || ($quote.stmpClosed=0)
			$problems.push("quote status "+String:C10($quote.status.code)+" after its PO instead of RO")
		: ($stage#Null:C1517) && ($lead.currentStageID#$stage.stageID)
			$problems.push("the PO did not close the lead as won")
		: (cs:C1710.ga_followUps.me.isScheduled($followUp))
			$problems.push("the PO did not cancel the pending follow-up")
	End case
	$po2:=ds:C1482.PurchaseOrder.new()
	$po2.UUID_Customer:=$customer.UUID
	$po2.UUID_Quote:=$quote.UUID
	$po2.poNum:="DEMOCHECK2"
	$res:=$po2.save()
	$statusChange:=cs:C1710.ga_quoteStatus.me.onPurchaseOrderSaved($po2; "0"*32)
	If ($statusChange.changed) || ($statusChange.messages.length>0)
		$problems.push("a second PO on the won quote did something: "+$statusChange.messages.join(" "))
	End if
	If (cs:C1710.ga_quoteStatus.me.onPurchaseOrderRemoved($quote.UUID; $po.UUID).messages.length>0)
		$problems.push("PO removed: a message although another PO is left")
	End if
	$res:=$po2.drop()
	If (cs:C1710.ga_quoteStatus.me.onPurchaseOrderRemoved($quote.UUID; $po.UUID).messages.length=0)
		$problems.push("PO removed: no message for a won quote left without a PO")
	End if
	$res:=$quote.reopen()  // for the manual "Close as won" below
	If (Not:C34(Bool:C1537($res.success)))
		$problems.push("Reopen after the PO: "+String:C10($res.message))
	End if

	This:C1470.step:="close as won"
	$res:=$quote.close(True:C214; "DEMOCHECK reason")
	$lead.reload()
	$followUp.reload()
	$stage:=cs:C1710.ga_sales.me.stageFor("won")
	Case of
		: (Not:C34(Bool:C1537($res.success)))
			$problems.push("Close as won: "+String:C10($res.message))
		: ($quote.outcome#"won") || ($quote.stmpClosed=0)
			$problems.push("won quote status "+String:C10($quote.status.code))
		: ($stage#Null:C1517) && ($lead.currentStageID#$stage.stageID)
			$problems.push("the lead was not closed as won")
		: ($lead.reasonWL#"DEMOCHECK reason")
			$problems.push("the lead's W/L reason is \""+$lead.reasonWL+"\"")
		: (cs:C1710.ga_followUps.me.isScheduled($followUp))
			$problems.push("the pending follow-up was not cancelled")
	End case

	This:C1470.step:="reopen and void"
	$res:=$quote.reopen()
	If (Not:C34(Bool:C1537($res.success))) || ($quote.isClosed)
		$problems.push("Reopen: "+String:C10($res.message))
	End if
	$res:=$quote.setVoided(True:C214; "demo check")
	If (Not:C34(Bool:C1537($res.success))) || ($quote.isOpen)
		$problems.push("Void: "+String:C10($res.message))
	End if

	$r:=This:C1470._r($problems.length=0; Choose:C955($problems.length=0; "contact made main, quote created from the lead, sent, PO and job on the lead, PO closed the quote as won, won with the reason, reopened, voided"; $problems.join("; ")); "Send this line to Claude.")

	// A lead with two follow-ups (one overdue) and two quotes (one expiring, one not): the list
	// columns of Leads and the saved views of Leads and Quotes (Lead.4dm, Quote.4dm)
Function checkSalesViews()->$r : Object
	var $customer : 4D:C1709.Entity
	var $lead : cs:C1710.LeadEntity
	var $quote; $later : cs:C1710.QuoteEntity
	var $followUp : cs:C1710.InteractionEntity
	var $stage; $won : cs:C1710.LeadStageEntity
	var $status : cs:C1710.QuoteStatusEntity
	var $res : Object
	var $problems : Collection
	var $staffUUID : Text

	ds:C1482.startTransaction()
	This:C1470.inTransaction:=True:C214
	$problems:=New collection:C1472

	This:C1470.step:="test lead and follow-ups"
	$customer:=ds:C1482.Customer.new()
	$customer.name:="DEMOCHECK customer"
	$res:=$customer.save()
	$lead:=ds:C1482.Lead.new()
	$lead.leadCode:="DEMOCHECK"
	$lead.UUID_Customer:=$customer.UUID
	$stage:=ds:C1482.LeadStage.query("code == :1"; "NE").first()
	$lead.currentStageID:=($stage=Null:C1517) ? 0 : $stage.stageID
	$lead.amount:=10000
	$lead.probabilityPC:=40
	$staffUUID:=String:C10(cs:C1710.sfw_userManager.me.info.UUID_Staff)
	If ($staffUUID#"")
		$lead.UUID_Staff:=$staffUUID
	End if
	$res:=$lead.save()
	$followUp:=ds:C1482.Interaction.new()
	$followUp.UUID_Lead:=$lead.UUID
	$followUp.UUID_Type:=cs:C1710.ga_followUps.me.typeUUID("SCHEDULED")
	$followUp.stmpCreation:=cs:C1710.sfw_stmp.me.now()
	$followUp.stmpFollowUp:=cs:C1710.sfw_stmp.me.build(Current date:C33-2)
	$res:=$followUp.save()
	$followUp:=ds:C1482.Interaction.new()
	$followUp.UUID_Lead:=$lead.UUID
	$followUp.UUID_Type:=cs:C1710.ga_followUps.me.typeUUID("SCHEDULED")
	$followUp.stmpCreation:=cs:C1710.sfw_stmp.me.now()
	$followUp.stmpFollowUp:=cs:C1710.sfw_stmp.me.build(Current date:C33+5)
	$res:=$followUp.save()
	$followUp:=ds:C1482.Interaction.new()  // done: not open
	$followUp.UUID_Lead:=$lead.UUID
	$followUp.UUID_Type:=cs:C1710.ga_followUps.me.typeUUID("COMPLETED")
	$followUp.stmpCreation:=cs:C1710.sfw_stmp.me.now()
	$followUp.stmpFollowUp:=cs:C1710.sfw_stmp.me.build(Current date:C33-10)
	$res:=$followUp.save()

	This:C1470.step:="lead columns"
	If ($lead.pipelineValue#4000)
		$problems.push("pipeline "+String:C10($lead.pipelineValue)+" instead of 4000")
	End if
	If ($lead.openInteractions#2)
		$problems.push(String:C10($lead.openInteractions)+" open follow-ups instead of 2")
	End if
	If ($lead.nextFollowUp#(Current date:C33-2))
		$problems.push("next follow-up "+String:C10($lead.nextFollowUp)+" instead of "+String:C10(Current date:C33-2))
	End if

	This:C1470.step:="lead views"
	If (ds:C1482.Lead.openLeads().query("UUID = :1"; $lead.UUID).length#1)
		$problems.push("a New lead is not in Open leads")
	End if
	Case of
		: ($staffUUID="")
			// a user without a staff record: My leads is empty for them, nothing to test
		: (ds:C1482.Lead.myLeads().query("UUID = :1"; $lead.UUID).length#1)
			$problems.push("the user's own lead is not in My leads")
	End case
	$won:=cs:C1710.ga_sales.me.stageFor("won")
	If ($won#Null:C1517)
		$lead.currentStageID:=$won.stageID
		$res:=$lead.save()
		If (ds:C1482.Lead.openLeads().query("UUID = :1"; $lead.UUID).length#0)
			$problems.push("a Won lead is still in Open leads")
		End if
	End if

	This:C1470.step:="test quotes"
	$status:=ds:C1482.QuoteStatus.query("code == :1"; "A").first()
	If ($status=Null:C1517)
		return This:C1470._r(False:C215; "no quote status A (Active)"; "Run __import_quote_param, then this check again.")
	End if
	$quote:=ds:C1482.Quote.new()
	$quote.code:="DEMOCHECK1"
	$quote.UUID_Customer:=$customer.UUID
	$quote.UUID_Status:=$status.UUID
	$quote.stmpCreation:=cs:C1710.sfw_stmp.me.now()
	$quote.stmpValidUntil:=cs:C1710.sfw_stmp.me.build(Current date:C33+10)
	$res:=$quote.save()
	$later:=ds:C1482.Quote.new()
	$later.code:="DEMOCHECK2"
	$later.UUID_Customer:=$customer.UUID
	$later.UUID_Status:=$status.UUID
	$later.stmpCreation:=cs:C1710.sfw_stmp.me.now()
	$later.stmpValidUntil:=cs:C1710.sfw_stmp.me.build(Current date:C33+60)
	$res:=$later.save()

	This:C1470.step:="quote views"
	If (ds:C1482.Quote.pendingQuotes().query("UUID in :1"; New collection:C1472($quote.UUID; $later.UUID)).length#2)
		$problems.push("Active quotes missing from Pending quotes")
	End if
	If (ds:C1482.Quote.expiringQuotes().query("UUID = :1"; $quote.UUID).length#1)
		$problems.push("a quote valid 10 more days is not in Expiring quotes")
	End if
	If (ds:C1482.Quote.expiringQuotes().query("UUID = :1"; $later.UUID).length#0)
		$problems.push("a quote valid 60 more days is in Expiring quotes")
	End if
	If (ds:C1482.Quote.quotesToFollowUp().query("UUID = :1"; $quote.UUID).length#0)
		$problems.push("a quote without a due follow-up is in Quotes to follow up")
	End if
	$followUp:=ds:C1482.Interaction.new()  // due today, on the quote
	$followUp.UUID_Quote:=$quote.UUID
	$followUp.UUID_Type:=cs:C1710.ga_followUps.me.typeUUID("SCHEDULED")
	$followUp.stmpCreation:=cs:C1710.sfw_stmp.me.now()
	$followUp.stmpFollowUp:=cs:C1710.sfw_stmp.me.build(Current date:C33)
	$res:=$followUp.save()
	If (ds:C1482.Quote.quotesToFollowUp().query("UUID = :1"; $quote.UUID).length#1)
		$problems.push("a quote with a follow-up due today is not in Quotes to follow up")
	End if
	$lead.UUID_Quote:=$later.UUID  // the lead's overdue follow-up counts for its quote
	$res:=$lead.save()
	If (ds:C1482.Quote.quotesToFollowUp().query("UUID = :1"; $later.UUID).length#1)
		$problems.push("a quote whose lead has an overdue follow-up is not in Quotes to follow up")
	End if
	$quote.voided:=True:C214
	$res:=$quote.save()
	If (ds:C1482.Quote.pendingQuotes().query("UUID = :1"; $quote.UUID).length#0)
		$problems.push("a voided quote is still in Pending quotes")
	End if

	$r:=This:C1470._r($problems.length=0; Choose:C955($problems.length=0; "pipeline, next follow-up and open count right; Open / My leads; Pending, Expiring and To follow up quotes"+Choose:C955($staffUUID=""; " (My leads not tested: this user has no staff record)"; ""); $problems.join("; ")); "Send this line to Claude.")

	// A job with two purchase lines, a pull and a put back: its cost columns (JobEntity.jobsRow),
	// the roll-up line and the To Ship view (Job.4dm)
Function checkJobCosts()->$r : Object
	var $job : cs:C1710.JobEntity
	var $buyLine : 4D:C1709.Entity
	var $pull : 4D:C1709.Entity
	var $row; $res : Object
	var $problems : Collection
	var $text : Text

	ds:C1482.startTransaction()
	This:C1470.inTransaction:=True:C214
	$problems:=New collection:C1472

	This:C1470.step:="test job"
	$job:=ds:C1482.Job.new()
	$job.UUID:=Generate UUID:C1066
	$job.jobNumber:=Num:C11(ds:C1482.Job.all().max("jobNumber"))+1000  // a number no pull uses
	$job.totalCharge:=1000
	$job.directCost:=999  // imported figures: ignored once there are lines and pulls
	$job.inventoryCost:=999
	$res:=$job.save()

	This:C1470.step:="imported costs"
	If ($job.subconCost#999) || ($job.materialCost#999)
		$problems.push("without lines or pulls the imported costs are not used")
	End if

	This:C1470.step:="purchase lines and pulls"
	$buyLine:=ds:C1482.BuyingOrderLine.new()
	$buyLine.UUID_Job:=$job.UUID
	$buyLine.lineTotal:=300
	$res:=$buyLine.save()
	$buyLine:=ds:C1482.BuyingOrderLine.new()
	$buyLine.UUID_Job:=$job.UUID
	$buyLine.lineTotal:=100
	$res:=$buyLine.save()
	$pull:=ds:C1482.InventoryPull.new()
	$pull.jobNumber:=$job.jobNumber
	$pull.type:="Pull"
	$pull.cost:=150
	$res:=$pull.save()
	$pull:=ds:C1482.InventoryPull.new()
	$pull.jobNumber:=$job.jobNumber
	$pull.type:="Put Back"
	$pull.cost:=50
	$res:=$pull.save()
	$job.reload()

	This:C1470.step:="cost columns"
	$row:=$job.jobsRow()
	Case of
		: ($row.subcon#400)
			$problems.push("subcon "+String:C10($row.subcon)+" instead of 400")
		: ($row.actual#500)
			$problems.push("actual cost "+String:C10($row.actual)+" instead of 500 (400 bought + 150 pulled - 50 put back)")
		: ($row.markup#500)
			$problems.push("markup "+String:C10($row.markup)+" instead of 500")
		: ($row.markupPCText#"100%")
			$problems.push("markup % \""+$row.markupPCText+"\" instead of 100%")
	End case

	This:C1470.step:="roll-up"
	$text:=ds:C1482.Job.rollupText(New collection:C1472($row))
	If (Position:C15("Actual cost "+_ga_usdText(500); $text)=0) || (Position:C15("(100%"; $text)=0)
		$problems.push("roll-up line \""+$text+"\"")
	End if

	This:C1470.step:="To Ship view"
	If (ds:C1482.Job.jobsToShip().query("UUID = :1"; $job.UUID).length#1)
		$problems.push("an unshipped job is not in To Ship")
	End if
	$job.shipped:=True:C214
	$res:=$job.save()
	If (ds:C1482.Job.jobsToShip().query("UUID = :1"; $job.UUID).length#0)
		$problems.push("a shipped job is still in To Ship")
	End if

	$r:=This:C1470._r($problems.length=0; Choose:C955($problems.length=0; "subcon 400, actual 500, markup 500 (100%), roll-up line, To Ship in and out"; $problems.join("; ")); "Send this line to Claude.")
	
	
	// ga_processTime on a throwaway Operation Process (2 h + 3.6 s / unit) and two steps, one
	// inheriting it and one with its own 5 h, plus a step with no process. Inside a cancelled
	// transaction.
Function checkProcessTime()->$r : Object
	var $process; $inherit; $own; $none : 4D:C1709.Entity
	var $problems : Collection
	var $std : Object
	var $h : Real

	$problems:=New collection:C1472
	ds:C1482.startTransaction()
	This:C1470.inTransaction:=True:C214

	This:C1470.step:="throwaway process and steps"
	$process:=ds:C1482.StepProcess.new()
	$process.name:="zz demo check process"
	$process.standardHours:=2
	$process.secondsPerUnit:=3.6
	$process.save()
	$inherit:=ds:C1482.Step.new()
	$inherit.description:="zz demo check step (inherits)"
	$inherit.UUID_StepProcess:=$process.UUID
	$own:=ds:C1482.Step.new()
	$own.description:="zz demo check step (own time)"
	$own.UUID_StepProcess:=$process.UUID
	$own.standardHours:=5
	$none:=ds:C1482.Step.new()
	$none.description:="zz demo check step (no process)"
	$none.UUID_StepProcess:="00"*16

	This:C1470.step:="ga_processTime"
	$std:=cs:C1710.ga_processTime.me.standardFor($inherit)
	$h:=cs:C1710.ga_processTime.me.plannedHoursFor($inherit; 1000)
	If ($std.source#"process") || ($h#3)
		$problems.push("inheriting step: "+$std.source+", "+String:C10($h)+" h for 1000 units instead of process, 3 h")
	End if
	$std:=cs:C1710.ga_processTime.me.standardFor($own)
	$h:=cs:C1710.ga_processTime.me.plannedHoursFor($own; 1000)
	If ($std.source#"step") || ($h#5)
		$problems.push("step with its own 5 h: "+$std.source+", "+String:C10($h)+" h instead of step, 5 h")
	End if
	$std:=cs:C1710.ga_processTime.me.standardFor($none)
	If ($std.source#"none") || (cs:C1710.ga_processTime.me.plannedHoursFor($none; 1000)#0)
		$problems.push("step with no process: "+$std.source+" instead of none, 0 h")
	End if

	ds:C1482.cancelTransaction()
	This:C1470.inTransaction:=False:C215
	$r:=This:C1470._r($problems.length=0; Choose:C955($problems.length=0; "process 2 h + 3.6 s / unit gives 3 h for 1000 units; a step's own 5 h wins; no process gives 0"; $problems.join("; ")); "Send this line to Claude.")


	// ga_processTime.projectedCompletion on a throwaway lot of 1000 units, at a fixed "now"
	// (5 Jan 2026 08:00), committed for 4 Jan: step 1 done, step 2 current with 4 planned hours,
	// step 3 with no planned hours on a step whose process gives 3 h. Not started: 15:00, late
	// 1 day; step 2 punched in at 06:00: 13:00. Inside a cancelled transaction.
Function checkProjectedCompletion()->$r : Object
	var $process; $step; $lot; $ls : 4D:C1709.Entity
	var $problems : Collection
	var $p : Object

	$problems:=New collection:C1472
	ds:C1482.startTransaction()
	This:C1470.inTransaction:=True:C214

	This:C1470.step:="throwaway lot"
	$process:=ds:C1482.StepProcess.new()
	$process.name:="zz demo check process"
	$process.standardHours:=2
	$process.secondsPerUnit:=3.6
	$process.save()
	$step:=ds:C1482.Step.new()
	$step.description:="zz demo check step"
	$step.UUID_StepProcess:=$process.UUID
	$step.save()
	$lot:=ds:C1482.Lot.new()
	$lot.ourCount:=1000
	$lot.commit:=!2026-01-04!
	$lot.save()
	$ls:=ds:C1482.LotStep.new()
	$ls.UUID_Lot:=$lot.UUID
	$ls.order:=1
	$ls.qtyIn:=1000
	$ls.qtyOut:=1000
	$ls.dateIn:=!2026-01-02!
	$ls.dateOut:=!2026-01-02!
	$ls.plannedHours:=1
	$ls.save()
	$ls:=ds:C1482.LotStep.new()
	$ls.UUID_Lot:=$lot.UUID
	$ls.order:=2
	$ls.plannedHours:=4
	$ls.save()
	$ls:=ds:C1482.LotStep.new()
	$ls.UUID_Lot:=$lot.UUID
	$ls.order:=3
	$ls.UUID_Step:=$step.UUID
	$ls.save()

	This:C1470.step:="not started"
	$p:=cs:C1710.ga_processTime.me.projectedCompletion($lot; !2026-01-05!; ?08:00:00?)
	If (Date:C102($p.date)#!2026-01-05!) || (Time:C179($p.time)#?15:00:00?) || ($p.hoursLeft#7) || ($p.hoursTotal#8) || (Not:C34($p.late)) || ($p.daysLate#1)
		$problems.push("not started: "+String:C10(Date:C102($p.date))+" "+String:C10(Time:C179($p.time))+", "+String:C10($p.hoursLeft)+" h left of "+String:C10($p.hoursTotal)+", late "+String:C10($p.daysLate)+" day(s) instead of 05/01/2026 15:00, 7 of 8 h, late 1 day")
	End if

	This:C1470.step:="punched in"
	$ls:=ds:C1482.LotStep.query("UUID_Lot = :1 AND order = 2"; $lot.UUID).first()
	$ls.qtyIn:=1000
	$ls.dateIn:=!2026-01-05!
	$ls.timeIn:=?06:00:00?
	$ls.save()
	$p:=cs:C1710.ga_processTime.me.projectedCompletion($lot; !2026-01-05!; ?08:00:00?)
	If (Date:C102($p.date)#!2026-01-05!) || (Time:C179($p.time)#?13:00:00?) || ($p.hoursLeft#5)
		$problems.push("punched in at 06:00: "+String:C10(Date:C102($p.date))+" "+String:C10(Time:C179($p.time))+", "+String:C10($p.hoursLeft)+" h left instead of 05/01/2026 13:00, 5 h")
	End if

	ds:C1482.cancelTransaction()
	This:C1470.inTransaction:=False:C215
	$r:=This:C1470._r($problems.length=0; Choose:C955($problems.length=0; "7 h left from 08:00 gives 15:00, 1 day after the commit; punched in at 06:00 gives 13:00"; $problems.join("; ")); "Send this line to Claude.")


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
	
	// every error of the stack, not just the last one (the first raised is usually the cause), with the
	// method and line when 4D gives them
Function _errorStack($errors : Collection)->$text : Text
	var $e : Object
	var $parts : Collection
	$parts:=New collection:C1472
	For each ($e; $errors)
		$parts.push(String:C10($e.message)+" (code "+String:C10($e.errCode)+Choose:C955(String:C10($e.method)=""; ""; ", "+String:C10($e.method)+" line "+String:C10($e.line))+")")
	End for each
	$text:=$parts.join(" | ")

Function _firstLine($text : Text)->$line : Text
	$line:=Split string:C1554(Replace string:C233($text; "\n"; "\r"); "\r").first() || ""
