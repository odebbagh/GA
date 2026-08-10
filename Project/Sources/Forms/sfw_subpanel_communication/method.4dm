var $file : 4D:C1709.File

$inModification:=sfw_checkIsInModification
$setActivation:=False:C215
$rebuildDisplayedLB:=False:C215
If (Form:C1466#Null:C1517) && (Form:C1466.communicationTypes=Null:C1517)
	$file:=Folder:C1567(fk resources folder:K87:11).file("sfw/communication/communicationTypes.json")
	If ($file.exists)
		$json:=$file.getText()
		Form:C1466.communicationTypes:=JSON Parse:C1218($json)
		For each ($type; Form:C1466.communicationTypes)
			$file:=Folder:C1567(fk resources folder:K87:11).file("sfw/communication/"+$type.icon)
			$blob:=$file.getContent()
			BLOB TO PICTURE:C682($blob; $pict; ".png")
			$type.displayedIcon:=$pict
		End for each 
		
	End if 
End if 

Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		$setActivation:=True:C214
		$rebuildDisplayedLB:=True:C214
		
		
	: (FORM Event:C1606.code=On Bound Variable Change:K2:52)
		$setActivation:=True:C214
		$rebuildDisplayedLB:=True:C214
		
	: (FORM Event:C1606.code=On Data Change:K2:15)
		Case of 
			: (FORM Event:C1606.columnName="col_contact")
				Form:C1466.communications[Form:C1466.communicationMeanPosition-1].contact:=Form:C1466.communicationMean.contact
			: (FORM Event:C1606.columnName="col_comment")
				Form:C1466.communications[Form:C1466.communicationMeanPosition-1].comment:=Form:C1466.communicationMean.comment
		End case 
		CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
		
		
	: (FORM Event:C1606.code=On Clicked:K2:4) && (FORM Event:C1606.objectName="bActions")
		$refMenus:=New collection:C1472
		$mainMenu:=Create menu:C408
		$refMenus.push($mainMenu)
		
		APPEND MENU ITEM:C411($mainMenu; ds:C1482.sfw_readXliff("communication.add"; "Add a communication means"); *)
		SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--add")
		If (sfw_checkIsInModification)=False:C215
			DISABLE MENU ITEM:C150($mainMenu; -1)
		End if 
		
		APPEND MENU ITEM:C411($mainMenu; ds:C1482.sfw_readXliff("communication.delete"; "Delete a communication means"); *)
		SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--delete")
		If (sfw_checkIsInModification)=False:C215
			DISABLE MENU ITEM:C150($mainMenu; -1)
		Else 
			If (Form:C1466.communicationMean=Null:C1517)
				DISABLE MENU ITEM:C150($mainMenu; -1)
			End if 
		End if 
		
		
		
		OBJECT GET COORDINATES:C663(*; "bActions"; $g; $h; $d; $b)
		CONVERT COORDINATES:C1365($g; $b; XY Current form:K27:5; XY Current window:K27:6)
		$choose:=Dynamic pop up menu:C1006($mainMenu; ""; $g; $b)
		For each ($refMenu; $refMenus)
			RELEASE MENU:C978($refMenu)
		End for each 
		Case of 
			: ($choose="")
			: ($choose="--delete")
				Form:C1466.communications.remove(Form:C1466.communicationMeanPosition-1)
				$rebuildDisplayedLB:=True:C214
				CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
			: ($choose="--add")
				Form:C1466.communications.push(New object:C1471("type"; Form:C1466.communicationTypes[0].type))
				$rebuildDisplayedLB:=True:C214
				CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
				
		End case 
		
	: (FORM Event:C1606.code=On Clicked:K2:4)
		
		If (FORM Event:C1606.columnName="col_type") && ($inModification) && (Form:C1466.communicationMeanPosition>0)
			$refMenus:=New collection:C1472
			$mainMenu:=Create menu:C408
			$refMenus.push($mainMenu)
			
			For each ($type; Form:C1466.communicationTypes)
				APPEND MENU ITEM:C411($mainMenu; ds:C1482.sfw_readXliff("communication."+Replace string:C233(Lowercase:C14($type.label); " "; ""); $type.label); *)
				SET MENU ITEM PARAMETER:C1004($mainMenu; -1; $type.type)
				SET MENU ITEM ICON:C984($mainMenu; -1; "path:/RESOURCES/sfw/communication/"+$type.icon)
			End for each 
			$choose:=Dynamic pop up menu:C1006($mainMenu)
			For each ($refMenu; $refMenus)
				RELEASE MENU:C978($refMenu)
			End for each 
			Case of 
				: ($choose="")
				Else 
					
					Form:C1466.communications[Form:C1466.communicationMeanPosition-1].type:=$choose
					$rebuildDisplayedLB:=True:C214
					
					CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
			End case 
			
		End if 
		
End case 

//OBJECT SET ENTERABLE(*; "col_@"; False)
If ($setActivation)
	OBJECT SET ENTERABLE:C238(*; "col_contact"; $inModification)
	OBJECT SET ENTERABLE:C238(*; "col_comment"; $inModification)
End if 

If ($rebuildDisplayedLB)
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($width_subform; $height_subform)
	OBJECT SET COORDINATES:C1248(*; "communication_bkgd"; 0; 0; $width_subform; $height_subform)
	OBJECT GET COORDINATES:C663(*; "bActions"; $g; $h; $d; $b)
	$heightButton:=$b-$h
	$verticalMargin:=5
	$horizontalMargin:=5
	OBJECT SET COORDINATES:C1248(*; "bActions"; $horizontalMargin; $height_subform-$verticalMargin-$heightButton; $horizontalMargin+$d-$g; $height_subform-$verticalMargin)
	OBJECT SET COORDINATES:C1248(*; "lb_communications"; $horizontalMargin; $verticalMargin; $width_subform-$horizontalMargin; $height_subform-$verticalMargin-$heightButton-$verticalMargin)
	
	
	If (Form:C1466#Null:C1517)
		Form:C1466.lb_communications:=New collection:C1472
		For each ($mean; Form:C1466.communications)
			$item:=New object:C1471
			$item.contact:=$mean.contact
			$item.comment:=$mean.comment
			$item.type:=$mean.type || "phone"
			$indices:=Form:C1466.communicationTypes.indices("type = :1"; $item.type)
			If ($indices.length>0)
				$item.displayedType:=Form:C1466.communicationTypes[$indices[0]].label
				$item.displayedIcon:=Form:C1466.communicationTypes[$indices[0]].displayedIcon
			End if 
			Form:C1466.lb_communications.push($item)
		End for each 
	End if 
End if 