// ga_wipExcel
// Writes a ga_wipReport.build() report to an .xlsx workbook through an offscreen 4D View Pro area
// (VP Run offscreen area, as ExcelDataExporter): VP Run offscreen area returns once the file is
// exported. Sheets: Assumptions, WIP by lot, By process, By area.
property area : Text
property autoQuit : Boolean
property report : Object
property filePath : Text

Class constructor($report : Object; $filePath : Text)
	This:C1470.area:="ga_wipExcel"
	This:C1470.autoQuit:=False:C215
	This:C1470.report:=$report
	This:C1470.filePath:=$filePath

Function onEvent()
	var $params : Object

	If (FORM Event:C1606.code=On VP Ready:K2:59)
		VP SET SHEET COUNT(This:C1470.area; 4)
		This:C1470._assumptions(0)
		This:C1470._byLot(1)
		This:C1470._byGroup(2; "By process"; "Operation Process"; This:C1470.report.processes)
		This:C1470._byGroup(3; "By area"; "Area"; This:C1470.report.areas)
		VP SET CURRENT SHEET(This:C1470.area; 1)
		$params:=New object:C1471("format"; vk MS Excel format:K89:2; "formula"; Formula:C1597(ACCEPT:C269))
		$params.excelOptions:=New object:C1471("includeStyles"; True:C214; "includeFormulas"; True:C214)
		VP EXPORT DOCUMENT(This:C1470.area; This:C1470.filePath; $params)
	End if

	// ---------------------------------------------------------------- sheets

Function _assumptions($sheet : Integer)
	var $r; $o : Object
	var $pairs; $rules; $pair : Collection
	var $row; $i : Integer

	$r:=This:C1470.report
	$o:=$r.options
	VP SET SHEET NAME(This:C1470.area; "Assumptions"; $sheet)
	VP SET COLUMN ATTRIBUTES(VP Column(This:C1470.area; 0; 1; $sheet); New object:C1471("width"; 260))
	VP SET COLUMN ATTRIBUTES(VP Column(This:C1470.area; 1; 1; $sheet); New object:C1471("width"; 760))
	This:C1470._title($sheet; "WIP Tracking Report")

	$pairs:=New collection:C1472(\
		New collection:C1472("Generated"; String:C10(Date:C102($r.date))+" "+String:C10(Time:C179($r.time); HH MM:K7:2)+" by "+String:C10(cs:C1710.sfw_userManager.me.info.name)); \
		New collection:C1472("Customer"; ($o.customer="") ? "All" : $o.customer); \
		New collection:C1472("Lot type"; ($o.lotType="") ? "All" : $o.lotType); \
		New collection:C1472("On hold only"; Bool:C1537($o.onHoldOnly) ? "Yes" : "No"); \
		New collection:C1472("Late only"; Bool:C1537($o.lateOnly) ? "Yes" : "No"); \
		New collection:C1472(""; ""); \
		New collection:C1472("Lots listed"; String:C10($r.lots.length)); \
		New collection:C1472("Hours left, all lots listed"; String:C10($r.hoursLeft; "###,##0.00")); \
		New collection:C1472("Late lots"; String:C10($r.late)); \
		New collection:C1472("Lots on hold"; String:C10($r.onHold)); \
		New collection:C1472("Lots with steps without time"; String:C10($r.withoutTime)); \
		New collection:C1472("Active lots not started yet (not listed)"; String:C10($r.notStarted)); \
		New collection:C1472("Active lots with every step out (not listed)"; String:C10($r.allStepsOut)))
	$row:=2
	For each ($pair; $pairs)
		This:C1470._text($sheet; 0; $row; $pair[0])
		This:C1470._text($sheet; 1; $row; $pair[1])
		$row+=1
	End for each
	VP SET CELL STYLE(VP Cells(This:C1470.area; 0; 2; 1; $pairs.length; $sheet); New object:C1471("font"; "bold 10pt Arial"))

	$rules:=New collection:C1472(\
		"A WIP lot is a lot not shipped (no Date Out), not merged into another lot, with at least one step punched in and at least one step still open. Lots not started yet, or with every step out, are counted above but not listed."; \
		"Current step: the first traveller step, in order, not punched out (Qty Out = 0 and no Date Out). The lot is at the Operation Process and the area of that step."; \
		"Hours of a step: its planned hours when set. Else the standard time of its step template, else of its Operation Process: standard hours + quantity x seconds per unit / 3600. Quantity: our count, else the customer count."; \
		"A step with no planned hours and no standard time counts 0 h. It is flagged: Time source \"none\" and \"step(s) without time\" on the lot, so the projection is too early for that lot."; \
		"Hours left: the hours of the current step and of every step after it. The current step counts in full: its actual hours are only known at punch-out."; \
		"Projected completion: now + the hours left, around the clock (24/7: no shifts, weekends or holidays, as in the legacy app). When the current step is punched in, it ends at its punch-in + its hours (never before now); each next step starts when the one before ends."; \
		"Due date: the recommit date, else the commit date. A lot is late when its projected completion date is after its due date. Days late = projected completion date - due date."; \
		"By process / By area: a section per Operation Process / area, in workflow order (the average position of each one in the travellers of the lots listed); the ones not met there come after, by name, with 0 lots. Hours at this step: the current step only; hours left: every step left.")
	$row+=1
	This:C1470._text($sheet; 0; $row; "Assumptions and calculation rules")
	This:C1470._style($sheet; $row; 2; New object:C1471("font"; "bold 12pt Arial"))
	$row+=1
	For ($i; 0; $rules.length-1)
		This:C1470._text($sheet; 0; $row; String:C10($i+1)+".")
		This:C1470._text($sheet; 1; $row; $rules[$i])
		VP SET CELL STYLE(VP Cell(This:C1470.area; 1; $row; $sheet); New object:C1471("wordWrap"; True:C214))
		VP SET ROW ATTRIBUTES(VP Row(This:C1470.area; $row; 1; $sheet); New object:C1471("height"; 34))
		$row+=1
	End for

