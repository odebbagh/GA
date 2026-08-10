Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Form:C1466.current_item.onHold)
			
			var $defaults : Object
			var $form : Object
			
			$refMenu:=Create menu:C408
			
			APPEND MENU ITEM:C411($refMenu; "Non-Conforming Material Notice")
			SET MENU ITEM PARAMETER:C1004($refMenu; 1; "--NCMN")
			
			APPEND MENU ITEM:C411($refMenu; "Internal Start-Stop Notification Form")
			SET MENU ITEM PARAMETER:C1004($refMenu; 2; "--ISSNF")
			
			$defaults:=New object:C1471(\
				"customer"; Form:C1466.current_item.job.customer.name; \
				"lotNumber"; String:C10(Form:C1466.current_item.number)\
				)
			
			$choose:=Dynamic pop up menu:C1006($refMenu)
			Case of 
				: ($choose="--NCMN")
					$form:=LotHoldForm_resolveForm(Form:C1466.current_item; "NCMN"; $defaults)
					
					$winRef:=Open form window:C675("NCMN"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
					DIALOG:C40("NCMN"; $form)
					CLOSE WINDOW:C154($winRef)
					
					If (OK=1)
						LotHoldForm_saveForm(Form:C1466.current_item; "NCMN"; $form)
						Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
					End if 
					
				: ($choose="--ISSNF")
					$form:=LotHoldForm_resolveForm(Form:C1466.current_item; "ISSNF"; $defaults)
					
					$winRef:=Open form window:C675("ISSNF"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
					DIALOG:C40("ISSNF"; $form)
					CLOSE WINDOW:C154($winRef)
					
					If (OK=1)
						LotHoldForm_saveForm(Form:C1466.current_item; "ISSNF"; $form)
						Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
					End if 
			End case 
			
		Else 
			
		End if 
End case 
