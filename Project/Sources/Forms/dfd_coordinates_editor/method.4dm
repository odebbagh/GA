Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		Form:C1466.unit:=New object:C1471
		Form:C1466.unit.values:=New collection:C1472("pixel"; "cm")
		Form:C1466.unit.index:=0  // pixel
		GOTO OBJECT:C206(*; "")
		
		Form:C1466.pixelBycm:=28+(1/3)
		
		Form:C1466.topCm:=Form:C1466.topPx/Form:C1466.pixelBycm
		Form:C1466.leftCm:=Form:C1466.leftPx/Form:C1466.pixelBycm
		Form:C1466.bottomCm:=Form:C1466.bottomPx/Form:C1466.pixelBycm
		Form:C1466.rightCm:=Form:C1466.rightPx/Form:C1466.pixelBycm
		Form:C1466.widthCm:=Form:C1466.widthPx/Form:C1466.pixelBycm
		Form:C1466.heightCm:=Form:C1466.heightPx/Form:C1466.pixelBycm
		
		Form:C1466.bLook_top:=0
		Form:C1466.bLook_left:=0
		Form:C1466.bLook_bottom:=0
		Form:C1466.bLook_right:=0
		Form:C1466.bLook_width:=0
		Form:C1466.bLook_height:=0
		
		Form:C1466.bChain:=0
		
		OBJECT SET FORMAT:C236(*; "coordinate_@"; "###,##0")
		
		
	: (FORM Event:C1606.code=On Clicked:K2:4)
		
		Form:C1466.enterable_top:=(Form:C1466.bLook_top=0) && ((Form:C1466.bLook_bottom=0) | (Form:C1466.bLook_height=0))
		dfd_coordinate_set_display("coordinate_top"; Form:C1466.enterable_top)
		
		Form:C1466.enterable_left:=(Form:C1466.bLook_left=0) && ((Form:C1466.bLook_right=0) | (Form:C1466.bLook_width=0))
		dfd_coordinate_set_display("coordinate_left"; Form:C1466.enterable_left)
		
		Form:C1466.enterable_bottom:=(Form:C1466.bLook_bottom=0) && ((Form:C1466.bLook_top=0) | (Form:C1466.bLook_height=0))
		dfd_coordinate_set_display("coordinate_bottom"; Form:C1466.enterable_bottom)
		
		Form:C1466.enterable_right:=(Form:C1466.bLook_right=0) && ((Form:C1466.bLook_left=0) | (Form:C1466.bLook_width=0))
		dfd_coordinate_set_display("coordinate_right"; Form:C1466.enterable_right)
		
		Form:C1466.enterable_width:=(Form:C1466.bLook_width=0) && ((Form:C1466.bLook_right=0) | (Form:C1466.bLook_left=0))
		dfd_coordinate_set_display("coordinate_width"; Form:C1466.enterable_width)
		
		Form:C1466.enterable_height:=(Form:C1466.bLook_height=0) && ((Form:C1466.bLook_top=0) | (Form:C1466.bLook_bottom=0))
		dfd_coordinate_set_display("coordinate_height"; Form:C1466.enterable_height)
		
		
	: (FORM Event:C1606.code=On Data Change:K2:15)
		$objectName:=OBJECT Get name:C1087(Object with focus:K67:3)
		If ($objectName="coordinate_top")
			Case of 
				: (Form:C1466.bLook_bottom=1)
					Form:C1466.height:=Form:C1466.bottom-Form:C1466.top
				: (Form:C1466.bLook_height=1)
					Form:C1466.bottom:=Form:C1466.top+Form:C1466.height
				Else 
					Form:C1466.bottom:=Form:C1466.top+Form:C1466.height
			End case 
		End if 
		
		If ($objectName="coordinate_left")
			Case of 
				: (Form:C1466.bLook_right=1)
					Form:C1466.width:=Form:C1466.right-Form:C1466.left
				: (Form:C1466.bLook_width=1)
					Form:C1466.right:=Form:C1466.left+Form:C1466.width
				Else 
					Form:C1466.right:=Form:C1466.left+Form:C1466.width
			End case 
		End if 
		
		If ($objectName="coordinate_bottom")
			Case of 
				: (Form:C1466.bLook_top=1)
					Form:C1466.height:=Form:C1466.bottom-Form:C1466.top
				: (Form:C1466.bLook_height=1)
					Form:C1466.top:=Form:C1466.bottom-Form:C1466.height
				Else 
					Form:C1466.height:=Form:C1466.bottom-Form:C1466.top
			End case 
		End if 
		
		If ($objectName="coordinate_right")
			Case of 
				: (Form:C1466.bLook_left=1)
					Form:C1466.width:=Form:C1466.right-Form:C1466.left
				: (Form:C1466.bLook_width=1)
					Form:C1466.left:=Form:C1466.right-Form:C1466.width
				Else 
					Form:C1466.width:=Form:C1466.right-Form:C1466.left
			End case 
		End if 
		
		If ($objectName="coordinate_height")
			Case of 
				: (Form:C1466.bLook_top=1)
					Form:C1466.bottom:=Form:C1466.top+Form:C1466.height
				: (Form:C1466.bLook_bottom=1)
					Form:C1466.top:=Form:C1466.bottom-Form:C1466.height
				Else 
					Form:C1466.bottom:=Form:C1466.top+Form:C1466.height
			End case 
			
			Case of 
				: (Form:C1466.bChain=1) & (Form:C1466.bLook_width=1)
					Form:C1466.height:=Form:C1466.previousHeight
					BEEP:C151
					
				: (Form:C1466.bChain=1) & (Form:C1466.bLook_width=0)
					Form:C1466.width:=Form:C1466.previousWidth/Form:C1466.previousHeight*Form:C1466.height
					Case of 
						: (Form:C1466.bLook_left=1)
							Form:C1466.right:=Form:C1466.left+Form:C1466.width
						: (Form:C1466.bLook_right=1)
							Form:C1466.left:=Form:C1466.right-Form:C1466.width
						Else 
							Form:C1466.right:=Form:C1466.left+Form:C1466.width
					End case 
					
			End case 
			
		End if 
		
		If ($objectName="coordinate_width")
			Case of 
				: (Form:C1466.bLook_left=1)
					Form:C1466.right:=Form:C1466.left+Form:C1466.width
				: (Form:C1466.bLook_right=1)
					Form:C1466.left:=Form:C1466.right-Form:C1466.width
				Else 
					Form:C1466.right:=Form:C1466.left+Form:C1466.width
			End case 
			
			Case of 
				: (Form:C1466.bChain=1) & (Form:C1466.bLook_height=1)
					Form:C1466.width:=Form:C1466.previousWidth
					BEEP:C151
					
				: (Form:C1466.bChain=1) & (Form:C1466.bLook_width=0)
					Form:C1466.height:=Form:C1466.previousHeight/Form:C1466.previousWidth*Form:C1466.width
					
					Case of 
						: (Form:C1466.bLook_top=1)
							Form:C1466.bottom:=Form:C1466.top+Form:C1466.height
						: (Form:C1466.bLook_bottom=1)
							Form:C1466.top:=Form:C1466.bottom-Form:C1466.height
						Else 
							Form:C1466.bottom:=Form:C1466.top+Form:C1466.height
					End case 
			End case 
			
		End if 
		
		
		Case of 
			: (Form:C1466.unit.index=0)  //pixel
				Form:C1466.topPx:=Form:C1466.top
				Form:C1466.leftPx:=Form:C1466.left
				Form:C1466.widthPx:=Form:C1466.width
				Form:C1466.heightPx:=Form:C1466.height
				Form:C1466.bottomPx:=Form:C1466.bottom
				Form:C1466.rightPx:=Form:C1466.right
				
			: (Form:C1466.unit.index=1)  //cm
				Form:C1466.topPx:=Form:C1466.top*Form:C1466.pixelBycm
				Form:C1466.leftPx:=Form:C1466.left*Form:C1466.pixelBycm
				Form:C1466.widthPx:=Form:C1466.width*Form:C1466.pixelBycm
				Form:C1466.heightPx:=Form:C1466.height*Form:C1466.pixelBycm
				Form:C1466.bottomPx:=Form:C1466.bottom*Form:C1466.pixelBycm
				Form:C1466.rightPx:=Form:C1466.right*Form:C1466.pixelBycm
				
		End case 
		
		
End case 

Form:C1466.previousHeight:=Form:C1466.height
Form:C1466.previousWidth:=Form:C1466.width