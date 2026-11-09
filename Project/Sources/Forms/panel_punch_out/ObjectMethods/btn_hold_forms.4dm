Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Form:C1466.current_item.lot.onHold)
			
			var $defaults : Object
			var $form : Object
			var $lot : 4D:C1709.Entity
			
			$refMenu:=Create menu:C408
			
			APPEND MENU ITEM:C411($refMenu; "Non-Conforming Material Notice")
			SET MENU ITEM PARAMETER:C1004($refMenu; 1; "--NCMN")
			
			APPEND MENU ITEM:C411($refMenu; "Internal Start-Stop Notification Form")
			SET MENU ITEM PARAMETER:C1004($refMenu; 2; "--ISSNF")
			
			$defaults:=New object:C1471(\
				"customer"; Form:C1466.current_item.lot.job.customer.name; \
				"lotNumber"; String:C10(Form:C1466.current_item.lot.number)\
				)
			
			$choose:=Dynamic pop up menu:C1006($refMenu)
			Case of 
				: ($choose="--NCMN")
					$form:=LotHoldForm_resolveForm(Form:C1466.current_item.lot; "NCMN"; $defaults)
					
					$winRef:=Open form window:C675("NCMN"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
					DIALOG:C40("NCMN"; $form)
					CLOSE WINDOW:C154($winRef)
					
					If (OK=1)
						$lot:=Form:C1466.current_item.lot
						LotHoldForm_saveForm($lot; "NCMN"; $form)
						// the lot is a related record: saving the step does not save it, so it is saved now
						// (before this, the form only reached the database with the next hold / unhold)
						If (Not:C34(LotHoldForm_trySaveLot($lot).success))
							cs:C1710.sfw_dialog.me.alert("The lot record is locked: the NCMN could not be saved. Please free the lot record and try again.")
						End if 
						Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
					End if 
					
				: ($choose="--ISSNF")
					$form:=LotHoldForm_resolveForm(Form:C1466.current_item.lot; "ISSNF"; $defaults)
					
					$winRef:=Open form window:C675("ISSNF"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
					DIALOG:C40("ISSNF"; $form)
					CLOSE WINDOW:C154($winRef)
					
					If (OK=1)
						$lot:=Form:C1466.current_item.lot
						LotHoldForm_saveForm($lot; "ISSNF"; $form)
						// the lot is a related record: saving the step does not save it, so it is saved now
						// (before this, the form only reached the database with the next hold / unhold)
						If (Not:C34(LotHoldForm_trySaveLot($lot).success))
							cs:C1710.sfw_dialog.me.alert("The lot record is locked: the ISSNF could not be saved. Please free the lot record and try again.")
						End if 
						Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
					End if 
			End case 
			
		Else 
			
		End if 
End case 
