property lb_items : Variant
property lb_results : Collection
property searchbox : Text

Class extends sfw_foundations


Class constructor()
	Super:C1705()
	
	This:C1470.lb_items:=Null:C1517
	This:C1470.lb_results:=Null:C1517
	This:C1470.searchbox:=""
	
Function searchForEntry()
	
	If (This:C1470.searchbox="")
		This:C1470.lb_items:=Null:C1517
	Else 
		This:C1470._searchEngine()
	End if 
	
	