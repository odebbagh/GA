//%attributes = {}
// Serial numbers printed under an SN step of the Lot Traveller, six units a row:
// - SNA (all units): every unit on the step's list, with its result once the step is punched out;
// - SNF (fails only): before punch out every unit, boxes blank for the floor to mark the fails;
//   after punch out only the units that failed.
// Before punch out the results stay blank: the traveller is filled in by hand on the floor.
#DECLARE($step : 4D:C1709.Entity)->$result : Object

var $cells : Collection
var $done : Boolean
var $failCount : Integer
var $failsOnly : Boolean
var $i : Integer
var $k : Integer
var $row : Object
var $title : Text
var $unit : Object
var $units : Collection

$result:=New object:C1471(\
"hasSn"; False:C215; \
"snH"; New collection:C1472(); \
"sns"; New collection:C1472()\
)

If ($step=Null:C1517)
	return $result
End if
If (Not:C34(cs:C1710.ga_serialization.me.isSnStep($step)))
	return $result
End if
If ($step.snTable=Null:C1517) || ($step.snTable.items=Null:C1517) || ($step.snTable.items.length=0)
	return $result
End if

$done:=($step.dateOut#!00-00-00!) || ($step.qtyOut>0)
$failsOnly:=Not:C34(cs:C1710.ga_serialization.me.hasProperty($step; "SNA"))
$units:=$step.snTable.items.orderBy("id asc")

$failCount:=0
For each ($unit; $units)
	If (Not:C34(Bool:C1537($unit.pass)))
		$failCount:=$failCount+1
	End if
End for each

$cells:=New collection:C1472()
For each ($unit; $units)
	Case of
		: (Not:C34($done))
			$cells.push(String:C10($unit.id))
		: (Bool:C1537($unit.pass)) && ($failsOnly)
		: (Bool:C1537($unit.pass))
			$cells.push(String:C10($unit.id)+"  Pass")
		Else
			$cells.push(String:C10($unit.id)+"  FAIL")
	End case
End for each

Case of
	: (Not:C34($done)) && ($failsOnly)
		$title:="Serial numbers, "+String:C10($units.length)+" units: mark the fails"
	: (Not:C34($done))
		$title:="Serial numbers, "+String:C10($units.length)+" units"
	: ($failsOnly) && ($failCount=0)
		$title:="Serial numbers: no unit failed"
	: ($failsOnly)
		$title:="Serial numbers, failed units: "+String:C10($failCount)
	Else
		$title:="Serial numbers, "+String:C10($units.length)+" units: "+String:C10($units.length-$failCount)+" pass, "+String:C10($failCount)+" fail"
End case

$result.hasSn:=True:C214
$result.snH.push(New object:C1471("snHeader"; Planning_travSanitizeText($title)))

For ($i; 0; $cells.length-1; 6)
	$row:=New object:C1471()
	For ($k; 1; 6)
		$row["sn"+String:C10($k)]:=""
		If ($i+$k-1<$cells.length)
			$row["sn"+String:C10($k)]:=Planning_travSanitizeText($cells[$i+$k-1])
		End if
	End for
	$result.sns.push($row)
End for
