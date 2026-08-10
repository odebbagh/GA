$form:=New object:C1471
$form.date:=Form:C1466.startDate
$form.pushUp:=Form:C1466.pushUp
OBJECT GET COORDINATES:C663(*; "pup_startDate"; $left; $top; $rigth; $bottom)
If ($form.pushUp)
	$bottom:=$bottom-190
End if 
CONVERT COORDINATES:C1365($left; $bottom; XY Current form:K27:5; XY Main window:K27:8)
Open window:C153($left; $bottom; $left+285; $bottom+210; Movable dialog box:K34:7; "calendar")
DIALOG:C40("_ga_calendar"; $form)
If ($form.calendar.display.date<=Form:C1466.endDate)
	Form:C1466.startDate:=$form.calendar.display.date
	OBJECT SET TITLE:C194(*; "pup_startDate"; String:C10(Form:C1466.startDate))
	Form:C1466.interval:=String:C10(Form:C1466.endDate-Form:C1466.startDate)
	
Else 
	cs:C1710.sfw_dialog.me.info(ds:C1482.sfw_readXliff("Info"; "Start date can not be greater then End date"))
End if 



