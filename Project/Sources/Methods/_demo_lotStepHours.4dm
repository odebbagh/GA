//%attributes = {}
// _demo_lotStepHours
// Test helper for the estimated completion (ga_processTime.projectedCompletion): sets the planned
// hours of one step of a lot, then shows the estimate before and after. A step already punched out
// changes only the total; a step not punched out also changes the hours left and the date.
// Asks for the lot # (41, or 41-1 for a sublot), the step # and the hours. Saves the lot step:
// close the lot in Planning first (a lot open in Modify is locked), then reopen it to see the result.

var $answer; $before; $after; $info : Object
var $lot; $ls : 4D:C1709.Entity
var $order : Integer
var $hours : Real
var $describe : 4D:C1709.Function

$describe:=Formula:C1597(Choose:C955($1.completed; "completed"; String:C10(Date:C102($1.date); Internal date short:K1:7)+" "+String:C10(Time:C179($1.time); HH MM:K7:2))+", "+String:C10($1.hoursLeft; "###,##0.00")+" h left of "+String:C10($1.hoursTotal; "###,##0.00")+" h")

$answer:=cs:C1710.sfw_dialog.me.request("Lot # (41, or 41-1 for a sublot):"; ""; "Next"; "Cancel"; "trimSpace"; "notEmpty")
If (Not:C34($answer.ok))
	return
End if
$lot:=ds:C1482.Lot.query("displayNumber = :1"; $answer.answer).first()
If ($lot=Null:C1517)
	cs:C1710.sfw_dialog.me.alert("Lot "+$answer.answer+" was not found.")
	return
End if

$answer:=cs:C1710.sfw_dialog.me.request("Step # of lot "+$lot.displayNumber+":"; "1"; "Next"; "Cancel"; "trimSpace"; "notEmpty")
If (Not:C34($answer.ok))
	return
End if
$order:=Num:C11($answer.answer)
$ls:=ds:C1482.LotStep.query("UUID_Lot = :1 AND order = :2"; $lot.UUID; $order).first()
If ($ls=Null:C1517)
	cs:C1710.sfw_dialog.me.alert("Lot "+$lot.displayNumber+" has no step "+String:C10($order)+".")
	return
End if

$answer:=cs:C1710.sfw_dialog.me.request("Planned hours for step "+String:C10($order)+" ("+$ls.description+"), now "+String:C10($ls.plannedHours)+":"; "100"; "Set"; "Cancel"; "trimSpace"; "notEmpty")
If (Not:C34($answer.ok))
	return
End if
$hours:=Num:C11($answer.answer)
If ($hours<0)
	cs:C1710.sfw_dialog.me.alert("The hours cannot be negative.")
	return
End if

$before:=cs:C1710.ga_processTime.me.projectedCompletion($lot)
$ls.plannedHours:=$hours
$info:=$ls.save()
If (Not:C34($info.success))
	cs:C1710.sfw_dialog.me.alert("The step could not be saved ("+String:C10($info.statusText)+"): close the lot in Planning and try again.")
	return
End if
$after:=cs:C1710.ga_processTime.me.projectedCompletion($lot)

cs:C1710.sfw_dialog.me.info("Lot "+$lot.displayNumber+", step "+String:C10($order)+": planned hours set to "+String:C10($hours)+\
Choose:C955(($ls.qtyOut#0) || ($ls.dateOut#!00-00-00!); " (step punched out: only the total changes)"; "")+"\r\r"+\
"Before: "+$describe.call(Null:C1517; $before)+"\r"+\
"After:  "+$describe.call(Null:C1517; $after))
