//%attributes = {}
// _fix_assumptionDefaults
// One-time setup of Assumption.isDefault (Oct 2026): a new quote now gets only the default
// assumptions (QuoteEntity.addAssumptions), where it used to get every one (177 after the legacy
// import, most of them one-off texts).
// Proposes as default the assumptions found on at least half of the 300 most recent quotes
// (ds.Assumption.usualOnRecentQuotes). On the legacy data that gives 6 (US dollars, F.O.B.
// Milpitas, change order fee, lead times, lot definition, 90 days' validity).
// Asks first: "Report only" changes nothing and writes Project/imports/assumption_defaults_fix.txt
// with the use of every assumption; "Apply" does the same and saves. Assumptions already marked
// stay marked. Safe to run again. Admins adjust the list in Administration > Assumptions.

var $apply : Boolean
var $assumption : cs:C1710.AssumptionEntity
var $rows; $lines; $failed : Collection
var $usual; $row; $info : Object
var $marked : Integer

If (ds:C1482.Assumption.all().length=0)
	cs:C1710.sfw_dialog.me.alert("There are no assumptions.\rNothing was changed.")
	return
End if

$apply:=cs:C1710.sfw_dialog.me.confirm("Mark the usual assumptions as Default?\r\r"+\
"Report only: writes Project/imports/assumption_defaults_fix.txt and changes nothing.\r"+\
"Apply: does the same and marks the assumptions found on at least half of the recent quotes."; "Apply"; "Report only")

$usual:=ds:C1482.Assumption.usualOnRecentQuotes(300)

$rows:=New collection:C1472
$failed:=New collection:C1472
For each ($assumption; ds:C1482.Assumption.all())
	$row:=New object:C1471("code"; $assumption.code; "uses"; Num:C11($usual.uses[$assumption.UUID]); "value"; Substring:C12(Replace string:C233($assumption.value; "\r"; " "); 1; 90))
	$row.isDefault:=$assumption.isDefault || ($usual.UUIDs.indexOf($assumption.UUID)#-1)
	$rows.push($row)
	If ($apply) && ($row.isDefault) && (Not:C34($assumption.isDefault))
		$assumption.isDefault:=True:C214
		$info:=$assumption.save()
		If (Not:C34($info.success))
			$failed.push($assumption.code+" ("+String:C10($info.statusText)+")")
		End if
	End if
End for each
$rows:=$rows.orderBy("uses desc, code asc")
$marked:=$rows.query("isDefault = :1"; True:C214).length

$lines:=New collection:C1472("Assumption defaults fix - "+String:C10(Current date:C33)+" "+String:C10(Current time:C178)+" - "+($apply ? "APPLIED" : "report only"))
$lines.push("")
$lines.push("Assumptions: "+String:C10($usual.total)+"; quotes counted: "+String:C10($usual.counted)+" (the most recent with their own list); default from "+String:C10($usual.threshold)+" uses")
$lines.push("Default: "+String:C10($marked)+($apply ? "" : " (not saved)"))
$lines.push("Save failed ("+String:C10($failed.length)+"): "+$failed.join(", "))
$lines.push("")
$lines.push("Default  Uses  Code  Value")
For each ($row; $rows)
	$lines.push(($row.isDefault ? "  yes  " : "       ")+String:C10($row.uses; "#####")+"  "+$row.code+"  "+$row.value)
End for each

Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("assumption_defaults_fix.txt").setText($lines.join("\r\n"))
cs:C1710.sfw_dialog.me.info(String:C10($marked)+" of "+String:C10($usual.total)+" assumptions "+($apply ? "are" : "would be")+" default.\rDetails in Project/imports/assumption_defaults_fix.txt")
