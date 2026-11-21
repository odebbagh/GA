// ga_receivables: what customers owe and what they pay (QuickBooks "Receive Payment").
//
// For someone new to accounting:
// - An invoice posted (ga_invoicePosting) says "the customer owes us 1,000": the 1,000 sits on
//   Accounts receivable (A/R), the account of the money customers owe.
// - When the customer pays, we record ONE payment (CustomerPayment): the money received, and
//   how it is split over the invoices it pays (CustomerPaymentLine, "applied"). The OPEN BALANCE
//   of an invoice is what is still unpaid: billed - payments applied - discounts given.
// - A DISCOUNT taken is money the customer was allowed not to pay (e.g. term "2% 10 Net 30":
//   2% off when paid within 10 days). It closes the invoice like money, but it costs us: it goes
//   to the Sales discounts account (role DefaultSalesDiscounts).
// - Money received and applied to no invoice is a CREDIT of the customer: we hold it until it is
//   used on a later invoice. As in legacy, it sits on Customer advances (role
//   DefaultCustomerAdvance, legacy "CusAdv"), a liability: we owe it back (in work or money).
//
// The entry of a payment (ga_ledger.post, type "Payment", dated the payment date):
//   Dr  Deposit to (Undeposited funds, or a bank) ............ the amount received
//   Dr  Sales discounts ....................................... the discounts taken
//   Cr  Accounts receivable (customer on the line) ............ applied + discounts
//   Cr  Customer advances (customer on the line) .............. what is left (the credit)
// A payment of 0 that applies an existing credit to invoices ("Apply credit") has a negative
// remainder: its Customer advances line is a DEBIT (the credit is used) and A/R is credited.
// So the credit of a customer is simply the sum of the unappliedAmount of its posted payments.
//
// Saved = posted (QuickBooks): the panel blocks Save while the payment has a problem, and the
// entry is rewritten on each Save while its date is after the closing date. Void cancels it.
// A payment dated on or before the closing date is locked: a credit it left is used with an
// "Apply credit" payment dated today.
// Legacy credits imported at the start date (isLegacy) have no entry: their amount is already
// on Customer advances in the opening balance.
singleton Class constructor
	This:C1470._noUUID:="0"*32


	// MARK: - Invoices

	// what was billed and counts for payments: the posted total; for an invoice imported from
	// the legacy open receivables, what legacy said was still due on the start date; 0 for a
	// draft, a void invoice, or an older legacy invoice (paid in legacy)
