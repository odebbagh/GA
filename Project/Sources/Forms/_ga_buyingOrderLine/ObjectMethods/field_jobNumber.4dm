// Job Number is a picker: click to choose a Job from the list (same selectNto1
// pattern used elsewhere). Sets both the UUID_Job link and the displayed jobNumber.
Case of
	: (FORM Event:C1606.code=On Clicked:K2:4)

		var $form : Object
		var $winRef : Integer

		OBJECT GET COORDINATES:C663(*; "field_jobNumber"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)

		$form:=New object:C1471(\
			"colName"; "jobNumber"; \
			"allData"; ds:C1482.Job.all().orderBy("jobNumber"); \
			"dataclass"; "Job"\
			)

		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)

		If (OK=1)
			Form:C1466.details.UUID_Job:=$form.item.UUID
			Form:C1466.details.jobNumber:=$form.item.jobNumber
		End if

	: (FORM Event:C1606.code=On Mouse Move:K2:35)
		SET CURSOR:C469(9000)
End case