Function _byLot($sheet : Integer)
	var $lot; $step; $lotStyle; $red : Object
	var $row : Integer

	VP SET SHEET NAME(This:C1470.area; "WIP by lot"; $sheet)
	This:C1470._title($sheet; "WIP by lot")
	This:C1470._text($sheet; 0; 1; "Bold rows: the lot, its current step and its totals. Rows under it: the steps left, in traveller order, with their projected start and end. See the Assumptions sheet.")
	This:C1470._headers($sheet; 3; \
		New collection:C1472("Lot #"; "Customer"; "Device"; "Lot type"; "Priority"; "Qty"; "Step"; "Description"; "Operation Process"; "Area"; "Status"; "Hours (left)"; "Time source"; "Projected start"; "Projected end / completion"; "Commit"; "Recommit"; "Due"; "Days late"); \
		New collection:C1472(70; 160; 120; 100; 55; 55; 60; 220; 140; 110; 190; 75; 150; 120; 140; 80; 80; 80; 60))
	$lotStyle:=New object:C1471("font"; "bold 10pt Arial"; "backColor"; "#DDEBF7")
	$red:=New object:C1471("font"; "bold 10pt Arial"; "backColor"; "#DDEBF7"; "foreColor"; "#C00000")
	$row:=4
	For each ($lot; This:C1470.report.lots)
		This:C1470._lotCells($sheet; $row; $lot)
		This:C1470._text($sheet; 6; $row; $lot.step)
		This:C1470._text($sheet; 7; $row; $lot.description)
		This:C1470._text($sheet; 8; $row; $lot.process)
		This:C1470._text($sheet; 9; $row; $lot.area)
		This:C1470._text($sheet; 10; $row; This:C1470._lotStatus($lot))
		This:C1470._num($sheet; 11; $row; $lot.hoursLeft; "#,##0.00")
		This:C1470._text($sheet; 12; $row; ($lot.withoutTime>0) ? (String:C10($lot.withoutTime)+" step(s) without time") : "")
		This:C1470._moment($sheet; 14; $row; Date:C102($lot.completionDate); $lot.completionTime)
		This:C1470._moment($sheet; 15; $row; Date:C102($lot.commit))
		This:C1470._moment($sheet; 16; $row; Date:C102($lot.reCommit))
		This:C1470._moment($sheet; 17; $row; Date:C102($lot.due))
		If ($lot.late)
			This:C1470._num($sheet; 18; $row; $lot.daysLate; "0")
		End if
		This:C1470._style($sheet; $row; 19; $lotStyle)
		If ($lot.late) || ($lot.onHold)
			This:C1470._cellStyle($sheet; 10; $row; $red)
			This:C1470._cellStyle($sheet; 18; $row; $red)
		End if
		If ($lot.withoutTime>0)
			This:C1470._cellStyle($sheet; 12; $row; $red)
		End if
		$row+=1

		For each ($step; $lot.steps)
			This:C1470._text($sheet; 0; $row; $lot.lotNumber)
			This:C1470._cellStyle($sheet; 0; $row; New object:C1471("foreColor"; "#808080"))
			This:C1470._text($sheet; 6; $row; $step.step)
			This:C1470._text($sheet; 7; $row; $step.description)
			This:C1470._text($sheet; 8; $row; $step.process)
			This:C1470._text($sheet; 9; $row; $step.area)
			This:C1470._text($sheet; 10; $row; $step.status)
			This:C1470._num($sheet; 11; $row; $step.hours; "#,##0.00")
			This:C1470._text($sheet; 12; $row; This:C1470._sourceLabel($step.source))
			If ($step.source="none")
				This:C1470._cellStyle($sheet; 12; $row; New object:C1471("foreColor"; "#C00000"))
			End if
			This:C1470._moment($sheet; 13; $row; Date:C102($step.startDate); $step.startTime)
			This:C1470._moment($sheet; 14; $row; Date:C102($step.endDate); $step.endTime)
			$row+=1
		End for each
	End for each

	If (This:C1470.report.lots.length=0)
		This:C1470._text($sheet; 0; $row; "No WIP lot matches the filters.")
		$row+=1
	End if
	This:C1470._text($sheet; 0; $row; "Total")
	This:C1470._text($sheet; 1; $row; This:C1470._lots(This:C1470.report.lots.length))
	This:C1470._num($sheet; 11; $row; This:C1470.report.hoursLeft; "#,##0.00")
	This:C1470._text($sheet; 18; $row; String:C10(This:C1470.report.late)+" late")
	This:C1470._totalStyle($sheet; $row; 19)

