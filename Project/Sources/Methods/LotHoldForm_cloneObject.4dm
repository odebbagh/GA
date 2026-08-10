//%attributes = {}
// Deep-clones a plain object using JSON (no legacy OB commands).
#DECLARE($source : Object)->$clone : Object

If ($source=Null:C1517)
	$clone:=New object:C1471
Else 
	$clone:=JSON Parse:C1218(JSON Stringify:C1217($source))
End if 
