//%attributes = {}

$uuidHex:=$1
$blob:=BLOB from hex($uuidHex)
$base64:=BLOB to base64($blob)
$0:=$base64



