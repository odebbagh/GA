//%attributes = {}
// _demo_check
// Run before the demo: checks the demo data and runs the new features (merge, split,
// history, QA sign-off rule, tool expiry, Forms & Specs) on throwaway records, then shows
// PASS / FAIL with what to do for each failure. The full report is written to
// Project/imports/demo_check.txt.
// Safe to run any time: the throwaway records are created inside a transaction that is
// always cancelled (cs.ga_demoCheck), so the database is left as it was.
	
var $results : Collection
var $r : Object
var $lines : Collection
var $failed : Collection
var $summary : Text
	
$results:=cs:C1710.ga_demoCheck.new().run()
$failed:=$results.query("ok = :1"; False:C215)
	
$lines:=New collection:C1472
$summary:=Choose:C955($failed.length=0; "ALL "+String:C10($results.length)+" CHECKS PASSED - ready for the demo"; String:C10($failed.length)+" OF "+String:C10($results.length)+" CHECKS FAILED")
$lines.push("DEMO CHECK - "+String:C10(Current date:C33)+" "+String:C10(Current time:C178; HH MM:K7:2))
$lines.push($summary)
$lines.push("")
For each ($r; $results)
	$lines.push(Choose:C955($r.ok; "PASS  "; "FAIL  ")+$r.label)
	$lines.push("      "+$r.detail)
	If (Not:C34($r.ok))
		$lines.push("      -> "+$r.fix)
	End if 
End for each 
Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("demo_check.txt").setText($lines.join("\r\n"))
	
If ($failed.length=0)
	ALERT:C41($summary+"\r\rDetails: Project/imports/demo_check.txt")
Else 
	$lines:=New collection:C1472($summary; "")
	For each ($r; $failed)
		$lines.push("FAIL  "+$r.label)
		$lines.push("   "+Substring:C12($r.detail; 1; 220))
		$lines.push("   -> "+$r.fix)
	End for each 
	$lines.push("")
	$lines.push("Full report: Project/imports/demo_check.txt")
	ALERT:C41($lines.join("\r"))
End if 
