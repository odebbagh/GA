property storedParameters : Object
property globalParametersClassName : Text
property dfd : Object
property userVision : Object

shared singleton Class constructor
	This:C1470.globalParametersClassName:=Storage:C1525.definitionClass.globalParametersName
	This:C1470.getParameters()
	
shared Function getParameters->$globalParameters : Object
	
	$parameters:=cs:C1710[This:C1470.globalParametersClassName].new()
	For each ($parameterName; $parameters)
		Case of 
			: (Value type:C1509($parameters[$parameterName])=Is object:K8:27)
				This:C1470[$parameterName]:=OB Copy:C1225($parameters[$parameterName]; ck shared:K85:29; This:C1470)
			: (Value type:C1509($parameters[$parameterName])=Is collection:K8:32)
				This:C1470[$parameterName]:=$parameters[$parameterName].copy(ck shared:K85:29; This:C1470)
			Else 
				This:C1470[$parameterName]:=$parameters[$parameterName]
		End case 
	End for each 
	
	