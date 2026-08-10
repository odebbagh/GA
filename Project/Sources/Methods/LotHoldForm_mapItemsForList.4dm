//%attributes = {}
// Maps lotHold history items for listbox display (formatted time/action, sort keys).
#DECLARE($items : Collection)->$mapped : Collection

var $item : Object
var $row : Object
var $holdTime : Variant
var $holdDate : Date

$mapped:=New collection:C1472()

If ($items=Null:C1517)
	return $mapped
End if 

For each ($item; $items)
	$row:=LotHoldForm_cloneObject($item)
	
	$holdDate:=Choose:C955($row.date#Null:C1517; $row.date; $row.holdDate)
	$holdTime:=Choose:C955($row.time#Null:C1517; $row.time; $row.holdTime)
	
	Case of 
		: ($holdTime=Null:C1517)
			$row.timeDisplay:=""
		: (Value type:C1509($holdTime)=Is time:K8:8)
			$row.timeDisplay:=String:C10($holdTime; HH MM:K7:2)
		: ((Value type:C1509($holdTime)=Is real:K8:4) | (Value type:C1509($holdTime)=Is longint:K8:6))
			$row.timeDisplay:=String:C10(Time:C179($holdTime); HH MM:K7:2)
		: (String:C10($holdTime)="")
			$row.timeDisplay:=""
		Else 
			$row.timeDisplay:=String:C10($holdTime)
	End case 
	$row.sortDate:=$holdDate
	$row.sortTime:=Time:C179($holdTime)
	
	Case of 
		: ($row.action="on")
			$row.actionDisplay:="on"
		: ($row.action="off")
			$row.actionDisplay:="off"
		: (String:C10($row.holdAction)="Hold ON")
			$row.actionDisplay:="Hold ON"
		: (String:C10($row.holdAction)="Hold OFF")
			$row.actionDisplay:="Hold OFF"
		: ($row.action#Null:C1517)
			$row.actionDisplay:=String:C10($row.action)
		Else 
			$row.actionDisplay:=String:C10($row.holdAction)
	End case 
	
	If ($row.hold_reason=Null:C1517) && ($row.holdReason#Null:C1517)
		$row.hold_reason:=$row.holdReason
	End if 
	If ($row.hold_code=Null:C1517) && ($row.holdCode#Null:C1517)
		$row.hold_code:=$row.holdCode
	End if 
	
	$mapped.push($row)
End for each 
