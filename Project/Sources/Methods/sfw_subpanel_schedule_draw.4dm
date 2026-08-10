//%attributes = {}
#DECLARE($newAttribute : Text)

var $attribute : Text
var $period : Object

If (Form:C1466.schedule=Null:C1517)
	Form:C1466.schedule:=New object:C1471
End if 
If (Form:C1466.schedule.default=Null:C1517)
	Form:C1466.schedule.default:=New object:C1471("min"; 900; "except"; New collection:C1472(7; 1); "work"; New collection:C1472(32400; 43200; 50400; 61200))
End if 

Form:C1466.periods:=New collection:C1472()
For each ($attribute; Form:C1466.schedule)
	$period:=New object:C1471
	$scheduleElement:=Form:C1466.schedule[$attribute]
	$period.name:=$attribute
	If ($scheduleElement.min#Null:C1517)
		$period.min:=String:C10(Time:C179($scheduleElement.min); HH MM:K7:2)
	End if 
	$scheduleElementCopy:=OB Copy:C1225($scheduleElement)
	If ($scheduleElement.work#Null:C1517)
		$period.type:="work"
		$ranges:=New collection:C1472()
		While ($scheduleElementCopy.work.length>0)
			$start:=$scheduleElementCopy.work.shift()
			$end:=$scheduleElementCopy.work.shift()
			$ranges.push(String:C10(Time:C179($start); HH MM:K7:2)+" -> "+String:C10(Time:C179($end); HH MM:K7:2))
		End while 
		$period.ranges:=$ranges.join(", ")
		If ($scheduleElement.except#Null:C1517)
			$period.ranges:=$period.ranges+" ("+ds:C1482.sfw_readXliff("period.type.only"; "only:")+" "
			$days:=New collection:C1472
			For ($d; 1; 7)
				If ($scheduleElement.except.countValues($d)=0)
					$days.push(Substring:C12(Form:C1466.days[$d-1]; 1; 2))
				End if 
			End for 
			$period.ranges:=$period.ranges+$days.join(", ")+")"
		End if 
	Else 
		Case of 
			: ($scheduleElement.bankHoliday)
				$period.type:="bankHoliday"
				$period.ranges:=ds:C1482.sfw_readXliff("period.type.bankHoliday"; "Bank holiday")
			: ($scheduleElement.holiday)
				$period.type:="holiday"
				$period.ranges:=ds:C1482.sfw_readXliff("period.type.holiday"; "Holiday")
			Else 
				$period.type:="-"
				$period.ranges:=""
		End case 
		$period.min:=""
	End if 
	
	Case of 
		: (Length:C16($attribute)=8)  // Day
			$period.order:=10
			$period.kind:="D"
			$year:=Num:C11(Substring:C12($attribute; 1; 4))
			$month:=Num:C11(Substring:C12($attribute; 5; 2))
			$day:=Num:C11(Substring:C12($attribute; 7))
			$period.dayDate:=Add to date:C393(!00-00-00!; $year; $month; $day)
			
		: (Length:C16($attribute)=6)
			If ($attribute[[5]]="Q")  // Quarter
				$period.order:=30
				$period.kind:="Q"
			Else   // Month
				$period.order:=20
				$period.kind:="M"
			End if 
			
		: (Length:C16($attribute)=4)  // Year
			$period.order:=40
			$period.kind:="Y"
			
		: ($attribute="default")
			$period.order:=100
			$period.kind:="-"
			$default_exist:=True:C214
			
		Else 
			TRACE:C157
	End case 
	
	$period.element:=$scheduleElement
	
	Form:C1466.periods.push($period)
	
End for each 

Form:C1466.periods:=Form:C1466.periods.orderBy("order, name")

If (Count parameters:C259>0)
	$indices:=Form:C1466.periods.indices("name = :1"; $newAttribute)
	If ($indices.length>0)
		$indice:=Num:C11($indices[0])
		LISTBOX SELECT ROW:C912(*; "lb_periods"; $indice+1; lk replace selection:K53:1)
		sfw_subpanel_schedule_period(Form:C1466.periods[$indice])
	End if 
	
End if 