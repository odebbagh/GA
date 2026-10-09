singleton Class constructor
	//It's a singleton class
	
Function _activate_save_cancel_button()
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	Form:C1466.sfw.redrawButtons()
	
Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities
	// Purpose: SFW redraws buttons inside panelFormMethod before this panel finishes loading. Sync the clone after display work, then redraw.
	// modified by 4D/PS [2026-october-05]
	$needSync:=Form:C1466.sfw.updateOfPanelNeeded()
	If ($needSync)  //The current item is changed or reloaded, so it's necessary ti refresh 
		
		This:C1470.LoadAllTabs()
		
		If (Undefined:C82(Form:C1466.bufferOfEvents))
			Form:C1466.bufferOfEvents:=New collection:C1472()
		End if 
		
	End if 
	
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of 
			: (FORM Get current page:C276(*)=1)
				
			: (FORM Get current page:C276(*)=2)
				This:C1470.loadDocuments()
				OBJECT SET ENTERABLE:C238(*; "lb_documents"; False:C215)
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if 
	cs:C1710.Util.me.lockDateInputs()
	If ($needSync)
		This:C1470._syncCloneAfterLoad()
		Form:C1466.sfw.redrawButtons()
	End if 
	
	
Function drawPup_XXX()
	/* Unused SFW panel template stub.
	Form:C1466.sfw.drawButtonPup("pup_xxx"; $xxxName; "xxxx.png"; (Form:C1466.current_item.xxxx=Null:C1517))
	*/
	
	
