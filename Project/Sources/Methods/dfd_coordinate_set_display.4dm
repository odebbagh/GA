//%attributes = {}
#DECLARE($objectName : Text; $state : Boolean)

OBJECT SET ENTERABLE:C238(*; $objectName; $state)
If ($state)
	OBJECT SET RGB COLORS:C628(*; $objectName; Foreground color:K23:1; "white")
Else 
	OBJECT SET RGB COLORS:C628(*; $objectName; "grey"; "lightgrey")
End if 