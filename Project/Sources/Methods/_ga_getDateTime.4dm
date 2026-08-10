//%attributes = {}

var $time; $days : Integer
var $TimeType : Time
$days:=Trunc:C95($1.value.creationDateTimeStamp/86400; 0)
$time:=$1.value.creationDateTimeStamp%86400
$TimeType:=?00:00:00?+$time

$1.value.creationDateTime:=String:C10((Add to date:C393(!00-00-00!; 2000; 1; 1)+$days); System date short:K1:1)+"   "+String:C10($TimeType; HH MM:K7:2)

$1.result:=$1.value