Function pup_XXX()
	/* Unused SFW panel template stub. */
	
	
Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	This:C1470._drawPups()
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	
	Case of 
			
		: (FORM Get current page:C276(*)=2)
			
			OBJECT GET COORDINATES:C663(*; "lb_documents"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			$offset:=4
			
			OBJECT SET COORDINATES:C1248(*; "lb_documents"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			
	End case 
	OBJECT SET VISIBLE:C603(*; "btnDatePicker@"; Form:C1466.sfw.checkIsInModification())
	cs:C1710.Util.me.lockDateInputs()
	OBJECT SET VISIBLE:C603(*; "bSpecView"; Not:C34(Form:C1466.sfw.checkIsInModification()))
	OBJECT SET VISIBLE:C603(*; "bSpecEdit"; Form:C1466.sfw.checkIsInModification())
	
	Use (Form:C1466.sfw.entry.panel.pages)
		$docCount:=0
		If (Form:C1466.lb_documents#Null:C1517)
			$docCount:=Form:C1466.lb_documents.length
		End if 
		Form:C1466.sfw.entry.panel.pages[1].label:="Documents ("+String:C10($docCount)+")"
	End use 
	
	If (Form:C1466.sfw.checkIsInModification())
		
		// Purpose: QA edit gate uses _ga_qaEditProfiles (qs, qi, qm) — aligned with Staff entry.
		// modified by 4D/PS [2026-may-21]
		// modified by 4D/PS [2026-october-05]
		$approverProfile:=_ga_qaEditProfiles
		$hasAuthorizedProfile:=False:C215
		If (cs:C1710.sfw_userManager.me.authorizedProfiles#Null:C1517)
			$hasAuthorizedProfile:=cs:C1710.sfw_userManager.me.authorizedProfiles.find(Formula:C1597((Value type:C1509($1.value)=Is text:K8:3) && ($approverProfile.indexOf($1.value)#-1)))#Null:C1517
		End if
		
		OBJECT SET ENABLED:C1123(*; "entryField_isApproved"; $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_approver"; False:C215)  // $hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "entryField_approvalDate"; False:C215)  //$hasAuthorizedProfile)
		OBJECT SET ENABLED:C1123(*; "btnDatePickerApproval"; False:C215)  //$hasAuthorizedProfile)
		
	End if 
	
	Form:C1466.sfw.drawHTab()
	
	
Function LoadAllTabs()
	
	This:C1470.loadDocuments()
	This:C1470._drawPups()
	
	
Function _syncCloneAfterLoad()
	// Purpose: After Cancel, SFW reloads then the panel display can touch the entity again; take a fresh clean clone.
	// modified by 4D/PS [2026-october-05]
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	If (Not:C34(Undefined:C82(Form:C1466.current_clone))) && (Form:C1466.current_clone#Null:C1517)
		Form:C1466.current_clone:=Form:C1466.current_item.clone()
	End if
	
	
Function loadDocuments()
	var $doc; $row : Object
	
	// Purpose: Build a display collection; do not write creationDateTime back onto the entity documents.
	// modified by 4D/PS [2026-october-09]
	Form:C1466.lb_documents:=New collection:C1472()
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	If (Form:C1466.current_item.documents=Null:C1517) || (Form:C1466.current_item.documents.documentsCollection=Null:C1517)
		return 
	End if 
	For each ($doc; Form:C1466.current_item.documents.documentsCollection)
		$row:=New object:C1471(\
			"code"; String:C10($doc.code); \
			"sourcePath"; String:C10($doc.sourcePath); \
			"description"; String:C10($doc.description); \
			"isApproved"; Bool:C1537($doc.isApproved); \
			"creationDateTime"; This:C1470._documentFillingLabel($doc)\
			)
		Form:C1466.lb_documents.push($row)
	End for each 
	
	
	// Purpose: Format document filling stamp for the listbox without mutating the stored object.
	// created by 4D/PS [2026-october-09]
Function _documentFillingLabel($doc : Object)->$label : Text
	var $days; $time : Integer
	var $timeType : Time
	
	$label:=""
	If ($doc=Null:C1517)
		return 
	End if 
	$days:=Trunc:C95(Num:C11($doc.creationDateTimeStamp)/86400; 0)
	$time:=Num:C11($doc.creationDateTimeStamp)%86400
	$timeType:=?00:00:00?+$time
	$label:=String:C10((Add to date:C393(!00-00-00!; 2000; 1; 1)+$days); System date short:K1:1)+"   "+String:C10($timeType; HH MM:K7:2)
	
	
	// Purpose: Stored document row for View/Modify/Delete (list rows are display-only).
	// created by 4D/PS [2026-october-09]
Function _selectedStoredDocument()->$doc : Object
	var $pos : Integer
	
	$doc:=Null:C1517
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	If (Form:C1466.current_item.documents=Null:C1517) || (Form:C1466.current_item.documents.documentsCollection=Null:C1517)
		return 
	End if 
	$pos:=Num:C11(Form:C1466.selectedDocumentPos)
	If ($pos>0) && ($pos<=Form:C1466.current_item.documents.documentsCollection.length)
		$doc:=Form:C1466.current_item.documents.documentsCollection[$pos-1]
	End if 
	
	
Function _ensureDocuments()
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	If (Form:C1466.current_item.documents=Null:C1517)
		Form:C1466.current_item.documents:=New object:C1471
	End if 
	If (Form:C1466.current_item.documents.documentsCollection=Null:C1517)
		Form:C1466.current_item.documents.documentsCollection:=New collection:C1472()
	End if 
	
	
	
Function bActionDocument()
	
	$refMenu:=Create menu:C408
	APPEND MENU ITEM:C411($refMenu; "View document"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 1; "--view")
	If (Form:C1466.selectedDocument=Null:C1517) | (Undefined:C82(Form:C1466.selectedDocument))
		DISABLE MENU ITEM:C150($refMenu; 1)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "Add Document"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 2; "--add")
	If (Form:C1466.sfw.checkIsInModification()=False:C215)
		DISABLE MENU ITEM:C150($refMenu; 2)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "Modify document"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 3; "--modify")
	If (Form:C1466.sfw.checkIsInModification()=False:C215) | (Form:C1466.selectedDocument=Null:C1517) | Undefined:C82(Form:C1466.selectedDocument)
		DISABLE MENU ITEM:C150($refMenu; 3)
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "Delete document"; *)
	SET MENU ITEM PARAMETER:C1004($refMenu; 4; "--delete")
	If (Form:C1466.sfw.checkIsInModification()=False:C215) | (Form:C1466.selectedDocument=Null:C1517) | Undefined:C82(Form:C1466.selectedDocument)
		DISABLE MENU ITEM:C150($refMenu; 4)
	End if 
	
	$choice:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	Case of 
		: ($choice="--view")
			
			$doc:=This:C1470._selectedStoredDocument()
			If ($doc#Null:C1517)
				$LocalFile:=Temporary folder:C486+Folder separator:K24:12+String:C10($doc.sourcePath)
				If ($doc.blob#Null:C1517)
					BLOB TO DOCUMENT:C526($LocalFile; $doc.blob)
					OPEN URL:C673($LocalFile; *)
				Else 
					cs:C1710.sfw_dialog.me.alert("This document has no file to open.")
				End if 
			End if
			
			
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
			$form.displayApprovalFields:=True:C214
			$form.documentHasChanged:=True:C214
			
			$winRef:=Open form window:C675("_ga_document"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("_ga_document"; $form)
			
			If (OK=1)
				
				If ($form.documentHasChanged) | Not:C34($form.details.isApproved)
					Form:C1466.current_item.stmpApproval:=0
					Form:C1466.current_item.approvedBy:=""
					Form:C1466.current_item.isApproved:=False:C215
				End if 
				
				//Form.lb_documents.push($form.details)
				
				If (Undefined:C82(Form:C1466.bufferOfEvents)) | (Form:C1466.bufferOfEvents=Null:C1517)
					Form:C1466.bufferOfEvents:=New collection:C1472()
				End if 
				$buffer:=New object:C1471()
				$buffer.event:="addDocument"
				$buffer.label:="Document "+$form.details.sourcePath+" added"
				$buffer.stmp:=cs:C1710.sfw_stmp.me.now()
				Form:C1466.bufferOfEvents.push($buffer)
				
				This:C1470._ensureDocuments()
				Form:C1466.current_item.documents.documentsCollection.push($form.details)
				cs:C1710.panel_specification.me._activate_save_cancel_button()
			End if 
			
			
		: ($choice="--modify")
			
			$document:=OB Copy:C1225(Form:C1466.current_item.documents.documentsCollection[Form:C1466.selectedDocumentPos-1])
			$form:=New object:C1471("details"; OB Copy:C1225(Form:C1466.current_item.documents.documentsCollection[Form:C1466.selectedDocumentPos-1]))
			$form.approverProfile:=_ga_qaEditProfiles
			$form.displayApprovalFields:=True:C214
			$form.documentHasChanged:=False:C215
			$form.bufferOfEvents:=Form:C1466.bufferOfEvents
			
			$winRef:=Open form window:C675("_ga_document"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
			DIALOG:C40("_ga_document"; $form)
			
			If (OK=1)
				
				If ($form.documentHasChanged) | Not:C34($form.details.isApproved)
					Form:C1466.current_item.stmpApproval:=0
					Form:C1466.current_item.approvedBy:=""
					Form:C1466.current_item.isApproved:=False:C215
				End if 
				//$blobHasBeenChanged:=JSON Stringify($document.blob)#JSON Stringify($form.details.blob)
				If ($form.modified) | ($form.documentHasChanged)
					//Form.selectedDocument:=$form.details
					Form:C1466.current_item.documents.documentsCollection[Form:C1466.selectedDocumentPos-1]:=$form.details
					cs:C1710.panel_specification.me._activate_save_cancel_button()
				End if 
			End if 
			
		: ($choice="--delete")
			
			$ok:=cs:C1710.sfw_dialog.me.confirm("Do you really want to delete this document? "; "Delete"; "CANCEL")
			If ($ok)
				//Form.lb_documents.remove(Form.selectedDocumentPos-1)
				
				If (Undefined:C82(Form:C1466.bufferOfEvents)) | (Form:C1466.bufferOfEvents=Null:C1517)
					Form:C1466.bufferOfEvents:=New collection:C1472()
				End if 
				$buffer:=New object:C1471()
				$buffer.event:="deleteDocument"
				$buffer.label:="Document "+Form:C1466.current_item.documents.documentsCollection[Form:C1466.selectedDocumentPos-1].sourcePath+" deleted"
				$buffer.stmp:=cs:C1710.sfw_stmp.me.now()
				Form:C1466.bufferOfEvents.push($buffer)
				
				Form:C1466.current_item.documents.documentsCollection.remove(Form:C1466.selectedDocumentPos-1)
				cs:C1710.panel_specification.me._activate_save_cancel_button()
				
			End if 
			
	End case 
	
	This:C1470.loadDocuments()
	
	
Function _drawPups()
	// Purpose: Category and Department are 3D popup buttons, not bound inputs. Clear or rewrite them on every item change/cancel so the previous record's label cannot stick.
	// created by 4D/PS [2026-october-05]
	If (Form:C1466.current_item=Null:C1517)
		If (Form:C1466.sfw#Null:C1517)
			Form:C1466.sfw.drawButtonPup("pup_category"; ""; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; False:C215)
			Form:C1466.sfw.drawButtonPup("pup_departement"; ""; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; False:C215)
		End if 
		OBJECT SET TITLE:C194(*; "pup_category"; "")
		OBJECT SET TITLE:C194(*; "pup_departement"; "")
		return 
	End if 
	This:C1470.drawPup_category()
	This:C1470.drawPup_departement()
	
	
Function drawPup_category()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("DocumentCategory"; "UUID"; "UUID_DocumentCategory"; "pup_category")
	End if 
	
	
Function pup_category()
	//Create pop up menu
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	Form:C1466.current_item.pup("specCategories"; "DocumentCategory"; "UUID"; "UUID_DocumentCategory")
	This:C1470.drawPup_category()
	
	
Function drawPup_departement()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.drowPup("ControllingDepartment"; "UUID"; "UUID_ControllingDepartment"; "pup_departement")
	End if 
	
	
Function pup_departement()
	//Create pop up menu
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	Form:C1466.current_item.pup("specDepartements"; "ControllingDepartment"; "UUID"; "UUID_ControllingDepartment")
	This:C1470.drawPup_departement()
	
	
Function bSpecEdit()
	
	If (Form:C1466.current_item=Null:C1517)
		return 
	End if 
	
	$details:=New object:C1471("blob"; Form:C1466.current_item.publishedDocumentBlob; "docPath"; ""; "docName"; Form:C1466.current_item.spec)
	
	$form:=New object:C1471("details"; $details)
	$form.documentHasChanged:=False:C215
	
	$winRef:=Open form window:C675("_ga_uploadDocument"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40("_ga_uploadDocument"; $form)
	
	If (OK=1)
		If ($form.documentHasChanged)
			Form:C1466.current_item.revisionDate:=Current date:C33(*)
			Form:C1466.current_item.stmpApproval:=0
			Form:C1466.current_item.approvedBy:=""
			Form:C1466.current_item.isApproved:=False:C215
			Form:C1466.current_item.publishedDocumentBlob:=$form.details.blob
			cs:C1710.panel_specification.me._activate_save_cancel_button()
		End if 
	End if 
	
	
	
	
	