//%attributes = {}
// _demo_salesTestData
// Test data only, for the Quotes & Leads test plan. Works on customers that have at least
// two contacts (most contacts first, vendors left out). When fewer than $maxCustomers have
// them, other customers get test contacts (Alice, Brian, Carla "Test") until they have three.
// Each of the first $maxCustomers customers then gets:
// - a purchase order "TEST-<customer code>" with two lines (line 1 is released to the job,
//   line 2 is left unreleased) and its amount summed from the lines
// - a job linked to that purchase order and to line 1
// so a lead or a quote on that customer can link a quote, a PO and a job, and the contact
// dialogs have more than one contact to offer.
//
// Contacts belong to a customer through Contact.UUID_Company: that is what the contact
// dialogs of panel_lead / panel_quote query.
// Safe to run again: a customer whose TEST- purchase order has its lines is skipped (one left
// without lines by an interrupted run is completed), and a customer that already has two
// contacts gets no new ones. Calls _fix_sequences first, so the Job counter is past the
// imported job numbers.
// Records are saved with ORDA, so the panel callbacks (loadAfterCreation...) do not run:
// what they would set (job number, addresses, dates) is set here.
// What was created and the list of customers with 2+ contacts are shown at the end and
// written to Project/imports/sales_test_data.txt.

var $maxCustomers : Integer
var $counts : Object
var $rows : Collection
var $toComplete : Collection
var $row : Object
var $id : Text
var $customer : cs.CustomerEntity
var $customers : cs.CustomerSelection
var $contact : cs.ContactEntity
var $po : cs.PurchaseOrderEntity
var $line : cs.PurchaseOrderLineEntity
var $job : cs.JobEntity
var $contacts : cs.ContactSelection
var $e : cs.ContactEntity
var $people : Collection
var $person : Object
var $names : Collection
var $lines : Collection
var $res : Object
var $poNum : Text
var $code : Text
var $created : Integer
var $jobNumber : Integer
var $nbNewContacts : Integer
var $i : Integer
var $address : Object
var $message : Text

$maxCustomers:=3  // how many customers get a PO and a job

// 1. Contacts per customer (only companies that are customers, vendors left out)
$counts:=New object
For each ($id; ds.Contact.query("UUID_Company # :1"; "0"*32).extract("UUID_Company"))
	$counts[$id]:=Num($counts[$id])+1
End for each

