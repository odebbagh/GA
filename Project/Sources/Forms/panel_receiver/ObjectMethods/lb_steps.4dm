Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		If (Not:C34(Contextual click:C713))
			cs:C1710.panel_lot.me.manageReOrderBtns()
		Else 
			If ((Form:C1466.selectedLot#Null:C1517) && (Form:C1466.sfw.checkIsInModification()))
				LIST TO ARRAY:C288("StepProperty"; $arr_items; $arr_refs)
				$lotStep:=Form:C1466.selectedLot
				
				If ($lotStep.properties=Null:C1517)
					$lotStep.properties:=New object:C1471(\
						"items"; New collection:C1472()\
						)
					
					For ($i; 1; Size of array:C274($arr_items))
						$lotStep.properties.items.push(New object:C1471(\
							"ref"; $arr_refs{$i}; \
							"name"; $arr_items{$i}; \
							"checked"; False:C215\
							))
					End for 
				Else 
					For ($i; 1; Size of array:C274($arr_items))
						$property_es:=$lotStep.properties.items.query("ref = :1"; $arr_refs{$i})
						
						If ($property_es.length=0)
							$lotStep.properties.items.push(New object:C1471(\
								"ref"; $arr_refs{$i}; \
								"name"; $arr_items{$i}; \
								"checked"; False:C215\
								))
						End if 
					End for 
				End if 
				
				$refMenu:=Create menu:C408
				
				For each ($property; $lotStep.properties.items.orderBy("ref asc"))
					APPEND MENU ITEM:C411($refMenu; $property.name; *)
					SET MENU ITEM PARAMETER:C1004($refMenu; -1; String:C10($property.ref))
					If ($property.checked)
						SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
						If (Is Windows:C1573)
							SET MENU ITEM STYLE:C425($refMenu; -1; Bold:K14:2)
						End if 
					End if 
				End for each 
				
				$choose:=Dynamic pop up menu:C1006($refMenu)
				
				If ($choose#"")
					$property_es:=$lotStep.properties.items.query("ref = :1"; Num:C11($choose))
					$property_es[0].checked:=Not:C34($property_es[0].checked)
					
					$res:=$lotStep.save()
					
					If ($res.success)
						cs:C1710.panel_lot.me._activate_save_cancel_button()
					End if 
				End if 
				
				
			End if 
		End if 
		
	: (FORM Event:C1606.code=On Begin Drag Over:K2:44)
		Form:C1466.dragAndDrop:=New object:C1471("from"; Form:C1466.selectedLotPos; "to"; 0)
	: (FORM Event:C1606.code=On Drop:K2:12)
		Form:C1466.dragAndDrop:=New object:C1471("from"; Form:C1466.selectedLotPos; "to"; Drop position:C608)
		
		cs:C1710.panel_lot.me.btnReOrderLots(Form:C1466.dragAndDrop.from; Form:C1466.dragAndDrop.to)
		
	: (FORM Event:C1606.code=On Data Change:K2:15)
		For each ($lotStep; Form:C1466.lb_steps.orderBy("order asc"))
			If ($lotStep.serialization=Null:C1517)
				$lotStep.serialization:=New object:C1471(\
					"items"; New collection:C1472()\
					)
				$res:=$lotStep.save()
			End if 
			
			If ($lotStep.beSerialized)
				If ($lotStep.serialization.items.length=0)
					For ($i; 1; $lotStep.lot.original)
						$lotStep.serialization.items.push(New object:C1471(\
							"sn"; $i; \
							"status"; ""; \
							"comments"; ""\
							))
					End for 
					
					$res:=$lotStep.save()
					
					If ($res.success)
						cs:C1710.panel_lot.me._activate_save_cancel_button()
					End if 
				Else 
					//ALERT("lotStep already serialized !!")
				End if 
			End if 
		End for each 
End case 