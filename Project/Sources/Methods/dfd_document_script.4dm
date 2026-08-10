//%attributes = {}
var $formName : Text
var $formDefinition : Object

$pageDefinition:=Form:C1466.sfw.entry.panel.pages.query("page = :1"; FORM Get current page:C276(*)).first()

Case of 
	: ($pageDefinition.dynamicSource=Null:C1517)
	: (FORM Event:C1606.objectName=("dfdSubform_"+$pageDefinition.dynamicSource.ident+"_ddPage"))
		cs:C1710.dfd_panel_document.me.redraw_preview(Form:C1466.dfd_context; "--subform")
		$formName:="dfdSubform_"+$pageDefinition.dynamicSource.ident
		$formDefinition:=Form:C1466.dfd_context.formDefinition
		OBJECT SET SUBFORM:C1138(*; $formName; $formDefinition)
		
	: (FORM Event:C1606.objectName=("dfdSubform_"+$pageDefinition.dynamicSource.ident+"_bRuler"))
		cs:C1710.dfd_panel_document.me.redraw_preview(Form:C1466.dfd_context; "--subform")
		$formName:="dfdSubform_"+$pageDefinition.dynamicSource.ident
		$formDefinition:=Form:C1466.dfd_context.formDefinition
		OBJECT SET SUBFORM:C1138(*; $formName; $formDefinition)
		
	: (FORM Event:C1606.objectName=("dfdSubform_"+$pageDefinition.dynamicSource.ident+"_bPDF"))
		$printPreview:=Form:C1466.eDfdDocument.moreData.settings.printPreview
		Form:C1466.eDfdDocument.moreData.settings.printPreview:=True:C214
		cs:C1710.dfd_panel_document.me.redraw_preview(Form:C1466.dfd_context; "--print")
		$formName:="dfdSubform_"+$pageDefinition.dynamicSource.ident
		$formDefinition:=Form:C1466.dfd_context.formDefinition
		OBJECT SET SUBFORM:C1138(*; $formName; $formDefinition)
		Form:C1466.eDfdDocument.moreData.settings.printPreview:=$printPreview
		
	: (FORM Event:C1606.objectName=("dfdSubform_"+$pageDefinition.dynamicSource.ident+"_bPrint"))
		cs:C1710.dfd_panel_document.me.redraw_preview(Form:C1466.dfd_context; "--print")
		$formName:="dfdSubform_"+$pageDefinition.dynamicSource.ident
		$formDefinition:=Form:C1466.dfd_context.formDefinition
		OBJECT SET SUBFORM:C1138(*; $formName; $formDefinition)
		
	: (FORM Event:C1606.objectName=("dfdSubform_"+$pageDefinition.dynamicSource.ident+"_ruler"))
		cs:C1710.dfd_panel_document.me.redraw_preview(Form:C1466.dfd_context; "--subform")
		$formName:="dfdSubform_"+$pageDefinition.dynamicSource.ident
		$formDefinition:=Form:C1466.dfd_context.formDefinition
		OBJECT SET SUBFORM:C1138(*; $formName; $formDefinition)
		
	: (FORM Event:C1606.objectName=("WP_"+$pageDefinition.dynamicSource.ident+"_area"))
		WP UpdateWidget("WP_"+$pageDefinition.dynamicSource.ident+"_toolbar"; "WP_"+$pageDefinition.dynamicSource.ident+"_area")
		
		
End case 