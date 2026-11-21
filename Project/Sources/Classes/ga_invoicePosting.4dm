// ga_invoicePosting: putting a customer invoice (JobInvoice) into the books, the QuickBooks way.
//
// For someone new to accounting: an invoice says "the customer owes us this". Posting it writes
// one journal entry (ga_ledger) that day:
//   Dr  Accounts receivable (what customers owe), with the customer on the line ... the total
//   Cr  Income (the process's sales account) ............................... the work billed
//   Cr  Freight billed (role DefaultFreightIncome, else the income account) .. the freight
//   Cr  Sales tax payable (collected for the state, not ours) ............... the tax
// Debits = credits because total = work + freight + tax.
//
// The life of an invoice (JobInvoice.status):
//   Draft   being prepared (lots, PO lines, charges): not in the books.
//   Posted  in the books (Post action). Its total is added to the customer PO's billed amount
//           and the job is marked invoiced (postToPO, as legacy). It may still be edited while
//           its month is open: the entry and the PO are corrected on Save (repost).
//   Void    cancelled: the entry is voided and the PO gets the amount back. The number stays.
// "Unpost" puts a posted invoice back to Draft (legacy SubrUnPostInvoice).
// Invoices posted in legacy (job.postToPO already True, or isLegacy) have no entry here: their
// amount is inside the opening balance. They cannot be unposted or voided here.
//
// The rules kept from legacy SubrPostInvoice / SubrAdjustPO: the job must be shipped, the PO must
// exist, not be closed, belong to the job's division and have enough money left (an open PO has
// no limit; going over by less than the tax only warns, as IsPOShort did).
// The income account: the job's GL Acc when set, else the sales sub-account of the job's process
// ("Burn-In-GAC" = Sales12GA), created under the Sales account when missing (legacy
// CreateSubIncomeAccount), else the account with the role Sales.
singleton Class constructor


	// MARK: - State

	// Draft, Posted, Posted in legacy, Partially paid, Paid, Void (the payments: ga_receivables)
