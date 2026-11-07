//%attributes = {}
// _demo_jobsDeliveries
// Demo data only, for the Jobs & Deliveries page of a lead. For Sandia National Laboratories and
// DEMO CUSTOMER it creates a PO "DEMO-JD-<code>" (linked to the customer's latest quote), ten jobs
// with their lots covering every row the page shows (on time, late, partly shipped, late not
// shipped, on hold, recommitted, not released, invoiced, archived), and a lead "Demo - Jobs &
// Deliveries" when the customer has none, so the page is one click away. Dates are relative to
// today, so the period filters always have something to show. The customer's own jobs stay in the
// list next to these.
// Every record it creates is marked moreData.demo = "jobsDeliveries". "Create" removes the previous
// demo data first, so running it again just refreshes the dates; "Remove" only removes it.
// Lot locations are written as text ("5 of 9 : Burn-in"): real traveller steps need a step file and
// planning. Saved with ORDA: no panel callback runs, so numbers and dates are set here.
// The rows to expect are listed in Project/imports/demo_jobs_deliveries.txt.

var $mark : Text
var $names; $lines; $scenarios; $lotsDef : Collection
var $name; $code; $poNum : Text
var $customer : cs.CustomerEntity
var $quote : cs.QuoteEntity
var $po : cs.PurchaseOrderEntity
var $line : cs.PurchaseOrderLineEntity
var $job : cs.JobEntity
var $lot : cs.LotEntity
var $lead : cs.LeadEntity
var $s; $l; $row; $address : Object
var $today : Date
var $item; $removed : Integer
var $create : Boolean

$mark:="jobsDeliveries"
$names:=New collection("Sandia National Laboratories"; "DEMO CUSTOMER")
$today:=Current date

If (cs.sfw_dialog.me.confirm("Jobs & Deliveries demo data for "+$names.join(" and ")+".\r\rCreate (or refresh) it, or remove it?"; "Create"; "Remove"))
	$create:=True
Else
	If (Not(cs.sfw_dialog.me.confirm("Remove the Jobs & Deliveries demo data?"; "Remove"; "Cancel")))
		return
	End if
End if

// 1. Previous demo data out (lots, PO lines, jobs, POs, leads)
$removed:=0
For each ($name; New collection("Lot"; "PurchaseOrderLine"; "Job"; "PurchaseOrder"; "Lead"))
	$removed+=ds[$name].query("moreData.demo = :1"; $mark).length
	ds[$name].query("moreData.demo = :1"; $mark).drop()
End for each
If (Not($create))
	cs.sfw_dialog.me.info(String($removed)+" demo records removed.")
	return
End if

// numbers come from the table counters: put them past the imported numbers first
_fix_sequences

// 2. The ten jobs: d = days from today (negative = past); a lot per entry of "lots"
$scenarios:=New collection
$scenarios.push(New object("label"; "Shipped on time"; "expect"; "Shipped · On time"; "process"; "Test"; \
	"lots"; New collection(New object("in"; -35; "commit"; -20; "out"; -22; "location"; "completed"))))
$scenarios.push(New object("label"; "Shipped a bit late"; "expect"; "Shipped · Late 3 d · CT. Capacity tester"; "process"; "Test"; \
	"lots"; New collection(New object("in"; -30; "commit"; -15; "out"; -12; "location"; "completed"; "pareto"; "CT. Capacity tester"))))
$scenarios.push(New object("label"; "Shipped very late"; "expect"; "Shipped · Late 12 d · WS. Waiting for source"; "process"; "Screening"; \
	"lots"; New collection(New object("in"; -60; "commit"; -40; "out"; -28; "location"; "completed"; "pareto"; "WS. Waiting for source"))))
$scenarios.push(New object("label"; "Partly shipped"; "expect"; "In WIP · On track · 5 of 9 : Burn-in"; "process"; "Burn-in"; \
	"lots"; New collection(New object("in"; -20; "commit"; 6; "out"; -2; "location"; "completed"); New object("in"; -20; "commit"; 6; "location"; "5 of 9 : Burn-in"))))
