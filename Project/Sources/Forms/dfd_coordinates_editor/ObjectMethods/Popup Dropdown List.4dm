Case of 
	: (Form:C1466.unit.index=0)  //pixel
		Form:C1466.top:=Form:C1466.topPx
		Form:C1466.left:=Form:C1466.leftPx
		Form:C1466.width:=Form:C1466.widthPx
		Form:C1466.height:=Form:C1466.heightPx
		Form:C1466.bottom:=Form:C1466.topPx+Form:C1466.heightPx
		Form:C1466.right:=Form:C1466.leftPx+Form:C1466.widthPx
		OBJECT SET FORMAT:C236(*; "coordinate_@"; "###,##0")
		
	: (Form:C1466.unit.index=1)  //cm
		Form:C1466.top:=Form:C1466.topCm
		Form:C1466.left:=Form:C1466.leftCm
		Form:C1466.width:=Form:C1466.widthCm
		Form:C1466.height:=Form:C1466.heightCm
		Form:C1466.bottom:=Form:C1466.topCm+Form:C1466.heightCm
		Form:C1466.right:=Form:C1466.leftCm+Form:C1466.widthCm
		OBJECT SET FORMAT:C236(*; "coordinate_@"; "###,##0.00")
		
End case 