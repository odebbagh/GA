//%attributes = {"executedOnServer":true}
// __import_operationTypes
// Fills [OperationType] with the five operation types used by the application:
// AI, BI, EI, FT and WS.
//
// The table is emptied first, so the method is re-runnable: running it twice leaves
// the same five records rather than duplicating them. ID is an autosequence field,
// so it is left for 4D to assign.

var $names : Collection
var $name : Text
var $operationType : cs:C1710.OperationTypeEntity
var $result : Object
var $created : Integer
var $errors : Text

$names:=New collection:C1472("AI"; "BI"; "EI"; "FT"; "WS")

TRUNCATE TABLE:C1051([OperationType:104])

$created:=0
$errors:=""

For each ($name; $names)
	
	$operationType:=ds:C1482.OperationType.new()
	$operationType.name:=$name
	
	$result:=$operationType.save()
	
	If ($result.success)
		$created:=$created+1
	Else
		$errors:=$errors+"\r"+$name+": "+JSON Stringify:C1217($result)
	End if 
	
End for each 

If ($errors="")
	ALERT:C41("Import termine - OperationType : "+String:C10($created)+" enregistrement(s) cree(s)")
Else
	ALERT:C41("Import termine - OperationType : "+String:C10($created)+" enregistrement(s) cree(s) | echecs :"+$errors)
End if 
