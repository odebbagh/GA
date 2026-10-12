//%attributes = {}
// _import_gafLinks
// Client entry point for linking the GAF forms to the steps of their processes, from the
// client's sheet (Project/imports/gaf_step_links.json). The work is done on the server by
// _import_gafLinks_srv; this method asks for the mode and shows the result.
//
// Run order: _import_specControl, _import_steps, _import_specFiles, then this.
// The full detail is in Project/imports/gaf_step_links_report.json.
	
var $report : Object
var $apply : Boolean
var $summary : Text
	
CONFIRM:C162("Link the GAF forms to the steps of their processes (client sheet)?\r\rRun a dry run first to see what would change."; "Apply"; "Dry run")
$apply:=(OK=1)
	
$report:=_import_gafLinks_srv(New object:C1471("dryRun"; Not:C34($apply)))
	
If ($report.error#"")
	ALERT:C41($report.error)
Else 
	$summary:=Choose:C955($report.dryRun; "DRY RUN - nothing was changed\r\r"; "")
	$summary+="Sheet rows: "+String:C10($report.rows)+" ("+String:C10($report.rowsSkipped)+" not linked: not related to the traveler / not process specific / will review / blank)\r"
	$summary+="Forms linked: "+String:C10($report.formsLinked)+"\r"
	$summary+="Links created: "+String:C10($report.linksCreated)+" (of which "+String:C10($report.linksGuess)+" through a guessed process name, "+String:C10($report.linksRule)+" from the all-steps / QA GATE rules)\r"
	$summary+="Already linked, left as they were: "+String:C10($report.linksAlreadyPresent)+"\r"
	$summary+="Previous sheet links replaced: "+String:C10($report.previousRemoved)+"\r\r"
	$summary+="Process names with no match: "+String:C10($report.unmatched.length)+"\r"
	$summary+="Forms not found: "+String:C10($report.formNotFound.length)+"   ambiguous: "+String:C10($report.formAmbiguous.length)+"\r"
	$summary+="Referenced specs not found: "+String:C10($report.refsMissing.length)+"\r\r"
	$summary+="Details: "+$report.reportPath
	
	ALERT:C41($summary)
End if 