Function startingBalance($invoice : cs:C1710.JobInvoiceEntity)->$amount : Real
	Case of
		: ($invoice=Null:C1517)
		: ($invoice.status="Void")
		: ($invoice.isLegacy)
			If ($invoice.moreData#Null:C1517) && ($invoice.moreData.legacyAR#Null:C1517)
				$amount:=Round:C94(Num:C11($invoice.moreData.legacyAR.openBalance); 2)
			End if
		: (cs:C1710.ga_invoicePosting.me.isPosted($invoice))
			$amount:=Round:C94($invoice.postedTotal; 2)
	End case

	// the payment lines of posted payments on the invoice ($excludePaymentUUID: but that one)
Function linesOf($invoiceUUID : Text; $excludePaymentUUID : Text)->$lines : cs:C1710.CustomerPaymentLineSelection
	$lines:=ds:C1482.CustomerPaymentLine.query("UUID_JobInvoice = :1 AND payment.status = :2"; $invoiceUUID; "Posted")
	If ($excludePaymentUUID#"")
		$lines:=$lines.query("UUID_CustomerPayment # :1"; $excludePaymentUUID)
	End if

	// what is still unpaid ($excludePaymentUUID: as if that payment did not exist)
Function openBalance($invoice : cs:C1710.JobInvoiceEntity; $excludePaymentUUID : Text)->$open : Real
	var $lines : cs:C1710.CustomerPaymentLineSelection
	If ($invoice=Null:C1517)
		return
	End if
	$lines:=This:C1470.linesOf($invoice.UUID; $excludePaymentUUID)
	$open:=Round:C94(This:C1470.startingBalance($invoice)-$lines.sum("amountApplied")-$lines.sum("discountTaken"); 2)

	// what the customer paid on it: in legacy (before the start date) and here, discounts included
Function amountPaid($invoice : cs:C1710.JobInvoiceEntity)->$paid : Real
	var $billed : Real
	If ($invoice=Null:C1517) || ($invoice.status="Void")
		return
	End if
	$billed:=($invoice.isLegacy) ? Round:C94($invoice.total; 2) : Round:C94($invoice.postedTotal; 2)
	If (Not:C34(cs:C1710.ga_invoicePosting.me.isPosted($invoice))) && Not:C34($invoice.isLegacy)
		return
	End if
	$paid:=Round:C94($billed-This:C1470.openBalance($invoice; ""); 2)

	// "" (nothing paid yet, or not in the books), "Partially paid" or "Paid"
Function paymentState($invoice : cs:C1710.JobInvoiceEntity)->$state : Text
	var $open; $paid : Real
	If ($invoice=Null:C1517) || ($invoice.status#"Posted")
		return
	End if
	If (Not:C34($invoice.isLegacy)) && Not:C34(cs:C1710.ga_invoicePosting.me.isPosted($invoice))
		return
	End if
	If ($invoice.isLegacy) && (($invoice.moreData=Null:C1517) || ($invoice.moreData.legacyAR=Null:C1517))
		return  // posted in legacy, not in the open receivables imported: nothing known here
	End if
	$open:=This:C1470.openBalance($invoice; "")
	$paid:=This:C1470.amountPaid($invoice)
	Case of
		: ($open<=0) && (($paid#0) || $invoice.isLegacy)
			$state:="Paid"
		: ($paid>0)
			$state:="Partially paid"
	End case

	// payments applied to the invoice (a void or draft invoice must have none)
Function hasPayments($invoice : cs:C1710.JobInvoiceEntity)->$has : Boolean
	$has:=This:C1470.linesOf($invoice.UUID; "").query("amountApplied # :1 OR discountTaken # :1"; 0).length>0

	// the early payment discount allowed for a payment on $date (its term: "2% 10 Net 30"), on
	// what was billed, never more than what is open
Function suggestedDiscount($invoice : cs:C1710.JobInvoiceEntity; $date : Date; $open : Real)->$discount : Real
	var $term : cs:C1710.PaymentTermEntity
	$term:=$invoice.paymentTerm
	If ($term=Null:C1517) || ($term.discountPercent=0) || ($date=!00-00-00!)
		return
	End if
	If ($date>Add to date:C393($invoice.invoiceDate; 0; 0; $term.discountDays))
		return
	End if
	$discount:=Round:C94(This:C1470.startingBalance($invoice)*$term.discountPercent/100; 2)
	If ($discount>$open)
		$discount:=$open
	End if


	// MARK: - Customers

	// the invoices of the customer that can take a payment (posted here or imported open from
	// legacy), oldest due first
Function postedInvoicesOf($customerUUID : Text)->$invoices : cs:C1710.JobInvoiceSelection
	$invoices:=ds:C1482.JobInvoice.query("UUID_Customer = :1 AND status = :2"; $customerUUID; "Posted").orderBy("dueStmp asc, invoiceStmp asc, invoiceNumber asc")

	// what the customer still owes on its invoices
Function customerOwed($customerUUID : Text)->$owed : Real
	var $invoice : cs:C1710.JobInvoiceEntity
	For each ($invoice; This:C1470.postedInvoicesOf($customerUUID))
		$owed:=$owed+This:C1470.openBalance($invoice; "")
	End for each
	$owed:=Round:C94($owed; 2)

	// the money received from the customer and not used yet ($excludePaymentUUID: but that one)
Function customerCredit($customerUUID : Text; $excludePaymentUUID : Text)->$credit : Real
	var $payments : cs:C1710.CustomerPaymentSelection
	$payments:=ds:C1482.CustomerPayment.query("UUID_Customer = :1 AND status = :2"; $customerUUID; "Posted")
	If ($excludePaymentUUID#"")
		$payments:=$payments.query("UUID # :1"; $excludePaymentUUID)
	End if
	$credit:=Round:C94($payments.sum("unappliedAmount"); 2)

	// what the customer owes, less its credit (negative: we owe it)
Function customerBalance($customerUUID : Text)->$balance : Real
	$balance:=Round:C94(This:C1470.customerOwed($customerUUID)-This:C1470.customerCredit($customerUUID; ""); 2)

	// the customers that owe something or have a credit, by name (for the payment panel menu)
Function customersWithBalance()->$customers : Collection
	var $uuids : Collection
	var $uuid : Text
	var $customer : cs:C1710.CustomerEntity
	var $owed; $credit : Real
	$uuids:=ds:C1482.JobInvoice.query("status = :1"; "Posted").distinct("UUID_Customer")
	$uuids.combine(ds:C1482.CustomerPayment.query("status = :1 AND unappliedAmount # :2"; "Posted"; 0).distinct("UUID_Customer"))
	$uuids:=$uuids.distinct()
	$customers:=New collection:C1472
	For each ($uuid; $uuids)
		$customer:=ds:C1482.Customer.get($uuid)
		If ($customer=Null:C1517)
			continue
		End if
		$owed:=This:C1470.customerOwed($uuid)
		$credit:=This:C1470.customerCredit($uuid; "")
		If ($owed#0) || ($credit#0)
			$customers.push(New object:C1471("UUID"; $uuid; "name"; $customer.name; "owed"; $owed; "credit"; $credit))
		End if
	End for each
	$customers:=$customers.orderBy("name asc")


	// MARK: - Payments: rows of the panel

	// The rows of the "Invoices" tab: each invoice of the customer still open (as if this payment
	// did not exist), and the ones this payment pays. $all False: only the ones it pays.
	// A row: {UUID_JobInvoice; invoiceNumber; invoiceDate; dueDate; billed; open; apply; discount;
	// suggestedDiscount; jobNumber}
Function rowsForPayment($payment : cs:C1710.CustomerPaymentEntity; $all : Boolean)->$rows : Collection
	var $invoice : cs:C1710.JobInvoiceEntity
	var $line : cs:C1710.CustomerPaymentLineEntity
	var $mine : Object
	var $open : Real
	var $paymentUUID : Text
	var $row : Object

	$rows:=New collection:C1472
	If ($payment=Null:C1517) || cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($payment.UUID_Customer))
		return
	End if
	$paymentUUID:=String:C10($payment.UUID)
	$mine:=New object:C1471
	If ($payment.lines#Null:C1517)
		For each ($line; $payment.lines)
			$mine[$line.UUID_JobInvoice]:=New object:C1471("apply"; $line.amountApplied; "discount"; $line.discountTaken)
		End for each
	End if
	For each ($invoice; This:C1470.postedInvoicesOf($payment.UUID_Customer))
		$open:=This:C1470.openBalance($invoice; $paymentUUID)
		If ($mine[$invoice.UUID]=Null:C1517) && (($open<=0) || Not:C34($all))
			continue
		End if
		$row:=New object:C1471(\
			"UUID_JobInvoice"; $invoice.UUID; \
			"invoiceNumber"; $invoice.invoiceNumber; \
			"invoiceDate"; $invoice.invoiceDate; \
			"dueDate"; $invoice.dueDate; \
			"jobNumber"; ($invoice.job=Null:C1517) ? "" : String:C10($invoice.job.jobNumber); \
			"billed"; ($invoice.isLegacy) ? Round:C94($invoice.total; 2) : Round:C94($invoice.postedTotal; 2); \
			"open"; $open; \
			"apply"; ($mine[$invoice.UUID]=Null:C1517) ? 0 : Num:C11($mine[$invoice.UUID].apply); \
			"discount"; ($mine[$invoice.UUID]=Null:C1517) ? 0 : Num:C11($mine[$invoice.UUID].discount); \
			"suggestedDiscount"; This:C1470.suggestedDiscount($invoice; $payment.paymentDate; $open))
		$rows.push($row)
	End for each

	// Fills "apply" oldest due first with the amount received (and the customer's credit when the
	// payment is an "Apply credit" one of 0), discounts kept. Returns what is left.
Function autoApply($payment : cs:C1710.CustomerPaymentEntity; $rows : Collection)->$left : Real
	var $row : Object
	var $take : Real
	$left:=Round:C94($payment.amount; 2)
	If ($left=0)
		$left:=This:C1470.customerCredit($payment.UUID_Customer; String:C10($payment.UUID))
	End if
	For each ($row; $rows)
		$take:=Round:C94($row.open-$row.discount; 2)
		If ($take>$left)
			$take:=$left
		End if
		If ($take<0)
			$take:=0
		End if
		$row.apply:=$take
		$left:=Round:C94($left-$take; 2)
	End for each


	// MARK: - Payments: checks and posting

	// The problems of the payment with these rows ($result.errors: Save is refused), what only
	// warns, and the totals {applied; discounts; unapplied}.
Function checkPayment($payment : cs:C1710.CustomerPaymentEntity; $rows : Collection)->$result : Object
	var $errors; $warnings : Collection
	var $row : Object
	var $applied; $discounts; $unapplied; $available : Real
	var $date : Date
	var $account : cs:C1710.GLAccountEntity
	var $division; $money : Text
	var $old : cs:C1710.CustomerPaymentEntity

	$money:="###,###,##0.00"
	$errors:=New collection:C1472
	$warnings:=New collection:C1472
	$rows:=$rows || New collection:C1472
	$division:=This:C1470._uuidOr($payment.UUID_Division)
	$date:=$payment.paymentDate

	For each ($row; $rows)
		$row.apply:=Round:C94(Num:C11($row.apply); 2)
		$row.discount:=Round:C94(Num:C11($row.discount); 2)
		Case of
			: ($row.apply<0) || ($row.discount<0)
				$errors.push("Invoice "+String:C10($row.invoiceNumber)+": amounts are never negative.")
			: (Round:C94($row.apply+$row.discount-$row.open; 2)>0)
				$errors.push("Invoice "+String:C10($row.invoiceNumber)+": "+String:C10($row.apply+$row.discount; $money)+" applied, but only "+String:C10($row.open; $money)+" is open.")
		End case
		$applied:=$applied+$row.apply
		$discounts:=$discounts+$row.discount
	End for each
	$applied:=Round:C94($applied; 2)
	$discounts:=Round:C94($discounts; 2)
	$unapplied:=Round:C94($payment.amount-$applied; 2)

	Case of
		: ($payment.status="Void")
			$errors.push("The payment is void.")
		: ($payment.isLegacy)
			$errors.push("A credit imported from legacy cannot be changed: use it with an \"Apply credit\" payment.")
	End case
	If (cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($payment.UUID_Customer))) || ($payment.customer=Null:C1517)
		$errors.push("Choose the customer.")
	End if
	If ($date=!00-00-00!)
		$errors.push("The payment has no date.")
	Else
		If (Not:C34(cs:C1710.ga_ledger.me.isOpen($date)))
			$errors.push("The books are closed up to "+String:C10(cs:C1710.ga_ledger.me.closingDate())+": a payment dated "+String:C10($date)+" cannot be recorded or changed.")
		End if
	End if
	// a payment already in the books, now dated in a closed period, is locked
	If (Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($payment.UUID))))
		$old:=ds:C1482.CustomerPayment.get($payment.UUID)
		If ($old#Null:C1517) && ($old.status="Posted") && Not:C34(cs:C1710.ga_ledger.me.isOpen($old.paymentDate))
			$errors.push("This payment is dated "+String:C10($old.paymentDate)+", in a closed period: it is locked.")
		End if
	End if

	Case of
		: ($payment.amount<0)
			$errors.push("The amount received is never negative.")
		: ($payment.amount=0) && ($applied=0) && ($discounts=0)
			$errors.push("Type the amount received, or apply the customer's credit to an invoice.")
	End case
	If ($payment.amount>0)
		$account:=$payment.depositAccount
		Case of
			: ($account=Null:C1517)
				$errors.push("Choose where the money goes (Deposit to).")
			: ($account.removed)
				$errors.push("Account "+$account.label+" is inactive.")
		End case
	End if
	If ($unapplied<0) && Not:C34(cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($payment.UUID_Customer)))
		$available:=This:C1470.customerCredit($payment.UUID_Customer; String:C10($payment.UUID))
		If (-$unapplied>$available)
			$errors.push("The invoices get "+String:C10($applied; $money)+" but only "+String:C10($payment.amount; $money)+" was received"+Choose:C955($available>0; " and the customer has "+String:C10($available; $money)+" of credit"; "")+".")
		Else
			$warnings.push(String:C10(-$unapplied; $money)+" of the customer's credit is used.")
		End if
	End if
	If ($unapplied>0)
		$warnings.push(String:C10($unapplied; $money)+" is applied to no invoice: it is kept as a credit of the customer.")
	End if

	// the accounts
	If (($applied+$discounts)#0) && (cs:C1710.ga_ledger.me.defaultAccount("DefaultA/R"; $division)=Null:C1517)
		$errors.push("No account has the role Accounts receivable (Chart of Accounts).")
	End if
	If ($discounts#0) && (cs:C1710.ga_ledger.me.defaultAccount("DefaultSalesDiscounts"; $division)=Null:C1517)
		$errors.push("A discount is taken but no account has the role Sales discounts (Chart of Accounts: create e.g. \"Sales Discounts\", type Income, and give it that role).")
	End if
	If ($unapplied#0) && (cs:C1710.ga_ledger.me.defaultAccount("DefaultCustomerAdvance"; $division)=Null:C1517)
		$errors.push("No account has the role Customer advances (Chart of Accounts): it keeps the credit of the customer.")
	End if

	$result:=New object:C1471("success"; $errors.length=0; "errors"; $errors; "warnings"; $warnings; \
		"applied"; $applied; "discounts"; $discounts; "unapplied"; $unapplied)

	// Writes the lines of the payment from the rows (rows of 0 are not kept), its unapplied amount
	// and status, saves it and posts it. Call it inside a transaction (the panel's, or your own):
	// it does not check (call checkPayment first). $result: {success; errors}
Function writePayment($payment : cs:C1710.CustomerPaymentEntity; $rows : Collection)->$result : Object
	var $row : Object
	var $eLine : cs:C1710.CustomerPaymentLineEntity
	var $existing : cs:C1710.CustomerPaymentLineSelection
	var $applied : Real
	var $save : Object

	$result:=New object:C1471("success"; True:C214; "errors"; New collection:C1472)
	$rows:=$rows || New collection:C1472
	If ($payment.UUID=Null:C1517) || ($payment.UUID="")
		$payment.UUID:=Generate UUID:C1066
	End if
	If ($payment.number=0)
		$payment.number:=ds:C1482.sfw_Counter.getNextValue("CustomerPayment")
	End if
	For each ($row; $rows)
		$applied:=$applied+Round:C94(Num:C11($row.apply); 2)
	End for each
	$payment.unappliedAmount:=Round:C94($payment.amount-$applied; 2)
	$payment.status:="Posted"
	If ($payment.postedStmp=0)
		$payment.postedStmp:=cs:C1710.sfw_stmp.me.now()
		$payment.UUID_PostedBy:=cs:C1710.ga_ledger.me._currentUserUUID()
	End if
	If ($payment.method="") && ($payment.amount=0)
		$payment.method:="Credit"
	End if
	$save:=$payment.save()
	If (Not:C34($save.success))
		$result.success:=False:C215
		$result.errors.push("The payment could not be saved: "+String:C10($save.statusText))
		return
	End if

	$existing:=ds:C1482.CustomerPaymentLine.query("UUID_CustomerPayment = :1"; $payment.UUID)
	If ($existing.length>0)
		$existing.drop()
	End if
	For each ($row; $rows)
		If (Round:C94(Num:C11($row.apply); 2)=0) && (Round:C94(Num:C11($row.discount); 2)=0)
			continue
		End if
		$eLine:=ds:C1482.CustomerPaymentLine.new()
		$eLine.UUID_CustomerPayment:=$payment.UUID
		$eLine.UUID_JobInvoice:=$row.UUID_JobInvoice
		$eLine.amountApplied:=Round:C94(Num:C11($row.apply); 2)
		$eLine.discountTaken:=Round:C94(Num:C11($row.discount); 2)
		$eLine.moreData:=New object:C1471
		$save:=$eLine.save()
		If (Not:C34($save.success))
			$result.success:=False:C215
			$result.errors.push("Invoice "+String:C10($row.invoiceNumber)+": the line could not be saved: "+String:C10($save.statusText))
		End if
	End for each
	If ($result.success)
		$result:=This:C1470.postPayment($payment)
	End if

	// (re)writes the entry of a saved payment from its lines. A legacy credit has no entry.
Function postPayment($payment : cs:C1710.CustomerPaymentEntity)->$result : Object
	If ($payment.isLegacy)
		$result:=New object:C1471("success"; True:C214; "errors"; New collection:C1472)
		return
	End if
	$result:=cs:C1710.ga_ledger.me.post(This:C1470._spec($payment))

	// Voids a saved payment in its own transaction: its entry is voided, the invoices are open
	// again, the lines stay (they no longer count). Refused in a closed period, for a legacy
	// credit, and when the credit it left was already used by another payment.
Function voidPayment($payment : cs:C1710.CustomerPaymentEntity)->$result : Object
	var $res; $save : Object
	$result:=New object:C1471("success"; False:C215; "errors"; This:C1470.checkVoid($payment))
	If ($result.errors.length>0)
		return
	End if
	ds:C1482.startTransaction()
	$res:=cs:C1710.ga_ledger.me.unpost("CustomerPayment"; $payment.UUID)
	If ($res.success)
		$payment.status:="Void"
		$save:=$payment.save()
		If (Not:C34($save.success))
			$res.success:=False:C215
			$res.errors.push("The payment could not be saved: "+String:C10($save.statusText))
		End if
	End if
	If (Not:C34($res.success))
		ds:C1482.cancelTransaction()
		$payment.reload()
		$result.errors:=$res.errors
		return
	End if
	ds:C1482.validateTransaction()
	$result.success:=True:C214

Function checkVoid($payment : cs:C1710.CustomerPaymentEntity)->$errors : Collection
	$errors:=New collection:C1472
	Case of
		: ($payment=Null:C1517)
			$errors.push("No payment.")
		: ($payment.status="Void")
			$errors.push("The payment is already void.")
		: ($payment.isLegacy)
			$errors.push("A credit imported from legacy is in the opening balance: correct it with a journal entry.")
		: (Not:C34(cs:C1710.ga_ledger.me.isOpen($payment.paymentDate)))
			$errors.push("The payment is dated "+String:C10($payment.paymentDate)+", in a closed period (books closed up to "+String:C10(cs:C1710.ga_ledger.me.closingDate())+").")
		: ($payment.unappliedAmount>0) && (This:C1470.customerCredit($payment.UUID_Customer; $payment.UUID)<0)
			$errors.push("The credit this payment left was already used by another payment: void that one first.")
	End case


	// MARK: - Private

	// the ga_ledger.post spec of a saved payment (lines read from the database)
Function _spec($payment : cs:C1710.CustomerPaymentEntity)->$spec : Object
	var $lines : Collection
	var $division; $customerUUID; $text; $customerName : Text
	var $applied; $discounts; $unapplied : Real
	var $paid : cs:C1710.CustomerPaymentLineSelection

	$division:=This:C1470._uuidOr($payment.UUID_Division)
	$customerUUID:=$payment.UUID_Customer
	$customerName:=($payment.customer=Null:C1517) ? "" : $payment.customer.name
	$paid:=ds:C1482.CustomerPaymentLine.query("UUID_CustomerPayment = :1"; $payment.UUID)
	$applied:=Round:C94($paid.sum("amountApplied"); 2)
	$discounts:=Round:C94($paid.sum("discountTaken"); 2)
	$unapplied:=Round:C94($payment.amount-$applied; 2)
	$text:=(($payment.amount=0) ? "Credit applied" : "Payment")+" #"+String:C10($payment.number)+" - "+$customerName+(($payment.reference="") ? "" : " - "+$payment.reference)

	$lines:=New collection:C1472
	If ($payment.amount#0)
		$lines.push(New object:C1471("UUID_GLAccount"; $payment.UUID_DepositAccount; "debit"; Round:C94($payment.amount; 2); "credit"; 0; "memo"; $text; "UUID_Customer"; $customerUUID))
	End if
	If ($discounts#0)
		$lines.push(New object:C1471("UUID_GLAccount"; cs:C1710.ga_ledger.me.defaultAccount("DefaultSalesDiscounts"; $division).UUID; "debit"; $discounts; "credit"; 0; "memo"; "Discounts taken"; "UUID_Customer"; $customerUUID))
	End if
	If (($applied+$discounts)#0)
		$lines.push(New object:C1471("UUID_GLAccount"; cs:C1710.ga_ledger.me.defaultAccount("DefaultA/R"; $division).UUID; "debit"; 0; "credit"; Round:C94($applied+$discounts; 2); "memo"; "Invoices paid: "+$paid.extract("invoice.invoiceNumber").join(", "); "UUID_Customer"; $customerUUID))
	End if
	Case of
		: ($unapplied>0)
			$lines.push(New object:C1471("UUID_GLAccount"; cs:C1710.ga_ledger.me.defaultAccount("DefaultCustomerAdvance"; $division).UUID; "debit"; 0; "credit"; $unapplied; "memo"; "Credit kept for the customer"; "UUID_Customer"; $customerUUID))
		: ($unapplied<0)
			$lines.push(New object:C1471("UUID_GLAccount"; cs:C1710.ga_ledger.me.defaultAccount("DefaultCustomerAdvance"; $division).UUID; "debit"; -$unapplied; "credit"; 0; "memo"; "Customer credit used"; "UUID_Customer"; $customerUUID))
	End case
	$spec:=New object:C1471("type"; "Payment"; "sourceDataclass"; "CustomerPayment"; "sourceUUID"; $payment.UUID; \
		"date"; $payment.paymentDate; "memo"; $text+(($payment.memo="") ? "" : " - "+$payment.memo); "divisionUUID"; $division; "lines"; $lines)

Function _uuidOr($value : Variant)->$uuid : Text
	$uuid:=String:C10($value)
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($uuid))
		$uuid:=This:C1470._noUUID
	End if
