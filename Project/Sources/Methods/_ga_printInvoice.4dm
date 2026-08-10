//%attributes = {}
/*
Method Name : _ga_printInvoice
Author : Medard /4D PS
Date : 01-December-2025
Purpose : Print Invoice
*/

If (Form:C1466.current_item#Null:C1517)
	
	var $context : Object
	
	$context:=New object:C1471()
	
	$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/invoicePrintOutTemplate.4wp")
	$template:=WP Import document:C1318($file.platformPath)
	
	$billingAddress:=Form:C1466.current_item.job.address.addresses.query("type =:1"; "billing").first()
	$billingAddress.detail.state:=$billingAddress.detail.state#Null:C1517 ? $billingAddress.detail.state : ""
	$address:=Undefined:C82($billingAddress.detail.street_1) ? $billingAddress.detail.street : $billingAddress.detail.street_1
	$address:=$address+"\n"+$billingAddress.detail.city+"\n"+\
		$billingAddress.detail.state+" "  //+$billingAddress.detail.postcode+"\n"
	$address:=Undefined:C82($billingAddress.detail.postcode) ? $address+$billingAddress.detail.zipCode+"\n" : $address+$billingAddress.detail.postcode+"\n"
	$address:=$address+$billingAddress.detail.country
	$context.accountAddress:=$address
	
	$payToAddressInfo:=ds:C1482.DivisionInfo.query("UUID_Division =:1"; Form:C1466.current_item.job.UUID_Division).first()
	
	$payToAdress:=$payToAddressInfo.contactDetails.addresses.query("type =:1"; "remit").first()
	$payToAdress.detail.state:=$payToAdress.detail.state#Null:C1517 ? $payToAdress.detail.state : ""
	$address:=Undefined:C82($payToAdress.detail.street_1) ? $payToAdress.detail.street : $payToAdress.detail.street_1
	$address:=$address+"\n"+$payToAdress.detail.city+","+\
		$payToAdress.detail.state+" "  //+$payToAdress.detail.postcode+"\n"  //+$payToAdress.detail.country
	$address:=Undefined:C82($payToAdress.detail.postcode) ? $address+$payToAdress.detail.zipCode+"\n" : $address+$payToAdress.detail.postcode+"\n"
	
	$context.remitAddress:=$address
	
	$context.invoiceNumber:=Form:C1466.current_item.invoiceNumber
	$context.jobNumber:=Form:C1466.current_item.job.jobNumber
	$context.invoiceDate:=Form:C1466.current_item.invoiceDate
	$context.customer:=Form:C1466.current_item.job.customerName
	$context.posted:=Form:C1466.current_item.job.postToPO
	
	$case_a_cocher:=WP Get element by ID:C1549($template; "textBox6")
	If ($context.posted=False:C215)
		WP DELETE TEXT BOX:C1798($case_a_cocher)
	End if 
	
	$context.customerShipper:=Form:C1466.current_item.job.customerShipper
	$context.poNumber:=Form:C1466.current_item.job.poNumber
	$context.process:=Form:C1466.current_item.job.process
	$context.pr_qualifier:=Form:C1466.current_item.job.pr_qualifier
	$context.deviceNumber:=Form:C1466.current_item.job.deviceNumber
	$context.poRel:=Form:C1466.current_item.job.poRel
	
	//Add table
	$paragraphs:=WP Get elements:C1550($template; wk type paragraph:K81:191)
	
	For each ($paragraph; $paragraphs)
		
		If (WP Get text:C1575($paragraph)="Tabl@")
			$range:=WP Paragraph range:C1346($paragraph)
		End if 
		
	End for each 
	$table:=WP Insert table:C1473($range; wk replace:K81:177; wk include in range:K81:180)
	
	Case of 
			
		: (Form:C1466.current_item.poBasedCharges#0)
			
			// insert header
			$row:=WP Table append row:C1474($table; "#"; "Description"; "Qty"; "Unit price"; "Taxable"; "Sales Tax"; "Total")
			
			$poLines:=ds:C1482.PurchaseOrderLine.query("UUID_Job =:1"; Form:C1466.current_item.job.UUID)
			
			For each ($poLine; $poLines)
				
				$row:=WP Table append row:C1474($table; $poLine.itemNum; $poLine.description; $poLine.qtyOrdered; "$"+String:C10($poLine.unitPrice; "###,###,##0.00"); \
					$poLine.taxable=True:C214 ? "Yes" : "No"; $poLine.saleTax; "$"+String:C10($poLine.total; "###,###,##0.00"))
				
			End for each 
			
			$numCol:=WP Table get columns:C1476($table; 1)
			$descCol:=WP Table get columns:C1476($table; 2)
			$qtyCol:=WP Table get columns:C1476($table; 3)
			$unitPriceCol:=WP Table get columns:C1476($table; 4)
			$taxableCol:=WP Table get columns:C1476($table; 5)
			$salesTaxCol:=WP Table get columns:C1476($table; 6)  //
			$totalCol:=WP Table get columns:C1476($table; 7)
			
			
			WP SET ATTRIBUTES:C1342($numCol; wk width:K81:45; "1cm")
			WP SET ATTRIBUTES:C1342($numCol; wk text align:K81:49; wk right:K81:96)
			WP SET ATTRIBUTES:C1342($descCol; wk width:K81:45; "9.2cm")
			WP SET ATTRIBUTES:C1342($descCol; wk text align:K81:49; wk left:K81:95)
			WP SET ATTRIBUTES:C1342($qtyCol; wk width:K81:45; "1cm")
			WP SET ATTRIBUTES:C1342($qtyCol; wk text align:K81:49; wk right:K81:96)
			WP SET ATTRIBUTES:C1342($unitPriceCol; wk width:K81:45; "2cm")
			WP SET ATTRIBUTES:C1342($unitPriceCol; wk text align:K81:49; wk right:K81:96)
			WP SET ATTRIBUTES:C1342($taxableCol; wk width:K81:45; "1.3cm")
			WP SET ATTRIBUTES:C1342($taxableCol; wk text align:K81:49; wk right:K81:96)
			WP SET ATTRIBUTES:C1342($salesTaxCol; wk width:K81:45; "1.6cm")
			WP SET ATTRIBUTES:C1342($salesTaxCol; wk text align:K81:49; wk right:K81:96)
			WP SET ATTRIBUTES:C1342($totalCol; wk width:K81:45; "2cm")
			WP SET ATTRIBUTES:C1342($totalCol; wk text align:K81:49; wk right:K81:96)
			
			
		: (Form:C1466.current_item.boxStockShipment=True:C214)
			
			//Notice that boxStockShipment is always false so this piece of cade never executed --> TODO : CHECK FURTHER 
			
		: (Form:C1466.current_item.lineItem=True:C214)
			
			
		Else 
			
			
	End case 
	
	
	$endRange:=WP Text range:C1341($template; wk end text:K81:164; wk end text:K81:164)
	
	WP SET TEXT:C1574($endRange; Char:C90(Carriage return:K15:38); wk append:K81:179; wk include in range:K81:180)
	
	WP SET ATTRIBUTES:C1342($endRange; wk font size:K81:66; 11)
	WP SET ATTRIBUTES:C1342($endRange; wk layout unit:K81:78; wk unit cm:K81:135)
	
	
	$tab:=New object:C1471
	$tab[wk type:K81:189]:=wk left:K81:95
	$tab[wk offset:K81:280]:="17.5cm"
	$tab[wk leading:K81:281]:=" "
	
	$tab_1:=New object:C1471
	$tab_1[wk type:K81:189]:=wk right:K81:96
	$tab_1[wk offset:K81:280]:="17cm"
	$tab_1[wk leading:K81:281]:=" "
	
	//WP SET ATTRIBUTES($endRange; wk tab default; $tab)
	
	WP SET ATTRIBUTES:C1342($endRange; wk tabs:K81:278; New collection:C1472($tab_1; $tab))
	
	$text:=Char:C90(Carriage return:K15:38)+Form:C1466.current_item.job.miscNote+Char:C90(Tab:K15:37)+Char:C90(Tab:K15:37)+Form:C1466.current_item.job.currency+String:C10(Form:C1466.current_item.job.miscCharges; "###,###,##0.00")
	
	WP SET TEXT:C1574($endRange; $text; wk append:K81:179; wk include in range:K81:180)
	
	WP SET TEXT:C1574($endRange; Char:C90(Carriage return:K15:38); wk append:K81:179; wk include in range:K81:180)
	
	
	If (Form:C1466.current_item.job.taxable=False:C215)
		$text:=Char:C90(Carriage return:K15:38)+Char:C90(Tab:K15:37)+Char:C90(Tab:K15:37)+"☐ Taxable"
	Else 
		$text:=Char:C90(Carriage return:K15:38)+Char:C90(Tab:K15:37)+Char:C90(Tab:K15:37)+"☒ Taxable"
	End if 
	
	WP SET TEXT:C1574($endRange; $text; wk append:K81:179; wk include in range:K81:180)
	
	
	WP SET TEXT:C1574($endRange; Char:C90(Carriage return:K15:38); wk append:K81:179; wk include in range:K81:180)
	
	$tax:=Form:C1466.current_item.job.salesTax#Null:C1517 ? Form:C1466.current_item.job.salesTax.rate : 0
	
	$text:=Char:C90(Carriage return:K15:38)+Char:C90(Tab:K15:37)+"Tax@ "+String:C10($tax)+"%"+Char:C90(Tab:K15:37)+Form:C1466.current_item.job.currency+String:C10(Form:C1466.current_item.job.totalTax; "###,###,##0.00")
	
	$text:=$text+Char:C90(Carriage return:K15:38)+Char:C90(Tab:K15:37)+"Freight"+Char:C90(Tab:K15:37)+Form:C1466.current_item.job.currency+String:C10(Form:C1466.current_item.job.freight; "###,###,##0.00")
	
	WP SET TEXT:C1574($endRange; $text; wk append:K81:179; wk include in range:K81:180)
	
	
	WP SET TEXT:C1574($endRange; Char:C90(Carriage return:K15:38); wk append:K81:179; wk include in range:K81:180)
	
	$text:=Char:C90(Carriage return:K15:38)+Char:C90(Tab:K15:37)+"Total Due"
	
	WP SET TEXT:C1574($endRange; $text; wk append:K81:179; wk exclude from range:K81:181)
	
	$endRange:=WP Text range:C1341($template; wk end text:K81:164; wk end text:K81:164)
	
	WP SET ATTRIBUTES:C1342($endRange; wk font size:K81:66; 11)
	
	WP SET ATTRIBUTES:C1342($endRange; wk layout unit:K81:78; wk unit cm:K81:135)
	
	WP SET ATTRIBUTES:C1342($endRange; wk tabs:K81:278; New collection:C1472($tab_1; $tab))
	
	$text:=Char:C90(Tab:K15:37)+Form:C1466.current_item.job.currency+String:C10(Form:C1466.current_item.total; "###,###,##0.00")
	
	WP SET TEXT:C1574($endRange; $text; wk append:K81:179; wk include in range:K81:180)
	
	WP SET ATTRIBUTES:C1342($endRange; wk font bold:K81:68; wk true:K81:174)
	
	
	WP SET DATA CONTEXT:C1786($template; $context)
	
	PRINT SETTINGS:C106(2)
	WP PRINT:C1343($template)
	
Else 
	cs:C1710.sfw_dialog.me.info(ds:C1482.sfw_readXliff("Info"; "Select an Invoice to print"))
	
End if 
