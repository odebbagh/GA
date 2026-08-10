//%attributes = {}
#DECLARE($text : Text)->$safe : Text

$safe:=String:C10($text)
$safe:=Replace string:C233($safe; "##"; "")
$safe:=Replace string:C233($safe; Char:C90(13)+Char:C90(10); " ")
$safe:=Replace string:C233($safe; Char:C90(13); " ")
$safe:=Replace string:C233($safe; Char:C90(10); " ")
