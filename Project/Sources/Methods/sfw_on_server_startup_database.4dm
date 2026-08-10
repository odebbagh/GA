//%attributes = {}
#DECLARE($definitionClassName : Text; $globalParametersClassName : Text)

Use (Storage:C1525)
	Storage:C1525.definitionClass:=New shared object:C1526("name"; $definitionClassName)
	Use (Storage:C1525.definitionClass)
		If (Count parameters:C259>1)
			Storage:C1525.definitionClass.globalParametersName:=$globalParametersClassName
		Else 
			Storage:C1525.definitionClass.globalParametersName:=$definitionClassName+"_globalParameters"
		End if 
	End use 
End use 

If (OB Entries:C1720(cs:C1710).indices("key = :1"; Storage:C1525.definitionClass.globalParametersName).length=0)
	cs:C1710.sfw_dialog.me.alert("The class \""+Storage:C1525.definitionClass.globalParametersName+"\" is missing")
End if 

//$visions:=cs:C1710.sfw_definition.me.visions
cs:C1710.sfw_userManager.me.onStartup()
cs:C1710.sfw_notificationManager.me.onStartup()
sfw_scheduler_delayedLaunch