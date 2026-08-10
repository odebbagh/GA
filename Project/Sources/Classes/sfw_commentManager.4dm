property window : Integer
property callingWindow : Integer
property levels : Object

shared singleton Class constructor
	
	This:C1470.window:=0
	This:C1470.callingWindow:=0
	This:C1470.levels:=New shared object:C1526
	This:C1470.levels["0"]:=New shared object:C1526("header"; "HoneyDew"; "body"; "MintCream"; "label"; ds:C1482.sfw_readXliff("comment.level.low"; "Low"))
	This:C1470.levels["1"]:=New shared object:C1526("header"; "LemonChiffon"; "body"; "LightYellow"; "label"; ds:C1482.sfw_readXliff("comment.level.normal"; "Normal"))
	This:C1470.levels["2"]:=New shared object:C1526("header"; "LightPink"; "body"; "MistyRose"; "label"; ds:C1482.sfw_readXliff("comment.level.important"; "Important"))
	This:C1470.levels["3"]:=New shared object:C1526("header"; "Wheat"; "body"; "Bisque"; "label"; ds:C1482.sfw_readXliff("comment.level.critical"; "Critical"))
	
	
Function launch()
	
	CALL WORKER:C1389("commentManager"; "sfw_commentPalette_launch")
	
shared Function setWindow($ref : Integer)
	This:C1470.window:=$ref
	
	
	
	
shared Function _formMethod()
	var $eComment : cs:C1710.sfw_CommentEntity
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			
			Form:C1466.levelFilter:=0
			This:C1470._drawCommentContainer()
			
			
		: (FORM Event:C1606.code=On Close Box:K2:21)
			CANCEL:C270
			This:C1470.window:=0
			
			
		: (FORM Event:C1606.code=On Clicked:K2:4)
			Case of 
				: (FORM Event:C1606.objectName="bCancelComment")
					Form:C1466.comments.remove(0)
					This:C1470._drawCommentContainer()
					
				: (FORM Event:C1606.objectName="bCreateComment")
					$eComment:=ds:C1482.sfw_Comment.new()
					$eComment.UUID:=Generate UUID:C1066
					$eComment.UUID_target:=Form:C1466.UUID_target
					$eComment.UUID_User:=cs:C1710.sfw_userManager.me.info.UUID
					$eComment.stmp:=cs:C1710.sfw_stmp.me.now()
					$eComment.ID_level:=Form:C1466.comments[0].level
					$eComment.comment:=Form:C1466.comments[0].message
					$info:=$eComment.save()
					This:C1470._displayComments(Form:C1466.UUID_target)
					CALL FORM:C1391(This:C1470.callingWindow; Formula:C1597(cs:C1710.sfw_commentManager.me._displayHeaderTabComment()))
					
			End case 
			
	End case 
	This:C1470._activateAddButton()
	
Function _activateAddButton()
	$activateAdd:=(Form:C1466.comments.length=0) || (Form:C1466.comments[0].add=Null:C1517)
	OBJECT SET ENABLED:C1123(*; "bAddComment"; $activateAdd)
	If (Form:C1466.comments.length>0) && (Form:C1466.comments[0].add)
		Form:C1466.comments[0].stmp:=cs:C1710.sfw_stmp.me.now()
	End if 
	
