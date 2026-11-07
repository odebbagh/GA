//%attributes = {}
// Quote_savePreviewPdf {($revision)} -> the sfw_Document created
// Saves the quote as it shows on the Preview tab (panel_quote.quoteDocument) as a PDF in the
// "Quotes sent" folder of its Documents tab (_ga_createSalesDocFolders, ident quoteSent), then opens it.
// Every save is kept, with its date: revision A, then B...
// With $revision (a QuoteRevision, from Quote_newRevision): the frozen copy instead, named after the
// revision it was frozen as; not opened, and the caller says it is saved.
//
// Called by the item action "Save PDF to Documents" (Quote.entryDefinition: Form is then the sfw
// window, Form.subForm the panel) and by the Actions menu of the Preview tab (panel_quote.bActionPreview: Form is the panel).
// Not in Modify: the PDF is the saved quote, and a document saved inside the sfw transaction would
// be dropped by Cancel while its file stayed in DocumentData.
#DECLARE($revision : cs:C1710.QuoteRevisionEntity)->$doc : 4D:C1709.Entity

var $file : 4D:C1709.File
var $fileName; $revisionName : Text
var $quote : cs:C1710.QuoteEntity
var $preview; $wp : Object

If ($revision=Null:C1517)
	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	If (Form:C1466.sfw.checkIsInModification())
		cs:C1710.sfw_dialog.me.alert("Save or cancel the changes first: the PDF is made from the saved quote.")
		return
	End if
	$quote:=Form:C1466.current_item
	$preview:=$quote.preview()
	$revisionName:=String:C10($quote.revision.name)
Else
	$quote:=$revision.quote
	$preview:=$revision.preview()
	$revisionName:=String:C10($preview.quoteRevision)
End if

// the folder, created when missing (an install that has not restarted since the folders were added)
If (ds:C1482.sfw_DocumentFolder.query("ident = :1"; "quoteSent").length=0)
	_ga_createSalesDocFolders
End if

$wp:=cs:C1710.panel_quote.me.quoteDocument($preview)

$fileName:="Quote_"+String:C10($quote.code)
If ($revisionName#"")
	$fileName:=$fileName+"_Rev"+$revisionName
End if
$fileName:=$fileName+"_"+Substring:C12(String:C10(Current date:C33; ISO date:K1:8); 1; 10)
$fileName:=Replace string:C233(Replace string:C233(Replace string:C233($fileName; "/"; "-"); "\\"; "-"); ":"; "-")

$file:=Folder:C1567(Temporary folder:C486; fk platform path:K87:2).file($fileName+".pdf")
If ($file.exists)
	$file.delete()
End if
WP EXPORT DOCUMENT:C1337($wp; $file.platformPath; wk pdf:K81:315)
If (Not:C34($file.exists))
	cs:C1710.sfw_dialog.me.alert("The PDF could not be written to "+$file.platformPath+".")
	return
End if

$doc:=_ga_attachFileToTarget($quote.UUID; "quoteSent"; $file)
If ($revision=Null:C1517)
	OPEN URL:C673($file.platformPath)
End if

If ($doc#Null:C1517)
	// the count on the Documents tab
	If (Form:C1466.subForm#Null:C1517)  // item action: the panel picks the flag up on its bound variable change
		Form:C1466.subForm.refreshDocumentsTab:=True:C214
		Form:C1466.subForm:=Form:C1466.subForm
	Else
		cs:C1710.panel_quote.me.refreshDocumentsTab()
	End if
	If ($revision=Null:C1517)
		cs:C1710.sfw_dialog.me.info($file.fullName+" is saved in the \"Quotes sent\" folder of the quote's Documents tab.")
	End if
End if
