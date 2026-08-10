//%attributes = {}
GET WINDOW RECT:C443($g; $h; $d; $b; Current form window:C827)
GET MOUSE:C468($x; $y; $button; *)
//CONVERT COORDINATES($x; $y; XY Main window; XY Current form)
$cancel:=True:C214
Case of 
	: ($x<$g)
	: ($x>$d)
	: ($y<$h)
	: ($y>$b)
	Else 
		$cancel:=False:C215
End case 
If ($cancel)
	CANCEL:C270
End if 
