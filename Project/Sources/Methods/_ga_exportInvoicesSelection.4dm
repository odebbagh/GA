//%attributes = {}

/*
Method Name : _ga_exportInvoicesSelection
Author : Medard /4D PS
Date : 22-December-2025
Purpose : This method export current invoice selection to .xlsx document
*/


var $fields : Collection
var $mapping : Collection:=New collection:C1472()

If (Form:C1466.sfw.lb_items.length>0)
	
	$fileName:=Form:C1466.sfw.view.label
	
	$templateFile:=Folder:C1567(fk resources folder:K87:11).file("excelTemplates/excelExportTemplate.xlsx")
	
	$mapping:=New collection:C1472(\
		New object:C1471("header"; "Div"; "field"; "job.division.name"; "footerOperation"; ""); \
		New object:C1471("header"; "Job#"; "field"; "job.jobNumber"; "footerOperation"; ""); \
		New object:C1471("header"; "Date In"; "field"; "job.dateCreated"; "footerOperation"; ""); \
		New object:C1471("header"; "Expected Out"; "field"; "job.expectedDate"; "footerOperation"; ""); \
		New object:C1471("header"; "Last ship on"; "field"; "job.lastShipDate"; "footerOperation"; ""); \
		New object:C1471("header"; "Invoice date"; "field"; "job.invoiceDate"; "footerOperation"; ""); \
		New object:C1471("header"; "Customer"; "field"; "job.purchaseOrder.customer.name"; "footerOperation"; ""); \
		New object:C1471("header"; "PO#"; "field"; "job.purchaseOrder.poNumber"; "footerOperation"; ""); \
		New object:C1471("header"; "Process"; "field"; "job.process"; "footerOperation"; ""); \
		New object:C1471("header"; "Ccy"; "field"; "job.currency"; "footerOperation"; ""); \
		New object:C1471("header"; "Charge"; "field"; "job.totalCharge"; "footerOperation"; "sum"); \
		New object:C1471("header"; "Shipped?"; "field"; "job.shipped"; "footerOperation"; ""); \
		New object:C1471("header"; "Invoiced"; "field"; "job.postToPO"; "footerOperation"; ""); \
		New object:C1471("header"; "Qty In"; "field"; "job.qty"; "footerOperation"; "sum"); \
		New object:C1471("header"; "In-House"; "field"; "job.qtyOnHand"; "footerOperation"; ""); \
		New object:C1471("header"; "Device"; "field"; "job.deviceNumber"; "footerOperation"; ""); \
		New object:C1471("header"; "Parent"; "field"; "job.parentJobNumber"; "footerOperation"; ""); \
		New object:C1471("header"; "Tester"; "field"; "job.testerType"; "footerOperation"; ""); \
		New object:C1471("header"; "Pkg"; "field"; "job.packageType"; "footerOperation"; ""); \
		New object:C1471("header"; "Note"; "field"; "job.acNote"; "footerOperation"; ""); \
		New object:C1471("header"; "Inven-cost"; "field"; "job.inventoryCost"; "footerOperation"; "sum"); \
		New object:C1471("header"; "Derect-cost"; "field"; "job.directCost"; "footerOperation"; "")\
		)
	
	If ($fileName="main") | ($fileName="Main view")
		$title:="All Invoices"
		$fileName:="AllInvoices"
	Else 
		$title:=$fileName
		$fileName:=Replace string:C233($fileName; " "; "")
	End if 
	
	
	$destinationFolderPath:=Get 4D folder:C485(Current resources folder:K5:16)+"exportedData"+Folder separator:K24:12+"Invoices"
	
	$destinationFileName:=Split string:C1554(String:C10($fileName+"_"+Replace string:C233(String:C10(Date:C102(Timestamp:C1445)); "/"; "_")); " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2).join("")
	$sheetName:=$fileName
	$selection:=Form:C1466.sfw.lb_items
	$offscreen:=cs:C1710.ExcelDataExporter.new($templateFile.platformPath; $mapping; $selection; $destinationFileName; $destinationFolderPath; $title; $sheetName; True:C214)
	$excelSheet:=VP Run offscreen area($offscreen)
	
	//cs.sfw_dialog.me.info(ds.sfw_readXliff("export.done"; "The export is done"))
	//OPEN URL($file.platformPath; *)
Else 
	
	cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("No items in the list to Export"))
	
End if 





