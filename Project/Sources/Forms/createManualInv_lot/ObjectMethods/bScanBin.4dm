Case of
	: (FORM Event:C1606.code=On Clicked:K2:4)

		var $barcodeData : Text
		var $bin : cs:C1710.BinEntity

		/*
		$barcodeData:=cs.Util_ScannerManager.me.communicateWithScanner()

		If ($barcodeData="")
			return
		End if
		*/
		
		var $scanResult : Object
		
		$scanResult:=cs:C1710.Util_ScannerManager.me.communicateWithScanner()
		
		If ($scanResult.cancelled)
			return
		End if
		
		If ($scanResult.manualEntry)
			return
		End if
		
		$barcodeData:=$scanResult.barcodeData
		If ($barcodeData="")
			return
		End if

		// Resolve the bin from its scanned barcode (Bin.moreData.barcodeData)
		$bin:=ds:C1482.Bin.query("moreData.barcodeData = :1"; $barcodeData).first()

		If ($bin=Null:C1517)
			cs:C1710.sfw_dialog.me.alert("The scanned barcode does not correspond to any bin.")
			return
		End if

		// Load the bin location into the field, same as the "choose bin location" picker
		Form:C1466.inventory_e.UUID_Location:=$bin.UUID
		Form:C1466.inventory_e.location:=$bin.binLocationPath
		Form:C1466.currentPath:=$bin.binLocationPath
		Form:C1466.selectedBins:=Storage:C1525.cache.bins.query("binLocationPath = :1"; $bin.binLocationPath)
		OBJECT SET TITLE:C194(*; "pup_binLocation"; $bin.binLocationPath)

	: (FORM Event:C1606.code=On Mouse Enter:K2:33)
		SET CURSOR:C469(Choose:C955(OBJECT Get enabled:C1079(Self:C308->); 9000; 9019))

	: (FORM Event:C1606.code=On Mouse Leave:K2:34)
		SET CURSOR:C469()
End case
