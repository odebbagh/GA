Class extends Entity



local Function get job()->$job : cs:C1710.JobEntity
	$job:=ds:C1482.Job.query("jobNumber =:1"; Num:C11(This:C1470.invoice.invoice)).first()
	
	
Function rebuildInvoices()->$data : Object
	
	$data:=New object:C1471()
	Case of 
		: (This:C1470.job=Null:C1517)
		: (This:C1470.job.invoices[0].poBasedCharges#0)
			$data.invoices:=ds:C1482.PurchaseOrderLine.query("UUID_Job =:1"; This:C1470.job.UUID)  //This.job.purchaseOrderLines
			$colSettings:=New collection:C1472(\
				New object:C1471("field"; "indexOf()+1"; "title"; "#"; "fieldType"; Is text:K8:3; "width"; 30; "minWidth"; 30; "maxWidth"; 50); \
				New object:C1471("field"; "description"; "title"; "Description"; "fieldType"; Is text:K8:3; "width"; 280; "minWidth"; 100; "maxWidth"; 500); \
				New object:C1471("field"; "qtyOrdered"; "title"; "Qty"; "fieldType"; Is integer:K8:5; "width"; 70; "minWidth"; 70; "maxWidth"; 80); \
				New object:C1471("field"; "unitPrice"; "title"; "Unit Price"; "fieldType"; Is real:K8:4; "width"; 70; "minWidth"; 70; "maxWidth"; 80); \
				New object:C1471("field"; "taxable"; "title"; "Taxable"; "fieldType"; Is text:K8:3; "width"; 70; "minWidth"; 70; "maxWidth"; 80); \
				New object:C1471("field"; "saleTax"; "title"; "Sales Tax"; "fieldType"; Is real:K8:4; "width"; 70; "minWidth"; 70; "maxWidth"; 80); \
				New object:C1471("field"; "total"; "title"; "Total"; "fieldType"; Is real:K8:4; "width"; 70; "minWidth"; 70; "maxWidth"; 80)\
				)
			$data.colSettings:=$colSettings
			
			
		: (This:C1470.job.boxStockShipment=True:C214)
			//Not records match this condition
			
		: (This:C1470.job.lineItem=False:C215)
			//AL_SetHeaders($Alp; 1; 7; "#"; "Item-description"; "Qty-in"; "Qty-Out"; "Unit price"; "Item-total"; "Lot")
			
			$data.invoices:=This:C1470.job.lots
			$colSettings:=New collection:C1472(\
				New object:C1471("field"; "indexOf()+1"; "title"; "#"; "fieldType"; Is text:K8:3; "width"; 30; "minWidth"; 30; "maxWidth"; 50); \
				New object:C1471("field"; "device"; "title"; "Description"; "fieldType"; Is text:K8:3; "width"; 280; "minWidth"; 100; "maxWidth"; 500); \
				New object:C1471("field"; "ourCount"; "title"; "Qty-in"; "fieldType"; Is integer:K8:5; "width"; 70; "minWidth"; 70; "maxWidth"; 80); \
				New object:C1471("field"; "progressive"; "title"; "Qty-Out"; "fieldType"; Is text:K8:3; "width"; 70; "minWidth"; 70; "maxWidth"; 80); \
				New object:C1471("field"; "unitCost"; "title"; "Unit Price"; "fieldType"; Is real:K8:4; "width"; 70; "minWidth"; 70; "maxWidth"; 80); \
				New object:C1471("field"; "totalCharge"; "title"; "Item-total"; "fieldType"; Is real:K8:4; "width"; 70; "minWidth"; 70; "maxWidth"; 80); \
				New object:C1471("field"; "lotNumber"; "title"; "Lot"; "fieldType"; Is text:K8:3; "width"; 70; "minWidth"; 70; "maxWidth"; 80)\
				)
			$data.colSettings:=$colSettings
			
			
			
			
		: (This:C1470.job.lineItem=True:C214)
			
			$data.invoices:=This:C1470.job.lineItems
			$colSettings:=New collection:C1472(\
				New object:C1471("field"; "indexOf()+1"; "title"; "#"; "fieldType"; Is text:K8:3; "width"; 30; "minWidth"; 30; "maxWidth"; 50); \
				New object:C1471("field"; "description"; "title"; "Description"; "fieldType"; Is text:K8:3; "width"; 280; "minWidth"; 100; "maxWidth"; 500); \
				New object:C1471("field"; "quantity"; "title"; "Qty"; "fieldType"; Is integer:K8:5; "width"; 70; "minWidth"; 70; "maxWidth"; 80); \
				New object:C1471("field"; "unitPrice"; "title"; "Unit Price"; "fieldType"; Is real:K8:4; "width"; 70; "minWidth"; 70; "maxWidth"; 80); \
				New object:C1471("field"; "taxable"; "title"; "Taxable"; "fieldType"; Is text:K8:3; "width"; 70; "minWidth"; 70; "maxWidth"; 80); \
				New object:C1471("field"; "salesTax"; "title"; "Sales Tax"; "fieldType"; Is real:K8:4; "width"; 70; "minWidth"; 70; "maxWidth"; 80); \
				New object:C1471("field"; "lineTotal"; "title"; "Total"; "fieldType"; Is real:K8:4; "width"; 70; "minWidth"; 70; "maxWidth"; 80)\
				)
			$data.colSettings:=$colSettings
			
			
		Else 
			
	End case 
	