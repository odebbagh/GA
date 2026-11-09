Class extends DataClass

	// Administration entry for the buy-order approver list.
	//
	// Who may sign a buy order, at which level, and up to what amount. The identity and
	// password half of approval is not here: cs.Util_Authorizer checks the BOAPPROVER
	// profile and the [sfw_User] account password. This table only adds the ceiling, and
	// the panel offers a shortcut to reset that account's password so an administrator
	// does not have to go to Users to do it.

local Function entryDefinition()->$entry : cs:C1710.sfw_definitionEntry
	$entry:=cs:C1710.sfw_definitionEntry.new("boApprover"; "administration"; "BO Approvers")
	$entry.setDataclass("BOApprover")
	// setIcon is NOT optional: sfw_toolbar.drawToolbar does
	//     $iconFile:=Folder(fk resources folder).file($entry.icon)
	// with no null guard, so an entry without one raises "a valid posix path was
	// expected" the moment its vision is opened.
	$entry.setIcon("image/entry/staff-50x50.png"; "image/entry/staff-50x50.png")
	$entry.setDisplayOrder(-32000)

	$entry.setSearchboxField("staff.lastName")
	$entry.setSearchboxField("staff.firstName")

	$entry.setPanel("panel_boApprover")
	$entry.setPanelPage(1; ""; "Approver")

	$entry.setLBItemsColumn("staff.fullName"; "Approver"; "width:220")
	$entry.setLBItemsColumn("level"; "Level"; "width:60"; "center")
	$entry.setLBItemsColumn("moneyLimit"; "Limit"; "width:120"; "format:$###,###,##0.00")
	$entry.setLBItemsColumn("active?\"Active\":\"Inactive\""; "Status"; "width:90"; "orderByFormula:this.active")

	$entry.setLBItemsOrderBy("staff.lastName")
	$entry.setLBItemsOrderBy("level")

	$entry.setLBItemsCounter("###0###0##0 ^1;;"; "unit1:approver"; "unitN:approvers")

	$entry.enableTransaction()
