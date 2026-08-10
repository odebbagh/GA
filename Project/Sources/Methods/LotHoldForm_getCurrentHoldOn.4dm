//%attributes = {}
// Returns the active hold ON record for a lot by walking the on/off history.
#DECLARE($lot : 4D:C1709.Entity)->$hold : Object

var $sorted : Collection
var $event : Object

$hold:=Null:C1517

If ($lot=Null:C1517) || (Not:C34(Bool:C1537($lot.onHold)))
	return $hold
End if 

If ($lot.lotHold#Null:C1517) && ($lot.lotHold.items#Null:C1517)
	$sorted:=$lot.lotHold.items.orderBy("date asc; time asc")
	
	For each ($event; $sorted)
		If (($event.action="on") || (String:C10($event.holdAction)="Hold ON"))
			$hold:=$event
		Else 
			$hold:=Null:C1517
		End if 
	End for each 
	
	If ($hold=Null:C1517)
		$hold:=$lot.lotHold.items.query("action = :1"; "on").orderBy("date desc; time desc").first()
		If ($hold=Null:C1517)
			$hold:=$lot.lotHold.items.query("holdAction = :1"; "Hold ON").orderBy("holdDate desc; holdTime desc").first()
		End if 
	End if 
End if 
