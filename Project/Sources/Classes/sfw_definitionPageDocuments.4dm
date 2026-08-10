property ident : Text
property offsetHorizontal : Integer
property offsetVertical : Integer
property heightProperties : Integer
property gutter : Integer
property hl_icon_document : Object
property heightDfdButton : Integer
property options : Object
property nbDocuments : Integer
property panelPage : Object

Class constructor($ident : Text; $options : Object)
	
	This:C1470.ident:=$ident
	This:C1470.options:=$options || New object:C1471
	This:C1470.hl_icon_document:=New object:C1471
	For each ($type; Split string:C1554("folder;folderOpen;document;dfd;picture;pdf;write;text"; ";"))
		$file:=Folder:C1567(fk resources folder:K87:11).file("sfw/image/hl/"+$type+".png")
		READ PICTURE FILE:C678($file.platformPath; $pict)
		This:C1470.hl_icon_document[$type]:=$pict
	End for each 
	
	
shared Function _insertDynamicDocumentsPage($formDefinition : Object; $panelPage : Object; $offsetHorizontal : Integer; $offsetVertical : Integer)
	var $pageDefinition : Object
	
	This:C1470.panelPage:=$panelPage
	$dynamicSource:=$panelPage.dynamicSource
	OBJECT GET COORDINATES:C663(*; "detail_panel"; $g; $h; $d; $b)
	$widthDetailPanel:=$d-$g
	$heightDetailPanel:=$b-$h
	
	$widthLH:=300
	This:C1470.heightProperties:=150
	This:C1470.gutter:=5
	
	$pageDefinition:=$formDefinition.pages[$panelPage.page]
	
	This:C1470.offsetHorizontal:=$offsetHorizontal
	This:C1470.offsetVertical:=$offsetVertical
	This:C1470.heightDfdButton:=32
	//bkgd_hl_list
	$bkgdProperties:=New object:C1471
	$bkgdProperties.type:="rectangle"
	$bkgdProperties.top:=$offsetVertical
	$bkgdProperties.left:=$offsetHorizontal
	$bkgdProperties.width:=$widthLH
	$bkgdProperties.height:=$heightDetailPanel-$offsetVertical-This:C1470.heightProperties
	$bkgdProperties.fill:="#FDF3FC"
	$bkgdProperties.stroke:="#C0C0C0"
	$pageDefinition.objects["bkgd_hl_"+$dynamicSource.ident]:=$bkgdProperties
	
	// bAction
	$bActionproperties:=New object:C1471
	$bActionproperties.type:="button"
	$bActionproperties.text:="Actions"
	$bActionproperties.width:=80
	$bActionproperties.height:=21
	$bActionproperties.top:=$heightDetailPanel-This:C1470.gutter-$bActionproperties.height-This:C1470.heightProperties
	$marginBottom:=This:C1470.gutter+$bActionproperties.height+This:C1470.gutter
	$bActionproperties.left:=This:C1470.gutter+$offsetHorizontal
	$bActionproperties.events:=["onClick"]
	$bActionproperties.style:="custom"
	$bActionproperties.popupPlacement:="linked"
	$bActionproperties.icon:="/RESOURCES/sfw/image/picto/gear.png"
	$bActionproperties.textPlacement:="right"
	$bActionproperties.method:="sfw_dynamicPage_bAction"
	$bActionproperties.sizingY:="move"
	$pageDefinition.objects["bAction_"+$dynamicSource.ident]:=$bActionproperties
	
	//HL List
	$bHLProperties:=New object:C1471
	$bHLProperties.type:="list"
	$bHLProperties.top:=$offsetVertical+1
	$bHLProperties.left:=$offsetHorizontal
	$bHLProperties.width:=$widthLH
	$bHLProperties.height:=$heightDetailPanel-$bHLProperties.top-$marginBottom-This:C1470.heightProperties-1
	$bHLProperties.events:=["onSelectionChange"; "onClick"]
	$bHLProperties.scrollbarHorizontal:="hidden"
	$bHLProperties.borderStyle:="none"
	$bHLProperties.fill:="transparent"
	$bHLProperties.enterable:=False:C215
	$bHLProperties.focusable:=False:C215
	$bHLProperties.dataSource:="Form.hl_documents"
	$bHLProperties.sizingY:="grow"
	$bHLProperties.method:="sfw_dynamicPage_hl_document"
	$pageDefinition.objects["hl_"+$dynamicSource.ident]:=$bHLProperties
	
	//bkgd_properties
	$bkgdProperties:=New object:C1471
	$bkgdProperties.type:="rectangle"
	$bkgdProperties.top:=$offsetVertical+$heightDetailPanel-$offsetVertical-This:C1470.heightProperties
	$bkgdProperties.left:=$offsetHorizontal
	$bkgdProperties.width:=$widthLH
	$bkgdProperties.height:=This:C1470.heightProperties
	$bkgdProperties.fill:="#EDF3FC"
	$bkgdProperties.stroke:="#C0C0C0"
	$pageDefinition.objects["bkgd_properties_"+$dynamicSource.ident]:=$bkgdProperties
	
	//title_properties
	$titlePropProperties:=New object:C1471
	$titlePropProperties.type:="text"
	$titlePropProperties.text:=ds:C1482.sfw_readXliff("pagedocument.properties")  //"Properties")
	$titlePropProperties.top:=$offsetVertical+$heightDetailPanel-$offsetVertical-This:C1470.heightProperties+This:C1470.gutter
	$titlePropProperties.height:=16
	$titlePropProperties.left:=This:C1470.gutter+$offsetHorizontal
	$titlePropProperties.with:=150
	$titlePropProperties.stroke:="navy"
	$pageDefinition.objects["title_properties_"+$dynamicSource.ident]:=$titlePropProperties
	
	//pictPreview
	$pictPreviewProperties:=New object:C1471
	$pictPreviewProperties.type:="input"
	$pictPreviewProperties.top:=$offsetVertical
	$pictPreviewProperties.height:=$heightDetailPanel-$offsetVertical
	$pictPreviewProperties.left:=$widthLH
	$pictPreviewProperties.with:=$widthDetailPanel-$widthLH
	$pictPreviewProperties.enterable:=False:C215
	$pictPreviewProperties.focusable:=False:C215
	$pictPreviewProperties.dataSource:="Form.document_pictPreview"
	$pictPreviewProperties.dataSourceTypeHint:="picture"
	$pictPreviewProperties.sizingY:="grow"
	$pictPreviewProperties.sizingX:="grow"
	$pictPreviewProperties.pictureFormat:="proportionalCenter"
	$pictPreviewProperties.borderStyle:="none"
	$pictPreviewProperties.events:=["onClick"]
	$pictPreviewProperties.contextMenu:="none"
	$pageDefinition.objects["pictPreview_"+$dynamicSource.ident]:=$pictPreviewProperties
	
	//WArea for pdf
	$waProperties:=New object:C1471
	$waProperties.type:="webArea"
	$waProperties.top:=$offsetVertical
	$waProperties.height:=$heightDetailPanel-$offsetVertical
	$waProperties.left:=$widthLH
	$waProperties.width:=$widthDetailPanel-$widthLH
	$waProperties.dataSource:="Form.document_pdfInWA"
	$pageDefinition.objects["pdfInWA_"+$dynamicSource.ident]:=$waProperties
	
	//input field for balisedText
	$balisedTextProperties:=New object:C1471
	$balisedTextProperties.type:="input"
	$balisedTextProperties.top:=$offsetVertical
	$balisedTextProperties.height:=$heightDetailPanel-$offsetVertical
	$balisedTextProperties.left:=$widthLH
	$balisedTextProperties.width:=$widthDetailPanel-$widthLH
	$balisedTextProperties.dataSource:="Form.document_balisedText"
	$pageDefinition.objects["balisedText_"+$dynamicSource.ident]:=$balisedTextProperties
	
	
	//dfd
	
	//bkgd_subform
	$bkgdSubformProperties:=New object:C1471
	$bkgdSubformProperties.type:="rectangle"
	$bkgdSubformProperties.top:=$offsetVertical+21+This:C1470.gutter+This:C1470.gutter
	$bkgdSubformProperties.left:=$widthLH
	$bkgdSubformProperties.width:=$widthDetailPanel-$widthLH
	$bkgdSubformProperties.height:=$heightDetailPanel-$offsetVertical
	$bkgdSubformProperties.fill:="#C0C0C0"
	$bkgdSubformProperties.stroke:="#C0C0C0"
	$pageDefinition.objects["dfdSubform_"+$dynamicSource.ident+"_bkgd"]:=$bkgdSubformProperties
	
	//ddPage
	$ddPageProperties:=New object:C1471
	$ddPageProperties.type:="dropdown"
	$ddPageProperties.top:=$offsetVertical+This:C1470.gutter
	$ddPageProperties.left:=$widthLH+This:C1470.gutter
	$ddPageProperties.width:=132
	$ddPageProperties.height:=21
	$ddPageProperties.events:=["onDataChange"]
	$ddPageProperties.dataSource:="Form.dfd_context.ddPage"
	$ddPageProperties.focusable:=False:C215
	$ddPageProperties.method:="dfd_document_script"
	$pageDefinition.objects["dfdSubform_"+$dynamicSource.ident+"_ddPage"]:=$ddPageProperties
	
	//bRuler
	$bRulerProperties:=New object:C1471
	$bRulerProperties.type:="checkbox"
	$bRulerProperties.text:=""
	$bRulerProperties.top:=$offsetVertical+This:C1470.gutter
	$bRulerProperties.left:=$widthDetailPanel-This:C1470.gutter-This:C1470.heightDfdButton
	$bRulerProperties.width:=This:C1470.heightDfdButton
	$bRulerProperties.height:=This:C1470.heightDfdButton
	$bRulerProperties.events:=["onClick"]
	$bRulerProperties.style:="bevel"
	$bRulerProperties.icon:="/RESOURCES/dfd/image/icon/ruler.png"
	$bRulerProperties.focusable:=False:C215
	$bRulerProperties.dataSource:="Form.dfd_context.rulers"
	$bRulerProperties.method:="dfd_document_script"
	$bRulerProperties.sizingX:="move"
	$pageDefinition.objects["dfdSubform_"+$dynamicSource.ident+"_bRuler"]:=$bRulerProperties
	
	
	//bPDF
	$bPDFProperties:=New object:C1471
	$bPDFProperties.type:="button"
	$bPDFProperties.text:=""
	$bPDFProperties.top:=$offsetVertical+This:C1470.gutter
	$bPDFProperties.left:=$widthDetailPanel-This:C1470.gutter-This:C1470.heightDfdButton-This:C1470.gutter-This:C1470.heightDfdButton
	$bPDFProperties.width:=This:C1470.heightDfdButton
	$bPDFProperties.height:=This:C1470.heightDfdButton
	$bPDFProperties.events:=["onClick"]
	$bPDFProperties.style:="bevel"
	$bPDFProperties.icon:="/RESOURCES/dfd/image/icon/document-pdf.png"
	$bPDFProperties.sizingY:="fixed"
	$bPDFProperties.focusable:=False:C215
	$bPDFProperties.sizingX:="move"
	$bPDFProperties.popupPlacement:="None"
	$bPDFProperties.method:="dfd_document_script"
	$pageDefinition.objects["dfdSubform_"+$dynamicSource.ident+"_bPDF"]:=$bPDFProperties
	
	//bPrint
	$bPrintProperties:=New object:C1471
	$bPrintProperties.type:="button"
	$bPrintProperties.text:=""
	$bPrintProperties.top:=$offsetVertical+This:C1470.gutter
	$bPrintProperties.left:=$widthDetailPanel-This:C1470.gutter-This:C1470.heightDfdButton-This:C1470.gutter-This:C1470.heightDfdButton-This:C1470.gutter-This:C1470.heightDfdButton
	$bPrintProperties.width:=This:C1470.heightDfdButton
	$bPrintProperties.height:=This:C1470.heightDfdButton
	$bPrintProperties.events:=["onClick"]
	$bPrintProperties.style:="bevel"
	$bPrintProperties.icon:="/RESOURCES/dfd/image/icon/printer.png"
	$bPrintProperties.sizingY:="fixed"
	$bPrintProperties.focusable:=False:C215
	$bPrintProperties.sizingX:="move"
	$bPrintProperties.popupPlacement:="None"
	$bPrintProperties.method:="dfd_document_script"
	$pageDefinition.objects["dfdSubform_"+$dynamicSource.ident+"_bPrint"]:=$bPrintProperties
	
	
	//ruler
	$rulerProperties:=New object:C1471
	$rulerProperties.type:="ruler"
	$rulerProperties.left:=$widthDetailPanel-(This:C1470.gutter*6)-(This:C1470.heightDfdButton*4)-210
	$rulerProperties.top:=$offsetVertical+This:C1470.gutter
	$rulerProperties.width:=210
	$rulerProperties.height:=21
	$rulerProperties.max:=200
	$rulerProperties.events:=["onClick"; "onDataChange"]
	$rulerProperties.min:=25
	$rulerProperties.graduationStep:=25
	$rulerProperties.step:=25
	$rulerProperties.showGraduations:=True:C214
	$rulerProperties.labelsPlacement:="bottom"
	$rulerProperties.dataSource:="Form.dfd_context.zoom"
	$rulerProperties.fontSize:=10
	$rulerProperties.sizingX:="move"
	$rulerProperties.method:="dfd_document_script"
	$rulerProperties.focusable:=False:C215
	$rulerProperties.continuousExecution:=False:C215
	$pageDefinition.objects["dfdSubform_"+$dynamicSource.ident+"_ruler"]:=$rulerProperties
	
	//subform 
	$dfdSubformProperties:=New object:C1471
	$dfdSubformProperties.type:="subform"
	$dfdSubformProperties.top:=$offsetVertical+21+This:C1470.gutter+This:C1470.gutter
	$dfdSubformProperties.height:=$heightDetailPanel-$offsetVertical
	$dfdSubformProperties.left:=$widthLH
	$dfdSubformProperties.with:=$widthDetailPanel-$widthLH
	$dfdSubformProperties.dataSource:="Form.document_dfd"
	$dfdSubformProperties.borderStyle:="dotted"
	$dfdSubformProperties.sizingY:="grow"
	$dfdSubformProperties.sizingX:="grow"
	$dfdSubformProperties.scrollbarHorizontal:="visible"
	$dfdSubformProperties.scrollbarVertical:="visible"
	$dfdSubformProperties.focusable:=False:C215
	
	$pageDefinition.objects["dfdSubform_"+$dynamicSource.ident]:=$dfdSubformProperties
	
	
	//lb properties
	$lbPropProperties:=New object:C1471
	$lbPropProperties.type:="listbox"
	$lbPropProperties.top:=$offsetVertical+$heightDetailPanel-$offsetVertical-This:C1470.heightProperties+This:C1470.gutter+16+This:C1470.gutter
	$lbPropProperties.left:=$offsetHorizontal+This:C1470.gutter
	$lbPropProperties.width:=$widthLH-This:C1470.gutter-This:C1470.gutter
	$lbPropProperties.height:=This:C1470.heightProperties-This:C1470.gutter-16-This:C1470.gutter-This:C1470.gutter
	$lbPropProperties.listboxType:="collection"
	$lbPropProperties.dataSource:="Form.lb_properties"
	$lbPropProperties.horizontalLineStroke:="transparent"
	$lbPropProperties.verticalLineStroke:="transparent"
	$lbPropProperties.resizingMode:="legacy"
	$lbPropProperties.focusable:=False:C215
	$lbPropProperties.showHeaders:=False:C215
	$lbPropProperties.hideSystemHighlight:=True:C214
	$lbPropProperties.scrollbarHorizontal:="hidden"
	$lbPropProperties.scrollbarVertical:="hidden"
	$lbPropProperties.fill:="transparent"
	$lbPropProperties.borderStyle:="none"
	$lbPropProperties.columns:=New collection:C1472
	$column:=New object:C1471
	$column.name:="columnPropertyName"
	$column.dataSource:="This.property"
	$column.stroke:="#808080"
	$column.width:=90
	$lbPropProperties.columns.push($column)
	$column:=New object:C1471
	$column.name:="columnPropertyValue"
	$column.dataSource:="This.value"
	$lbPropProperties.columns.push($column)
	$pageDefinition.objects["lb_properties_"+$dynamicSource.ident]:=$lbPropProperties
	
	
	$WPareaProperties:=New object:C1471
	$WPareaProperties.type:="write"
	$WPareaProperties.top:=156
	$WPareaProperties.left:=$heightDetailPanel-$offsetVertical+90
	$WPareaProperties.width:=880
	$WPareaProperties.height:=590
	$WPareaProperties.sizingX:="grow"
	$WPareaProperties.sizingY:="grow"
	$WPareaProperties.dataSource:="Form.eDocument.area"
	$WPareaProperties.hideFocusRing:=True:C214
	$WPareaProperties.scrollbarVertical:="automatic"
	$WPareaProperties.scrollbarHorizontal:="automatic"
	$WPareaProperties.dpi:=0
	$WPareaProperties.borderStyle:="none"
	$WPareaProperties.method:="dfd_document_script"
	$WPareaProperties.events:=["onLoad"; "onLosingFocus"; "onGettingFocus"; "onSelectionChange"; "onAfterEdit"]
	$pageDefinition.objects["WP_"+$dynamicSource.ident+"_area"]:=$WPareaProperties
	
	$WPtoolbarProperties:=New object:C1471
	$WPtoolbarProperties.type:="subform"
	$WPtoolbarProperties.top:=$offsetVertical
	$WPtoolbarProperties.left:=$heightDetailPanel-$offsetVertical
	$WPtoolbarProperties.width:=880
	$WPtoolbarProperties.height:=90
	$WPtoolbarProperties.sizingX:="grow"
	$WPtoolbarProperties.detailForm:="WP_Toolbar"
	$WPtoolbarProperties.focusable:=False:C215
	$WPtoolbarProperties.deletableInList:=False:C215
	$WPtoolbarProperties.doubleClickInRowAction:="editSubrecord"
	$WPtoolbarProperties.doubleClickInEmptyAreaAction:="addSubrecord"
	$WPtoolbarProperties.selectionMode:="multiple"
	$WPtoolbarProperties.printFrame:="variable"
	$pageDefinition.objects["WP_"+$dynamicSource.ident+"_toolbar"]:=$WPtoolbarProperties
	
