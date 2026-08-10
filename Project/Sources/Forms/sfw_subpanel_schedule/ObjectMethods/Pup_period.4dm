$menu:=Create menu:C408

For each ($kind; Form:C1466.pupPeriods)
	APPEND MENU ITEM:C411($menu; $kind.label)
	SET MENU ITEM PARAMETER:C1004($menu; -1; $kind.kind)
	If (Form:C1466.period.kind="-")
		If ($kind.kind#"-")
			DISABLE MENU ITEM:C150($menu; -1)
		Else 
			APPEND MENU ITEM:C411($menu; "-")
		End if 
	Else 
		If ($kind.kind="-")
			DISABLE MENU ITEM:C150($menu; -1)
			APPEND MENU ITEM:C411($menu; "-")
		End if 
	End if 
	If (Form:C1466.period.kind=$kind.kind)
		SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
	End if 
End for each 
$ref:=Dynamic pop up menu:C1006($menu)

RELEASE MENU:C978($menu)

$oldAttribute:=Form:C1466.period.name
$newAttribute:=""
Case of 
	: ($ref="")
	: ($ref="Y")
		$values:=Form:C1466.periods.query("kind = :1"; $ref).extract("name")
		If ($values.length>0)
			$valuesN:=New collection:C1472
			For each ($value; $values)
				$valuesN.push(Num:C11($value))
			End for each 
			$max:=$valuesN.max()
			$newAttribute:=String:C10($max+1)
		Else 
			$newAttribute:=String:C10(Year of:C25(Current date:C33))
		End if 
		
	: ($ref="Q")
		$values:=Form:C1466.periods.query("kind = :1"; $ref).extract("name")
		If ($values.length>0)
			$valuesN:=New collection:C1472
			For each ($value; $values)
				$valueO:=New object:C1471
				$valueO.year:=Num:C11(Substring:C12($value; 1; 4))
				$valueO.quarter:=Num:C11(Substring:C12($value; 6))
				$valuesN.push($valueO)
			End for each 
			$valuesN:=$valuesN.orderBy("year, quarter")
			$valueO:=$valuesN.pop()
			$valueO.quarter:=$valueO.quarter+1
			If ($valueO.quarter>4)
				$valueO.quarter:=1
				$valueO.year:=$valueO.year+1
			End if 
		Else 
			$valueO:=New object:C1471
			$valueO.year:=String:C10(Year of:C25(Current date:C33))
			$month:=Month of:C24(Current date:C33)
			$valueO.quarter:=($month\3)+Num:C11(($month%3)#0)
		End if 
		
		$newAttribute:=String:C10($valueO.year)+"Q"+String:C10($valueO.quarter)
		
	: ($ref="M")
		$values:=Form:C1466.periods.query("kind = :1"; $ref).extract("name")
		If ($values.length>0)
			$valuesN:=New collection:C1472
			For each ($value; $values)
				$valueO:=New object:C1471
				$valueO.year:=Num:C11(Substring:C12($value; 1; 4))
				$valueO.month:=Num:C11(Substring:C12($value; 5; 2))
				$valuesN.push($valueO)
			End for each 
			$valuesN:=$valuesN.orderBy("year, month")
			$valueO:=$valuesN.pop()
			$valueO.month:=$valueO.month+1
			If ($valueO.month>12)
				$valueO.month:=1
				$valueO.year:=$valueO.year+1
			End if 
		Else 
			$valueO:=New object:C1471
			$valueO.year:=String:C10(Year of:C25(Current date:C33))
			$valueO.month:=Month of:C24(Current date:C33)
		End if 
		$newAttribute:=String:C10($valueO.year)+String:C10($valueO.month; "00")
		
	: ($ref="D")
		$values:=Form:C1466.periods.query("kind = :1"; $ref).extract("name")
		If ($values.length>0)
			$valueD:=New collection:C1472
			For each ($value; $values)
				$year:=Num:C11(Substring:C12($value; 1; 4))
				$month:=Num:C11(Substring:C12($value; 5; 2))
				$day:=Num:C11(Substring:C12($value; 7; 2))
				$valueD.push(Add to date:C393(!00-00-00!; $year; $month; $day))
			End for each 
			$date:=$valueD.max()+1
		Else 
			$date:=Current date:C33
		End if 
		$newAttribute:=String:C10(Year of:C25($date); "0000")+String:C10(Month of:C24($date); "00")+String:C10(Day of:C23($date); "00")
		
End case 

If ($newAttribute#"")
	Form:C1466.schedule[$newAttribute]:=OB Copy:C1225(Form:C1466.schedule[$oldAttribute])
	OB REMOVE:C1226(Form:C1466.schedule; $oldAttribute)
	If ($ref="D")
		OB REMOVE:C1226(Form:C1466.schedule[$newAttribute]; "except")
	End if 
	sfw_subpanel_schedule_draw($newAttribute)
	CALL SUBFORM CONTAINER:C1086(-98001)
	
End if 