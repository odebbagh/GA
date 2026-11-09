//%attributes = {}
// _demo_wipTestData
// Test data only, so Planning > "WIP report to Excel" (_ga_exportWipReport) has something to show
// right away. Asks first. Then:
// 1. Standard times: every Operation Process with none (standardHours and secondsPerUnit at 0)
//    gets a demo one from its name (Burn In 48 h, Temp Cycle 24 h, Electrical Test 0.5 h + 6 s /
//    unit...; 2 h + 1 s / unit otherwise). Processes with a time already keep it.
// 2. Travellers: every active lot (dateOut empty, not merged) without steps gets 8 steps from the
//    step library: Incoming QC, Electrical Test, Temp Cycle, Burn In, Electrical Test, PIND,
//    Marking, Outgoing QC (the first library step of each process, by description).
// 3. Progress: every active lot whose steps were never punched in or out gets a state, in turn:
//    not started (counted, not listed), 0 to 2 steps punched out, the current step punched in
//    3 h ago or waiting. Lots with real punches are left as they are.
// 4. Lot fields left empty: quantity 500, priority 1-3, commit date from 3 days ago to 30 days
//    ahead (so some lots are late), a recommit on every 4th lot, currentOrNextArea.
// Records are saved with ORDA (no panel callbacks); new lot steps and the lots changed carry
// moreData.wipDemo = True. Close the lots open in Planning first (a lot open in Modify is locked:
// it is skipped and listed). Safe to run again: lots with steps or punches are not touched twice.
// What was done is shown and written to Project/imports/wip_test_data.txt.

var $lines; $flow; $done; $locked; $standards : Collection
var $rule; $md; $res : Object
var $process; $step; $lot; $ls : 4D:C1709.Entity
var $lots; $steps : 4D:C1709.EntitySelection
var $name : Text
var $i; $n; $k; $out; $qty : Integer
var $now; $cursor; $h : Real
var $punchedIn : Boolean

If (Not:C34(cs:C1710.sfw_dialog.me.confirm("Add WIP test data (standard times, travellers, punches, commit dates) to the active lots?\rTest databases only. Close the lots open in Planning first."; "Apply"; "Cancel")))
	return
End if

$lines:=New collection:C1472("WIP test data - "+String:C10(Current date:C33)+" "+String:C10(Current time:C178; HH MM:K7:2))
$locked:=New collection:C1472

// ---------------------------------------------------------------- 1. standard times
// first keyword found in the lower-case process name wins
$standards:=New collection:C1472(\
New object:C1471("keyword"; "burn in"; "hours"; 48; "spu"; 0); \
New object:C1471("keyword"; "temp cycle"; "hours"; 24; "spu"; 0); \
New object:C1471("keyword"; "thermal shock"; "hours"; 12; "spu"; 0); \
New object:C1471("keyword"; "electrical"; "hours"; 0.5; "spu"; 6); \
New object:C1471("keyword"; "pind"; "hours"; 0.5; "spu"; 3); \
New object:C1471("keyword"; "marking"; "hours"; 0.5; "spu"; 1); \
New object:C1471("keyword"; "optical"; "hours"; 1; "spu"; 2); \
New object:C1471("keyword"; "leak"; "hours"; 2; "spu"; 0); \
New object:C1471("keyword"; "qc"; "hours"; 1; "spu"; 0); \
New object:C1471("keyword"; ""; "hours"; 2; "spu"; 1))
$lines.push("")
$lines.push("1. STANDARD TIMES SET")
$n:=0
For each ($process; ds:C1482.StepProcess.query("(standardHours = 0 OR standardHours = null) AND (secondsPerUnit = 0 OR secondsPerUnit = null)").orderBy("name asc"))
	$name:=Lowercase:C14(String:C10($process.name))
	For each ($rule; $standards)
		If ($rule.keyword="") || (Position:C15($rule.keyword; $name)>0)
			break
		End if
	End for each
	$process.standardHours:=$rule.hours
	$process.secondsPerUnit:=$rule.spu
	$res:=$process.save()
	If ($res.success)
		$n+=1
		$lines.push("  "+$process.name+": "+cs:C1710.ga_processTime.me.describe(New object:C1471("hours"; $rule.hours; "secondsPerUnit"; $rule.spu)))
	Else
		$lines.push("  "+$process.name+": not saved ("+String:C10($res.statusText)+")")
	End if
End for each
$lines.push("  "+String:C10($n)+" process(es) set")

