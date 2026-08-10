//%attributes = {}
#DECLARE()

var $element : Object
var $key : Text

Form:C1466.lb_attributes:=New collection:C1472()
If (Form:C1466.element#Null:C1517)
	
	For each ($key; OB Keys:C1719(Form:C1466.element))
		$element:=New object:C1471
		$element.attribute:=$key
		$element.value:=Form:C1466.element[$element.attribute]
		
		Case of 
			: (Value type:C1509($element.value)=Is text:K8:3)
				$element.type:="text"
			: (Value type:C1509($element.value)=Is real:K8:4)
				$element.type:="real"
			: (Value type:C1509($element.value)=Is date:K8:7)
				$element.type:="date"
			: (Value type:C1509($element.value)=Is time:K8:8)
				$element.type:="time"
			: (Value type:C1509($element.value)=Is boolean:K8:9)
				$element.type:="boolean"
			Else 
				$element.type:=""
		End case 
		
		Form:C1466.lb_attributes.push($element)
		
	End for each 
	
End if 
