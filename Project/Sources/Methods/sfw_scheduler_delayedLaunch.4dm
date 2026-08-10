//%attributes = {}
#DECLARE($option : Integer)

If (Count parameters:C259=0)
	
	$ref:=New process:C317(Current method name:C684; 0; Current method name:C684; 1)
	
Else 
	
	DELAY PROCESS:C323(Current process:C322; 60*60)  // 1 min
	
	cs:C1710.sfw_schedulerManager.me.launch()
	
End if 