Function _drawCommentContainer()
	var $formDefinitionFile : 4D:C1709.File
	var $formMessageListItemFile : 4D:C1709.File
	var $bestWidth : Integer
	var $bestHeight : Integer
	var $formDefinition : Object
	OBJECT SET VISIBLE:C603(*; "subFormCommentList"; Form:C1466.comments.length>0)
	OBJECT SET VISIBLE:C603(*; "noComment_@"; Form:C1466.comments.length=0)
	
	If (Form:C1466.comments.length>0)
		$formDefinitionFile:=Folder:C1567(fk resources folder:K87:11).file("sfw/dynform/container.json")
		$formDefinition:=JSON Parse:C1218($formDefinitionFile.getText())
		$formMessageListItemFile:=Folder:C1567(fk resources folder:K87:11).file("sfw/dynform/messageListItem.json")
		$formMessageListItemJson:=$formMessageListItemFile.getText()
		$formMessageListItemAddFile:=Folder:C1567(fk resources folder:K87:11).file("sfw/dynform/messageListItemWithAddButton.json")
		$formMessageListItemAddJson:=$formMessageListItemAddFile.getText()
		
		$pageObjects:=$formDefinition.pages[1].objects
		$lineNum:=-1
		$vOffset:=0
		For each ($comment; Form:C1466.comments)
			$lineNum+=1
			If ($comment.level>=Form:C1466.levelFilter) || ($comment.add)
				If ($comment.message#"")
					Form:C1466.text_calculator:=$comment.message
					OBJECT GET BEST SIZE:C717(*; "text_calculator"; $bestWidth; $bestHeight; 332)
				Else 
					$bestHeight:=100
				End if 
				If ($comment.add)
					$newLineDefinition:=Replace string:C233($formMessageListItemAddJson; "##1##"; String:C10($lineNum))
				Else 
					$newLineDefinition:=Replace string:C233($formMessageListItemJson; "##1##"; String:C10($lineNum))
				End if 
				$widgets:=JSON Parse:C1218($newLineDefinition).objects
				$widget:=$widgets["message_"+String:C10($lineNum)]
				If ($comment.add)
					$widget.enterable:=True:C214
					$add:=True:C214
				Else 
					$widget.height:=$bestHeight
				End if 
				If ($comment.add)
					$widget:=$widgets["pup_priority_"+String:C10($lineNum)]
					$widget.text:=ds:C1482.sfw_readXliff("comment.priority"; "Priority")+" : "+This:C1470.levels["1"].label
				End if 
				$widget:=$widgets["header_bkgd_"+String:C10($lineNum)]
				$widget.fill:=This:C1470.levels[String:C10($comment.level)].header
				If ($comment.expand=0)
					$maxBottom:=$widget.top+$widget.height
				End if 
				$widget:=$widgets["message_bkgd_"+String:C10($lineNum)]
				$widget.fill:=This:C1470.levels[String:C10($comment.level)].body
				If ($comment.add)
				Else 
					$widget.height:=$bestHeight+16
				End if 
				If ($comment.expand=1)
					$maxBottom:=$widget.top+$widget.height
				End if 
				For each ($widgetName; $widgets)
					$widget:=$widgets[$widgetName]
					$widget.top+=$vOffset
					If ($comment.expand=1) || (($comment.expand=0) && (Not:C34(Bool:C1537($widget._expandOnly))))
						$pageObjects[$widgetName]:=$widget
					End if 
				End for each 
				$vOffset+=$maxBottom
			End if 
		End for each 
		
		$formDefinition.method:="sfw_commentManager_sfm"
		
		Form:C1466.subFormCommentList:=New object:C1471
		Form:C1466.subFormCommentList.messages:=Form:C1466.comments.orderBy("stmp desc")
		OBJECT SET SUBFORM:C1138(*; "subFormCommentList"; $formDefinition)
	End if 
	
	
Function bAddComment()
	
	$comment:=New object:C1471
	$comment.stmp:=cs:C1710.sfw_stmp.me.now()
	$comment.user:=cs:C1710.sfw_userManager.me.info.login
	$comment.message:=""
	$comment.level:=1
	$comment.add:=True:C214
	$comment.expand:=1
	Form:C1466.comments.unshift($comment)
	This:C1470._drawCommentContainer()
	POST CLICK:C466(90; 90)  //no other choice at this moment :-(
	BRING TO FRONT:C326(Current process:C322)
	
	
Function bAction()
	$refMenus:=New collection:C1472
	$refMenu:=Create menu:C408
	$refMenus.push($refMenu)
	
	APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("comment.expandAll"; "Expand all"); *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--expandAll")
	APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("comment.collapseAll"; "Collapse all"); *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--collapseAll")
	
	$refSubMenu:=Create menu:C408
	$refMenus.push($refSubMenu)
	$i:=-1
	For each ($level; This:C1470.levels)
		$i+=1
		APPEND MENU ITEM:C411($refSubMenu; ds:C1482.sfw_readXliff("comment.level."+Lowercase:C14(This:C1470.levels[$level].label); This:C1470.levels[$level].label); *)
		SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "level:"+String:C10($i))
	End for each 
	APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("comment.limitToLevel"; "Limit to level"); $refSubMenu; *)
	
	$choice:=Dynamic pop up menu:C1006($refMenu)
	For each ($refMenu; $refMenus)
		RELEASE MENU:C978($refMenu)
	End for each 
	
	Case of 
		: ($choice="--expandAll")
			For each ($comment; Form:C1466.comments)
				$comment.expand:=1
			End for each 
			cs:C1710.sfw_commentManager.me._drawCommentContainer()
		: ($choice="--collapseAll")
			For each ($comment; Form:C1466.comments)
				$comment.expand:=0
			End for each 
			cs:C1710.sfw_commentManager.me._drawCommentContainer()
		: ($choice="level:@")
			Form:C1466.levelFilter:=Num:C11(Split string:C1554($choice; ":").pop())
			cs:C1710.sfw_commentManager.me._drawCommentContainer()
			
	End case 
	
