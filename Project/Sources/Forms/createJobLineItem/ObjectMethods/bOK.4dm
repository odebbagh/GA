
var $eJobLineItem : cs:C1710.JobLineItemEntity

Case of 
		
	: (Form:C1466.operation="create")
		$eJobLineItem:=ds:C1482.JobLineItem.new()
		$eJobLineItem:=Form:C1466.lineItem
		$eJobLineItem.UUID_Job:=Form:C1466.jobUUID
		$info:=$eJobLineItem.save()
		
		If (Not:C34($info.success))
			TRACE:C157
		End if 
		
	: (Form:C1466.operation="modify")
		$eJobLineItem:=ds:C1482.JobLineItem.get(Form:C1466.lineItem.UUID)
		$eJobLineItem:=Form:C1466.lineItem
		//$eJobLineItem.UUID_Job:=Form.jobUUID
		$info:=$eJobLineItem.save()
		
		If (Not:C34($info.success))
			TRACE:C157
		End if 
		
		
	Else 
		
End case 