Function _setDataSourceForDynamicPage()
	
	If (Form:C1466.hl_documents#Null:C1517) && (Is a list:C621(Form:C1466.hl_documents))
		CLEAR LIST:C377(Form:C1466.hl_documents; *)
	End if 
	
	If (Form:C1466.documentFolders=Null:C1517)
		Form:C1466.documentFolders:=ds:C1482.sfw_DocumentFolder.all().toCollection()
	End if 
	Form:C1466.documentsToDeleteOnServer:=Form:C1466.documentsToDeleteOnServer || New collection:C1472
	Form:C1466.documents:=ds:C1482.sfw_Document.query("UUID_target = :1 and Not(UUID in :2)"; Form:C1466.current_item.UUID; Form:C1466.documentsToDeleteOnServer.extract("UUID")).toCollection()
	
	This:C1470._showHideAreas()
	
	Form:C1466.hl_documents:=This:C1470._buildHLDocuments()
	//Form.hl_current_ref:=0
	This:C1470._reorganize()
	
	
Function _showHideAreas($showZone : Text)
	
	For each ($zone; Split string:C1554("pictPreview;pdfInWA;balisedText;dfdSubform;WP"; ";"))
		OBJECT SET VISIBLE:C603(*; $zone+"_"+This:C1470.ident+"@"; False:C215)
	End for each 
	If (Count parameters:C259>0)
		OBJECT SET VISIBLE:C603(*; $showZone+"_"+This:C1470.ident+"@"; True:C214)
	End if 
	
	
Function _buildHLDocuments($uuidParent : Text)->$refList : Integer
	
	$authorizedProfiles:=cs:C1710.sfw_userManager.me.authorizedProfiles
	
	If (Count parameters:C259=0)
		Form:C1466.hl_documents_refCounter:=0
		Form:C1466.nb_sfw_Documents:=0
		Form:C1466.documents:=ds:C1482.sfw_Document.query("UUID_target = :1 and Not(UUID in :2) order by name"; Form:C1466.current_item.UUID; Form:C1466.documentsToDeleteOnServer.extract("UUID")).toCollection("*, documentModel.*")
		Form:C1466.dfd_Documents:=ds:C1482.dfd_Document.query("UUID_target = :1 order by name"; Form:C1466.current_item.UUID).toCollection("*, template.*")
		$documentFolders:=Form:C1466.documentFolders.query("UUID_ParentFolder in :1"; [(16*"00"); 16*"20"; ""])
		$documents:=New collection:C1472
		$esDfdDocuments:=New collection:C1472
	Else 
		$documentFolders:=Form:C1466.documentFolders.query("UUID_ParentFolder = :1"; $uuidParent)
		$documents:=Form:C1466.documents.query("UUID_DocumentFolder = :1"; $uuidParent).orderBy("name")
		$esDfdDocuments:=Form:C1466.dfd_Documents.query("UUID_target = :1 and template.UUID_DocumentFolder = :2"; Form:C1466.current_item.UUID; $uuidParent).orderBy("name")
	End if 
	$documentFolders:=$documentFolders.orderBy("name")
	$refList:=New list:C375
	For each ($documentFolder; $documentFolders)
		If ($documentFolder.moreData.allowedProfiles#Null:C1517) && ($documentFolder.moreData.allowedProfiles.length>0)
			$displayingAllowed:=False:C215
			For each ($authorizedProfile; $authorizedProfiles)
				$displayingAllowed:=$displayingAllowed || ($documentFolder.moreData.allowedProfiles.indexOf($authorizedProfile)#-1)
			End for each 
		Else 
			$displayingAllowed:=True:C214
		End if 
		If ($displayingAllowed) && (($documentFolder.moreData.allowedEntries=Null:C1517) || ($documentFolder.moreData.allowedEntries.indexOf(Form:C1466.sfw.entry.ident)>=0))
			$sublist:=This:C1470._buildHLDocuments($documentFolder.UUID)
			If (Count list items:C380($sublist)=0)
				CLEAR LIST:C377($sublist; *)
				$sublist:=0
				$pict:=This:C1470.hl_icon_document["folder"]
			Else 
				$pict:=This:C1470.hl_icon_document["folderOpen"]
			End if 
			Form:C1466.hl_documents_refCounter+=1
			APPEND TO LIST:C376($refList; $documentFolder.name; Form:C1466.hl_documents_refCounter; $sublist; True:C214)
			SET LIST ITEM PARAMETER:C986($refList; Form:C1466.hl_documents_refCounter; "UUID"; $documentFolder.UUID)
			SET LIST ITEM PARAMETER:C986($refList; Form:C1466.hl_documents_refCounter; "kind"; "folder")
			SET LIST ITEM PROPERTIES:C386($refList; Form:C1466.hl_documents_refCounter; False:C215; Bold:K14:2)
			SET LIST ITEM ICON:C950($refList; Form:C1466.hl_documents_refCounter; $pict)
		End if 
	End for each 
	For each ($document; $documents)
		Form:C1466.nb_sfw_Documents+=1
		Form:C1466.hl_documents_refCounter+=1
		APPEND TO LIST:C376($refList; $document.name; Form:C1466.hl_documents_refCounter)
		SET LIST ITEM PARAMETER:C986($refList; Form:C1466.hl_documents_refCounter; Additional text:K28:7; String:C10($document.date; Internal date short:K1:7))
		SET LIST ITEM PARAMETER:C986($refList; Form:C1466.hl_documents_refCounter; "UUID"; $document.UUID)
		Case of 
			: ($document.extension=".pdf")
				$pict:=This:C1470.hl_icon_document["pdf"]
				SET LIST ITEM PARAMETER:C986($refList; Form:C1466.hl_documents_refCounter; "kind"; "document")
			: (Position:C15($document.extension; ".jpg;.png;.tiff")>0)
				$pict:=This:C1470.hl_icon_document["picture"]
				SET LIST ITEM PARAMETER:C986($refList; Form:C1466.hl_documents_refCounter; "kind"; "document")
			: (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($document.UUID_DocumentModel))) && ($document.documentModel.type=1)
				$pict:=This:C1470.hl_icon_document["text"]
				SET LIST ITEM PARAMETER:C986($refList; Form:C1466.hl_documents_refCounter; "kind"; "textDocument")
			: (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID($document.UUID_DocumentModel))) && ($document.documentModel.type=2)
				$pict:=This:C1470.hl_icon_document["write"]
				SET LIST ITEM PARAMETER:C986($refList; Form:C1466.hl_documents_refCounter; "kind"; "wpDocument")
			Else 
				$pict:=This:C1470.hl_icon_document["document"]
				SET LIST ITEM PARAMETER:C986($refList; Form:C1466.hl_documents_refCounter; "kind"; "document")
		End case 
		SET LIST ITEM ICON:C950($refList; Form:C1466.hl_documents_refCounter; $pict)
	End for each 
	For each ($eDfdDocument; $esDfdDocuments)
		Form:C1466.nb_sfw_Documents+=1
		Form:C1466.hl_documents_refCounter+=1
		APPEND TO LIST:C376($refList; $eDfdDocument.name; Form:C1466.hl_documents_refCounter)
		SET LIST ITEM PARAMETER:C986($refList; Form:C1466.hl_documents_refCounter; Additional text:K28:7; String:C10($eDfdDocument.date; Internal date short:K1:7))
		SET LIST ITEM PARAMETER:C986($refList; Form:C1466.hl_documents_refCounter; "UUID"; $eDfdDocument.UUID)
		SET LIST ITEM PARAMETER:C986($refList; Form:C1466.hl_documents_refCounter; "kind"; "dfdDocument")
		$pict:=This:C1470.hl_icon_document["dfd"]
		SET LIST ITEM ICON:C950($refList; Form:C1466.hl_documents_refCounter; $pict)
	End for each 
	
	If (Count parameters:C259=0)
		This:C1470.redrawHTab()
	End if 
	
Function redrawHTab()
	If (This:C1470.options.showCountInTab)
		Use (This:C1470.panelPage)
			If (Form:C1466.nb_sfw_Documents>0)
				This:C1470.panelPage.extraLabel:=" ["+String:C10(Form:C1466.nb_sfw_Documents)+"]"
			Else 
				This:C1470.panelPage.extraLabel:=""
			End if 
		End use 
		Form:C1466.sfw.drawHTab()
	End if 
	
Function refreshHTab()
	If (This:C1470.options.showCountInTab)
		Form:C1466.nb_sfw_Documents:=ds:C1482.sfw_Document.query("UUID_target = :1"; Form:C1466.current_item.UUID).length
		Form:C1466.nb_sfw_Documents+=ds:C1482.dfd_Document.query("UUID_target = :1"; Form:C1466.current_item.UUID).length
		This:C1470.redrawHTab()
	End if 
	
Function _bAction()
	
	$authorizedProfiles:=cs:C1710.sfw_userManager.me.authorizedProfiles
	
	$refMenus:=New collection:C1472
	$refMenu:=Create menu:C408
	$refMenus.push($refMenu)
	
	APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("pagedocument.uploadfile"); *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--upload")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/menu/upload.png")
	If (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.hl_current_ref#0) && (Form:C1466.hl_current_kind="folder") && (Not:C34(Bool:C1537(Form:C1466.eFolder.moreData.dontUpload)))
	Else 
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	Form:C1466.hl_current_uuid:=Form:C1466.hl_current_uuid || ""
	$refSubMenu:=Create menu:C408
	$refMenus.push($refSubMenu)
	$esModels:=ds:C1482.sfw_DocumentModel.query("UUID_DocumentFolder = :1 order by name"; Form:C1466.hl_current_uuid)
	For ($type; 1; 2)
		$firstItem:=$type#1
		For each ($eModel; $esModels)
			If ($eModel.type=$type)
				$propose:=True:C214
				Case of 
					: ($eModel.moreData.allowedProfiles=Null:C1517) && (($eModel.moreData.allowedEntries=Null:C1517) || ($eModel.moreData.allowedEntries.indexOf(Form:C1466.sfw.entry.ident)>=0))
					: ($eModel.moreData.allowedProfiles#Null:C1517) && (($eModel.moreData.allowedEntries=Null:C1517) || ($eModel.moreData.allowedEntries.indexOf(Form:C1466.sfw.entry.ident)>=0))
						$propose:=False:C215
						For each ($authorizedProfile; $authorizedProfiles)
							$propose:=$propose || ($eModel.moreData.allowedProfiles.indexOf($authorizedProfile)#-1)
						End for each 
					Else 
						$propose:=False:C215
				End case 
				
				If ($propose)
					If ($firstItem)
						APPEND MENU ITEM:C411($refSubMenu; "-")
					End if 
					APPEND MENU ITEM:C411($refSubMenu; $eModel.name; *)
					Case of 
						: ($eModel.type=1)
							SET MENU ITEM ICON:C984($refSubMenu; -1; "Path:/RESOURCES/sfw/image/menu/text.png")
						: ($eModel.type=2)
							SET MENU ITEM ICON:C984($refSubMenu; -1; "Path:/RESOURCES/sfw/image/menu/write.png")
					End case 
					SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--useModel:"+$eModel.UUID)
				End if 
			End if 
		End for each 
	End for 
	APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("pagedocument.adddocmodel"); $refSubMenu; *)
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/menu/plus-circle.png")
	If (Count menu items:C405($refSubMenu)#0) && (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.hl_current_ref#0) && (Form:C1466.hl_current_kind="folder")
	Else 
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	
	If (OB Entries:C1720(ds:C1482).indices("key = :1"; "dfd_@").length>0)
		
		$refSubMenu:=Create menu:C408
		$refMenus.push($refSubMenu)
		$esTemplates:=ds:C1482.dfd_Template.query("UUID_DocumentFolder = :1 order by name"; Form:C1466.hl_current_uuid)
		For each ($eTemplate; $esTemplates)
			$propose:=True:C214
			Case of 
				: ($eTemplate.moreData.allowedProfiles=Null:C1517) && (($eTemplate.moreData.allowedEntries=Null:C1517) || ($eTemplate.moreData.allowedEntries.indexOf(Form:C1466.sfw.entry.ident)>=0))
				: ($eTemplate.moreData.allowedProfiles#Null:C1517) && (($eTemplate.moreData.allowedEntries=Null:C1517) || ($eTemplate.moreData.allowedEntries.indexOf(Form:C1466.sfw.entry.ident)>=0))
					$propose:=False:C215
					For each ($authorizedProfile; $authorizedProfiles)
						$propose:=$propose || ($eTemplate.moreData.allowedProfiles.indexOf($authorizedProfile)#-1)
					End for each 
				Else 
					$propose:=False:C215
			End case 
			
			If ($propose)
				APPEND MENU ITEM:C411($refSubMenu; $eTemplate.name; *)  // XLIFF
				SET MENU ITEM ICON:C984($refSubMenu; -1; "Path:/RESOURCES/sfw/image/menu/dfd.png")
				SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "--useDfdTemplate:"+$eTemplate.UUID)
			End if 
		End for each 
		APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("pagedocument.adddynamicdoc"); $refSubMenu; *)
		SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/menu/document-template.png")
		If (Count menu items:C405($refSubMenu)#0) && (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.hl_current_ref#0) && (Form:C1466.hl_current_kind="folder")
		Else 
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
	End if 
	
	APPEND MENU ITEM:C411($refMenu; "-")
	
	APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("pagedocument.rename"); *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--rename")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/menu/pencil.png")
	If (Form:C1466.hl_current_kind="folder")
		DISABLE MENU ITEM:C150($refMenu; -1)
	Else 
		If (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.hl_current_ref#0) && (Form:C1466.hl_current_kind="@document")
		Else 
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
	End if 
	
	APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("pagedocument.delete"); *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--delete")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/menu/minus-circle.png")
	If (Form:C1466.hl_current_kind="folder")
		DISABLE MENU ITEM:C150($refMenu; -1)
	Else 
		If (Form:C1466.sfw.checkIsInModification()) && (Form:C1466.hl_current_ref#0) && ((Form:C1466.hl_current_kind="document") || (Form:C1466.hl_current_kind="textDocument") || (Form:C1466.hl_current_kind="wpDocument"))
		Else 
			DISABLE MENU ITEM:C150($refMenu; -1)
		End if 
	End if 
	
	APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("pagedocument.download"); *)
	SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--download")
	SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/menu/download.png")
	If (Form:C1466.hl_current_kind="folder") || (Form:C1466.hl_current_kind="textDocument")
		DISABLE MENU ITEM:C150($refMenu; -1)
	End if 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	For each ($refMenu; $refMenus)
		RELEASE MENU:C978($refMenu)
	End for each 
	
	Case of 
		: ($choose="--upload")
			This:C1470._uploadFile()
			
		: ($choose="--download")
			This:C1470._downloadFile()
			
		: ($choose="--delete")
			This:C1470._deleteDocument()
			
		: ($choose="--rename")
			This:C1470._renameDocument()
			
		: ($choose="--useDfdTemplate:@")
			Form:C1466.templateToUseUUID:=Split string:C1554($choose; ":").pop()
			This:C1470._useDfdTemplate()
			
		: ($choose="--useModel:@")
			Form:C1466.modelToUseUUID:=Split string:C1554($choose; ":").pop()
			This:C1470._useModel()
			
			
	End case 
	
	
Function _hl_document()
	
	This:C1470._load_hl_item_properties(1)
	
	Case of 
		: (FORM Event:C1606.code=On Clicked:K2:4) && (Right click:C712)
			This:C1470._bAction()
			
		: (FORM Event:C1606.code=On Clicked:K2:4)
			
	End case 
	
Function _load_hl_item_properties($option : Integer)
	var $refItem : Integer
	var $textItem : Text
	var $sublist : Integer
	var $uuid : Text
	var $kind : Text
	
	GET LIST ITEM:C378(Form:C1466.hl_documents; *; $refItem; $textItem; $sublist; $expanded)
	Form:C1466.lb_properties:=New collection:C1472
	If ($refItem#0) && (($refItem#Form:C1466.hl_current_ref) || (Count parameters:C259>0))
		Form:C1466.hl_current_ref:=$refItem
		Form:C1466.hl_current_text:=$textItem
		Form:C1466.hl_current_sublist:=$sublist
		$test:=Is a list:C621($subList)
		GET LIST ITEM PARAMETER:C985(Form:C1466.hl_documents; Form:C1466.hl_current_ref; "UUID"; $uuid)
		Form:C1466.hl_current_uuid:=$uuid
		GET LIST ITEM PARAMETER:C985(Form:C1466.hl_documents; Form:C1466.hl_current_ref; "kind"; $kind)
		Form:C1466.hl_current_kind:=$kind
		This:C1470._showHideAreas()
		
		Case of 
			: (Form:C1466.hl_current_kind="document")
				Form:C1466.eDocument:=ds:C1482.sfw_Document.get(Form:C1466.hl_current_uuid)
				This:C1470._displayUploadedFile(Form:C1466.eDocument)
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.filename"); value: Form:C1466.eDocument.name})
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.extension"); value: Form:C1466.eDocument.extension})
				$size:=cs:C1710.sfw_bytes.me.getBestFormat(Form:C1466.eDocument.moreData.fileInfo.size)
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.size"); value: $size})
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.creationdate"); value: String:C10(Form:C1466.eDocument.moreData.fileInfo.creationDate; Internal date short:K1:7)})
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.creationtime"); value: String:C10(Time:C179(Form:C1466.eDocument.moreData.fileInfo.creationTime); HH MM SS:K7:1)})
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.modifdate"); value: String:C10(Form:C1466.eDocument.moreData.fileInfo.modificationDate; Internal date short:K1:7)})
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.modiftime"); value: String:C10(Time:C179(Form:C1466.eDocument.moreData.fileInfo.modificationTime); HH MM SS:K7:1)})
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.addedby"); value: Form:C1466.eDocument.user.fullName})
				
			: (Form:C1466.hl_current_kind="textDocument")
				Form:C1466.eDocument:=ds:C1482.sfw_Document.get(Form:C1466.hl_current_uuid)
				This:C1470._displayDocument(Form:C1466.eDocument)
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.name"); value: Form:C1466.eDocument.name})
				$size:=String:C10(Length:C16(Form:C1466.eDocument.moreData.balisedText))+ds:C1482.sfw_readXliff("pagedocument.chars")
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.size"); value: $size})
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.creationdate"); value: String:C10(cs:C1710.sfw_stmp.me.getDate(Form:C1466.eDocument.stmp); Internal date short:K1:7)})
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.creationtime"); value: String:C10(cs:C1710.sfw_stmp.me.getTime(Form:C1466.eDocument.stmp); HH MM SS:K7:1)})
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.addedby"); value: Form:C1466.eDocument.user.fullName})
				
				
			: (Form:C1466.hl_current_kind="wpDocument")
				Form:C1466.eDocument:=ds:C1482.sfw_Document.get(Form:C1466.hl_current_uuid)
				This:C1470._displayDocument(Form:C1466.eDocument)
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.name"); value: Form:C1466.eDocument.name})
				
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.creationdate"); value: String:C10(cs:C1710.sfw_stmp.me.getDate(Form:C1466.eDocument.stmp); Internal date short:K1:7)})
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.creationtime"); value: String:C10(cs:C1710.sfw_stmp.me.getTime(Form:C1466.eDocument.stmp); HH MM SS:K7:1)})
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.addedby"); value: Form:C1466.eDocument.user.fullName})
				GOTO OBJECT:C206(*; "WP_"+This:C1470.ident+"_area")
				
			: (Form:C1466.hl_current_kind="folder")
				Form:C1466.eFolder:=ds:C1482.sfw_DocumentFolder.get(Form:C1466.hl_current_uuid)
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.foldername"); value: Form:C1466.hl_current_text})
				$nbSubFolders:=ds:C1482.sfw_DocumentFolder.query("UUID_ParentFolder = :1"; Form:C1466.hl_current_uuid).length
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.nbsubfolders"); value: String:C10($nbSubFolders; "###,##0;;-")})
				$nbDocuments:=Form:C1466.documents.query("UUID_DocumentFolder = :1"; Form:C1466.hl_current_uuid).length+Form:C1466.dfd_Documents.query("template.UUID_DocumentFolder = :1"; Form:C1466.hl_current_uuid).length
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.nbdoc"); value: String:C10($nbDocuments; "###0##0; ; -")})
				
			: (Form:C1466.hl_current_kind="dfdDocument")
				This:C1470._displayDfdDocument()
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.name"); value: Form:C1466.eDfdDocument.name})
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.creationdate"); value: String:C10(cs:C1710.sfw_stmp.me.getDate(Form:C1466.eDfdDocument.stmp || 0); Internal date short:K1:7)})
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.creationtime"); value: String:C10(cs:C1710.sfw_stmp.me.getTime(Form:C1466.eDfdDocument.stmp || 0); HH MM SS:K7:1)})
				Form:C1466.lb_properties.push({property: ds:C1482.sfw_readXliff("pagedocument.addedby"); value: Form:C1466.eDfdDocument.user.fullName})
				
				
		End case 
	End if 
	
Function _uploadFile()
	var $file : 4D:C1709.File
	ARRAY TEXT:C222($_file; 0)
	$fileSelected:=Select document:C905(7638; ""; "Select the file to upload"; Use sheet window:K24:11; $_file)
	If (ok=1) && (Size of array:C274($_file)>0)
		$file:=File:C1566($_file{1}; fk platform path:K87:2)
		
		$uuid_folder:=Form:C1466.hl_current_uuid
		
		$eDocument:=ds:C1482.sfw_Document.new()
		$eDocument.UUID:=Generate UUID:C1066
		$eDocument.UUID_DocumentFolder:=$uuid_folder
		$eDocument.UUID_target:=Form:C1466.current_item.UUID
		$eDocument.UUID_User:=cs:C1710.sfw_userManager.me.info.UUID
		$eDocument.name:=$file.name
		$eDocument.extension:=$file.extension
		$eDocument.stmp:=cs:C1710.sfw_stmp.me.now()
		$eDocument.moreData:=New object:C1471
		$eDocument.moreData.originalPathOnClient:=$file.platformPath
		$info:=$eDocument.save()
		Form:C1466.nb_sfw_Documents+=1
		Form:C1466.documentsToUpLoadOnServer:=Form:C1466.documentsToUpLoadOnServer || New collection:C1472
		Form:C1466.documentsToUpLoadOnServer.push($eDocument)
		
		If (Form:C1466.hl_current_sublist=0)
			Form:C1466.hl_current_sublist:=New list:C375
			SET LIST ITEM:C385(Form:C1466.hl_documents; Form:C1466.hl_current_ref; Form:C1466.hl_current_text; Form:C1466.hl_current_ref; Form:C1466.hl_current_sublist; True:C214)
		End if 
		
		Form:C1466.hl_documents_refCounter+=1
		APPEND TO LIST:C376(Form:C1466.hl_current_sublist; $eDocument.name; Form:C1466.hl_documents_refCounter)
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_current_sublist; Form:C1466.hl_documents_refCounter; "UUID"; $eDocument.UUID)
		SET LIST ITEM PARAMETER:C986(Form:C1466.hl_current_sublist; Form:C1466.hl_documents_refCounter; "kind"; "document")
		$pict:=This:C1470.hl_icon_document["document"]
		SET LIST ITEM ICON:C950(Form:C1466.hl_current_sublist; Form:C1466.hl_documents_refCounter; $pict)
		SORT LIST:C391(Form:C1466.hl_current_sublist)
		SELECT LIST ITEMS BY REFERENCE:C630(Form:C1466.hl_documents; Form:C1466.hl_documents_refCounter)
		
		Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
		
		This:C1470._displayUploadedFile($eDocument)
		This:C1470.redrawHTab()
		
	End if 
	
	
	
Function _downloadFile()
	var $blob : 4D:C1709.Blob
	var $picture : Picture
	
	Case of 
		: (Form:C1466.hl_current_kind="document")
			If (Form:C1466.eDocument#Null:C1517)
				Case of 
					: (Form:C1466.eDocument.moreData.fileInfo#Null:C1517)
						$blob:=Form:C1466.eDocument.getStoredBlob()
						BLOB TO PICTURE:C682($blob; $picture; Form:C1466.eDocument.moreData.fileInfo.extension)
						ARRAY TEXT:C222($_file; 0)
						$fileName:=Select document:C905(Form:C1466.eDocument.moreData.fileInfo.fullName; Form:C1466.eDocument.moreData.fileInfo.extension; "Download the file:"; File name entry:K24:17+Use sheet window:K24:11; $_file)
						If (ok=1) & (Size of array:C274($_file)>0)
							$filePath:=$_file{1}
							WRITE PICTURE FILE:C680($filePath; $picture; Form:C1466.eDocument.moreData.fileInfo.extension)
						End if 
				End case 
				
			End if 
			
		: (Form:C1466.eDfdDocument#Null:C1517)
			$fileName:=Select document:C905(Form:C1466.eDfdDocument.name; ".pdf"; "Download the file:"; File name entry:K24:17+Use sheet window:K24:11; $_file)
			
	End case 
	
Function _deleteDocument()
	Case of 
		: (Form:C1466.hl_current_kind="document")
			If (Form:C1466.eDocument#Null:C1517)
				Form:C1466.documentsToDeleteOnServer:=Form:C1466.documentsToUpLoadOnServer || New collection:C1472
				Form:C1466.documentsToDeleteOnServer.push(Form:C1466.eDocument)
				Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
				Form:C1466.hl_documents:=This:C1470._buildHLDocuments()
				Form:C1466.nb_sfw_Documents-=1
				This:C1470.redrawHTab()
			End if 
		: (Form:C1466.hl_current_kind="textDocument") || (Form:C1466.hl_current_kind="wpDocument")
			If (Form:C1466.eDocument#Null:C1517)
				$info:=Form:C1466.eDocument.drop()
				Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
				Form:C1466.hl_documents:=This:C1470._buildHLDocuments()
				Form:C1466.nb_sfw_Documents-=1
				This:C1470.redrawHTab()
			End if 
			
		: (Form:C1466.hl_current_kind="dfdDocument")
			If (Form:C1466.eDfdDocument#Null:C1517)
				Form:C1466.eDfdDocument.drop()
				Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
				Form:C1466.hl_documents:=This:C1470._buildHLDocuments()
				Form:C1466.nb_sfw_Documents-=1
				This:C1470.redrawHTab()
			End if 
	End case 
	Form:C1466.hl_documents:=This:C1470._buildHLDocuments()
	This:C1470._load_hl_item_properties(1)
	
Function _renameDocument()
	Case of 
		: (Form:C1466.hl_current_kind="document")
			If (Form:C1466.eDocument#Null:C1517)
				$answer:=cs:C1710.sfw_dialog.me.request(ds:C1482.sfw_readXliff("pagedocument.newnamedoc"); Form:C1466.hl_current_text; ds:C1482.sfw_readXliff("pagedocument.rename"); ds:C1482.sfw_readXliff("pagedocument.cancel"); "trimSpace"; "notEmpty")
				If ($answer.ok)
					Form:C1466.eDocument.name:=$answer.answer
					$info:=Form:C1466.eDocument.save()
					Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
					Form:C1466.hl_documents:=This:C1470._buildHLDocuments()
				End if 
			End if 
		: (Form:C1466.hl_current_kind="dfdDocument")
			If (Form:C1466.eDfdDocument#Null:C1517)
				$answer:=cs:C1710.sfw_dialog.me.request(ds:C1482.sfw_readXliff("pagedocument.newnamedoc"); Form:C1466.hl_current_text; ds:C1482.sfw_readXliff("pagedocument.rename"); ds:C1482.sfw_readXliff("pagedocument.cancel"); "trimSpace"; "notEmpty")
				If ($answer.ok)
					Form:C1466.eDfdDocument.name:=$answer.answer
					$info:=Form:C1466.eDfdDocument.save()
					Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
					Form:C1466.hl_documents:=This:C1470._buildHLDocuments()
				End if 
			End if 
	End case 
	
Function _useDfdTemplate()
	var $eDfdDocument : cs:C1710.dfd_DocumentEntity
	var $eDfdTemplate : cs:C1710.dfd_TemplateEntity
	
	$eDfdTemplate:=ds:C1482.dfd_Template.get(Form:C1466.templateToUseUUID)
	$data:=New object:C1471
	
	If ($eDfdTemplate.moreData.documentPrecalculationMethod#Null:C1517)
		$method:="<!--#4DCODE \r"
		$method+="$data:=$1 \r"
		$method+=$eDfdTemplate.moreData.documentPrecalculationMethod
		$method+="\r-->"
		ds:C1482.startTransaction()
		PROCESS 4D TAGS:C816($method; $result; $data)
		ds:C1482.cancelTransaction()
		
	End if 
	If ($eDfdTemplate.moreData.documentNameFormula#Null:C1517)
		$expressionDocument:=Replace string:C233($eDfdTemplate.moreData.documentNameFormula; "$data"; "$1")
		$documentName:=Formula from string:C1601($expressionDocument).call(Form:C1466.current_item; $data)
	Else 
		$documentName:=$eDfdTemplate.name+"-"+String:C10(Current date:C33)
	End if 
	
	$eDfdDocument:=ds:C1482.dfd_Document.buildFromTemplate($documentName; $eDfdTemplate; $data; "save")
	$eDfdDocument.UUID_target:=Form:C1466.current_item.UUID
	$info:=$eDfdDocument.save()
	
	If (Form:C1466.hl_current_sublist=0)
		Form:C1466.hl_current_sublist:=New list:C375
		SET LIST ITEM:C385(Form:C1466.hl_documents; Form:C1466.hl_current_ref; Form:C1466.hl_current_text; Form:C1466.hl_current_ref; Form:C1466.hl_current_sublist; True:C214)
	End if 
	
	Form:C1466.hl_documents_refCounter+=1
	$label:=$eDfdDocument.name
	$subList:=Form:C1466.hl_current_sublist
	$test:=Is a list:C621($subList)
	APPEND TO LIST:C376($subList; $label; Form:C1466.hl_documents_refCounter)
	SET LIST ITEM PARAMETER:C986($subList; Form:C1466.hl_documents_refCounter; "UUID"; $eDfdDocument.UUID)
	SET LIST ITEM PARAMETER:C986($subList; Form:C1466.hl_documents_refCounter; "kind"; "dfdDocument")
	$pict:=This:C1470.hl_icon_document["dfd"]
	SET LIST ITEM ICON:C950($subList; Form:C1466.hl_documents_refCounter; $pict)
	SORT LIST:C391($subList)
	SELECT LIST ITEMS BY REFERENCE:C630(Form:C1466.hl_documents; Form:C1466.hl_documents_refCounter)
	
	This:C1470._load_hl_item_properties()
	
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	Form:C1466.nb_sfw_Documents+=1
	This:C1470.redrawHTab()
	
	
Function _useModel()
	var $eDocument : cs:C1710.sfw_DocumentEntity
	var $eModel : cs:C1710.sfw_DocumentModelEntity
	
	$eModel:=ds:C1482.sfw_DocumentModel.get(Form:C1466.modelToUseUUID)
	$data:=New object:C1471
	
	If ($eModel.moreData.documentPrecalculationMethod#Null:C1517)
		$method:="<!--#4DCODE \r"
		$method+="$data:=$1 \r"
		$method+=$eModel.moreData.documentPrecalculationMethod
		$method+="\r-->"
		ds:C1482.startTransaction()
		PROCESS 4D TAGS:C816($method; $result; $data)
		ds:C1482.cancelTransaction()
		
	End if 
	If ($eModel.moreData.documentNameFormula#Null:C1517)
		$expressionDocument:=Replace string:C233($eModel.moreData.documentNameFormula; "$data"; "$1")
		$documentName:=Formula from string:C1601($expressionDocument).call(Form:C1466.current_item; $data)
	Else 
		$documentName:=$eModel.name+"-"+String:C10(Current date:C33)
	End if 
	
	$eDocument:=ds:C1482.sfw_Document.new()
	$eDocument.name:=$documentName
	$eDocument.UUID_DocumentModel:=$eModel.UUID
	$eDocument.UUID_DocumentFolder:=Form:C1466.hl_current_uuid
	$eDocument.UUID_target:=Form:C1466.current_item.UUID
	$eDocument.UUID_User:=cs:C1710.sfw_userManager.me.info.UUID
	$eDocument.stmp:=cs:C1710.sfw_stmp.me.now()
	$eDocument.moreData:=New object:C1471
	
	Case of 
		: ($eModel.type=1)  //balized text
			$model:=$eModel.moreData.balisedTextModel
			$model:=Replace string:C233($model; "$data"; "$1")
			$model:=Replace string:C233($model; "\\t"; "\t")
			$model:=Replace string:C233($model; "\\r"; "\r")
			$model:=Replace string:C233($model; "\\n"; "\n")
			PROCESS 4D TAGS:C816($model; $result; $data)
			$eDocument.moreData.balisedText:=$result
			$kind:="textDocument"
			$icon:="text"
		: ($eModel.type=2)  //4D Write Pro
			$eDocument.moreData.wpContextData:=$data
			$eDocument.area:=$eModel.area
			$kind:="wpDocument"
			$icon:="write"
			
			
	End case 
	$info:=$eDocument.save()
	
	If (Form:C1466.hl_current_sublist=0)
		Form:C1466.hl_current_sublist:=New list:C375
		SET LIST ITEM:C385(Form:C1466.hl_documents; Form:C1466.hl_current_ref; Form:C1466.hl_current_text; Form:C1466.hl_current_ref; Form:C1466.hl_current_sublist; True:C214)
	End if 
	
	Form:C1466.hl_documents_refCounter+=1
	$label:=$eDocument.name
	$subList:=Form:C1466.hl_current_sublist
	$test:=Is a list:C621($subList)
	APPEND TO LIST:C376($subList; $label; Form:C1466.hl_documents_refCounter)
	SET LIST ITEM PARAMETER:C986($subList; Form:C1466.hl_documents_refCounter; "UUID"; $eDocument.UUID)
	SET LIST ITEM PARAMETER:C986($subList; Form:C1466.hl_documents_refCounter; "kind"; $kind)
	SET LIST ITEM PARAMETER:C986($subList; Form:C1466.hl_documents_refCounter; Additional text:K28:7; String:C10($eDocument.date; Internal date short:K1:7))
	SORT LIST:C391($subList)
	$pict:=This:C1470.hl_icon_document[$icon]
	SET LIST ITEM ICON:C950($subList; Form:C1466.hl_documents_refCounter; $pict)
	SELECT LIST ITEMS BY REFERENCE:C630(Form:C1466.hl_documents; Form:C1466.hl_documents_refCounter)
	
	This:C1470._load_hl_item_properties()
	
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID
	Form:C1466.nb_sfw_Documents+=1
	This:C1470.redrawHTab()
	
	
Function _displayUploadedFile($eDocument : cs:C1710.sfw_DocumentEntity)
	var $content : 4D:C1709.Blob
	var $pict : Picture
	If (Form:C1466.eDocument#Null:C1517)
		Case of 
			: (Form:C1466.eDocument.moreData.fileInfo#Null:C1517) && (Form:C1466.eDocument.moreData.fileInfo.extension=".pdf")
				$content:=Form:C1466.eDocument.getStoredBlob()
				If ($content#Null:C1517)
					$folder:=Temporary folder:C486
					$file:=Folder:C1567($folder; fk platform path:K87:2).file(Form:C1466.eDocument.UUID+".pdf")
					//If ($file.exists)
					$file.setContent($content)
					$path:=Replace string:C233($file.platformPath; Folder separator:K24:12; "/")
					
					Case of 
						: (Is Windows:C1573)
							$path:="file:///"+$path
						: (Is macOS:C1572)
							$path:="file:///Volumes/"+Replace string:C233($path; " "; "%20")
					End case 
					
					This:C1470._showHideAreas("pdfInWA")
					OBJECT GET COORDINATES:C663(*; "pdfInWA_"+This:C1470.ident; $g; $h; $d; $b)
					OBJECT GET SUBFORM CONTAINER SIZE:C1148($width; $height)
					OBJECT SET COORDINATES:C1248(*; "pdfInWA_"+This:C1470.ident; $g; $h; $width; $height)
					
					WA OPEN URL:C1020(*; "pdfInWA_"+This:C1470.ident; $path)
					//End if 
				End if 
			: (Form:C1466.eDocument.moreData.fileInfo#Null:C1517)
				$content:=Form:C1466.eDocument.getStoredBlob()
				BLOB TO PICTURE:C682($content; $pict; Form:C1466.eDocument.moreData.fileInfo.extension)
				Form:C1466.document_pictPreview:=$pict
				This:C1470._showHideAreas("pictPreview")
				OBJECT GET COORDINATES:C663(*; "pictPreview_"+This:C1470.ident; $g; $h; $d; $b)
				OBJECT GET SUBFORM CONTAINER SIZE:C1148($width; $height)
				OBJECT SET COORDINATES:C1248(*; "pictPreview_"+This:C1470.ident; $g; $h; $width; $height)
				
			: (Form:C1466.eDocument.moreData.originalPathOnClient#Null:C1517)
				READ PICTURE FILE:C678(Form:C1466.eDocument.moreData.originalPathOnClient; $pict)
				Form:C1466.document_pictPreview:=$pict
				This:C1470._showHideAreas("pictPreview")
				OBJECT GET COORDINATES:C663(*; "pictPreview_"+This:C1470.ident; $g; $h; $d; $b)
				OBJECT GET SUBFORM CONTAINER SIZE:C1148($width; $height)
				OBJECT SET COORDINATES:C1248(*; "pictPreview_"+This:C1470.ident; $g; $h; $width; $height)
			Else 
		End case 
	Else 
		Form:C1466.document_pictPreview:=$pict
	End if 
	
	
Function _displayDocument($eDocument : cs:C1710.sfw_DocumentEntity)
	If (Form:C1466.eDocument#Null:C1517)
		Case of 
			: (Form:C1466.eDocument.documentModel.type=1)  //balised text
				Form:C1466.document_balisedText:=Form:C1466.eDocument.moreData.balisedText
				This:C1470._showHideAreas("balisedText")
				
			: (Form:C1466.eDocument.documentModel.type=2)  //4D Write Pro
				$context:=Form:C1466.eDocument.moreData.wpContextData || New object:C1471
				WP SET DATA CONTEXT:C1786(Form:C1466.eDocument.area; $context)
				This:C1470._showHideAreas("WP")
				
		End case 
	End if 
	
	
Function _displayDfdDocument()
	var $formName : Text
	var $formDefinition : Object
	
	Form:C1466.eDfdDocument:=ds:C1482.dfd_Document.get(Form:C1466.hl_current_uuid)
	This:C1470._showHideAreas("dfdSubform")
	//OBJECT SET SUBFORM(*; "dfdSubform_"+This.ident; "zz4Colors")
	Form:C1466.dfd_context:=New object:C1471()
	
	Form:C1466.dfd_context.zoom:=75
	Form:C1466.dfd_context.portrait:=1
	Form:C1466.dfd_context.rulers:=0
	Form:C1466.dfd_context.landscape:=0
	Form:C1466.dfd_context.paper:=New object:C1471
	Form:C1466.dfd_context.paper.formats:=ds:C1482.dfd_Line.getFormatPapers()
	Form:C1466.dfd_context.paper.format:="A4"
	
	Form:C1466.dfd_context.document:=Form:C1466.eDfdDocument
	
	cs:C1710.dfd_panel_document.me.redraw_preview(Form:C1466.dfd_context; "--subform")
	$formName:="dfdSubform_"+This:C1470.ident
	$formDefinition:=Form:C1466.dfd_context.formDefinition
	OBJECT SET SUBFORM:C1138(*; $formName; $formDefinition)
	
	
Function _reorganize()
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($width; $height)
	$verticalSplit:=$width\4
	$verticalSplit:=($verticalSplit>300) ? ($verticalSplit<600) ? $verticalSplit : 600 : 300
	
	$heightProperties:=$height\3
	$heightProperties:=($heightProperties>150) ? ($heightProperties<300) ? $heightProperties : 300 : 150
	
	OBJECT SET COORDINATES:C1248(*; "bkgd_hl_"+This:C1470.ident; This:C1470.offsetHorizontal-1; This:C1470.offsetVertical-1; $verticalSplit; $height-$heightProperties)
	OBJECT GET COORDINATES:C663(*; "bAction_"+This:C1470.ident; $g; $h; $d; $b)
	OBJECT SET COORDINATES:C1248(*; "bAction_"+This:C1470.ident; This:C1470.offsetHorizontal+This:C1470.gutter; $height-$heightProperties-This:C1470.gutter-$b+$h; This:C1470.offsetHorizontal+This:C1470.gutter+$d-$g; $height-$heightProperties-This:C1470.gutter)
	OBJECT SET COORDINATES:C1248(*; "hl_"+This:C1470.ident; This:C1470.offsetHorizontal; This:C1470.offsetVertical+1; $verticalSplit; $height-$heightProperties-This:C1470.gutter-$b+$h-This:C1470.gutter)
	OBJECT SET COORDINATES:C1248(*; "bkgd_properties_"+This:C1470.ident; This:C1470.offsetHorizontal-1; $height-$heightProperties-1; $verticalSplit; $height+1)
	OBJECT GET COORDINATES:C663(*; "title_properties_"+This:C1470.ident; $g; $h; $d; $b)
	OBJECT SET COORDINATES:C1248(*; "title_properties_"+This:C1470.ident; This:C1470.offsetHorizontal+This:C1470.gutter; $height-$heightProperties+This:C1470.gutter; This:C1470.offsetHorizontal+This:C1470.gutter+$d-$g; $height-$heightProperties+This:C1470.gutter+$b-$h)
	OBJECT SET COORDINATES:C1248(*; "lb_properties_"+This:C1470.ident; This:C1470.offsetHorizontal+This:C1470.gutter; $height-$heightProperties+This:C1470.gutter+16+This:C1470.gutter; $verticalSplit-This:C1470.gutter; $height-This:C1470.gutter)
	OBJECT SET COORDINATES:C1248(*; "pictPreview_"+This:C1470.ident; $verticalSplit; This:C1470.offsetVertical; $width; $height)
	OBJECT SET COORDINATES:C1248(*; "pdfInWA_"+This:C1470.ident; $verticalSplit; This:C1470.offsetVertical; $width; $height)
	OBJECT SET COORDINATES:C1248(*; "balisedText_"+This:C1470.ident; $verticalSplit+This:C1470.gutter; This:C1470.offsetVertical+This:C1470.gutter; $width-This:C1470.gutter; $height-This:C1470.gutter)
	OBJECT SET COORDINATES:C1248(*; "dfdSubform_"+This:C1470.ident; $verticalSplit; This:C1470.offsetVertical+This:C1470.heightDfdButton+This:C1470.gutter+This:C1470.gutter; $width; $height)
	OBJECT SET COORDINATES:C1248(*; "dfdSubform_"+This:C1470.ident+"_bkgd"; $verticalSplit; This:C1470.offsetVertical+This:C1470.heightDfdButton+This:C1470.gutter+This:C1470.gutter; $width; $height)
	OBJECT SET COORDINATES:C1248(*; "dfdSubform_"+This:C1470.ident+"_ddPage"; $verticalSplit+This:C1470.gutter; This:C1470.offsetVertical+This:C1470.gutter+This:C1470.gutter; $verticalSplit+This:C1470.gutter+132; This:C1470.offsetVertical+This:C1470.gutter+This:C1470.gutter+21)
	OBJECT SET COORDINATES:C1248(*; "dfdSubform_"+This:C1470.ident+"_bRuler"; $width-This:C1470.gutter-This:C1470.heightDfdButton; This:C1470.offsetVertical+This:C1470.gutter; $width-This:C1470.gutter; This:C1470.offsetVertical+This:C1470.gutter+This:C1470.heightDfdButton)
	OBJECT SET COORDINATES:C1248(*; "dfdSubform_"+This:C1470.ident+"_bPDF"; $width-This:C1470.gutter-This:C1470.heightDfdButton-This:C1470.gutter-This:C1470.heightDfdButton; This:C1470.offsetVertical+This:C1470.gutter; $width-This:C1470.gutter-This:C1470.gutter-This:C1470.heightDfdButton; This:C1470.offsetVertical+This:C1470.gutter+This:C1470.heightDfdButton)
	OBJECT SET COORDINATES:C1248(*; "dfdSubform_"+This:C1470.ident+"_bPrint"; $width-This:C1470.gutter-This:C1470.heightDfdButton-This:C1470.gutter-This:C1470.heightDfdButton-This:C1470.gutter-This:C1470.heightDfdButton; This:C1470.offsetVertical+This:C1470.gutter; $width-This:C1470.gutter-This:C1470.gutter-This:C1470.heightDfdButton-This:C1470.gutter-This:C1470.heightDfdButton; This:C1470.offsetVertical+This:C1470.gutter+This:C1470.heightDfdButton)
	OBJECT SET COORDINATES:C1248(*; "dfdSubform_"+This:C1470.ident+"_ruler"; $width-(This:C1470.gutter*6)-(This:C1470.heightDfdButton*4)-210; This:C1470.offsetVertical+This:C1470.gutter; $width-(This:C1470.gutter*6)-(This:C1470.heightDfdButton*4); This:C1470.offsetVertical+This:C1470.gutter+21)
	
	OBJECT SET COORDINATES:C1248(*; "WP_"+This:C1470.ident+"_toolbar"; $verticalSplit; This:C1470.offsetVertical; $width; This:C1470.offsetVertical+90)
	OBJECT SET COORDINATES:C1248(*; "WP_"+This:C1470.ident+"_area"; $verticalSplit; This:C1470.offsetVertical+90; $width; $height)
	
	
Function resizePanel()
	This:C1470._reorganize()
	SET TIMER:C645(30)
	
Function timerPanel()
	SET TIMER:C645(0)
	If (Form:C1466.hl_current_ref#Null:C1517)
		SELECT LIST ITEMS BY REFERENCE:C630(Form:C1466.hl_documents; Form:C1466.hl_current_ref)
		This:C1470._load_hl_item_properties(1)
	End if 
	