// ---------------------------------------------------------------- 2. travellers
$flow:=New collection:C1472
For each ($name; New collection:C1472("Incoming QC"; "Electrical Test"; "Temp Cycle"; "Burn In"; "Electrical Test"; "PIND"; "Marking"; "Outgoing QC"))
	$process:=ds:C1482.StepProcess.query("name = :1"; $name).first()
	If ($process#Null:C1517)
		$step:=ds:C1482.Step.query("UUID_StepProcess = :1"; $process.UUID).orderBy("description asc").first()
		If ($step#Null:C1517)
			$flow.push($step)
		End if
	End if
End for each
$lines.push("")
$lines.push("2. TRAVELLERS ADDED ("+String:C10($flow.length)+" library steps: "+$flow.extract("description").join(", ")+")")

$lots:=ds:C1482.Lot.query("dateOut = :1 AND location # :2"; !00-00-00!; "merged").orderBy("number asc, subSequence asc")
For each ($lot; $lots)
	If ($lot.lotSteps.length>0) || ($flow.length=0)
		continue
	End if
	$k:=0
	For each ($step; $flow)
		$k+=1
		$ls:=ds:C1482.LotStep.new()
		$ls.UUID_Lot:=$lot.UUID
		$ls.UUID_Step:=$step.UUID
		$ls.order:=$k
		$ls.description:=$step.description
		$ls.alert:=$step.alert
		$ls.area:=$step.areas
		$ls.moreData:=New object:C1471("wipDemo"; True:C214)
		$ls.save()
	End for each
	$lines.push("  lot "+$lot.displayNumber+": "+String:C10($flow.length)+" steps")
End for each

// ---------------------------------------------------------------- 3 and 4. progress and lot fields
$lines.push("")
$lines.push("3. LOTS PREPARED")
$now:=cs:C1710.ga_wipReport.me._seconds(Current date:C33; Current time:C178)
$i:=0
For each ($lot; $lots)
	$steps:=$lot.lotSteps.orderBy("order asc")
	If ($steps.length=0) || ($steps.query("dateIn # :1 OR dateOut # :1 OR qtyIn # 0 OR qtyOut # 0"; !00-00-00!).length>0)
		continue  // no traveller, or real punches: left as it is
	End if

	// lot fields left empty
	If ($lot.ourCount=0) && ($lot.customerCount=0)
		$lot.ourCount:=500
	End if
	If ($lot.priority=0)
		$lot.priority:=($i%3)+1
	End if
	If ($lot.commit=!00-00-00!)
		$lot.commit:=Current date:C33+New collection:C1472(-3; 2; 7; 15; 30)[$i%5]
		If ($i%4=3)
			$lot.reCommit:=$lot.commit+5
		End if
	End if
	$qty:=cs:C1710.ga_processTime.me.lotQty($lot)

	// progress: every 5th lot not started; else 0 to 2 steps out, the current one in or waiting
	$out:=Choose:C955($i%5=0; -1; $i%3)
	If ($out>=$steps.length)  // a short traveller: its last step is the current one
		$out:=$steps.length-1
	End if 
	$punchedIn:=($i%2=1)
	$done:=New collection:C1472
	If ($out>=0)
		$cursor:=$now-(Choose:C955($punchedIn; 3; 1)*3600)
		If ($punchedIn)
			$ls:=$steps[$out]
			$ls.dateIn:=cs:C1710.ga_wipReport.me._date($cursor)
			$ls.timeIn:=cs:C1710.ga_wipReport.me._time($cursor)
			$ls.qtyIn:=$qty
			$done.push($ls)
		End if
		For ($k; $out-1; 0; -1)  // the steps out, back in time from the current one
			$ls:=$steps[$k]
			$h:=cs:C1710.ga_processTime.me.plannedHoursFor($ls.step; $qty)
			$h:=Choose:C955($h<1; 1; $h)
			$cursor:=$cursor-1800  // half an hour between two steps
			$ls.dateOut:=cs:C1710.ga_wipReport.me._date($cursor)
			$ls.timeOut:=cs:C1710.ga_wipReport.me._time($cursor)
			$cursor:=$cursor-($h*3600)
			$ls.dateIn:=cs:C1710.ga_wipReport.me._date($cursor)
			$ls.timeIn:=cs:C1710.ga_wipReport.me._time($cursor)
			$ls.qtyIn:=$qty
			$ls.qtyOut:=$qty
			$ls.actualHours:=$h
			$done.push($ls)
		End for
		$lot.currentOrNextArea:=String:C10($steps[$out].area)
	End if

	$md:=($lot.moreData=Null:C1517) ? New object:C1471 : OB Copy:C1225($lot.moreData)
	$md.wipDemo:=True:C214
	$lot.moreData:=$md
	$res:=$lot.save()
	If (Not:C34($res.success))
		$locked.push($lot.displayNumber)
		continue
	End if
	For each ($ls; $done)
		$ls.save()
	End for each
	$lines.push("  lot "+$lot.displayNumber+": "+Choose:C955($out<0; "not started"; String:C10($out)+" step(s) out, step "+String:C10($out+1)+Choose:C955($punchedIn; " punched in 3 h ago"; " waiting"))+", qty "+String:C10($qty)+", priority "+String:C10($lot.priority)+", commit "+String:C10($lot.commit)+Choose:C955($lot.reCommit#!00-00-00!; ", recommit "+String:C10($lot.reCommit); ""))
	$i+=1
End for each
If ($i=0)
	$lines.push("  none: every active lot has real punches or no traveller")
End if
If ($locked.length>0)
	$lines.push("  NOT SAVED (open in Planning?): "+$locked.join(", "))
End if

Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("wip_test_data.txt").setText($lines.join("\r\n"))
cs:C1710.sfw_dialog.me.info(String:C10($i)+" lot(s) prepared"+Choose:C955($locked.length>0; ", "+String:C10($locked.length)+" locked (open in Planning?)"; "")+".\rDetails in Project/imports/wip_test_data.txt.\rNext: Planning > WIP report to Excel.")
