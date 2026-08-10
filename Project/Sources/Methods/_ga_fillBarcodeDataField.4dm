//%attributes = {"executedOnServer":true}
/*
_ga_fillBarcodeDataField

*/


//For ($tableNumber; 1; Last table number)
For ($tableNumber; 118; 118)
	
	If (Is table number valid:C999($tableNumber))
		$tableName:=Table name:C256($tableNumber)
		//$entityName:=$tableName+"$entity"
		
		If ($tableName#"sfw_@") & ($tableName#"dfd_@")
			
			For each ($entity; ds:C1482[$tableName].all())
				//var $entity : cs[$entityName]
				If ($entity.moreData=Null:C1517)
					$entity.moreData:=New object:C1471()
				End if 
				$recodNumber:=ds:C1482.sfw_Counter.getNextValue($tableName)
				$entity.moreData.barcodeData:=String:C10($recodNumber; "0000000000")
				$res:=$entity.save()
				
				If (Not:C34($res.success))
					TRACE:C157
				End if 
				
			End for each 
			
		End if 
		
	End if 
	
End for 


