singleton Class constructor
	
	//It's a singleton class
	
Function formMethod()
	
	
	If (Form:C1466#Null:C1517)
		
		var $rebuildForm : Boolean
		
		Case of 
			: (FORM Event:C1606.code=On Load:K2:1)
				$rebuildForm:=True:C214
				
				
			: (FORM Event:C1606.code=On Bound Variable Change:K2:52)
				$rebuildForm:=True:C214
				
				
			: (FORM Event:C1606.code=On Data Change:K2:15)
				//CALL SUBFORM CONTAINER(-2000)
				
			Else 
				
				
		End case 
		
		If ($rebuildForm)
			$isInModification:=sfw_checkIsInModification
			
			This:C1470.drawPup_priority()
			This:C1470.drawPup_origin()
			This:C1470.drawPup_category()
			This:C1470.drawPup_disposition()
			This:C1470.drawPup_humanFactor()
			This:C1470.drawPup_yesNoQuestion()
			This:C1470.drawPup_procedureType()
			
			
			If ($isInModification)
				//OBJECT SET RGB COLORS(*; "entryField_@"; "black"; "white")
				OBJECT SET ENTERABLE:C238(*; "entryField@"; True:C214)
				If (OBJECT Get title:C1068(*; "pup_procedure")="QCAR#@")
					OBJECT SET ENTERABLE:C238(*; "entryField_action"; False:C215)
				Else 
					OBJECT SET ENTERABLE:C238(*; "entryField_action"; True:C214)
				End if 
				
				
			Else 
				//OBJECT SET RGB COLORS(*; "entryField_@"; "black"; "transparent")
				OBJECT SET ENTERABLE:C238(*; "entryField@"; False:C215)
			End if 
			
			OBJECT SET ENTERABLE:C238(*; "entryField_interestedParty"; False:C215)
			OBJECT SET ENTERABLE:C238(*; "entryField_responsible"; False:C215)
			OBJECT SET VISIBLE:C603(*; "bResponsibleEdit"; $isInModification)
			OBJECT SET VISIBLE:C603(*; "bActionRefresh"; $isInModification)
			OBJECT SET VISIBLE:C603(*; "PopupDa@"; $isInModification)
			OBJECT SET VISIBLE:C603(*; "Rectangl@"; $isInModification)
			
		End if 
		
	End if 
	
	
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and
	
	
	
Function drawPup_priority()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("CIPriority"; "levelID"; "UUID_CIPriority"; "pup_priority")
	End if 
	CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
	
Function pup_priority()
	//Create pop up menu
	Form:C1466.current_item.pup("ImprovementPriorities"; "CIPriority"; "levelID"; "UUID_CIPriority")
	This:C1470.drawPup_priority()
	
	
Function drawPup_origin()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("CIOrigin"; "originID"; "origin"; "pup_origin")
	End if 
	CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
	
Function pup_origin()
	//Create pop up menu
	Form:C1466.current_item.pup("ImprovementOrigins"; "CIOrigin"; "originID"; "origin")
	This:C1470.drawPup_origin()
	
	
Function drawPup_category()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("CICategory"; "categoryID"; "category"; "pup_category")
	End if 
	CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
	
Function pup_category()
	//Create pop up menu
	Form:C1466.current_item.pup("ImprovementCategories"; "CICategory"; "categoryID"; "category")
	This:C1470.drawPup_category()
	
	
Function drawPup_disposition()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("CIDisposition"; "dispositionID"; "disposition"; "pup_disposition")
	End if 
	CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
	
Function pup_disposition()
	//Create pop up menu
	Form:C1466.current_item.pup("ImprovementDispositions"; "CIDisposition"; "dispositionID"; "disposition")
	This:C1470.drawPup_disposition()
	
	
	
Function drawPup_humanFactor()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("CIHumanFactor"; "factorID"; "humanFactor"; "pup_humanFactor")
	End if 
	CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
	
Function pup_humanFactor()
	//Create pop up menu
	Form:C1466.current_item.pup("ImprovementFactors"; "CIHumanFactor"; "factorID"; "humanFactor")
	This:C1470.drawPup_humanFactor()
	
	
Function drawPup_yesNoQuestion()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("YesNoQuestion"; "responseID"; "IsAcceptable"; "pup_yesNoQuestion")
	End if 
	CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
	
Function pup_yesNoQuestion()
	//Create pop up menu
	Form:C1466.current_item.pup("ImprovementResponses"; "YesNoQuestion"; "responseID"; "IsAcceptable")
	This:C1470.drawPup_yesNoQuestion()
	
	
Function drawPup_procedureType()
	If (Form:C1466.current_item#Null:C1517)
		If (Form:C1466.current_item.action="QCAR#@")
			OBJECT SET TITLE:C194(*; "pup_procedure"; Form:C1466.current_item.action)
			
		Else 
			OBJECT SET TITLE:C194(*; "pup_procedure"; "")
			
		End if 
		
		If (Form:C1466.sfw.checkIsInModification())
			
			OBJECT SET FORMAT:C236(*; "pup_procedure"; ";#sfw/image/skin/rainbow/icon/spacer-1x24.png;0;3;1;1;8;0;0;0;1;0;1")
		Else 
			OBJECT SET FORMAT:C236(*; "pup_procedure"; ";#sfw/image/skin/rainbow/icon/spacer-1x24.png;0;3;1;1;0;0;0;0;0;0;1")
		End if 
		
	End if 
	CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
	
Function pup_procedureType()
	//Create pop up menu
	If (Form:C1466.sfw.checkIsInModification())
		OBJECT GET COORDINATES:C663(*; "pup_procedure"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$form:=New object:C1471(\
			"colName"; "qcarNumberRef"; \
			"allData"; ds:C1482.Qcar.all().toCollection().map(Formula:C1597(_ga_getQcarRef)); \
			"dataclass"; "Qcar"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (ok=1)
			Form:C1466.current_item.action:=$form.item.qcarNumberRef
			CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
		End if 
		
	End if 
	
	This:C1470.drawPup_procedureType()
	
	
Function refreshAction()
	If (Form:C1466.sfw.checkIsInModification())
		OBJECT SET TITLE:C194(*; "pup_procedure"; "")
		Form:C1466.current_item.action:=""
		CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
	End if 
	
	
Function responsibleEdit()
	If (Form:C1466.sfw.checkIsInModification())
		
		$form:=New object:C1471
		
		var $teams : cs:C1710.TeamSelection
		var $staffs : cs:C1710.StaffEntity
		var $hListItems : Collection
		var $hSousListItems; $memberShips; $teamMembers : Collection
		
		$memberShips:=New collection:C1472()
		$hListItems:=New collection:C1472()
		$hSousListItems:=New collection:C1472()
		$teamMembers:=New collection:C1472()
		
		$teams:=ds:C1482.Team.all()
		//$hListItems:=ds.Team.all().toCollection().extract("name")
		//hListItems:=New collection()
		
		For each ($team; $teams)
			$memberShips:=$team.memberships.extract("UUID_Staff")
			$staffs:=ds:C1482.Staff.query("UUID in :1"; $memberShips)
			$teamMembers:=New collection:C1472()
			For each ($staff; $staffs)
				$obj:=New object:C1471("selected"; False:C215; "staffName"; String:C10($staff.firstName+" "+$staff.lastName))
				$teamMembers.push($obj)
				
			End for each 
			$hSousListItems.push($teamMembers)
		End for each 
		
		For ($i; 0; ds:C1482.Team.all().toCollection().extract("name").length-1)
			$obj:=New object:C1471("selected"; False:C215; "teamName"; ds:C1482.Team.all().toCollection().extract("name")[$i]; "members"; $hSousListItems[$i])
			$hListItems.push($obj)
		End for 
		
		
		$responsibles:=Split string:C1554(Form:C1466.current_item.responsible; ",")
		
		For ($k; 0; $responsibles.length-1)
			
			For ($i; 0; $hListItems.length-1)
				
				If ($hListItems[$i].teamName=$responsibles[$k])
					
					$hListItems[$i].selected:=True:C214
					
				Else 
					
					For ($j; 0; $hSousListItems[$i].length-1)
						
						If ($hSousListItems[$i][$j].staffName=$responsibles[$k])
							
							$hSousListItems[$i][$j].selected:=True:C214
							
						End if 
						
					End for 
					
				End if 
				
			End for 
			
		End for 
		
		
		$form.teams:=$hListItems
		$winRef:=Open form window:C675("_ga_staffsPerTeam"; Movable dialog box:K34:7; Horizontally centered:K39:1; Vertically centered:K39:4)
		DIALOG:C40("_ga_staffsPerTeam"; $form)
		
		If (OK=1)
			
			$responsables:=New collection:C1472()
			$choices:=$form.teams
			
			For ($i; 0; $choices.length-1)
				
				If ($choices[$i].selected=True:C214) & ($responsables.indexOf($choices[$i].teamName)=-1)
					$responsables.push($choices[$i].teamName)
					
				Else 
					
					For ($j; 0; $choices[$i].members.length-1)
						
						If ($choices[$i].members[$j].selected=True:C214) & ($responsables.indexOf($choices[$i].members[$j].staffName)=-1)
							$responsables.push($choices[$i].members[$j].staffName)
						End if 
						
					End for 
					
				End if 
				
			End for 
			
			
			Form:C1466.current_item.responsible:=$responsables.join(",")
			CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
		End if 
		
	End if 
	
	