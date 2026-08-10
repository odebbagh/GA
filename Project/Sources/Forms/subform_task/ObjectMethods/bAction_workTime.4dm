
$refMenus:=New collection:C1472

$refMenu:=Create menu:C408
$refMenus.push($refMenu)
APPEND MENU ITEM:C411($refMenu; "Open in new window")
//If (Form.current_taskTime#Null)
SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--modifyTaskTime")
//Else 
DISABLE MENU ITEM:C150($refMenu; -1)
//End if 

APPEND MENU ITEM:C411($refMenu; "-")

APPEND MENU ITEM:C411($refMenu; "Add a new task time")
SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--addTaskTime")
SET MENU ITEM SHORTCUT:C423($refMenu; -1; "+"; Command key mask:K16:1)
//If (Not(sfw_checkIsInModification))
//DISABLE MENU ITEM($refMenu; -1)
//End if 

$choice:=Dynamic pop up menu:C1006($refMenu)
For each ($ref; $refMenus)
	RELEASE MENU:C978($ref)
End for each 

Case of 
	: ($choice="--modifyTaskTime")
		Form:C1466.sfw.openInANewWindow(Form:C1466.current_taskTime; "projectManagment"; "taskTime")
		
	: ($choice="--addTaskTime")
		Form:C1466.current_item.addNewTaskTime()
End case 

