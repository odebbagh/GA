//%attributes = {}
// Purpose: Format creationDateTimeStamp for document list display.
// Return a display row; never write back onto the entity document object (that marks the record dirty on mere selection).
// modified by 4D/PS [2026-october-05]

var $time; $days : Integer
var $TimeType : Time
var $formatted : Text
var $src; $row : Object

If ($1.value=Null:C1517)
	$1.result:=New object:C1471
	return 
End if 

$src:=$1.value

If (Num:C11($src.creationDateTimeStamp)=0)
	$formatted:=""
Else 
	$days:=Trunc:C95($src.creationDateTimeStamp/86400; 0)
	$time:=$src.creationDateTimeStamp%86400
	$TimeType:=?00:00:00?+$time
	$formatted:=String:C10((Add to date:C393(!00-00-00!; 2000; 1; 1)+$days); System date short:K1:1)+"   "+String:C10($TimeType; HH MM:K7:2)
End if 

$row:=New object:C1471
$row.code:=$src.code
$row.sourcePath:=$src.sourcePath
$row.description:=$src.description
$row.isApproved:=$src.isApproved
$row.creationDateTimeStamp:=$src.creationDateTimeStamp
$row.creationDateTime:=$formatted
$row.blob:=$src.blob
$1.result:=$row
