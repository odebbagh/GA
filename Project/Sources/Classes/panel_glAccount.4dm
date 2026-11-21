// panel_glAccount: one account of the chart of accounts (GLAccount).
// Page 1: what the account is (type and family, its role for the documents, division, buying
// flags). Page 2: its register - every journal line between two dates with a running balance;
// a double-click opens the journal entry.
singleton Class constructor
	// It's a singleton class


Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID


Function formMethod()
	If (Form:C1466.register=Null:C1517)
		Form:C1466.register:=New object:C1471(\
			"from"; cs:C1710.ga_ledger.me.fiscalYearStart(Current date:C33); \
			"to"; Current date:C33)
		This:C1470._clearRegister("")
		Form:C1466.roleHelp:="The documents (invoices, payments, bills...) put their amounts on the account that has the role they need."
	End if
	Form:C1466.sfw.panelFormMethod()
	If (Form:C1466.sfw.updateOfPanelNeeded())
		This:C1470._clearRegister("")
		If (FORM Get current page:C276(*)=2)
			This:C1470.loadRegister()
		End if
	End if
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())
		If (FORM Get current page:C276(*)=2)
			This:C1470.loadRegister()
		End if
	End if
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if


Function redrawAndSetVisible()
	var $widthSubform; $heightSubform; $left; $top; $right; $bottom : Integer
	This:C1470.drawPup_type()
	This:C1470.drawPup_defaultKey()
	This:C1470.drawPup_division()

	// Register: the ribbon down the left side (filters and totals stacked, Actions at the bottom),
	// the list filling the rest - the layout of the Step tab of the planning panel
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	If (FORM Get current page:C276(*)=2)
		OBJECT GET COORDINATES:C663(*; "rec_bkgd"; $left; $top; $right; $bottom)
		OBJECT SET COORDINATES:C1248(*; "rec_bkgd"; $left; $top; $right; $heightSubform)
		OBJECT GET COORDINATES:C663(*; "lb_register"; $left; $top; $right; $bottom)
		OBJECT SET COORDINATES:C1248(*; "lb_register"; $left; $top; $widthSubform; $heightSubform)
		OBJECT GET COORDINATES:C663(*; "bActionRegister"; $left; $top; $right; $bottom)
		OBJECT SET COORDINATES:C1248(*; "bActionRegister"; $left; $heightSubform-5-($bottom-$top); $right; $heightSubform-5)
	End if


	// MARK: - Type (and so the family)

Function drawPup_type()
	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	Form:C1466.sfw.drawButtonPup("pup_type"; (Form:C1466.current_item.accountType="") ? " " : Form:C1466.current_item.accountType; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; (Form:C1466.current_item.accountType=""))

