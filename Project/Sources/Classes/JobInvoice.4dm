

Class extends DataClass


local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	//Mark: entry : Invoice
	$entry:=cs:C1710.sfw_definitionEntry.new("JobInvoice"; ["customerService"]; "Invoices")
	$entry.setDataclass("JobInvoice")
	$entry.setDisplayOrder(-800)
	$entry.setIcon("image/entry/invoice-white-50x50.png")
	
	$entry.setSearchField("attribute:invoiceNumber"; "tag:InvoiceNumber"; "popupDescription:the invoice number")
	$entry.setSearchField("path:job.purchaseOrder.customer.name"; "tag:Customer"; "popupPart:Job"; "placeholder:customerName"; "popupDescription:the customer name")
	$entry.setSearchField("path:job.jobNumber"; "tag:Job"; "placeholder:jobNumer"; "popupDescription:the job number")
	$entry.setSearchField("path:job.purchaseOrder.poNumber"; "tag:PO"; "placeholder:poNumber"; "popupDescription:the Purchase Order number"; "onlyWithTag"; "pupopPart:invoice")
	$entry.setSearchField("path:job.invoiceDate"; "tag:invoiceDate"; "placeholder:invoiceDate"; "date"; "onlyWithTag")
	
	$entry.setPanel("panel_jobInvoice")
	$entry.setPanelPage(1; ""; "Main")
	$entry.setPanelPage(2; ""; "Lot Qty Amt Based"; "disabled:Form.current_item.job.lineItem=True")
	$entry.setPanelPage(3; ""; "PO Items Based")
	$entry.setPanelPage(4; ""; "Order Items"; "disabled:Form.current_item.job.lineItem=False")
	
	$entry.setLBItemsColumn("invoiceNumber"; "Invoice#"; "width:100")
	$entry.setLBItemsColumn("job.jobNumber"; "Job#"; "width:100")
	$entry.setLBItemsColumn("job.purchaseOrder.customer.name"; "customer"; "width:100")
	$entry.setLBItemsColumn("invoiceDate"; "Invoice Date"; "width:100")
	
	$entry.setSubset("main")
	
	$entry.setLBItemsOrderBy("invoiceNumber")
	$entry.setMainViewLabel("Ready to invoices")
	
	$entry.setItemListAction("Export to Excel"; "_ga_exportInvoicesSelection")
	
	$entry.setItemListAction("Print selection"; "_ga_printInvoicesSelection")
	
	$entry.setItemAction("Print Invoice"; "_ga_printInvoice")
	
	$entry.enableTransaction()
	
	$entry.activateFavorite()
	
	
	
	// MARK: -Filters
	
	
	
	// MARK: -Views
	$view:=cs:C1710.sfw_definitionView.new("postedInvoices"; "Posted Invoices")  //; "derivedFrom:main"; $entry)
	$view.setSubset("postedInvoices")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/archived-16x16.png")
	$view.setLBItemsColumn("invoiceNumber"; "Invoice#"; "width:100")
	$view.setLBItemsColumn("job.jobNumber"; "Job#"; "width:100")
	$view.setLBItemsColumn("job.purchaseOrder.customer.name"; "customer"; "width:100")
	$view.setLBItemsColumn("invoiceDate"; "Invoice Date"; "width:100")
	$view.setLBItemsOrderBy("invoiceNumber")
	$entry.setView($view)
	
	//$view:=cs.sfw_definitionView.new("allReadyToInvoice"; "All Invoice")  //; "derivedFrom:main"; $entry)
	//$view.setSubset("allReadyToInvoice")
	//$view.setPictoLabel("/RESOURCES/ga/image/picto/archived-16x16.png")
	//$view.setLBItemsColumn("invoiceNumber"; "Invoice#"; "width:100")
	//$view.setLBItemsColumn("job.jobNumber"; "Job#"; "width:100")
	//$view.setLBItemsColumn("job.purchaseOrder.customer.name"; "customer"; "width:100")
	//$view.setLBItemsColumn("invoiceDate"; "Invoice Date"; "width:100")
	//$view.setLBItemsOrderBy("invoiceNumber")
	//$entry.setView($view)
	
	$view:=cs:C1710.sfw_definitionView.new("lineItemJobInvoices"; "Invoices - Line-Item Jobs")  //; "derivedFrom:main"; $entry)
	$view.setSubset("lineItemJobInvoices")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/archived-16x16.png")
	$view.setLBItemsColumn("invoiceNumber"; "Invoice#"; "width:100")
	$view.setLBItemsColumn("job.jobNumber"; "Job#"; "width:100")
	$view.setLBItemsColumn("job.purchaseOrder.customer.name"; "customer"; "width:100")
	$view.setLBItemsColumn("invoiceDate"; "Invoice Date"; "width:100")
	$view.setLBItemsOrderBy("invoiceNumber")
	$entry.setView($view)
	
	$view:=cs:C1710.sfw_definitionView.new("travelerBasedJobInvoices"; "Invoices - Traveler-based Jobs")  //; "derivedFrom:main"; $entry)
	$view.setSubset("travelerBasedJobInvoices")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/archived-16x16.png")
	$view.setLBItemsColumn("invoiceNumber"; "Invoice#"; "width:100")
	$view.setLBItemsColumn("job.jobNumber"; "Job#"; "width:100")
	$view.setLBItemsColumn("job.purchaseOrder.customer.name"; "customer"; "width:100")
	$view.setLBItemsColumn("invoiceDate"; "Invoice Date"; "width:100")
	$view.setLBItemsOrderBy("invoiceNumber")
	$entry.setView($view)
	
	
	$view:=cs:C1710.sfw_definitionView.new("archivedJobInvoice"; "Archived Jobs Invoices")  //; "derivedFrom:main"; $entry)
	$view.setSubset("archivedJobInvoice")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/archived-16x16.png")
	$view.setLBItemsColumn("invoiceNumber"; "Invoice#"; "width:100")
	$view.setLBItemsColumn("job.jobNumber"; "Job#"; "width:100")
	$view.setLBItemsColumn("job.purchaseOrder.customer.name"; "customer"; "width:100")
	$view.setLBItemsColumn("invoiceDate"; "Invoice Date"; "width:100")
	$view.setLBItemsOrderBy("invoiceNumber")
	$entry.setView($view)
	
	
