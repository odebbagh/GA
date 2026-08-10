//%attributes = {}
TRUNCATE TABLE:C1051([Division:20])

$division:=ds:C1482.Division.new()
$division.name:="GAC"
$result:=$division.save()

If ($result.success)
	ALERT:C41("1 Division Created")
Else 
	ALERT:C41("Division Creation Failed!")
End if 