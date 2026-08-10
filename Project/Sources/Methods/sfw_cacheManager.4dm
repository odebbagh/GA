//%attributes = {}

#DECLARE($action : Text; $target : Text)

Case of 
	: ($action="clear")
		$memberFunction:="cacheClear"
		If (ds:C1482[$target][$memberFunction]#Null:C1517)
			ds:C1482[$target][$memberFunction]()
		End if 
		
End case 