Function stateText($invoice : cs:C1710.JobInvoiceEntity)->$text : Text
	var $paid : Text
	Case of
		: ($invoice=Null:C1517)
			$text:=""
		: ($invoice.status="Void")
			$text:="Void"
		: ($invoice.status="Posted") && Not:C34($invoice.isLegacy)
			$text:="Posted"
		: (This:C1470.isLegacyPosted($invoice))
			$text:="Posted in legacy"
		Else
			$text:="Draft"
	End case
	If ($text="Posted") || ($text="Posted in legacy")
		$paid:=cs:C1710.ga_receivables.me.paymentState($invoice)
		If ($paid#"")
			$text:=$paid
		End if
	End if

	// in the books through this application (it has a journal entry)
Function isPosted($invoice : cs:C1710.JobInvoiceEntity)->$posted : Boolean
	$posted:=($invoice.status="Posted") && Not:C34($invoice.isLegacy)

	// posted before this application: the amount is in the legacy opening balance
Function isLegacyPosted($invoice : cs:C1710.JobInvoiceEntity)->$legacy : Boolean
	Case of
		: ($invoice.status="Void")
		: ($invoice.isLegacy)
			$legacy:=True:C214
		: ($invoice.status="Posted")
		: ($invoice.job#Null:C1517)
			$legacy:=$invoice.job.postToPO
	End case

	// the date the invoice is in the books on: its own, else the job's, else today
Function accountingDate($invoice : cs:C1710.JobInvoiceEntity)->$date : Date
	$date:=$invoice.invoiceDate
	If ($date=!00-00-00!) && ($invoice.job#Null:C1517)
		$date:=$invoice.job.invoiceDate
	End if
	If ($date=!00-00-00!)
		$date:=Current date:C33
	End if

	// total, tax, freight and the work billed (income), rounded to the cent
Function amounts($invoice : cs:C1710.JobInvoiceEntity)->$amounts : Object
	$amounts:=New object:C1471("total"; Round:C94($invoice.total; 2); "tax"; 0; "freight"; 0)
	If ($invoice.job#Null:C1517)
		$amounts.tax:=Round:C94($invoice.job.totalTax; 2)
		$amounts.freight:=Round:C94($invoice.job.freight; 2)
	End if
	$amounts.income:=Round:C94($amounts.total-$amounts.tax-$amounts.freight; 2)

	// the customer of the invoice: the job's, else the PO's
Function customerOf($invoice : cs:C1710.JobInvoiceEntity)->$customer : cs:C1710.CustomerEntity
	If ($invoice.job#Null:C1517)
		$customer:=$invoice.job.customer
		If ($customer=Null:C1517) && ($invoice.job.purchaseOrder#Null:C1517)
			$customer:=$invoice.job.purchaseOrder.customer
		End if
	End if

	// what a customer owes: the open balance of its invoices (posted here, or imported open from
	// legacy), less the credit it has (ga_receivables). Not read from the A/R lines: the legacy
	// invoices are inside the opening balance, which has no customer.
Function customerBalance($customerUUID : Text)->$balance : Real
	$balance:=cs:C1710.ga_receivables.me.customerBalance($customerUUID)

	// the term of the invoice: the customer's, else the default one (may be Null)
Function termOf($customer : cs:C1710.CustomerEntity)->$term : cs:C1710.PaymentTermEntity
	If ($customer#Null:C1517)
		$term:=$customer.paymentTerm
	End if
	If ($term=Null:C1517)
		$term:=ds:C1482.PaymentTerm.defaultTerm()
	End if


	// MARK: - Income account

	// {account; create (Boolean: a process account to create); name; problem}
Function incomeAccount($job : cs:C1710.JobEntity)->$result : Object
	var $sales; $account : cs:C1710.GLAccountEntity
	var $processName : Text

	$result:=New object:C1471("account"; Null:C1517; "create"; False:C215; "name"; ""; "problem"; "")
	If ($job=Null:C1517)
		$result.problem:="The invoice has no job."
		return
	End if
	If (cs:C1710.sfw_string.me.trimSpace($job.glAcc)#"")
		$account:=cs:C1710.ga_ledger.me.accountByGlac(cs:C1710.sfw_string.me.trimSpace($job.glAcc))
		Case of
			: ($account=Null:C1517)
				$result.problem:="The job's GL Acc \""+$job.glAcc+"\" is not in the chart of accounts."
			: ($account.removed)
				$result.problem:="The job's GL Acc "+$account.label+" is inactive."
			Else
				$result.account:=$account
		End case
		return
	End if
	$sales:=cs:C1710.ga_ledger.me.defaultAccount("DefaultSales"; $job.UUID_Division)
	If ($sales=Null:C1517)
		$result.problem:="No account has the role Sales (Chart of Accounts)."
		return
	End if
	If (cs:C1710.sfw_string.me.trimSpace($job.process)="")
		$result.account:=$sales
		return
	End if
	$processName:=This:C1470._processAccountName($job)
	$account:=ds:C1482.GLAccount.query("description = :1 AND parentAccountName = :2 AND removed = :3"; $processName; $sales.glac; False:C215).first()
	If ($account#Null:C1517)
		$result.account:=$account
	Else
		$result.account:=$sales
		$result.create:=True:C214
		$result.name:=$processName
	End if

	// legacy CodeProcessNameForGLAccs: "<process>-<division>"
Function _processAccountName($job : cs:C1710.JobEntity)->$name : Text
	$name:=cs:C1710.sfw_string.me.trimSpace($job.process)+"-"+(($job.division=Null:C1517) ? "GAC" : $job.division.name)

	// legacy CreateSubIncomeAccount "AddAccount": Sales<n><2 letters of the division>, under Sales
Function _createProcessAccount($job : cs:C1710.JobEntity; $sales : cs:C1710.GLAccountEntity)->$account : cs:C1710.GLAccountEntity
	var $suffix; $glac : Text
	var $n : Integer
	$suffix:=Substring:C12((($job.division=Null:C1517) ? "GAC" : $job.division.name); 1; 2)
	Repeat
		$n:=$n+1
		$glac:="Sales"+String:C10($n)+$suffix
	Until (ds:C1482.GLAccount.query("glac = :1"; $glac).length=0)
	$account:=ds:C1482.GLAccount.new()
	$account.glac:=$glac
	$account.fullAccountName:=$glac
	$account.description:=This:C1470._processAccountName($job)
	$account.accountType:="Income"
	$account.accountTypeCode:=8
	$account.parentAccountName:=$sales.glac
	$account.subAccount:=True:C214
	$account.subLevel:=1
	$account.UUID_Division:=$sales.UUID_Division
	$account.defaultKey:=""
	$account.buyItemType:=""
	$account.moreData:=New object:C1471("createdBy"; "ga_invoicePosting"; "createdAt"; cs:C1710.sfw_stmp.me.now(); "process"; $job.process)
	$account.save()


	// MARK: - Checks

	// What stops the posting (errors) and what only warns (warnings), on $date.
Function checkPost($invoice : cs:C1710.JobInvoiceEntity; $date : Date)->$check : Object
	var $job : cs:C1710.JobEntity
	var $po : cs:C1710.PurchaseOrderEntity
	var $customer : cs:C1710.CustomerEntity
	var $amounts; $income : Object
	var $over; $balance : Real

	$check:=New object:C1471("errors"; New collection:C1472; "warnings"; New collection:C1472)
	$job:=$invoice.job
	$amounts:=This:C1470.amounts($invoice)
	Case of
		: ($invoice.status="Void")
			$check.errors.push("The invoice is void.")
		: (This:C1470.isPosted($invoice))
			$check.errors.push("The invoice is already posted.")
		: (This:C1470.isLegacyPosted($invoice))
			$check.errors.push("The invoice was posted in legacy: its amount is already in the books.")
		: ($job=Null:C1517)
			$check.errors.push("The invoice has no job.")
	End case
	If ($check.errors.length>0)
		return
	End if

	If (Not:C34($job.shipped))
		$check.errors.push("Job "+String:C10($job.jobNumber)+" is not shipped. Invoice not posted (legacy rule).")
	End if
	If ($amounts.total=0)
		$check.errors.push("The invoice total is 0.")
	End if
	If ($amounts.income<0)
		$check.errors.push("Tax ("+String:C10($amounts.tax)+") and freight ("+String:C10($amounts.freight)+") are more than the total ("+String:C10($amounts.total)+").")
	End if
	If (Not:C34(cs:C1710.ga_ledger.me.isOpen($date)))
		$check.errors.push("The books are closed up to "+String:C10(cs:C1710.ga_ledger.me.closingDate())+": an invoice dated "+String:C10($date)+" cannot be posted.")
	End if

	// the customer PO (legacy RelateOneJobToPO / SubrAdjustPO)
	$po:=$job.purchaseOrder
	Case of
		: ($po=Null:C1517)
			$check.errors.push("The job has no valid customer PO. Invoice not posted.")
		: ($po.closed)
			$check.errors.push("PO "+String:C10($po.poNumber)+" is closed. Invoice not posted.")
		: ($po.division#"") && ($job.division#Null:C1517) && ($po.division#$job.division.name)
			$check.errors.push("PO "+String:C10($po.poNumber)+" belongs to division "+$po.division+", the job to "+$job.division.name+". Invoice not posted.")
		: (Not:C34($po.openPO))
			$over:=Round:C94($po.amountBilled+$amounts.total-$po.poAmount; 2)
			Case of
				: ($over>($amounts.tax+1))
					$check.errors.push("PO "+String:C10($po.poNumber)+" has not enough money left: it would be over by "+String:C10($over; "###,###,##0.00")+" (PO "+String:C10($po.poAmount; "###,###,##0.00")+", already billed "+String:C10($po.amountBilled; "###,###,##0.00")+").")
				: ($over>0.01)
					$check.warnings.push("PO "+String:C10($po.poNumber)+" goes over by "+String:C10($over; "###,###,##0.00")+" (less than the tax).")
			End case
	End case

	// the customer and its credit
	$customer:=This:C1470.customerOf($invoice)
	If ($customer=Null:C1517)
		$check.errors.push("The invoice has no customer (job and PO).")
	Else
		If ($customer.creditHold)
			$check.warnings.push($customer.name+" is on credit hold"+Choose:C955($customer.creditHoldReason=""; ""; ": "+$customer.creditHoldReason)+".")
		End if
		If ($customer.creditLimit>0)
			$balance:=This:C1470.customerBalance($customer.UUID)
			If (($balance+$amounts.total)>$customer.creditLimit)
				$check.warnings.push($customer.name+" would owe "+String:C10($balance+$amounts.total; "###,###,##0.00")+", above its credit limit of "+String:C10($customer.creditLimit; "###,###,##0.00")+".")
			End if
		End if
	End if

	// the accounts
	If (cs:C1710.ga_ledger.me.defaultAccount("DefaultA/R"; $job.UUID_Division)=Null:C1517)
		$check.errors.push("No account has the role Accounts receivable (Chart of Accounts).")
	End if
	If ($amounts.tax#0) && (cs:C1710.ga_ledger.me.defaultAccount("DefaultSalesTaxPayable"; $job.UUID_Division)=Null:C1517)
		$check.errors.push("No account has the role Sales tax payable (Chart of Accounts).")
	End if
	$income:=This:C1470.incomeAccount($job)
	If ($income.problem#"")
		$check.errors.push($income.problem)
	End if
	If ($income.create)
		$check.warnings.push("A sales account will be created for the process \""+$income.name+"\" (under "+$income.account.label+"), as legacy did.")
	End if


	// MARK: - Post / repost / unpost

	// Posts $invoice on $date (!00-00-00!: its date, else today), in its own transaction.
	// $result: {success; errors; warnings; entryNumber}
Function post($invoice : cs:C1710.JobInvoiceEntity; $date : Date)->$result : Object
	var $check; $income; $res; $amounts : Object
	var $job : cs:C1710.JobEntity
	var $po : cs:C1710.PurchaseOrderEntity
	var $customer : cs:C1710.CustomerEntity
	var $term : cs:C1710.PaymentTermEntity
	var $account : cs:C1710.GLAccountEntity

	If ($date=!00-00-00!)
		$date:=This:C1470.accountingDate($invoice)
	End if
	$check:=This:C1470.checkPost($invoice; $date)
	$result:=New object:C1471("success"; False:C215; "errors"; $check.errors; "warnings"; $check.warnings; "entryNumber"; 0)
	If ($check.errors.length>0)
		return
	End if

	$job:=$invoice.job
	$po:=$job.purchaseOrder
	$customer:=This:C1470.customerOf($invoice)
	$amounts:=This:C1470.amounts($invoice)

	ds:C1482.startTransaction()
	$income:=This:C1470.incomeAccount($job)
	$account:=$income.account
	If ($income.create)
		$account:=This:C1470._createProcessAccount($job; $income.account)
	End if

	// the invoice first: the entry reads its date and customer
	$term:=This:C1470.termOf($customer)
	$invoice.invoiceDate:=$date
	$invoice.UUID_Customer:=$customer.UUID
	$invoice.UUID_PaymentTerm:=($term=Null:C1517) ? ("0"*32) : $term.UUID
	$invoice.dueStmp:=cs:C1710.sfw_stmp.me.build(($term=Null:C1517) ? Add to date:C393($date; 0; 0; 30) : $term.dueDate($date); ?00:00:00?)
	$invoice.status:="Posted"
	$invoice.isLegacy:=False:C215
	$invoice.postedStmp:=cs:C1710.sfw_stmp.me.now()
	$invoice.UUID_PostedBy:=cs:C1710.ga_ledger.me._currentUserUUID()
	$invoice.postedTotal:=$amounts.total
	$invoice.moreData:=$invoice.moreData || New object:C1471
	$invoice.moreData.posting:=New object:C1471("incomeAccount"; $account.glac; "amounts"; $amounts; "date"; String:C10($date))

	$res:=cs:C1710.ga_ledger.me.post(This:C1470._spec($invoice; $date; $amounts; $account))
	If ($res.success)
		$res:=This:C1470._saveAll($invoice; $job; $po; $amounts.total; $date; True:C214)
	End if
	If (Not:C34($res.success))
		ds:C1482.cancelTransaction()
		$invoice.reload()
		$result.errors:=$res.errors
		return
	End if
	ds:C1482.validateTransaction()
	$result.success:=True:C214
	$result.entryNumber:=cs:C1710.ga_ledger.me.entriesOf("JobInvoice"; $invoice.UUID).query("isVoid = :1"; False:C215).first().number
	If ($income.create)
		$result.warnings.push("Sales account "+$account.label+" created.")
	End if

	// A posted invoice was edited and saved (JobInvoiceEntity.afterSave, inside the panel's
	// transaction): the entry is rewritten and the PO gets the difference.
Function repost($invoice : cs:C1710.JobInvoiceEntity)->$result : Object
	var $amounts; $income : Object
	var $date : Date
	var $account : cs:C1710.GLAccountEntity
	var $customer : cs:C1710.CustomerEntity
	var $term : cs:C1710.PaymentTermEntity
	var $delta : Real

	$result:=New object:C1471("success"; True:C214; "errors"; New collection:C1472)
	If (Not:C34(This:C1470.isPosted($invoice)))
		return
	End if
	If (This:C1470._sameAsPosted($invoice))
		// nothing that counts changed (a note, a field of the job): the entry is left as it is
		return
	End if
	$date:=This:C1470.accountingDate($invoice)
	$amounts:=This:C1470.amounts($invoice)
	$income:=This:C1470.incomeAccount($invoice.job)
	If ($income.problem#"") || ($amounts.income<0)
		$result.success:=False:C215
		$result.errors.push(($income.problem#"") ? $income.problem : "Tax and freight are more than the total.")
		return
	End if
	$account:=$income.account
	If ($income.create)
		$account:=This:C1470._createProcessAccount($invoice.job; $income.account)
	End if
	$result:=cs:C1710.ga_ledger.me.post(This:C1470._spec($invoice; $date; $amounts; $account))
	If (Not:C34($result.success))
		return
	End if
	$delta:=Round:C94($amounts.total-$invoice.postedTotal; 2)
	$term:=$invoice.paymentTerm
	If ($term#Null:C1517)
		$invoice.dueStmp:=cs:C1710.sfw_stmp.me.build($term.dueDate($date); ?00:00:00?)
	End if
	$invoice.postedTotal:=$amounts.total
	$invoice.moreData:=$invoice.moreData || New object:C1471
	$invoice.moreData.posting:=New object:C1471("incomeAccount"; $account.glac; "amounts"; $amounts; "date"; String:C10($date))
	$result:=This:C1470._saveAll($invoice; $invoice.job; $invoice.job.purchaseOrder; $delta; $date; True:C214)

	// Takes a posted invoice out of the books: back to "Draft" (unpost) or "Void". Its own
	// transaction. The entry is voided and the PO gets the amount back.
Function unpost($invoice : cs:C1710.JobInvoiceEntity; $newStatus : Text)->$result : Object
	var $res : Object
	var $date : Date
	var $job : cs:C1710.JobEntity

	$result:=New object:C1471("success"; False:C215; "errors"; New collection:C1472; "warnings"; New collection:C1472)
	$date:=This:C1470.accountingDate($invoice)
	Case of
		: ($invoice.status="Void")
			$result.errors.push("The invoice is already void.")
		: (This:C1470.isLegacyPosted($invoice))
			$result.errors.push("The invoice was posted in legacy: its amount is in the opening balance. Correct it with a credit memo or a journal entry.")
		: (Not:C34(This:C1470.isPosted($invoice))) && ($newStatus="Draft")
			$result.errors.push("The invoice is not posted.")
		: (This:C1470.isPosted($invoice)) && Not:C34(cs:C1710.ga_ledger.me.isOpen($date))
			$result.errors.push("The invoice is dated "+String:C10($date)+", in a closed period (books closed up to "+String:C10(cs:C1710.ga_ledger.me.closingDate())+").")
		: (cs:C1710.ga_receivables.me.hasPayments($invoice))
			$result.errors.push("Payments are applied to the invoice: void them, or take the invoice out of them, first (Receive payment).")
	End case
	If ($result.errors.length>0)
		return
	End if

	$job:=$invoice.job
	ds:C1482.startTransaction()
	If (This:C1470.isPosted($invoice))
		$res:=cs:C1710.ga_ledger.me.unpost("JobInvoice"; $invoice.UUID)
		If ($res.success)
			$res:=This:C1470._saveAll($invoice; $job; ($job=Null:C1517) ? Null:C1517 : $job.purchaseOrder; -$invoice.postedTotal; $date; False:C215)
		End if
	Else
		$res:=New object:C1471("success"; True:C214; "errors"; New collection:C1472)  // a draft voided: nothing in the books
	End if
	If ($res.success)
		$invoice.status:=$newStatus
		$invoice.postedTotal:=0
		$invoice.postedStmp:=0
		$invoice.UUID_PostedBy:="0"*32
		$res:=This:C1470._save($invoice; $res)
	End if
	If (Not:C34($res.success))
		ds:C1482.cancelTransaction()
		$invoice.reload()
		$result.errors:=$res.errors
		return
	End if
	ds:C1482.validateTransaction()
	$result.success:=True:C214


	// MARK: - Private

	// same date and amounts as when it was last written to the books (moreData.posting)
Function _sameAsPosted($invoice : cs:C1710.JobInvoiceEntity)->$same : Boolean
	var $last; $now : Object
	If ($invoice.moreData=Null:C1517) || ($invoice.moreData.posting=Null:C1517)
		return
	End if
	$last:=$invoice.moreData.posting
	$now:=This:C1470.amounts($invoice)
	$same:=(String:C10($last.date)=String:C10(This:C1470.accountingDate($invoice))) && \
		(Num:C11($last.amounts.total)=$now.total) && (Num:C11($last.amounts.tax)=$now.tax) && (Num:C11($last.amounts.freight)=$now.freight)

	// the ga_ledger.post spec of the invoice
Function _spec($invoice : cs:C1710.JobInvoiceEntity; $date : Date; $amounts : Object; $income : cs:C1710.GLAccountEntity)->$spec : Object
	var $division; $customerUUID; $text : Text
	var $freight; $ar; $tax : cs:C1710.GLAccountEntity
	var $lines : Collection
	var $line : Object
	var $swap : Real
	var $customer : cs:C1710.CustomerEntity

	$division:=$invoice.job.UUID_Division
	If (cs:C1710.sfw_string.me.isAnEmptyUUID($invoice.UUID_Customer))
		$customer:=This:C1470.customerOf($invoice)
		If ($customer#Null:C1517)
			$invoice.UUID_Customer:=$customer.UUID
		End if
	End if
	$customerUUID:=$invoice.UUID_Customer
	$customer:=$invoice.customer
	$ar:=cs:C1710.ga_ledger.me.defaultAccount("DefaultA/R"; $division)
	$tax:=cs:C1710.ga_ledger.me.defaultAccount("DefaultSalesTaxPayable"; $division)
	$freight:=cs:C1710.ga_ledger.me.defaultAccount("DefaultFreightIncome"; $division)
	If ($freight=Null:C1517)
		$freight:=$income  // legacy: the freight went to income
	End if
	$text:="Invoice "+$invoice.invoiceNumber+" - job "+String:C10($invoice.job.jobNumber)+(($customer=Null:C1517) ? "" : " - "+$customer.name)

	$lines:=New collection:C1472
	$lines.push(New object:C1471("UUID_GLAccount"; $ar.UUID; "debit"; $amounts.total; "credit"; 0; "memo"; $text; "UUID_Customer"; $customerUUID))
	If ($amounts.income#0)
		$lines.push(New object:C1471("UUID_GLAccount"; $income.UUID; "debit"; 0; "credit"; $amounts.income; "memo"; "Work billed"; "UUID_Customer"; $customerUUID))
	End if
	If ($amounts.freight#0)
		$lines.push(New object:C1471("UUID_GLAccount"; $freight.UUID; "debit"; 0; "credit"; $amounts.freight; "memo"; "Freight billed"; "UUID_Customer"; $customerUUID))
	End if
	If ($amounts.tax#0)
		$lines.push(New object:C1471("UUID_GLAccount"; $tax.UUID; "debit"; 0; "credit"; $amounts.tax; "memo"; "Sales tax collected"; "UUID_Customer"; $customerUUID))
	End if
	// a negative total (a credit invoice) puts each amount in the other column
	For each ($line; $lines)
		If ($line.debit<0) || ($line.credit<0)
			$swap:=-$line.debit
			$line.debit:=-$line.credit
			$line.credit:=$swap
		End if
	End for each
	$spec:=New object:C1471("type"; "Invoice"; "sourceDataclass"; "JobInvoice"; "sourceUUID"; $invoice.UUID; "date"; $date; \
		"memo"; $text; "divisionUUID"; $division; "lines"; $lines)

	// the invoice, the job (invoiced or not) and the PO (billed amount + $poDelta)
Function _saveAll($invoice : cs:C1710.JobInvoiceEntity; $job : cs:C1710.JobEntity; $po : cs:C1710.PurchaseOrderEntity; $poDelta : Real; $date : Date; $invoiced : Boolean)->$result : Object
	var $save : Object
	$result:=New object:C1471("success"; True:C214; "errors"; New collection:C1472)
	If ($po#Null:C1517) && ($poDelta#0)
		$po.amountBilled:=Round:C94($po.amountBilled+$poDelta; 2)
		$result:=This:C1470._save($po; $result)
	End if
	If ($job#Null:C1517)
		$job.postToPO:=$invoiced
		If ($invoiced)
			$job.invoiceDate:=$date
		End if
		$result:=This:C1470._save($job; $result)
	End if
	$result:=This:C1470._save($invoice; $result)

Function _save($entity : 4D:C1709.Entity; $result : Object)->$out : Object
	var $save : Object
	$out:=$result
	$save:=$entity.save()
	If (Not:C34($save.success))
		$out.success:=False:C215
		$out.errors.push(String:C10($entity.getDataClass().getInfo().name)+" could not be saved: "+String:C10($save.statusText))
	End if
