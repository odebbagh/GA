//%attributes = {}
// _diag_processTimes
// READ-ONLY. What planned / actual hours exist today, to choose the standard processing time of
// each Operation Process (StepProcess) before adding it. Four sections:
//  1. per process: library Steps, how many carry moreData.planhrs (fixed hours) / moreData.time,
//     and step file rows of those steps with planned_hours > 0
//  2. step files: rows with planned_hours > 0 vs 0, rows with time > 0, files with no rows
//  3. active WIP lots (dateOut empty, not merged, as JobEntity.liveLots): open lot steps
//     (not punched out) with plannedHours > 0 vs 0, per process and per area; lots with no
//     current step; lots with no quantity
//  4. lot steps punched out in the last 24 months with actual hours: hours per lot step and
//     seconds per unit (actualHours x 3600 / qtyIn), per process: the base for realistic defaults
// Writes Project/imports/process_times.txt. Changes nothing.

var $lines; $c; $names; $noCurrent; $done : Collection
var $byProc; $processByStep; $wipProc; $wipArea; $g; $row; $o : Object
var $fmt : 4D.Function
var $proc; $step; $sf; $lot; $ls : 4D.Entity
var $active; $open : 4D.EntitySelection
var $md : Object
var $key; $name : Text
var $v : Real
var $nbRows; $nbRowsPlan; $nbRowsTime; $nbFilesNoRows; $nbNoQty; $nbOpen; $nbOpenPlanned : Integer
var $since : Date

// "n values: min / max / avg / median", only called on a non-empty collection
$fmt:=Formula(String($1.length)+" values: min "+String($1.min(); "#####0.0##")+" / max "+String($1.max(); "#####0.0##")+" / avg "+String($1.average(); "#####0.0##")+" / median "+String($1.orderBy()[Int($1.length/2)]; "#####0.0##"))

$lines:=New collection("Process times - "+String(Current date)+" "+String(Current time); "")

// ---------------------------------------------------------------- 1. library steps per process
$byProc:=New object
For each ($proc; ds.StepProcess.all())
	$byProc[$proc.UUID]:=New object("name"; $proc.name; "steps"; 0; "plan"; New collection; "time"; New collection; "filePlan"; New collection)
End for each
$byProc.none:=New object("name"; "(no process)"; "steps"; 0; "plan"; New collection; "time"; New collection; "filePlan"; New collection)

