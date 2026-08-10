// Shipping Job is picked from the jobs attached to this purchase order, through the
// standard selectNto1 list (same pattern as the other job pickers).
Case of
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Form:C1466.poJobs=Null:C1517)
			return
		End if
		If (Form:C1466.poJobs.length=0)
			return
		End if

		var $form : Object
		var $winRef : Integer

		OBJECT GET COORDINATES:C663(*; "Field_shipJob"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)

		$form:=New object:C1471(\
			"colName"; "jobNumber"; \
			"allData"; Form:C1466.poJobs; \
			"dataclass"; "Job"\
			)

		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)

		If (OK=1)
			Form:C1466.poLine.shipJobNumber:=$form.item.jobNumber
		End if

	: (FORM Event:C1606.code=On Mouse Enter:K2:33)
		// the field is bound to an expression, not a variable, so Self-> is not usable:
		// address the object by name instead
		SET CURSOR:C469(Choose:C955(OBJECT Get enabled:C1079(*; "Field_shipJob"); 9000; 9019))

	: (FORM Event:C1606.code=On Mouse Leave:K2:34)
		SET CURSOR:C469()
End case
