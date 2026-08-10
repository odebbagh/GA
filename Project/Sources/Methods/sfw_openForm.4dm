//%attributes = {}
#DECLARE($formData : Object)

If ($formData.current_uuid#Null:C1517) && ($formData.current_item=Null:C1517)
	$formData.current_item:=ds:C1482[$formData.sfw.entry.dataclass].get($formData.current_uuid)
End if 

$formData.sfw._openFormInProcess($formData)