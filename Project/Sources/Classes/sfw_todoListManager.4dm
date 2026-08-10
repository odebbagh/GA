property todoListWorkerName : Text
property currentToolbarWindowRef : Integer
property currentWizardWindowRef : Integer

singleton Class constructor
	
	This:C1470.currentToolbarWindowRef:=0
	This:C1470.currentWizardWindowRef:=0
	This:C1470.todoListWorkerName:="todoListWorker"
	
	
	
Function openWizardtodoList()
	var $eTodo : cs:C1710.sfw_TodoEntity
	var $dateToHighlight : Object
	
	If (This:C1470.currentWizardWindowRef=0)
		$dialogName:="sfw_wizard_todoList"
		$windowType:=Plain form window:K39:10
		$formData:=New object:C1471
		$formData.lb_todoList:=This:C1470.loadtodoList()
		$formData.calendarPicker:=New object:C1471("calendar"; New object:C1471("display"; New object:C1471("date"; Current date:C33)))
		$formData.calendarPicker.calendar.display.datesToHighlight:=New collection:C1472
		For each ($eTodo; $formData.lb_todoList)
			$date:=cs:C1710.sfw_stmp.me.getDate($eTodo.deadlineStmp)
			Case of 
				: ($eTodo.achievedStmp#0)
					$dateToHighlight:=$formData.calendarPicker.calendar.display.datesToHighlight.query("date = :1"; $date).first()
					If ($dateToHighlight=Null:C1517)
						$dateToHighlight:=New object:C1471
						$dateToHighlight.date:=$date
						$dateToHighlight.color:="cyan"
						$formData.calendarPicker.calendar.display.datesToHighlight.push($dateToHighlight)
					End if 
				: ($eTodo.deadlineStmp#0) && (Current date:C33<$date)
					$dateToHighlight:=$formData.calendarPicker.calendar.display.datesToHighlight.query("date = :1"; $date).first()
					If ($dateToHighlight=Null:C1517)
						$dateToHighlight:=New object:C1471
						$dateToHighlight.date:=$date
						$formData.calendarPicker.calendar.display.datesToHighlight.push($dateToHighlight)
					End if 
					If ($dateToHighlight.color#"salmon")
						$dateToHighlight.color:="orange"
					End if 
				: ($eTodo.deadlineStmp#0)
					$dateToHighlight:=$formData.calendarPicker.calendar.display.datesToHighlight.query("date = :1"; $date).first()
					If ($dateToHighlight=Null:C1517)
						$dateToHighlight:=New object:C1471
						$dateToHighlight.date:=$date
						$formData.calendarPicker.calendar.display.datesToHighlight.push($dateToHighlight)
					End if 
					$dateToHighlight.color:="salmon"
			End case 
		End for each 
		This:C1470.currentWizardWindowRef:=cs:C1710.sfw_window.me.openFormWindow($dialogName; $windowType)
		DIALOG:C40($dialogName; $formData)
		cs:C1710.sfw_window.me.closeWindow(This:C1470.currentWizardWindowRef)
		This:C1470.currentWizardWindowRef:=0
	Else 
		BRING TO FRONT:C326(Current process:C322)
	End if 
	
Function formMethod()
	
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			Form:C1466.sfw:=cs:C1710.sfw_foundations.new()
			Form:C1466.current_todo:=Null:C1517
			
		: (FORM Event:C1606.code=On Selection Change:K2:29) && (FORM Event:C1606.objectName="lb_todoList")
			
			GET WINDOW RECT:C443($gw; $hw; $dw; $bw)
			If (Form:C1466.current_todo=Null:C1517)
				OBJECT GET COORDINATES:C663(*; "bkgd_middle"; $g; $h; $d; $b)
				LISTBOX SELECT ROW:C912(*; "lb_todoList"; 0; lk remove from selection:K53:3)
			Else 
				OBJECT GET COORDINATES:C663(*; "bkgd_bottom"; $g; $h; $d; $b)
				This:C1470.loadDescription()
			End if 
			If (($bw-$hw)#$b)
				SET WINDOW RECT:C444($gw; $hw; $dw; $hw+$b)
			End if 
			
	End case 
	
Function loadtodoList()->$esTodo : cs:C1710.sfw_TodoSelection
	
	$esTodo:=ds:C1482.sfw_Todo.query("UUID_targetAssigned = :1 order by achievedStmp, deadlineStmp desc"; cs:C1710.sfw_userManager.me.info.UUID)
	
Function loadDescription()
	
	Form:C1466.description:=Form:C1466.current_todo.description
	Form:C1466.description+="\r\r"
	Form:C1466.description+=ds:C1482.sfw_readXliff("assignationManager.assignatedby")+": "+Form:C1466.current_todo.creatorName  //okxliff
	Form:C1466.description+="\r"
	Form:C1466.description+=ds:C1482.sfw_readXliff("assignationManager.assignateddate")+": "+cs:C1710.sfw_stmp.me.getFullRelative(Form:C1466.current_todo.stmp)  //okxliff
	Form:C1466.description+="\r"
	Form:C1466.description+=ds:C1482.sfw_readXliff("assignationManager.assignatedto")+": "+Form:C1466.current_todo.assignedName  //okxliff
	Form:C1466.description+="\r"
	If (Form:C1466.current_todo.deadlineStmp=0)
		Form:C1466.description+=ds:C1482.sfw_readXliff("assignationManager.nodeadline")  //okxliff
	Else 
		Form:C1466.description+=ds:C1482.sfw_readXliff("assignationManager.deadline")+": "+String:C10(cs:C1710.sfw_stmp.me.getDate(Form:C1466.current_todo.deadlineStmp))  //okxliff
		Form:C1466.description+=ds:C1482.sfw_readXliff("assignationManager.at")+" "+String:C10(cs:C1710.sfw_stmp.me.getTime(Form:C1466.current_todo.deadlineStmp); HH MM:K7:2)  //okxliff
	End if 
	Form:C1466.description+="\r"
	If (Form:C1466.current_todo.achievedStmp=0)
		Form:C1466.description+=ds:C1482.sfw_readXliff("assignationManager.notachived")  //okxliff
	Else 
		Form:C1466.description+=ds:C1482.sfw_readXliff("assignationManager.achived")+": "+cs:C1710.sfw_stmp.me.getFullRelative(Form:C1466.current_todo.achievedStmp)  //okxliff
	End if 
	
	Form:C1466.achievedDate:=(Form:C1466.current_todo.achievedStmp#0) ? cs:C1710.sfw_stmp.me.getDate(Form:C1466.current_todo.achievedStmp) : Current date:C33
	Form:C1466.achievedTime:=(Form:C1466.current_todo.achievedStmp#0) ? cs:C1710.sfw_stmp.me.getTime(Form:C1466.current_todo.achievedStmp) : Current time:C178
	OBJECT SET VISIBLE:C603(*; "bAchieved"; (Form:C1466.current_todo.achievedStmp=0))
	
Function bAchieved()
	If (Form:C1466.current_todo#Null:C1517)
		Form:C1466.current_todo.achievedStmp:=cs:C1710.sfw_stmp.me.build(Form:C1466.achievedDate; Form:C1466.achievedTime)
		$info:=Form:C1466.current_todo.save()
		This:C1470.loadtodoList()
		Form:C1466.current_todo:=Null:C1517
		LISTBOX SELECT ROW:C912(*; "lb_todoList"; 0; lk remove from selection:K53:3)
	End if 
	
Function refreshtodoList()
	This:C1470.loadtodoList()
	$index:=Form:C1466.current_todoList.indexOf()
	If ($index>=0)
		LISTBOX SELECT ROW:C912(*; "lb_todoList"; $index+2; lk replace selection:K53:1)
	Else 
		Form:C1466.current_todoList:=Null:C1517
	End if 
	
Function bOpenRelatedRecord()
	$entity:=4D:C1709.Entity
	
	$entry:=cs:C1710.sfw_definition.me.entries.query("ident = :1"; Form:C1466.current_todoList.moreData.targetDataclass).first()
	$visionIdent:=$entry.visions[0]
	
	$entity:=ds:C1482[$entry.dataclass].get(Form:C1466.current_todoList.UUID_target)
	If ($entity=Null:C1517)
		$todoList:=ds:C1482.sfw_todoList.query("UUID_target =:1"; Form:C1466.current_todoList.UUID_target)
		$info:=$todoList.drop()
		cs:C1710.sfw_todoListManager.me.updateTodoList()
	Else 
		Form:C1466.sfw.openInANewWindow($entity; $visionIdent; $entry.ident)
	End if 
	
	
Function bValidatetodoList()
	
	Form:C1466.current_todoList.stmpOver:=cs:C1710.sfw_stmp.me.now()
	$info:=Form:C1466.current_todoList.save()
	This:C1470.updateTodoList()
	
	
Function getNbTodo()->$nbT : Text
	var $esTodo : cs:C1710.sfw_TodoSelection
	$summary:=ds:C1482.sfw_Todo.assignationsSummaryForToolbar(cs:C1710.sfw_userManager.me.info.UUID)
	
	$nb:=$summary.todoForMe
	If ($nb>99)
		$nbT:="99+"
	Else 
		$nbT:=String:C10($nb)
	End if 
	If ($summary.todoForMeLate#0)
		$nbT:="!"+$nbT
	End if 
	
Function notify($ident : Text; $users : Collection; $context : Object)
	ds:C1482.sfw_fireAndForgetFormula(Formula:C1597(cs:C1710.sfw_todoListManager.me._notify($1; $2; $3)); "todoListWorker"; $ident; $users; $context)
	
	
Function _notify($ident : Text; $users : Collection; $context : Object)
	var $etodoList : cs:C1710.sfw_TodoEntity
	
	//If ($context.targetDataclass#Null)
	//$esSubscriptions:=ds.sfw_Subscription.query("UUID_target = :1 and entryIdent = :2"; $context.target; $context.targetDataclass)
	//If ($esSubscriptions.length>0)
	//$users:=$users.concat($esSubscriptions.distinct("UUID_User")).distinct()
	//End if 
	//End if 
	
	//$etodoListType:=ds.sfw_todoListType.query("ident = :1"; $ident).first()
	////$staff:=ds.Staff.query("UUID_User = :1"; cs.sfw_userManager.me.info.UUID).first()
	//If ($etodoListType#Null)
	//For each ($user; $users)
	
	////If ($user#$staff.user.UUID)
	//$etodoList:=ds.sfw_todoList.new()
	//$etodoList.UUID:=Generate UUID
	//$etodoList.UUID_todoListType:=$etodoListType.UUID
	//$etodoList.UUID_User:=$user
	//$etodoList.UUID_target:=$context.target || ("0"*32)
	//$etodoList.stmp:=cs.sfw_stmp.me.now()
	//$etodoList.ID_level:=$context.level || 1
	//$etodoList.moreData:=New object
	//If ($context.targetDataclass#Null)
	//$etodoList.moreData.targetDataclass:=$context.targetDataclass
	//End if 
	//$etodoList.comment:=$etodoListType.description
	//For each ($attribute; $context)
	//If (Position("##"+$attribute+"##"; $etodoList.comment)>0)
	//$etodoList.comment:=Replace string($etodoList.comment; "##"+$attribute+"##"; String($context[$attribute]))
	//End if 
	//End for each 
	//$info:=$etodoList.save()
	//If ($info.success)
	//If (Application type=4D Server)
	//EXECUTE ON CLIENT("@"; "sfw_todoListUpdate")
	//Else 
	//sfw_todoListUpdate
	//End if 
	//End if 
	
	////End if 
	//End for each 
	//End if 
	
Function onStartup()
	
	If (Application type:C494#4D Remote mode:K5:5)
		
		
	End if 
	
	
Function setToolbarWindowRef($windowRef : Integer)
	
	This:C1470.currentToolbarWindowRef:=$windowRef
	
	
	//Function createTypeIfNotExist($ident : Text; $label : Text; $definition : cs.sfw_definitiontodoListType)
	
	//var $etodoListType : cs.sfw_todoListTypeEntity
	
	//$etodoListType:=ds.sfw_todoListType.query("ident = :1"; $ident).first()
	//If ($etodoListType=Null)
	//$etodoListType:=ds.sfw_todoListType.new()
	//$etodoListType.ident:=$ident
	//$etodoListType.label:=$label
	//$etodoListType.description:=String($definition.description)
	//$etodoListType.active:=Bool($definition.active)
	//$info:=$etodoListType.save()
	
	//End if 
	
Function updateTodoList()
	If (Bool:C1537(cs:C1710.sfw_definition.me.globalParameters.todoList.activate))
		If (This:C1470.currentToolbarWindowRef=0)
			This:C1470.currentToolbarWindowRef:=cs:C1710.sfw_window.me.toolbarWindowRef
		End if 
		If (This:C1470.currentToolbarWindowRef#0)
			CALL FORM:C1391(This:C1470.currentToolbarWindowRef; Formula:C1597(Form:C1466.sfw.displayToDoList()))
		End if 
		
		$window:=cs:C1710.sfw_window.me.windows.query("process.name = :1"; cs:C1710.sfw_todoListManager.me.todoListWorkerName).first()
		If ($window#Null:C1517)
			CALL FORM:C1391($window.reference; Formula:C1597(cs:C1710.sfw_todoListManager.me.refreshtodoList()))
		End if 
		
		
	End if 