Function subFormMethod()
	
	Case of 
		: (FORM Event:C1606.code=On Clicked:K2:4) && (FORM Event:C1606.objectName="pup_priority_0")
			
			$refMenu:=Create menu:C408
			For each ($attributeName; This:C1470.levels)
				APPEND MENU ITEM:C411($refMenu; This:C1470.levels[$attributeName].label)
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; $attributeName)
			End for each 
			$choice:=Dynamic pop up menu:C1006($refMenu)
			RELEASE MENU:C978($refMenu)
			Case of 
				: ($choice#"")
					Form:C1466.messages[0].level:=Num:C11($choice)
					OBJECT SET RGB COLORS:C628(*; "header_bkgd_0"; This:C1470.levels[$choice].header; This:C1470.levels[$choice].header)
					OBJECT SET RGB COLORS:C628(*; "message_bkgd_0"; This:C1470.levels[$choice].body; This:C1470.levels[$choice].body)
					OBJECT SET TITLE:C194(*; "pup_priority_0"; ds:C1482.sfw_readXliff("comment.priority"; "Priority")+": "+ds:C1482.sfw_readXliff("comment.level."+Lowercase:C14(This:C1470.levels[$choice].label); This:C1470.levels[$choice].label))
			End case 
			
			
			
		: (FORM Event:C1606.code=On Load:K2:1)
			If (Form:C1466.comments.length>0) && (Form:C1466.comments[0].add)
				GOTO OBJECT:C206(*; "message_0")
				CALL SUBFORM CONTAINER:C1086(-2001)
			End if 
			
		: (FORM Event:C1606.code=On Clicked:K2:4) & (FORM Event:C1606.objectName="bExpand_@")
			CALL SUBFORM CONTAINER:C1086(-2000)
			
			
	End case 
	
	OBJECT GET BEST SIZE:C717(*; "pup_priority_0"; $bestWidth; $bestHeight; 200)
	OBJECT GET COORDINATES:C663(*; "pup_priority_0"; $g; $h; $d; $b)
	OBJECT SET COORDINATES:C1248(*; "pup_priority_0"; $g; $h; $g+$bestWidth+3; $b)
	
	
Function _displayHeaderTabComment()
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.sfw.entry.comment#Null:C1517)
		$nb:=ds:C1482.sfw_getNbComments(Form:C1466.current_item.UUID)
		Case of 
			: ($nb=0)
				$title:=ds:C1482.sfw_readXliff("commentPalette.no"; Form:C1466.sfw.entry.comment.unit0)
				
			: ($nb=1)
				$title:=ds:C1482.sfw_readXliff("commentPalette.one"; Form:C1466.sfw.entry.comment.unit1)
				
			Else 
				$title:=String:C10($nb)+" "+ds:C1482.sfw_readXliff("commentPalette.comments"; Form:C1466.sfw.entry.comment.unitN)
				
		End case 
		OBJECT SET VALUE:C1742("headerTabComment_title"; $title)
	End if 
	$commentTabVisible:=(Form:C1466.current_item#Null:C1517) && (Form:C1466.sfw.entry.comment#Null:C1517)
	OBJECT SET VISIBLE:C603(*; "headerTabComment@"; $commentTabVisible)
	Form:C1466.sfw.arrangeHeaderTabs()
	
	
Function clicOnHeader($uuid_target : Text)
	cs:C1710.sfw_tracker.me.internal("comment clic on header : "+Get window title:C450)
	If (This:C1470.window#0)
		SHOW WINDOW:C435(This:C1470.window)
	End if 
	WINDOW LIST:C442($_refWindows; *)
	If (This:C1470.window=0) || (Find in array:C230($_refWindows; This:C1470.window)<0)
		This:C1470.launch()
	End if 
	DELAY PROCESS:C323(Current process:C322; 10)
	SHOW WINDOW:C435(This:C1470.window)
	CALL FORM:C1391(This:C1470.window; Formula:C1597(cs:C1710.sfw_commentManager.me._displayComments($1)); $uuid_target)
	
	
shared Function refresh($uuid_target : Text)
	cs:C1710.sfw_tracker.me.internal("comments refresh : "+Get window title:C450)
	This:C1470.callingWindow:=Current form window:C827
	If (This:C1470.window#0)
		SHOW WINDOW:C435(This:C1470.window)
	End if 
	WINDOW LIST:C442($_refWindows; *)
	If (This:C1470.window#0) && (Find in array:C230($_refWindows; This:C1470.window)>0)
		SHOW WINDOW:C435(This:C1470.window)
		CALL FORM:C1391(This:C1470.window; Formula:C1597(cs:C1710.sfw_commentManager.me._displayComments($1)); $uuid_target)
	End if 
	
	
Function hide()
	cs:C1710.sfw_tracker.me.internal("comments hide : "+Get window title:C450)
	WINDOW LIST:C442($_refWindows; *)
	If (This:C1470.window#0) && (Find in array:C230($_refWindows; This:C1470.window)>0)
		HIDE WINDOW:C436(This:C1470.window)
	End if 
	
	
Function _displayComments($uuid_target : Text)
	var $esComments : cs:C1710.sfw_CommentSelection
	var $eComment : cs:C1710.sfw_CommentEntity
	Form:C1466.UUID_target:=$uuid_target
	Form:C1466.comments:=New collection:C1472
	$esComments:=ds:C1482.sfw_Comment.query("UUID_target = :1 order by stmp desc"; $uuid_target)
	For each ($eComment; $esComments)
		$comment:=New object:C1471
		$comment.stmp:=$eComment.stmp
		If ($eComment.user#Null:C1517)
			If (cs:C1710.sfw_definition.me.globalParameters.linkedPathToNameFormUserEntity=Null:C1517)
				$eComment.user:=$eEvent.user.fullName
			Else 
				$source:=$eEvent.user
				$pathParts:=Split string:C1554(cs:C1710.sfw_definition.me.globalParameters.linkedPathToNameFormUserEntity; ".")
				$lastAttribute:=$pathParts.pop()
				For each ($pathPart; $pathParts)
					If ($pathPart="@()")
						$source:=$source[Substring:C12($pathPart; 1; Length:C16($pathPart)-2)]()
					Else 
						$source:=$source[$pathPart]
					End if 
				End for each 
				$eComment.user:=$source[$lastAttribute]
			End if 
		Else 
			$comment.user:=""
		End if 
		$comment.message:=$eComment.comment
		$comment.level:=$eComment.ID_level
		$comment.expand:=1
		Form:C1466.comments.push($comment)
	End for each 
	This:C1470._drawCommentContainer()
	This:C1470._activateAddButton()
	