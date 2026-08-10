//%attributes = {}
// Returns the hold ON event associated with a selected lotHold listbox row.
#DECLARE($lot : 4D:C1709.Entity; $holdEvent : Object)->$holdOn : Object

var $events : Collection
var $event : Object
var $lastOn : Object

$holdOn:=Null:C1517

If ($lot=Null:C1517) || ($holdEvent=Null:C1517)
	return $holdOn
End if 

If (($holdEvent.action="on") || (String:C10($holdEvent.holdAction)="Hold ON"))
	$holdOn:=$holdEvent
	return $holdOn
End if 

If ($lot.lotHold#Null:C1517) && ($lot.lotHold.items#Null:C1517)
	$events:=$lot.lotHold.items.orderBy("date asc; time asc")
	
	For each ($event; $events)
		If (($event.action="on") || (String:C10($event.holdAction)="Hold ON"))
			$lastOn:=$event
		End if 
		
		If (LotHoldForm_holdsMatch($event; $holdEvent))
			$holdOn:=$lastOn
		End if 
	End for each 
End if 
