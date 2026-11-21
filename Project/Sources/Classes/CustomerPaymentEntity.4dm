// CustomerPaymentEntity: see CustomerPayment and ga_receivables.
// The panel (panel_customerPayment) keeps the invoice rows in Form.cpRows while the payment is
// edited; after the save, writePayment writes the lines and the journal entry (inside the sfw
// transaction: Cancel puts everything back).
Class extends Entity

local Function get paymentDate()->$date : Date
	$date:=(This:C1470.paymentStmp=0) ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.paymentStmp)

local Function set paymentDate($date : Date)
	This:C1470.paymentStmp:=($date=!00-00-00!) ? 0 : cs:C1710.sfw_stmp.me.build($date; ?00:00:00?)

local Function get stateText()->$text : Text
	Case of
		: (This:C1470.status="Void")
			$text:="Void"
		: (This:C1470.isLegacy)
			$text:="From legacy"
		: (This:C1470.status="Posted")
			$text:="Posted"
		Else
			$text:="New"
	End case

local Function get methodText()->$text : Text
	var $o : Object
	$o:=ds:C1482.CustomerPayment.methods().query("method = :1"; This:C1470.method).first()
	$text:=($o=Null:C1517) ? This:C1470.method : $o.label

local Function get nameInWindowTitle()->$name : Text
	$name:="Payment "+((This:C1470.number=0) ? "(new)" : "#"+String:C10(This:C1470.number))+((This:C1470.customer=Null:C1517) ? "" : " - "+This:C1470.customer.name)

	// can be changed in the panel: not void, not a legacy credit, dated after the closing date
local Function get isEditable()->$editable : Boolean
	Case of
		: (This:C1470.status="Void")
		: (This:C1470.isLegacy)
		: (This:C1470.paymentStmp=0)
			$editable:=True:C214
		Else
			$editable:=cs:C1710.ga_ledger.me.isOpen(This:C1470.paymentDate)
	End case

local Function get canVoid()->$can : Boolean
	$can:=(This:C1470.status="Posted") && (cs:C1710.ga_receivables.me.checkVoid(This:C1470).length=0)

local Function get appliedAmount()->$amount : Real
	$amount:=Round:C94(This:C1470.lines.sum("amountApplied"); 2)

local Function get discountAmount()->$amount : Real
	$amount:=Round:C94(This:C1470.lines.sum("discountTaken"); 2)


	// MARK: - sfw callbacks

local Function loadAfterCreation()
	var $account : cs:C1710.GLAccountEntity
	This:C1470.number:=0  // given at the save, so a cancelled payment leaves no hole
	This:C1470.paymentDate:=Current date:C33
	This:C1470.UUID_Customer:="0"*32
	This:C1470.method:="Check"
	This:C1470.status:=""
	This:C1470.UUID_PostedBy:="0"*32
	This:C1470.UUID_Division:="0"*32
	This:C1470.isLegacy:=False:C215
	$account:=cs:C1710.ga_ledger.me.defaultAccount("UndepositedFunds"; "")
	This:C1470.UUID_DepositAccount:=($account=Null:C1517) ? ("0"*32) : $account.UUID
	This:C1470.moreData:=New object:C1471

local Function beforeSaveCreation()
	// a new number, never posted yet (a duplicated payment arrives with its original's)
	This:C1470.number:=ds:C1482.sfw_Counter.getNextValue("CustomerPayment")
	This:C1470.postedStmp:=0
	This:C1470.status:=""
	This:C1470.isLegacy:=False:C215

local Function afterCreation()
	This:C1470._writePanelRows()

local Function afterSave()
	If (Bool:C1537(Form:C1466.info.success))
		This:C1470._writePanelRows()
	End if

	// a payment is voided, never deleted
local Function isDeletable()->$isDeletable : Boolean
	$isDeletable:=False:C215

local Function _writePanelRows()
	var $result : Object
	If (Form:C1466.cpRows=Null:C1517)
		return
	End if
	$result:=cs:C1710.ga_receivables.me.writePayment(This:C1470; Form:C1466.cpRows)
	If (Not:C34($result.success))
		// the panel blocks Save while the payment has a problem, so this is a safety net only
		cs:C1710.sfw_dialog.me.alert("The payment is saved but not in the books:\r"+$result.errors.join("\r")+"\r\rCancel your changes, or fix the problem and save again.")
	End if
