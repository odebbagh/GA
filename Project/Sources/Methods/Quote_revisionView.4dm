//%attributes = {}
// Quote_revisionView($revision)
// A revision kept by "New revision..." (QuoteRevision), read-only: what was frozen (customer, subject,
// lines, assumptions and terms, the note) and the quote document as it printed then
// (panel_quote.quoteDocument from the frozen copy). Opened from the Revisions tab of a quote
// (double-click, or Actions > Open the revision...).
#DECLARE($revision : cs:C1710.QuoteRevisionEntity)

var $preview; $form; $clause : Object
var $header : Collection
var $winRef : Integer

If ($revision=Null:C1517)
	return
End if
$preview:=$revision.preview()

$form:=New object:C1471
$form.title:="Quote "+String:C10($preview.quoteNumber)+", revision "+$revision.label+" (#"+String:C10($revision.num)+")"
$form.info:="Kept on "+$revision.dateText+Choose:C955($revision.userName=""; ""; " by "+$revision.userName)+". Later changes to the quote, or to the assumptions and terms, are not in this copy."

$header:=New collection:C1472
$header.push("Customer:\t"+String:C10($preview.customerName))
$header.push("Contact:\t"+String:C10($preview.contactName))
$header.push("Subject:\t"+String:C10($preview.quoteSubject))
$header.push("Reference:\t"+String:C10($preview.quoteReference))
$header.push("Status:\t"+String:C10($preview.statusName)+"     Service: "+String:C10($preview.serviceTypeName))
$header.push("Owner:\t"+String:C10($preview.preparerName)+"     Dated: "+String:C10($preview.quoteDate))
$header.push("Total:\t"+_ga_usdText(Num:C11($preview.total)))
$form.header:=$header.join("\r")
$form.note:=$revision.note

$form.lines:=$preview.quoteLines
$form.clauses:=New collection:C1472
For each ($clause; $preview.assumptions)
	$form.clauses.push(New object:C1471("kind"; "Assumption"; "code"; $clause.code; "value"; $clause.value))
End for each
For each ($clause; $preview.conditions)
	$form.clauses.push(New object:C1471("kind"; "Term"; "code"; $clause.code; "value"; $clause.value))
End for each

$form.preview:=cs:C1710.panel_quote.me.quoteDocument($preview)

$winRef:=Open form window:C675("Quote_revisionView"; Plain form window:K39:10; Horizontally centered:K39:1; Vertically centered:K39:4)
SET WINDOW TITLE:C213($form.title; $winRef)
DIALOG:C40("Quote_revisionView"; $form)
CLOSE WINDOW:C154($winRef)
