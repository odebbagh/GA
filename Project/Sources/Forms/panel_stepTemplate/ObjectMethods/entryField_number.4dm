
C_LONGINT:C283($templateNumber)
C_COLLECTION:C1488($numbers)
C_LONGINT:C283($next)

$numbers:=ds:C1482.StepTemplate.all().orderBy("templateNumber asc").extract("templateNumber")
$numbers:=$numbers.orderBy("asc")
$next:=1
For each ($num; $numbers)
	$next:=$num+1
End for each 


$templateNumber:=Form:C1466.current_item.templateNumber
$existing:=ds:C1482.StepTemplate.query("templateNumber = :1"; $templateNumber)
If ($existing.length>0)  // Assign the smallest available template ID
	ALERT:C41("Template number already exists")
	Form:C1466.current_item.templateNumber:=$next
End if 

