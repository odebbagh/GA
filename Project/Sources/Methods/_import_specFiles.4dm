//%attributes = {}
// _import_specFiles
// Client entry point for loading the GAF form PDFs (<data folder>/GAF) into Document
// Control. The work is done by _import_specFiles_srv, which runs on the server; this method
// only asks for the mode and shows the result, because an ALERT raised inside an
// executedOnServer method would open on the server machine, not in front of the user.
//
// Run "Dry run" first: it reads every file and reports exactly what Apply would do,
// without writing anything. The full detail is in GAF_import_report.json, next to the
// GAF folder in the server's data folder.
//
// Run it again after every _import_specControl, which truncates Specification.
	
var $report : Object
var $apply : Boolean
var $summary : Text
var $attention : Integer
	
CONFIRM:C162("Load the GAF form PDFs from the data folder (GAF) into Document Control?\r\rRun a dry run first to see what would change."; "Apply"; "Dry run")
$apply:=(OK=1)
	
$report:=_import_specFiles_srv(New object:C1471("dryRun"; Not:C34($apply); "createMissing"; True:C214; "updateRevision"; True:C214))
	
If ($report.error#"")
	ALERT:C41($report.error)
Else 
	$attention:=$report.fileOlderThanRecord.length+$report.ambiguous.length+$report.onlySuppressed.length+$report.unparsable.length+$report.failed.length
	
	$summary:=Choose:C955($report.dryRun; "DRY RUN - nothing was changed\r\r"; "")
	$summary+="Files scanned: "+String:C10($report.filesScanned)+" ("+String:C10($report.supersededFiles.length)+" older copies ignored)\r"
	$summary+="Attached: "+String:C10($report.attached.length)+"   Replaced: "+String:C10($report.replaced.length)+"   Unchanged: "+String:C10($report.unchanged)+"\r"
	$summary+="Forms created: "+String:C10($report.specsCreated.length)+"   Revisions moved up: "+String:C10($report.revisionsUpdated.length)+"\r"
	$summary+="Old attachments removed: "+String:C10($report.orphansRemoved)+"\r\r"
	$summary+="Needs attention: "+String:C10($attention)
	$summary+=" (file older than record "+String:C10($report.fileOlderThanRecord.length)
	$summary+=", ambiguous "+String:C10($report.ambiguous.length)
	$summary+=", suppressed only "+String:C10($report.onlySuppressed.length)
	$summary+=", unreadable name "+String:C10($report.unparsable.length)
	$summary+=", failed "+String:C10($report.failed.length)+")\r"
	$summary+="Active forms with no file: "+String:C10($report.activeFormsWithoutFile.length)+"\r\r"
	$summary+="Details: "+$report.reportPath
	
	ALERT:C41($summary)
End if 
