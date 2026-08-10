property months : Collection
property days : Collection

shared singleton Class constructor
	
	This:C1470.months:=Split string:C1554(ds:C1482.sfw_readXliff("dateAndTime.months"; "January;Febuary;March;April;May;June;July;August;September;October;November;December"); ";").copy(ck shared:K85:29)
	This:C1470.days:=Split string:C1554(ds:C1482.sfw_readXliff("dateAndTime.days"; "Sunday;Monday;Tuesday;Wednesday;Thursday;Friday;Saturday"); ";").copy(ck shared:K85:29)
	
	
	
	//mark:-form method
Function formMethod()
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			Form:C1466.lastReload_month:=-1
			Form:C1466.lastReload_year:=-1
			OBJECT GET COORDINATES:C663(*; "button_displayDay_1"; $offsetX; $offsetY; $g; $d)
			Form:C1466.offsetX:=$offsetX
			Form:C1466.offsetY:=$offsetY
			Form:C1466.format_button_displayDay:=OBJECT Get format:C894(*; "button_displayDay_1")
			Form:C1466.display:=Form:C1466.display || New object:C1471
			Form:C1466.display.date:=Form:C1466.display.date || Current date:C33
			This:C1470.displayDate()
			
		: (FORM Event:C1606.code=On Clicked:K2:4)
			
			$objectName:=FORM Event:C1606.objectName
			If ($objectName="button_displayDay_@")
				$numSelectedDay:=Num:C11(Substring:C12($objectName; 19))
				Form:C1466.display.date:=Add to date:C393(!00-00-00!; Form:C1466.display.year; Form:C1466.display.month; $numSelectedDay)
				Case of 
					: (String:C10(Form:C1466.widget)="calendar")
						
					Else 
						ACCEPT:C269
				End case 
			End if 
			
	End case 
	
	//mark:-form button & pup
Function bPreviousMonth()
	Form:C1466.display.date:=Add to date:C393(Form:C1466.display.date; 0; -1; 0)
	This:C1470.displayDate()
	
Function bNextMonth()
	Form:C1466.display.date:=Add to date:C393(Form:C1466.display.date; 0; 1; 0)
	This:C1470.displayDate()
	
Function bToday()
	Form:C1466.display.date:=Current date:C33
	This:C1470.displayDate()
	
