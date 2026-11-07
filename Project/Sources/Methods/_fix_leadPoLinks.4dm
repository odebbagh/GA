//%attributes = {}
// _fix_leadPoLinks
// One-time fill: the leads whose quote already has customer POs get the PO and the job, as a PO
// saved from now on does (ga_sales.syncLeadsFromPurchaseOrder, PurchaseOrderEntity.afterSave). Only
// empty links are filled. Asks first: "Report only" changes nothing and writes
// Project/imports/lead_po_links_fix.txt; "Apply" does the same and saves. Safe to run again.

var $apply : Boolean
var $po : cs:C1710.PurchaseOrderEntity
var $lines; $report : Collection
var $nb : Integer

$apply:=cs:C1710.sfw_dialog.me.confirm("Fill the PO and job of the leads from the POs of their quote?\r\r"+\
"Report only: writes Project/imports/lead_po_links_fix.txt and changes nothing.\r"+\
"Apply: does the same and saves the leads."; "Apply"; "Report only")

$report:=New collection:C1472
For each ($po; ds:C1482.PurchaseOrder.query("UUID_Quote # :1"; "0"*32).orderBy("logDate asc"))
	$nb+=cs:C1710.ga_sales.me.syncLeadsFromPurchaseOrder($po; $report; Not:C34($apply))
End for each

$lines:=New collection:C1472("Lead PO links fix - "+String:C10(Current date:C33)+" "+String:C10(Current time:C178)+" - "+($apply ? "APPLIED" : "report only"))
$lines.push("")
$lines.push("Leads "+($apply ? "updated" : "to update")+": "+String:C10($nb))
$lines.push("")
$lines.combine($report)

Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("lead_po_links_fix.txt").setText($lines.join("\r\n"))
cs:C1710.sfw_dialog.me.info("Leads "+($apply ? "updated" : "to update")+": "+String:C10($nb)+"\rReport: Project/imports/lead_po_links_fix.txt")