$rows:=New collection
For each ($id; $counts)
	If ($counts[$id]>=2)
		$customer:=ds.Customer.get($id)
		If ($customer#Null) && (Not(Bool($customer.vendor)))
			$rows.push(New object("uuid"; $id; "name"; $customer.name; "code"; $customer.code; "nbContacts"; $counts[$id]))
		End if
	End if
End for each
$rows:=$rows.orderBy("nbContacts desc, name asc")

// customers that will get test contacts: those with one contact first, then by name
$toComplete:=New collection
If ($rows.length<$maxCustomers)
	$customers:=ds.Customer.query("vendor = :1 and not(UUID in :2)"; False; $rows.extract("uuid"))
	For each ($customer; $customers)
		$toComplete.push(New object("uuid"; $customer.UUID; "name"; $customer.name; "code"; $customer.code; "nbContacts"; Num($counts[$customer.UUID])))
	End for each
	$toComplete:=$toComplete.orderBy("nbContacts desc, name asc").slice(0; $maxCustomers-$rows.length)
End if

If ($rows.length=0) && ($toComplete.length=0)
	cs.sfw_dialog.me.alert("There is no customer in the data file: nothing was created.")
	return
End if

$message:=String($rows.length)+" customers have two contacts or more."
If ($toComplete.length>0)
	$message+="\r"+String($toComplete.length)+" more will get test contacts: "+$toComplete.extract("name").join(", ")+"."
End if
$message+="\rCreate a test purchase order and job for "+String($rows.length+$toComplete.length)+" customers?"
If (Not(cs.sfw_dialog.me.confirm($message; "Create"; "Cancel")))
	return
End if

$lines:=New collection
$lines.push("Sales test data - "+String(Current date)+" "+String(Current time))
$lines.push("")

// 2. Test contacts, up to three per customer
$people:=New collection
$people.push(New object("firstName"; "Alice"; "title"; "Buyer"; "phone"; "408-555-0101"))
$people.push(New object("firstName"; "Brian"; "title"; "Test Engineer"; "phone"; "408-555-0102"))
$people.push(New object("firstName"; "Carla"; "title"; "Quality Manager"; "phone"; "408-555-0103"))

For each ($row; $toComplete)
	$nbNewContacts:=0
	For ($i; $row.nbContacts; 2)
		$person:=$people[$i]
		$code:=Lowercase(Choose($row.code#""; $row.code; Substring($row.uuid; 1; 6)))

		$contact:=ds.Contact.new()
		$contact.UUID_Company:=$row.uuid
		$contact.UUID_Customer:=$row.uuid
		$contact.firstName:=$person.firstName
		$contact.lastName:="Test"
		$contact.title:=$person.title
		$contact.contactDetails:=New object("addresses"; New collection; "communications"; New collection)
		$contact.contactDetails.addresses.push(New object("type"; "main"; "detail"; New object(\
			"street_1"; "1 Test Street"; "street_2"; ""; "city"; "San Jose"; "state"; "CA"; \
			"postcode"; "95134"; "country"; "United States"; "iso_code_2"; "US")))
		$contact.contactDetails.communications.push(New object("type"; "phone"; "contact"; $person.phone; "comment"; ""))
		$contact.contactDetails.communications.push(New object("type"; "email"; "contact"; Lowercase($person.firstName)+".test@"+$code+".example.com"; "comment"; ""))
		$res:=$contact.save()
		If ($res.success)
			$nbNewContacts+=1
		Else
			$lines.push($row.name+": contact "+$person.firstName+" Test not saved ("+String($res.statusText)+")")
		End if
	End for
	$lines.push($row.name+": "+String($nbNewContacts)+" test contacts added")
	$row.nbContacts+=$nbNewContacts
	$rows.push($row)
End for each

// 3. A PO, its two lines and a job for each of the first customers
// the Job counter first: after the legacy import it is far behind the job numbers in use
_fix_sequences
For each ($row; $rows)
	If ($created>=$maxCustomers)
		break
	End if

	$customer:=ds.Customer.get($row.uuid)
	$poNum:="TEST-"+Choose($customer.code#""; $customer.code; Substring($row.uuid; 1; 8))

	$contacts:=ds.Contact.query("UUID_Company = :1"; $row.uuid).orderBy("lastName asc, firstName asc")
	$names:=New collection
	For each ($e; $contacts)
		$names.push($e.fullName)
	End for each

	// purchase order: a complete one means this customer is done; one without lines (a run that
	// stopped half way) is reused and gets its job and lines now
	$po:=ds.PurchaseOrder.query("poNum = :1"; $poNum).first()
	If ($po#Null)
		If (ds.PurchaseOrderLine.query("UUID_PurchaseOrder = :1"; $po.UUID).length>0)
			$lines.push($customer.name+": already has PO "+$poNum+", skipped")
			$created+=1
			continue
		End if
	Else
		$po:=ds.PurchaseOrder.new()
		$po.UUID_Customer:=$customer.UUID
		$po.customer_name:=$customer.name
		$po.poNum:=$poNum
		$po.logDate:=Current date
		$po.openPO:=True
		$po.currency:="USD"
		$po.description:="Test purchase order for the Quotes & Leads tests"
		$po.address:=New object("addresses"; New collection)
		$res:=$po.save()
		If (Not($res.success))
			$lines.push($customer.name+": PO not saved ("+String($res.statusText)+")")
			continue
		End if
	End if

	// job: the table's counter, as JobEntity.loadAfterCreation does (_fix_sequences moved it past
	// the imported job numbers above); should the number be taken anyway, the highest + 1
	$jobNumber:=Sequence number([Job])
	If (ds.Job.query("jobNumber = :1"; $jobNumber).length>0)
		$lines.push($customer.name+": job counter gave "+String($jobNumber)+", already used; highest + 1 taken instead")
		$jobNumber:=Num(ds.Job.all().max("jobNumber"))+1
	End if

	$address:=New object("addresses"; New collection)
	$address.addresses.push(New object("type"; "billing"; "detail"; New object("city"; ""; "country"; ""; "iso_code_2"; ""; "postcode"; ""; "state"; ""; "street_1"; ""; "street_2"; "")))
	$address.addresses.push(New object("type"; "shipping"; "detail"; New object("city"; ""; "country"; ""; "iso_code_2"; ""; "postcode"; ""; "state"; ""; "street_1"; ""; "street_2"; "")))

	$job:=ds.Job.new()
	$job.jobNumber:=$jobNumber
	$job.UUID_Customer:=$customer.UUID
	$job.customerName:=$customer.name
	$job.UUID_PurchaseOrder:=$po.UUID
	$job.dateCreated:=Current date
	$job.stmpExpected:=cs.sfw_stmp.me.build(Current date+21; ?00:00:00?)
	$job.deviceNumber:="TEST-DEV-001"
	$job.process:="Test"
	$job.qty:=100
	$job.jobComment:="Test job for the Quotes & Leads tests"
	$job.address:=$address
	$res:=$job.save()
	If (Not($res.success))
		$lines.push($customer.name+": PO "+$poNum+" created, job not saved ("+String($res.statusText)+")")
		continue
	End if

	// line 1: released to the job
	$line:=ds.PurchaseOrderLine.new()
	$line.UUID_PurchaseOrder:=$po.UUID
	$line.UUID_Job:=$job.UUID
	$line.itemNum:=1
	$line.seqNum:=1
	$line.description:="Electrical test, 100 units"
	$line.partNum:="TEST-DEV-001"
	$line.dateOrdered:=Current date
	$line.customerRequestedDate:=Current date+21
	$line.qtyOrdered:=100
	$line.unitPrice:=12.5
	$line.total:=$line.qtyOrdered*$line.unitPrice
	$line.currency:="USD"
	$res:=$line.save()

	// line 2: not released yet
	$line:=ds.PurchaseOrderLine.new()
	$line.UUID_PurchaseOrder:=$po.UUID
	$line.itemNum:=2
	$line.seqNum:=2
	$line.description:="Minimum lot charge"
	$line.partNum:="TEST-DEV-001"
	$line.dateOrdered:=Current date
	$line.customerRequestedDate:=Current date+21
	$line.qtyOrdered:=1
	$line.unitPrice:=500
	$line.total:=$line.qtyOrdered*$line.unitPrice
	$line.currency:="USD"
	$line.unreleased:=True
	$res:=$line.save()

	$po.poAmount:=ds.PurchaseOrderLine.query("UUID_PurchaseOrder = :1"; $po.UUID).sum("total")
	$res:=$po.save()

	$lines.push($customer.name+" ("+$customer.code+"): PO "+$poNum+" ($"+String($po.poAmount; "###,##0.00")+"), job "+String($jobNumber)+", contacts: "+$names.join(", "))
	$created+=1
End for each

// 4. Report: what was created, then every customer that can be used for the contact tests
$lines.push("")
$lines.push("Customers with two contacts or more ("+String($rows.length)+"):")
For each ($row; $rows)
	$lines.push("  "+$row.name+" ("+$row.code+"): "+String($row.nbContacts)+" contacts")
End for each

Folder(fk database folder).folder("Project/imports").file("sales_test_data.txt").setText($lines.join("\r\n"))
cs.sfw_dialog.me.info($lines.slice(0; $lines.indexOf("")+1+$toComplete.length+$maxCustomers+1).join("\r")+"\r\rFull list in Project/imports/sales_test_data.txt")