Function pup_displayYear()
	$refmenus:=New collection:C1472()
	$menu:=Create menu:C408
	$refmenus.push($menu)
	$yearToday:=Year of:C25(Form:C1466.display.date)
	For ($year; $yearToday-3; $yearToday+10)
		APPEND MENU ITEM:C411($menu; String:C10($year))
		$ref:=String:C10($year)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $ref)
		If ($year=$yearToday)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if 
	End for 
	
	$ref:=Dynamic pop up menu:C1006($menu)
	
	For each ($menu; $refmenus)
		RELEASE MENU:C978($menu)
	End for each 
	
	Case of 
		: ($ref="")
		: ($ref#"")
			Form:C1466.display.year:=Num:C11($ref)
			Form:C1466.display.date:=Add to date:C393(!00-00-00!; Form:C1466.display.year; Form:C1466.display.month; Form:C1466.display.day)
			This:C1470.displayDate()
	End case 
	
	
Function pup_displayMonth()
	$refmenus:=New collection:C1472()
	$menu:=Create menu:C408
	$refmenus.push($menu)
	$m:=0
	For each ($month; This:C1470.months)
		$m:=$m+1
		APPEND MENU ITEM:C411($menu; $month; *)
		$ref:=String:C10($m; "00")
		SET MENU ITEM PARAMETER:C1004($menu; -1; $ref)
		If ($m=Form:C1466.display.month)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if 
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
			Form:C1466.display.month:=Num:C11($ref)
			Form:C1466.display.date:=Add to date:C393(!00-00-00!; Form:C1466.display.year; Form:C1466.display.month; Form:C1466.display.day)
			This:C1470.displayDate()
	End case 
	
	
	//mark:-calendar drawing
	
Function displayDate()
	
	Form:C1466.display.year:=Year of:C25(Form:C1466.display.date)
	Form:C1466.display.month:=Month of:C24(Form:C1466.display.date)
	Form:C1466.display.day:=Day of:C23(Form:C1466.display.date)
	This:C1470.calendar_drawing()
	
Function calendar_drawing()
	$reload:=False:C215
	If (Form:C1466.lastReload_month#Form:C1466.display.month)
		$reload:=True:C214
		Form:C1466.lastReload_month:=Form:C1466.display.month
	End if 
	If (Form:C1466.lastReload_year#Form:C1466.display.year)
		$reload:=True:C214
		Form:C1466.lastReload_year:=Form:C1466.display.year
	End if 
	
	OBJECT SET TITLE:C194(*; "Pup_displayYear"; String:C10(Form:C1466.display.year))
	OBJECT SET TITLE:C194(*; "Pup_displayMonth"; This:C1470.months[Form:C1466.display.month-1])
	$dayWidth:=24
	$dayHeight:=24
	OBJECT SET VISIBLE:C603(*; "button_displayDay_@"; False:C215)
	OBJECT SET ENABLED:C1123(*; "button_displayDay_@"; False:C215)
	OBJECT SET FORMAT:C236(*; "button_displayDay_@"; Form:C1466.format_button_displayDay)
	OBJECT SET RGB COLORS:C628(*; "button_displayDay_@"; "black"; Background color none:K23:10)
	$day:=Add to date:C393(!00-00-00!; Form:C1466.display.year; Form:C1466.display.month; 1)
	
	$column:=Day number:C114($day)
	$line:=1
	$dayCounter:=0
	$noWorkingsToDisplay:=True:C214
	$monthInDrawing:=Form:C1466.display.month
	If ($monthInDrawing=13)
		$monthInDrawing:=1
	End if 
	
	While (Month of:C24($day)=($monthInDrawing))
		$dayCounter:=$dayCounter+1
		$buttonName:="button_displayDay_"+String:C10($dayCounter)
		OBJECT SET VISIBLE:C603(*; $buttonName; True:C214)
		OBJECT SET TITLE:C194(*; $buttonName; String:C10(Day of:C23($day)))
		OBJECT SET COORDINATES:C1248(*; $buttonName; \
			Form:C1466.offsetX+(($column-1)*$dayWidth); \
			Form:C1466.offsetY+(($line-1)*$dayHeight); \
			Form:C1466.offsetX+($column*$dayWidth); \
			Form:C1466.offsetY+($line*$dayHeight))
		
		$color:="white"
		$colorText:="black"
		$tips:=String:C10($day; System date long:K1:3)
		If (Form:C1466.display.datesToHighlight#Null:C1517)
			$indices:=Form:C1466.display.datesToHighlight.indices("date = :1"; $day)
		Else 
			$indices:=[]
		End if 
		Case of 
			: ($indices.length>0)
				$color:=Form:C1466.display.datesToHighlight[$indices[0]].color
				$colorText:=Form:C1466.display.datesToHighlight[$indices[0]].colorText
				
			: (Day number:C114($day)=1) | (Day number:C114($day)=7)  // week-end
				$color:="grey"
		End case 
		If ($day=Current date:C33)
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
		OBJECT SET HELP TIP:C1181(*; $buttonName; $tips)
		$day:=$day+1
		$column:=$column+1
		If ($column=8)
			$column:=1
			$line:=$line+1
		End if 
	End while 
	
	
	//mark:-widget callback
	
Function datePickerIcon($sourceExpression : Text)
	var $ptr : Pointer:=OBJECT Get pointer:C1124(Object named:K67:5; FORM Event:C1606.objectName)
	
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			$ptr->:=New object:C1471("hostForm"; Form:C1466; "hostSource"; $sourceExpression)
			OBJECT GET COORDINATES:C663(*; FORM Event:C1606.objectName; $g; $h; $d; $b)
			CONVERT COORDINATES:C1365($g; $h; XY Current form:K27:5; XY Main window:K27:8)
			CONVERT COORDINATES:C1365($d; $b; XY Current form:K27:5; XY Main window:K27:8)
			$ptr->hostCoordinates:=New object:C1471("left"; $g; "top"; $h; "right"; $d; "bottom"; $b)
	End case 
	
	
Function calendarPicker($sourceExpression : Text)
	//var $ptr : Pointer:=OBJECT Get pointer(Object named; FORM Event.objectName)
	
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			//$ptr->:=New object("hostForm"; Form; "hostSource"; $sourceExpression)
			//$ptr->display:=New object
			//$ptr->display.date:=Formula from string(Replace string(Form.hostSource; "Form."; "Form.hostForm.")).call()
			//$formData:=New object("display"; New object)
			//If (Form.hostSource#Null)
			//$formData.display.date:=Formula from string(Replace string(Form.hostSource; "Form."; "Form.hostForm.")).call()
			//$formData.display.datesToHighlight:=[{date: $formData.display.date; color: "red"; colorText: "white"}]
			//End if 
			//$refWindow:=Open form window("sfw_calendar"; Pop up form window; Form.hostCoordinates.left; Form.hostCoordinates.bottom)
			//DIALOG("sfw_calendar"; $formData)
			//CLOSE WINDOW($refWindow)
			//If (ok=1)
			//$parts:=Split string(Replace string(Form.hostSource; "Form."; "Form.hostForm."); ".")
			//$lastAttribute:=$parts.pop()
			//$sourcePart:=$parts.shift()
			//$source:=Form
			//For each ($part; $parts)
			//$source:=$source[$part]
			//End for each 
			//$source[$lastAttribute]:=$formData.display.date
			//End if 
			
	End case 