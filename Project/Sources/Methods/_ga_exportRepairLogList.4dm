//%attributes = {}

/*
Method Name : _ga_exportRepairLogList
Author : Medard /4D PS
last modification Date : 03-march-2026
Purpose : This method export the items on repair Log  View List to an .xls document
*/


var $OK; $allFields; $continue : Boolean
var $fields : Collection
var $mapping : Collection:=New collection:C1472()

If (Form:C1466.sfw.lb_items.length>0)
	
	$fileName:=Form:C1466.sfw.view.label
	
	$templateFile:=Folder:C1567(fk resources folder:K87:11).file("excelTemplates/excelExportTemplate.xlsx")
	
	
	$continue:=True:C214
	$allFields:=False:C215
	
	MOUSE POSITION:C468($vlMouseX; $vlMouseY; $vlButton)
	
	$vtItems:="Export relevant fields; (-; Export all fields"
	$vlUserChoice:=Pop up menu:C542($vtItems)
	Case of 
		: ($vlUserChoice=1)
			$allFields:=False:C215
			
		: ($vlUserChoice=3)
			$allFields:=True:C214
			
		Else 
			$continue:=False:C215
			
	End case 
	
	If ($continue)
		If (Not:C34($allFields))
			$mapping:=New collection:C1472(\
				New object:C1471("header"; "System ID"; "field"; "equipment.assignedID"; "footerOperation"; ""); \
				New object:C1471("header"; "Report ID"; "field"; "reportID"; "footerOperation"; ""); \
				New object:C1471("header"; "Problem"; "field"; "problem"; "footerOperation"; ""); \
				New object:C1471("header"; "Fix"; "field"; "fix"; "footerOperation"; ""); \
				New object:C1471("header"; "Down hrs"; "field"; "downHrs"; "footerOperation"; "")\
				)
			
		Else 
			
			$mapping:=New collection:C1472(\
				New object:C1471("header"; "System ID"; "field"; "equipment.assignedID"; "footerOperation"; ""); \
				New object:C1471("header"; "Report ID"; "field"; "reportID"; "footerOperation"; ""); \
				New object:C1471("header"; "Problem"; "field"; "problem"; "footerOperation"; ""); \
				New object:C1471("header"; "Fix"; "field"; "fix"; "footerOperation"; ""); \
				New object:C1471("header"; "Down hrs"; "field"; "downHrs"; "footerOperation"; ""); \
				New object:C1471("header"; "Report Date"; "field"; "reportDate"; "footerOperation"; ""); \
				New object:C1471("header"; "Fix Date"; "field"; "fixedDate"; "footerOperation"; ""); \
				New object:C1471("header"; "Status"; "field"; "status"; "footerOperation"; ""); \
				New object:C1471("header"; "is Approved"; "field"; "isApproved"; "footerOperation"; ""); \
				New object:C1471("header"; "Approver"; "field"; "approvedBy"; "footerOperation"; ""); \
				New object:C1471("header"; "approvalDate"; "field"; "approvalDate"; "footerOperation"; ""); \
				New object:C1471("header"; "Up at"; "field"; "upAt"; "footerOperation"; ""); \
				New object:C1471("header"; "Down at"; "field"; "downAt"; "footerOperation"; ""); \
				New object:C1471("header"; "Fixed By"; "field"; "fixer"; "footerOperation"; ""); \
				New object:C1471("header"; "Reported By"; "field"; "reporter"; "footerOperation"; "")\
				)
		End if 
		
		If ($fileName="main") | ($fileName="Main view")
			$title:="All repairLogs"
			$fileName:="AllRepairLogs"
		Else 
			$title:=$fileName
			$fileName:=Replace string:C233($fileName; " "; "")
		End if 
		
		
		$destinationFolderPath:=Get 4D folder:C485(Current resources folder:K5:16)+"exportedData"+Folder separator:K24:12+"RepairLogs"
		
		$destinationFileName:=Split string:C1554(String:C10($fileName+"_"+Replace string:C233(String:C10(Date:C102(Timestamp:C1445)); "/"; "_")); " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2).join("")
		$sheetName:=$fileName
		$selection:=Form:C1466.sfw.lb_items
		$offscreen:=cs:C1710.ExcelDataExporter.new($templateFile.platformPath; $mapping; $selection; $destinationFileName; $destinationFolderPath; $title; $sheetName; True:C214)
		$excelSheet:=VP Run offscreen area($offscreen)
		
	End if 
	
	//cs.sfw_dialog.me.info(ds.sfw_readXliff("export.done"; "The export is done"))
	//OPEN URL($file.platformPath; *)
Else 
	
	cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("No items in the list to Export"))
	
End if 





