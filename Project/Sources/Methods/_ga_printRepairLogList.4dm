//%attributes = {}


/*
Method Name : _ga_printRepairLogList
Author : Medard /4D PS
Date : 03-June-2025
Purpose : Print ReportLog View List
*/

If (Form:C1466.sfw.lb_items.length>0)
	
	var $identEntry : Text:=Form:C1466.sfw.view.ident
	var $context : Object
	
	$context:=New object:C1471()
	
	$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/repairLogsListPrint.4wp")
	$template:=WP Import document:C1318($file.platformPath)
	
	
	$context.length:=Form:C1466.sfw.lb_items.length
	$context.division:=_ga_getListFiltersValues("Division"; "UUID")
	$context.user:=Current machine:C483
	Use (Storage:C1525)
		$startDate:=Storage:C1525.cache.startDate
		$endDate:=Storage:C1525.cache.endDate
	End use 
	
	If (Form:C1466.sfw.searchbox="")
		
		$equipment:="all"
	Else 
		$equipment:=Form:C1466.sfw.searchbox
	End if 
	
	$context.equipment:=$equipment
	
	$context.subject:=Form:C1466.sfw.view.label
	
	SET PRINT OPTION:C733(Orientation option:K47:2; 1)
	
	//Case of 
	//: ($identEntry="main") & (Count parameters=0)
	
	//$context.subject:="Repairs Logs"
	
	//: ($identEntry="currentProblems") & (Count parameters=0)
	
	//$context.subject:="Open problems"
	
	//: ($identEntry="problemsByInterval") & (Count parameters=0)
	
	//$context.subject:="Problems from "+String($startDate)+" to "+String($endDate)
	
	//: ($identEntry="repairsByInterval") & (Count parameters=0)
	
	//$context.subject:="Repairs between "+String($startDate)+" to "+String($endDate)
	
	//Else 
	//If (Count parameters=1)
	//$context.subject:="Down incident report"
	//End if 
	
	
	//End case 
	
	
	WP SET DATA CONTEXT:C1786($template; $context)
	
	PRINT SETTINGS:C106(2)
	WP PRINT:C1343($template)
	
Else 
	cs:C1710.sfw_dialog.me.info(ds:C1482.sfw_readXliff("Info"; "No items in the list to print"))
	
End if 