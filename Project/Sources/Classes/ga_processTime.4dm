// ga_processTime
// The standard processing time of a production step, and the planned hours it gives a lot step.
// - The time is set on the Operation Process (StepProcess.standardHours, StepProcess.secondsPerUnit)
//   and can be overridden on a Step Template (Step.standardHours, Step.secondsPerUnit): when either
//   step value is > 0 the step's pair is used as a whole, else the process's (0 = inherit).
// - planned hours = standard hours (fixed, per lot) + quantity x seconds per unit / 3600.
//   The legacy app had no working calendar and computed test time the same way (qty x seconds
//   / 3600, subr_planned_test_time); its test-specific extras (final test +0.5 h, wafer sort,
//   sample size, rescreen quantity) are left out on purpose.
// - A step file row's planned_hours, when > 0, stays the winner: panel_planning applies this
//   only when the row has none.
// Plain functions: callable from panels, services and _fix_ methods (no sfw callbacks involved).
singleton Class constructor

Function standardFor($step : 4D:C1709.Entity)->$standard : Object
	// $step: a Step (library step template). Returns {hours; secondsPerUnit; source}, source
	// "step" (its own override), "process" (its Operation Process) or "none".
	var $process : 4D:C1709.Entity

	$standard:=New object:C1471("hours"; 0; "secondsPerUnit"; 0; "source"; "none")
	If ($step=Null:C1517)
		return
	End if
	If (Num:C11($step.standardHours)>0) || (Num:C11($step.secondsPerUnit)>0)
		$standard.hours:=This:C1470._notNegative($step.standardHours)
		$standard.secondsPerUnit:=This:C1470._notNegative($step.secondsPerUnit)
		$standard.source:="step"
		return
	End if
	$process:=This:C1470.processFor($step)
	If ($process#Null:C1517) && ((Num:C11($process.standardHours)>0) || (Num:C11($process.secondsPerUnit)>0))
		$standard.hours:=This:C1470._notNegative($process.standardHours)
		$standard.secondsPerUnit:=This:C1470._notNegative($process.secondsPerUnit)
		$standard.source:="process"
	End if

Function processFor($step : 4D:C1709.Entity)->$process : 4D:C1709.Entity
	// The Operation Process of a Step, found as panel_step.drawPup_process shows it: by its link,
	// queried rather than through the relation (on a step being edited the link may just have
	// changed), else by the process name the step keeps in moreData (processName, or Process for
	// the steps created by _import_steps).
	var $name : Text
	
	If ($step=Null:C1517)
		return Null:C1517
	End if
	If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($step.UUID_StepProcess)))
		$process:=ds:C1482.StepProcess.query("UUID = :1"; $step.UUID_StepProcess).first()
		If ($process#Null:C1517)
			return
		End if
	End if
	If ($step.moreData#Null:C1517)
		$name:=String:C10($step.moreData.processName)
		If ($name="")
			$name:=String:C10($step.moreData.Process)
		End if
		If ($name#"")
			$process:=ds:C1482.StepProcess.query("name = :1"; $name).first()
		End if
	End if

Function hoursFrom($standard : Object; $qty : Real)->$hours : Real
	// planned hours of a standard (from standardFor) for a quantity, rounded to 0.01 h
	If ($standard=Null:C1517)
		return 0
	End if
	$hours:=Round:C94(Num:C11($standard.hours)+(This:C1470._notNegative($qty)*Num:C11($standard.secondsPerUnit)/3600); 2)

Function plannedHoursFor($step : 4D:C1709.Entity; $qty : Real)->$hours : Real
	// planned hours of one lot of $qty units at this Step; 0 when no standard is set
	$hours:=This:C1470.hoursFrom(This:C1470.standardFor($step); $qty)

Function lotQty($lot : 4D:C1709.Entity)->$qty : Integer
	// the quantity the time per unit applies to: our count, else the customer's count
	If ($lot=Null:C1517)
		return 0
	End if
	$qty:=($lot.ourCount>0) ? $lot.ourCount : $lot.customerCount

Function describe($standard : Object)->$text : Text
	// "2.00 h + 3.00 s / unit", "2.00 h", "none"
	Case of
		: ($standard=Null:C1517) || ((Num:C11($standard.hours)=0) && (Num:C11($standard.secondsPerUnit)=0))
			$text:="none"
		: (Num:C11($standard.secondsPerUnit)=0)
			$text:=String:C10($standard.hours; "###,##0.00")+" h"
		Else
			$text:=String:C10($standard.hours; "###,##0.00")+" h + "+String:C10($standard.secondsPerUnit; "###,##0.00")+" s / unit"
	End case

Function remainingHoursFor($lot : 4D:C1709.Entity)->$result : Object
	// What is left to do on a lot, for its projected completion: the steps not punched out yet
	// (from the current step, LotSplitService.resolveCurrentStep rule), in traveller order.
	// Each counts its plannedHours, else the standard of its library step for the lot quantity.
	// The current step counts in full, even when started (actualHours is set at punch out).
	// Returns {hours; currentStep; steps: [{lotStep; hours; source}]; withoutTime: count}, source
	// "planned", "step", "process" or "none".
	var $ls : 4D:C1709.Entity
	var $standard : Object
	var $qty : Integer
	var $h : Real

	$result:=New object:C1471("hours"; 0; "currentStep"; Null:C1517; "steps"; New collection:C1472; "withoutTime"; 0)
	If ($lot=Null:C1517)
		return
	End if
	$qty:=This:C1470.lotQty($lot)
	For each ($ls; ds:C1482.LotStep.query("UUID_Lot = :1 AND qtyOut = 0 AND dateOut = :2"; $lot.UUID; !00-00-00!).orderBy("order asc"))
		If ($result.currentStep=Null:C1517)
			$result.currentStep:=$ls
		End if
		If ($ls.plannedHours>0)
			$h:=$ls.plannedHours
			$standard:=New object:C1471("source"; "planned")
		Else
			$standard:=This:C1470.standardFor($ls.step)
			$h:=This:C1470.hoursFrom($standard; $qty)
		End if
		If ($h=0)
			$result.withoutTime+=1
		End if
		$result.hours+=$h
		$result.steps.push(New object:C1471("lotStep"; $ls; "hours"; $h; "source"; $standard.source))
	End for each
	$result.hours:=Round:C94($result.hours; 2)

Function projectedCompletion($lot : 4D:C1709.Entity; $nowDate : Date; $nowTime : Time)->$result : Object
	// The estimated completion of a lot, 24/7 as the legacy app (no working calendar): the
	// remaining hours of its traveller (remainingHoursFor) added to now. When the current step is
	// punched in, it ends at its punch-in + its hours (now if that is already past), then the
	// next steps follow. $nowDate / $nowTime: optional, now by default (the demo check passes
	// a fixed moment).
	// Returns {completed; date; time; hoursLeft; hoursTotal; withoutTime; stepsLeft; due; late;
	// daysLate}: due = the re-commit date, else the commit date; late when the estimate is after it.
	var $remaining : Object
	var $current : 4D:C1709.Entity
	var $ls : 4D:C1709.Entity
	var $now; $end; $currentHours : Real
	var $date; $due : Date
	
	If (Count parameters:C259<2)
		$nowDate:=Current date:C33
		$nowTime:=Current time:C178
	End if
	$result:=New object:C1471("completed"; False:C215; "date"; !00-00-00!; "time"; ?00:00:00?; "hoursLeft"; 0; "hoursTotal"; 0; "withoutTime"; 0; "stepsLeft"; 0; "due"; !00-00-00!; "late"; False:C215; "daysLate"; 0)
	If ($lot=Null:C1517)
		return
	End if
	
	// the whole traveller: plannedHours, else the standard for the lot quantity
	For each ($ls; ds:C1482.LotStep.query("UUID_Lot = :1"; $lot.UUID))
		$result.hoursTotal+=($ls.plannedHours>0) ? $ls.plannedHours : This:C1470.plannedHoursFor($ls.step; This:C1470.lotQty($lot))
	End for each
	$result.hoursTotal:=Round:C94($result.hoursTotal; 2)
	
	$remaining:=This:C1470.remainingHoursFor($lot)
	$result.withoutTime:=$remaining.withoutTime
	$result.stepsLeft:=$remaining.steps.length
	$current:=$remaining.currentStep
	If ($current=Null:C1517)
		$result.completed:=True:C214
		return
	End if
	
	$now:=This:C1470._seconds($nowDate; $nowTime)
	$end:=$now+($remaining.hours*3600)
	If ($current.dateIn#!00-00-00!)
		// started: the current step runs from its punch-in, never ends before now
		$currentHours:=$remaining.steps[0].hours
		$end:=This:C1470._seconds($current.dateIn; $current.timeIn)+($currentHours*3600)
		If ($end<$now)
			$end:=$now
		End if
		$end:=$end+(($remaining.hours-$currentHours)*3600)
	End if
	$result.hoursLeft:=Round:C94(($end-$now)/3600; 2)
	// dates are worked out in Date variables: inside an object 4D may keep a date as text (the
	// "dates inside objects" setting) and a time as seconds, so readers use Date() / Time()
	$date:=!2000-01-01!+Int:C8($end/86400)
	$result.date:=$date
	$result.time:=Time:C179($end-(Int:C8($end/86400)*86400))
	
	$due:=($lot.reCommit#!00-00-00!) ? $lot.reCommit : $lot.commit
	$result.due:=$due
	If ($due#!00-00-00!) && ($date>$due)
		$result.late:=True:C214
		$result.daysLate:=$date-$due
	End if
	
Function _seconds($date : Date; $time : Time)->$seconds : Real
	// a moment as seconds since 1 Jan 2000, to add hours across days
	$seconds:=(($date-!2000-01-01!)*86400)+($time+0)
	
Function _notNegative($value : Variant)->$num : Real
	$num:=Num:C11($value)
	If ($num<0)
		$num:=0
	End if
