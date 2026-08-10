
Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		var $ePoLine : Object  //cs.PurchaseOrderLineEntity
		For each ($poLine; Form:C1466.selectedPoLines)
			$ePoLine:=ds:C1482.PurchaseOrderLine.query("UUID =:1"; $poLine.UUID).first()  //get($poLine.UUID)
			$statusLock:=$ePoLine.lock()  // Lock entity
			If ($statusLock.success)
				$ePoLine.UUID_Job:=Form:C1466.job.UUID
				
				$res:=$ePoLine.save()
				
				$statusUnLock:=$ePoLine.unlock()
			End if 
			
			If (Not:C34($res.success))
				TRACE:C157
			End if 
		End for each 
		
		ACCEPT:C269
End case 