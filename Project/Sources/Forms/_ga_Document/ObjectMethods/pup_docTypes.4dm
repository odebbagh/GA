

Case of 
		
	: (Form event code:C388=On Load:K2:1)
		OBJECT SET TITLE:C194(*; "pup_docTypes"; String:C10(Form:C1466.details.code))
		
	: (Form event code:C388=On Clicked:K2:4)
		//var $hList; $hSousList : Integer
		var $hListItems : Collection
		var $hSousListItems : Collection
		$hListItems:=ds:C1482.DocumentCategory.all().toCollection().extract("name")
		//$hListItems:=New collection("DocTypeChecks"; \
			"DocTypeDeposits"; \
			"DocTypeEquipment"; \
			"DocTypeJob"; \
			"DocTypeOther"; \
			"DocTypeQuote"; \
			"DocTypeResourceCal"; \
			"DocTypeSalesOrder"; \
			"DocTypeSupplier"; \
			"DocTypeTraveler"; \
			"DocTypeVendorPO")
		
		//$hSousListItems:=New collection(New collection("CKD Check Disbursed"); \
			New collection("CKR Check Received"); \
			New collection("CAL Calibration Data"); \
			New collection("IN Customer Job-Instructions"; "RPT Reports"); \
			New collection("---"; "OT   Other"); \
			New collection("QT Quote"; "RFQ Request for Quote"); \
			New collection("TS Resource Time-Slip acknowledgement"); \
			New collection("CPO Customer's PO"); \
			New collection("CRT Certificate"); \
			New collection("DL data-log"; "SM Tester Summary"); \
			New collection("VPO PO issued to Vendor"))
		
		$hList:=Create menu:C408
		
		
		$hListItemsLength:=$hListItems.length
		$k:=1
		For ($i; 0; $hListItemsLength-1)
			
			//$hSousListItemsLength:=$hSousListItems[$i].length
			//$hSousList:=Create menu
			
			//For ($j; 0; $hSousListItemsLength-1)
			
			//APPEND MENU ITEM($hSousList; $hSousListItems[$i][$j]; *)
			//SET MENU ITEM PARAMETER($hSousList; -1; $hSousListItems[$i][$j])
			//End for 
			
			APPEND MENU ITEM:C411($hList; $hListItems[$i]; *)
			SET MENU ITEM PARAMETER:C1004($hList; -1; $hListItems[$i])
			$k:=$k+1
		End for 
		
		$choose:=Dynamic pop up menu:C1006($hList)
		RELEASE MENU:C978($hList)
		Case of 
			: ($choose#"")
				Form:C1466.details.code:=$choose
				OBJECT SET TITLE:C194(*; "pup_docTypes"; String:C10(Form:C1466.details.code))
				
		End case 
		
End case 