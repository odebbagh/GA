$refMenu:=Create menu:C408

APPEND MENU ITEM:C411($refMenu; "Open in new window"; *)
SET MENU ITEM PARAMETER:C1004($refMenu; -1; "openInWindow")
If (Form:C1466.current_project=Null:C1517)
	DISABLE MENU ITEM:C150($refMenu; -1)
End if 


$choice:=Dynamic pop up menu:C1006($refMenu)
RELEASE MENU:C978($refMenu)

Case of 
	: ($choice="openInWindow")
		Form:C1466.sfw.openInANewWindow(Form:C1466.current_project; "projectManagment"; "project")
End case 