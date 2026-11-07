//%attributes = {}
// _diag_wipReport
// READ-ONLY. The WIP tracking report (ga_wipReport.build, no filter) as text, with its checks, to
// read beside the Excel export (Planning > "WIP report to Excel"). Nothing is saved. Writes
// Project/imports/wip_report_diag.txt.
//   - every lot listed: current step, process, area, hours left, projected completion, due, late
//   - checks: the last step's projected end = the lot's projected completion (ga_processTime);
//     every lot is in one process group and one area group; group totals = report totals

var $report; $lot; $last; $group : Object
var $lines : Collection
var $checks : Object
var $kind : Text
var $count : Integer
var $hours : Real

$report:=cs.ga_wipReport.me.build(Null)
$checks:=New object("endMatches"; 0; "endDiffers"; New collection)
$lines:=New collection
$lines.push("WIP REPORT DIAG "+String(Date($report.date))+" "+String(Time($report.time); HH MM))
$lines.push("lots listed: "+String($report.lots.length)+", hours left: "+String($report.hoursLeft)+", late: "+String($report.late)+", on hold: "+String($report.onHold)+", with steps without time: "+String($report.withoutTime))
$lines.push("not listed: "+String($report.notStarted)+" not started, "+String($report.allStepsOut)+" with every step out")
$lines.push("")
$lines.push("LOTS")
For each ($lot; $report.lots)
	$lines.push("  "+$lot.lotNumber+" | "+$lot.customer+" | "+$lot.currentStep+" | "+$lot.process+" | "+$lot.area+" | in: "+Choose($lot.punchedIn; "yes"; "no")+Choose($lot.onHold; " | ON HOLD"; "")+" | left "+String($lot.hoursLeft)+" h of "+String($lot.hoursTotal)+" | ends "+String(Date($lot.completionDate))+" "+String(Time($lot.completionTime); HH MM)+" | due "+String(Date($lot.due))+Choose($lot.late; " | LATE "+String($lot.daysLate)+" d"; "")+Choose($lot.withoutTime>0; " | "+String($lot.withoutTime)+" step(s) without time"; ""))
	For each ($last; $lot.steps)
		$lines.push("      "+$last.step+" "+$last.description+" | "+$last.process+" | "+$last.area+" | "+$last.status+" | "+String($last.hours)+" h ("+$last.source+") | "+String(Date($last.startDate))+" "+String(Time($last.startTime); HH MM)+" -> "+String(Date($last.endDate))+" "+String(Time($last.endTime); HH MM))
	End for each
	$last:=$lot.steps[$lot.steps.length-1]
	If (Date($last.endDate)=Date($lot.completionDate)) && (Time($last.endTime)=Time($lot.completionTime))
		$checks.endMatches:=$checks.endMatches+1
	Else
		$checks.endDiffers.push($lot.lotNumber)
	End if
End for each

For each ($kind; New collection("processes"; "areas"))
	$lines.push("")
	$lines.push(Uppercase($kind)+" (workflow order)")
	$count:=0
	$hours:=0
	For each ($group; $report[$kind])
		$lines.push("  "+String($group.position; "0.00")+" "+$group.name+": "+String($group.lotCount)+" lot(s), "+String($group.hoursHere)+" h here, "+String($group.hoursLeft)+" h left, "+String($group.late)+" late, "+String($group.onHold)+" on hold")
		$count:=$count+$group.lotCount
		$hours:=$hours+$group.hoursLeft
	End for each
	$checks[$kind]:=New object("lots"; $count; "hoursLeft"; Round($hours; 2))
End for each

$lines.push("")
$lines.push("CHECKS")
$lines.push("  "+Choose($checks.endDiffers.length=0; "OK  "; "FAIL")+" last step end = projected completion: "+String($checks.endMatches)+" match"+Choose($checks.endDiffers.length=0; ""; ", differ: "+$checks.endDiffers.join(", ")))
For each ($kind; New collection("processes"; "areas"))
	$lines.push("  "+Choose(($checks[$kind].lots=$report.lots.length) && ($checks[$kind].hoursLeft=$report.hoursLeft); "OK  "; "FAIL")+" "+$kind+": "+String($checks[$kind].lots)+" lots, "+String($checks[$kind].hoursLeft)+" h left in the groups (report: "+String($report.lots.length)+", "+String($report.hoursLeft)+")")
End for each

Folder(fk database folder).folder("Project/imports").file("wip_report_diag.txt").setText($lines.join("\r\n"))
ALERT("WIP report diagnostic written to Project/imports/wip_report_diag.txt.\r"+$lines[$lines.length-3]+"\r"+$lines[$lines.length-2]+"\r"+$lines[$lines.length-1])