Function main()->$invoices : cs:C1710.JobInvoiceSelection
	$invoices:=ds:C1482.JobInvoice.query("job.postToPO =:1 & job.archived =:2 & job.shipped =:3"; False:C215; False:C215; True:C214)
	
Function postedInvoices()->$invoices : cs:C1710.JobInvoiceSelection
	//cs.Util.me.setDateInterval(False)
	$invoices:=ds:C1482.JobInvoice.query("job.postToPO =:1 & job.archived =:2"; True:C214; False:C215)
	
	//Function allReadyToInvoice()->$invoices : cs.JobInvoiceSelection
	////cs.Util.me.setDateInterval(False)
	//$invoices:=ds.JobInvoice.query("job.postToPO =:1 & job.archived =:2 & job.shipped =:3"; False; False; True)
	
Function lineItemJobInvoices()->$invoices : cs:C1710.JobInvoiceSelection
	//cs.Util.me.setDateInterval(False)
	$invoices:=ds:C1482.JobInvoice.query("job.postToPO =:1 & job.archived =:2 & job.shipped =:3 & job.lineItem =:4"; False:C215; False:C215; True:C214; True:C214)
	
Function travelerBasedJobInvoices()->$invoices : cs:C1710.JobInvoiceSelection
	//cs.Util.me.setDateInterval(False)
	$invoices:=ds:C1482.JobInvoice.query("job.postToPO =:1 & job.archived =:2 & job.shipped =:3 & job.lineItem =:4"; False:C215; False:C215; True:C214; False:C215)
	
Function archivedJobInvoice()->$invoices : cs:C1710.JobInvoiceSelection
	$invoices:=ds:C1482.JobInvoice.query("job.archived =:1"; True:C214)
	
	