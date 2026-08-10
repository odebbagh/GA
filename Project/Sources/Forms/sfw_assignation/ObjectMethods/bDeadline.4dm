
$refMenus:=New collection:C1472
$refMenu:=Create menu:C408
$refMenus.push($refMenu)

APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("assignation.nodeadline"); *)  //okxliff
SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--nodeadline")
APPEND MENU ITEM:C411($refMenu; "-")

$values:=Split string:C1554("today;tomorrow;in 7 days;in 30 days;in 365 days;next week;next month;next year"; ";")
$i:=0
For each ($value; $values)
	APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("assignation."+Replace string:C233($value; " "; "")); *)  //okxliff
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--value:"+String:C10($i))
	$i+=1
End for each 


$choose:=Dynamic pop up menu:C1006($refMenu)
For each ($refMenu; $refMenus)
	RELEASE MENU:C978($refMenu)
End for each 

Form:C1466.deadline:=True:C214
Case of 
	: ($choose="--nodeadline")
		Form:C1466.deadline:=False:C215
		
	: ($choose="--value:@")
		Form:C1466.deadline:=True:C214
		
		$numValue:=Num:C11(Split string:C1554($choose; ":").pop())
		$value:=$values[$numValue]
		Case of 
			: ($numValue=0)
				Form:C1466.deadlineDate:=Current date:C33
			: ($numValue=1)
				Form:C1466.deadlineDate:=Current date:C33+1
			: ($numValue=2)
				Form:C1466.deadlineDate:=Current date:C33+7
			: ($numValue=3)
				Form:C1466.deadlineDate:=Current date:C33+30
			: ($numValue=4)
				Form:C1466.deadlineDate:=Current date:C33+365
			: ($numValue=5)
				$numberOfDay:=Day number:C114(Current date:C33)-1
				$numberOfDay:=(($numberOfDay=0) ? 7 : $numberOfDay)
				Form:C1466.deadlineDate:=Current date:C33-$numberOfDay+1
			: ($numValue=6)
				$month:=Month of:C24(Current date:C33)
				$year:=Year of:C25(Current date:C33)
				Form:C1466.deadlineDate:=Add to date:C393(!00-00-00!; $year; $month+1; 1)
			: ($numValue=7)
				$year:=Year of:C25(Current date:C33)
				Form:C1466.deadlineDate:=Add to date:C393(!00-00-00!; $year+1; 1; 1)
		End case 
End case 
