//%attributes = {}

$base64:=$1
$blob:=BLOB from base64($base64)
$uuidHex:=BLOB to hex($blob)
$0:=$uuidHex