$scenarios.push(New object("label"; "Running late"; "expect"; "In WIP · Late, not shipped (4 d) · HW. Hardware"; "process"; "Test"; \
	"lots"; New collection(New object("in"; -25; "commit"; -4; "location"; "7 of 10 : Final electrical test"; "pareto"; "HW. Hardware"))))
$scenarios.push(New object("label"; "On hold"; "expect"; "On hold · On track"; "process"; "Qualification"; \
	"lots"; New collection(New object("in"; -10; "commit"; 3; "location"; "2 of 8 : Visual inspection"; "hold"; -1))))
$scenarios.push(New object("label"; "Recommitted"; "expect"; "In WIP · On track (due = the recommit date, 5 d ahead)"; "process"; "Environmental"; \
	"lots"; New collection(New object("in"; -30; "commit"; -10; "recommit"; 5; "location"; "6 of 9 : Temperature cycling"))))
$scenarios.push(New object("label"; "Not released"; "expect"; "Not released · On track (due = PO line requested date)"; "process"; "Test"; \
	"requested"; 30; "unreleased"; True; "lots"; New collection))
$scenarios.push(New object("label"; "Invoiced"; "expect"; "Invoiced · On time"; "process"; "Test"; "invoiced"; -45; \
	"lots"; New collection(New object("in"; -80; "commit"; -55; "out"; -50; "location"; "completed"))))
$scenarios.push(New object("label"; "Old, archived"; "expect"; "Archived · On time (outside the period filters)"; "process"; "Screening"; "archived"; -400; \
	"lots"; New collection(New object("in"; -440; "commit"; -420; "out"; -425; "location"; "completed"))))

$address:=New object("addresses"; New collection(\
	New object("type"; "billing"; "detail"; New object("city"; ""; "country"; ""; "iso_code_2"; ""; "postcode"; ""; "state"; ""; "street_1"; ""; "street_2"; "")); \
	New object("type"; "shipping"; "detail"; New object("city"; ""; "country"; ""; "iso_code_2"; ""; "postcode"; ""; "state"; ""; "street_1"; ""; "street_2"; ""))))

$lines:=New collection("Jobs & Deliveries demo data - "+String($today); "")

