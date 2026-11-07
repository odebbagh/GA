//%attributes = {}
// _fix_leadStageOutcome
// One-time set-up: marks which lead stages mean the deal is won or lost (LeadStage.moreData.outcome
// = "won" / "lost"), so panel_lead shows W/L Reasons on those stages whatever their ID. Until it
// runs, LeadStage.outcomeOf counts stages 6 and 7 as won and lost. The stages are found by their
// code (WN = Won, LS = Lost in the reference file), or by their name when the code differs.
// Asks first: "Report only" changes nothing and writes Project/imports/lead_stage_outcome_fix.txt;
// "Apply" does the same and saves. Safe to run again.

var $apply : Boolean
var $lines : Collection
var $rule : Object
var $stage : cs.LeadStageEntity
var $info : Object

$apply:=cs.sfw_dialog.me.confirm("Mark the Won and Lost lead stages?\r\r"+\
"Report only: writes Project/imports/lead_stage_outcome_fix.txt and changes nothing.\r"+\
"Apply: does the same and saves the stages."; "Apply"; "Report only")

$lines:=New collection("Lead stage outcomes - "+String(Current date)+" "+String(Current time)+(Choose($apply; ""; " (report only)")); "")
For each ($rule; New collection(New object("outcome"; "won"; "code"; "WN"; "name"; "Won"); New object("outcome"; "lost"; "code"; "LS"; "name"; "Lost")))
	$stage:=ds.LeadStage.query("code = :1"; $rule.code).first()
	If ($stage=Null)
		$stage:=ds.LeadStage.query("name = :1"; $rule.name).first()
	End if
	Case of
		: ($stage=Null)
			$lines.push($rule.outcome+": no stage with code "+$rule.code+" or name "+$rule.name+", set it by hand (moreData.outcome)")
		: ($stage.moreData#Null) && (String($stage.moreData.outcome)=$rule.outcome)
			$lines.push($rule.outcome+": "+$stage.name+" (ID "+String($stage.stageID)+") already marked")
		Else
			$lines.push($rule.outcome+": "+$stage.name+" (ID "+String($stage.stageID)+")"+Choose($apply; " marked"; " would be marked"))
			If ($apply)
				// a new object, so the change of an Object field is seen by save()
				$stage.moreData:=OB Copy(($stage.moreData=Null) ? New object : $stage.moreData)
				$stage.moreData.outcome:=$rule.outcome
				$info:=$stage.save()
				If (Not($info.success))
					$lines.push("  not saved: "+String($info.statusText))
				End if
			End if
	End case
End for each
If ($apply)
	ds.LeadStage.trigger()  // the stage menus read a cache
End if

Folder(fk database folder).folder("Project/imports").file("lead_stage_outcome_fix.txt").setText($lines.join("\r\n"))
cs.sfw_dialog.me.info($lines.join("\r"))
