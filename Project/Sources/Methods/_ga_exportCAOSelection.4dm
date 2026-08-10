//%attributes = {}

/*
Method Name : _ga_exportCAOSelection
Author : Medard /4D PS
Date : 23-Jan-2025
Purpose : This method export current CAO selection to .xlsx document
*/


var $fields : Collection
var $mapping : Collection:=New collection:C1472()

If (Form:C1466.sfw.lb_items.length>0)
	
	$fileName:=Form:C1466.sfw.view.label
	
	$templateFile:=Folder:C1567(fk resources folder:K87:11).file("excelTemplates/excelExportTemplate.xlsx")
	
	$mapping:=New collection:C1472(\
		New object:C1471("header"; "Name"; "field"; "name"; "footerOperation"; "TOTAL"); \
		New object:C1471("header"; "Type"; "field"; "type.name"; "footerOperation"; ""); \
		New object:C1471("header"; "Type Details"; "field"; "typeDetail.name"; "footerOperation"; ""); \
		New object:C1471("header"; "Balance"; "field"; "balance"; "footerOperation"; "sum")\
		)
	
	If ($fileName="main") | ($fileName="Main view")
		$title:="All CAOs"
		$fileName:="AllCAOs"
	Else 
		$title:=$fileName
		$fileName:=Replace string:C233($fileName; " "; "")
	End if 
	
	$destinationFolderPath:=Get 4D folder:C485(Current resources folder:K5:16)+"exportedData"+Folder separator:K24:12+"CAO"
	
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





