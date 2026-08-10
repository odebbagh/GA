//%attributes = {}


/*
Method Name : _ga_printEquipmentList
Author : Medard /4D PS
Date : 20-May-2025
Purpose : Print Equipments View List
*/

If (Form:C1466.sfw.lb_items.length>0)
	
	var $identEntry : Text:=Form:C1466.sfw.view.ident
	var $context : Object
	
	$context:=New object:C1471()
	
	$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/equipmentsListPrint.4wp")
	$template:=WP Import document:C1318($file.platformPath)
	
	$context.length:=Form:C1466.sfw.lb_items.length
	$context.location:=_ga_getListFiltersValues("EquipmentLocation"; "UUID")
	$context.equipmentType:=_ga_getListFiltersValues("ToolType"; "UUID")
	$context.division:=_ga_getListFiltersValues("Division"; "UUID")
	$context.user:=Current machine:C483
	$context.subject:=Form:C1466.sfw.view.label
	
	SET PRINT OPTION:C733(Orientation option:K47:2; 1)
	
	//Case of 
	//: ($identEntry="main")
	
	//$context.subject:="equipments"
	
	//: ($identEntry="equipmentsOutOfCalibration")
	
	//$context.subject:="equipments out of calibration"
	
	//: ($identEntry="pmEquipments")
	
	//$context.subject:="PM equipments"
	
	//: ($identEntry="dueCalibrationEquipments")
	
	//$context.subject:="equipments overdue for calibration"
	
	//: ($identEntry="duePMEquipments")
	
	//$context.subject:="Due PM Equipments"
	
	//: ($identEntry="equipmentsDownOrOnHold")
	
	//$context.subject:="equipments down"
	
	//: ($identEntry="calibrationExemptList")
	
	//$context.subject:="equipments that do not required calibration"
	
	
	//End case 
	
	
	WP SET DATA CONTEXT:C1786($template; $context)
	
	PRINT SETTINGS:C106(2)
	WP COMPUTE FORMULAS:C1707($template)
	WP PRINT:C1343($template; wk do not recompute expressions:K81:312)
	
Else 
	cs:C1710.sfw_dialog.me.info(ds:C1482.sfw_readXliff("Info"; "No items in the list to print"))
	
End if 