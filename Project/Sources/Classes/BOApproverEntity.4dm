Class extends Entity

	// One person's authority to approve buy orders at one level.
	//
	// Legacy kept two parallel tables, [BO_Approvers] for level 1 and [BO_Approvers2] for
	// level 2, each holding Approved_by, Password, MoneyLimit and DateModified. One table
	// with a level column replaces both: the same person often sat at both levels with
	// different ceilings, which the two-table shape could only express by duplicating them.
	//
	// The Password column is deliberately NOT carried over. Legacy stored it as a plain
	// BLOB and compared it by hand in MatchSignature1/2, because it predates the
	// application having real user accounts. Approval here verifies the [sfw_User] account
	// password through cs.Util_Authorizer, which is bcrypt via sfw_passwordManager. A
	// second secret on this table would be a weaker duplicate of one that already exists.

	// "Ben Mendoza - level 2, limit $50,000"
Function get label()->$label : Text
	var $name : Text
	$name:=(This:C1470.staff#Null:C1517) ? String:C10(This:C1470.staff.fullName) : "(no staff)"
	$label:=$name+" - level "+String:C10(Num:C11(This:C1470.level))+", limit "+String:C10(Num:C11(This:C1470.moneyLimit); "$###,###,##0.00")

	// Legacy MatchSignature1/2 converted the order total through
	// CurrencyExchange("Purchase"; Currency; ISSUE_DATE; T_Amt) before comparing. Every
	// legacy order is in dollars and the decision was taken to keep it that way, so the
	// amount is compared as it stands. If a second currency ever appears, this is the one
	// place that has to learn about it.
	//
	// A zero limit means unlimited, not "cannot approve anything" - that is how an
	// approver with no ceiling recorded has always behaved.
Function canApprove($amount : Real)->$result : Object
	$result:=New object:C1471("ok"; False:C215; "reason"; "")

	If (Not:C34(Bool:C1537(This:C1470.active)))
		$result.reason:="This approver is no longer active."
		return
	End if

	If (Num:C11(This:C1470.moneyLimit)>0) && ($amount>Num:C11(This:C1470.moneyLimit))
		//---legacy wording, kept so the people who used it recognise it
		$result.reason:="You have exceeded your authorized limit."
		return
	End if

	$result.ok:=True:C214

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=This:C1470.label
