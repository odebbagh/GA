//%attributes = {}
// Ensures the given hold ON record has a UUID and persists it on the lot.
#DECLARE($lot : 4D:C1709.Entity; $hold : Object)

var $holds : Collection
var $holdDate : Date
var $holdTime : Time
var $itemDate : Date
var $itemTime : Time
var $uuid : Text
var $updated : Boolean
var $updatedItem : Object

If ($lot=Null:C1517) || ($hold=Null:C1517)
	return 
End if 

If ($hold.UUID#Null:C1517) && (String:C10($hold.UUID)#"")
	return 
End if 

If ($hold.date#Null:C1517)
	$holdDate:=$hold.date
Else 
	$holdDate:=$hold.holdDate
End if 

If ($hold.time#Null:C1517)
	$holdTime:=$hold.time
Else 
	$holdTime:=$hold.holdTime
End if 

$uuid:=Generate UUID:C1066
$holds:=New collection:C1472()
$updated:=False:C215

If ($lot.lotHold#Null:C1517) && ($lot.lotHold.items#Null:C1517)
	For each ($item; $lot.lotHold.items)
		$itemDate:=Choose:C955($item.date#Null:C1517; $item.date; $item.holdDate)
		$itemTime:=Choose:C955($item.time#Null:C1517; $item.time; $item.holdTime)
		
		If (Not:C34($updated)) && ($itemDate=$holdDate) && ($itemTime=$holdTime)
			If (($item.action="on") || (String:C10($item.holdAction)="Hold ON"))
				$updatedItem:=LotHoldForm_cloneObject($item)
				$updatedItem.UUID:=$uuid
				$hold.UUID:=$uuid
				$holds.push($updatedItem)
				$updated:=True:C214
			Else 
				$holds.push($item)
			End if 
		Else 
			$holds.push($item)
		End if 
	End for each 
	
	If ($updated)
		$lot.lotHold:=New object:C1471("items"; $holds)
	End if 
End if 