For each ($name; $names)
	$customer:=ds.Customer.query("name = :1"; $name).first()
	If ($customer=Null)
		$customer:=ds.Customer.query("name = :1"; $name+"@").first()
	End if
	If ($customer=Null)
		$lines.push($name+": customer not found, skipped")
		continue
	End if
	$code:=($customer.code#"") ? $customer.code : Substring($customer.UUID; 1; 6)
	$quote:=ds.Quote.query("UUID_Customer = :1"; $customer.UUID).orderBy("stmpCreation desc").first()

	// the PO
	$po:=ds.PurchaseOrder.new()
	$poNum:="DEMO-JD-"+$code
	$po.UUID_Customer:=$customer.UUID
	$po.customer_name:=$customer.name
	$po.poNum:=$poNum
	$po.logDate:=$today-90
	$po.openPO:=True
	$po.currency:="USD"
	$po.description:="Demo purchase order for the Jobs & Deliveries page"
	$po.address:=OB Copy($address)
	If ($quote#Null)
		$po.UUID_Quote:=$quote.UUID
	End if
	$po.moreData:=New object("demo"; $mark)
	$po.save()

	$lines.push($customer.name+" - PO "+$poNum+(($quote#Null) ? ", quote "+String($quote.code) : ", no quote for this customer"))
	$item:=0
	For each ($s; $scenarios)
		$item+=1

		// the job
		$job:=ds.Job.new()
		$job.jobNumber:=Sequence number([Job])
		If (ds.Job.query("jobNumber = :1"; $job.jobNumber).length>0)
			$job.jobNumber:=Num(ds.Job.all().max("jobNumber"))+1
		End if
		$job.UUID_Customer:=$customer.UUID
		$job.customerName:=$customer.name
		$job.UUID_PurchaseOrder:=$po.UUID
		$job.dateCreated:=$today+(($s.lots.length>0) ? Num($s.lots[0].in) : -5)  // ternary: Choose evaluates both branches
		$job.process:=$s.process
		$job.deviceNumber:="DEMO-DEV-"+String($item; "00")
		$job.qty:=100*Num($s.lots.length || 1)
		$job.jobComment:=$s.label+" (demo)"
		$job.address:=OB Copy($address)
		If ($s.invoiced#Null)
			$job.invoiceDate:=$today+$s.invoiced
		End if
		If ($s.archived#Null)
			$job.archived:=True
			$job.archivedDate:=$today+$s.archived
		End if
		$job.moreData:=New object("demo"; $mark)
		$job.save()

		// its PO line
		$line:=ds.PurchaseOrderLine.new()
		$line.UUID_PurchaseOrder:=$po.UUID
		$line.UUID_Job:=$job.UUID
		$line.itemNum:=$item
		$line.seqNum:=$item
		$line.description:=$s.label+" - "+$s.process+" of DEMO-DEV-"+String($item; "00")
		$line.partNum:="DEMO-DEV-"+String($item; "00")
		$line.dateOrdered:=$job.dateCreated
		$line.customerRequestedDate:=($s.requested#Null) ? ($today+$s.requested) : $job.dateCreated+30
		$line.qtyOrdered:=$job.qty
		$line.unitPrice:=15
		$line.total:=$line.qtyOrdered*$line.unitPrice
		$line.currency:="USD"
		$line.unreleased:=Bool($s.unreleased)
		$line.moreData:=New object("demo"; $mark)
		$line.save()

		// its lots
		For each ($l; $s.lots)
			$lot:=ds.Lot.new()
			$lot.number:=cs.LotSplitService.me.freeLotNumber(Sequence number([Lot]); $lot.UUID)
			$lot.lotNumber:=String($lot.number)
			$lot.UUID_Job:=$job.UUID
			$lot.customer:=$customer.name
			$lot.poNumber:=$poNum
			$lot.device:=$job.deviceNumber
			$lot.process:=$s.process
			$lot.ourCount:=100
			$lot.customerCount:=100
			$lot.dateIn:=$today+$l.in
			$lot.commit:=$today+$l.commit
			If ($l.recommit#Null)
				$lot.reCommit:=$today+$l.recommit
			End if
			If ($l.out#Null)
				$lot.dateOut:=$today+$l.out
				$lot.readyToShipDate:=$lot.dateOut
			End if
			$lot.location:=String($l.location)
			$lot.latePareto:=String($l.pareto)
			If ($l.hold#Null)
				$lot.onHold:=True
				$lot.holdDate:=$today+$l.hold
			End if
			$lot.moreData:=New object("demo"; $mark)
			$lot.save()
		End for each

		$row:=$job.jobsRow()
		$lines.push("  job "+String($job.jobNumber)+"  "+$s.label+"  -> expected: "+$s.expect+"   | computed: "+$row.status+" · "+$row.timing+Choose($row.location#""; " · "+$row.location; "")+Choose($row.reasons#""; " · "+$row.reasons; ""))
	End for each

	// a lead to open the page from
	$lead:=ds.Lead.query("UUID_Customer = :1"; $customer.UUID).orderBy("stmpCreation desc").first()
	If ($lead=Null)
		$lead:=ds.Lead.new()
		$lead.leadCode:=$lead.calculateCode()
		$lead.UUID_Customer:=$customer.UUID
		$lead.deal:=True
		If (cs.sfw_userManager.me.info.UUID_Staff#Null)
			$lead.UUID_Staff:=cs.sfw_userManager.me.info.UUID_Staff
		End if
		$lead.dateCreation:=$today
		$lead.moreData:=New object("demo"; $mark; "secondaryContacts"; New collection)
		$lead.save()
		$lines.push("  lead "+$lead.leadCode+" created: open it, page Jobs & Deliveries")
	Else
		$lines.push("  open lead "+$lead.leadCode+", page Jobs & Deliveries")
	End if
	$lines.push("")
End for each

Folder(fk database folder).folder("Project/imports").file("demo_jobs_deliveries.txt").setText($lines.join("\r\n"))
cs.sfw_dialog.me.info($lines.join("\r")+"\rAlso in Project/imports/demo_jobs_deliveries.txt")
