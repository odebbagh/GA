var $entitySelection : 4D:C1709.EntitySelection

Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		
		
		$file:=Folder:C1567(fk resources folder:K87:11).file(Form:C1466.entry.icon)
		READ PICTURE FILE:C678($file.platformPath; vIconSelector)
		vIconSelector:=vIconSelector*0.75
		OBJECT SET FORMAT:C236(*; "bIcon_entry"; ";vIconSelector;0;0;0;1;0;0;0;0;0;0;1")
		
		Form:C1466.sfw:=cs:C1710.sfw_main.new()
		Form:C1466.sfw.entry:=Form:C1466.entry
		Form:C1466.sfw.lb_items_define()
		Form:C1466.sfw.lb_items_search()
		If (Form:C1466.subset#Null:C1517)
			$formula:=Formula from string:C1601(Form:C1466.subset)
			$entitySelection:=$formula.call()
			Form:C1466.sfw.lb_items:=Form:C1466.sfw.lb_items.and($entitySelection)
		End if 
		Form:C1466.sfw.lb_items_sort()
			
		OBJECT SET VISIBLE:C603(*; "bUnselect"; Not:C34(Bool:C1537(Form:C1466.options.noCutLink)))
		OBJECT SET VISIBLE:C603(*; "bCreate"; Not:C34(Bool:C1537(Form:C1466.options.noCreation)))
		
		GOTO OBJECT(*;"Search_Input")

		
End case 

OBJECT SET ENABLED:C1123(*; "bSelect"; (Form:C1466.current_item#Null:C1517))