Function _byGroup($sheet : Integer; $name : Text; $label : Text; $groups : Collection)
	// a section per group, its totals on its header row, then its lots
	var $group; $lot; $head; $empty; $red : Object
	var $row; $lots : Integer
	var $hoursHere : Real

	VP SET SHEET NAME(This:C1470.area; $name; $sheet)
	This:C1470._title($sheet; "WIP by "+$label)
	This:C1470._text($sheet; 0; 1; "One section per "+$label+", in workflow order, with the lots whose current step is there (0 lots included). See the Assumptions sheet.")
	This:C1470._headers($sheet; 3; \
		New collection:C1472("Lot #"; "Customer"; "Device"; "Lot type"; "Priority"; "Qty"; "Current step"; "Punched in"; "Hold"; "Hours at this step"; "Hours left"; "Projected completion"; "Commit"; "Recommit"; "Due"; "Days late"); \
		New collection:C1472(70; 160; 120; 100; 55; 55; 260; 70; 70; 80; 75; 140; 80; 80; 80; 60))
	$head:=New object:C1471("font"; "bold 10pt Arial"; "backColor"; "#00A4A4"; "foreColor"; "#FFFFFF")
	$empty:=New object:C1471("font"; "10pt Arial"; "backColor"; "#EDEDED"; "foreColor"; "#808080")
	$red:=New object:C1471("foreColor"; "#C00000")
	$row:=4
	For each ($group; $groups)
		This:C1470._text($sheet; 0; $row; $group.name)
		This:C1470._text($sheet; 6; $row; This:C1470._lots($group.lotCount))
		If ($group.lotCount>0)
			This:C1470._text($sheet; 8; $row; ($group.onHold>0) ? (String:C10($group.onHold)+" on hold") : "")
			This:C1470._num($sheet; 9; $row; $group.hoursHere; "#,##0.00")
			This:C1470._num($sheet; 10; $row; $group.hoursLeft; "#,##0.00")
			This:C1470._text($sheet; 15; $row; ($group.late>0) ? (String:C10($group.late)+" late") : "")
			This:C1470._style($sheet; $row; 16; $head)
		Else
			This:C1470._style($sheet; $row; 16; $empty)
		End if
		$row+=1

		For each ($lot; $group.lots)
			This:C1470._lotCells($sheet; $row; $lot)
			This:C1470._text($sheet; 6; $row; $lot.currentStep)
			This:C1470._text($sheet; 7; $row; $lot.punchedIn ? "Yes" : "No")
			This:C1470._text($sheet; 8; $row; $lot.onHold ? "ON HOLD" : "")
			This:C1470._num($sheet; 9; $row; $lot.hoursHere; "#,##0.00")
			This:C1470._num($sheet; 10; $row; $lot.hoursLeft; "#,##0.00")
			This:C1470._moment($sheet; 11; $row; Date:C102($lot.completionDate); $lot.completionTime)
			This:C1470._moment($sheet; 12; $row; Date:C102($lot.commit))
			This:C1470._moment($sheet; 13; $row; Date:C102($lot.reCommit))
			This:C1470._moment($sheet; 14; $row; Date:C102($lot.due))
			If ($lot.late)
				This:C1470._num($sheet; 15; $row; $lot.daysLate; "0")
				This:C1470._cellStyle($sheet; 15; $row; $red)
			End if
			If ($lot.onHold)
				This:C1470._cellStyle($sheet; 8; $row; $red)
			End if
			$row+=1
		End for each
		$lots+=$group.lotCount
		$hoursHere+=$group.hoursHere
	End for each

	This:C1470._text($sheet; 0; $row; "Total")
	This:C1470._text($sheet; 6; $row; This:C1470._lots($lots)+" in "+String:C10($groups.query("lotCount > 0").length)+" of "+String:C10($groups.length)+" "+Lowercase:C14($label)+" groups")
	This:C1470._num($sheet; 9; $row; Round:C94($hoursHere; 2); "#,##0.00")
	This:C1470._num($sheet; 10; $row; This:C1470.report.hoursLeft; "#,##0.00")
	This:C1470._text($sheet; 15; $row; String:C10(This:C1470.report.late)+" late")
	This:C1470._totalStyle($sheet; $row; 16)

	// ---------------------------------------------------------------- helpers

