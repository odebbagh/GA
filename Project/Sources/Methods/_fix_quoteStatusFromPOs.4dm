//%attributes = {}
// _fix_quoteStatusFromPOs
// One-time clean-up: the open quotes (Active, Under Customer Review, Require Follow-Up) that already
// have a customer PO are closed as won, Received Order, as a PO entered from now on does
// (ga_quoteStatus "poLinked": the lead goes to Won, the pending follow-ups are cancelled, a history
// line). The close date is today's. Asks first: "Report only" changes nothing and writes
// Project/imports/quote_status_fix.txt; "Apply" does the same and saves. Safe to run again.

var $apply : Boolean
var $quote : cs:C1710.QuoteEntity
var $po : cs:C1710.PurchaseOrderEntity
var $lines; $report : Collection
var $res : Object
var $poText; $message : Text
var $nb : Integer

$apply:=cs:C1710.sfw_dialog.me.confirm("Close as won (Received Order) the open quotes that already have a customer PO?\r\r"+\
"Report only: writes Project/imports/quote_status_fix.txt and changes nothing.\r"+\
"Apply: does the same and closes the quotes (and moves their leads to Won)."; "Apply"; "Report only")

$report:=New collection:C1472
For each ($quote; ds:C1482.Quote.pendingQuotes().orderBy("stmpCreation asc"))
	$po:=$quote.purchaseOrders.orderBy("logDate asc").first()
	If ($po=Null:C1517)
		continue
	End if
	$poText:=cs:C1710.ga_quoteStatus.me.poText($po)
	$report.push("Quote "+$quote.code+" ("+String:C10($quote.status.code)+"): PO "+$poText+Choose:C955($quote.purchaseOrders.length>1; " (+"+String:C10($quote.purchaseOrders.length-1)+")"; ""))
	If ($apply)
		$res:=cs:C1710.ga_quoteStatus.me.apply("poLinked"; $quote; New object:C1471("origin"; "customer PO "+$poText+" (_fix_quoteStatusFromPOs)"; "reason"; "Customer PO "+$poText))
		If ($res.changed)
			$nb+=1
		End if
		For each ($message; $res.messages)
			$report.push("  "+$message)
		End for each
	Else
		$nb+=1
	End if
End for each

$lines:=New collection:C1472("Quote status fix - "+String:C10(Current date:C33)+" "+String:C10(Current time:C178)+" - "+($apply ? "APPLIED" : "report only"))
$lines.push("")
$lines.push("Quotes "+($apply ? "closed as won" : "to close as won")+": "+String:C10($nb))
$lines.push("")
$lines.combine($report)

Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("quote_status_fix.txt").setText($lines.join("\r\n"))
cs:C1710.sfw_dialog.me.info("Quotes "+($apply ? "closed as won" : "to close as won")+": "+String:C10($nb)+"\rReport: Project/imports/quote_status_fix.txt")
