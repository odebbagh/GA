Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		GET WINDOW RECT:C443($right; $top; $left; $bottom; Current form window:C827)
		$height:=20*Num:C11(Form:C1466.lb_tags.length)
		SET WINDOW RECT:C444($right; $top; $left; $top+$height+1; Current form window:C827)
		
End case 