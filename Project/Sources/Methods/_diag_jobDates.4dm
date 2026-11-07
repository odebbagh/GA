//%attributes = {}
// _diag_jobDates
// Read-only check of the job dates the Jobs & Deliveries page relies on for imported jobs whose lots
// were not imported. _import_receiver copies legacy Invoice_date, Last_lot_ship_date and
// ExpectedJobCompletionDate with Num(): if those were Dates in the export, the stamps are wrong.
// For each stamp field of Job: how many jobs have one, how many give a date outside 1990-2035 (or
// none at all), and a few examples with their job number, to compare with the legacy app.
// Writes Project/imports/job_dates_diag.txt. Changes nothing.

var $fields : Collection
var $f : Object
var $jobs : cs.JobSelection
var $job : cs.JobEntity
var $lines; $examples : Collection
var $date : Date
var $nbBad : Integer
var $text : Text

$fields:=New collection(\
New object("stamp"; "stmpCreated"; "date"; "dateCreated"); \
New object("stamp"; "stmpExpected"; "date"; "expectedDate"); \
New object("stamp"; "stmpLastShipped"; "date"; "lastShipDate"); \
New object("stamp"; "stmpInvoiced"; "date"; "invoiceDate"); \
New object("stamp"; "stmpArchived"; "date"; "archivedDate"))

$lines:=New collection("Job dates - "+String(Current date)+" "+String(Current time); "")
For each ($f; $fields)
	$jobs:=ds.Job.query($f.stamp+" > 0")
	$nbBad:=0
	$examples:=New collection
	For each ($job; $jobs)
		$date:=$job[$f.date]
		If ($date=!00-00-00!) || (Year of($date)<1990) || (Year of($date)>2035)
			$nbBad+=1
			If ($examples.length<10)
				$examples.push("job "+String($job.jobNumber)+": "+$f.stamp+" = "+String($job[$f.stamp])+" -> "+String($date))
			End if
		End if
	End for each
	$lines.push($f.stamp+": "+String($jobs.length)+" jobs with a value, "+String($nbBad)+" giving an impossible date")
	For each ($text; $examples)
		$lines.push("    "+$text)
	End for each
	// a few good ones too, to compare with the legacy app
	For each ($job; $jobs.slice(0; 3))
		$lines.push("    sample: job "+String($job.jobNumber)+" -> "+String($job[$f.date]))
	End for each
End for each

Folder(fk database folder).folder("Project/imports").file("job_dates_diag.txt").setText($lines.join("\r\n"))
cs.sfw_dialog.me.info($lines.join("\r"))
