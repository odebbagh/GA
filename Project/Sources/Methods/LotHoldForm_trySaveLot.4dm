//%attributes = {}
// Attempts to save a lot entity. Returns success=false when the record is locked or save fails.
// Every lot save that does not go through the Save button (holds and hold forms from Punch In /
// Punch Out) passes here, so this is also where those changes enter the lot history
// (ga_events): the framework event log never sees them.
#DECLARE($lot : 4D:C1709.Entity)->$result : Object

var $saveResult : Object
var $before : Object

$result:=New object:C1471("success"; False:C215)

If ($lot=Null:C1517)
	return $result
End if 

$before:=cs:C1710.ga_events.me.storedState($lot; New collection:C1472("lotHold"; "NCMN"; "ISSNF"; "snTable"))
$saveResult:=$lot.save()
$result.success:=Bool:C1537($saveResult.success)

If ($result.success)
	cs:C1710.ga_events.me.logLotSave($before; $lot)
End if 

return $result
