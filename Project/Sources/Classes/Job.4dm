Class extends DataClass

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	$entry:=cs:C1710.sfw_definitionEntry.new("jobs"; ["customerService"]; "Jobs"; "Job")
	$entry.setDataclass("Job")
	$entry.setDisplayOrder(-200)
	$entry.setIcon("image/entry/jobs-white-50x50.png")
	
	$entry.setSearchboxField("jobNumber")
	
	$entry.setPanel("panel_job"; 1)
	$entry.setPanelPage(1; "po-infos-32x32.png"; "Main")
	// Addresses are now shown in their own section on the Main page, so this tab is
	// disabled (kept in place to preserve the page numbering of the following tabs).
	$entry.setPanelPage(2; "po-addresses-32x32.png"; "Addresses"; "disabled")
	$entry.setPanelPage(3; "po-lines-32x32.png"; "Line Items")
	$entry.setPanelPage(4; "lots-32x32.png"; "Lots"; "disabled:Form.current_item.lineItem=True")
	
	
	$entry.setLBItemsColumn("jobNumber"; "Job #"; "width:100")
	$entry.setLBItemsColumn("purchaseOrder.customer.name"; "Division"; "width:250")
	$entry.setLBItemsColumn("dateCreated"; "Created"; "width:100")
	
	$entry.setLBItemsOrderBy("jobNumber")
	
	$entry.setItemListAction("Export to Excel"; "_ga_exportJobSelection")
	
	$entry.setItemAction("Print Shipper"; "_ga_printShipper")
	
	$entry.setItemAction("Generate Barcode"; "_ga_openBarCodeForm")
	
	$entry.setItemListAction("Search by Scanning"; "_ga_searchByBarcodeScanning")
	
	
	// MARK: -Views
	$view:=cs:C1710.sfw_definitionView.new("archivedJobs"; "Archived Jobs"; "derivedFrom:main"; $entry)
	$view.setSubset("archivedJobs")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/archived-16x16.png")
	$entry.setView($view)
	
	$view:=cs:C1710.sfw_definitionView.new("shippedJobs"; "Shipped Jobs"; "derivedFrom:main"; $entry)
	$view.setSubset("shippedJobs")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/shipped-16x16.png")
	$entry.setView($view)
	
	$view:=cs:C1710.sfw_definitionView.new("invoicedJobs"; "Invoiced Jobs"; "derivedFrom:main"; $entry)
	$view.setSubset("invoicedJobs")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/invoiced-16x16.png")
	$entry.setView($view)
	
	$view:=cs:C1710.sfw_definitionView.new("lotRelatedJobs"; "Lot Related Jobs"; "derivedFrom:main"; $entry)
	$view.setSubset("lotRelatedJobs")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/lotRelated-16x16.png")
	$entry.setView($view)
	
	$view:=cs:C1710.sfw_definitionView.new("notRelatedJobs"; "NR Jobs"; "derivedFrom:main"; $entry)
	$view.setSubset("notRelatedJobs")
	$view.setPictoLabel("/RESOURCES/ga/image/picto/notRelated-16x16.png")
	$entry.setView($view)
	
	$entry.enableTransaction()
	
	
Function archivedJobs()->$jobs : cs:C1710.JobSelection
	cs:C1710.Util.me.setDateInterval(False:C215)
	$jobs:=ds:C1482.Job.query("archived =:1 & archivedDate >=:2 & archivedDate <=:3"; True:C214; Storage:C1525.cache.startDate; Storage:C1525.cache.endDate)
	
Function shippedJobs()->$jobs : cs:C1710.JobSelection
	cs:C1710.Util.me.setDateInterval(False:C215)
	$jobs:=ds:C1482.Job.query("shipped =:1 & lastShipDate >=:2 & lastShipDate <=:3 & archived =:4"; True:C214; Storage:C1525.cache.startDate; Storage:C1525.cache.endDate; False:C215)
	
Function invoicedJobs()->$jobs : cs:C1710.JobSelection
	cs:C1710.Util.me.setDateInterval(False:C215)
	$jobs:=ds:C1482.Job.query("shipped =:1 & invoiceDate >=:2 & invoiceDate <=:3 & archived =:4"; True:C214; Storage:C1525.cache.startDate; Storage:C1525.cache.endDate; False:C215)
	
Function lotRelatedJobs()->$jobs : cs:C1710.JobSelection
	$jobs:=ds:C1482.Job.query("lineItem =:1 & archived =:2"; False:C215; False:C215)
	
Function notRelatedJobs()->$jobs : cs:C1710.JobSelection
	$jobs:=ds:C1482.Job.query("lineItem =:1 & archived =:2"; True:C214; False:C215)
	
	
	
	// MARK: -
	
local Function cacheLoad()
	
	If (Storage:C1525.cache=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.cache:=New shared object:C1526
		End use 
	End if 
	If (Storage:C1525.cache.jobs=Null:C1517)
		$jobs:=This:C1470._loadAsCollection()
		Use (Storage:C1525.cache)
			Storage:C1525.cache.jobs:=$jobs.copy(ck shared:K85:29; Storage:C1525.cache)
		End use 
	End if 
	
	
Function _loadAsCollection()->$jobs : Collection
	$jobs:=This:C1470.query("shipped =:1 & postToPO =:2"; True:C214; False:C215).toCollection("UUID,jobNumber").orderBy("jobNumber")
	
	
	