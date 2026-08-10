Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4) & (Contextual click:C713)
		$row:=Num:C11(FORM Event:C1606.row)
		If ($row<=Form:C1466.lb_results.length) & ($row>0)
			$line:=Form:C1466.lb_results[$row-1]
			$refWindow:=Num:C11(Storage:C1525.windows.globalSearch)
			
			Case of 
				: ($line.kind="more")
					Form:C1466.limit[$line.dataclass].max:=Form:C1466.limit[$line.dataclass].max+10
					CALL FORM:C1391($refWindow; "sfw_globalSearchManager"; "search")
					
					
				: ($line.kind="entity")
					$refMenu:=Create menu:C408
					
					APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("menu.displayRecord"; "Display the record"))
					SET MENU ITEM PARAMETER:C1004($refMenu; -1; "UUID:"+$line.entity.getKey())
					
					$choose:=Dynamic pop up menu:C1006($refMenu)
					RELEASE MENU:C978($refMenu)
					
					Case of 
						: ($choose="")
						: ($choose="UUID:@")
							$key:=Substring:C12($choose; 6)
							
							$formEvent:=FORM Event:C1606
							$iconNum:=Num:C11(Substring:C12($formEvent.objectName; 10))
							
							$formData:=New object:C1471()
							//singleton for the framework useCase of 
							
							$indices:=Form:C1466.entries.indices("dataclass = :1"; $line.dataclass)
							$entry:=Form:C1466.entries[$indices[0]]
							$formData.sfw:=cs:C1710.sfw_item.new()
							
							$formData.sfw.vision:=Form:C1466.vision
							$formData.sfw.entry:=$entry
							$formData.current_item:=$line.entity
							$formData.sfw.openForm($formData)
							
					End case 
					
			End case 
			
		End if 
		
	: (FORM Event:C1606.code=On Double Clicked:K2:5)
		$row:=Num:C11(FORM Event:C1606.row)
		If ($row<=Form:C1466.lb_results.length) & ($row>0)
			$line:=Form:C1466.lb_results[$row-1]
			Case of 
				: ($line.kind="entity")
					$key:=$line.entity.getKey()
					
					$formData:=New object:C1471()
					//singleton for the framework useCase of 
					
					$indices:=Form:C1466.entries.indices("dataclass = :1"; $line.dataclass)
					$entry:=Form:C1466.entries[$indices[0]]
					$formData.sfw:=cs:C1710.sfw_item.new()
					
					$formData.sfw.vision:=Form:C1466.vision
					$formData.sfw.entry:=$entry
					$formData.current_item:=$line.entity
					$formData.sfw.openForm($formData)
			End case 
		End if 
End case 