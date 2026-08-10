var $rowHeight; $buttonBarHeight; $wantedWidth; $wantedHeight : Integer

Case of 
	: (Form event code:C388=On Load:K2:1)
		If (Form:C1466.options=Null:C1517)
			Form:C1466.options:=New collection:C1472
		End if 
		If (Form:C1466.choice=Null:C1517)
			Form:C1466.choice:=""
		End if 
		
		$rowHeight:=22
		$buttonBarHeight:=50
		$wantedHeight:=(Form:C1466.options.length*$rowHeight)+$buttonBarHeight+8
		If ($wantedHeight<120)
			$wantedHeight:=120
		End if 
		If ($wantedHeight>500)
			$wantedHeight:=500
		End if 
		
		$wantedWidth:=340
		If (Form:C1466.width#Null:C1517)
			If (Form:C1466.width>150)
				$wantedWidth:=Form:C1466.width
			End if 
		End if 
		
		RESIZE FORM WINDOW:C890($wantedWidth; $wantedHeight)  //; Pop up form window)
		
	: (Form event code:C388=On Close Box:K2:21)
		CANCEL:C270
End case 
