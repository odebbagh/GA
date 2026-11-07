//%attributes = {}
// _fix_lotLatePareto
// One-time repair: the lot import (_import_lotinfo) did not map the legacy delay reason
// ([Lotinfo]Latepareto) to Lot.latePareto; it is only in moreData.legacyRecord.Latepareto. Copies it
// onto the lots that have none, so the late legacy jobs show their reason in the Jobs & Deliveries
// page of a lead (JobEntity.jobsRow) and in planning. Lots that already have a reason are left alone.
// Asks first: "Report only" changes nothing and writes Project/imports/lot_late_pareto_fix.txt;
// "Apply" does the same and saves. Safe to run again.

var $apply : Boolean
var $lots : cs.LotSelection
var $lot : cs.LotEntity
var $lines : Collection
var $count : Object
var $reason : Text
var $info : Object
var $nbSaved; $nbFailed : Integer

$apply:=cs.sfw_dialog.me.confirm("Copy the legacy delay reason (Latepareto) onto the imported lots?\r\r"+\
"Report only: writes Project/imports/lot_late_pareto_fix.txt and changes nothing.\r"+\
"Apply: does the same and saves the lots."; "Apply"; "Report only")

$lots:=ds.Lot.query("latePareto = :1 and moreData.legacyRecord.Latepareto # :1"; "")
$count:=New object
For each ($lot; $lots)
	$reason:=String($lot.moreData.legacyRecord.Latepareto)
	If ($reason="")
		continue
	End if
	$count[$reason]:=Num($count[$reason])+1
	If ($apply)
		$lot.latePareto:=$reason
		$info:=$lot.save()
		If ($info.success)
			$nbSaved+=1
		Else
			$nbFailed+=1
		End if
	End if
End for each

$lines:=New collection("Lot late pareto - "+String(Current date)+" "+String(Current time)+Choose($apply; ""; " (report only)"); "")
$lines.push(String($lots.length)+" lots with a legacy reason and none in GA"+Choose($apply; ": "+String($nbSaved)+" saved, "+String($nbFailed)+" not saved"; ""))
$lines.push("")
$lines.push("By reason:")
For each ($reason; $count)
	$lines.push("  "+$reason+": "+String($count[$reason]))
End for each

Folder(fk database folder).folder("Project/imports").file("lot_late_pareto_fix.txt").setText($lines.join("\r\n"))
cs.sfw_dialog.me.info($lines.join("\r"))
