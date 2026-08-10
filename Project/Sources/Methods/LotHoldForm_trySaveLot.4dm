//%attributes = {}
// Attempts to save a lot entity. Returns success=false when the record is locked or save fails.
#DECLARE($lot : 4D:C1709.Entity)->$result : Object

var $saveResult : Object

$result:=New object:C1471("success"; False:C215)

If ($lot=Null:C1517)
	return $result
End if 

$saveResult:=$lot.save()
$result.success:=Bool:C1537($saveResult.success)

return $result
