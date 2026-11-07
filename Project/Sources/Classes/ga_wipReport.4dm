// ga_wipReport
// The WIP tracking report (Planning > list action "WIP report to Excel", _ga_exportWipReport): the
// lots with work under way, their current step and projected completion, by lot, by Operation
// Process and by area. build() returns plain data (no form, no sfw callback): the Excel export
// (ga_wipExcel) and _diag_wipReport share it.
// - Lots: dateOut empty and not merged (JobEntity.liveLots), at least one step punched in and a
//   step still open (the current step: first step with qtyOut = 0 and no dateOut, the
//   LotSplitService.resolveCurrentStep rule). Lots not started yet or with every step out are
//   only counted.
// - Times come from ga_processTime, 24/7: projectedCompletion once per lot, and the same rule
//   step by step for the projected start / end of each step left.
// - Groups follow the workflow: the mean position of each process / area in the travellers of the
//   lots listed (StepProcess and StepArea have no sequence field). The ones not met there come
//   after, by name, with 0 lots.
singleton Class constructor
	This:C1470.noProcess:="(no process)"
	This:C1470.noArea:="(no area)"
	This:C1470._processByStep:=New object:C1471

Function activeLots()->$lots : cs:C1710.LotSelection
	// not shipped, not merged into another lot
	$lots:=ds:C1482.Lot.query("dateOut = :1 AND location # :2"; !00-00-00!; "merged")

Function newOptions()->$options : Object
	// the data of the WIP_reportOptions dialog: the customers and lot types of the active lots
	var $lots : cs:C1710.LotSelection
	var $values : Collection

	$lots:=This:C1470.activeLots()
	$options:=New object:C1471("onHoldOnly"; False:C215; "lateOnly"; False:C215)
	$values:=$lots.job.customer.distinct("name")
	$values.unshift("All customers")
	$options.customers:=New object:C1471("values"; $values; "index"; 0)
	$values:=$lots.query("process # :1"; "").distinct("process")
	$values.unshift("All lot types")
	$options.lotTypes:=New object:C1471("values"; $values; "index"; 0)

