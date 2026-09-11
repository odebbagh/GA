

$refMenus:=New collection:C1472
$mainMenu:=Create menu:C408
$refMenus.push($mainMenu)

APPEND MENU ITEM:C411($mainMenu; "Add a team member"; *)
SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--add")
If (sfw_checkIsInModification)=False:C215
	DISABLE MENU ITEM:C150($mainMenu; -1)
End if 

APPEND MENU ITEM:C411($mainMenu; "Delete a team member"; *)
SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--delete")
If (sfw_checkIsInModification)=False:C215
	DISABLE MENU ITEM:C150($mainMenu; -1)
Else 
	If (Form:C1466.auditMember=Null:C1517)
		DISABLE MENU ITEM:C150($mainMenu; -1)
	End if 
End if 


OBJECT GET COORDINATES:C663(*; "bActionTeam"; $g; $h; $d; $b)
CONVERT COORDINATES:C1365($g; $b; XY Current form:K27:5; XY Current window:K27:6)
$choose:=Dynamic pop up menu:C1006($mainMenu; ""; $g; $b)
For each ($refMenu; $refMenus)
	RELEASE MENU:C978($refMenu)
End for each 

Case of 
	: ($choose="")
	: ($choose="--delete")
		Form:C1466.lb_teamMembers.remove(Form:C1466.auditMemberPosition-1)
		//Form.current_item.auditTeam.teamMembers:=Form.lb_teamMembers
		
		Form:C1466.correctiveActionReport.teamMembers:=Form:C1466.lb_teamMembers.extract("fullName").join("\n")
		
		
	: ($choose="--add")
		
		Case of 
			: (FORM Event:C1606.code=On Clicked:K2:4) & (sfw_checkIsInModification)
				
				$form:=New object:C1471
				
				$winRef:=Open form window:C675("_ga_addSingleTeamMember"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
				DIALOG:C40("_ga_addSingleTeamMember"; $form)
				
				//$answer:=cs.sfw_dialog.me.request("Enter Disposition value"; Form.current_item.moreData.disposition; "Save"; "Cancel"; "trimSpace")
				
				//If ($answer.ok) & ($answer.answer#"")
				If (OK=1)
					Form:C1466.lb_teamMembers.push($form)
					Form:C1466.correctiveActionReport.teamMembers:=Form:C1466.lb_teamMembers.extract("fullName").join("\n")
					
					//If (Form.correctiveActionReport.teamMembers="")
					//Form.correctiveActionReport.teamMembers:=$form.teamMemberName  //$answer.answer
					//Else 
					//Form.correctiveActionReport.teamMembers:=Form.correctiveActionReport.teamMembers+Char(Carriage return)+$form.teamMemberName  //$answer.answer
					//End if 
					
				End if 
				//End if 
			: (FORM Event:C1606.code=On Mouse Enter:K2:33)
				SET CURSOR:C469(Choose:C955(sfw_checkIsInModification; 9000; 9019))
				
		End case 
		
End case 

