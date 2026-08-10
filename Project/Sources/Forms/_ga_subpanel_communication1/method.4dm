var $file : 4D:C1709.File

OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)


OBJECT GET COORDINATES:C663(*; "lb_communications"; $lb_left; $lb_top; $lb_right; $lb_bottom)
OBJECT GET COORDINATES:C663(*; "bActions"; $ba_left; $ba_top; $ba_right; $ba_bottom)
OBJECT GET COORDINATES:C663(*; "header_bkgd"; $hb_left; $hb_top; $hb_right; $hb_bottom)
OBJECT GET COORDINATES:C663(*; "communication_bkgd"; $cb_left; $cb_top; $cb_right; $cb_bottom)

$widthBa:=$ba_right-$ba_left

OBJECT SET COORDINATES:C1248(*; "lb_communications"; $lb_left; $lb_top; $widthSubform; $lb_bottom)
OBJECT SET COORDINATES:C1248(*; "bActions"; $widthSubform-$widthBa; $ba_top; $widthSubform-9; $ba_bottom)
OBJECT SET COORDINATES:C1248(*; "header_bkgd"; $hb_left; $hb_top; $widthSubform; $hb_bottom)
OBJECT SET COORDINATES:C1248(*; "communication_bkgd"; $cb_left; $cb_top; $widthSubform; $cb_bottom)

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
		
		//: (FORM Event.code=On Data Change)
		
		//Case of 
		//: (FORM Event.columnName="col_contact")
		//Form.communications[Form.communicationMeanPosition-1].contact:=Form.communicationMean.contact
		//: (FORM Event.columnName="col_comment")
		//Form.communications[Form.communicationMeanPosition-1].comment:=Form.communicationMean.comment
		//End case 
		//CALL FORM(Current form window; "sfw_main_draw_button")
		
		
	: (FORM Event:C1606.code=On Clicked:K2:4) && (FORM Event:C1606.objectName="bActions")
		$refMenus:=New collection:C1472
		$mainMenu:=Create menu:C408
		$refMenus.push($mainMenu)
		
		APPEND MENU ITEM:C411($mainMenu; "Add a communication means"; *)
		SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--add")
		If (sfw_checkIsInModification)=False:C215
			DISABLE MENU ITEM:C150($mainMenu; -1)
		End if 
		
		APPEND MENU ITEM:C411($mainMenu; "Delete a communication means"; *)
		SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--delete")
		If (sfw_checkIsInModification)=False:C215
			DISABLE MENU ITEM:C150($mainMenu; -1)
		Else 
			If (Form:C1466.communicationMean=Null:C1517)
				DISABLE MENU ITEM:C150($mainMenu; -1)
			End if 
		End if 
		
		APPEND MENU ITEM:C411($mainMenu; "modify a communication means"; *)
		SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--update")
		
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
				
				$form:=New object:C1471()
				
				$winRef:=Open form window:C675("_ga_subpanelCommunicationSingle"; Controller form window:K39:17; Horizontally centered:K39:1; Vertically centered:K39:4)
				DIALOG:C40("_ga_subpanelCommunicationSingle"; $form)
				CLOSE WINDOW:C154($winRef)
				
				If (OK=1)
					Form:C1466.communications.push($form.com)
				End if 
				
				$rebuildDisplayedLB:=True:C214
				CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
				
			: ($choose="--update")
/*
If ($inModification) && (Form.communicationMeanPosition>0)  //(FORM Event.columnName="col_type") && 
$form:=New object
				
$form.com:=OB Copy(Form.communications[Form.communicationMeanPosition-1])
				
$winRef:=Open form window("_ga_subpanelCommunicationSingle"; Plain form window; Horizontally centered; Vertically centered)
DIALOG("_ga_subpanelCommunicationSingle"; $form)
				
If (OK=1)
Form.communications[Form.communicationMeanPosition-1]:=$form.com
End if 
				
$rebuildDisplayedLB:=True
				
CALL FORM(Current form window; "sfw_main_draw_button")
				
End if 
*/
		End case 
		
		//: (FORM Event.code=On Clicked)
/*
If ($inModification) && (Form.communicationMeanPosition>0)  //(FORM Event.columnName="col_type") && 
$form:=New object
		
$form.com:=Form.communications[Form.communicationMeanPosition-1]
		
$winRef:=Open form window("_ga_subpanelCommunicationSingle"; Plain form window; Horizontally centered; Vertically centered)
DIALOG("_ga_subpanelCommunicationSingle"; $form)
		
If (OK=1)
Form.communications[Form.communicationMeanPosition-1]:=$form.com
		
Else 
		
End if 
		
//$refMenus:=New collection
//$mainMenu:=Create menu
//$refMenus.push($mainMenu)
		
//For each ($type; Form.communicationTypes)
//APPEND MENU ITEM($mainMenu; $type.label; *)
//SET MENU ITEM PARAMETER($mainMenu; -1; $type.type)
//SET MENU ITEM ICON($mainMenu; -1; "path:/RESOURCES/sfw/communication/"+$type.icon)
//End for each 
//$choose:=Dynamic pop up menu($mainMenu)
//For each ($refMenu; $refMenus)
//RELEASE MENU($refMenu)
//End for each 
//Case of 
//: ($choose="")
//Else 
		
//Form.communications[Form.communicationMeanPosition-1].type:=$choose
$rebuildDisplayedLB:=True
		
CALL FORM(Current form window; "sfw_main_draw_button")
//End case 
		
End if 
*/
		
End case 


If ($rebuildDisplayedLB)
	
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