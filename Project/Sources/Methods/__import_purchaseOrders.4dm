//%attributes = {"executedOnServer":true}
//var $eDepartment : cs.DepartmentEntity

/**
import step template
**/
If (True:C214)
	TRUNCATE TABLE:C1051([StepTemplate:121])
	TRUNCATE TABLE:C1051([StepTemplateRule:92])
	TRUNCATE TABLE:C1051([ContainerCode:93])
	
	var $rulesToImport : Collection
	$rulesToImport:=New collection:C1472(\
		New object:C1471("name"; "TransformationStep"; "description"; "Show Transformation Control (1)"; "mask"; 0x0001); \
		New object:C1471("name"; "LabelsButton"; "description"; "Show Labels Button (2)"; "mask"; 0x0002); \
		New object:C1471("name"; "ShowInpar1"; "description"; "Make [LOTSTEPS] field In_Par1 available (4)"; "mask"; 0x0004); \
		New object:C1471("name"; "ShowInpar2"; "description"; "Make [LOTSTEPS] field In_Par2 available (8)"; "mask"; 0x0008); \
		New object:C1471("name"; "ShowInpar3"; "description"; "Make [LOTSTEPS] field In_Par3 available (16)"; "mask"; 0x0010); \
		New object:C1471("name"; "ShowOutpar1"; "description"; "Make [LOTSTEPS] field Out_Par1 available (32)"; "mask"; 0x0020); \
		New object:C1471("name"; "ShowOutpar2"; "description"; "Make [LOTSTEPS] field Out_Par2 available (64)"; "mask"; 0x0040); \
		New object:C1471("name"; "ShowOutpar3"; "description"; "Make [LOTSTEPS] field Out_Par3 available (128)"; "mask"; 0x0080); \
		New object:C1471("name"; "ShowAuxillaryCounts"; "description"; "Make [LOTSTEPS] Auxillary-Count available (256)"; "mask"; 0x0100); \
		New object:C1471("name"; "MarkingPicture"; "description"; "Make marking picture available in traveler & lotstep"; "mask"; 0x0200); \
		New object:C1471("name"; "WaferSortSubTable"; "description"; "Wafer-Sort Template will enable Sub-table for each wafer"; "mask"; 0x0400); \
		New object:C1471("name"; "ElectricalTest"; "description"; "Electrical-Test Template"; "mask"; 0x0800); \
		New object:C1471("name"; "ElectricalTestRescreen"; "description"; "Electrical-Test-Rescreen Template"; "mask"; 0x1000); \
		New object:C1471("name"; "Bake"; "description"; "Bake"; "mask"; 0x2000); \
		New object:C1471("name"; "Reserved_Bit15"; "description"; "Reserved"; "mask"; 0x4000); \
		New object:C1471("name"; "Reserved_Bit16"; "description"; "Reserved"; "mask"; 0x8000); \
		New object:C1471("name"; "ShowComment1"; "description"; "Show Comment1 field"; "mask"; 0x00010000); \
		New object:C1471("name"; "ShowComment2"; "description"; "Show Comment2 field"; "mask"; 0x00020000); \
		New object:C1471("name"; "Reserved_Bit19"; "description"; "Reserved"; "mask"; 0x00040000); \
		New object:C1471("name"; "ShowTestWindowControl"; "description"; "Show Test-Window Control Check-Box"; "mask"; 0x00080000); \
		New object:C1471("name"; "MinWaitTimeWindow"; "description"; "Time Window specifies a minimum time wait instead of Max"; "mask"; 0x00100000); \
		New object:C1471("name"; "ListOfValuesDataTable"; "description"; "Data table is a list of values in column 2"; "mask"; 0x00200000); \
		New object:C1471("name"; "AutoWidthsForDataTableEPL"; "description"; "Column Widths in EPL for Data Table are set automatically"; "mask"; 0x00400000)\
		)
	
	For ($i; 0; $rulesToImport.length-1)
		$stepRule_e:=ds:C1482.StepTemplateRule.new()
		$stepRule_e.name:=$rulesToImport[$i].name
		$stepRule_e.description:=$rulesToImport[$i].description
		$stepRule_e.levelID:=$i+1
		
		$res:=$stepRule_e.save()
		
		If (Not:C34($res.success))
			TRACE:C157
		End if 
		
	End for 
	
	
	var $containerCodesToImport : Collection
	$containerCodesToImport:=New collection:C1472(\
		New object:C1471("name"; "DisplayContainerList"; "description"; "Display Container List / BI Board draw button"; "mask"; 0x0001); \
		New object:C1471("name"; "AllowLoadingContainers"; "description"; "Allow loading of Containers"; "mask"; 0x0002); \
		New object:C1471("name"; "AllowUnloadingContainers"; "description"; "Allow unloading of Containers"; "mask"; 0x0004); \
		New object:C1471("name"; "MandatoryContainerCheck"; "description"; "Perform mandatory check of Container-list during punch-in"; "mask"; 0x0008); \
		New object:C1471("name"; "CollectAttributeData"; "description"; "Collect Attribute Data"; "mask"; 0x1000); \
		New object:C1471("name"; "CopyCountRulesToProperty"; "description"; "Outside of Count Rules Copied from Template to LotStep Property"; "mask"; 0x00100000); \
		New object:C1471("name"; "FinalQAApprovalStamp"; "description"; "Final QA Approval with Stamp"; "mask"; 0x00200000)\
		)
	
	For ($i; 0; $containerCodesToImport.length-1)
		$containerCode_e:=ds:C1482.ContainerCode.new()
		$containerCode_e.name:=$containerCodesToImport[$i].name
		$containerCode_e.description:=$containerCodesToImport[$i].description
		$containerCode_e.levelID:=$i+1
		
		$res:=$containerCode_e.save()
		
		If (Not:C34($res.success))
			TRACE:C157
		End if 
		
	End for 
	
	
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/step_template_export.json")
	
	$records:=JSON Parse:C1218($file.getText())
	
	For each ($record; $records)
		$stepTemplate_e:=ds:C1482.StepTemplate.new()
		
		$stepTemplate_e.name:=$record.name
		
		//$stepTemplate_e.operation:=$record.operation
		$operations:=ds:C1482.Operation.query("name =:1"; Split string:C1554($record.operation; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($operations.length>0)
			$stepTemplate_e.UUID_Operation:=$operations[0].UUID
		Else 
			$stepTemplate_e.UUID_Operation:="00"*16
		End if 
		
		//$stepTemplate_e.division:=$record.division
		$division:=ds:C1482.Division.query("name =:1"; Split string:C1554($record.division; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($division.length>0)
			$stepTemplate_e.UUID_Division:=$division[0].UUID
		Else 
			$stepTemplate_e.UUID_Division:="00"*16
		End if 
		
		$stepTemplate_e.status:=$record.status
		$stepTemplate_e.binning:=$record.binning
		
		$template:=ds:C1482.StepTemplateLayout.query("name =:1"; Split string:C1554($record.smallLayout; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($template.length>0)
			$stepTemplate_e.smallLayout_UUID:=$template[0].UUID
		Else 
			$stepTemplate_e.smallLayout_UUID:="00"*16
		End if 
		
		$template:=ds:C1482.StepTemplateLayout.query("name =:1"; Split string:C1554($record.largeLayout; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($template.length>0)
			$stepTemplate_e.largeLayout_UUID:=$template[0].UUID
		Else 
			$stepTemplate_e.largeLayout_UUID:="00"*16
		End if 
		
		
		//$stepTemplate_e.smallLayout:=$record.smallLayout
		//$stepTemplate_e.largeLayout:=$record.largeLayout
		$stepTemplate_e.comment1:=$record.comment1
		$stepTemplate_e.comment2:=$record.comment2
		$stepTemplate_e.areas:=$record.areas
		$stepTemplate_e.templateNumber:=$record.templateNumber
		
		$stepTemplate_e.bins:=New object:C1471("items"; New collection:C1472())
		For ($i; 0; 31)
			
			$bin:=New object:C1471()
			$bin.num:=$i+1
			$bin.definition:=$record.bins.items[$i]
			$bin.type:=""
			
			If (Split string:C1554($record.bins.items[$i]; "\r"; sk trim spaces:K86:2).join("\r")#"")
				$stepTemplate_e.bins.items.push($bin)
			End if 
			
		End for 
		
		$stepTemplate_e.rules:=New object:C1471("items"; New collection:C1472())
		For each ($rule; $rulesToImport)
			If (($record.miscellaneousControl & $rule.mask)=$rule.mask)
				$stepRule:=New object:C1471()
				$stepRule.name:=$rule.name
				$stepRule.description:=$rule.description
				
				$stepTemplate_e.rules.items.push($stepRule)
			End if 
		End for each 
		
		$stepTemplate_e.containerCodes:=New object:C1471("items"; New collection:C1472())
		For each ($containerCode; $containerCodesToImport)
			If (($record.containerCode & $containerCode.mask)=$containerCode.mask)
				$stepcontainerCode:=New object:C1471()
				$stepcontainerCode.name:=$containerCode.name
				$stepcontainerCode.description:=$containerCode.description
				
				$stepTemplate_e.containerCodes.items.push($stepcontainerCode)
			End if 
		End for each 
		
		
		$res:=$stepTemplate_e.save()
		
		If (Not:C34($res.success))
			TRACE:C157
		End if 
	End for each 
End if 

//MARK:- import StepTemplates -> [Step]

TRUNCATE TABLE:C1051([Step:120])
TRUNCATE TABLE:C1051([StepProperty:94])


var $stepPropertiesToImport : Collection
var $stepProcess : 4D:C1709.Entity
$stepPropertiesToImport:=New collection:C1472(\
New object:C1471("name"; "HoldPoint"; "description"; "01. Hold Point"; "mask"; 0x0001); \
New object:C1471("name"; "Reserved2"; "description"; "02. Reserved"; "mask"; 0x0002); \
New object:C1471("name"; "FreezeTraveler"; "description"; "04. Reserved {Freeze Traveler}"; "mask"; 0x0004); \
New object:C1471("name"; "Reserved4"; "description"; "08. Reserved"; "mask"; 0x0008); \
New object:C1471("name"; "SupervisorSignoffReqd"; "description"; "16. Supervisor's Signoff is required"; "mask"; 0x0010); \
New object:C1471("name"; "QASignoffReqd"; "description"; "32. QA signoff is required"; "mask"; 0x0020); \
New object:C1471("name"; "SNTableForAllUnits"; "description"; "64. SN logging for all units"; "mask"; 0x0040); \
New object:C1471("name"; "SNTableForFailsOnly"; "description"; "128. SN logging for current-step Fails"; "mask"; 0x0080); \
New object:C1471("name"; "SNTableAtPunchin"; "description"; "256. SN logging at Punch-IN"; "mask"; 0x0100); \
New object:C1471("name"; "Reserved10"; "description"; "512. Reserved"; "mask"; 0x0200); \
New object:C1471("name"; "NonSequentialProcessing"; "description"; "1024. Step may be performed non-sequentially"; "mask"; 0x0400); \
New object:C1471("name"; "OutsideOfCountRules"; "description"; "2048. Outside of Count Rules"; "mask"; 0x0800); \
New object:C1471("name"; "FinalQAApprovalWithStamp"; "description"; "4096. Final QA Approval with Stamp"; "mask"; 0x1000); \
New object:C1471("name"; "Reserved14"; "description"; "Reserved (Bit 14)"; "mask"; 0x2000); \
New object:C1471("name"; "Reserved15"; "description"; "Reserved (Bit 15)"; "mask"; 0x4000); \
New object:C1471("name"; "Reserved16"; "description"; "Reserved (Bit 16)"; "mask"; 0x8000); \
New object:C1471("name"; "WasStepManuallyAdded"; "description"; "Was Step Manually Added"; "mask"; 0x00010000); \
New object:C1471("name"; "ParetoInTraveler"; "description"; "Pareto in Traveler"; "mask"; 0x00020000); \
New object:C1471("name"; "Reserved19"; "description"; "Reserved (Bit 19)"; "mask"; 0x00040000); \
New object:C1471("name"; "QAFinalReview"; "description"; "QA Final Review"; "mask"; 0x00080000); \
New object:C1471("name"; "Clear"; "description"; "Clear"; "mask"; 0x00100000)\
)

For ($i; 0; $stepPropertiesToImport.length-1)
	$stepProperty_e:=ds:C1482.StepProperty.new()
	$stepProperty_e.name:=$stepPropertiesToImport[$i].name
	$stepProperty_e.description:=$stepPropertiesToImport[$i].description
	$stepProperty_e.levelID:=$i+1
	
	$res:=$stepProperty_e.save()
	
	If (Not:C34($res.success))
		TRACE:C157
	End if 
	
End for 


$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/steps.json")

$records:=JSON Parse:C1218($file.getText())
For each ($record; $records)
	$template:=ds:C1482.StepTemplate.query("templateNumber = :1"; $record.Template).first()
	
	If ($template=Null:C1517)
		$template:=ds:C1482.StepTemplate.new()
		$template.templateNumber:=$record.Template
		$template.name:="Template "+String:C10($record.Template)
		$info:=$template.save()
	End if 
	
	$step:=ds:C1482.Step.new()
	$step.UUID_StepTemplate:=$template.UUID
	
	$step.stepProperties:=New object:C1471("items"; New collection:C1472())
	For each ($property; $stepPropertiesToImport)
		If (($record.StepProperty & $property.mask)=$property.mask)
			$stepProperty:=New object:C1471()
			$stepProperty.name:=$property.name
			$stepProperty.description:=$property.description
			
			$step.stepProperties.items.push($stepProperty)
		End if 
	End for each 
	
	$step.description:=$record.Description
	$step.alert:=$record.Step_Alert
	$step.UUID_Specification:=16*"00"
	$step.areas:=$record.Area
	$step.moreData:=New object:C1471()
	$step.moreData.Process:=$record.Process
	$stepProcess:=ds:C1482.StepProcess.query("name = :1"; $record.Process).first()
	If ($stepProcess#Null:C1517)
		$step.UUID_StepProcess:=$stepProcess.UUID
	End if 
	//$step.moreData:=$record
	$succ:=$step.save()
	
End for each 



/**
import po & po lines (po <-- po_lines)
**/
If (True:C214)
	TRUNCATE TABLE:C1051([PurchaseOrder:115])
	TRUNCATE TABLE:C1051([PurchaseOrderLine:116])
	TRUNCATE TABLE:C1051([Invoice:4])
	
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/po_log_export.json")
	
	$records:=JSON Parse:C1218($file.getText())
	
	$erreur:=New collection:C1472()
	
	$poNumber:=0
	
	For each ($record; $records)
		
		$poNumber:=$poNumber+1
		
		$po:=ds:C1482.PurchaseOrder.new()
		
		$customer_es:=ds:C1482.Customer.query("name = :1"; $record.customer_name)
		
		If ($customer_es.length>0)
			$po.UUID_Customer:=$customer_es[0].UUID
		Else 
			$erreur.push($record.customer_name)
		End if 
		
		$po.customer_name:=$record.customer_name
		
		$po.poNumber:=$poNumber
		$po.oldPoNumber:=$record.poNumber
		$po.poAmount:=$record.poAmount
		$po.amountBilled:=$record.amountBilled
		
		//$po.ourQuote:=$record.ourQuote
		$quote:=ds:C1482.Quote.query("code =:1"; Split string:C1554($record.ourQuote; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($quote.length>0)
			$po.UUID_Quote:=$quote[0].UUID
		Else 
			
		End if 
		
		$po.resaleNumber:=$record.resaleNumber
		$po.identifier:=$record.identifier
		$po.initials:=$record.initials
		$po.division:=$record.division
		$po.openPO:=$record.openPO
		$po.address:=$record.address
		$po.altBillTo:=$record.altBillTo
		$po.dropShipCustomer:=$record.dropShipCustomer
		$po.releaseNumber:=$record.releaseNumber
		$po.forTimeBilling:=$record.forTimeBilling
		$po.timeBillingRate:=$record.timeBillingRate
		$po.timeBilling:=$record.timeBilling
		$po.description:=$record.description
		$po.log_date:=$record.Log_date
		
		var $customer : Object
		$customer:=ds:C1482.Customer.query("name =:1"; $record.customer_name).first()
		If ($customer#Null:C1517)
			$po.UUID_Customer:=$customer.UUID
			
		End if 
		
		$res:=$po.save()
		
		If (Not:C34($res.success))
			TRACE:C157
		Else 
			
			For each ($invoice; $record.invoices)
				$invoice_e:=ds:C1482.Invoice.new()
				
				$invoice_e.division:=$invoice.division
				$invoice_e.invoice:=Split string:C1554($invoice.invoice; "\r"; sk trim spaces:K86:2).join("\r")
				$invoice_e.date:=$invoice.date
				$invoice_e.currency:=$invoice.currency
				$invoice_e.total:=$invoice.total
				$invoice_e.due:=$invoice.due
				$invoice_e.slip:=$invoice.slip
				$invoice_e.UUID_PurchaseOrder:=$po.UUID
				$invoice_e.customerId:=$invoice.customerId
				$invoice_e.amountPaid:=$invoice.amountPaid
				$invoice_e.saleAmount:=$invoice.saleAmount
				$invoice_e.readyToDel:=$invoice.readyToDel
				$res:=$invoice_e.save()
				
				If (Not:C34($res.success))
					TRACE:C157
				End if 
			End for each 
			
			For each ($line; $record.lineItems)
				$poLine:=ds:C1482.PurchaseOrderLine.new()
				
				$poLine.UUID_PurchaseOrder:=$po.UUID
				$poLine.itemNum:=$line.itemNum
				$poLine.description:=$line.description
				$poLine.partNum:=$line.partNum
				$poLine.dateOrdered:=$line.dateOrdered
				$poLine.customerRequestedDate:=$line.customerRequestedDate
				$poLine.qtyOrdered:=$line.qtyOrdered
				$poLine.currency:=$line.currency
				$poLine.unitPrice:=$line.unitPrice
				$poLine.shipJobNumber:=$line.shipJobNumber
				$poLine.buildJobNumber:=$line.buildJobNumber
				$poLine.unreleased:=$line.unreleased
				$poLine.closed:=$line.closed
				$poLine.seqNum:=$line.seqNum
				$poLine.total:=$line.total
				$poLine.saleTax:=$line.saleTax
				$poLine.taxable:=$line.taxable
				
				
				$res:=$poLine.save()
				
				If (Not:C34($res.success))
					TRACE:C157
				End if 
				
			End for each 
		End if 
	End for each 
	
	
	If ($erreur.length>0)
		//TRACE
	End if 
End if 

/**
import jobs & lot (job <-- lots) 
**/
If (True:C214)
	TRUNCATE TABLE:C1051([Job:117])
	TRUNCATE TABLE:C1051([Lot:118])
	TRUNCATE TABLE:C1051([LotStep:5])
	TRUNCATE TABLE:C1051([JobInvoice:67])
	TRUNCATE TABLE:C1051([JobLineItem:65])
	
	//__import_data_unitCost
	
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/job_log_export.json")
	
	$records:=JSON Parse:C1218($file.getText())
	$counter:=0
	
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
		$job.stmpExpected:=Date:C102($record.expectedDate)=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build(Date:C102($record.expectedDate))  //$record.expectedDate
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
		$job.archived:=False:C215
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
		
		//JobInvoice
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
					$poLine_e.total:=$poline.total
					$poLine_e.unitPrice:=$poline.unitPrice
					$poLine_e.taxable:=$poline.taxable
					
					$res:=$poLine_e.save()
					
					If (Not:C34($res.success))
						TRACE:C157
					End if 
				Else 
					
					
				End if 
				
			Else 
				
				
			End if 
		End for each 
		
		
		For each ($lot; $record.lots.orderBy("parentLotNumber asc"))
			
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
			
			$po_s:=ds:C1482.PurchaseOrder.query("oldPoNumber =:1"; Split string:C1554($record.poNumber; "\r"; sk trim spaces:K86:2).join("\r"))
			If ($po_s.length>0)
				$lot_e.poNumber:=$po_s[0].poNumber
				//$lot_e.UUID_PurchaseOrder:=$po_s[0].UUID
				
			Else 
				$lot_e.poNumber:=0
			End if 
			
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
			$lot_e.altDevNumber:=$lot.altDevNumber
			$lot_e.altLotNumber:=$lot.altLotNumber
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
			
			$lot_e.moreData:=New object:C1471()
			$recodNumber:=ds:C1482.sfw_Counter.getNextValue("Lot")
			$lot_e.moreData.barcodeData:=String:C10($recodNumber; "0000000000")
			
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
					
					
					While (($lotStep_e.tools#Null:C1517) && ($lotStep_e.tools.items.indexOf("")#-1))
						
						$lotStep_e.tools.items:=$lotStep_e.tools.items.remove($lotStep_e.tools.items.indexOf(""))
						
					End while 
					
					$lotStep_e.parametricMeasurements:=New object:C1471("items"; New collection:C1472())
					$lotStep_e.stepInterruptions:=New object:C1471("items"; New collection:C1472())
					$lotStep_e.dataTables:=New object:C1471("items"; New collection:C1472())
					
					//$lotStep_e.bins:=New object("items"; New collection())
					
					$lotStep_e.bins:=New object:C1471("items"; New collection:C1472())
					For ($i; 0; $step.bins.items.length-1)
						
						$bin:=New object:C1471()
						$bin.num:=$i+1
						$bin.definition:=""
						$bin.type:=""
						
						//If (Split string($step.bins.items[$i]; "\r"; sk trim spaces).join("\r")#"")
						$lotStep_e.bins.items.push($bin)
						//End if 
						
					End for 
					
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

/**
import archived Jobs
**/
__import_data_archivedJobs

/**
import inventories
**/
If (True:C214)
	TRUNCATE TABLE:C1051([Inventory:126])
	TRUNCATE TABLE:C1051([InventoryPull:127])
	TRUNCATE TABLE:C1051([Location:47])
	TRUNCATE TABLE:C1051([Unit:48])
	TRUNCATE TABLE:C1051([Classification:59])
	TRUNCATE TABLE:C1051([Bin:95])
	
	$binLocations:=New collection:C1472("ASSY OSS RACK/IQC/B1"; \
		"ASSY OSS RACK/IQC/B10"; "ASSY OSS RACK/IQC/B15"; \
		"ASSY OSS RACK/IQC/B16"; "ASSY OSS RACK/IQC/B20"; "ASSY OSS RACK/IQC/B7"; \
		"ASSY OSS RACK/IQC/B8"; "ASSY OSS RACK/IQC/B9"; "BACKEND/IQC/B16"; \
		"BACKEND/IQC/B20"; "Line/IQC/B1"; "Line/IQC/B10"; "Line/IQC/B11"; \
		"Line/IQC/B12"; "Line/IQC/B15"; "Line/IQC/B16"; "Line/IQC/B19"; "Line/IQC/B20"; \
		"Line/IQC/B5"; "Line/IQC/B7"; "Line/IQC/B8"; "WareHouse/ASSY OSS RACK"; \
		"WareHouse/BACKEND"; "WareHouse/CBNT2/BIN 16"; "WareHouse/CBNT 3"; \
		"WareHouse/CBNT1"; "WareHouse/CBNT1/B1"; "WareHouse/CBNT1/B10"; \
		"WareHouse/CBNT1/B2"; "WareHouse/CBNT1/B3"; "WareHouse/CBNT1/B4"; \
		"WareHouse/CBNT1/B5"; "WareHouse/CBNT1/B6"; "WareHouse/CBNT1/B7"; \
		"WareHouse/CBNT1/B8"; "WareHouse/CBNT1/B9"; "WareHouse/CBNT10"; \
		"WareHouse/CBNT11"; "WareHouse/CBNT12"; "WareHouse/CBNT2/B11"; \
		"WareHouse/CBNT2/B12"; "WareHouse/CBNT2/B13"; "WareHouse/CBNT2/B14"; \
		"WareHouse/CBNT2/B15"; "WareHouse/CBNT2/B16"; "WareHouse/CBNT2/B17"; \
		"WareHouse/CBNT2/B18"; "WareHouse/CBNT2/B19"; "WareHouse/CBNT3/B21"; \
		"WareHouse/CBNT4"; "WareHouse/DESICCATOR"; "WareHouse/Engineering"; \
		"WareHouse/FOL-CABINET/75"; "WareHouse/FOL-CABINET/76"; "WareHouse/FOL-CABINET/77"; \
		"WareHouse/FOL-CABINET/79"; "WareHouse/Freezer/1 (FOL)"; "WareHouse/Freezer/2"; \
		"WareHouse/Inventory/CBNT 12/ROW A"; "WareHouse/Inventory/CBNT 12/ROW B"; \
		"WareHouse/Inventory/CBNT 12/ROW C"; "WareHouse/Inventory/CBNT 12/ROW D"; \
		"WareHouse/Inventory/CBNT 13/ROW A"; "WareHouse/Inventory/CBNT 13/ROW B"; \
		"WareHouse/Inventory/CBNT 13/ROW C"; "WareHouse/Inventory/CBNT 13/ROW D"; \
		"WareHouse/Inventory/CBNT 13/ROW E"; "WareHouse/Inventory/CBNT 14/ROW A"; \
		"WareHouse/Inventory/CBNT 14/ROW C"; "WareHouse/Inventory/CBNT 14/ROW D"; \
		"WareHouse/Inventory/CBNT 4/ROW A"; "WareHouse/Inventory/CBNT 4/ROW B"; \
		"WareHouse/Inventory/CBNT 4/ROW C"; "WareHouse/Inventory/CBNT 4/ROW D"; \
		"WareHouse/Inventory/CBNT 4/ROW E"; "WareHouse/Inventory/CBNT 5/ROW A"; \
		"WareHouse/Inventory/CBNT 5/ROW B"; "WareHouse/Inventory/CBNT 5/ROW C"; \
		"WareHouse/Inventory/CBNT 5/ROW D"; "WareHouse/Inventory/CBNT 6/ROW A"; \
		"WareHouse/Inventory/CBNT 6/ROW B"; "WareHouse/Inventory/CBNT 6/ROW C"; \
		"WareHouse/Inventory/CBNT 6/ROW D"; "WareHouse/Inventory/CBNT 6/ROW E"; \
		"WareHouse/Inventory/CBNT 8/ROW A"; "WareHouse/Inventory/CBNT 8/ROW B"; "WareHouse/Inventory/CBNT 8/ROW C"; "WareHouse/Inventory/CBNT 8/ROW D"; "WareHouse/Inventory/CBNT 8/ROW E"; "WareHouse/Inventory/Milpitas"; "WareHouse/Inventory/OQC Rack"; "WareHouse/Inventory/Roller"; "WareHouse/Inventory/Shelve A"; "WareHouse/Inventory/Shelve B"; "WareHouse/Inventory/Shelve C"; "WareHouse/Inventory/Shelve E"; "WareHouse/Inventory/Shelve J"; "WareHouse/Inventory/Desiccator/Bank 22"; "WareHouse/Inventory/Desiccator/Bank 23"; "WareHouse/Inventory/Desiccator/Bank 24"; "WareHouse/Inventory/Desiccator/Bank 25"; "WareHouse/Inventory/Desiccator/Bank 26"; "WareHouse/LAB"; "WareHouse/LAB OSS RACK"; "WareHouse/Line"; "WareHouse/Vault/1"; "WareHouse/Vault/2")
	
	
	For each ($binLocation; $binLocations)
		$binLocation_e:=ds:C1482.Bin.new()
		$binLocation_e.binLocationPath:=$binLocation
		$res:=$binLocation_e.save()
		
		If (Not:C34($res.success))
			TRACE:C157
		End if 
	End for each 
	
	
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/inventory_export.json")
	
	$records:=JSON Parse:C1218($file.getText())
	
	For each ($record; $records)
		$inventory_e:=ds:C1482.Inventory.new()
		
		$inventory_e.customerSpecific:=$record.customerSpecific
		$inventory_e.partNumber:=$record.partNum
		$inventory_e.vendor:=$record.vendor
		$inventory_e.description:=$record.description
		$inventory_e.classification:=$record.classification
		//$inventory_e.partLotNumber:=$record.lotNumber
		$inventory_e.stockNum:=$record.stockNum
		$inventory_e.dateIn:=cs:C1710.sfw_stmp.me.build(Date:C102($record.dateIn))
		$inventory_e.expirationDate:=$record.expirationDate
		$inventory_e.qtyInStock:=$record.qtyInStock
		$inventory_e.unitCost:=$record.unitCost
		$inventory_e.units:=$record.inventoryUnits
		$inventory_e.currency:=$record.currency
		
		//$inventory_e.location:=$record.binLocation
		$formula:=Formula:C1597(Replace string:C233(Replace string:C233(This:C1470.binLocationPath; "/"; " "); " "; "")=Replace string:C233($record.binLocation; " "; ""))
		$bin:=ds:C1482.Bin.query($formula)
		If ($bin.length>0)
			var $bin_e : cs:C1710.BinEntity
			$bin_e:=$bin[0]
			$inventory_e.UUID_Location:=$bin_e.UUID

		Else
			$inventory_e.UUID_Location:="00"*16
		End if 
		
		$inventory_e.receivedBy:=$record.recdBy
		$inventory_e.totalCost:=$record.totalCost
		$inventory_e.availableQty:=$record.AvailableQty
		$inventory_e.initialQty:=$record.originalQty
		$inventory_e.inventoryID:=(ds:C1482.Inventory.all().length>0) ? ds:C1482.Inventory.all().max("inventoryID")+1 : 1
		$inventory_e.code:="INV"+String:C10($inventory_e.inventoryID; "00000#")
		
		$staff_es:=ds:C1482.Staff.query("code = :1"; $inventory_e.receivedBy)
		
		If ($staff_es.length>0)
			$inventory_e.UUID_Staff:=$staff_es[0].UUID
		End if 
		
		$res:=$inventory_e.save()
		
		If (Not:C34($res.success))
			TRACE:C157
		Else 
			//For each ($pull; $record.pulls)
			//$pull_e:=ds.InventoryPull.new()
			
			//$pull_e.partNum:=$pull.partNum
			//$pull_e.qty:=$pull.qty
			//$pull_e.cost:=$pull.partNum
			//$pull_e.datePulled:=$pull.datePulled
			//$pull_e.jobNumber:=$pull.jobNumber
			//$pull_e.uniqueID:=$pull.uniqueID
			//$pull_e.pulledBy:=$pull.pulledBy
			//$pull_e.division:=$pull.division
			//$pull_e.docsInDocServer:=$pull.docsInDocServer
			//$pull_e.currency:=$pull.currency
			//$pull_e.units:=$pull.units
			//$pull_e.currency:=$pull.currency
			//$pull_e.pullMode:=$pull.pullMode
			//$pull_e.lotNumber:=$pull.lotNumber
			//$pull_e.property:=$pull.property
			//$pull_e.jobInvoiceDate:=$pull.jobInvoiceDate
			//$pull_e.UUID_Inventory:=$inventory_e.UUID
			
			//$res:=$pull_e.save()
			
			//If (Not($res.success))
			//TRACE
			//End if 
			//End for each 
		End if 
		
	End for each 
	
	$locations:=ds:C1482.Inventory.all().distinct("location")
	
	For each ($location; $locations)
		$location_e:=ds:C1482.Location.new()
		$location_e.name:=$location
		$res:=$location_e.save()
		
		If (Not:C34($res.success))
			TRACE:C157
		End if 
	End for each 
	
	$units:=ds:C1482.Inventory.all().distinct("units")
	
	For each ($unit; $units)
		$unit_e:=ds:C1482.Unit.new()
		$unit_e.name:=$unit
		$res:=$unit_e.save()
		
		If (Not:C34($res.success))
			TRACE:C157
		End if 
	End for each 
	
	$classifications:=ds:C1482.Inventory.all().distinct("classification")
	
	For each ($classification; $classifications)
		$classification_e:=ds:C1482.Classification.new()
		$classification_e.name:=$classification
		$res:=$classification_e.save()
		
		If (Not:C34($res.success))
			TRACE:C157
		End if 
	End for each 
	
End if 
_ga_updateBinIsEmpty


/**
import tools
**/
If (True:C214)
	TRUNCATE TABLE:C1051([ToolType:122])
	TRUNCATE TABLE:C1051([Tool:6])
	
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/tools_export.json")
	
	$records:=JSON Parse:C1218($file.getText())
	
	For each ($record; $records)
		$toolType_e:=ds:C1482.ToolType.new()
		
		$toolType_e.name:=$record.name
		$toolType_e.type:=$record.type
		$toolType_e.date:=$record.date
		
		$res:=$toolType_e.save()
		
		If (Not:C34($res.success))
			TRACE:C157
		Else 
			For each ($tool; $record.tools)
				$tool_e:=ds:C1482.Tool.new()
				
				$tool_e.name:=Split string:C1554($tool; "*")[0]
				$tool_e.date:=Date:C102(Split string:C1554($tool; "*")[1])
				
				$tool_e.UUID_ToolType:=$toolType_e.UUID
				
				$res:=$tool_e.save()
				
				If (Not:C34($res.success))
					TRACE:C157
				End if 
			End for each 
		End if 
	End for each 
End if 

/**
import cetifications
**/
If (True:C214)
	TRUNCATE TABLE:C1051([Certification:124])
	
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/certifications_export.json")
	
	$records:=JSON Parse:C1218($file.getText())
	
	For each ($record; $records)
		$certification_e:=ds:C1482.Certification.new()
		
		$certification_e.ref:=$record.ref
		$certification_e.name:=$record.name
		
		$res:=$certification_e.save()
		
		If (Not:C34($res.success))
			TRACE:C157
		End if 
	End for each 
End if 

/**
import specifications
**/
If (True:C214)
	
	var $blob : Blob
	
	TRUNCATE TABLE:C1051([Specification:10])
	
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/specification_export.json")
	
	$records:=JSON Parse:C1218($file.getText())
	
	$docs:=Folder:C1567(fk data folder:K87:12).file("DataJson/docServerIndex_export.json")
	If ($docs.exists)
		$documents:=JSON Parse:C1218($docs.getText())
	End if 
	
	
	For each ($record; $records)
		$specification_e:=ds:C1482.Specification.new()
		
		$specification_e.spec:=$record.Spec
		$specification_e.title:=$record.Spec_Title
		$specification_e.stmpRevisionDate:=cs:C1710.sfw_stmp.me.build(Date:C102($record.Revsion_Date))
		$specification_e.revision:=$record.Rev
		
		$division:=ds:C1482.Division.query("name =:1"; Split string:C1554($record.Division; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($division.length>0)
			$specification_e.UUID_Division:=$division[0].UUID
		Else 
			$specification_e.UUID_Division:=""
		End if 
		
		$specification_e.isForm:=$record.Form
		
		$category:=ds:C1482.DocumentCategory.query("name =:1"; Split string:C1554($record.PublishedDocCategory; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($category.length>0)
			$specification_e.UUID_DocumentCategory:=$category[0].UUID
		Else 
			$specification_e.UUID_DocumentCategory:=0
		End if 
		
		$specification_e.remark:=$record.Remarks
		$specification_e.extension:=$record.Dosext
		$specification_e.suppress:=$record.Suppress
		$specification_e.reviewIntervalInDays:=$record.ReviewIntervalInDays
		$specification_e.stmpReviewDate:=cs:C1710.sfw_stmp.me.build(Date:C102($record.Review_Date))
		
		$specification_e.moreData:=New object:C1471(\
			"dueReview"; False:C215; \
			"dueApproval"; False:C215\
			)
		
		$stecControllingDetpt:=ds:C1482.ControllingDepartment.query("name =:1"; Split string:C1554($record.ControllingDept; "\r"; sk trim spaces:K86:2).join("\r"))
		If ($stecControllingDetpt.length>0)
			$specification_e.UUID_ControllingDepartment:=$stecControllingDetpt[0].UUID
		Else 
			$specification_e.UUID_ControllingDepartment:=0
		End if 
		
		
		$PublishedDocumentBlob:=Folder:C1567(fk data folder:K87:12).file("DataJson/SpecificationsPublishedDocumentBlobFields/"+String:C10($record.Spec))
		If ($PublishedDocumentBlob.exists)
			
			DOCUMENT TO BLOB:C525($PublishedDocumentBlob.platformPath; $blob)
			$specification_e.publishedDocumentBlob:=$blob
			
		Else 
			
		End if 
		
		
		$_documents:=$documents.query("PrimaryKeyValue=:1 & TableNumber=:2"; String:C10($record.UniqueID); 21)
		
		$specification_e.documents:=New object:C1471()
		$specification_e.documents.documentsCollection:=New collection:C1472()
		
		For each ($document; $_documents)
			$docObj:=New object:C1471
			
			$docObj.code:=$document.DocCode
			$docObj.dateTimeStamp:=$document.DateTimeStamp
			$docObj.creationDateTimeStamp:=$document.CreationDateTimeStamp
			$docObj.documentPath:=$document.DocumentPath
			$docObj.sourcePath:=$document.SourcePath
			$docObj.description:=$document.DocDescription
			$docObj.approvalDate:=!00-00-00!
			$docObj.approvedBy:=""
			$docObj.isApproved:=False:C215
			
			$doc:=Folder:C1567(fk data folder:K87:12).file("DataJson/SpecificationsDocuments/"+String:C10($document.UniqueID+$document.PrimaryKeyValue))
			If ($doc.exists)
				
				
				DOCUMENT TO BLOB:C525($doc.platformPath; $blob)
				
				$docObj.blob:=$blob
				
			End if 
			
			$specification_e.documents.documentsCollection.push($docObj)
		End for each 
		
		
		$res:=$specification_e.save()
		If (Not:C34($res.success))
			TRACE:C157
		End if 
	End for each 
End if 

/**
Create user: sfw_User & Staff tables
**/



If (True:C214)
	TRUNCATE TABLE:C1051([Staff:135])
	TRUNCATE TABLE:C1051([sfw_User:16])
	
	$user:=ds:C1482.sfw_User.new()
	$user.firstName:="Hassan"
	$user.lastName:="Sribet"
	$user.login:="hassansribet"
	$user.accesses:=JSON Parse:C1218("{\"asDesigner\":true,\"password\":{\"temporary\":false,\"sendTemporaryByMail\":false,\"lastReset\":705253775,\"hash\":\"$2b$10$1KIfSf/DkyivGUKEeHHPDulQ51F9LSOuyFmHy6X9TvAXi1K79E4ri\",\"lastChange\":705253879}}")  //pSzjGX!Ey9P1c~p
	$user.asDesigner:=True:C214
	$user.moreData:=New object:C1471()
	$recodNumber:=ds:C1482.sfw_Counter.getNextValue("sfw_User")
	$user.moreData.barcodeData:=String:C10($recodNumber; "0000000000")
	$res:=$user.save()
	
	If (Not:C34($res.success))
		TRACE:C157
	End if 
	
	$staff:=ds:C1482.Staff.new()
	$staff.UUID_User:=$user.UUID
	$staff.firstName:="Hassan"
	$staff.lastName:="Sribet"
	$staff.code:=String:C10($staff.codeID; "00000#")
	
	$staff.contactDetails:=New object:C1471(\
		"addresses"; New collection:C1472(); \
		"communications"; New collection:C1472()\
		)
	
	$res:=$staff.save()
	
	If (Not:C34($res.success))
		TRACE:C157
	End if 
	
	$user:=ds:C1482.sfw_User.new()
	$user.firstName:="Omar"
	$user.lastName:="Debbagh"
	$user.login:="omardebbagh"
	$user.accesses:=JSON Parse:C1218("{\"asDesigner\":true,\"password\":{\"temporary\":false,\"sendTemporaryByMail\":false,\"lastReset\":706358866,\"hash\":\"$2b$10$1KIfSf/DkyivGUKEeHHPDulQ51F9LSOuyFmHy6X9TvAXi1K79E4ri\",\"lastChange\":706358916}}")
	$user.moreData:=New object:C1471()
	$recodNumber:=ds:C1482.sfw_Counter.getNextValue("sfw_User")
	$user.moreData.barcodeData:=String:C10($recodNumber; "0000000000")
	$res:=$user.save()
	
	If (Not:C34($res.success))
		TRACE:C157
	End if 
	
	$staff:=ds:C1482.Staff.new()
	$staff.UUID_User:=$user.UUID
	$staff.firstName:="Omar"
	$staff.lastName:="Debbagh"
	$staff.code:=String:C10($staff.codeID; "00000#")
	
	$staff.contactDetails:=New object:C1471(\
		"addresses"; New collection:C1472(); \
		"communications"; New collection:C1472()\
		)
	
	$res:=$staff.save()
	
	If (Not:C34($res.success))
		TRACE:C157
	End if 
End if 

/**
import staffs
**/
If (True:C214)
	$file_excel:=Folder:C1567(fk data folder:K87:12).file("DataJson/GA_employee_list.csv")
	
	$records_excel:=Split string:C1554($file_excel.getText(); "\r\n")
	
	$records_excel.shift()  //remove the header
	
	$staffs_excel:=New collection:C1472()
	
	For each ($record; $records_excel)
		$staffs_excel.push(New object:C1471(\
			"lastName"; Split string:C1554(Split string:C1554($record; ";")[1]; ",")[0]; \
			"firstName"; Split string:C1554(Split string:C1554($record; ";")[1]; ",")[1]; \
			"roles"; Split string:C1554(Split string:C1554($record; ";")[2]; ","); \
			"teams"; Split string:C1554(Split string:C1554($record; ";")[3]; ",")\
			))
	End for each 
	
	TRUNCATE TABLE:C1051([Team:136])
	TRUNCATE TABLE:C1051([Membership:137])
	TRUNCATE TABLE:C1051([Role:132])
	TRUNCATE TABLE:C1051([StaffRole:63])
	//TRUNCATE TABLE([Staff])
	
	//SET DATABASE PARAMETER([Staff]; Table sequence number; 2)
	
	For each ($staff; $staffs_excel)
		
		
		$user:=ds:C1482.sfw_User.new()
		$user.firstName:=$staff.firstName
		$user.lastName:=$staff.lastName
		$user.login:=Lowercase:C14($staff.firstName+$staff.lastName)
		$user.accesses:=JSON Parse:C1218("{\"asDesigner\":true,\"password\":{\"temporary\":true,\"sendTemporaryByMail\":false,\"lastReset\":705253775,\"hash\":\"$2b$10$1KIfSf/DkyivGUKEeHHPDulQ51F9LSOuyFmHy6X9TvAXi1K79E4ri\",\"lastChange\":705253879}}")  //pSzjGX!Ey9P1c~p
		$user.asDesigner:=True:C214
		$user.isInactive:=False:C215
		$user.moreData:=New object:C1471()
		$recodNumber:=ds:C1482.sfw_Counter.getNextValue("sfw_User")
		$user.moreData.barcodeData:=String:C10($recodNumber; "0000000000")
		$res:=$user.save()
		
		If (Not:C34($res.success))
			TRACE:C157
		End if 
		
		
		$staff_e:=ds:C1482.Staff.new()
		
		$staff_e.UUID_User:=$user.UUID
		$staff_e.code:=String:C10($staff_e.codeID; "00000#")
		$staff_e.firstName:=$staff.firstName
		$staff_e.lastName:=$staff.lastName
		
		//$division:=ds.Division.query("name =:1"; Split string($staff_e.division; "\r"; sk trim spaces).join("\r"))
		
		//If ($division.length>0)
		//$staff_e.UUID_Division:=$division[0].UUID
		//Else 
		//$staff_e.UUID_Division:=16*"00"
		//End if 
		
		$staff_e.contactDetails:=New object:C1471(\
			"addresses"; New collection:C1472(); \
			"communications"; New collection:C1472()\
			)
		
		$staff_e.moreData:=New object:C1471(\
			"retrainNotified"; False:C215\
			)
		
		
		$res:=$staff_e.save()
		
		
		If ($res.success)
			
			For each ($team; $staff.teams)
				$teams_es:=ds:C1482.Team.query("name = :1"; $team)
				
				If ($teams_es.length>0)
					$team_e:=$teams_es[0]
				Else 
					$team_e:=ds:C1482.Team.new()
					$team_e.levelID:=ds:C1482.Team.all().length+1
					$team_e.name:=$team
					
					$res:=$team_e.save()
					
					If (Not:C34($res.success))
						TRACE:C157
					End if 
				End if 
				
				$membership_e:=ds:C1482.Membership.new()
				
				$membership_e.UUID_Staff:=$staff_e.UUID
				$membership_e.UUID_Team:=$team_e.UUID
				
				$res:=$membership_e.save()
				
				If (Not:C34($res.success))
					TRACE:C157
				End if 
			End for each 
			
			For each ($role; $staff.roles)
				$roles_es:=ds:C1482.Role.query("name = :1"; $role)
				
				If ($roles_es.length>0)
					$role_e:=$roles_es[0]
				Else 
					$role_e:=ds:C1482.Role.new()
					
					$role_e.name:=$role
					
					$res:=$role_e.save()
					
					If (Not:C34($res.success))
						TRACE:C157
					End if 
				End if 
				
				$staffRole_e:=ds:C1482.StaffRole.new()
				
				$staffRole_e.UUID_Staff:=$staff_e.UUID
				$staffRole_e.UUID_Role:=$role_e.UUID
				
				$res:=$staffRole_e.save()
				
				If (Not:C34($res.success))
					TRACE:C157
				End if 
			End for each 
			
			
			
		End if 
	End for each 
End if 

/**
import qcars
**/
If (True:C214)
	TRUNCATE TABLE:C1051([Qcar:138])
	
	$file:=Folder:C1567(fk data folder:K87:12).file("DataJson/qcar_export.json")
	
	$records:=JSON Parse:C1218($file.getText())
	
	For each ($record; $records)
		$qcar_e:=ds:C1482.Qcar.new()
		
		$qcar_e.qcarNumber:=$record.qcarNumber
		$qcar_e.device:=$record.device
		$qcar_e.closedDate:=$record.closedDate
		$qcar_e.targetCloseDate:=$record.targetCloseDate
		//$qcar_e.actualCloseDate:=$record.actualCloseDate
		$qcar_e.verifiedBy:=$record.verifiedBy
		$qcar_e.verifiedDate:=$record.verifiedDate
		$qcar_e.void:=$record.void
		$qcar_e.submit:=$record.submit
		$qcar_e.submitDate:=$record.submitDate
		$qcar_e.category:=$record.category
		$qcar_e.issuedBy:=$record.issuedBy
		$qcar_e.issuedTo:=$record.issuedTo
		$qcar_e.issuedDate:=$record.issuedDate
		
		$qcar_e._initCorrectiveActionReport()
		
		
		$customer_es:=ds:C1482.Customer.query("name = :1"; $record.customer)
		
		If ($customer_es.length>0)
			$qcar_e.UUID_Customer:=$customer_es[0].UUID
		Else 
			//TRACE
		End if 
		
		$lot_es:=ds:C1482.Lot.query("lotNumber = :1"; $record.lotNumber)
		
		If ($lot_es.length>0)
			$qcar_e.UUID_Lot:=$lot_es[0].UUID
		Else 
			//TRACE
		End if 
		
		$res:=$qcar_e.save()
		
		If (Not:C34($res.success))
			TRACE:C157
		End if 
	End for each 
End if 
