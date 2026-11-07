//%attributes = {}
// Purpose: Collection.map helper — return the year of a date value.
// created by 4D/PS [2026-june-08]
// modified by 4D/PS [2026-october-05]
If ($1.value=Null:C1517)
	$1.result:=0
Else 
	$1.result:=Year of:C25(Date:C102($1.value))
End if 
