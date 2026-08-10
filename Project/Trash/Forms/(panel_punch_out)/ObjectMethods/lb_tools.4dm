Case of 
	: (FORM Event:C1606.code=On Double Clicked:K2:5) && (Form:C1466.sfw.checkIsInModification())
		If (Form:C1466.selectedTool#Null:C1517)
			OBJECT GET COORDINATES:C663(*; "toolNameCol"; $l; $t; $r; $b)
			CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
			
			$form:=New object:C1471(\
				"colName"; "name"; \
				"allData"; ds:C1482.Tool.query("UUID_ToolType = :1"; Form:C1466.selectedTool.uuid_toolType); \
				"dataclass"; "Tool"\
				)
			
			$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-80+(Form:C1466.selectedTool.order*20))
			DIALOG:C40("selectNto1"; $form)
			CLOSE WINDOW:C154($winRef)
			
			If (ok=1)
				
				$tool:=Form:C1466.current_item.tools.items.query("order = :1"; Form:C1466.selectedTool.order)[0]
				$tool.toolName:=$form.item.name
				$tool.toolDate:=$form.item.date
				
				cs:C1710.panel_punch_in.me.loadToolsLb()
			End if 
		End if 
End case 