//%attributes = {}
/*
Method Name : _ga_printInvoice
Author : Medard /4D PS
Last modification date : 02-march-2026
Purpose : Print Asset selection List
*/

If (Form:C1466.sfw.lb_items.length>0)
	
	var $context : Object
	
	$context:=New object:C1471()
	
	$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/selectionPrintTemplate.4wp")
	$template:=WP Import document:C1318($file.platformPath)
	
	$context.subject:=Form:C1466.sfw.view.label
	//Add table
	$paragraphs:=WP Get elements:C1550($template; wk type paragraph:K81:191)
	
	For each ($paragraph; $paragraphs)
		
		If (WP Get text:C1575($paragraph)="Tabl@")
			$range:=WP Paragraph range:C1346($paragraph)
		End if 
		
	End for each 
	
	$table:=WP Insert table:C1473($range; wk replace:K81:177; wk include in range:K81:180)
	
	// insert header
	$row:=WP Table append row:C1474($table; "Asset #"; "Asset type"; "Vendor"; "Description"; "Monthly Dep"; "Acquired Date"; "Total acc depreciation")
	
	For each ($record; Form:C1466.sfw.lb_items)
		
		$row:=WP Table append row:C1474($table; $record.assetNumber; String:C10($record.assetType.name); String:C10($record.vendor.name); $record.description; \
			String:C10($record.monthlyDepreciation; "###,###,##0.00"); String:C10($record.acquiredDate); String:C10($record.totalAccDepreciation; "###,###,##0.00"))
		
	End for each 
	
	$numCol:=WP Table get columns:C1476($table; 1)
	$descCol:=WP Table get columns:C1476($table; 2)
	$qtyCol:=WP Table get columns:C1476($table; 3)
	$unitPriceCol:=WP Table get columns:C1476($table; 4)
	$taxableCol:=WP Table get columns:C1476($table; 5)
	$salesTaxCol:=WP Table get columns:C1476($table; 6)  //
	$totalCol:=WP Table get columns:C1476($table; 7)
	
	
	WP SET ATTRIBUTES:C1342($numCol; wk width:K81:45; "1.2cm")
	WP SET ATTRIBUTES:C1342($numCol; wk text align:K81:49; wk right:K81:96)
	WP SET ATTRIBUTES:C1342($descCol; wk width:K81:45; "4cm")
	WP SET ATTRIBUTES:C1342($descCol; wk text align:K81:49; wk left:K81:95)
	WP SET ATTRIBUTES:C1342($qtyCol; wk width:K81:45; "2cm")
	WP SET ATTRIBUTES:C1342($qtyCol; wk text align:K81:49; wk right:K81:96)
	WP SET ATTRIBUTES:C1342($unitPriceCol; wk width:K81:45; "5cm")
	WP SET ATTRIBUTES:C1342($unitPriceCol; wk text align:K81:49; wk right:K81:96)
	WP SET ATTRIBUTES:C1342($taxableCol; wk width:K81:45; "1.5cm")
	WP SET ATTRIBUTES:C1342($taxableCol; wk text align:K81:49; wk right:K81:96)
	WP SET ATTRIBUTES:C1342($salesTaxCol; wk width:K81:45; "2cm")
	WP SET ATTRIBUTES:C1342($salesTaxCol; wk text align:K81:49; wk right:K81:96)
	WP SET ATTRIBUTES:C1342($totalCol; wk width:K81:45; "2cm")
	WP SET ATTRIBUTES:C1342($totalCol; wk text align:K81:49; wk right:K81:96)
	
	
	WP SET DATA CONTEXT:C1786($template; $context)
	
	PRINT SETTINGS:C106(2)
	WP PRINT:C1343($template)
	
Else 
	
	
End if 