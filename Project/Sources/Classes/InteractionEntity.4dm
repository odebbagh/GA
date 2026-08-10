Class extends Entity

Function get creationDate()->$creationDate : Date
	$creationDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpCreation)
	
Function get followUPDate()->$followUPDate : Date
	$followUPDate:=cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpFollowUp)
	
	
Function set creationDate($creationDate : Date)
	This:C1470.stmpCreation:=cs:C1710.sfw_stmp.me.build($creationDate)
	
Function set followUPDate($followUPDate : Date)
	This:C1470.stmpFollowUp:=cs:C1710.sfw_stmp.me.build($followUPDate)
	
	
	
	
	
	