property window : Integer
property events : Object
property collapsedMonths : Collection
property collapsedYears : Collection
property expandedEvents : Collection
property usersToDisplay : Collection
property eventTypeToDisplay : Collection

shared singleton Class constructor
	
	This:C1470.window:=0
	This:C1470.events:=New shared object:C1526
	This:C1470._init()
	This:C1470.collapsedYears:=New shared collection:C1527
	This:C1470.collapsedMonths:=New shared collection:C1527
	This:C1470.expandedEvents:=New shared collection:C1527
	This:C1470.usersToDisplay:=New shared collection:C1527
	This:C1470.eventTypeToDisplay:=New shared collection:C1527
	
shared Function createIfNotExist($ident : Text; $label : Text)
	var $eEventType : cs:C1710.sfw_EventTypeEntity
	If (This:C1470.events[$ident]=Null:C1517)
		$eEventType:=ds:C1482.sfw_EventType.query("ident = :1"; $ident).first()
		If ($eEventType=Null:C1517)
			CALL WORKER:C1389("sfw_event_worker"; Formula:C1597(cs:C1710.sfw_eventManager.me._createEventType($1; $2)); $ident; $label)
		Else 
			This:C1470.events[$ident]:=OB Copy:C1225($eEventType.toObject(); ck shared:K85:29)
		End if 
	End if 
	
	
shared Function _init()
	
	This:C1470.createIfNotExist("createRecord"; "Create the record")
	This:C1470.createIfNotExist("modifRecord"; "Modify the record")
	This:C1470.createIfNotExist("duplicateRecord"; "Duplicate the record")
	
	
shared Function _createEventType($ident : Text; $label : Text)
	var $eEventType : cs:C1710.sfw_EventTypeEntity
	$eEventType:=ds:C1482.sfw_EventType.new()
	$eEventType.ident:=$ident
	$eEventType.label:=$label
	$info:=$eEventType.save()
	If ($info.success)
		This:C1470.events[$ident]:=OB Copy:C1225($eEventType.toObject(); ck shared:K85:29)
	End if 
	
	
	
shared Function getEventType($ident : Text)->$eventType : Object
	var $eEventType : cs:C1710.sfw_EventTypeEntity
	If (This:C1470.events[$ident]=Null:C1517)
		$eEventType:=ds:C1482.sfw_EventType.query("ident = :1"; $ident).first()
		If ($eEventType=Null:C1517)
		Else 
			This:C1470.events[$ident]:=OB Copy:C1225($eEventType.toObject(); ck shared:K85:29)
		End if 
	End if 
	$eventType:=This:C1470.events[$ident]
	
shared Function getEventTypeByUUID($uuid : Text)->$eventType : Object
	var $eEventType : cs:C1710.sfw_EventTypeEntity
	If (This:C1470.events[$uuid]=Null:C1517)
		$eEventType:=ds:C1482.sfw_EventType.get($uuid)
		If ($eEventType=Null:C1517)
		Else 
			This:C1470.events[$uuid]:=OB Copy:C1225($eEventType.toObject(); ck shared:K85:29)
		End if 
	End if 
	$eventType:=This:C1470.events[$uuid]
	
	
