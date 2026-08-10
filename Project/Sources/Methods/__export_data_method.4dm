//%attributes = {}

//Instruntion : 

//-Do not execute on framework version
//-copy the method and paste in the old version of the application
//-modify if needed and execute to export data to the DataJson folder(Folder that contain the exported data)
//-if you made some modifications, copy the method content from old system to framework version


var $folderPath : Text
var $myFolder : Object

$folderPath:=Get 4D folder:C485(Database folder:K5:14)+"DataJson"

$myFolder:=Folder:C1567(Convert path system to POSIX:C1106($folderPath))

If (Not:C34($myFolder.exists))
	$myFolder.create()
End if 


If (True:C214)  // export po & po lines (po <-- po_lines)
	ALL RECORDS:C47([PO_LOG])
	
	$records:=New collection:C1472()
	
	While (Not:C34(End selection:C36([PO_LOG])))
		$record:=New object:C1471(\
			"customer_name"; [PO_LOG]Customer; \
			"poNumber"; [PO_LOG]PO_Number; \
			"poAmount"; [PO_LOG]PO_Amount; \
			"amountBilled"; [PO_LOG]AMT_Billed; \
			"ourQuote"; [PO_LOG]Our_Quote; \
			"resaleNumber"; [PO_LOG]Resale_Number; \
			"identifier"; [PO_LOG]Identifier; \
			"initials"; [PO_LOG]Initials; \
			"division"; [PO_LOG]Division; \
			"openPO"; [PO_LOG]Open_PO; \
			"address"; New object:C1471("addresses"; New collection:C1472()); \
			"altBillTo"; [PO_LOG]Alt_bill_to; \
			"dropShipCustomer"; [PO_LOG]Drop_Ship_Customer; \
			"releaseNumber"; [PO_LOG]Release_Number; \
			"forTimeBilling"; [PO_LOG]For_time_billing; \
			"timeBillingRate"; [PO_LOG]Time_billing_Rate; \
			"timeBilling"; [PO_LOG]Time_billing; \
			"description"; [PO_LOG]Description; \
			"invoices"; New collection:C1472(); \
			"lineItems"; New collection:C1472()\
			)
		
		$record.address.addresses.push(New object:C1471(\
			"type"; "billing"; \
			"detail"; New object:C1471("street_1"; [PO_LOG]Bill_add1; "street_2"; [PO_LOG]Bill_add2; "city"; [PO_LOG]Bill_City; "state"; [PO_LOG]Bill_ST; "postcode"; [PO_LOG]Bill_ZIP; "country"; "US"; "iso_code_2"; "US")\
			))
		
		$record.address.addresses.push(New object:C1471(\
			"type"; "shipping"; \
			"detail"; New object:C1471("street_1"; [PO_LOG]Ship_add1; "street_2"; [PO_LOG]Ship_add2; "city"; [PO_LOG]Ship_City; "state"; [PO_LOG]Ship_ST; "postcode"; [PO_LOG]Ship_ZIP; "country"; "US"; "iso_code_2"; "US")\
			))
		
		QUERY:C277([Receivables]; [Receivables]POnum=[PO_LOG]PO_Number)
		
		If ([PO_LOG]PO_Number="0000003831")
			//TRACE
		End if 
		
		While (Not:C34(End selection:C36([Receivables])))
			$record.invoices.push(New object:C1471(\
				"customerId"; [Receivables]custid; \
				"saleAmount"; [Receivables]Saleamt; \
				"amountPaid"; [Receivables]Amt_Paid; \
				"division"; [Receivables]Division; \
				"invoice"; [Receivables]R_type+" "+String:C10([Receivables]Invoice); \
				"date"; [Receivables]Idate; \
				"customer"; [Receivables]Customer; \
				"currency"; [Receivables]Currency; \
				"total"; [Receivables]TotalInv; \
				"due"; [Receivables]NetDue; \
				"slip"; [Receivables]D_slip\
				))
			
			NEXT RECORD:C51([Receivables])
		End while 
		
		
		QUERY:C277([PO_Items]; [PO_Items]PO_number=[PO_LOG]PO_Number)
		
		While (Not:C34(End selection:C36([PO_Items])))
			If ([PO_Items]Part_Num#"")
				TRACE:C157
			End if 
			
			$lineItem:=New object:C1471(\
				"itemNum"; [PO_Items]Item_num; \
				"description"; [PO_Items]Item_Desc; \
				"partNum"; [PO_Items]Part_Num; \
				"dateOrdered"; [PO_Items]Date_Ordered; \
				"customerRequestedDate"; [PO_Items]CustomerRequestedDate; \
				"qtyOrdered"; [PO_Items]Qty_Ordered; \
				"currency"; [PO_Items]Currency; \
				"unitPrice"; [PO_Items]Unit_Price; \
				"shipJobNumber"; [PO_Items]ShipJobNumber; \
				"buildJobNumber"; [PO_Items]BuildJobNumber; \
				"unreleased"; [PO_Items]UnReleased; \
				"closed"; [PO_Items]Closed; \
				"seqNum"; [PO_Items]SeqNum\
				)
			
			$record.lineItems.push($lineItem)
			
			NEXT RECORD:C51([PO_Items])
		End while 
		
		$records.push($record)
		NEXT RECORD:C51([PO_LOG])
	End while 
	
	
	//TEXT TO DOCUMENT($myFolder.platformPath+"po_log_export.json"; JSON Stringify($records))
	vhDoc:=Create document:C266($myFolder.platformPath+"po_log_export.json")
	
	If (OK=1)
		SEND PACKET:C103(vhDoc; JSON Stringify:C1217($records))
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	//SHOW ON DISK($myFolder.platformPath+"po_log_export.json")
End if 

If (True:C214)  // export jobs & lot (job <-- lots)
	$records:=New collection:C1472()
	
	ALL RECORDS:C47([Receiver])
	
	While (Not:C34(End selection:C36([Receiver])))
		
		ARRAY LONGINT:C221(AInvItemNum; 0)
		ARRAY TEXT:C222(AInvPO_ItemPartNum; 0)
		ARRAY TEXT:C222(AInvPO_itemDesc; 0)
		ARRAY DATE:C224(AInvPO_itemOrderDate; 0)
		ARRAY LONGINT:C221(AInvPO_itemID; 0)
		ARRAY LONGINT:C221(AInvPO_itemQty; 0)
		ARRAY BOOLEAN:C223(AInvPO_itemTaxable; 0)
		ARRAY REAL:C219(AInvPO_UnitPrice; 0)
		ARRAY REAL:C219(AInvPO_itemTotal; 0)
		ARRAY REAL:C219(AInvPO_itemSalesTax; 0)
		
		If ([Receiver]Ship_Memo#"")
			TRACE:C157
		End if 
		$record:=New object:C1471(\
			"jobNumber"; [Receiver]ErpJobNumber; \
			"poNumber"; [Receiver]Purchase_Order; \
			"division"; [Receiver]Division; \
			"dateCreated"; [Receiver]DateCreated; \
			"expectedDate"; [Receiver]ExpectedJobCompletionDate; \
			"invoiceDate"; [Receiver]Invoice_date; \
			"lastShipDate"; [Receiver]Last_lot_ship_date; \
			"archivedDate"; !00-00-00!; \
			"deviceNumber"; [Receiver]Device_Number; \
			"process"; [Receiver]Process; \
			"salesTax"; [Receiver]Sales_Tax; \
			"totalCharge"; [Receiver]Total_Charge; \
			"shipped"; [Receiver]Shipped; \
			"lineItem"; [Receiver]Line_item; \
			"noLots"; [Receiver]NO_lots; \
			"postToPO"; [Receiver]Post_to_PO; \
			"parentJobNumber"; [Receiver]ParentJobNumber; \
			"blobSize"; BLOB size:C605([Receiver]POLineItems); \
			"alternateShipAddress"; [Receiver]AlternateAddress; \
			"shippers"; [Receiver]Shippers; \
			"customer"; [Receiver]Customer; \
			"qty"; [Receiver]Qty; \
			"qtyOnHand"; [Receiver]QtyOnHand; \
			"shipMemo"; [Receiver]Ship_Memo; \
			"jobComment"; [Receiver]Job_Comment; \
			"dropShipCustomer"; [Receiver]Drop_Ship_Customer; \
			"currency"; [Receiver]Currency; \
			"recommitDate"; [Receiver]RecommitDate; \
			"altDeviceNumber"; [Receiver]AltDevice_Number; \
			"customerShipper"; [Receiver]Customer_Shipper; \
			"initials"; [Receiver]Initials; \
			"miscCharges"; [Receiver]Misc_Charge; \
			"miscNote"; [Receiver]Misc_Description; \
			"glAcc"; [Receiver]GLAC; \
			"taxable"; [Receiver]Taxable; \
			"salesTaxRate"; [Receiver]SalesTax_Rate; \
			"freight"; [Receiver]JobFreight; \
			"unitPriceCode"; [Receiver]UnitPrice_Code; \
			"minimumJobCharge"; [Receiver]MinimumJobCharge; \
			"boxStockShipment"; [Receiver]BoxStockShipment; \
			"poRel"; [Receiver]PO_Rel; \
			"poBasedCharges"; [Receiver]POLinesTotal; \
			"travBasedCharges"; [Receiver]Step_Charge; \
			"pr_qualifier"; [Receiver]Pr_qualifier; \
			"packageType"; [Receiver]Pkg_Type; \
			"testerType"; [Receiver]TesterType; \
			"acNote"; [Receiver]AC_note; \
			"inventoryCost"; [Receiver]Inventory_Cost; \
			"directCost"; [Receiver]Direct_Cost; \
			"archived"; False:C215; \
			"address"; New object:C1471("addresses"; New collection:C1472()); \
			"poLines"; New collection:C1472(); \
			"lots"; New collection:C1472(); \
			"jobLineItems"; New collection:C1472(); \
			"jobPOLines"; New collection:C1472()\
			)
		
		$record.address.addresses.push(New object:C1471(\
			"type"; "billing"; \
			"detail"; New object:C1471("street_1"; [Receiver]Bill_add1; "street_2"; [Receiver]Bill_add2; "city"; [Receiver]Bill_addr_City; "state"; [Receiver]Bill_addr_ST; "postcode"; [Receiver]Bill_addr_ZIP; "country"; "US"; "iso_code_2"; "US")\
			))
		
		$record.address.addresses.push(New object:C1471(\
			"type"; "shipping"; \
			"detail"; New object:C1471("street_1"; [Receiver]Ship_add1; "street_2"; [Receiver]Ship_add2; "city"; [Receiver]Ship_addr_City; "state"; [Receiver]Ship_addr_ST; "postcode"; [Receiver]Ship_addr_ZIP; "country"; "US"; "iso_code_2"; "US")\
			))
		If ([Receiver]ErpJobNumber=11067)
			//TRACE
		End if 
		
		If (BLOB size:C605([Receiver]POLineItems)>0)
			GET_VAR_FROM_BLOB(->[Receiver]POLineItems; ->AInvItemNum; ->AInvPO_ItemPartNum; ->AInvPO_itemOrderDate; ->AInvPO_itemDesc; ->AInvPO_itemQty; ->AInvPO_UnitPrice; ->AInvPO_itemTaxable; ->AInvPO_itemTotal; ->AInvPO_itemID; ->AInvPO_itemSalesTax)
			
			If (Size of array:C274(AInvPO_itemID)>0)
				For ($i; 1; Size of array:C274(AInvPO_itemID))
					$record.poLines.push(New object:C1471(\
						"description"; AInvPO_itemDesc{$i}; \
						"seqNum"; AInvPO_itemID{$i}; \
						"taxable"; AInvPO_itemTaxable{$i}; \
						"saleTax"; AInvPO_itemSalesTax{$i}; \
						"total"; AInvPO_itemTotal{$i}\
						))
				End for 
			End if 
		End if 
		
		QUERY:C277([Lotinfo]; [Lotinfo]ErpJobNumber=[Receiver]ErpJobNumber)
		
		If ([Lotinfo]Lotnum#"206735")
			//TRACE
		End if 
		
		While (Not:C34(End selection:C36([Lotinfo])))
			
			$steps:=New collection:C1472()
			
			QUERY:C277([LotSteps]; [LotSteps]Lotnum=[Lotinfo]Lotnum)
			ORDER BY:C49([LotSteps]; [LotSteps]Seq_Number; >)
			
			While (Not:C34(End selection:C36([LotSteps])))
				$tools:=New object:C1471("items"; New collection:C1472([LotSteps]Tool1; [LotSteps]Tool2; [LotSteps]Tool3; [LotSteps]Tool4; [LotSteps]Tool5; [LotSteps]Tool6; [LotSteps]Tool7; [LotSteps]Tool8))
				$steps.push(New object:C1471(\
					"order"; $steps.length+1; \
					"description"; [LotSteps]StepDesc; \
					"lotSpecs"; [LotSteps]ControlSpec; \
					"specRevision"; [LotSteps]ControlSpec_Rev; \
					"alert"; [LotSteps]Step_Alert; \
					"qtyIn"; [LotSteps]QtyIn; \
					"qtyOut"; [LotSteps]QtyOut; \
					"dateIn"; [LotSteps]DateIn; \
					"dateOut"; [LotSteps]DateOut; \
					"timeIn"; [LotSteps]Timein; \
					"timeOut"; [LotSteps]TimeOut; \
					"rejects"; [LotSteps]Rejects; \
					"minYield"; [LotSteps]Step_Accyld; \
					"good"; [LotSteps]; \
					"discard"; [LotSteps]Discard; \
					"type"; [LotSteps]Step_Type; \
					"outOperator"; [LotSteps]Operator; \
					"inOperator"; [LotSteps]IN_Oper; \
					"actualHours"; [LotSteps]ActualHours; \
					"plannedHours"; [LotSteps]Planned_hrs; \
					"areas"; [LotSteps]Step_Area; \
					"tools"; $tools\
					))
				
				NEXT RECORD:C51([LotSteps])
			End while 
			
			//If ([Lotinfo]Lotnum#"206735")
			//TRACE
			//End if 
			
			$parentLotNumber:=""
			
			$lot_es:=ds:C1482.Lotinfo.query("ID = :1"; [Lotinfo]ParentID)
			
			If ($lot_es.length>0)
				$parentLotNumber:=$lot_es[0].Lotnum
			End if 
			
			$record.lots.push(New object:C1471(\
				"lotNum"; [Lotinfo]Lotnum; \
				"jobNum"; [Lotinfo]ErpJobNumber; \
				"customer"; [Lotinfo]Customer; \
				"poNumber"; [Lotinfo]PO_num; \
				"dateIn"; [Lotinfo]Datein; \
				"dateOut"; [Lotinfo]Dateout; \
				"process"; [Lotinfo]Process; \
				"device"; [Lotinfo]Device; \
				"altDevNumber"; [Lotinfo]AltDevNum; \
				"altLotNumber"; [Lotinfo]AltLotNumber; \
				"deviceTableLink"; [Lotinfo]LinkToDeviceTable; \
				"onHold"; [Lotinfo]Hold; \
				"holdDate"; [Lotinfo]Hold_date; \
				"holdTime"; [Lotinfo]Hold_time; \
				"commit"; [Lotinfo]ExpectedOutDate; \
				"reCommit"; [Lotinfo]Recommit_date; \
				"original"; [Lotinfo]Customercount; \
				"progressive"; [Lotinfo]Progress_count; \
				"ourCount"; [Lotinfo]Our_count; \
				"totalTested"; [Lotinfo]TotalTestedOrTotalPulls; \
				"az"; [Lotinfo]Pyield; \
				"et"; [Lotinfo]Yield; \
				"OQADone"; [Lotinfo]OQAdone; \
				"OQADate"; [Lotinfo]OQADate; \
				"OQASimpleSize"; [Lotinfo]OQASamplesize; \
				"releaseNumber"; 0; \
				"trackingNumber"; [Lotinfo]ShipTrackingNumber; \
				"readyToShipDate"; [Lotinfo]ReadyToShipdate; \
				"shippingMemo"; [Lotinfo]ShippingMemo; \
				"currentOrNextArea"; [Lotinfo]CurrentOrNextArea; \
				"location"; [Lotinfo]Location; \
				"comment"; [Lotinfo]Lot_comment; \
				"status"; [Lotinfo]TravelerApprovalStatus; \
				"prQualifier"; [Lotinfo]Pr_qualifier; \
				"ID"; [Lotinfo]ID; \
				"parentID"; [Lotinfo]ParentID; \
				"parentLotNumber"; $parentLotNumber; \
				"packageType"; [Lotinfo]PackageType1; \
				"cOfCInspector"; [Lotinfo]CofCInspector; \
				"dateCode"; [Lotinfo]Datecode; \
				"shipRel"; [Lotinfo]ShipRel; \
				"carrier"; [Lotinfo]Carrier; \
				"totalCharge"; [Lotinfo]TotalCharge; \
				"unitCost"; [Lotinfo]UnitCost; \
				"steps"; $steps\
				))
			
			NEXT RECORD:C51([Lotinfo])
		End while 
		
		
		QUERY:C277([Receiver_LotsSubT]; [Receiver_LotsSubT]OneID=[Receiver]UniqueID)
		
		While (Not:C34(End selection:C36([Receiver_LotsSubT])))
			
			$record.jobLineItems.push(New object:C1471(\
				"itemNumber"; [Receiver_LotsSubT]Item_num; \
				"description"; [Receiver_LotsSubT]Charge_Description; \
				"quantity"; [Receiver_LotsSubT]OUR_Count; \
				"unitPrice"; [Receiver_LotsSubT]Charge; \
				"taxable"; [Receiver_LotsSubT]SpecialCharges; \
				"lineTotal"; [Receiver_LotsSubT]Line_item_total; \
				"salesTax"; [Receiver_LotsSubT]ItemSalesTax; \
				"hourCount"; [Receiver_LotsSubT]TBhours\
				))
			
			NEXT RECORD:C51([Receiver_LotsSubT])
		End while 
		
		
		
		//QUERY([PO_Items]; [PO_Items]ShipJobNumber=[Receiver]ErpJobNumber)
		
		//While (Not(End selection([PO_Items])))
		//If ([PO_Items]Part_Num#"")
		//TRACE
		//End if 
		//If (Records in selection([PO_Items])>1)
		
		//End if 
		
		//$jobPOLines:=New object(\
			"itemNum"; [PO_Items]Item_num; \
			"description"; [PO_Items]Item_Desc; \
			"partNum"; [PO_Items]Part_Num; \
			"dateOrdered"; [PO_Items]Date_Ordered; \
			"customerRequestedDate"; [PO_Items]CustomerRequestedDate; \
			"qtyOrdered"; [PO_Items]Qty_Ordered; \
			"currency"; [PO_Items]Currency; \
			"unitPrice"; [PO_Items]Unit_Price; \
			"shipJobNumber"; [PO_Items]ShipJobNumber; \
			"buildJobNumber"; [PO_Items]BuildJobNumber; \
			"unreleased"; [PO_Items]UnReleased; \
			"closed"; [PO_Items]Closed; \
			"seqNum"; [PO_Items]SeqNum\
			)
		
		//$record.jobPOLines.push($jobPOLines)
		
		//NEXT RECORD([PO_Items])
		//End while 
		
		
		$records.push($record)
		NEXT RECORD:C51([Receiver])
	End while 
	
	//TEXT TO DOCUMENT($myFolder.platformPath+"job_log_export.json"; JSON Stringify($records))
	vhDoc:=Create document:C266($myFolder.platformPath+"job_log_export.json")
	
	If (OK=1)
		SEND PACKET:C103(vhDoc; JSON Stringify:C1217($records))
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	
	//SHOW ON DISK($myFolder.platformPath+"job_log_export.json")
End if 

If (True:C214)  //export Inventory
	$records:=New collection:C1472()
	
	ALL RECORDS:C47([Inventory:126])
	
	While (Not:C34(End selection:C36([Inventory:126])))
		$record:=New object:C1471(\
			"customerSpecific"; [Inventory:126]customerSpecific:3; \
			"stockNum"; [Inventory]Stock_Num; \
			"partNum"; [Inventory]Part_Number; \
			"vendor"; [Inventory:126]vendor:5; \
			"description"; [Inventory:126]description:6; \
			"classification"; [Inventory:126]classification:7; \
			"lotNumber"; [Inventory]LotNumber; \
			"stockNum"; [Inventory]Stock_Num; \
			"dateIn"; [Inventory]Date_in; \
			"expirationDate"; [Inventory]Expiration_Date; \
			"qtyInStock"; [Inventory]Qty_in_Stock; \
			"unitCost"; [Inventory]Unit_Cost; \
			"units"; [Inventory:126]units:28; \
			"currency"; [Inventory:126]currency:16; \
			"binLocation"; [Inventory]Bin_Location; \
			"recdBy"; [Inventory]Recd_by; \
			"division"; [Inventory:126]division:23; \
			"totalCost"; [Inventory]Current_Actual_Value; \
			"property"; [Inventory]Property; \
			"pulls"; New collection:C1472()\
			)
		
		
		QUERY:C277([Inv_Usage_Many]; [Inv_Usage_Many]Stock_num=[Inventory]Stock_Num)
		
		While (Not:C34(End selection:C36([Inv_Usage_Many])))
			$record.pulls.push(New object:C1471(\
				"partNum"; [Inv_Usage_Many]Part_num; \
				"qty"; [Inv_Usage_Many]Qty; \
				"cost"; [Inv_Usage_Many]Cost; \
				"datePulled"; [Inv_Usage_Many]Date_pulled; \
				"jobNumber"; [Inv_Usage_Many]ErpJobNumber; \
				"uniqueID"; [Inv_Usage_Many]UniqueID; \
				"pulledBy"; [Inv_Usage_Many]Pulled_by; \
				"division"; [Inv_Usage_Many]Division; \
				"docsInDocServer"; [Inv_Usage_Many]DocumentsinDocServer; \
				"currency"; [Inv_Usage_Many]Currency; \
				"units"; [Inv_Usage_Many]Units; \
				"pullMode"; [Inv_Usage_Many]PullMode; \
				"lotNumber"; [Inv_Usage_Many]LotNumber; \
				"property"; [Inv_Usage_Many]property ; \
				"jobInvoiceDate"; [Inv_Usage_Many]JobInvoiceDate\
				))
			
			NEXT RECORD:C51([Inv_Usage_Many])
		End while 
		
		
		$records.push($record)
		NEXT RECORD:C51([Inventory:126])
	End while 
	
	//TEXT TO DOCUMENT($myFolder.platformPath+"inventory_export.json"; JSON Stringify($records))
	vhDoc:=Create document:C266($myFolder.platformPath+"inventory_export.json")
	
	If (OK=1)
		SEND PACKET:C103(vhDoc; JSON Stringify:C1217($records))
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	//SHOW ON DISK($myFolder.platformPath+"inventory_export.json")
End if 

If (True:C214)  // export stepTemplates
	ALL RECORDS:C47([Template_definitions])
	
	$records:=New collection:C1472()
	
	While (Not:C34(End selection:C36([Template_definitions])))
		$record:=New object:C1471(\
			"name"; [Template_definitions]Name; \
			"operation"; [Template_definitions]Operation; \
			"division"; [Template_definitions]Division; \
			"status"; False:C215; \
			"binning"; [Template_definitions]IsBinningRequired; \
			"smallLayout"; [Template_definitions]S_layout; \
			"largeLayout"; [Template_definitions]L_layout; \
			"comment1"; [Template_definitions]Comment1Fmt; \
			"comment2"; [Template_definitions]Comment2Fmt; \
			"templateNumber"; [Template_definitions]Template_num; \
			"settings"; 0; \
			"areas"; ""; \
			"steps"; New collection:C1472()\
			)
		
		QUERY:C277([StepTemplates]; [StepTemplates]Template=[Template_definitions]Template_num)
		
		If (Records in selection:C76([StepTemplates])>0)
			$record.settings:=[StepTemplates]StepProperty
			$record.areas:=[StepTemplates]Area
		End if 
		
		
		$records.push($record)
		NEXT RECORD:C51([Template_definitions])
	End while 
	
	//TEXT TO DOCUMENT($myFolder.platformPath+"step_template_export.json"; JSON Stringify($records))
	vhDoc:=Create document:C266($myFolder.platformPath+"step_template_export.json")
	
	If (OK=1)
		SEND PACKET:C103(vhDoc; JSON Stringify:C1217($records))
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	//SHOW ON DISK($myFolder.platformPath+"step_template_export.json")
End if 

If (True:C214)  // export tools
	QUERY:C277([Save_lists]; [Save_lists]List_name="z@")
	
	$records:=New collection:C1472()
	
	While (Not:C34(End selection:C36([Save_lists])))
		$record:=New object:C1471(\
			"name"; [Save_lists]Description; \
			"date"; Date:C102(GetDateTimeValueCompact([Save_lists]DateTimeStamp; "DateOnly")); \
			"type"; [Save_lists]ListType; \
			"tools"; New collection:C1472()\
			)
		
		$listRef:=BLOB to list:C557([Save_lists]l_blob)
		
		
		For ($i; 1; Count list items:C380($listRef))
			GET LIST ITEM:C378($listRef; $i; $itemRef; $itemText)
			
			$record.tools.push($itemText)
		End for 
		
		If ($record.tools.length>0)
			$records.push($record)
		End if 
		NEXT RECORD:C51([Save_lists])
	End while 
	
	//TEXT TO DOCUMENT($myFolder.platformPath+"tools_export.json"; JSON Stringify($records))
	vhDoc:=Create document:C266($myFolder.platformPath+"tools_export.json")
	
	If (OK=1)
		SEND PACKET:C103(vhDoc; JSON Stringify:C1217($records))
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	//SHOW ON DISK($myFolder.platformPath+"tools_export.json")
End if 

If (True:C214)  // export certifications
	$listRef:=Load list:C383("Certification list")
	
	$records:=New collection:C1472()
	
	For ($i; 1; Count list items:C380($listRef))
		GET LIST ITEM:C378($listRef; $i; $itemRef; $itemText)
		
		If ($itemText#"Cert@")
			$records.push(New object:C1471(\
				"ref"; $itemRef; \
				"name"; $itemText\
				))
		End if 
	End for 
	
	//TEXT TO DOCUMENT($myFolder.platformPath+"certifications_export.json"; JSON Stringify($records))
	vhDoc:=Create document:C266($myFolder.platformPath+"certifications_export.json")
	
	If (OK=1)
		SEND PACKET:C103(vhDoc; JSON Stringify:C1217($records))
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	//SHOW ON DISK($myFolder.platformPath+"certifications_export.json")
End if 

If (True:C214)  // export employees
	ALL RECORDS:C47([Employees])
	
	$records:=New collection:C1472()
	
	While (Not:C34(End selection:C36([Employees])))
		$contactDetails:=New object:C1471(\
			"addresses"; New collection:C1472(); \
			"communications"; New collection:C1472()\
			)
		
		If ([Employees]Telephone#"")
			$contactDetails.communications.push(New object:C1471(\
				"type"; "phone"; \
				"comment"; Substring:C12([Employees]Telephone; 13); \
				"contact"; Substring:C12([Employees]Telephone; 1; 12)\
				))
		End if 
		
		If ([Employees]Mobile#"")
			$contactDetails.communications.push(New object:C1471(\
				"type"; "mobile"; \
				"comment"; ""; \
				"contact"; [Employees]Mobile\
				))
		End if 
		
		If ([Employees]Fax#"")
			$contactDetails.communications.push(New object:C1471(\
				"type"; "fax"; \
				"comment"; ""; \
				"contact"; [Employees]Fax\
				))
		End if 
		
		If ([Employees]EmailAddress#"")
			$contactDetails.communications.push(New object:C1471(\
				"type"; "mail"; \
				"comment"; ""; \
				"contact"; [Employees]EmailAddress\
				))
		End if 
		
		$record:=New object:C1471(\
			"firstName"; [Employees]First_Name; \
			"lastName"; [Employees]Last_Name; \
			"retrainDate"; [Employees]Retrain_Date; \
			"terminationDate"; [Employees]Termination_Date; \
			"creationDate"; [Employees]CreationDateTimeStamp; \
			"code"; [Employees]Employee_Code; \
			"department"; [Employees]Department; \
			"terminated"; [Employees]Emp_Terminated; \
			"hireDate"; [Employees]Hire_Date; \
			"division"; [Employees]Division; \
			"password"; [Employees]Password; \
			"citizenShipStatus"; [Employees]CiitizenShipStatus; \
			"skillCodes"; [Employees]SkillCodeText; \
			"contactDetails"; $contactDetails; \
			"teamMemberShip"; New object:C1471()\
			)
		
		For ($i; 1; 31)
			$record.teamMemberShip[String:C10($i)]:=False:C215
			
			If (([Employees]TeamMemberShipCode & (2^($i-1)))=(2^($i-1)))
				$record.teamMemberShip[String:C10($i)]:=True:C214
			End if 
		End for 
		
		$records.push($record)
		
		NEXT RECORD:C51([Employees])
	End while 
	
	//TEXT TO DOCUMENT($myFolder.platformPath+"staff_export.json"; JSON Stringify($records))
	vhDoc:=Create document:C266($myFolder.platformPath+"staff_export.json")
	
	If (OK=1)
		SEND PACKET:C103(vhDoc; JSON Stringify:C1217($records))
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	//SHOW ON DISK($myFolder.platformPath+"staff_export.json")
End if 

If (True:C214)  // export qcars
	ALL RECORDS:C47([QCARS])
	
	$records:=New collection:C1472()
	
	While (Not:C34(End selection:C36([QCARS])))
		$record:=New object:C1471(\
			"customer"; [QCARS]Customer; \
			"lotNumber"; [QCARS]Lotnum; \
			"qcarNumber"; [QCARS]QcarNumber; \
			"device"; [QCARS]Device; \
			"closedDate"; [QCARS]Date_closed; \
			"targetCloseDate"; [QCARS]CA_reqd_date; \
			"actualCloseDate"; [QCARS]Date_closed; \
			"verifiedBy"; [QCARS]Verify_by; \
			"verifiedDate"; [QCARS]Verify_date; \
			"void"; [QCARS]Void; \
			"submit"; [QCARS]Submit; \
			"submitDate"; [QCARS]Submit_date; \
			"category"; [QCARS]Category; \
			"issuedBy"; [QCARS]Issued_by; \
			"issuedTo"; [QCARS]Issued_to; \
			"issuedDate"; [QCARS]Date_Issued; \
			"d2"; WP Get text:C1575(([QCARS]WPDesc_#Null:C1517) ? [QCARS]WPDesc_ : WP New:C1317()); \
			"d3"; WP Get text:C1575(([QCARS]WPShortTermContPlan_#Null:C1517) ? [QCARS]WPShortTermContPlan_ : WP New:C1317()); \
			"d4"; WP Get text:C1575(([QCARS]WPRootCause_#Null:C1517) ? [QCARS]WPRootCause_ : WP New:C1317()); \
			"d5"; WP Get text:C1575(([QCARS]WPCA_#Null:C1517) ? [QCARS]WPCA_ : WP New:C1317()); \
			"d6"; WP Get text:C1575(([QCARS]WPPermCAandPrevention_#Null:C1517) ? [QCARS]WPPermCAandPrevention_ : WP New:C1317())\
			)
		
		$records.push($record)
		
		NEXT RECORD:C51([QCARS])
	End while 
	
	//TEXT TO DOCUMENT($myFolder.platformPath+"qcar_export.json"; JSON Stringify($records))
	vhDoc:=Create document:C266($myFolder.platformPath+"qcar_export.json")
	
	If (OK=1)
		SEND PACKET:C103(vhDoc; JSON Stringify:C1217($records))
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	
	//SHOW ON DISK($myFolder.platformPath+"qcar_export.json")
End if 

If (True:C214)  // export byt_orders
	
	ALL RECORDS:C47([BUY_ORDERS])
	
	$records:=New collection:C1472()
	
	QUERY:C277([Formats]; [Formats]Name="BuyOrderTerms")
	$terms:=[Formats]ContentsWP_
	
	QUERY:C277([Formats]; [Formats]Name="BuyOrderTerms_CriticalMaterials")
	$termsCriticalMaterials:=[Formats]ContentsWP_
	
	QUERY:C277([Formats]; [Formats]Name="BuyOrderTerms_CriticalService")
	$termsCriticalService:=[Formats]ContentsWP_
	
	WP EXPORT DOCUMENT:C1337($terms; "terms")
	WP EXPORT DOCUMENT:C1337($termsCriticalMaterials; "termsCriticalMaterials")
	WP EXPORT DOCUMENT:C1337($termsCriticalService; "termsCriticalService")
	
	
	
	While (Not:C34(End selection:C36([BUY_ORDERS])))
		$record:=New object:C1471(\
			"boNumber"; [BUY_ORDERS]SEQ_NUM; \
			"orderDate"; [BUY_ORDERS]ISSUE_DATE; \
			"buyer"; [BUY_ORDERS]Buyer; \
			"buyerCode"; [BUY_ORDERS]BuyersCode; \
			"buyOrderLimit"; [BUY_ORDERS]BO_limit; \
			"accountNumber"; [BUY_ORDERS]GLAC; \
			"salesTaxRate"; [BUY_ORDERS]ST_rate; \
			"currency"; [BUY_ORDERS]Currency; \
			"discount"; [BUY_ORDERS]Discount; \
			"discountDays"; [BUY_ORDERS]DDAYS; \
			"netDays"; [BUY_ORDERS]NetDays; \
			"shippingAddress"; [BUY_ORDERS]ShippingAddr; \
			"fob"; [BUY_ORDERS]FOB; \
			"shipVia"; [BUY_ORDERS]ShipVia; \
			"division"; [BUY_ORDERS]Division; \
			"requestedBy"; [BUY_ORDERS]Requestor; \
			"salesTax"; [BUY_ORDERS]T_salestax; \
			"lineItemsTotal"; [BUY_ORDERS]T_Amt; \
			"approver1"; [BUY_ORDERS]Approver1; \
			"approver2"; [BUY_ORDERS]Approver2; \
			"signature1"; [BUY_ORDERS]Signature1; \
			"signature2"; [BUY_ORDERS]Signature2; \
			"terms"; $terms; \
			"termsCriticalMaterials"; $termsCriticalMaterials; \
			"termsCriticalService"; $termsCriticalService; \
			"lines"; New collection:C1472()\
			)
		
		QUERY:C277([BUY_ITEMS]; [BUY_ITEMS]PO_NUM=[BUY_ORDERS]SEQ_NUM)
		
		
		While (Not:C34(End selection:C36([BUY_ITEMS])))
			$record.lines.push(New object:C1471(\
				"order"; [BUY_ITEMS]Item; \
				"description"; [BUY_ITEMS]Description; \
				"qty"; [BUY_ITEMS]QTY; \
				"unitPrice"; [BUY_ITEMS]Unit_Price; \
				"lineTotal"; [BUY_ITEMS]Line_total; \
				"glAccount"; [BUY_ITEMS]Glac; \
				"orderDate"; [BUY_ITEMS]Order_Date; \
				"requiredDate"; [BUY_ITEMS]Date_required; \
				"dateIn"; [BUY_ITEMS]Date_in; \
				"checkNumber"; [BUY_ITEMS]Check_num; \
				"paidDate"; [BUY_ITEMS]Paid_date; \
				"amountPaid"; [BUY_ITEMS]T_paid; \
				"jobNumber"; [BUY_ITEMS]Int_jobnum; \
				"assetListNumber"; [BUY_ITEMS]Assetlist_num; \
				"supPsNumber"; [BUY_ITEMS]Sup_ps_num\
				))
			
			NEXT RECORD:C51([BUY_ITEMS])
		End while 
		
		
		$records.push($record)
		
		NEXT RECORD:C51([BUY_ORDERS])
	End while 
	
	//TEXT TO DOCUMENT($myFolder.platformPath+"buyOrders_export.json"; JSON Stringify($records))
	vhDoc:=Create document:C266($myFolder.platformPath+"buyOrders_export.json")
	
	If (OK=1)
		SEND PACKET:C103(vhDoc; JSON Stringify:C1217($records))
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	//SHOW ON DISK($myFolder.platformPath+"buyOrders_export.json")
End if 

If (True:C214)  // export archived jobs & lot (job <-- lots)
	$records:=New collection:C1472()
	
	ALL RECORDS:C47([ARCHIVES])
	
	While (Not:C34(End selection:C36([ARCHIVES])))
		
		ARRAY LONGINT:C221(AInvItemNum; 0)
		ARRAY TEXT:C222(AInvPO_ItemPartNum; 0)
		ARRAY TEXT:C222(AInvPO_itemDesc; 0)
		ARRAY DATE:C224(AInvPO_itemOrderDate; 0)
		ARRAY LONGINT:C221(AInvPO_itemID; 0)
		ARRAY LONGINT:C221(AInvPO_itemQty; 0)
		ARRAY BOOLEAN:C223(AInvPO_itemTaxable; 0)
		ARRAY REAL:C219(AInvPO_UnitPrice; 0)
		ARRAY REAL:C219(AInvPO_itemTotal; 0)
		ARRAY REAL:C219(AInvPO_itemSalesTax; 0)
		
		If ([ARCHIVES]Ship_Memo#"")
			//TRACE
		End if 
		$record:=New object:C1471(\
			"pr_qualifier"; [ARCHIVES]Pr_qualifier; \
			"jobNumber"; [ARCHIVES]ErpJobNumber; \
			"poNumber"; [ARCHIVES]Purchase_Order; \
			"division"; [ARCHIVES]Division; \
			"dateCreated"; [ARCHIVES]Datein; \
			"expectedDate"; !00-00-00!; \
			"invoiceDate"; [ARCHIVES]Invoice_Date; \
			"lastShipDate"; [ARCHIVES]Last_lot_ship_date; \
			"archivedDate"; [ARCHIVES]Archive_Date; \
			"deviceNumber"; [ARCHIVES]Device_Number; \
			"process"; [ARCHIVES]Process; \
			"salesTax"; [ARCHIVES]Sales_Tax; \
			"totalCharge"; [ARCHIVES]Total_Charge; \
			"shipped"; [ARCHIVES]Shipped; \
			"lineItem"; [ARCHIVES]line_item; \
			"noLots"; [ARCHIVES]No_Lots; \
			"postToPO"; True:C214; \
			"parentJobNumber"; [ARCHIVES]ParentJobNumber; \
			"blobSize"; BLOB size:C605([ARCHIVES]POLineItems); \
			"alternateShipAddress"; [ARCHIVES]AlternateAddress; \
			"shippers"; [ARCHIVES]Shippers; \
			"customer"; [ARCHIVES]Customer; \
			"qty"; [ARCHIVES]Qty; \
			"qtyOnHand"; 0; \
			"shipMemo"; [ARCHIVES]Ship_Memo; \
			"jobComment"; [ARCHIVES]MEMO; \
			"currency"; [ARCHIVES]Currency; \
			"dropShipCustomer"; [ARCHIVES]Drop_Ship_Customer; \
			"recommitDate"; !00-00-00!; \
			"altDeviceNumber"; [ARCHIVES]AltDevice_Number; \
			"customerShipper"; [ARCHIVES]Customer_Shipper; \
			"initials"; [ARCHIVES]Initials; \
			"miscCharges"; [ARCHIVES]Misc_Charge; \
			"miscNote"; [ARCHIVES]Misc_Description; \
			"glAcc"; [ARCHIVES]GLAC; \
			"taxable"; [ARCHIVES]Taxable; \
			"salesTaxRate"; [ARCHIVES]SalesTax_Rate; \
			"freight"; [ARCHIVES]Freight; \
			"unitPriceCode"; [ARCHIVES]Unitprice_Code; \
			"minimumJobCharge"; ""; \
			"boxStockShipment"; [ARCHIVES]BoxStockShipment; \
			"poRel"; [ARCHIVES]PO_Rel; \
			"poBasedCharges"; [ARCHIVES]POLinesTotal; \
			"travBasedCharges"; [ARCHIVES]Step_Charge; \
			"packageType"; [ARCHIVES]Pkg_Type; \
			"testerType"; [ARCHIVES]TesterType; \
			"acNote"; [ARCHIVES]AC_note; \
			"inventoryCost"; [ARCHIVES]Inventory_Cost; \
			"directCost"; [ARCHIVES]Direct_Cost; \
			"archived"; False:C215; \
			"archived"; True:C214; \
			"address"; New object:C1471(\
			"addresses"; New collection:C1472(\
			New object:C1471(\
			"type"; "billing"; \
			"detail"; New object:C1471("street"; ""; "additionalAddress"; ""; "city"; [ARCHIVES]Bill_addr_City; "state"; [ARCHIVES]Bill_addr_ST; "zipCode"; [ARCHIVES]Bill_addr_ZIP; \
			"country"; [ARCHIVES]BillAddrCountry)\
			); \
			New object:C1471(\
			"type"; "shipping"; \
			"detail"; New object:C1471("street"; [ARCHIVES]Ship_add1; "additionalAddress"; [ARCHIVES]Ship_add2; "city"; [ARCHIVES]Ship_addr_City; "state"; [ARCHIVES]Ship_addr_ST; \
			"zipCode"; [ARCHIVES]Ship_addr_ZIP; "country"; [ARCHIVES]ShipAddrCountry)\
			)\
			)); \
			"poLines"; New collection:C1472(); \
			"lots"; New collection:C1472()\
			)
		
		
		If (BLOB size:C605([ARCHIVES]POLineItems)>0)
			GET_VAR_FROM_BLOB(->[ARCHIVES]POLineItems; ->AInvItemNum; ->AInvPO_ItemPartNum; ->AInvPO_itemOrderDate; ->AInvPO_itemDesc; ->AInvPO_itemQty; ->AInvPO_UnitPrice; ->AInvPO_itemTaxable; ->AInvPO_itemTotal; ->AInvPO_itemID; ->AInvPO_itemSalesTax)
			
			If (Size of array:C274(AInvPO_itemID)>0)
				For ($i; 1; Size of array:C274(AInvPO_itemID))
					
					//If (Size of array(AInvPO_itemDesc)<$i)
					//INSERT IN ARRAY(AInvPO_itemDesc; $i)
					//End if 
					
					$record.poLines.push(New object:C1471(\
						"description"; AInvPO_itemDesc{$i}; \
						"seqNum"; AInvPO_itemID{$i}; \
						"taxable"; AInvPO_itemTaxable{$i}; \
						"saleTax"; AInvPO_itemSalesTax{$i}; \
						"total"; AInvPO_itemTotal{$i}\
						))
				End for 
			End if 
		End if 
		
		QUERY:C277([Lotinfo]; [Lotinfo]ErpJobNumber=[ARCHIVES]ErpJobNumber)
		
		If ([Lotinfo]Lotnum#"206735")
			//TRACE
		End if 
		
		While (Not:C34(End selection:C36([Lotinfo])))
			
			$steps:=New collection:C1472()
			
			QUERY:C277([LotSteps]; [LotSteps]Lotnum=[Lotinfo]Lotnum)
			ORDER BY:C49([LotSteps]; [LotSteps]Seq_Number; >)
			
			While (Not:C34(End selection:C36([LotSteps])))
				$tools:=New object:C1471("items"; New collection:C1472([LotSteps]Tool1; [LotSteps]Tool2; [LotSteps]Tool3; [LotSteps]Tool4; [LotSteps]Tool5; [LotSteps]Tool6; [LotSteps]Tool7; [LotSteps]Tool8))
				$steps.push(New object:C1471(\
					"order"; $steps.length+1; \
					"description"; [LotSteps]StepDesc; \
					"lotSpecs"; [LotSteps]ControlSpec; \
					"specRevision"; [LotSteps]ControlSpec_Rev; \
					"alert"; [LotSteps]Step_Alert; \
					"qtyIn"; [LotSteps]QtyIn; \
					"qtyOut"; [LotSteps]QtyOut; \
					"dateIn"; [LotSteps]DateIn; \
					"dateOut"; [LotSteps]DateOut; \
					"timeIn"; [LotSteps]Timein; \
					"timeOut"; [LotSteps]TimeOut; \
					"rejects"; [LotSteps]Rejects; \
					"good"; [LotSteps]; \
					"discard"; [LotSteps]Discard; \
					"type"; [LotSteps]Step_Type; \
					"outOperator"; [LotSteps]Operator; \
					"inOperator"; [LotSteps]IN_Oper; \
					"actualHours"; [LotSteps]ActualHours; \
					"plannedHours"; [LotSteps]Planned_hrs; \
					"areas"; [LotSteps]Step_Area; \
					"tools"; $tools\
					))
				
				NEXT RECORD:C51([LotSteps])
			End while 
			
			//If ([Lotinfo]Lotnum#"206735")
			//TRACE
			//End if 
			
			$record.lots.push(New object:C1471(\
				"lotNum"; [Lotinfo]Lotnum; \
				"jobNum"; [Lotinfo]ErpJobNumber; \
				"customer"; [Lotinfo]Customer; \
				"poNumber"; [Lotinfo]PO_num; \
				"dateIn"; [Lotinfo]Datein; \
				"dateOut"; [Lotinfo]Dateout; \
				"process"; [Lotinfo]Process; \
				"device"; [Lotinfo]Device; \
				"altDevNumber"; [Lotinfo]AltDevNum; \
				"altLotNumber"; [Lotinfo]AltLotNumber; \
				"deviceTableLink"; [Lotinfo]LinkToDeviceTable; \
				"onHold"; [Lotinfo]Hold; \
				"holdDate"; [Lotinfo]Hold_date; \
				"holdTime"; [Lotinfo]Hold_time; \
				"commit"; [Lotinfo]ExpectedOutDate; \
				"reCommit"; [Lotinfo]Recommit_date; \
				"original"; [Lotinfo]Customercount; \
				"progressive"; [Lotinfo]Progress_count; \
				"ourCount"; [Lotinfo]Our_count; \
				"totalTested"; [Lotinfo]TotalTestedOrTotalPulls; \
				"az"; [Lotinfo]Pyield; \
				"et"; [Lotinfo]Yield; \
				"OQADone"; [Lotinfo]OQAdone; \
				"OQADate"; [Lotinfo]OQADate; \
				"OQASimpleSize"; [Lotinfo]OQASamplesize; \
				"releaseNumber"; 0; \
				"trackingNumber"; [Lotinfo]ShipTrackingNumber; \
				"readyToShipDate"; [Lotinfo]ReadyToShipdate; \
				"shippingMemo"; [Lotinfo]ShippingMemo; \
				"currentOrNextArea"; [Lotinfo]CurrentOrNextArea; \
				"location"; [Lotinfo]Location; \
				"comment"; [Lotinfo]Lot_comment; \
				"status"; [Lotinfo]TravelerApprovalStatus; \
				"prQualifier"; [Lotinfo]Pr_qualifier; \
				"ID"; [Lotinfo]ID; \
				"parentID"; [Lotinfo]ParentID; \
				"parentLotNumber"; $parentLotNumber; \
				"packageType"; [Lotinfo]PackageType1; \
				"cOfCInspector"; [Lotinfo]CofCInspector; \
				"dateCode"; [Lotinfo]Datecode; \
				"shipRel"; [Lotinfo]ShipRel; \
				"carrier"; [Lotinfo]Carrier; \
				"totalCharge"; [Lotinfo]TotalCharge; \
				"unitCost"; [Lotinfo]UnitCost; \
				"steps"; $steps\
				))
			
			NEXT RECORD:C51([Lotinfo])
		End while 
		
		
		
		$records.push($record)
		NEXT RECORD:C51([ARCHIVES])
	End while 
	
	//TEXT TO DOCUMENT($myFolder.platformPath+"archived_jobs_export.json"; JSON Stringify($records))
	vhDoc:=Create document:C266($myFolder.platformPath+"archived_jobs_export.json")
	
	If (OK=1)
		SEND PACKET:C103(vhDoc; JSON Stringify:C1217($records))
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	//SHOW ON DISK($myFolder.platformPath+"archived_jobs_export.json")
End if 

If (True:C214)  // export Repair_Log
	
	ALL RECORDS:C47([Repair_Log])
	$jsonString:=Selection to JSON:C1234([Repair_Log])
	
	vhDoc:=Create document:C266($myFolder.platformPath+"repair_log_export.json")
	If (OK=1)
		SEND PACKET:C103(vhDoc; $jsonString)
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
End if 

If (True:C214)  // export Equipments
	
	ALL RECORDS:C47([ATE])
	$jsonString:=Selection to JSON:C1234([ATE])
	
	vhDoc:=Create document:C266($myFolder.platformPath+"equipment_export.json")
	If (OK=1)
		SEND PACKET:C103(vhDoc; $jsonString)
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	
End if 

If (True:C214)  // export DocServerIndex
	
	ALL RECORDS:C47([DocServerIndex])
	$jsonString:=Selection to JSON:C1234([DocServerIndex])
	
	vhDoc:=Create document:C266($myFolder.platformPath+"docServerIndex_export.json")
	If (OK=1)
		SEND PACKET:C103(vhDoc; $jsonString)
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	
End if 

If (True:C214)  // export Equipments Documents
	
	QUERY:C277([DocServerIndex]; [DocServerIndex]TableNumber=10)
	
	FIRST RECORD:C50([DocServerIndex])
	For ($i; 0; Records in selection:C76([DocServerIndex]))
		
		If ($i=5587) | ($i=4576) | ($i=3521) | ($i=1478) | ($i=131)
			
			DELAY PROCESS:C323(Current process:C322; 5)
			
			$path:=Get external data path:C1133([DocServerIndex]DocBlob)
			FLUSH CACHE:C297(*)
			
			If (String:C10([DocServerIndex]UniqueID+[DocServerIndex]PrimaryKeyValue)#"")
				
				$file:=File:C1566(Convert path system to POSIX:C1106($myFolder.platformPath+"EquipmentReports/"+String:C10([DocServerIndex]UniqueID+[DocServerIndex]PrimaryKeyValue)))
				
				If (Not:C34($file.exists))
					
					$file.create()
				End if 
				
				BLOB TO DOCUMENT:C526($file.platformPath; [DocServerIndex]DocBlob)
				
			End if 
			
		End if 
		
		NEXT RECORD:C51([DocServerIndex])
		
	End for 
End if 

If (True:C214)  // export Spec_control
	
	ALL RECORDS:C47([Spec_Control])
	$jsonString:=Selection to JSON:C1234([Spec_Control])
	
	vhDoc:=Create document:C266($myFolder.platformPath+"specification_export.json")
	If (OK=1)
		SEND PACKET:C103(vhDoc; $jsonString)
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	
End if 

If (True:C214)  // export PartData
	
	ALL RECORDS:C47([PartData:58])
	$jsonString:=Selection to JSON:C1234([PartData:58])
	
	vhDoc:=Create document:C266($myFolder.platformPath+"partData_export.json")
	If (OK=1)
		SEND PACKET:C103(vhDoc; $jsonString)
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	
End if 

If (True:C214)  // export Suppliers
	
	ALL RECORDS:C47([Suppliers])
	$jsonString:=Selection to JSON:C1234([Suppliers])
	
	vhDoc:=Create document:C266($myFolder.platformPath+"suppliers_export.json")
	If (OK=1)
		SEND PACKET:C103(vhDoc; $jsonString)
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	
End if 

If (True:C214)  // export AML
	
	ALL RECORDS:C47([AVL_Supplies])
	$jsonString:=Selection to JSON:C1234([AVL_Supplies])
	
	vhDoc:=Create document:C266($myFolder.platformPath+"aml_export.json")
	If (OK=1)
		SEND PACKET:C103(vhDoc; $jsonString)
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	
End if 

If (True:C214)  //export  ManagementReview & Audit
	
	ALL RECORDS:C47([Log_Book])
	$jsonString:=Selection to JSON:C1234([Log_Book])
	
	vhDoc:=Create document:C266($myFolder.platformPath+"log_book_export.json")
	If (OK=1)
		SEND PACKET:C103(vhDoc; $jsonString)
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	
End if 

If (True:C214)  //export Pictures from [Pict] table
	
	ALL RECORDS:C47([Picts])
	
	For ($i; 0; Records in selection:C76([Picts]))
		
		$file:=File:C1566(Convert path system to POSIX:C1106($myFolder.platformPath+"PictsTable/"+String:C10([Picts]Pic_Name)+".png"))
		If (Not:C34($file.exists))
			
			$file.create()
		End if 
		$picture:=[Picts]Picture4d_
		CONVERT PICTURE:C1002($picture; "png")
		WRITE PICTURE FILE:C680($file.platformPath; $picture)
		
		NEXT RECORD:C51([Picts])
		
	End for 
End if 

If (True:C214)  //export LogBook(audit and managementReview) documents
	
	QUERY:C277([DocServerIndex]; [DocServerIndex]TableNumber=39)
	
	FIRST RECORD:C50([DocServerIndex])
	For ($i; 1; Records in selection:C76([DocServerIndex]))
		
		If (String:C10([DocServerIndex]UniqueID+[DocServerIndex]PrimaryKeyValue)#"")
			$file:=File:C1566(Convert path system to POSIX:C1106($myFolder.platformPath+"LogBookDocs/"+String:C10([DocServerIndex]UniqueID+[DocServerIndex]PrimaryKeyValue)))
			
			If (Not:C34($file.exists))
				
				$file.create()
			End if 
			
			BLOB TO DOCUMENT:C526($file.platformPath; [DocServerIndex]DocBlob)  //$blob)
			
		End if 
		
		NEXT RECORD:C51([DocServerIndex])
		
	End for 
	
End if 

If (True:C214)  // export Specification Documents
	
	QUERY:C277([DocServerIndex]; [DocServerIndex]TableNumber=21)
	$sizee:=Records in selection:C76([DocServerIndex])
	
	FIRST RECORD:C50([DocServerIndex])
	For ($i; 0; Records in selection:C76([DocServerIndex]))
		
		If (String:C10([DocServerIndex]UniqueID+[DocServerIndex]PrimaryKeyValue)#"")
			$file:=File:C1566(Convert path system to POSIX:C1106($myFolder.platformPath+"SpecificationsDocuments/"+String:C10([DocServerIndex]UniqueID+[DocServerIndex]PrimaryKeyValue)))
			
			If (Not:C34($file.exists))
				
				$file.create()
			End if 
			
			BLOB TO DOCUMENT:C526($file.platformPath; [DocServerIndex]DocBlob)
			
		End if 
		
		NEXT RECORD:C51([DocServerIndex])
		
	End for 
End if 

If (True:C214)  // export Specification PublishedDocumentBlob Field
	
	ALL RECORDS:C47([Spec_Control])
	FIRST RECORD:C50([Spec_Control])
	For ($i; 0; Records in selection:C76([Spec_Control]))
		If ([Spec_Control]Spec#"")
			
			$file:=File:C1566(Convert path system to POSIX:C1106($myFolder.platformPath+"SpecificationsPublishedDocumentBlobField/"+String:C10([Spec_Control]Spec)))
			
			If (Not:C34($file.exists))
				
				$file.create()
			End if 
			
			BLOB TO DOCUMENT:C526($file.platformPath; [Spec_Control]PublishedDocumentBlob)  //$blob)
			
		End if 
		
		NEXT RECORD:C51([Spec_Control])
		
	End for 
	
End if 

If (True:C214)  // export specification
	
	ALL RECORDS:C47([Spec_Control])
	$jsonString:=Selection to JSON:C1234([Spec_Control])
	
	vhDoc:=Create document:C266($myFolder.platformPath+"specification_export.json")
	If (OK=1)
		SEND PACKET:C103(vhDoc; $jsonString)
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	
	//SHOW ON DISK("specification_export.json")
	
End if 

If (True:C214)  // export Supplier Documents
	
	QUERY:C277([DocServerIndex]; [DocServerIndex]TableNumber=18)
	FIRST RECORD:C50([DocServerIndex])
	For ($i; 1; Records in selection:C76([DocServerIndex]))
		
		If (String:C10([DocServerIndex]UniqueID+[DocServerIndex]PrimaryKeyValue)#"")
			$file:=File:C1566(Convert path system to POSIX:C1106($myFolder.platformPath+"SuppliersDocs/"+String:C10([DocServerIndex]UniqueID+[DocServerIndex]PrimaryKeyValue)))
			
			If (Not:C34($file.exists))
				
				$file.create()
			End if 
			
			BLOB TO DOCUMENT:C526($file.platformPath; [DocServerIndex]DocBlob)  //$blob)
			
		End if 
		
		NEXT RECORD:C51([DocServerIndex])
		
	End for 
	
	
End if 


If (True:C214)  // export Housekeeping_div_add
	
	ALL RECORDS:C47([Housekeeping_div_add])
	$jsonString:=Selection to JSON:C1234([Housekeeping_div_add])
	
	vhDoc:=Create document:C266($myFolder.platformPath+"divisionInfo_export.json")
	If (OK=1)
		SEND PACKET:C103(vhDoc; $jsonString)
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	
	SHOW ON DISK:C922($myFolder.platformPath+"divisionInfo_export.json")
	
End if 


If (True:C214)  // export [CHART_OF_AC]
	
	ALL RECORDS:C47([CHART_OF_AC])
	$jsonString:=Selection to JSON:C1234([CHART_OF_AC])
	
	vhDoc:=Create document:C266($myFolder.platformPath+"chartOfAcc_export.json")
	If (OK=1)
		SEND PACKET:C103(vhDoc; $jsonString)
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	
	SHOW ON DISK:C922($myFolder.platformPath+"chartOfAcc_export.json")
	
End if 

If (True:C214)  // export [Asset_List]
	
	ALL RECORDS:C47([Asset_List])
	$jsonString:=Selection to JSON:C1234([Asset_List])
	
	vhDoc:=Create document:C266($myFolder.platformPath+"assetList_export.json")
	If (OK=1)
		SEND PACKET:C103(vhDoc; $jsonString)
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	
	SHOW ON DISK:C922($myFolder.platformPath+"assetList_export.json")
	
End if 

If (True:C214)  // export [Credit_Memo]
	
	ALL RECORDS:C47([Credit_Memo])
	$jsonString:=Selection to JSON:C1234([Credit_Memo])
	
	vhDoc:=Create document:C266($myFolder.platformPath+"Credit_Memo_list_export.json")
	If (OK=1)
		SEND PACKET:C103(vhDoc; $jsonString)
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	
	SHOW ON DISK:C922($myFolder.platformPath+"Credit_Memo_list_export.json")
	
End if 


If (True:C214)  // export [CM_items]
	
	ALL RECORDS:C47([CM_items])
	$jsonString:=Selection to JSON:C1234([CM_items])
	
	vhDoc:=Create document:C266($myFolder.platformPath+"CM_items_list_export.json")
	If (OK=1)
		SEND PACKET:C103(vhDoc; $jsonString)
		CLOSE DOCUMENT:C267(vhDoc)
	End if 
	
	SHOW ON DISK:C922($myFolder.platformPath+"CM_items_list_export.json")
	
End if 


ALERT:C41("END!")