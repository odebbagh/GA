$oldAttribute:=Form:C1466.period.name
Case of 
	: (Form:C1466.period.kind="Y")
		$year:=Num:C11(Form:C1466.period.name)
		Repeat 
			$year:=$year+1
			$newAttribute:=String:C10($year)
		Until (Form:C1466.schedule[$newAttribute]=Null:C1517)
		
	: (Form:C1466.period.kind="Q")
		$year:=Num:C11(Substring:C12(Form:C1466.period.name; 1; 4))
		$quarter:=Num:C11(Substring:C12(Form:C1466.period.name; 5))
		Repeat 
			$quarter:=$quarter+1
			If ($quarter>4)
				$quarter:=1
				$year:=$year+1
			End if 
			$newAttribute:=String:C10($year)+"Q"+String:C10($quarter)
		Until (Form:C1466.schedule[$newAttribute]=Null:C1517)
		
	: (Form:C1466.period.kind="M")
		$year:=Num:C11(Substring:C12(Form:C1466.period.name; 1; 4))
		$month:=Num:C11(Substring:C12(Form:C1466.period.name; 5))
		Repeat 
			$month:=$month+1
			If ($month>12)
				$month:=1
				$year:=$year+1
			End if 
			$newAttribute:=String:C10($year)+String:C10($month; "00")
		Until (Form:C1466.schedule[$newAttribute]=Null:C1517)
		
	: (Form:C1466.period.kind="D")
		$year:=Num:C11(Substring:C12(Form:C1466.period.name; 1; 4))
		$month:=Num:C11(Substring:C12(Form:C1466.period.name; 5; 2))
		$day:=Num:C11(Substring:C12(Form:C1466.period.name; 7; 2))
		$date:=Add to date:C393(!00-00-00!; $year; $month; $day)
		Repeat 
			$date:=$date+1
			$newAttribute:=String:C10(Year of:C25($date); "0000")+String:C10(Month of:C24($date); "00")+String:C10(Day of:C23($date); "00")
		Until (Form:C1466.schedule[$newAttribute]=Null:C1517)
		
	: (Form:C1466.period.kind="-")
		$year:=Num:C11(Year of:C25(Current date:C33))
		Repeat 
			$year:=$year+1
			$newAttribute:=String:C10($year)
		Until (Form:C1466.schedule[$newAttribute]=Null:C1517)
		
End case 

Form:C1466.schedule[$newAttribute]:=OB Copy:C1225(Form:C1466.schedule[$oldAttribute])
sfw_subpanel_schedule_draw($newAttribute)
CALL SUBFORM CONTAINER:C1086(-98001)