$processByStep:=New object  // UUID_Step -> process group
For each ($step; ds.Step.all())
	$key:="none"
	If (Not(cs.sfw_string.me.isAnEmptyUUID($step.UUID_StepProcess))) && ($byProc[$step.UUID_StepProcess]#Null)
		$key:=$step.UUID_StepProcess
	End if
	$g:=$byProc[$key]
	$g.steps+=1
	$processByStep[$step.UUID]:=$g
	$md:=$step.moreData
	If ($md#Null)
		$v:=($md.planhrs#Null) ? Num($md.planhrs) : Num($md.planHrs)  // same read as panel_stepFile.stepRowFromStepEntity
		If ($v>0)
			$g.plan.push($v)
		End if
		If (Num($md.time)>0)
			$g.time.push(Num($md.time))
		End if
	End if
End for each

// ---------------------------------------------------------------- 2. step file rows (also fills filePlan per process)
$nbRows:=0
$nbRowsPlan:=0
$nbRowsTime:=0
$nbFilesNoRows:=0
$c:=New collection  // planned_hours > 0
For each ($sf; ds.StepFile.all())
	If ($sf.stepsDefinition=Null) || ($sf.stepsDefinition.items=Null) || ($sf.stepsDefinition.items.length=0)
		$nbFilesNoRows+=1
	Else
		For each ($row; $sf.stepsDefinition.items)
			$nbRows+=1
			If (Num($row.planned_hours)>0)
				$nbRowsPlan+=1
				$c.push(Num($row.planned_hours))
				$g:=$processByStep[String($row.UUID_Step)]
				If ($g#Null)
					$g.filePlan.push(Num($row.planned_hours))
				End if
			End if
			If (Num($row.time)>0)
				$nbRowsTime+=1
			End if
		End for each
	End if
End for each

$lines.push("1. LIBRARY STEPS PER OPERATION PROCESS")
$lines.push("   (planhrs = Step.moreData.planhrs, time = Step.moreData.time, file rows = step file rows of these steps with planned_hours > 0)")
$names:=New collection
For each ($key; $byProc)
	$names.push($byProc[$key])
End for each
For each ($g; $names.orderBy("name"))
	$lines.push(String($g.name)+": "+String($g.steps)+" step(s)")
	If ($g.plan.length>0)
		$lines.push("    planhrs   "+$fmt.call(Null; $g.plan))
	End if
	If ($g.time.length>0)
		$lines.push("    time      "+$fmt.call(Null; $g.time))
	End if
	If ($g.filePlan.length>0)
		$lines.push("    file rows "+$fmt.call(Null; $g.filePlan))
	End if
End for each

$lines.push("")
$lines.push("2. STEP FILES")
$lines.push("   "+String(ds.StepFile.all().length)+" step file(s), "+String($nbFilesNoRows)+" with no step rows")
$lines.push("   "+String($nbRows)+" row(s): "+String($nbRowsPlan)+" with planned_hours > 0, "+String($nbRows-$nbRowsPlan)+" with 0; "+String($nbRowsTime)+" with time > 0")
If ($c.length>0)
	$lines.push("   planned_hours "+$fmt.call(Null; $c))
End if

// ---------------------------------------------------------------- 3. active WIP lots
$active:=ds.Lot.query("dateOut = :1 AND location # :2"; !00-00-00!; "merged")
$wipProc:=New object
$wipArea:=New object
$noCurrent:=New collection
$nbNoQty:=0
$nbOpen:=0
$nbOpenPlanned:=0
For each ($lot; $active)
	If ($lot.ourCount=0)
		$nbNoQty+=1
	End if
	// open = not punched out (the current step is the first of them: LotSplitService.resolveCurrentStep)
	$open:=$lot.lotSteps.query("qtyOut = 0 AND dateOut = :1"; !00-00-00!)
	If ($open.length=0)
		$noCurrent.push(String($lot.displayNumber)+(($lot.lotSteps.length=0) ? " (no steps)" : " (all steps out)"))
	End if
	For each ($ls; $open)
		$nbOpen+=1
		$g:=$processByStep[String($ls.UUID_Step)]
		$name:=($g=Null) ? "(step not in library)" : String($g.name)
		For each ($o; New collection(New object("map"; $wipProc; "key"; $name); New object("map"; $wipArea; "key"; ($ls.area="") ? "(no area)" : $ls.area)))
			If ($o.map[$o.key]=Null)
				$o.map[$o.key]:=New object("open"; 0; "planned"; 0; "hours"; 0)
			End if
			$o.map[$o.key].open+=1
			If ($ls.plannedHours>0)
				$o.map[$o.key].planned+=1
				$o.map[$o.key].hours+=$ls.plannedHours
			End if
		End for each
		If ($ls.plannedHours>0)
			$nbOpenPlanned+=1
		End if
	End for each
End for each

$lines.push("")
$lines.push("3. ACTIVE WIP LOTS (dateOut empty, not merged)")
$lines.push("   "+String($active.length)+" lot(s), "+String($nbNoQty)+" with ourCount = 0, "+String($noCurrent.length)+" with no current step")
$lines.push("   "+String($nbOpen)+" open lot step(s): "+String($nbOpenPlanned)+" with plannedHours > 0, "+String($nbOpen-$nbOpenPlanned)+" with 0")
For each ($o; New collection(New object("title"; "per process"; "map"; $wipProc); New object("title"; "per area"; "map"; $wipArea)))
	$lines.push("   "+$o.title+" (open / with planned hours / sum of planned hours):")
	$names:=New collection
	For each ($key; $o.map)
		$names.push($key)
	End for each
	For each ($key; $names.orderBy())
		$lines.push("    "+$key+": "+String($o.map[$key].open)+" / "+String($o.map[$key].planned)+" / "+String($o.map[$key].hours; "#####0.0#"))
	End for each
End for each
If ($noCurrent.length>0)
	$lines.push("   lots with no current step (first 50):")
	For each ($name; $noCurrent.slice(0; 50))
		$lines.push("    "+$name)
	End for each
End if

// ---------------------------------------------------------------- 4. actual hours, last 24 months
$since:=Add to date(Current date; -2; 0; 0)
$done:=ds.LotStep.query("dateOut >= :1 AND actualHours > 0"; $since).toCollection("UUID_Step, actualHours, plannedHours, qtyIn")
$wipProc:=New object  // reused: process name -> {hours; secsPerUnit; planned}
For each ($row; $done)
	$g:=$processByStep[String($row.UUID_Step)]
	$name:=($g=Null) ? "(step not in library)" : String($g.name)
	If ($wipProc[$name]=Null)
		$wipProc[$name]:=New object("hours"; New collection; "secs"; New collection; "planned"; New collection)
	End if
	$wipProc[$name].hours.push($row.actualHours)
	If ($row.qtyIn>0)
		$wipProc[$name].secs.push($row.actualHours*3600/$row.qtyIn)
	End if
	If ($row.plannedHours>0)
		$wipProc[$name].planned.push($row.plannedHours)
	End if
End for each

$lines.push("")
$lines.push("4. LOT STEPS PUNCHED OUT SINCE "+String($since)+" WITH ACTUAL HOURS ("+String($done.length)+")")
$lines.push("   (hours = actual hours per lot step, s/unit = actual hours x 3600 / qtyIn, planned = their plannedHours > 0)")
$names:=New collection
For each ($key; $wipProc)
	$names.push($key)
End for each
For each ($key; $names.orderBy())
	$lines.push($key+":")
	$lines.push("    hours   "+$fmt.call(Null; $wipProc[$key].hours))
	If ($wipProc[$key].secs.length>0)
		$lines.push("    s/unit  "+$fmt.call(Null; $wipProc[$key].secs))
	End if
	If ($wipProc[$key].planned.length>0)
		$lines.push("    planned "+$fmt.call(Null; $wipProc[$key].planned))
	End if
End for each

Folder(fk database folder).folder("Project/imports").file("process_times.txt").setText($lines.join("\r\n"))
cs.sfw_dialog.me.info("Process times report written to Project/imports/process_times.txt ("+String($lines.length)+" lines).")
