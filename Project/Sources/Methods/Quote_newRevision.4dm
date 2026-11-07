//%attributes = {}
// Quote_newRevision
// "New revision...": the item action of the Quotes entry (Quote.entryDefinition) and the Actions
// of the Revisions tab (panel_quote.bActionRevisions, through CALL FORM, so it always runs here with
// Form the sfw window and Form.subForm the panel).
// Asks for a note and the revision to move to (the next level by default), then:
// - QuoteEntity.newRevision freezes the saved quote into a QuoteRevision labelled with its current
//   revision (lines, assumptions, terms... as values) and moves the quote to the chosen one
// - the frozen copy is saved as a PDF in the "Quotes sent" folder (Quote_savePreviewPdf)
// - a history line "New revision" with the note (ga_events)
// A quote without a revision (imported) is frozen as the first level.
// Not in Modify: the copy is the saved quote, and sfw owns the transaction of Modify.
#DECLARE()

var $quote : cs:C1710.QuoteEntity
var $current; $next : cs:C1710.RevisionEntity
var $levels; $choices : cs:C1710.RevisionSelection
var $revision : cs:C1710.QuoteRevisionEntity
var $doc : 4D:C1709.Entity
var $form; $result; $statusChange : Object
var $labels : Collection
var $winRef : Integer
var $noteEmpty : Boolean
var $currentLabel; $nextLabel; $message : Text

If (Form:C1466.current_item=Null:C1517)
	return
End if
If (Form:C1466.sfw.checkIsInModification())
	cs:C1710.sfw_dialog.me.alert("Save or cancel the changes first: the revision keeps a copy of the saved quote.")
	return
End if

$levels:=ds:C1482.Revision.all().orderBy("levelID asc")
If ($levels.length=0)
	cs:C1710.sfw_dialog.me.alert("There is no revision level yet: add them in Quote P. > Revision.")
	return
End if

$quote:=ds:C1482.Quote.get(Form:C1466.current_item.UUID)  // as saved
If ($quote=Null:C1517)
	return
End if
$current:=$quote.revision
If ($current=Null:C1517)
	$current:=$levels.first()
End if
$currentLabel:=New collection:C1472($current.code; $current.name).join(" - "; ck ignore null or empty:K85:5)

// the levels after the current one, the next one selected
$choices:=$levels.query("levelID > :1"; $current.levelID)
If ($choices.length=0)
	cs:C1710.sfw_dialog.me.alert("Revision "+$currentLabel+" is the last level: add the next one in Quote P. > Revision first.")
	return
End if
$labels:=New collection:C1472
For each ($next; $choices)
	$labels.push(New collection:C1472($next.code; $next.name).join(" - "; ck ignore null or empty:K85:5))
End for each

$form:=New object:C1471
$form.title:="Quote "+$quote.code+": new revision"
$form.explanation:="A copy of the quote as it is saved now (lines, assumptions, terms) is kept as revision "+$currentLabel+" on the Revisions tab and as a PDF in \"Quotes sent\". The quote then continues as:"
$form.levels:=New object:C1471("values"; $labels; "index"; 0)
$form.note:=""

Repeat
	$winRef:=Open form window:C675("Quote_newRevision"; Movable form dialog box:K39:8; Horizontally centered:K39:1; Vertically centered:K39:4)
	SET WINDOW TITLE:C213($form.title; $winRef)
	DIALOG:C40("Quote_newRevision"; $form)
	CLOSE WINDOW:C154($winRef)
	$noteEmpty:=(Replace string:C233(Replace string:C233(Replace string:C233($form.note; " "; ""); "\r"; ""); "\n"; "")="")
	If (OK=1) && ($noteEmpty)
		cs:C1710.sfw_dialog.me.alert("Write a note: why this revision is made (what changed, who asked).")
	End if
Until (OK=0) || (Not:C34($noteEmpty))
If (OK=0)
	return
End if

$next:=$choices[Num:C11($form.levels.index)]
$nextLabel:=New collection:C1472($next.code; $next.name).join(" - "; ck ignore null or empty:K85:5)

$result:=$quote.newRevision($current.UUID; $next.UUID; $form.note)
If (Not:C34(Bool:C1537($result.success)))
	cs:C1710.sfw_dialog.me.alert($result.message)
	return
End if
$revision:=$result.revision
$statusChange:=$result.statusChange  // the automatic status rules of a new revision (ga_quoteStatus)

// the history line
cs:C1710.ga_events.me.addEvent("quote"; $quote.UUID; "quoteRevision"; "New revision"; New collection:C1472(\
	"Revision "+$currentLabel+" kept (revision #"+String:C10($revision.num)+"), the quote is now at revision "+$nextLabel+"."; \
	"Note: "+$form.note))

// the frozen copy as a PDF, kept with the revision
$doc:=Quote_savePreviewPdf($revision)
If ($doc#Null:C1517)
	$revision.moreData:=New object:C1471("UUID_Document"; $doc.UUID)
	$result:=$revision.save()
End if

// the quote on screen: the new revision label, and no change seen at the next Save
Form:C1466.current_item.reload()
If (Form:C1466.subForm#Null:C1517)  // the sfw window: the panel refreshes on its bound variable change
	Form:C1466.current_clone:=Form:C1466.current_item.clone()
	Form:C1466.subForm.refreshRevisions:=True:C214
	Form:C1466.subForm:=Form:C1466.subForm
Else
	cs:C1710.panel_quote.me.refreshAfterNewRevision()
End if
cs:C1710.sfw_eventManager.me.refresh($quote.UUID; Form:C1466.sfw.entry)

$message:="Revision "+$currentLabel+" is kept on the Revisions tab"
$message+=Choose:C955($doc#Null:C1517; " and as a PDF in the \"Quotes sent\" folder"; "")
$message+=".\rThe quote is now at revision "+$nextLabel+"."
If ($statusChange#Null:C1517) && ($statusChange.messages.length>0)
	$message+="\r"+$statusChange.messages.join("\r")
End if
cs:C1710.sfw_dialog.me.info($message)
