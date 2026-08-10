Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		
		$id:=SVG Find element ID by coordinates:C1054(*; "barIncorporations"; MouseX; MouseY)
		If ($id#"")
			$parts:=Split string:C1554($id; "-")
			Case of 
				: ($parts.length=2)
					$iValue:=Num:C11($parts.shift())
					$indices:=Form:C1466.incorporationDateData.indices("xValue = :1"; $iValue)
					If ($indices.length>0)
						Form:C1466.sfw.searchbox:="yearCreation:"+String:C10(Form:C1466.incorporationDateData[$indices[0]].year)
						If (Form:C1466.incorporationDateData[$indices[0]].month#Null:C1517)
							Form:C1466.sfw.searchbox+=" and monthCreation:"+String:C10(Form:C1466.incorporationDateData[$indices[0]].month)
						End if 
						CALL SUBFORM CONTAINER:C1086(-6000)
					End if 
					
					
			End case 
		End if 
End case 