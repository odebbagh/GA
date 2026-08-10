//%attributes = {"executedOnServer":true}
/**
import buyingOrders
**/
If (True:C214)
	
	TRUNCATE TABLE:C1051([BuyingOrder:46])
	
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/buy_orders_export.json")
	
	$records:=JSON Parse:C1218($file.getText())
	
	$terms:=WP Import document:C1318(Folder:C1567(fk data folder:K87:12).file("DataJson/BuyOrderTerms.4wp").platformPath)
	$termsCriticalMaterials:=WP Import document:C1318(Folder:C1567(fk data folder:K87:12).file("DataJson/BuyOrderTerms_CriticalMaterials.4wp").platformPath)
	$termsCriticalService:=WP Import document:C1318(Folder:C1567(fk data folder:K87:12).file("DataJson/BuyOrderTerms_CriticalService.4wp").platformPath)
	
	For each ($record; $records)
		$buyingOrder:=ds:C1482.BuyingOrder.new()
		
		$buyingOrder.boNumber:=$record.SEQ_NUM
		$buyingOrder.orderStmp:=Date:C102($record.ISSUE_DATE)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($record.ISSUE_DATE))
		$buyingOrder.buyOrderLimit:=$record.BO_limit
		//$buyingOrder.accountNumber:=$record.accountNumber
		$buyingOrder.salesTaxRate:=$record.ST_rate
		$buyingOrder.currency:=$record.Currency
		$buyingOrder.discount:=$record.Discount
		$buyingOrder.discountDays:=$record.DDAYS
		$buyingOrder.netDays:=$record.NetDays
		$buyingOrder.shippingAddress:=$record.ShippingAddr
		$buyingOrder.fob:=$record.FOB
		$buyingOrder.shipVia:=$record.ShipVia
		$buyingOrder.division:=$record.Division
		$buyingOrder.requestedBy:=$record.Requestor
		$buyingOrder.salesTax:=$record.T_salestax
		$buyingOrder.lineItemsTotal:=$record.T_Amt
		$buyingOrder.approver1:=$record.Approver1
		$buyingOrder.approver2:=$record.Approver2
		$buyingOrder.signature1:=$record.Signature1
		$buyingOrder.signature2:=$record.Signature2
		$buyingOrder.buyer:=$record.Buyer
		
		$buyingOrder.terms:=$terms
		$buyingOrder.termsCriticalMaterials:=$termsCriticalMaterials
		$buyingOrder.termsCriticalService:=$termsCriticalService
		
		$vendor:=ds:C1482.Supplier.query("name =:1"; Split string:C1554($record.VENDOR; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($vendor.length>0)
			//If ($record.VENDOR="XYZ@")
			
			//End if 
			$buyingOrder.UUID_Supplier:=$vendor[0].UUID
		Else 
			$buyingOrder.UUID_Supplier:="00"*16
			
		End if 
		
		
		$res:=$buyingOrder.save()
		
		If (Not:C34($res.success))
			TRACE:C157
		End if 
	End for each 
	
	
	$buyItems_file:=Folder:C1567(fk data folder:K87:12).file("DataJson/buy_items_export.json")
	var $text : Text:=""
	If ($buyItems_file.exists)
		$buyItems:=JSON Parse:C1218($buyItems_file.getText())
		TRUNCATE TABLE:C1051([BuyingOrderLine:64])
		
		For each ($buyItem; $buyItems)
			
			$eBuyItem:=ds:C1482.BuyingOrderLine.new()
			
			$BuyOrder:=ds:C1482.BuyingOrder.query("boNumber =:1"; $buyItem.PO_NUM)
			If ($BuyOrder.length>0)
				$eBuyItem.UUID_BuyingOrder:=$BuyOrder[0].UUID
			Else 
				$eBuyItem.UUID_BuyingOrder:="00"*16
				
			End if 
			
			$eBuyItem.boNumber:=$buyItem.PO_NUM
			$eBuyItem.description:=$buyItem.Description
			$eBuyItem.qty:=$buyItem.QTY
			$eBuyItem.unitPrice:=$buyItem.Unit_Price
			$eBuyItem.lineTotal:=$buyItem.Line_total
			$eBuyItem.glAccount:=$buyItem.Glac
			$eBuyItem.orderStmp:=Date:C102($buyItem.Order_Date)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($buyItem.Order_Date))
			$eBuyItem.requiredStmp:=Date:C102($buyItem.Date_required)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($buyItem.Date_required))
			$eBuyItem.inStmp:=Date:C102($buyItem.Date_in)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($buyItem.Date_in))
			$eBuyItem.checkNumber:=$buyItem.Check_num
			$eBuyItem.paidStmp:=Date:C102($buyItem.Paid_date)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($buyItem.Paid_date))
			$eBuyItem.amountPaid:=$buyItem.T_paid
			$eBuyItem.jobNumber:=$buyItem.Int_jobnum
			$eBuyItem.assetListNumber:=$buyItem.Assetlist_num
			$eBuyItem.supPsNumber:=$buyItem.Sup_ps_num
			
			$res:=$eBuyItem.save()
			
			If (Not:C34($res.success))
				TRACE:C157
			End if 
			
			
		End for each 
	End if 
	
