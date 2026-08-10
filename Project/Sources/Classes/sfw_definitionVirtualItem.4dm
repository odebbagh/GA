
property xliff : Text
property name : Text
property panel : Object


Class constructor($name : Text; $panel : Text))
	
	This:C1470.name:=$name
	This:C1470.panel:=New object:C1471("name"; $panel)
	
	
Function setXliffLabel($xliff : Text)
	This:C1470.xliff:=$xliff
	
	
Function setItemAction($label : Text; $method : Text;  ...  : Text)
	var $action : Object:=New object:C1471
	$action.label:=$label
	$action.method:=$method
	For ($i; 3; Count parameters:C259)
		$params:=Split string:C1554(${$i}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="xliff")
				$action.xliff:=$params[0]
		End case 
	End for 
	
	
	