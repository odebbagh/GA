//%attributes = {}
#DECLARE($period : Object)

var $pict : Picture

$isInModification:=sfw_checkIsInModification
$isDeletable:=True:C214
If (Form:C1466.period=Null:C1517)
	$isDeletable:=False:C215
Else 
	If (Form:C1466.period.name="default")
		$isDeletable:=False:C215
	End if 
End if 
$isDuplicable:=(Form:C1466.period#Null:C1517)

OBJECT SET ENABLED:C1123(*; "B_add"; $isInModification)
OBJECT SET ENABLED:C1123(*; "B_delete"; $isDeletable & $isInModification)
OBJECT SET ENABLED:C1123(*; "B_duplicate"; $isDuplicable & $isInModification)
$buttonVisible:=(Bool:C1537(Form:C1466.notEditable)=False:C215)
OBJECT SET VISIBLE:C603(*; "B_add"; $buttonVisible)
OBJECT SET VISIBLE:C603(*; "B_delete"; $buttonVisible)
OBJECT SET VISIBLE:C603(*; "B_duplicate"; $buttonVisible)

$isVisible:=($period#Null:C1517)

$isPeriod_dateVisible:=False:C215
$isPupSubPeriodVisible:=False:C215
$isDuration_visible:=False:C215
$isWorkingRangesVisible:=False:C215
$isPupExceptionVisible:=False:C215
If ($isVisible)
	$ptr_Pup_period:=OBJECT Get pointer:C1124(Object named:K67:5; "Pup_period")
	$indices:=Form:C1466.pupPeriods.indices("kind = :1"; $period.kind)
	
	$title_pup:=""
	$title_subpup:=""
	Case of 
		: ($period.kind="D")
			$isPeriod_dateVisible:=True:C214
			$title_pup:=ds:C1482.sfw_readXliff("period.type.date"; "Date")
			OBJECT SET TITLE:C194(*; "Pup_subperiodyear"; Substring:C12($period.name; 1; 4))
			OBJECT SET TITLE:C194(*; "Pup_subperiodmonth"; Substring:C12($period.name; 5; 2))
			OBJECT SET TITLE:C194(*; "Pup_subperiodday"; Substring:C12($period.name; 7; 2))
			
		: ($period.kind="M")
			$isPupSubPeriodVisible:=True:C214
			$isPupExceptionVisible:=True:C214
			$title_pup:=ds:C1482.sfw_readXliff("period.type.month"; "Month")
			$month:=Num:C11(Substring:C12($period.name; 5; 2))
			$title_subpup:=Form:C1466.months[$month-1]+" "+Substring:C12($period.name; 1; 4)
			
		: ($period.kind="Q")
			$isPupSubPeriodVisible:=True:C214
			$isPupExceptionVisible:=True:C214
			$title_pup:=ds:C1482.sfw_readXliff("period.type.quarter"; "Quarter")
			$title_subpup:=Substring:C12($period.name; 5; 2)+" "+Substring:C12($period.name; 1; 4)
			
		: ($period.kind="Y")
			$isPupSubPeriodVisible:=True:C214
			$isPupExceptionVisible:=True:C214
			$title_pup:=ds:C1482.sfw_readXliff("period.type.year"; "Year")
			$title_subpup:=$period.name
			
		: ($period.kind="-")
			$title_pup:=ds:C1482.sfw_readXliff("period.type.default"; "default")
			$isPupExceptionVisible:=True:C214
			
	End case 
	OBJECT SET TITLE:C194(*; "Pup_period"; $title_pup)
	OBJECT SET TITLE:C194(*; "Pup_subperiod"; $title_subpup)
	
	Case of 
		: ($period.type="work")
			$isDuration_visible:=True:C214
			OBJECT SET TITLE:C194(*; "Pup_duration"; String:C10((Form:C1466.period.element.min\60); "### mn"))
			$title_type:=ds:C1482.sfw_readXliff("period.type.work"; "Work")
			$isWorkingRangesVisible:=True:C214
			
			$scheduleElementCopy:=OB Copy:C1225(Form:C1466.period.element)
			
			//$pict:=schedule_drawWorkingRanges($scheduleElementCopy.work)
			
			
			(OBJECT Get pointer:C1124((Object named:K67:5); "working_ranges_pict")->):=$pict
			
			If (Form:C1466.period.element.except#Null:C1517)
				$excepts:=New collection:C1472()
				For each ($numDay; Form:C1466.period.element.except)
					$excepts.push(Substring:C12(Form:C1466.days[$numDay-1]; 1; 2))
				End for each 
				$title_except:=ds:C1482.sfw_readXliff("period.type.except"; "except:")+" "+$excepts.join(", ")
			Else 
				$title_except:=ds:C1482.sfw_readXliff("period.type.noException"; "no exception")
			End if 
			OBJECT SET TITLE:C194(*; "Pup_exception"; $title_except)
			
		: ($period.type="bankHoliday")
			$title_type:=ds:C1482.sfw_readXliff("period.type.bankHoliday"; "Bank Holiday")
			
		: ($period.type="Holiday")
			$title_type:=ds:C1482.sfw_readXliff("period.type.holiday"; "Holiday")
			
	End case 
	OBJECT SET TITLE:C194(*; "Pup_periodtype"; $title_type)
	
End if 

OBJECT SET VISIBLE:C603(*; "Pup_period"; $isVisible)
OBJECT SET VISIBLE:C603(*; "Pup_periodtype"; $isVisible)
OBJECT SET VISIBLE:C603(*; "Pup_subperiod"; $isPupSubPeriodVisible)
OBJECT SET VISIBLE:C603(*; "Pup_subperiodyear"; $isPeriod_dateVisible)
OBJECT SET VISIBLE:C603(*; "Pup_subperiodmonth"; $isPeriod_dateVisible)
OBJECT SET VISIBLE:C603(*; "Pup_subperiodday"; $isPeriod_dateVisible)
OBJECT SET VISIBLE:C603(*; "Pup_exception"; $isPupExceptionVisible)

OBJECT SET ENABLED:C1123(*; "Pup_@"; $isInModification)

OBJECT SET VISIBLE:C603(*; "label_@"; $isVisible)
OBJECT SET VISIBLE:C603(*; "@duration"; $isDuration_visible)
OBJECT SET VISIBLE:C603(*; "working_ranges_@"; $isWorkingRangesVisible)
