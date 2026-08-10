$resize:=False:C215

If (Form:C1466#Null:C1517)
	
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			//$resize:=True
			
		: (FORM Event:C1606.code=On Bound Variable Change:K2:52)
			$resize:=True:C214
			
		: (FORM Event:C1606.code=On Clicked:K2:4)
			If (FORM Event:C1606.objectName="vTabBar_@")
				$format:=OBJECT Get format:C894(*; FORM Event:C1606.objectName)
				$params:=Split string:C1554($format; ";")
				$num:=Num:C11($params[0])
				CALL SUBFORM CONTAINER:C1086(-99000-$num)
			End if 
			
	End case 
	
	If ($resize)
		If (Form:C1466.currentPage=Null:C1517)
			Form:C1466.currentPage:=1
		End if 
		CALL SUBFORM CONTAINER:C1086(-99000-Form:C1466.currentPage)
		OBJECT SET VISIBLE:C603(*; "vTabBar_@"; False:C215)
		$i:=0
		For each ($button; Form:C1466.buttons)
			$i:=$i+1
			$buttonName:="vTabBar_"+String:C10($i)
			OBJECT SET VISIBLE:C603(*; $buttonName; True:C214)
			$format:=String:C10($button.page)+";#sfw/image/skin/rainbow/btn4states/"+$button.pict+";;4;0;1;8;;;;0;;4"
			OBJECT SET FORMAT:C236(*; $buttonName; $format)
			If (Form:C1466.currentPage=$button.page)
				(OBJECT Get pointer:C1124(Object named:K67:5; $buttonName)->):=1
			End if 
		End for each 
	End if 
	
End if 