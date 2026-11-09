//%attributes = {}
// _fix_stepStandardHours
// One-time load of the legacy fixed step times (Oct 2026) into Step.standardHours, the step's own
// standard processing time (ga_processTime). The legacy [StepTemplates]Step_time_in_hrs was not
// part of steps_export.json: run __ga_StepTimesAudit in the legacy app first and copy the
// step_times_audit.json it writes on the Desktop to Project/imports.
// A legacy row is matched to its Step as _import_steps created it: same template number and same
// description; else by description alone when only one Step has it. Steps that already have their
// own standard time keep it. Steps of the same process with different times stay per step: the
// report shows per process the hours found, to set the Operation Process time by hand.
// Asks first: "Report only" changes nothing and writes Project/imports/step_standard_hours_fix.txt;
// "Apply" does the same and saves. Safe to run again.

var $apply : Boolean
var $file : 4D:C1709.File
var $rows; $lines; $failed; $notFound; $ambiguous; $kept; $names : Collection
var $row; $info; $byProcess : Object
var $steps : 4D:C1709.EntitySelection
var $step : 4D:C1709.Entity
var $hours : Real
var $key : Text
var $set : Integer

$file:=Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("step_times_audit.json")
If (Not:C34($file.exists))
	cs:C1710.sfw_dialog.me.alert("Project/imports/step_times_audit.json was not found.\rRun __ga_StepTimesAudit in the legacy app and copy the file from the Desktop.\rNothing was changed.")
	return
End if
$rows:=JSON Parse:C1218($file.getText())

$apply:=cs:C1710.sfw_dialog.me.confirm("Load the legacy step times into the Step Templates' standard hours?\r\r"+\
"Report only: writes Project/imports/step_standard_hours_fix.txt and changes nothing.\r"+\
"Apply: does the same and saves the hours on the steps that have no standard time yet."; "Apply"; "Report only")

$failed:=New collection:C1472
$notFound:=New collection:C1472
$ambiguous:=New collection:C1472
$kept:=New collection:C1472
$byProcess:=New object:C1471
$set:=0
For each ($row; $rows)
	$hours:=Num:C11($row.Step_time_in_hrs)
	If ($hours<=0)
		continue
	End if
	$key:=String:C10($row.Process)
	If ($byProcess[$key]=Null:C1517)
		$byProcess[$key]:=New collection:C1472
	End if
	$byProcess[$key].push($hours)

	$steps:=ds:C1482.Step.query("stepTemplate.templateNumber = :1 AND description = :2"; Num:C11($row.Template); String:C10($row.Description))
	If ($steps.length=0)
		$steps:=ds:C1482.Step.query("description = :1"; String:C10($row.Description))
	End if
	$key:="template "+String:C10($row.Template)+", "+String:C10($row.Process)+": "+Substring:C12(Replace string:C233(String:C10($row.Description); "\r"; " "); 1; 70)+" -> "+String:C10($hours)+" h"
	Case of
		: ($steps.length=0)
			$notFound.push($key)
		: ($steps.length>1)
			$ambiguous.push($key+" ("+String:C10($steps.length)+" steps)")
		Else
			$step:=$steps.first()
			Case of
				: ($step.standardHours>0) || ($step.secondsPerUnit>0)
					$kept.push($key+" (has "+String:C10($step.standardHours)+" h)")
				Else
					$set+=1
					If ($apply)
						$step.standardHours:=$hours
						$info:=$step.save()
						If (Not:C34($info.success))
							$set-=1
							$failed.push($key+" ("+String:C10($info.statusText)+")")
						End if
					End if
			End case
	End case
End for each

$lines:=New collection:C1472("Step standard hours fix - "+String:C10(Current date:C33)+" "+String:C10(Current time:C178)+" - "+($apply ? "APPLIED" : "report only"))
$lines.push("")
$lines.push("Legacy step templates: "+String:C10($rows.length)+", with hours: "+String:C10($rows.query("Step_time_in_hrs > 0").length))
$lines.push("Steps "+($apply ? "set" : "to set")+": "+String:C10($set))
$lines.push("Kept (own time already set): "+String:C10($kept.length))
$lines.push("Not found: "+String:C10($notFound.length)+", ambiguous: "+String:C10($ambiguous.length)+", save failed: "+String:C10($failed.length))
$lines.push("")
$lines.push("Hours found per legacy process (to set the Operation Process time by hand):")
$names:=New collection:C1472
For each ($key; $byProcess)
	$names.push($key)
End for each
For each ($key; $names.orderBy())
	$lines.push("  "+$key+": "+$byProcess[$key].orderBy().join(", "))
End for each
For each ($row; New collection:C1472(New object:C1471("title"; "Not found"; "list"; $notFound); New object:C1471("title"; "Ambiguous"; "list"; $ambiguous); New object:C1471("title"; "Kept"; "list"; $kept); New object:C1471("title"; "Save failed"; "list"; $failed)))
	If ($row.list.length>0)
		$lines.push("")
		$lines.push($row.title+":")
		For each ($key; $row.list)
			$lines.push("  "+$key)
		End for each
	End if
End for each

Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("step_standard_hours_fix.txt").setText($lines.join("\r\n"))
cs:C1710.sfw_dialog.me.info(String:C10($set)+" step(s) "+($apply ? "now have" : "would get")+" their legacy standard hours.\rDetails in Project/imports/step_standard_hours_fix.txt")
