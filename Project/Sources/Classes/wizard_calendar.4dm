singleton Class constructor
	
	
	//mark:- Interface
	
Function formMethod()
	
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			
			Form:C1466.calendar:=New object:C1471
			Form:C1466.calendar.display:=New object:C1471
			If (Form:C1466.date#!00-00-00!)
				Form:C1466.calendar.display.date:=Form:C1466.date
			Else 
				Form:C1466.calendar.display.date:=Current date:C33(*)
			End if 
			
			This:C1470.calendar_init()
			
		: (FORM Event:C1606.code=On Clicked:K2:4)
			$objectName:=FORM Event:C1606.objectName
			If ($objectName="button_displayDay_@")
				$numSelectedDay:=Num:C11(Substring:C12($objectName; 19))
				Form:C1466.calendar.display.date:=Add to date:C393(!00-00-00!; Form:C1466.calendar.display.year; Form:C1466.calendar.display.month; $numSelectedDay)
				This:C1470.displayDate()
				
			End if 
			
		: (FORM Event:C1606.code=On Unload:K2:2)  //| (FORM Event.code=On Close Box)
			
		: (FORM Event:C1606.code=On Close Box:K2:21)
			
			
	End case 
	
	
	//Mark:-Calendar
	
Function displayDate()
	Form:C1466.calendar.display.year:=Year of:C25(Form:C1466.calendar.display.date)
	Form:C1466.calendar.display.month:=Month of:C24(Form:C1466.calendar.display.date)
	Form:C1466.calendar.display.day:=Day of:C23(Form:C1466.calendar.display.date)
	This:C1470.calendar_drawing()
	
	
Function calendar_init()
	
	If (Form:C1466.months=Null:C1517)
		Form:C1466.months:=Split string:C1554(ds:C1482.sfw_readXliff("dateAndTime.months"; "January;Febuary;March;April;May;June;July;August;September;October;November;December"); ";")
		Form:C1466.days:=Split string:C1554(ds:C1482.sfw_readXliff("dateAndTime.days"; "Sunday;Monday;Tuesday;Wednesday;Thursday;Friday;Saturday"); ";")
	End if 
	If (Form:C1466.calendar=Null:C1517)
		Form:C1466.calendar:=New object:C1471
	End if 
	If (Form:C1466.calendar.display=Null:C1517)
		Form:C1466.calendar.display:=New object:C1471
		Form:C1466.calendar.display.date:=Current date:C33
	End if 
	
	If (FORM Event:C1606.code=On Load:K2:1)
		OBJECT GET COORDINATES:C663(*; "button_displayDay_1"; $offsetX; $offsetY; $g; $d)
		Form:C1466.calendar.offsetX:=$offsetX
		Form:C1466.calendar.offsetY:=$offsetY
		Form:C1466.format_button_displayDay:=OBJECT Get format:C894(*; "button_displayDay_1")
	End if 
	This:C1470.displayDate()
	
	
Function calendar_drawing()
	
	OBJECT SET TITLE:C194(*; "Pup_displayYear"; String:C10(Form:C1466.calendar.display.year))
	OBJECT SET TITLE:C194(*; "Pup_displayMonth"; Form:C1466.months[Form:C1466.calendar.display.month-1])
	$dayWidth:=24
	$dayHeight:=24
	OBJECT SET VISIBLE:C603(*; "button_displayDay_@"; False:C215)
	OBJECT SET ENABLED:C1123(*; "button_displayDay_@"; False:C215)
	OBJECT SET FORMAT:C236(*; "button_displayDay_@"; Form:C1466.format_button_displayDay)
	OBJECT SET RGB COLORS:C628(*; "button_displayDay_@"; "black"; Background color none:K23:10)
	$day:=Add to date:C393(!00-00-00!; Form:C1466.calendar.display.year; Form:C1466.calendar.display.month; 1)
	$column:=Day number:C114($day)
	$line:=1
	$dayCounter:=0
	$noWorkingsToDisplay:=True:C214
	$monthInDrawing:=Form:C1466.calendar.display.month
	If ($monthInDrawing=13)
		$monthInDrawing:=1
	End if 
	While (Month of:C24($day)=($monthInDrawing))
		$dayCounter:=$dayCounter+1
		$buttonName:="button_displayDay_"+String:C10($dayCounter)
		OBJECT SET VISIBLE:C603(*; $buttonName; True:C214)
		OBJECT SET TITLE:C194(*; $buttonName; String:C10(Day of:C23($day)))
		OBJECT SET COORDINATES:C1248(*; $buttonName; \
			Form:C1466.calendar.offsetX+(($column-1)*$dayWidth); \
			Form:C1466.calendar.offsetY+(($line-1)*$dayHeight); \
			Form:C1466.calendar.offsetX+($column*$dayWidth); \
			Form:C1466.calendar.offsetY+($line*$dayHeight))
		
		$color:="white"
		$colorText:="black"
		
		If ($day=Form:C1466.calendar.display.date)
			$color:=$color+"-border"
		End if 
		OBJECT SET FORMAT:C236(*; $buttonName; Replace string:C233(Form:C1466.format_button_displayDay; "grey"; $color))
		If ($day=Current date:C33)
			OBJECT SET FONT STYLE:C166(*; $buttonName; Bold and Underline:K14:10)
		Else 
			OBJECT SET FONT STYLE:C166(*; $buttonName; Plain:K14:1)
		End if 
		OBJECT SET RGB COLORS:C628(*; $buttonName; $colorText)
		OBJECT SET ENABLED:C1123(*; $buttonName; True:C214)
		OBJECT SET TITLE:C194(*; $buttonName; String:C10(Day of:C23($day)))
		$day:=$day+1
		$column:=$column+1
		If ($column=8)
			$column:=1
			$line:=$line+1
		End if 
	End while 
	If ($passe=0)
		If ($column#1)
			$line:=$line+1
		End if 
		$line:=$line+0.4
		OBJECT GET COORDINATES:C663(*; "Pup_displayYearNext"; $go; $ho; $do; $bo)
		OBJECT SET COORDINATES:C1248(*; "Pup_displayYearNext"; $go; Form:C1466.calendar.offsetY+(($line-1)*$dayHeight); $do; $bo-$ho+Form:C1466.calendar.offsetY+(($line-1)*$dayHeight))
		$line:=$line+1
		For ($dd; 1; 7)
			OBJECT SET COORDINATES:C1248(*; "header_day_"+String:C10($dd+7); \
				Form:C1466.calendar.offsetX+(($dd-1)*$dayWidth); \
				Form:C1466.calendar.offsetY+(($line-1)*$dayHeight); \
				Form:C1466.calendar.offsetX+($dd*$dayWidth); \
				Form:C1466.calendar.offsetY+($line*$dayHeight))
		End for 
		$line:=$line+1
	End if 
	
	
Function bPreviousMonth()
	Form:C1466.calendar.display.date:=Add to date:C393(Form:C1466.calendar.display.date; 0; -1; 0)
	This:C1470.displayDate()
	
Function bNextMonth()
	Form:C1466.calendar.display.date:=Add to date:C393(Form:C1466.calendar.display.date; 0; 1; 0)
	This:C1470.displayDate()
	
Function bToday()
	Form:C1466.calendar.display.date:=Current date:C33
	This:C1470.displayDate()
	
Function pup_displayYear()
	$refmenus:=New collection:C1472()
	$menu:=Create menu:C408
	$refmenus.push($menu)
	$yearToday:=Year of:C25(Current date:C33)
	For ($year; Form:C1466.calendar.display.year-10; Form:C1466.calendar.display.year+10)  //($year; $yearToday-10; $yearToday+10)
		APPEND MENU ITEM:C411($menu; String:C10($year))
		$ref:=String:C10($year)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $ref)
	End for 
	
	
	$ref:=Dynamic pop up menu:C1006($menu)
	
	For each ($menu; $refmenus)
		RELEASE MENU:C978($menu)
	End for each 
	
	Case of 
		: ($ref="")
		: ($ref#"")
			Form:C1466.calendar.display.year:=Num:C11($ref)
			Form:C1466.calendar.display.date:=Add to date:C393(!00-00-00!; Form:C1466.calendar.display.year; Form:C1466.calendar.display.month; Form:C1466.calendar.display.day)
			//OBJECT SET TITLE(*; "Pup_displayYear"; String(Form.calendar.display.year))
			This:C1470.displayDate()
	End case 
	
	
Function pup_displayMonth()
	$refmenus:=New collection:C1472()
	$menu:=Create menu:C408
	$refmenus.push($menu)
	$m:=0
	For each ($month; Form:C1466.months)
		$m:=$m+1
		APPEND MENU ITEM:C411($menu; $month; *)
		$ref:=String:C10($m; "00")
		SET MENU ITEM PARAMETER:C1004($menu; -1; $ref)
		If ($m%3=0)
			APPEND MENU ITEM:C411($menu; "-")
		End if 
	End for each 
	
	
	$ref:=Dynamic pop up menu:C1006($menu)
	
	For each ($menu; $refmenus)
		RELEASE MENU:C978($menu)
	End for each 
	
	Case of 
		: ($ref="")
		: ($ref#"")
			Form:C1466.calendar.display.month:=Num:C11($ref)
			Form:C1466.calendar.display.date:=Add to date:C393(!00-00-00!; Form:C1466.calendar.display.year; Form:C1466.calendar.display.month; Form:C1466.calendar.display.day)
			This:C1470.displayDate()
	End case 
	
	
	