Function pup_type()
	var $menu; $choice : Text
	var $type : Object
	var $code : Integer

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	$menu:=Create menu:C408
	$code:=0
	For each ($type; cs:C1710.ga_ledger.me.accountTypes())
		If ($type.code#$code)
			If ($code#0)
				APPEND MENU ITEM:C411($menu; "-")
			End if
			APPEND MENU ITEM:C411($menu; cs:C1710.ga_ledger.me.familyName($type.code); *)
			DISABLE MENU ITEM:C150($menu; -1)
			$code:=$type.code
		End if
		APPEND MENU ITEM:C411($menu; "   "+$type.name; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $type.name)
		If ($type.name=Form:C1466.current_item.accountType)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if
	End for each
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	If ($choice#"") && ($choice#Form:C1466.current_item.accountType)
		If (Form:C1466.current_item.isUsed()) && (cs:C1710.ga_ledger.me.typeCode($choice)#Form:C1466.current_item.accountTypeCode)
			If (Not:C34(cs:C1710.sfw_dialog.me.confirm("This account already has entries. Moving it to another family (for example from expense to asset) changes the reports of the past too.\r\rChange the type anyway?"; "Change"; "Keep")))
				return
			End if
		End if
		Form:C1466.current_item.accountType:=$choice
		Form:C1466.current_item.accountTypeCode:=cs:C1710.ga_ledger.me.typeCode($choice)
		This:C1470._activate_save_cancel_button()
		This:C1470.drawPup_type()
	End if


	// MARK: - Role for the documents (defaultKey)

Function drawPup_defaultKey()
	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	Form:C1466.sfw.drawButtonPup("pup_defaultKey"; (Form:C1466.current_item.defaultKey="") ? "None" : Form:C1466.current_item.defaultKeyLabel; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; False:C215)

Function pup_defaultKey()
	var $menu; $choice : Text
	var $key : Object
	var $holder : cs:C1710.GLAccountEntity

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	$menu:=Create menu:C408
	APPEND MENU ITEM:C411($menu; "None"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--none")
	APPEND MENU ITEM:C411($menu; "-")
	For each ($key; cs:C1710.ga_ledger.me.defaultKeys())
		APPEND MENU ITEM:C411($menu; $key.label; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $key.key)
		If ($key.key=Form:C1466.current_item.defaultKey)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if
	End for each
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)

	Case of
		: ($choice="")
			return
		: ($choice="--none")
			$choice:=""
	End case
	If ($choice=Form:C1466.current_item.defaultKey)
		return
	End if
	// one account per role and division: the role moves from the account that had it
	If ($choice#"")
		$holder:=ds:C1482.GLAccount.query("defaultKey = :1 AND UUID_Division = :2 AND UUID # :3"; $choice; Form:C1466.current_item.UUID_Division; Form:C1466.current_item.UUID).first()
		If ($holder#Null:C1517)
			If (Not:C34(cs:C1710.sfw_dialog.me.confirm("\""+cs:C1710.ga_ledger.me.defaultKeyLabel($choice)+"\" is the role of "+$holder.label+".\r\rGive it to this account instead?"; "Move the role"; "Keep")))
				return
			End if
			$holder.defaultKey:=""
			$holder.save()  // inside the panel transaction: Cancel puts it back
		End if
	End if
	Form:C1466.current_item.defaultKey:=$choice
	This:C1470._activate_save_cancel_button()
	This:C1470.drawPup_defaultKey()


	// MARK: - Division

Function drawPup_division()
	var $division : cs:C1710.DivisionEntity
	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	$division:=Form:C1466.current_item.division
	Form:C1466.sfw.drawButtonPup("pup_division"; ($division=Null:C1517) ? "All divisions" : $division.name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; False:C215)

Function pup_division()
	var $menu; $choice : Text
	var $division : cs:C1710.DivisionEntity

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	$menu:=Create menu:C408
	APPEND MENU ITEM:C411($menu; "All divisions"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "0"*32)
	APPEND MENU ITEM:C411($menu; "-")
	For each ($division; ds:C1482.Division.all().orderBy("levelID asc"))
		APPEND MENU ITEM:C411($menu; $division.name; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $division.UUID)
		If ($division.UUID=Form:C1466.current_item.UUID_Division)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if
	End for each
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	If ($choice#"") && ($choice#Form:C1466.current_item.UUID_Division)
		Form:C1466.current_item.UUID_Division:=$choice
		This:C1470._activate_save_cancel_button()
		This:C1470.drawPup_division()
	End if


	// MARK: - Register (page 2)

Function loadRegister()
	var $result : Object
	If (Form:C1466.current_item=Null:C1517) || (String:C10(Form:C1466.situation.mode)="add") || (String:C10(Form:C1466.situation.mode)="duplicate")
		This:C1470._clearRegister("The register shows the entries once the account is saved.")
		return
	End if
	If (Form:C1466.register.from>Form:C1466.register.to)
		This:C1470._clearRegister("The start date is after the end date.")
		return
	End if
	$result:=cs:C1710.ga_ledger.me.register(Form:C1466.current_item; Form:C1466.register.from; Form:C1466.register.to; "")
	Form:C1466.lb_register:=$result.rows
	Form:C1466.register.opening:=$result.opening
	Form:C1466.register.totalDebit:=$result.totalDebit
	Form:C1466.register.totalCredit:=$result.totalCredit
	Form:C1466.register.closing:=$result.closing
	Form:C1466.register.note:=String:C10($result.rows.length)+" line(s).\r"+\
		Choose:C955(cs:C1710.ga_ledger.me.normalSign(Form:C1466.current_item.accountTypeCode)=1; \
		"Debit account: debits add to the balance, credits subtract."; \
		"Credit account: credits add to the balance, debits subtract.")+\
		"\rDouble-click a line to open its journal entry."
	Form:C1466.register:=Form:C1466.register

	// empty register, with $note in the ribbon
Function _clearRegister($note : Text)
	Form:C1466.lb_register:=New collection:C1472
	Form:C1466.current_registerRow:=Null:C1517
	Form:C1466.register.opening:=0
	Form:C1466.register.totalDebit:=0
	Form:C1466.register.totalCredit:=0
	Form:C1466.register.closing:=0
	Form:C1466.register.note:=$note
	Form:C1466.register:=Form:C1466.register

	// Actions (bottom of the ribbon): open the entry, quick periods, Excel
Function bActionRegister()
	var $menu; $choice : Text
	var $today : Date

	$today:=Current date:C33
	$menu:=Create menu:C408
	APPEND MENU ITEM:C411($menu; "Open the journal entry"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--open")
	If (Form:C1466.current_registerRow=Null:C1517)
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	APPEND MENU ITEM:C411($menu; "-")
	APPEND MENU ITEM:C411($menu; "This month"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--thisMonth")
	APPEND MENU ITEM:C411($menu; "Last month"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--lastMonth")
	APPEND MENU ITEM:C411($menu; "This fiscal year"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--thisYear")
	APPEND MENU ITEM:C411($menu; "Last fiscal year"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--lastYear")
	APPEND MENU ITEM:C411($menu; "Since the start of the books"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--all")
	APPEND MENU ITEM:C411($menu; "-")
	APPEND MENU ITEM:C411($menu; "Export to Excel..."; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--excel")
	If (Form:C1466.lb_register.length=0)
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)

	Case of
		: ($choice="--open")
			This:C1470._openRegisterEntry()
		: ($choice="--thisMonth")
			This:C1470._setRegisterPeriod(Add to date:C393($today; 0; 0; 1-Day of:C23($today)); $today)
		: ($choice="--lastMonth")
			This:C1470._setRegisterPeriod(Add to date:C393(Add to date:C393($today; 0; 0; 1-Day of:C23($today)); 0; -1; 0); Add to date:C393($today; 0; 0; -Day of:C23($today)))
		: ($choice="--thisYear")
			This:C1470._setRegisterPeriod(cs:C1710.ga_ledger.me.fiscalYearStart($today); $today)
		: ($choice="--lastYear")
			This:C1470._setRegisterPeriod(Add to date:C393(cs:C1710.ga_ledger.me.fiscalYearStart($today); -1; 0; 0); Add to date:C393(cs:C1710.ga_ledger.me.fiscalYearStart($today); 0; 0; -1))
		: ($choice="--all")
			This:C1470._setRegisterPeriod(!2000-01-01!; $today)
		: ($choice="--excel")
			This:C1470._exportRegister()
	End case

Function _setRegisterPeriod($from : Date; $to : Date)
	Form:C1466.register.from:=$from
	Form:C1466.register.to:=$to
	This:C1470.loadRegister()

Function _openRegisterEntry()
	var $entry : cs:C1710.JournalEntryEntity
	If (Form:C1466.current_registerRow#Null:C1517)
		$entry:=ds:C1482.JournalEntry.get(Form:C1466.current_registerRow.UUID_JournalEntry)
		If ($entry#Null:C1517)
			Form:C1466.sfw.openInANewWindow($entry; "accounting"; "journalEntries")
		End if
	End if

	// the register lines in an Excel file (ExcelDataExporter), with the balance before and after
Function _exportRegister()
	var $rows; $mapping : Collection
	var $name : Text
	var $offscreen : Object
	$rows:=New collection:C1472(New object:C1471("date"; Form:C1466.register.from; "number"; ""; "type"; ""; "memo"; "Balance before"; "debit"; ""; "credit"; ""; "balance"; Form:C1466.register.opening))
	$rows.combine(Form:C1466.lb_register)
	$rows.push(New object:C1471("date"; Form:C1466.register.to; "number"; ""; "type"; ""; "memo"; "Balance at end"; "debit"; Form:C1466.register.totalDebit; "credit"; Form:C1466.register.totalCredit; "balance"; Form:C1466.register.closing))
	$mapping:=New collection:C1472(\
		New object:C1471("header"; "Date"; "field"; "date"; "footerOperation"; ""); \
		New object:C1471("header"; "Entry #"; "field"; "number"; "footerOperation"; ""); \
		New object:C1471("header"; "Type"; "field"; "type"; "footerOperation"; ""); \
		New object:C1471("header"; "Memo"; "field"; "memo"; "footerOperation"; ""); \
		New object:C1471("header"; "Debit"; "field"; "debit"; "footerOperation"; ""); \
		New object:C1471("header"; "Credit"; "field"; "credit"; "footerOperation"; ""); \
		New object:C1471("header"; "Balance"; "field"; "balance"; "footerOperation"; ""))
	$name:=Substring:C12("Register_"+Replace string:C233(Form:C1466.current_item.glac; "."; "_"); 1; 24)
	$offscreen:=cs:C1710.ExcelDataExporter.new(\
		Folder:C1567(fk resources folder:K87:11).file("excelTemplates/excelExportTemplate.xlsx").platformPath; \
		$mapping; $rows; $name; \
		Get 4D folder:C485(Current resources folder:K5:16)+"exportedData"+Folder separator:K24:12+"Accounting"; \
		"Register "+Form:C1466.current_item.label+" from "+String:C10(Form:C1466.register.from)+" to "+String:C10(Form:C1466.register.to); "Register"; False:C215)
	VP Run offscreen area($offscreen)

Function reg_from()
	If (FORM Event:C1606.code=On Data Change:K2:15)
		This:C1470.loadRegister()
	End if

Function reg_to()
	If (FORM Event:C1606.code=On Data Change:K2:15)
		This:C1470.loadRegister()
	End if

	// the calendars next to From / To (ga_datePicker); the dates are not saved, so no Save button
Function btnDatePickerRegFrom()
	If (FORM Event:C1606.code=On Clicked:K2:4)
		If (cs:C1710.ga_datePicker.me.pickInto(Form:C1466.register; "from"; "reg_from"))
			Form:C1466.register:=Form:C1466.register
			This:C1470.loadRegister()
		End if
	End if

Function btnDatePickerRegTo()
	If (FORM Event:C1606.code=On Clicked:K2:4)
		If (cs:C1710.ga_datePicker.me.pickInto(Form:C1466.register; "to"; "reg_to"))
			Form:C1466.register:=Form:C1466.register
			This:C1470.loadRegister()
		End if
	End if

Function lb_register()
	If (FORM Event:C1606.code=On Double Clicked:K2:5)
		This:C1470._openRegisterEntry()
	End if
