//%attributes = {}

/*
Method Name : _ga_exportEquipmentList
Author : Medard /4D PS
Date : 10-November-2025
Last modification date : 12-march-2026
Purpose : This method export current job selection to an .xlsx document
*/



var $fields : Collection
var $mapping : Collection:=New collection:C1472()

If (Form:C1466.sfw.lb_items.length>0)
	
	$fileName:=Form:C1466.sfw.view.label
	
	$templateFile:=Folder:C1567(fk resources folder:K87:11).file("excelTemplates/excelExportTemplate.xlsx")
	
	If ($fileName="Archived Jobs")
		$mapping:=New collection:C1472(\
			New object:C1471("header"; "Job #"; "field"; "jobNumber"; "footerOperation"; ""); \
			New object:C1471("header"; "Last Ship Date"; "field"; "lastShipDate"; "footerOperation"; ""); \
			New object:C1471("header"; "Invoice Date"; "field"; "invoiceDate"; "footerOperation"; ""); \
			New object:C1471("header"; "Customer"; "field"; "customer.name"; "footerOperation"; ""); \
			New object:C1471("header"; "PO #"; "field"; "life"; "poNumber"; ""); \
			New object:C1471("header"; "Process"; "field"; "process"; "footerOperation"; ""); \
			New object:C1471("header"; "Currency"; "field"; "currency"; "footerOperation"; ""); \
			New object:C1471("header"; "Total Charge"; "field"; "totalCharge"; "footerOperation"; "")\
			)
		
		
	Else 
		$mapping:=New collection:C1472(\
			New object:C1471("header"; "Job #"; "field"; "jobNumber"; "footerOperation"; ""); \
			New object:C1471("header"; "Expected Date"; "field"; "expectedDate"; "footerOperation"; ""); \
			New object:C1471("header"; "Recommit Date"; "field"; "recommitDate"; "footerOperation"; ""); \
			New object:C1471("header"; "Last Ship Date"; "field"; "lastShipDate"; "footerOperation"; ""); \
			New object:C1471("header"; "Invoice Date"; "field"; "invoiceDate"; "footerOperation"; ""); \
			New object:C1471("header"; "Customer"; "field"; "customer.name"; "footerOperation"; ""); \
			New object:C1471("header"; "PO #"; "field"; "life"; "poNumber"; ""); \
			New object:C1471("header"; "Process"; "field"; "process"; "footerOperation"; ""); \
			New object:C1471("header"; "Currency"; "field"; "currency"; "footerOperation"; ""); \
			New object:C1471("header"; "Total Charge"; "field"; "totalCharge"; "footerOperation"; ""); \
			New object:C1471("header"; "Shipped"; "field"; "shipped"; "footerOperation"; ""); \
			New object:C1471("header"; "Post to PO"; "field"; "postToPO"; "footerOperation"; "")\
			)
		
	End if 
	
	
	If ($fileName="Main view")
		$title:="All Jobs"
		$fileName:="AllJobs"
	Else 
		$title:=$fileName
		$fileName:=Replace string:C233($fileName; " "; "")
	End if 
	
	$destinationFolderPath:=Get 4D folder:C485(Current resources folder:K5:16)+"exportedData"+Folder separator:K24:12+"Jobs"
	
	$destinationFileName:=Split string:C1554(String:C10($fileName+"_"+Replace string:C233(String:C10(Date:C102(Timestamp:C1445)); "/"; "_")); " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2).join("")
	$sheetName:=$fileName
	$selection:=Form:C1466.sfw.lb_items
	$offscreen:=cs:C1710.ExcelDataExporter.new($templateFile.platformPath; $mapping; $selection; $destinationFileName; $destinationFolderPath; $title; $sheetName; True:C214)
	$excelSheet:=VP Run offscreen area($offscreen)
	
	
	
Else 
	
	cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("No items in the list to Export"))
	
End if 





