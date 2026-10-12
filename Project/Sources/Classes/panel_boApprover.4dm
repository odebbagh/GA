// BO Approvers panel (Administration).
//
// Three things an administrator needs: add an approver, change their ceiling, and reset
// the password they sign with. The first two are this table; the third is not - approval
// verifies the [sfw_User] ACCOUNT password through cs.Util_Authorizer, so the button here
// hands off to sfw_passwordManager rather than storing a second secret.
//
// Legacy kept that second secret: [BO_Approvers]Password was a plain BLOB compared by
// hand in MatchSignature1/2. It predates the application having real user accounts.

singleton Class constructor
	//It's a singleton class

Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID

Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()

	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if

Function redrawAndSetVisible()
	var $item : Object
	var $hasAccount; $isApprover : Boolean

	$item:=Form:C1466.current_item

	//---the password button only means something when the approver has an account behind
	//   them, and the profile warning only when we can see the account to check it
	$hasAccount:=False:C215
	$isApprover:=False:C215
	If ($item#Null:C1517) && ($item.staff#Null:C1517) && ($item.staff.user#Null:C1517)
		$hasAccount:=True:C214
		$isApprover:=cs:C1710.Util_Authorizer.me.isInAnyProfile($item.staff.user; New collection:C1472("BOAPPROVER"))
	End if

	OBJECT SET ENABLED:C1123(*; "btnChangePassword"; $hasAccount)

	//---a row whose person cannot actually sign is the single most confusing state this
	//   table can be in, so it is said out loud rather than left to be discovered
	Case of
		: ($item=Null:C1517)
			Form:C1466.warning:=""
		: ($item.staff=Null:C1517)
			Form:C1466.warning:="No staff member selected - this row cannot be used to approve."
		: (Not:C34($hasAccount))
			Form:C1466.warning:=String:C10($item.staff.fullName)+" has no application user account, so they cannot sign."
		: (Not:C34($isApprover))
			Form:C1466.warning:=String:C10($item.staff.fullName)+" does not hold the BOAPPROVER profile, so signing will be refused."
		Else
			Form:C1466.warning:=""
	End case
	Form:C1466.warning:=Form:C1466.warning

	// ---- the approver ---------------------------------------------------------
Function selectStaff()
	var $form : Object
	var $winRef : Integer
	var $l; $t; $r; $b : Integer

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if

	Case of
		: (FORM Event:C1606.code=On Mouse Move:K2:35)
			SET CURSOR:C469(9000)
			return
		: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
		Else
			return
	End case

	OBJECT GET COORDINATES:C663(*; "Field_staff"; $l; $t; $r; $b)
	CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)

	//---inactive and terminated staff are left out: an approver has to be someone who
	//   still works here
	$form:=New object:C1471(\
		"colName"; "fullName"; \
		"allData"; ds:C1482.Staff.query("inactive = :1 and terminated = :2"; False:C215; False:C215).orderBy("lastName asc"); \
		"dataclass"; "Staff"\
		)

	$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
	DIALOG:C40("selectNto1"; $form)
	CLOSE WINDOW:C154($winRef)

	If (ok=1)
		Form:C1466.current_item.UUID_Staff:=$form.item.UUID
		This:C1470._activate_save_cancel_button()
	End if

	// ---- the signing password -------------------------------------------------
	// Not stored here. This resets the password on the linked [sfw_User] account, which
	// is the one Util_Authorizer asks for when the approver signs. Same dialog and the
	// same bcrypt hashing the Users entry uses.
Function changePassword()
	var $item : Object
	var $result : Object

	If (FORM Event:C1606.code#On Clicked:K2:4)
		return
	End if

	$item:=Form:C1466.current_item
	If ($item=Null:C1517) || ($item.staff=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("Select the approver first.")
		return
	End if

	If ($item.staff.user=Null:C1517)
		cs:C1710.sfw_dialog.me.alert(String:C10($item.staff.fullName)+" has no application user account. Create one under Users before setting a signing password.")
		return
	End if

	$result:=$item.staff.user.askForNewPassword()

	If ($result#Null:C1517) && Bool:C1537($result.success)
		$result:=$item.staff.user.save()
		If ($result.success)
			cs:C1710.sfw_dialog.me.info("Password changed. It takes effect the next time this approver signs.")
		Else
			cs:C1710.sfw_dialog.me.alert("The new password could not be saved.")
		End if
	End if
