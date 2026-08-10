Case of 
	: (FORM Event:C1606.code=On Before Keystroke:K2:6)
		
		Form:C1466.previousSN:=Form:C1466.snItem.serial_number
		
	: (FORM Event:C1606.code=On Data Change:K2:15)
		
		START TRANSACTION:C239
		$FailedSave:=False:C215
		For each ($step; Form:C1466.current_item.lotSteps)
			If (($step.snTable#Null:C1517) && ($step.snTable.items#Null:C1517))
				$item:=$step.snTable.items.query("id = :1"; Form:C1466.snItem.id)
				If ($item.length>0)
					$item[0].serial_number:=Form:C1466.snItem.serial_number
					$step.snTable:=$step.snTable  // touch the object attribute so save() persists the nested change
					$result:=$step.save()
					If (Not:C34($result.success))
						$FailedSave:=True:C214
					End if
				End if
			End if
		End for each
		
		If ($FailedSave)
			Form:C1466.snItem.serial_number:=Form:C1466.previousSN
			CANCEL TRANSACTION:C241
			ALERT:C41("One or more steps are locked, please free the record to update the serial number.")
		Else 
			VALIDATE TRANSACTION:C240
		End if 
		
End case 