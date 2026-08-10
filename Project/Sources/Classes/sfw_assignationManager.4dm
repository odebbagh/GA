property pictos : Object
property targetedMe : Collection
singleton Class constructor
	
	This:C1470.pictos:=New object:C1471
	For each ($type; Split string:C1554("exclamation-circle;exclamation-red;tick;calendar;calendar-user"; ";"))
		$file:=Folder:C1567(fk resources folder:K87:11).file("sfw/image/picto/"+$type+".png")
		READ PICTURE FILE:C678($file.platformPath; $pict)
		This:C1470.pictos[$type]:=$pict
	End for each 
	This:C1470.targetedMe:=[cs:C1710.sfw_userManager.me.info.UUID].concat(ds:C1482.sfw_UserInscription.query("UUID_User = :1"; cs:C1710.sfw_userManager.me.info.UUID).extract("UUID_UserProfile"))
	
Function clicOnHeader
	
	
	OBJECT GET COORDINATES:C663(*; "headerTabAssignation_bkgdbottom"; $g; $h; $d; $b)
	CONVERT COORDINATES:C1365($g; $b; XY Current form:K27:5; XY Main window:K27:8)
	$formData:=New object:C1471
	$formData.current_item:=Form:C1466.current_item
	$formData.entry:=Form:C1466.sfw.entry
	$refWindow:=Open form window:C675("sfw_assignation"; Pop up form window:K39:11; $g; $b)
	DIALOG:C40("sfw_assignation"; $formData)
	CLOSE WINDOW:C154($refWindow)
	
	If (ok=1)
		This:C1470._displayHeaderTabAssignation()
	End if 
	
	
Function _displayHeaderTabAssignation()
	If (Form:C1466.current_item#Null:C1517) && (Bool:C1537(Form:C1466.sfw.entry.allowAssignation))
		$assignationTabVisible:=(Form:C1466.current_item#Null:C1517) && (Bool:C1537(Form:C1466.sfw.entry.allowSubscription))
		OBJECT SET VISIBLE:C603(*; "headerTabAssignation@"; $assignationTabVisible)
		If ($assignationTabVisible)
			$summary:=ds:C1482.sfw_Todo.assignationsSummaryForTab(Form:C1466.current_item.UUID; Form:C1466.sfw.entry.ident; cs:C1710.sfw_userManager.me.info.UUID)
			$title:=($summary.nbTodo=0) ? ds:C1482.sfw_readXliff("assignation.addAssignation"; "Assignation") : ds:C1482.sfw_readXliff("assignation.hasAssignation"; "Added assignations")
			OBJECT SET HELP TIP:C1181(*; "headerTabAssignation_button"; $title)
			If ($summary.nbTodo#0)
				Case of 
					: ($summary.notAchived) && ($summary.concernMe)
						$variation:="red-exclamation"
					: ($summary.notAchived)
						$variation:="red"
					: ($summary.concernMe)
						$variation:="green"
					Else 
						$variation:="blue"
				End case 
			End if 
			$format:=($summary.nbTodo=0) ? ";path:/RESOURCES/sfw/image/picto/task.png;;4;1;1;4;0;0;0;0;0;1;1" : ";path:/RESOURCES/sfw/image/picto/task-"+$variation+".png;;4;1;1;4;0;0;0;0;0;1;1"
			OBJECT SET FORMAT:C236(*; "headerTabAssignation_button"; $format)
		End if 
	Else 
		OBJECT SET VISIBLE:C603(*; "headerTabAssignation@"; False:C215)
	End if 
	
	Form:C1466.sfw.arrangeHeaderTabs()
	
	
	
Function metaldAssignations($eTodo : cs:C1710.sfw_TodoEntity)->$meta : Object
	
	$meta:=New object:C1471("cell"; New object:C1471)
	$meta.fontWeight:=($eTodo.achievedStmp#0) ? "normal" : "bold"
	If (This:C1470.targetedMe.indexOf($eTodo.UUID_targetAssigned)#-1)
		$meta.cell.columnAssignatedName:=$meta.cell.columnAssignatedName || New object:C1471
		$meta.cell.columnAssignatedName.stroke:=($eTodo.UUID_targetAssigned=cs:C1710.sfw_userManager.me.info.UUID) ? "red" : "blue"
		$meta.cell.columnAssignatedName.fill:="wheat"
	End if 
	
Function symbol($eTodo : cs:C1710.sfw_TodoEntity)->$picto : Picture
	
	Case of 
		: ($eTodo.achievedStmp#0)
			$picto:=This:C1470.pictos["tick"]
		: ($eTodo.achievedStmp=0) && ($eTodo.deadlineStmp#0) && ($eTodo.deadlineStmp<cs:C1710.sfw_stmp.me.now()) && (This:C1470.targetedMe.indexOf($eTodo.UUID_targetAssigned)#-1)
			$picto:=This:C1470.pictos["exclamation-red"]
		: ($eTodo.achievedStmp=0) && ($eTodo.deadlineStmp#0) && ($eTodo.deadlineStmp<cs:C1710.sfw_stmp.me.now())
			$picto:=This:C1470.pictos["exclamation-circle"]
		: ($eTodo.achievedStmp=0) && ($eTodo.deadlineStmp#0) && (This:C1470.targetedMe.indexOf($eTodo.UUID_targetAssigned)#-1)
			$picto:=This:C1470.pictos["calendar-user"]
		: ($eTodo.achievedStmp=0) && ($eTodo.deadlineStmp#0)
			$picto:=This:C1470.pictos["calendar"]
	End case 
	
	
Function fullDescription($eTodo : cs:C1710.sfw_TodoEntity)->$fullDescription : Text
	
	$fullDescription:=$eTodo.description
	$fullDescription+="\r\r"
	$fullDescription+=ds:C1482.sfw_readXliff("assignationManager.assignatedby")+": "+$eTodo.creatorName  //okxliff
	$fullDescription+="\r"
	$fullDescription+=ds:C1482.sfw_readXliff("assignationManager.assignateddate")+": "+cs:C1710.sfw_stmp.me.getFullRelative($eTodo.stmp)  //okxliff
	$fullDescription+="\r"
	$fullDescription+=ds:C1482.sfw_readXliff("assignationManager.assignatedto")+": "+$eTodo.assignedName  //okxliff
	$fullDescription+="\r"
	If ($eTodo.deadlineStmp=0)
		$fullDescription+=ds:C1482.sfw_readXliff("assignationManager.nodeadline")  //okxliff
	Else 
		$fullDescription+=ds:C1482.sfw_readXliff("assignationManager.deadline")+": "+cs:C1710.sfw_stmp.me.getFullRelative($eTodo.deadlineStmp)  //okxliff
	End if 
	$fullDescription+="\r"
	If ($eTodo.achievedStmp=0)
		$fullDescription+=ds:C1482.sfw_readXliff("assignationManager.notachived")  //okxliff
	Else 
		$fullDescription+=ds:C1482.sfw_readXliff("assignationManager.achived")+": "+cs:C1710.sfw_stmp.me.getFullRelative($eTodo.achievedStmp)  //okxliff
	End if 
	