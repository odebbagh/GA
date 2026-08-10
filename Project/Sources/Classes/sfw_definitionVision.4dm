property ident : Text
property label : Text
property xliff : Text
property toolbar : Object
property allowedProfiles : Collection
property displayOrder : Integer
property icon : Text

Class constructor($ident : Text; $label : Text)
	This:C1470.ident:=$ident
	This:C1470.label:=$label
	
	This:C1470.xliff:=""
	This:C1470.toolbar:={color: "#E0E0E0"}
	This:C1470.displayOrder:=0
	
Function setToolbarBackgroundColor($color : Text)
	This:C1470.toolbar.color:=$color
	
	
Function setFocusRingColor($color : Text)
	This:C1470.toolbar.focusRing:=$color
	
	
Function setXliffLabel($xliff : Text)
	This:C1470.xliff:=$xliff
	
	
Function setDisplayOrder($order : Integer)
	This:C1470.displayOrder:=$order
	
	
Function setAllowedProfiles( ...  : Variant)
	This:C1470.allowedProfiles:=This:C1470.allowedProfiles || New collection:C1472
	
	var $p : Integer
	For ($p; 1; Count parameters:C259)
		Case of 
			: (Value type:C1509(${$p})=Is text:K8:3)
				This:C1470.allowedProfiles.push(${$p})
			: (Value type:C1509(${$p})=Is collection:K8:32)
				This:C1470.allowedProfiles:=This:C1470.allowedProfiles.concat(${$p})
			Else 
				// not possible at this time
		End case 
	End for 
	
	
Function setIcon($relativeResssourcesPath : Text)
	
	This:C1470.icon:=$relativeResssourcesPath