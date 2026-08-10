//%attributes = {}
/*

__import_data_salesTransaction

*/

var $records : Collection:=New collection:C1472()
var $vendors : Text

If (True:C214)
	
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/assetList_export.json")
	
	$records:=JSON Parse:C1218($file.getText())
	
	$transactionTypes:=New collection:C1472("Invoice"; "Credit Note"; "Debit Memo"; "")
	
	TRUNCATE TABLE:C1051([TransactionType:87])
	For ($i; 0; $transactionTypes.length-1)
		
		$transactionType:=ds:C1482.TransactionType.new()
		$transactionType.levelID:=$i+1
		$transactionType.name:=$transactionTypes[$i]
		$transactionType.color:=""
		$transactionType.save()
		
	End for 
	
	$transactionStatus:=New collection:C1472("Openor due in"; "Applied"; "Partially Paid"; "Applied"; "Closed"; "")
	
	TRUNCATE TABLE:C1051([TransactionStatus:88])
	For ($i; 0; $transactionStatus.length-1)
		
		$eTransactionStatus:=ds:C1482.TransactionStatus.new()
		$eTransactionStatus.levelID:=$i+1
		$eTransactionStatus.name:=$transactionStatus[$i]
		$eTransactionStatus.color:=""
		$eTransactionStatus.save()
		
	End for 
	
	
	
	
	
End if 




