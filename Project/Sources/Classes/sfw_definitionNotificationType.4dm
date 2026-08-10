property active : Boolean
property description : Text

Class constructor
	
	
	
Function setDescription($description : Text)
	
	This:C1470.description:=$description
	
Function setActive($active : Boolean)
	
	If (Count parameters:C259=0)
		This:C1470.active:=True:C214
	Else 
		This:C1470.active:=$active
	End if 
	
	