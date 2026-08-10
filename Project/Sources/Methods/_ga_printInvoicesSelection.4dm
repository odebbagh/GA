//%attributes = {}

/*
Method Name : _ga_printInvoicesSelection
Author : Medard /4D PS
Date : 24-December-2025
Purpose : Print Invoice Selection 
*/


If (Form:C1466.sfw.lb_items.length>0)
	
	var $identEntry : Text:=Form:C1466.sfw.view.ident
	var $context : Object
	
	$context:=New object:C1471()
	
	$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/invoicePrintList.4wp")
	$template:=WP Import document:C1318($file.platformPath)
	
	$context.subject:=Form:C1466.sfw.view.label
	
	SET PRINT OPTION:C733(Orientation option:K47:2; 1)
	
	
	WP SET DATA CONTEXT:C1786($template; $context)
	
	PRINT SETTINGS:C106(2)
	WP PRINT:C1343($template)
	
Else 
	cs:C1710.sfw_dialog.me.info(ds:C1482.sfw_readXliff("Info"; "No items in the list to print"))
	
End if 