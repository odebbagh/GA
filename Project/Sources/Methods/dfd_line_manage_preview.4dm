//%attributes = {}
Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		MOUSE POSITION:C468($x; $y; $b)
		//CONVERT COORDINATES($x; $y; XY Current window; XY Current form)
		//CONVERT COORDINATES($x; $y; XY Current window; XY Current form)
		Form:C1466.dfd_current_x:=$x-472
		Form:C1466.dfd_current_y:=$y-392
		CALL SUBFORM CONTAINER:C1086(-100)
		//CALL FORM(Current form window; "TempLine_select_objectByXY"; $x; $y)
		
End case 