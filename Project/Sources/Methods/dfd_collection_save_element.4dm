//%attributes = {}
#DECLARE()

var $object : Object
var $item : Object

If (Form:C1466.element#Null:C1517)
	
	$object:=New object:C1471()
	Form:C1466.elements[Form:C1466.position_element-1]:=$object
	
	For each ($item; Form:C1466.lb_attributes)
		$object[$item.attribute]:=$item.value
	End for each 
End if 
