Class extends Entity

local Function loadAfterCreation()
	// Purpose: Assign a unique barcode in moreData for scanner lookup on new records.
	// modified by 4D/PS [2026-june-29]
	// modified by 4D/PS [2026-october-05]
	var $maxNumber : Integer
	
	If (This:C1470.moreData=Null:C1517)
		This:C1470.moreData:=New object:C1471
	End if 
	This:C1470.moreData.barcodeData:=String:C10(cs:C1710.Util_ScannerManager.me.getBarcodeData(Form:C1466.sfw.entry.dataclass); "0000000000")
	$maxNumber:=Num:C11(ds:C1482.RMA.all().max("rmaNumber"))
	This:C1470.rmaNumber:=($maxNumber>0) ? ($maxNumber+1) : 1
	
Function get dateClose()->$closeDate : Date
	$closeDate:=This:C1470.stmpClose=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpClose; True:C214)
	
Function set dateClose($closeDate : Date)
	This:C1470.stmpClose:=$closeDate=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($closeDate)
	
Function get dateReceived()->$receivedDate : Date
	$receivedDate:=This:C1470.stmpReceived=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.stmpReceived; True:C214)
	
Function set dateReceived($receivedDate : Date)
	This:C1470.stmpReceived:=$receivedDate=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($receivedDate)
	
