

$form:=New object:C1471
$form.date:=Form:C1466.date

OBJECT GET COORDINATES:C663(Self:C308->; $left; $top; $rigth; $bottom)
CONVERT COORDINATES:C1365($left; $bottom; XY Current form:K27:5; XY Main window:K27:8)
Open window:C153($left; $bottom; $left+285; $bottom+210; Movable dialog box:K34:7; "calendar")
DIALOG:C40("_ga_calendar"; $form)

If (OK=1)
	Form:C1466.date:=$form.calendar.display.date
End if 

