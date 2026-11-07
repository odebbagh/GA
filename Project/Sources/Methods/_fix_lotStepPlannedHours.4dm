//%attributes = {}
// _fix_lotStepPlannedHours
// Back-fill of the planned hours of work in progress (Oct 2026), once standard times are set on
// the Operation Processes / Step Templates (ga_processTime). New lot steps get them at planning
// (panel_planning.createLotStepFromStepEntity); the ones planned before have 0.
// Fills plannedHours on the lot steps not punched out yet (qtyOut = 0, dateOut empty) that have
// none, on the active lots (dateOut empty, not merged, as JobEntity.liveLots): the standard of
// the step's library Step for the lot quantity (ourCount, else customerCount). A planned value
// already there is never changed; a step with no standard time keeps 0 and is listed.
// Asks first: "Report only" changes nothing and writes Project/imports/lot_step_planned_hours_fix.txt;
// "Apply" does the same and saves. Safe to run again.

var $apply : Boolean
var $lot; $ls : 4D:C1709.Entity
var $lines; $filled; $noStandard; $failed : Collection
var $standard; $info : Object
var $qty : Integer
var $hours : Real
var $key : Text

$apply:=cs:C1710.sfw_dialog.me.confirm("Fill the planned hours of the open lot steps from the standard times?\r\r"+\
"Report only: writes Project/imports/lot_step_planned_hours_fix.txt and changes nothing.\r"+\
"Apply: does the same and saves the lot steps that have no planned hours."; "Apply"; "Report only")

$filled:=New collection:C1472
$noStandard:=New collection:C1472
$failed:=New collection:C1472
For each ($lot; ds:C1482.Lot.query("dateOut = :1 AND location # :2"; !00-00-00!; "merged").orderBy("number asc"))
	$qty:=cs:C1710.ga_processTime.me.lotQty($lot)
	For each ($ls; ds:C1482.LotStep.query("UUID_Lot = :1 AND qtyOut = 0 AND dateOut = :2 AND plannedHours = 0"; $lot.UUID; !00-00-00!).orderBy("order asc"))
		$standard:=cs:C1710.ga_processTime.me.standardFor($ls.step)
		$hours:=cs:C1710.ga_processTime.me.hoursFrom($standard; $qty)
		$key:="lot "+String:C10($lot.displayNumber)+" (qty "+String:C10($qty)+") step "+String:C10($ls.order)+" "+Substring:C12(Replace string:C233($ls.description; "\r"; " "); 1; 50)
		If ($hours=0)
			$noStandard.push($key)
		Else
			$key:=$key+" -> "+String:C10($hours)+" h ("+$standard.source+": "+cs:C1710.ga_processTime.me.describe($standard)+")"
			If ($apply)
				$ls.plannedHours:=$hours
				$info:=$ls.save()
				If ($info.success)
					$filled.push($key)
				Else
					$failed.push($key+" ("+String:C10($info.statusText)+")")
				End if
			Else
				$filled.push($key)
			End if
		End if
	End for each
End for each

$lines:=New collection:C1472("Lot step planned hours fix - "+String:C10(Current date:C33)+" "+String:C10(Current time:C178)+" - "+($apply ? "APPLIED" : "report only"))
$lines.push("")
$lines.push("Open lot steps "+($apply ? "filled" : "to fill")+": "+String:C10($filled.length))
$lines.push("No standard time (kept at 0): "+String:C10($noStandard.length))
$lines.push("Save failed: "+String:C10($failed.length))
For each ($info; New collection:C1472(New object:C1471("title"; ($apply ? "Filled" : "To fill"); "list"; $filled); New object:C1471("title"; "No standard time"; "list"; $noStandard); New object:C1471("title"; "Save failed"; "list"; $failed)))
	If ($info.list.length>0)
		$lines.push("")
		$lines.push($info.title+":")
		For each ($key; $info.list)
			$lines.push("  "+$key)
		End for each
	End if
End for each

Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("lot_step_planned_hours_fix.txt").setText($lines.join("\r\n"))
cs:C1710.sfw_dialog.me.info(String:C10($filled.length)+" open lot step(s) "+($apply ? "now have" : "would get")+" planned hours, "+String:C10($noStandard.length)+" have no standard time.\rDetails in Project/imports/lot_step_planned_hours_fix.txt")
