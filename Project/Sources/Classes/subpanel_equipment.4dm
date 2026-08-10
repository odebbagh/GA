singleton Class constructor
	
	//It's a singleton class
	
	
Function formMethod()
	
	
	If (Form:C1466#Null:C1517)
		
		//cs.sub_panel_cipInput.me.formMethod()
		
		var $rebuildForm : Boolean
		
		Case of 
			: (FORM Event:C1606.code=On Load:K2:1)
				$rebuildForm:=True:C214
				
				
			: (FORM Event:C1606.code=On Bound Variable Change:K2:52)
				$rebuildForm:=True:C214
				
				
			: (FORM Event:C1606.code=On Data Change:K2:15)
				
				
			Else 
				
				
		End case 
		
		If ($rebuildForm)
			$isInModification:=sfw_checkIsInModification
			
			If ($isInModification)
				OBJECT SET ENTERABLE:C238(*; "entryField@"; True:C214)
				
			Else 
				OBJECT SET ENTERABLE:C238(*; "entryField@"; False:C215)
			End if 
			
			If (Form:C1466.current_item#Null:C1517)
				OBJECT SET TITLE:C194(*; "statusHistory"; String:C10(Form:C1466.current_item.statusHistory))
			End if 
			OBJECT SET VISIBLE:C603(*; "Rectangl@"; $isInModification)
			
			
		End if 
		
	End if 
	
	
	