//%attributes = {}
// Returns true when two lotHold event objects represent the same history entry.
#DECLARE($a : Object; $b : Object)->$match : Boolean

var $dateA : Date
var $dateB : Date
var $timeA : Time
var $timeB : Time
var $actionA : Text
var $actionB : Text

$match:=False:C215

If ($a=Null:C1517) || ($b=Null:C1517)
	return $match
End if 

$dateA:=Choose:C955($a.date#Null:C1517; $a.date; $a.holdDate)
$dateB:=Choose:C955($b.date#Null:C1517; $b.date; $b.holdDate)
$timeA:=Choose:C955($a.time#Null:C1517; $a.time; $a.holdTime)
$timeB:=Choose:C955($b.time#Null:C1517; $b.time; $b.holdTime)
$actionA:=Choose:C955($a.action#Null:C1517; $a.action; $a.holdAction)
$actionB:=Choose:C955($b.action#Null:C1517; $b.action; $b.holdAction)

$match:=($dateA=$dateB) && ($timeA=$timeB) && ($actionA=$actionB)
