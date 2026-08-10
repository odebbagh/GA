Case of 
	: (FORM Event:C1606.code=On Double Clicked:K2:5)
		$item:=Selected list items:C379(Form:C1466.hList)
		
		If ($vlItemPos#0)
			GET LIST ITEM:C378(Form:C1466.hList; $item; $ref; $text; $subList; $subExpanded)
			
			If ($subList=0)
				
				Form:C1466.member:=$text
				
				ACCEPT:C269
			End if 
		End if 
End case 