shared Function getEvent($entry : cs:C1710.sfw_definitionEntry; $ident : Text; $uuid : Text)->$eEvent : 4D:C1709.Entity
	If ($entry.event.dataclass#Null:C1517) && ($entry.event.linkedAttribute#Null:C1517)
		$eventTypeUUID:=This:C1470.events[$ident].UUID
		$eEvent:=ds:C1482[$entry.event.dataclass].query("UUID_EventType = :1 AND "+$entry.event.linkedAttribute+" = :2"; $eventTypeUUID; $uuid).first()
	End if 
	
shared Function addEvent($entry : cs:C1710.sfw_definitionEntry; $ident : Text; $uuid : Text; $moreData : Object; $stmp : Integer)
	
	If ($entry.event.dataclass#Null:C1517)
		
		$eEvent:=ds:C1482[$entry.event.dataclass].new()
		$eEvent.UUID_EventType:=This:C1470.events[$ident].UUID
		$eEvent.UUID_User:=cs:C1710.sfw_userManager.me.info.UUID
		
		
		For each ($attribute; ds:C1482[$entry.event.dataclass])
			If (ds:C1482[$entry.event.dataclass][$attribute].kind="storage") && (ds:C1482[$entry.event.dataclass][$attribute].name=("UUID_"+$entry.dataclass))
				$eEvent[$attribute]:=$uuid
				break
			End if 
		End for each 
		
		If (Count parameters:C259>3)
			$eEvent.moreData:=$moreData
		End if 
		If (Count parameters:C259>4)
			$eEvent.stmp:=$stmp
		Else 
			$eEvent.stmp:=cs:C1710.sfw_stmp.me.now()
		End if 
		$info:=$eEvent.save()
		
	End if 
	
	
Function launch()
	
	CALL WORKER:C1389("eventManager"; "sfw_eventPalette_launch")
	
	
shared Function setWindow($ref : Integer)
	This:C1470.window:=$ref
	
	
shared Function bAction()
	$refMenus:=New collection:C1472
	$refMenu:=Create menu:C408
	$refMenus.push($refMenu)
	
	$refMenuExpand:=Create menu:C408
	$refMenus.push($refMenuExpand)
	APPEND MENU ITEM:C411($refMenuExpand; ds:C1482.sfw_readXliff("eventManager.expall"); *)
	SET MENU ITEM PARAMETER:C1004($refMenuExpand; -1; "--expandAll")
	APPEND MENU ITEM:C411($refMenuExpand; "-")
	APPEND MENU ITEM:C411($refMenuExpand; ds:C1482.sfw_readXliff("eventManager.expyears"); *)
	SET MENU ITEM PARAMETER:C1004($refMenuExpand; -1; "--expandYears")
	APPEND MENU ITEM:C411($refMenuExpand; ds:C1482.sfw_readXliff("eventManager.expmonths"); *)
	SET MENU ITEM PARAMETER:C1004($refMenuExpand; -1; "--expandMonths")
	APPEND MENU ITEM:C411($refMenuExpand; ds:C1482.sfw_readXliff("eventManager.expevent"); *)
	SET MENU ITEM PARAMETER:C1004($refMenuExpand; -1; "--expandEvents")
	APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("eventManager.exp"); $refMenuExpand; *)
	
	$refMenuCollapse:=Create menu:C408
	$refMenus.push($refMenuCollapse)
	APPEND MENU ITEM:C411($refMenuCollapse; ds:C1482.sfw_readXliff("eventManager.collall"); *)
	SET MENU ITEM PARAMETER:C1004($refMenuCollapse; -1; "--collapseAll")
	APPEND MENU ITEM:C411($refMenuCollapse; "-")
	APPEND MENU ITEM:C411($refMenuCollapse; ds:C1482.sfw_readXliff("eventManager.collyears"); *)
	SET MENU ITEM PARAMETER:C1004($refMenuCollapse; -1; "--collapseYears")
	APPEND MENU ITEM:C411($refMenuCollapse; ds:C1482.sfw_readXliff("eventManager.collmonths"); *)
	SET MENU ITEM PARAMETER:C1004($refMenuCollapse; -1; "--collapseMonths")
	APPEND MENU ITEM:C411($refMenuCollapse; ds:C1482.sfw_readXliff("eventManager.collevent"); *)
	SET MENU ITEM PARAMETER:C1004($refMenuCollapse; -1; "--collapseEvents")
	APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("eventManager.coll"); $refMenuCollapse; *)
	
	APPEND MENU ITEM:C411($refMenu; "-")
	
	$refMenuUser:=Create menu:C408
	$refMenus.push($refMenuUser)
	APPEND MENU ITEM:C411($refMenuUser; ds:C1482.sfw_readXliff("eventManager.userall"); *)
	SET MENU ITEM PARAMETER:C1004($refMenuUser; -1; "--allUsers")
	If (This:C1470.usersToDisplay=Null:C1517) || (This:C1470.usersToDisplay.length=0)
		SET MENU ITEM MARK:C208($refMenuUser; -1; Char:C90(18))
	End if 
	APPEND MENU ITEM:C411($refMenuUser; "-")
	For each ($eUser; Form:C1466.esEvents.user.orderBy("fullName"))
		APPEND MENU ITEM:C411($refMenuUser; $eUser.nameToDisplayForEventOrComment; *)
		SET MENU ITEM PARAMETER:C1004($refMenuUser; -1; "user:"+$eUser.UUID)
		If (This:C1470.usersToDisplay#Null:C1517) && (This:C1470.usersToDisplay.indexOf($eUser.UUID)>=0)
			SET MENU ITEM MARK:C208($refMenuUser; -1; Char:C90(18))
		End if 
	End for each 
	APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("eventManager.user"); $refMenuUser; *)
	
	$refMenuEventType:=Create menu:C408
	$refMenus.push($refMenuUser)
	APPEND MENU ITEM:C411($refMenuEventType; ds:C1482.sfw_readXliff("eventManager.alleventtype"); *)
	SET MENU ITEM PARAMETER:C1004($refMenuEventType; -1; "--allEventTypes")
	If (This:C1470.eventTypeToDisplay=Null:C1517) || (This:C1470.eventTypeToDisplay.length=0)
		SET MENU ITEM MARK:C208($refMenuEventType; -1; Char:C90(18))
	End if 
	APPEND MENU ITEM:C411($refMenuEventType; "-")
	For each ($eEventType; Form:C1466.esEvents.eventType.orderBy("label"))
		APPEND MENU ITEM:C411($refMenuEventType; $eEventType.label; *)
		SET MENU ITEM PARAMETER:C1004($refMenuEventType; -1; "eventType:"+$eEventType.UUID)
		If (This:C1470.eventTypeToDisplay#Null:C1517) && (This:C1470.eventTypeToDisplay.indexOf($eEventType.UUID)>=0)
			SET MENU ITEM MARK:C208($refMenuEventType; -1; Char:C90(18))
		End if 
	End for each 
	APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("eventManager.eventtype"); $refMenuEventType; *)
	
	$choice:=Dynamic pop up menu:C1006($refMenu)
	For each ($refMenu; $refMenus)
		RELEASE MENU:C978($refMenu)
	End for each 
	
	Case of 
		: ($choice="--expandAll")
			This:C1470.collapsedYears:=New shared collection:C1527
			This:C1470.collapsedMonths:=New shared collection:C1527
			This:C1470.expandedEvents:=Form:C1466.events.extract("UUID").copy(ck shared:K85:29)
			This:C1470._drawEventContainer()
			
		: ($choice="--expandYears")
			This:C1470.collapsedYears:=New shared collection:C1527
			This:C1470._drawEventContainer()
			
		: ($choice="--expandMonths")
			This:C1470.collapsedMonths:=New shared collection:C1527
			This:C1470._drawEventContainer()
			
		: ($choice="--expandEvents")
			This:C1470.expandedEvents:=Form:C1466.events.extract("UUID").copy(ck shared:K85:29)
			This:C1470._drawEventContainer()
			
		: ($choice="--collapseAll")
			This:C1470.collapsedYears:=New shared collection:C1527
			This:C1470.collapsedMonths:=New shared collection:C1527
			For ($year; 2000; 2050)
				This:C1470.collapsedYears.push($year)
				For ($month; 1; 12)
					This:C1470.collapsedMonths.push(String:C10($year)+"/"+String:C10($month))
				End for 
			End for 
			This:C1470.expandedEvents:=New shared collection:C1527
			This:C1470._drawEventContainer()
			
		: ($choice="--collapseYears")
			This:C1470.collapsedYears:=New shared collection:C1527
			For ($year; 2000; 2050)
				This:C1470.collapsedYears.push($year)
			End for 
			This:C1470._drawEventContainer()
			
		: ($choice="--collapseMonths")
			This:C1470.collapsedMonths:=New shared collection:C1527
			For ($year; 2000; 2050)
				For ($month; 1; 12)
					This:C1470.collapsedMonths.push(String:C10($year)+"/"+String:C10($month))
				End for 
			End for 
			This:C1470._drawEventContainer()
			
		: ($choice="--collapseEvents")
			This:C1470.expandedEvents:=New shared collection:C1527
			This:C1470._drawEventContainer()
			
			
		: ($choice="--allUsers")
			This:C1470.usersToDisplay:=New shared collection:C1527
			This:C1470._drawEventContainer()
			
		: ($choice="user:@")
			$uuid:=Split string:C1554($choice; ":").pop()
			This:C1470.usersToDisplay:=This:C1470.usersToDisplay || New shared collection:C1527
			$index:=This:C1470.usersToDisplay.indexOf($uuid)
			If ($index>=0)
				This:C1470.usersToDisplay.remove($index)
			Else 
				This:C1470.usersToDisplay.push($uuid)
			End if 
			This:C1470._drawEventContainer()
			
		: ($choice="--allEventTypes")
			This:C1470.eventTypeToDisplay:=New shared collection:C1527
			This:C1470._drawEventContainer()
			
		: ($choice="eventType:@")
			$uuid:=Split string:C1554($choice; ":").pop()
			This:C1470.eventTypeToDisplay:=This:C1470.eventTypeToDisplay || New shared collection:C1527
			$index:=This:C1470.eventTypeToDisplay.indexOf($uuid)
			If ($index>=0)
				This:C1470.eventTypeToDisplay.remove($index)
			Else 
				This:C1470.eventTypeToDisplay.push($uuid)
			End if 
			This:C1470._drawEventContainer()
	End case 
	
	