Else 
	
	TRUNCATE TABLE:C1051([BuyingOrder:46])
	
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/buyOrders_export.json")
	
	$records:=JSON Parse:C1218($file.getText())
	
	$terms:=WP Import document:C1318(Folder:C1567(fk data folder:K87:12).file("DataJson/terms.4wp").platformPath)
	$termsCriticalMaterials:=WP Import document:C1318(Folder:C1567(fk data folder:K87:12).file("DataJson/termsCriticalMaterials.4wp").platformPath)
	$termsCriticalService:=WP Import document:C1318(Folder:C1567(fk data folder:K87:12).file("DataJson/termsCriticalService.4wp").platformPath)
	
	For each ($record; $records)
		$buyingOrder:=ds:C1482.BuyingOrder.new()
		
		$buyingOrder.boNumber:=$record.boNumber
		$buyingOrder.orderStmp:=cs:C1710.sfw_stmp.me.build(Date:C102($record.orderDate))
		$buyingOrder.buyOrderLimit:=$record.buyOrderLimit
		//$buyingOrder.accountNumber:=$record.accountNumber
		$buyingOrder.salesTaxRate:=$record.salesTaxRate
		$buyingOrder.currency:=$record.currency
		$buyingOrder.discount:=$record.discount
		$buyingOrder.discountDays:=$record.discountDays
		$buyingOrder.netDays:=$record.netDays
		$buyingOrder.shippingAddress:=$record.shippingAddress
		$buyingOrder.fob:=$record.fob
		$buyingOrder.shipVia:=$record.shipVia
		$buyingOrder.division:=$record.division
		$buyingOrder.requestedBy:=$record.requestedBy
		$buyingOrder.salesTax:=$record.salesTax
		$buyingOrder.lineItemsTotal:=$record.lineItemsTotal
		$buyingOrder.approver1:=$record.approver1
		$buyingOrder.approver2:=$record.approver2
		$buyingOrder.signature1:=$record.signature1
		$buyingOrder.signature2:=$record.signature2
		$buyingOrder.terms:=$terms
		$buyingOrder.termsCriticalMaterials:=$termsCriticalMaterials
		$buyingOrder.termsCriticalService:=$termsCriticalService
		
		$res:=$buyingOrder.save()
		
		If (Not:C34($res.success))
			
		Else 
			If (Not:C34(Undefined:C82($buyingOrder.lines)))
				
				For each ($line; $buyingOrder.lines)
					$bo_line_e:=ds:C1482.BuyingOrderLine.new()
					
					$bo_line_e.boNumber:=$line.order
					$bo_line_e.description:=$line.description
					$bo_line_e.qty:=$line.qty
					$bo_line_e.unitPrice:=$line.unitPrice
					$bo_line_e.lineTotal:=$line.lineTotal
					$bo_line_e.glAccount:=$line.glAccount
					$bo_line_e.orderStmp:=cs:C1710.sfw_stmp.me.build(Date:C102($line.orderDate))
					$bo_line_e.requiredStmp:=cs:C1710.sfw_stmp.me.build(Date:C102($line.requiredDate))
					$bo_line_e.inStmp:=cs:C1710.sfw_stmp.me.build(Date:C102($line.dateIn))
					$bo_line_e.checkNumber:=$line.checkNumber
					$bo_line_e.paidStmp:=cs:C1710.sfw_stmp.me.build(Date:C102($line.paidDate))
					$bo_line_e.amountPaid:=$line.amountPaid
					$bo_line_e.jobNumber:=$line.jobNumber
					$bo_line_e.assetListNumber:=$line.assetListNumber
					$bo_line_e.supPsNumber:=$line.supPsNumber
					
					$res:=$bo_line_e.save()
					
					If (Not:C34($res.success))
						TRACE:C157
					End if 
				End for each 
				
			End if 
			
		End if 
	End for each 
End if 
