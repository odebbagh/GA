var $newAttribute : Text

$date:=Current date:C33
Repeat 
	$date:=$date+1
	$newAttribute:=String:C10(Year of:C25($date); "0000")+String:C10(Month of:C24($date); "00")+String:C10(Day of:C23($date); "00")
Until (Form:C1466.schedule[$newAttribute]=Null:C1517)

Form:C1466.schedule[$newAttribute]:=New object:C1471("min"; 900; "work"; New collection:C1472(32400; 43200; 50400; 61200))
sfw_subpanel_schedule_draw($newAttribute)
CALL SUBFORM CONTAINER:C1086(-98001)
