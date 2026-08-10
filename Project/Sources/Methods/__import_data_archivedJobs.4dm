//%attributes = {"executedOnServer":true}
// Archived Lots -->{ARCHIVES] in the old sytem

If (True:C214)
	
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/archived_jobs_export.json")
	
	$records:=JSON Parse:C1218($file.getText())
	$counter:=ds:C1482.JobInvoice.all().extract("invoiceNumber").map(Formula:C1597(Num:C11($1.value))).max()
	
	For each ($record; $records)
		$counter:=$counter+1
		$job:=ds:C1482.Job.new()
		
		$job.jobNumber:=$record.jobNumber
		
		//$job.poNumber:=$record.poNumber
		$po_s:=ds:C1482.PurchaseOrder.query("oldPoNumber =:1"; Split string:C1554($record.poNumber; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($po_s.length>0)
			$job.poNumber:=$po_s[0].poNumber
			$job.UUID_PurchaseOrder:=$po_s[0].UUID
			
		Else 
			$job.poNumber:=0
		End if 
		
		$division:=ds:C1482.Division.query("name =:1"; Split string:C1554($record.division; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($division.length>0)
			$job.UUID_Division:=$division[0].UUID
		Else 
			
		End if 
		
		//$job.division:=$record.division
		$job.stmpCreated:=Date:C102($record.dateCreated)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($record.dateCreated))  //$record.dateCreated
		$job.stmpExpected:=(Date:C102($record.expectedDate)=!00-00-00!) | ($record.expectedDate=Null:C1517) ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($record.expectedDate))  //$record.expectedDate
		$job.stmpInvoiced:=Date:C102($record.invoiceDate)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($record.invoiceDate))  //$record.invoiceDate
		$job.stmpLastShipped:=Date:C102($record.lastShipDate)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($record.lastShipDate))  //$record.lastShipDate
		$job.stmpArchived:=Date:C102($record.archivedDate)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($record.archivedDate))  //$record.archivedDate
		
		$job.deviceNumber:=$record.deviceNumber
		$job.process:=$record.process
		$job.totalTax:=$record.salesTax
		$job.totalCharge:=$record.totalCharge
		$job.shipped:=$record.shipped
		$job.lineItem:=$record.lineItem
		$job.noLots:=$record.noLots
		$job.postToPO:=$record.postToPO
		$job.parentJobNumber:=$record.parentJobNumber
		$job.address:=$record.address
		$job.alternateShipAddress:=$record.alternateShipAddress
		$job.shippers:=$record.shippers
		
		$customer:=ds:C1482.Customer.query("name =:1"; Split string:C1554($record.customer; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($customer.length>0)
			$job.UUID_Customer:=$customer[0].UUID
		Else 
			
		End if 
		
		$job.customerName:=$record.customer
		$job.qty:=$record.qty
		$job.qtyOnHand:=$record.qtyOnHand
		$job.shipMemo:=$record.shipMemo
		$job.jobComment:=$record.jobComment
		$job.archived:=True:C214
		$job.pr_qualifier:=$record.pr_qualifier
		$job.dropShipCustomer:=$record.dropShipCustomer
		
		$job.smtpRecommit:=Date:C102($record.recommitDate)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($record.recommitDate))  //$record.recommitDate
		
		$job.currency:=$record.currency
		$job.altDeviceNumber:=$record.altDeviceNumber
		$job.customerShipper:=$record.customerShipper
		$job.initials:=$record.initials
		$job.miscCharges:=$record.miscCharges
		$job.miscNote:=$record.miscNote
		$job.glAcc:=$record.glAcc
		$job.taxable:=$record.taxable
		
		$salesTax:=ds:C1482.SalesTax.query("rate =:1"; $record.salesTaxRate)
		If ($salesTax.length>0)
			$job.UUID_SalesTax:=$salesTax[0].UUID
		Else 
			$job.UUID_SalesTax:=16*"00"
		End if 
		
		$job.freight:=$record.freight
		$job.minimumJobCharge:=$record.minimumJobCharge
		$job.boxStockShipment:=$record.boxStockShipment
		$job.poRel:=$record.poRel
		$job.packageType:=$record.packageType
		$job.testerType:=$record.testerType
		$job.acNote:=$record.acNote
		$job.inventoryCost:=$record.inventoryCost
		$job.directCost:=$record.directCost
		
		$res:=$job.save()
		If (Not:C34($res.success))
			TRACE:C157
		End if 
		
		//If ($job.shipped) & Not($job.postToPO)
		
		$jobInvoice:=ds:C1482.JobInvoice.new()
		
		$jobInvoice.UUID_Job:=$job.UUID
		$jobInvoice.invoiceNumber:=String:C10($counter; "00000#")
		$jobInvoice.invoiceStmp:=Date:C102($record.invoiceDate)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($record.invoiceDate))
		//$jobInvoice.status:="Paid" or "Closed"
		$jobInvoice.poBasedCharges:=$record.poBasedCharges
		$jobInvoice.travBasedCharges:=$record.travBasedCharges
		$jobInvoice.totalSalesTax:=$record.salesTax
		$jobInvoice.total:=$record.totalCharge
		
		$res:=$jobInvoice.save()
		
		If (Not:C34($res.success))
			TRACE:C157
		End if 
		
		//End if 
		
		
		//var $unitCost : cs.UnitCostEntity
		
		//$unitCost:=ds.UnitCost.query("device =:1"; $job.unitPriceCode).first()
		//If ($unitCost#Null)
		//$job.UUID_UnitCost:=$unitCost.UUID
		//End if 
		
		var $ejobLineItem : cs:C1710.JobLineItemEntity
		
		For each ($jobLineItem; $record.jobLineItems)
			
			$ejobLineItem:=ds:C1482.JobLineItem.new()
			$ejobLineItem.UUID_Job:=$job.UUID
			$ejobLineItem.description:=$jobLineItem.description
			$ejobLineItem.quantity:=$jobLineItem.quantity
			$ejobLineItem.unitPrice:=$jobLineItem.unitPrice
			$ejobLineItem.taxable:=$jobLineItem.taxable
			$ejobLineItem.lineTotal:=$jobLineItem.lineTotal
			$ejobLineItem.salesTax:=$jobLineItem.salesTax
			
			$res:=$ejobLineItem.save()
			If (Not:C34($res.success))
				TRACE:C157
			End if 
			
		End for each 
		
		
		For each ($poline; $record.poLines)
			
			$poLine_es:=ds:C1482.PurchaseOrderLine.query("seqNum = :1"; $poLine.seqNum)
			
			If ($poLine_es.length>0)
				$poLine_e:=$poLine_es[0]
				
				If ($poLine_e.purchaseOrder.oldPoNumber=$record.poNumber) & ($poline.description=$poLine_e.description)
					$poLine_e.UUID_Job:=$job.UUID
					$poLine_e.total:=$poline.total
					$poLine_e.saleTax:=$poline.saleTax
					$poLine_e.taxable:=$poline.taxable
					
					$res:=$poLine_e.save()
					
					If (Not:C34($res.success))
						TRACE:C157
					End if 
				End if 
			End if 
		End for each 
		
		
		For each ($lot; $record.lots)
			$lot_e:=ds:C1482.Lot.new()
			
			$lot_e.lotNumber:=$lot.lotNum
			$lot_e.dateIn:=$lot.dateIn
			$lot_e.dateOut:=$lot.dateOut
			$lot_e.process:=$lot.process
			$lot_e.device:=$lot.device
			$lot_e.altLotNumber:=$lot.altLotNumber
			$lot_e.deviceTableLink:=$lot.deviceTableLink
			$lot_e.currentOrNextArea:=$lot.currentOrNextArea
			$lot_e.onHold:=$lot.onHold
			$lot_e.holdDate:=$lot.holdDate
			$lot_e.holdTime:=$lot.holdTime
			
			$lot_e.poNumber:=$lot.poNumber
			
			$lot_e.customer:=$lot.customer
			$lot_e.commit:=$lot.commit
			$lot_e.reCommit:=$lot.reCommit
			$lot_e.original:=$lot.original
			$lot_e.progressive:=$lot.progressive
			$lot_e.ourCount:=$lot.ourCount
			$lot_e.totalTested:=$lot.totalTested
			$lot_e.az:=$lot.az
			$lot_e.et:=$lot.et
			$lot_e.OQADone:=$lot.OQADone
			$lot_e.OQADate:=$lot.OQADate
			$lot_e.OQASimpleSize:=$lot.OQASimpleSize
			$lot_e.releaseNumber:=$lot.releaseNumber
			$lot_e.trackingNumber:=$lot.trackingNumber
			$lot_e.readyToShipDate:=$lot.readyToShipDate
			$lot_e.shippingMemo:=$lot.shippingMemo
			$lot_e.location:=$lot.location
			$lot_e.comment:=$lot.comment
			$lot_e.status:=$lot.status
			$lot_e.cOfCInspector:=$lot.cOfCInspector
			$lot_e.packageType:=$lot.packageType
			$lot_e.dateCode:=$lot.dateCode
			$lot_e.carrier:=$lot.carrier
			$lot_e.shipRel:=$lot.shipRel
			$lot_e.totalCharge:=$lot.totalCharge
			$lot_e.unitCost:=$lot.unitCost
			
			$lot_e.UUID_Job:=$job.UUID
			
			If ($lot.parentLotNumber#"") & Not:C34(Undefined:C82($lot.parentLotNumber))
				$lots_es:=ds:C1482.Lot.query("lotNumber = :1"; $lot.parentLotNumber)
				
				If ($lots_es.length>0)
					$lot_e.UUID_LotParent:=$lots_es[0].UUID
				Else 
					TRACE:C157
				End if 
			End if 
			
			$res:=$lot_e.save()
			
			If (Not:C34($res.success))
				TRACE:C157
			Else 
				
				For each ($step; $lot.steps)
					$lotStep_e:=ds:C1482.LotStep.new()
					
					$lotStep_e.order:=$step.order
					$lotStep_e.description:=$step.description
					$lotStep_e.lotSpecs:=$step.lotSpecs
					$lotStep_e.specRevision:=$step.specRevision
					$lotStep_e.alert:=$step.alert
					$lotStep_e.qtyIn:=$step.qtyIn
					$lotStep_e.qtyOut:=$step.qtyOut
					$lotStep_e.dateIn:=$step.dateIn
					$lotStep_e.dateOut:=$step.dateOut
					$lotStep_e.timeIn:=$step.timeIn
					$lotStep_e.timeOut:=$step.timeOut
					$lotStep_e.discard:=$step.discard
					$lotStep_e.type:=$step.type
					$lotStep_e.outOperator:=$step.outOperator
					$lotStep_e.inOperator:=$step.inOperator
					$lotStep_e.actualHours:=$step.actualHours
					$lotStep_e.plannedHours:=$step.plannedHours
					$lotStep_e.tools:=New object:C1471()
					$lotStep_e.tools:=$step.tools
					$lotStep_e.areas:=$step.areas
					
					While ($lotStep_e.tools.items.indexOf("")#-1)
						
						$lotStep_e.tools.items:=$lotStep_e.tools.items.remove($lotStep_e.tools.items.indexOf(""))
						
					End while 
					
					$lotStep_e.parametricMeasurements:=New object:C1471("items"; New collection:C1472())
					$lotStep_e.stepInterruptions:=New object:C1471("items"; New collection:C1472())
					$lotStep_e.dataTables:=New object:C1471("items"; New collection:C1472())
					$lotStep_e.bins:=New object:C1471("items"; New collection:C1472())
					$lotStep_e.skills:=New object:C1471("items"; New collection:C1472())
					$lotStep_e.requitedCertifications:=New object:C1471("items"; New collection:C1472())
					
					
					$lotStep_e.UUID_Lot:=$lot_e.UUID
					
					$res:=$lotStep_e.save()
					
					If (Not:C34($res.success))
						TRACE:C157
					End if 
				End for each 
			End if 
			
		End for each 
		
		
	End for each 
	
	
/**
fix lotParent for some lots
**/
	
	$lots_es:=ds:C1482.Lot.all().minus(ds:C1482.Lot.all().lotParent.subLots).query("lotNumber = :1"; "@-@")
	
	For each ($lot; $lots_es)
		$parentLotNumber:=Split string:C1554($lot.lotNumber; "-")[0]
		
		$parent_es:=ds:C1482.Lot.query("lotNumber = :1"; $parentLotNumber)
		
		If ($parent_es.length>0)
			$lot.UUID_LotParent:=$parent_es[0].UUID
			
			$res:=$lot.save()
			
			If (Not:C34($res.success))
				TRACE:C157
			End if 
		End if 
	End for each 
	
End if 



