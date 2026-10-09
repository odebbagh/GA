//%attributes = {}
// Purpose: Listbox display date for attached documents. Copy the row so the entity is not marked modified.
// modified by 4D/PS [2026-october-09]

var $time; $days : Integer
var $TimeType : Time
var $row : Object

$row:=OB Copy:C1225($1.value)
$days:=Trunc:C95(Num:C11($row.creationDateTimeStamp)/86400; 0)
$time:=Num:C11($row.creationDateTimeStamp)%86400
$TimeType:=?00:00:00?+$time

$row.creationDateTime:=String:C10((Add to date:C393(!00-00-00!; 2000; 1; 1)+$days); System date short:K1:1)+"   "+String:C10($TimeType; HH MM:K7:2)

$1.result:=$row
