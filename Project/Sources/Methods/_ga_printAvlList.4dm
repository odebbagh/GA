//%attributes = {}

/*
Method Name : _ga_printAvlList
Author : Medard /4D PS
Date : 11-August-2025
Purpose : This method print the avl selection on AVL Entry
*/




If (Form:C1466.sfw.lb_items.length>0)
	
	var $identEntry : Text:=Form:C1466.sfw.view.ident
	var $context : Object
	
	$context:=New object:C1471()
	
	$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/amlListPrint.4wp")
	$template:=WP Import document:C1318($file.platformPath)
	
	
	$context.length:=Form:C1466.sfw.lb_items.length
	$context.division:=_ga_getListFiltersValues("Division"; "UUID")
	$context.user:=Current machine:C483
	//$context.partNum:=Form.current_item.ourPartNum  //_ga_getListFiltersValues("PartData"; "UUID"; "internalPartNum")
	
	If (Form:C1466.sfw.searchbox="")
		
		$context.supplier:=_ga_getListFiltersValues("Supplier"; "UUID")
	Else 
		$context.supplier:=Form:C1466.sfw.searchbox
	End if 
	
	$context.subject:=Form:C1466.sfw.view.label
	
	SET PRINT OPTION:C733(Orientation option:K47:2; 1)
	
	//Case of 
	//: ($identEntry="main")
	
	//$context.subject:="AML"
	
	//: ($identEntry="productSuppliers")
	
	//$context.subject:="Products in AML"
	
	//: ($identEntry="serviceSuppliers")
	
	//$context.subject:="Services & suppliers in AML"
	
	//: ($identEntry="criticalProductSuppliers")
	
	//$context.subject:="Critical products & suppliers in AML"
	
	//: ($identEntry="criticalServicesSuppliers")
	
	//$context.subject:="Critical services & suppliers in AML"
	
	//Else 
	
	//End case 
	
	
	WP SET DATA CONTEXT:C1786($template; $context)
	
	PRINT SETTINGS:C106(2)
	WP PRINT:C1343($template)
	
Else 
	cs:C1710.sfw_dialog.me.info(ds:C1482.sfw_readXliff("Info"; "No items in the list to print"))
	
End if 