Function askOptions()->$options : Object
	// the filters, from the WIP_reportOptions dialog; Null when cancelled. Returns {customer;
	// lotType ("" = all); onHoldOnly; lateOnly}
	var $form : Object
	var $ref : Integer

	$form:=This:C1470.newOptions()
	$ref:=Open form window:C675("WIP_reportOptions"; Movable form dialog box:K39:8; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40("WIP_reportOptions"; $form)
	CLOSE WINDOW:C154($ref)
	If (OK=1)
		$options:=New object:C1471("customer"; ""; "lotType"; ""; "onHoldOnly"; Bool:C1537($form.onHoldOnly); "lateOnly"; Bool:C1537($form.lateOnly))
		If ($form.customers.index>0)
			$options.customer:=$form.customers.values[$form.customers.index]
		End if
		If ($form.lotTypes.index>0)
			$options.lotType:=$form.lotTypes.values[$form.lotTypes.index]
		End if
	End if

Function build($options : Object; $nowDate : Date; $nowTime : Time)->$report : Object
	// The whole report at a moment (now by default; _diag_wipReport may pass a fixed one).
	// $options: from askOptions, Null = every active lot. Returns {date; time; options; lots
	// [lotRow]; processes [group]; areas [group]; hoursLeft; late; onHold; withoutTime;
	// notStarted; allStepsOut}
	var $lots : cs:C1710.LotSelection
	var $lot : cs:C1710.LotEntity
	var $row; $byProcess; $byArea : Object
	var $names : Collection

	If (Count parameters:C259<2)
		$nowDate:=Current date:C33
		$nowTime:=Current time:C178
	End if
	If ($options=Null:C1517)
		$options:=New object:C1471("customer"; ""; "lotType"; ""; "onHoldOnly"; False:C215; "lateOnly"; False:C215)
	End if
	This:C1470._processByStep:=New object:C1471  // a process renamed since the last run
	$report:=New object:C1471("date"; $nowDate; "time"; $nowTime; "options"; $options; "lots"; New collection:C1472; \
		"hoursLeft"; 0; "late"; 0; "onHold"; 0; "withoutTime"; 0; "notStarted"; 0; "allStepsOut"; 0)

	$lots:=This:C1470.activeLots()
	If (String:C10($options.customer)#"")
		$lots:=$lots.query("job.customer.name = :1"; $options.customer)
	End if
	If (String:C10($options.lotType)#"")
		$lots:=$lots.query("process = :1"; $options.lotType)
	End if
	If (Bool:C1537($options.onHoldOnly))
		$lots:=$lots.query("onHold = :1"; True:C214)
	End if

	$byProcess:=New object:C1471
	$byArea:=New object:C1471
	For each ($lot; $lots.orderBy("number asc, subSequence asc"))
		If ($lot.lotSteps.query("dateIn # :1"; !00-00-00!).length=0)
			$report.notStarted+=1
			continue
		End if
		$row:=This:C1470.lotRow($lot; $nowDate; $nowTime)
		If ($row=Null:C1517)
			$report.allStepsOut+=1
			continue
		End if
		If (Bool:C1537($options.lateOnly)) && (Not:C34($row.late))
			continue
		End if
		$report.lots.push($row)
		$report.hoursLeft+=$row.hoursLeft
		$report.late+=Num:C11($row.late)
		$report.onHold+=Num:C11($row.onHold)
		$report.withoutTime+=Num:C11($row.withoutTime>0)
		This:C1470._addPositions($lot; $byProcess; $byArea)
	End for each
	$report.hoursLeft:=Round:C94($report.hoursLeft; 2)

	$names:=ds:C1482.StepProcess.all().distinct("name")
	$report.processes:=This:C1470._groups($names; $byProcess; $report.lots; "process")
	$names:=ds:C1482.StepArea.all().distinct("name")
	$report.areas:=This:C1470._groups($names; $byArea; $report.lots; "area")

Function lotRow($lot : cs:C1710.LotEntity; $nowDate : Date; $nowTime : Time)->$row : Object
	// One lot: where it is, what is left and when it should end. Null when every step is out.
	// steps: the steps left in traveller order, each with its hours, time source and projected
	// start / end. Dates are read back with Date() / Time() (an object may keep a date as text).
	var $pc; $remaining; $item : Object
	var $current; $ls : cs:C1710.LotStepEntity
	var $count; $i : Integer
	var $now; $start; $end : Real

	$pc:=cs:C1710.ga_processTime.me.projectedCompletion($lot; $nowDate; $nowTime)
	If ($pc.completed)
		return Null:C1517
	End if
	$remaining:=cs:C1710.ga_processTime.me.remainingHoursFor($lot)
	$current:=$remaining.currentStep
	$count:=$lot.lotSteps.length
	$row:=New object:C1471(\
		"lotNumber"; $lot.displayNumber; \
		"customer"; String:C10($lot.job.customer.name); \
		"device"; String:C10($lot.device); \
		"lotType"; String:C10($lot.process); \
		"priority"; $lot.priority; \
		"qty"; cs:C1710.ga_processTime.me.lotQty($lot); \
		"onHold"; $lot.onHold; \
		"step"; String:C10($current.order)+" of "+String:C10($count); \
		"description"; String:C10($current.description); \
		"process"; This:C1470.processName($current); \
		"area"; This:C1470.areaName($current); \
		"punchedIn"; $current.dateIn#!00-00-00!; \
		"hoursHere"; $remaining.steps[0].hours; \
		"hoursLeft"; $pc.hoursLeft; \
		"hoursTotal"; $pc.hoursTotal; \
		"withoutTime"; $pc.withoutTime; \
		"stepsLeft"; $pc.stepsLeft; \
		"completionDate"; Date:C102($pc.date); \
		"completionTime"; Time:C179($pc.time); \
		"commit"; $lot.commit; \
		"reCommit"; $lot.reCommit; \
		"due"; Date:C102($pc.due); \
		"late"; $pc.late; \
		"daysLate"; $pc.daysLate; \
		"steps"; New collection:C1472)
	$row.currentStep:=$row.step+" : "+$row.description  // as LotEntity.locationLabel

	// the projectedCompletion rule, step by step: the current step runs from its punch-in (never
	// ending before now), each next step starts when the one before ends
	$now:=This:C1470._seconds($nowDate; $nowTime)
	$end:=$now
	$i:=0
	For each ($item; $remaining.steps)
		$ls:=$item.lotStep
		If ($i=0) && ($ls.dateIn#!00-00-00!)
			$start:=This:C1470._seconds($ls.dateIn; $ls.timeIn)
			$end:=$start+($item.hours*3600)
			If ($end<$now)
				$end:=$now
			End if
		Else
			$start:=$end
			$end:=$start+($item.hours*3600)
		End if
		$row.steps.push(New object:C1471(\
			"step"; String:C10($ls.order)+" of "+String:C10($count); \
			"description"; String:C10($ls.description); \
			"process"; This:C1470.processName($ls); \
			"area"; This:C1470.areaName($ls); \
			"status"; ($i>0) ? "Waiting" : (($ls.dateIn#!00-00-00!) ? "In progress" : "Next, not punched in"); \
			"hours"; $item.hours; \
			"source"; String:C10($item.source); \
			"startDate"; This:C1470._date($start); \
			"startTime"; This:C1470._time($start); \
			"endDate"; This:C1470._date($end); \
			"endTime"; This:C1470._time($end)))
		$i+=1
	End for each

Function processName($ls : cs:C1710.LotStepEntity)->$name : Text
	// the Operation Process of a lot step (its library step's, ga_processTime.processFor), cached
	// per library step for the run
	var $key : Text
	var $process : 4D:C1709.Entity

	$key:=String:C10($ls.UUID_Step)
	If (This:C1470._processByStep[$key]=Null:C1517)
		$process:=cs:C1710.ga_processTime.me.processFor($ls.step)
		This:C1470._processByStep[$key]:=($process#Null:C1517) ? String:C10($process.name) : This:C1470.noProcess
		If (This:C1470._processByStep[$key]="")
			This:C1470._processByStep[$key]:=This:C1470.noProcess
		End if
	End if
	$name:=This:C1470._processByStep[$key]

Function areaName($ls : cs:C1710.LotStepEntity)->$name : Text
	// the area kept on the lot step, else its library step's area
	$name:=String:C10($ls.area)
	If ($name="") && ($ls.step#Null:C1517) && ($ls.step.stepArea#Null:C1517)
		$name:=String:C10($ls.step.stepArea.name)
	End if
	If ($name="")
		$name:=This:C1470.noArea
	End if

Function _addPositions($lot : cs:C1710.LotEntity; $byProcess : Object; $byArea : Object)
	// each step of the traveller adds its relative position (1/N .. 1) to its process and area
	var $steps : cs:C1710.LotStepSelection
	var $ls : cs:C1710.LotStepEntity
	var $i : Integer

	$steps:=$lot.lotSteps.orderBy("order asc")
	For each ($ls; $steps)
		$i+=1
		This:C1470._addPosition($byProcess; This:C1470.processName($ls); $i/$steps.length)
		This:C1470._addPosition($byArea; This:C1470.areaName($ls); $i/$steps.length)
	End for each

Function _addPosition($positions : Object; $name : Text; $position : Real)
	If ($positions[$name]=Null:C1517)
		$positions[$name]:=New object:C1471("sum"; 0; "count"; 0)
	End if
	$positions[$name].sum+=$position
	$positions[$name].count+=1

Function _groups($names : Collection; $positions : Object; $lots : Collection; $key : Text)->$groups : Collection
	// One group per name (every process / area, and the ones only met in the travellers), in
	// workflow order, with the lots whose current step is there and their totals
	var $name : Text
	var $group : Object
	var $here : Collection

	$names:=$names.copy()
	For each ($name; $positions)
		If ($names.indexOf($name)<0)
			$names.push($name)
		End if
	End for each
	$groups:=New collection:C1472
	For each ($name; $names)
		$here:=$lots.filter(Formula:C1597($1.result:=($1.value[$2]=$3)); $key; $name)
		$group:=New object:C1471("name"; $name; "lots"; $here; "lotCount"; $here.length; \
			"hoursHere"; Round:C94($here.sum("hoursHere"); 2); "hoursLeft"; Round:C94($here.sum("hoursLeft"); 2); \
			"late"; $here.query("late = :1"; True:C214).length; "onHold"; $here.query("onHold = :1"; True:C214).length; \
			"position"; 9)  // not met in the travellers: after the others
		If ($positions[$name]#Null:C1517)
			$group.position:=$positions[$name].sum/$positions[$name].count
		End if
		$groups.push($group)
	End for each
	$groups:=$groups.orderBy("position asc, name asc")

Function _seconds($date : Date; $time : Time)->$seconds : Real
	// a moment as seconds since 1 Jan 2000 (as ga_processTime), to add hours across days
	$seconds:=(($date-!2000-01-01!)*86400)+($time+0)

Function _date($seconds : Real)->$date : Date
	$date:=!2000-01-01!+Int:C8($seconds/86400)

Function _time($seconds : Real)->$time : Time
	$time:=Time:C179($seconds-(Int:C8($seconds/86400)*86400))