shared Function _formMethod()
	
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			
			Form:C1466.levelFilter:=0
			This:C1470._drawEventContainer()
			
			
		: (FORM Event:C1606.code=On Close Box:K2:21)
			CANCEL:C270
			This:C1470.window:=0
			
	End case 
	
	
Function _displayHeaderTabEvent()
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.sfw.entry.event#Null:C1517)
		$nb:=ds:C1482.sfw_getNbEvents(Form:C1466.current_item.UUID; Form:C1466.sfw.entry)
		Case of 
			: ($nb=0)
				$title:=Form:C1466.sfw.entry.event.unit0 || "no event"
			: ($nb=1)
				$title:=Form:C1466.sfw.entry.event.unit1 || "one event"
			Else 
				$title:=String:C10($nb)+" "+(Form:C1466.sfw.entry.event.unitN || "events")
		End case 
		OBJECT SET VALUE:C1742("headerTabEvent_title"; $title)
	End if 
	$eventTabVisible:=(Form:C1466.current_item#Null:C1517) && (Form:C1466.sfw.entry.event#Null:C1517)
	OBJECT SET VISIBLE:C603(*; "headerTabEvent@"; $eventTabVisible)
	Form:C1466.sfw.arrangeHeaderTabs()
	
	
Function clicOnHeader($uuid_target : Text; $entry : cs:C1710.sfw_definitionEntry)
	cs:C1710.sfw_tracker.me.internal("event clic on header : "+Get window title:C450)
	If (This:C1470.window#0)
		SHOW WINDOW:C435(This:C1470.window)
	End if 
	WINDOW LIST:C442($_refWindows; *)
	If (This:C1470.window=0) || (Find in array:C230($_refWindows; This:C1470.window)<0)
		This:C1470.launch()
	End if 
	DELAY PROCESS:C323(Current process:C322; 10)
	SHOW WINDOW:C435(This:C1470.window)
	CALL FORM:C1391(This:C1470.window; Formula:C1597(cs:C1710.sfw_eventManager.me._displayEvents($1; $2)); $uuid_target; $entry)
	
	
Function refresh($uuid_target : Text; $entry : cs:C1710.sfw_definitionEntry)
	cs:C1710.sfw_tracker.me.internal("events refresh : "+Get window title:C450)
	If (This:C1470.window#0)
		SHOW WINDOW:C435(This:C1470.window)
	End if 
	WINDOW LIST:C442($_refWindows; *)
	If (This:C1470.window#0) && (Find in array:C230($_refWindows; This:C1470.window)>0)
		SHOW WINDOW:C435(This:C1470.window)
		CALL FORM:C1391(This:C1470.window; Formula:C1597(cs:C1710.sfw_eventManager.me._displayEvents($1; $2)); $uuid_target; $entry)
	End if 
	
	
Function hide()
	cs:C1710.sfw_tracker.me.internal("events hide : "+Get window title:C450)
	WINDOW LIST:C442($_refWindows; *)
	If (This:C1470.window#0) && (Find in array:C230($_refWindows; This:C1470.window)>0)
		HIDE WINDOW:C436(This:C1470.window)
	End if 
	
	
Function _displayEvents($uuid_target : Text; $entry : cs:C1710.sfw_definitionEntry)
	var $eEvent : 4D:C1709.Entity
	
	Form:C1466.UUID_target:=$uuid_target
	Form:C1466.entry:=$entry
	Form:C1466.events:=New collection:C1472
	If (ds:C1482[$entry.event.dataclass]#Null:C1517)
		Form:C1466.esEvents:=ds:C1482[$entry.event.dataclass].query($entry.event.linkedAttribute+" = :1 order by stmp desc"; $uuid_target)
		For each ($eEvent; Form:C1466.esEvents)
			$event:=New object:C1471
			$event.UUID:=$eEvent.UUID
			$event.stmp:=$eEvent.stmp
			$event.date:=cs:C1710.sfw_stmp.me.getDate($event.stmp)
			$event.time:=String:C10(cs:C1710.sfw_stmp.me.getTime($event.stmp); HH MM SS:K7:1)
			$event.year:=Year of:C25($event.date)
			$event.month:=Month of:C24($event.date)
			If ($eEvent.user#Null:C1517)
				$event.user:=$eEvent.user.nameToDisplayForEventOrComment
				$event.UUID_User:=$eEvent.UUID_User
			Else 
				$event.user:=""  //cs.sfw_userManager.me.info.login
				$event.UUID_User:="0"*32
			End if 
			$commentParts:=New collection:C1472
			If ($eEvent.moreData#Null:C1517)
				If ($eEvent.moreData.modifiedFields#Null:C1517)
					For each ($attributeName; $eEvent.moreData.modifiedFields)
						$commentParts.push($attributeName+": "+String:C10($eEvent.moreData.modifiedFields[$attributeName].old)+" -> "+String:C10($eEvent.moreData.modifiedFields[$attributeName].new))
					End for each 
				End if 
				If ($eEvent.moreData.comment#Null:C1517)
					$commentParts.push($eEvent.moreData.comment)
				End if 
			End if 
			$event.comment:=$commentParts.join("\r"; ck ignore null or empty:K85:5)
			
			$event.eventTypeTitle:=This:C1470.getEventTypeByUUID($eEvent.UUID_EventType).label
			$event.UUID_EventType:=$eEvent.UUID_EventType
			Form:C1466.events.push($event)
		End for each 
	End if 
	This:C1470._drawEventContainer()
	
	
	
Function _drawEventContainer()
	var $file : 4D:C1709.File
	var $formDefinition : Object
	cs:C1710.sfw_tracker.me.internal("draw event container : "+Get window title:C450)
	
	OBJECT SET VISIBLE:C603(*; "subFormEventList"; Form:C1466.events.length>0)
	OBJECT SET VISIBLE:C603(*; "noEvent_@"; Form:C1466.events.length=0)
	If (Form:C1466.events.length>0)
		
		$file:=Folder:C1567(fk resources folder:K87:11).file("sfw/dynform/container.json")
		$formDefinition:=JSON Parse:C1218($file.getText())
		$file:=Folder:C1567(fk resources folder:K87:11).file("sfw/dynform/eventListYear.json")
		$formEventListYearJson:=$file.getText()
		$file:=Folder:C1567(fk resources folder:K87:11).file("sfw/dynform/eventListMonth.json")
		$formEventListMonthJson:=$file.getText()
		$file:=Folder:C1567(fk resources folder:K87:11).file("sfw/dynform/eventListItem.json")
		$formEventListItemJson:=$file.getText()
		$file:=Folder:C1567(fk resources folder:K87:11).file("sfw/dynform/eventListItemHidden.json")
		$formEventListItemHiddenJson:=$file.getText()
		
		$pageObjects:=$formDefinition.pages[1].objects
		$lineNum:=-1
		$vOffset:=0
		
		$years:=Form:C1466.events.distinct("year")
		Form:C1466.years:=New collection:C1472
		$y:=-1
		Form:C1466.months:=New collection:C1472
		$m:=-1
		For each ($yearNum; $years)
			$year:=New object:C1471
			$year.year:=$yearNum
			$year.expand:=(This:C1470.collapsedYears.indexOf($yearNum)=-1) ? 1 : 0
			Form:C1466.years.push($year)
		End for each 
		Form:C1466.years:=Form:C1466.years.orderBy("year desc")
		For each ($year; Form:C1466.years)
			$y+=1
			$newLineDefinition:=Replace string:C233($formEventListYearJson; "##1##"; String:C10($y))
			$widgets:=JSON Parse:C1218($newLineDefinition).objects
			$widget:=$widgets["year_"+String:C10($y)]
			$widget.dataSource:=String:C10($year.year)
			$widget:=$widgets["bExpand_year_"+String:C10($y)]
			$widget.dataSource:="Form.years["+String:C10($y)+"].expand"
			$widget:=$widgets["header_bkgd_year_"+String:C10($y)]
			$maxBottom:=$widget.top+$widget.height
			For each ($widgetName; $widgets)
				$widget:=$widgets[$widgetName]
				$widget.top+=$vOffset
				$pageObjects[$widgetName]:=$widget
			End for each 
			$vOffset+=$maxBottom
			If ($year.expand=1)
				$months:=Form:C1466.events.query("year = :1"; $year.year).distinct("month").reverse()
				For each ($monthNum; $months)
					$month:=New object:C1471
					$month.year:=$year.year
					$month.month:=$monthNum
					$yearmonth:=String:C10($month.year)+"/"+String:C10($month.month)
					$month.expand:=(This:C1470.collapsedMonths.indexOf($yearmonth)=-1) ? 1 : 0
					Form:C1466.months.push($month)
					$m+=1
					$newLineDefinition:=Replace string:C233($formEventListMonthJson; "##1##"; String:C10($m))
					$widgets:=JSON Parse:C1218($newLineDefinition).objects
					$widget:=$widgets["month_"+String:C10($m)]
					$widget.dataSource:=String:C10($month.month)
					$widget.dataSource:="\""+cs:C1710.sfw_stmp.me.monthNames[$month.month-1]+" - "+String:C10($month.year)+"\""
					$widget:=$widgets["bExpand_month_"+String:C10($m)]
					$widget.dataSource:="Form.months["+String:C10($m)+"].expand"
					$widget:=$widgets["header_bkgd_month_"+String:C10($m)]
					$maxBottom:=$widget.top+$widget.height
					For each ($widgetName; $widgets)
						$widget:=$widgets[$widgetName]
						$widget.top+=$vOffset
						$pageObjects[$widgetName]:=$widget
					End for each 
					$vOffset+=$maxBottom
					
					If ($month.expand=1)
						
						$events:=Form:C1466.events.query("year = :1 and month = :2"; $year.year; $month.month)
						For each ($event; $events)
							$lineNum+=1
							
							$displayed:=(This:C1470.usersToDisplay=Null:C1517) || (This:C1470.usersToDisplay.length=0) || (This:C1470.usersToDisplay.indexOf($event.UUID_User)>=0)
							$displayed:=$displayed & ((This:C1470.eventTypeToDisplay=Null:C1517) || (This:C1470.eventTypeToDisplay.length=0) || (This:C1470.eventTypeToDisplay.indexOf($event.UUID_EventType)>=0))
							If ($displayed)
								$newLineDefinition:=Replace string:C233($formEventListItemJson; "##1##"; String:C10($lineNum))
								$event.expand:=(This:C1470.expandedEvents.indexOf($event.UUID)=-1) ? 0 : 1
								
								$widgets:=JSON Parse:C1218($newLineDefinition).objects
								$widget:=$widgets["bCollapse_event_"+String:C10($lineNum)]
								$widget.dataSource:="Form.events["+String:C10($lineNum)+"].expand"
								
								Case of 
									: ($event.expand=0)
										$widget:=$widgets["header_bkgd_"+String:C10($lineNum)]
										$maxBottom:=$widget.top+$widget.height
									: ($event.comment="")
										$widget:=$widgets["time_"+String:C10($lineNum)]
										$maxBottom:=$widget.top+$widget.height+3
										$height:=$widget.height
										$widget:=$widgets["body_bkgd_"+String:C10($lineNum)]
										$widget.height:=$height+3+3
									Else 
										Form:C1466.text_calculator:=$event.comment
										OBJECT GET BEST SIZE:C717(*; "text_calculator"; $bestWidth; $bestHeight; 321)
										$widget:=$widgets["comment_"+String:C10($lineNum)]
										$widget.height:=$bestHeight
										$widget:=$widgets["body_bkgd_"+String:C10($lineNum)]
										$widget.height:=$bestHeight+17+3+3+3
										$maxBottom:=$widget.top+$widget.height
								End case 
								
								For each ($widgetName; $widgets)
									$widget:=$widgets[$widgetName]
									If ((Bool:C1537($widget._expand)=True:C214) && ($event.expand=1)) || (Bool:C1537($widget._expand)=False:C215)
										$widget.top+=$vOffset
										If ($widgetName#("comment_"+String:C10($lineNum)))
											$pageObjects[$widgetName]:=$widget
										Else 
											If ($event.comment#"")
												$pageObjects[$widgetName]:=$widget
											End if 
										End if 
									End if 
								End for each 
								$vOffset+=$maxBottom
								
							Else 
								
								$newLineDefinition:=Replace string:C233($formEventListItemHiddenJson; "##1##"; String:C10($lineNum))
								$widgets:=JSON Parse:C1218($newLineDefinition).objects
								$maxBottom:=0
								For each ($widgetName; $widgets)
									$widget:=$widgets[$widgetName]
									If ($widget.height+$widget.top>$maxBottom)
										$maxBottom:=$widget.height+$widget.top
									End if 
									$widget.top+=$vOffset
									$pageObjects[$widgetName]:=$widget
								End for each 
								$vOffset+=$maxBottom
								
							End if 
						End for each 
						
					End if 
					
					
				End for each 
				
			End if 
			
		End for each 
		$formDefinition.method:="sfw_eventManager_sfm"
		
		Form:C1466.subFormEventList:=New object:C1471
		Form:C1466.subFormEventList.events:=Form:C1466.events.orderBy("stmp desc")
		Form:C1466.subFormEventList.years:=Form:C1466.years
		Form:C1466.subFormEventList.months:=Form:C1466.months
		OBJECT SET SUBFORM:C1138(*; "subFormEventList"; $formDefinition)
	End if 
	
	
	
Function subFormMethod()
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			
			
		: (FORM Event:C1606.code=On Clicked:K2:4) & (FORM Event:C1606.objectName="bExpand_year_@")
			$year:=Form:C1466.years[Num:C11(Split string:C1554(FORM Event:C1606.objectName; "_").pop())]
			Case of 
				: ($year.expand=0)
					Use (This:C1470.collapsedYears)
						This:C1470.collapsedYears.push($year.year).distinct()
					End use 
				: ($year.expand=1)
					Use (This:C1470.collapsedYears)
						$index:=This:C1470.collapsedYears.indexOf($year.year)
						This:C1470.collapsedYears.remove($index)
					End use 
			End case 
			CALL SUBFORM CONTAINER:C1086(-2000)
			
		: (FORM Event:C1606.code=On Clicked:K2:4) & (FORM Event:C1606.objectName="bExpand_month_@")
			$month:=Form:C1466.months[Num:C11(Split string:C1554(FORM Event:C1606.objectName; "_").pop())]
			$yearmonth:=String:C10($month.year)+"/"+String:C10($month.month)
			Case of 
				: ($month.expand=0)
					Use (This:C1470.collapsedMonths)
						This:C1470.collapsedMonths.push($yearmonth).distinct()
					End use 
				: ($month.expand=1)
					Use (This:C1470.collapsedMonths)
						$index:=This:C1470.collapsedMonths.indexOf($yearmonth)
						This:C1470.collapsedMonths.remove($index)
					End use 
			End case 
			CALL SUBFORM CONTAINER:C1086(-2000)
			
		: (FORM Event:C1606.code=On Clicked:K2:4) & (FORM Event:C1606.objectName="bCollapse_event_@")
			$event:=Form:C1466.events[Num:C11(Split string:C1554(FORM Event:C1606.objectName; "_").pop())]
			Case of 
				: ($event.expand=0)
					Use (This:C1470.expandedEvents)
						$index:=This:C1470.expandedEvents.indexOf($event.UUID)
						This:C1470.expandedEvents.remove($index)
					End use 
				: ($event.expand=1)
					Use (This:C1470.expandedEvents)
						This:C1470.expandedEvents.push($event.UUID).distinct()
					End use 
					
			End case 
			CALL SUBFORM CONTAINER:C1086(-2000)
			
	End case 
	