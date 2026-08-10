Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		
		//cs.panel_planning.me.showDetailsForm()
		
		If (Form:C1466.stepRow#Null:C1517) && (Contextual click:C713)
			
			var $lotStepEntity : cs:C1710.LotStepEntity
			var $sfwInstance : cs:C1710.sfw
			
			$sfwInstance:=cs:C1710.sfw.new()
			$lotStepEntity:=Form:C1466.stepRow
			
			//$actions:=New collection()
			//$actions:=$lotStepEntity.getPossibleActions()
			
			//$refMenu:=Create menu
			
			//For ($i; 1; $actions.length)
			//APPEND MENU ITEM($refMenu; $actions[$i-1])
			//SET MENU ITEM PARAMETER($refMenu; $i; "--"+Replace string($actions[$i-1]; " "; ""))
			//End for 
			
			$refMenu:=Create menu:C408
			
			APPEND MENU ITEM:C411($refMenu; "Punch In")
			SET MENU ITEM PARAMETER:C1004($refMenu; 1; "--PunchIn")
			
			APPEND MENU ITEM:C411($refMenu; "Punch Out")
			SET MENU ITEM PARAMETER:C1004($refMenu; 2; "--PunchOut")
			
			$choose:=Dynamic pop up menu:C1006($refMenu)
			Case of 
				: ($choose="--PunchIn")
					$sfwInstance.openInANewWindow(Form:C1466.stepRow; "production"; "punchIn")
				: ($choose="--PunchOut")
					$sfwInstance.openInANewWindow(Form:C1466.stepRow; "production"; "punchOut")
			End case 
			
		End if 
		
		//$inModification:=sfw_checkIsInModification & (Form.stepRow#Null)
		
		//OBJECT SET ENABLED(*; "btn_move_first"; $inModification)
		//OBJECT SET ENABLED(*; "btn_move_up"; $inModification)
		//OBJECT SET ENABLED(*; "btn_move_down"; $inModification)
		//OBJECT SET ENABLED(*; "btn_move_last"; $inModification)
		//OBJECT SET ENABLED(*; "btn_delete_row"; $inModification)
		
End case 
