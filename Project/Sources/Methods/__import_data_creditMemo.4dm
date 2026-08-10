//%attributes = {"executedOnServer":true}




var $records : Collection:=New collection:C1472()


If (True:C214)
	
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/Credit_Memo_list_export.json")
	
	$records:=JSON Parse:C1218($file.getText())
	
	TRUNCATE TABLE:C1051([CreditMemo:78])
	For each ($record; $records)
		
		$eCreditMemo:=ds:C1482.CreditMemo.new()
		$eCreditMemo.cmTotal:=$record.CM_total
		$eCreditMemo.cmNum:=$record.CMnum
		$eCreditMemo.cmStmp:=Date:C102($record.CM_date)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($record.CM_date))  //$record.dateCreated
		$eCreditMemo.salesTax:=$record.Sales_Tax
		$eCreditMemo.description:=$record.totalBalance
		$eCreditMemo.reason:=$record.Reason
		$eCreditMemo.enteredBy:=$record.Entered_by
		$eCreditMemo.approvedBy:=$record.Approved_by
		
		$division:=ds:C1482.Division.query("name =:1"; Split string:C1554($record.Division; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($division.length>0)
			$eCreditMemo.UUID_Division:=$division[0].UUID
		Else 
			$eCreditMemo.UUID_Division:="00"*16
		End if 
		
		
		$info:=$eCreditMemo.save()
		
		If (Not:C34($info.success))
			TRACE:C157
		End if 
		
	End for each 
	
End if 



//$cmItems:=Folder(fk data folder).file("DataJson/CM_items_list_export.json")
//CM_items
If (True:C214)
	
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/CM_items_list_export.json")
	
	$records:=JSON Parse:C1218($file.getText())
	
	TRUNCATE TABLE:C1051([CMItem:79])
	For each ($record; $records)
		
		$eCmItem:=ds:C1482.CMItem.new()
		$eCmItem.amount:=$record.Amt
		$eCmItem.currency:=$record.Currency
		$eCmItem.salesTaxPortion:=$record.SalesTaxPortion
		
		$creditMemo:=ds:C1482.CreditMemo.query("cmNum =:1"; $record.CMnum)
		If ($creditMemo.length>0)
			$eCmItem.UUID_CreditMemo:=$creditMemo[0].UUID
		Else 
			$eCmItem.UUID_CreditMemo:="00"*16
		End if 
		
		
		$customer:=ds:C1482.Customer.query("name =:1"; Split string:C1554($record.Customer; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($customer.length>0)
			$eCmItem.UUID_Customer:=$customer[0].UUID
		Else 
			$eCmItem.UUID_Customer:="00"*16
		End if 
		
		$invoice:=ds:C1482.Invoice.query("invoice =:1"; String:C10($record.Invoice))
		If ($invoice.length>0)
			$eCmItem.UUID_Invoice:=$invoice[0].UUID
			If ($record.Invoice>0) & ($record.Invoice=1502)
				
			End if 
			
		Else 
			If ($record.Invoice>0) & ($record.Invoice=1502)
				
			End if 
			
			$eCmItem.UUID_Invoice:="00"*16
		End if 
		
		
		$info:=$eCmItem.save()
		
		If (Not:C34($info.success))
			TRACE:C157
		End if 
		
	End for each 
	
End if 



