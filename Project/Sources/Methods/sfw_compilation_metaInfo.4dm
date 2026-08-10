//%attributes = {}

#DECLARE($compilation : Object)->$meta : Object


$meta:=New object:C1471
If ($compilation.isError)
	$meta.fill:="#ff8566"
Else 
	$meta.fill:="#ffdb4d"
End if 


