//%attributes = {"executedOnServer":true}
/*
Bin_fillBarcodeData

One-time backfill: assign moreData.barcodeData to existing bins that don't have
one yet, using the same counter scheme as BinEntity.loadAfterCreation
(sfw_Counter, 10-digit zero-padded). Idempotent: bins that already have a
barcodeData are left untouched, so it is safe to run more than once.
*/

var $bin : cs:C1710.BinEntity
var $res : Object
var $filled : Integer

$filled:=0

For each ($bin; ds:C1482.Bin.all())

	If ($bin.moreData=Null:C1517)
		$bin.moreData:=New object:C1471()
	End if

	If (String:C10($bin.moreData.barcodeData)="")
		$bin.moreData.barcodeData:=String:C10(ds:C1482.sfw_Counter.getNextValue("Bin"); "0000000000")
		$res:=$bin.save()
		If ($res.success)
			$filled:=$filled+1
		Else
			TRACE:C157
		End if
	End if

End for each

ALERT:C41("Bins barcode backfill done - "+String:C10($filled)+" bin(s) updated.")