Function _lotCells($sheet : Integer; $row : Integer; $lot : Object)
	// Lot # .. Qty, the first columns of every lot row
	This:C1470._text($sheet; 0; $row; $lot.lotNumber)
	This:C1470._text($sheet; 1; $row; $lot.customer)
	This:C1470._text($sheet; 2; $row; $lot.device)
	This:C1470._text($sheet; 3; $row; $lot.lotType)
	This:C1470._num($sheet; 4; $row; Num:C11($lot.priority); "0")
	This:C1470._num($sheet; 5; $row; Num:C11($lot.qty); "#,##0")

Function _lotStatus($lot : Object)->$status : Text
	$status:=$lot.punchedIn ? "In progress" : "Not punched in"
	If ($lot.onHold)
		$status:="ON HOLD, "+Lowercase:C14($status)
	End if
	If ($lot.late)
		$status+=", LATE"
	End if

Function _sourceLabel($source : Text)->$label : Text
	Case of
		: ($source="planned")
			$label:="Planned hours"
		: ($source="step")
			$label:="Step template standard"
		: ($source="process")
			$label:="Operation Process standard"
		Else
			$label:="none (0 h)"
	End case

Function _lots($count : Integer)->$text : Text
	$text:=String:C10($count)+(($count=1) ? " lot" : " lots")

Function _title($sheet : Integer; $title : Text)
	This:C1470._text($sheet; 0; 0; $title)
	This:C1470._cellStyle($sheet; 0; 0; New object:C1471("font"; "bold 14pt Arial"))
	VP SET ROW ATTRIBUTES(VP Row(This:C1470.area; 0; 1; $sheet); New object:C1471("height"; 30))

Function _headers($sheet : Integer; $row : Integer; $headers : Collection; $widths : Collection)
	var $i : Integer
	For ($i; 0; $headers.length-1)
		This:C1470._text($sheet; $i; $row; $headers[$i])
		VP SET COLUMN ATTRIBUTES(VP Column(This:C1470.area; $i; 1; $sheet); New object:C1471("width"; $widths[$i]))
	End for
	This:C1470._style($sheet; $row; $headers.length; New object:C1471("font"; "bold 10pt Arial"; "backColor"; "#FFFF00"; "wordWrap"; True:C214))
	VP SET ROW ATTRIBUTES(VP Row(This:C1470.area; $row; 1; $sheet); New object:C1471("height"; 32))

Function _totalStyle($sheet : Integer; $row : Integer; $columns : Integer)
	This:C1470._style($sheet; $row; $columns; New object:C1471("font"; "bold 10pt Arial"; "backColor"; "#D3D3D3"; \
		"borderTop"; New object:C1471("color"; "black"; "style"; vk line style thin:K89:39)))

Function _style($sheet : Integer; $row : Integer; $columns : Integer; $style : Object)
	VP SET CELL STYLE(VP Cells(This:C1470.area; 0; $row; $columns; 1; $sheet); $style)

Function _cellStyle($sheet : Integer; $col : Integer; $row : Integer; $style : Object)
	VP SET CELL STYLE(VP Cell(This:C1470.area; $col; $row; $sheet); $style)

Function _text($sheet : Integer; $col : Integer; $row : Integer; $value : Text)
	If ($value#"")
		VP SET TEXT VALUE(VP Cell(This:C1470.area; $col; $row; $sheet); $value)
	End if

Function _num($sheet : Integer; $col : Integer; $row : Integer; $value : Real; $format : Text)
	VP SET NUM VALUE(VP Cell(This:C1470.area; $col; $row; $sheet); $value; $format)

Function _moment($sheet : Integer; $col : Integer; $row : Integer; $date : Date; $time : Variant)
	// a date, with its time when one is passed; nothing for an empty date
	Case of
		: ($date=!00-00-00!)
		: (Count parameters:C259<5)
			VP SET DATE VALUE(VP Cell(This:C1470.area; $col; $row; $sheet); $date; "mm/dd/yyyy")
		Else
			VP SET DATE TIME VALUE(VP Cell(This:C1470.area; $col; $row; $sheet); $date; Time:C179($time); "mm/dd/yyyy hh:mm")
	End case
