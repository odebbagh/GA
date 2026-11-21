// PaymentTermEntity: see PaymentTerm.
Class extends Entity

local Function get discountText()->$text : Text
	$text:=(This:C1470.discountPercent=0) ? "" : String:C10(This:C1470.discountPercent)+"% if paid within "+String:C10(This:C1470.discountDays)+" days"

local Function get label()->$label : Text
	$label:=This:C1470.name
	If ($label="")
		$label:=This:C1470.code
	End if

local Function get nameInWindowTitle()->$name : Text
	$name:=This:C1470.label

	// a plain sentence for the panel
local Function get explanation()->$text : Text
	Case of
		: (This:C1470.netDays=0)
			$text:="The invoice is due on its date."
		Else
			$text:="The invoice is due "+String:C10(This:C1470.netDays)+" days after its date."
	End case
	If (This:C1470.discountPercent#0)
		$text:=$text+" A customer paying within "+String:C10(This:C1470.discountDays)+" days may take "+String:C10(This:C1470.discountPercent)+"% off."
	End if

	// the due date of an invoice dated $date
Function dueDate($date : Date)->$due : Date
	$due:=Add to date:C393($date; 0; 0; This:C1470.netDays)

local Function loadAfterCreation()
	This:C1470.active:=True:C214
	This:C1470.netDays:=30

	// only one default term
local Function beforeSave()
	This:C1470._oneDefault()

local Function beforeSaveCreation()
	This:C1470._oneDefault()

local Function _oneDefault()
	var $other : cs:C1710.PaymentTermEntity
	If (This:C1470.isDefault)
		For each ($other; ds:C1482.PaymentTerm.query("isDefault = :1 AND UUID # :2"; True:C214; String:C10(This:C1470.UUID)))
			$other.isDefault:=False:C215
			$other.save()  // inside the entry transaction: Cancel puts it back
		End for each
	End if

	// a term used by a customer or an invoice can only be made inactive
local Function isDeletable()->$isDeletable : Boolean
	$isDeletable:=(This:C1470.customers.length=0) && (This:C1470.jobInvoices.length=0)
