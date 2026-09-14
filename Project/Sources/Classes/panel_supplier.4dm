singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities 
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh 
		Form:C1466.mainAddress:=1
		Form:C1466.remitAddress:=0
		Form:C1466.primaryContact:=1
		Form:C1466.secondaryContact:=0
		This:C1470.LoadContact()
		This:C1470.LoadAllTabs()
		
		If (Undefined:C82(Form:C1466.bufferOfEvents))
			Form:C1466.bufferOfEvents:=New collection:C1472()
		End if 
		
	End if 
	
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				
				
			: (FORM Get current page:C276(*)=2)
				This:C1470.LoadContact()
				
			: (FORM Get current page:C276(*)=3)
				This:C1470.loadDocuments()
				OBJECT SET ENTERABLE:C238(*; "lb_documents"; False:C215)
				
			: (FORM Get current page:C276(*)=4)
				This:C1470.loadRatingData()
				OBJECT SET ENTERABLE:C238(*; "lb_rating"; False:C215)
				
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	
	This:C1470.contactDetails()
	This:C1470.drawPup_enteredBy()
	This:C1470.drawPup_division()
	
	
	OBJECT SET VISIBLE:C603(*; "btnDatePicker@"; Form:C1466.sfw.checkIsInModification())
	OBJECT SET ENTERABLE:C238(*; "lb_contact"; False:C215)
	
	Use (Form:C1466.sfw.entry.panel.pages)
		Form:C1466.sfw.entry.panel.pages[2].label:="Documents ("+String:C10(Form:C1466.lb_documents.length)+")"
	End use 
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$offset:=2
	Case of 
			
		: (FORM Get current page:C276(*)=1)
			
			OBJECT GET COORDINATES:C663(*; "entryField_qaComment"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "entryField_qaComment"; $g; $h; $widthSubform-10; $b)
			
		: (FORM Get current page:C276(*)=2)
			
			OBJECT GET COORDINATES:C663(*; "subFormAddress"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "subFormAddress"; $g; $h; $widthSubform-10; $b)
			
		: (FORM Get current page:C276(*)=3)
			
			OBJECT GET COORDINATES:C663(*; "lb_documents"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT SET COORDINATES:C1248(*; "lb_documents"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			
		: (FORM Get current page:C276(*)=4)
			
			OBJECT GET COORDINATES:C663(*; "lb_rating"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			OBJECT SET COORDINATES:C1248(*; "lb_rating"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset)
			
			
			
	End case 
	
	If (Form:C1466.sfw.checkIsInModification())
		
		// Purpose: QA edit gate uses _ga_qaEditProfiles (qs, qi, qm) — aligned with Staff entry.
		// modified by 4D/PS [2026-may-21]
		$approverProfile:=_ga_qaEditProfiles
		
		$hasAuthorizedProfile:=cs:C1710.sfw_userManager.me.authorizedProfiles.find(Formula:C1597((Value type:C1509($1.value)=Is text:K8:3) && ($approverProfile.indexOf($1.value)#-1)))#Null:C1517
		
		OBJECT SET ENABLED:C1123(*; "entryField_approvedByQA"; $hasAuthorizedProfile)
		
		
	End if 
	
	Form:C1466.sfw.drawHTab()
	
	
Function contactDetails()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.subFormAddress:=New object:C1471()
		Form:C1466.subFormAddress.address:=Form:C1466.current_item.rebuildAddress()
		Form:C1466.lb_contact:=Form:C1466.current_item.rebuildContact()
		Form:C1466.subFormAddress.situation:=Form:C1466.situation
	End if 
	
	
Function bActionContact()
	$refMenu:=Create menu:C408
	APPEND MENU ITEM:C411($refMenu; "Open in new window"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "openInWindow")
	
	Case of 
		: (Form:C1466.primaryContact=1)
			$type:="Primary"
		: (Form:C1466.secondaryContact=1)
			$type:="Secondary"
	End case 
	
	If (ds:C1482.Contact.query("UUID_Company = :1"; Form:C1466.current_item.UUID).query("title=:1"; $type).first()=Null:C1517)
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	$choice:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	Case of 
		: ($choice="openInWindow")
			Form:C1466.sfw.openInANewWindow(ds:C1482.Contact.query("UUID_Company = :1"; Form:C1466.current_item.UUID).query("title=:1"; $type).first(); "customerService"; "contact")
	End case 
	This:C1470.LoadContact()
	
	
	
Function LoadContact()
	
	Case of 
		: (Form:C1466.primaryContact=1)
			$type:="Primary"
		: (Form:C1466.secondaryContact=1)
			$type:="Secondary"
	End case 
	
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.lb_contact:=New collection:C1472()
		Form:C1466.lb_contact:=Form:C1466.current_item.rebuildContact()
	End if 
	
	
Function drawPup_enteredBy()
	If (Form:C1466.current_item#Null:C1517)
		$operator:=ds:C1482.Staff.query("code= :1"; Form:C1466.current_item.enteredBy).first() || New object:C1471()
		$operatorCode:=$operator.code
		If ($operatorCode=Null:C1517)
			$operatorCode:=""
		End if 
		$color:=""
		$pathIcon:=""
		Form:C1466.sfw.drawButtonPup("pup_enteredBy"; $operatorCode; $pathIcon; ($operator=Null:C1517))
		
	End if 
	
	
Function pup_enteredBy()
	//Create pop up menu
	
	If (Form:C1466.sfw.checkIsInModification())
		
		OBJECT GET COORDINATES:C663(*; "pup_enteredBy"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$form:=New object:C1471(\
			"colName"; "code"; \
			"allData"; ds:C1482.Staff.all(); \
			"dataclass"; "Staff"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (ok=1)
			Form:C1466.current_item.enteredBy:=$form.item.code
			cs:C1710.panel_supplier.me._activate_save_cancel_button()
		End if 
	End if 
	
	This:C1470.drawPup_enteredBy()
	
	
Function drawPup_division()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("Division"; "UUID"; "UUID_Division"; "pup_division")
	End if 
	
	
Function pup_division()
	//Create pop up menu
	Form:C1466.current_item.pup("divisions"; "Division"; "UUID"; "UUID_Division")
	This:C1470.drawPup_division()
	
	
Function bActionDocument()
	
	$refMenu:=Create menu:C408
	APPEND MENU ITEM:C411($refMenu; "View report"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 1; "--view")
	If (Form:C1466.selectedDocument=Null:C1517) | (Undefined:C82(Form:C1466.selectedDocument))
		DISABLE MENU ITEM:C150($refMenu; 1)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "add report"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 2; "--add")
	If (sfw_checkIsInModification=False:C215)
		DISABLE MENU ITEM:C150($refMenu; 2)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "modify report"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 3; "--modify")
	If (sfw_checkIsInModification=False:C215) | (Form:C1466.selectedDocument=Null:C1517) | Undefined:C82(Form:C1466.selectedDocument)
		DISABLE MENU ITEM:C150($refMenu; 3)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "delete report"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 4; "--delete")
	If (sfw_checkIsInModification=False:C215) | (Form:C1466.selectedDocument=Null:C1517) | Undefined:C82(Form:C1466.selectedDocument)
		DISABLE MENU ITEM:C150($refMenu; 4)
	End if 
	
	$choice:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	Case of 
		: ($choice="--view")
			
			$LocalFile:=Temporary folder:C486+Folder separator:K24:12+Form:C1466.selectedDocument.sourcePath
			BLOB TO DOCUMENT:C526($LocalFile; Form:C1466.selectedDocument.blob)
			OPEN URL:C673($LocalFile; *)
			
			
		: ($choice="--add")
			
			$details:=New object:C1471
			OB SET:C1220($details; "code"; ""; \
				"dateTimeStamp"; cs:C1710.sfw_stmp.me.now(); \
				"creationDateTimeStamp"; cs:C1710.sfw_stmp.me.now(); \
				"documentPath"; ""; \
				"sourcePath"; ""; \
				"description"; ""; \
				"approvalDate"; Date:C102(!00-00-00!); \
				"approvedBy"; ""; \
				"isApproved"; False:C215)
			
			
			$form:=New object:C1471("details"; $details)  // Form.selectedDocument)
			$form.approverProfile:=_ga_qaEditProfiles
			$form.displayApprovalFields:=False:C215
			
			$winRef:=Open form window:C675("_ga_document"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("_ga_document"; $form)
			If (OK=1)
				//Form.lb_documents.push($form.details)
				
				$buffer:=New object:C1471()
				$buffer.event:="addDocument"
				$buffer.label:="Document "+$form.details.sourcePath+" added"
				$buffer.stmp:=cs:C1710.sfw_stmp.me.now()
				Form:C1466.bufferOfEvents.push($buffer)
				
				Form:C1466.current_item.attachedDocuments.documents.push($form.details)
				cs:C1710.panel_supplier.me._activate_save_cancel_button()
			End if 
			
			
		: ($choice="--modify")
			
			$form:=New object:C1471("details"; OB Copy:C1225(Form:C1466.current_item.attachedDocuments.documents[Form:C1466.selectedDocumentPos-1]))
			$form.approverProfile:=_ga_qaEditProfiles 
			$form.displayApprovalFields:=False:C215
			$form.bufferOfEvents:=Form:C1466.bufferOfEvents
			
			$winRef:=Open form window:C675("_ga_document"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("_ga_document"; $form)
			
			If (OK=1)
				If ($form.modified) | ($form.documentHasChanged)
					//Form.selectedDocument:=$form.details
					Form:C1466.current_item.attachedDocuments.documents[Form:C1466.selectedDocumentPos-1]:=$form.details
					cs:C1710.panel_supplier.me._activate_save_cancel_button()
				End if 
			End if 
			
		: ($choice="--delete")
			
			$ok:=cs:C1710.sfw_dialog.me.confirm("Do you really want to delete this document? "; "Delete"; "CANCEL")
			If ($ok)
				
				//Form.lb_documents.remove(Form.selectedDocumentPos-1)
				
				$buffer:=New object:C1471()
				$buffer.event:="deleteDocument"
				$buffer.label:="Document "+Form:C1466.current_item.attachedDocuments.documents[Form:C1466.selectedDocumentPos-1].sourcePath+" deleted"
				$buffer.stmp:=cs:C1710.sfw_stmp.me.now()
				Form:C1466.bufferOfEvents.push($buffer)
				
				Form:C1466.current_item.attachedDocuments.documents.remove(Form:C1466.selectedDocumentPos-1)
				cs:C1710.panel_supplier.me._activate_save_cancel_button()
				
			End if 
			
			//This.loadDocuments()
			
	End case 
	
	This:C1470.loadDocuments()
	
	
Function loadDocuments()
	
	If (Form:C1466.current_item#Null:C1517)
		
		Form:C1466.lb_documents:=Form:C1466.current_item.attachedDocuments.documents.map(Formula:C1597(_ga_getDateTime))
		
	End if 
	
	
Function LoadAllTabs()
	
	This:C1470.loadDocuments()
	
	
Function loadRatingData()
	// Delegates rating computation to SupplierEntity.buildRatingData() to keep logic in one place
	Form:C1466.lb_rating:=Form:C1466.current_item.buildRatingData()
	
Function bActionRating()
	
	$refMenu:=Create menu:C408
	
	APPEND MENU ITEM:C411($refMenu; "export to Excel"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 1; "--export")
	
	$choice:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	Case of 
			
		: ($choice="--export")
			
			If (Form:C1466.lb_rating.length>0)
				
				$templateFile:=Folder:C1567(fk resources folder:K87:11).file("excelTemplates/excelExportTemplate.xlsx")
				
				$mapping:=New collection:C1472(\
					New object:C1471("header"; "Date"; "field"; "date"; "footerOperation"; ""); \
					New object:C1471("header"; "Year"; "field"; "year"; "footerOperation"; ""); \
					New object:C1471("header"; "Month"; "field"; "month"; "footerOperation"; ""); \
					New object:C1471("header"; "Quarter"; "field"; "quarter"; "footerOperation"; ""); \
					New object:C1471("header"; "Receiving Total Lots"; "field"; "receivingTotalLots"; "footerOperation"; "sum"); \
					New object:C1471("header"; "Receiving without NMNs"; "field"; "receivingWithoutNMNs"; "footerOperation"; "sum"); \
					New object:C1471("header"; "Receiving % LAR"; "field"; "receivingLAR"; "footerOperation"; ""); \
					New object:C1471("header"; "Functional Total Lots"; "field"; "functionalTotalLots"; "footerOperation"; "sum"); \
					New object:C1471("header"; "Functional Without NMNs"; "field"; "functionalWithoutNMNs"; "footerOperation"; "sum"); \
					New object:C1471("header"; "Functional % LAR"; "field"; "functionalLAR"; "footerOperation"; ""); \
					New object:C1471("header"; "Delivery Total Lots"; "field"; "deliveryTotalLots"; "footerOperation"; "sum"); \
					New object:C1471("header"; "Delivery Minor Delay w/in 10 days"; "field"; "deliveryMinorDelay"; "footerOperation"; "sum"); \
					New object:C1471("header"; "Delivery Major Delay over 10 days"; "field"; "deliveryMajorDelay"; "footerOperation"; "sum"); \
					New object:C1471("header"; "Delivery % LAR"; "field"; "deliveryLAR"; "footerOperation"; ""); \
					New object:C1471("header"; "Composite % Over-all Rating"; "field"; "compositeOverAllRating"; "footerOperation"; ""); \
					New object:C1471("header"; "ISO Certified"; "field"; "ISOCertified"; "footerOperation"; "")\
					)
				
				$supplierName:=Replace string:C233(Form:C1466.current_item.name; " "; "_")
				$fileName:="SupplierRating_"+$supplierName
				$destinationFolderPath:=Get 4D folder:C485(Current resources folder:K5:16)+"exportedData"+Folder separator:K24:12+"Suppliers"
				$destinationFileName:=Split string:C1554(String:C10($fileName+"_"+Replace string:C233(String:C10(Date:C102(Timestamp:C1445)); "/"; "_")); " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2).join("")
				$sheetName:="Supplier Rating"
				
				$offscreen:=cs:C1710.ExcelDataExporter.new($templateFile.platformPath; $mapping; Form:C1466.lb_rating; $destinationFileName; $destinationFolderPath; ""; $sheetName; False:C215)
				$excelSheet:=VP Run offscreen area($offscreen)
				
			Else 
				
				cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("No items in the list to Export"))
				
			End if 
			
	End case 
	
	//This.loadDocuments()
	
	
	
	
	