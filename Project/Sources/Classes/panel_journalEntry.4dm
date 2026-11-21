// panel_journalEntry: one journal entry (JournalEntry) and its lines.
// - Manual and opening entries are typed here. The lines live in Form.jeLines while the entry is
//   edited; JournalEntryEntity writes them through ga_ledger after the save. Save stays disabled
//   while the lines have a problem (no account, debits # credits, date in a closed period...),
//   and the problems are listed under the lines.
// - Typing an account NUMBER in the "Account #" column finds the account; Actions > Pick the
//   account... chooses it from the chart of accounts.
// - Entries written by a document (invoice, payment...), void entries and entries dated in a
//   closed period are read-only (Form.notEditable).
singleton Class constructor
	// It's a singleton class


Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID


Function formMethod()
	If (Form:C1466.jeLines=Null:C1517)
		Form:C1466.jeLines:=New collection:C1472
		Form:C1466.jeDebit:=0
		Form:C1466.jeCredit:=0
		Form:C1466.jeDifference:=0
		Form:C1466.jeHelp:=""
		Form:C1466.jeProblems:=""
		Form:C1466.jeTypeHelp:=""
		Form:C1466.jeLinesHelp:="Type the account number in \"Account #\" (or Actions > Pick the account...), then the amount in Debit OR Credit. The debits must equal the credits."
	End if
	// before panelFormMethod, so sfw already sees the right editable state (updateOfPanelNeeded
	// can only be asked once per event: it remembers the item it has seen)
	Form:C1466.notEditable:=(Form:C1466.current_item#Null:C1517) && (String:C10(Form:C1466.situation.mode)#"add") && (String:C10(Form:C1466.situation.mode)#"duplicate") && Not:C34(Form:C1466.current_item.isEditable)
	Form:C1466.sfw.panelFormMethod()
	If (Form:C1466.sfw.updateOfPanelNeeded())
		This:C1470.loadLines()
	End if
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())
		This:C1470.updateTotals()
	End if
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if


Function redrawAndSetVisible()
	var $editable : Boolean
	var $widthSubform; $heightSubform; $left; $top; $right; $bottom : Integer

	$editable:=This:C1470._editable()
	OBJECT SET ENTERABLE:C238(*; "Column_jeGlac"; $editable)
	OBJECT SET ENTERABLE:C238(*; "Column_jeDebit"; $editable)
	OBJECT SET ENTERABLE:C238(*; "Column_jeCredit"; $editable)
	OBJECT SET ENTERABLE:C238(*; "Column_jeMemo"; $editable)
	OBJECT SET VISIBLE:C603(*; "bActionLines"; $editable)
	OBJECT SET VISIBLE:C603(*; "btnDatePickerDate"; $editable)
	This:C1470.drawPup_type()
	This:C1470.drawPup_division()

	// the list-tab layout: the ribbon down the left side (division, totals, problems, help, Actions
	// at the bottom), the lines filling the rest - as the Step tab of the planning panel
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	OBJECT GET COORDINATES:C663(*; "rec_bkgd"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "rec_bkgd"; $left; $top; $right; $heightSubform)
	OBJECT GET COORDINATES:C663(*; "lb_jeLines"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "lb_jeLines"; $left; $top; $widthSubform; $heightSubform)
	OBJECT GET COORDINATES:C663(*; "bActionLines"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "bActionLines"; $left; $heightSubform-5-($bottom-$top); $right; $heightSubform-5)
	OBJECT GET COORDINATES:C663(*; "je_help"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "je_help"; $left; $top; $right; $heightSubform-35)


	// MARK: - Lines

Function loadLines()
	If (Form:C1466.current_item=Null:C1517)
		Form:C1466.jeLines:=New collection:C1472
	Else
		If (String:C10(Form:C1466.situation.mode)="add")
			Form:C1466.jeLines:=New collection:C1472(This:C1470._blankLine(); This:C1470._blankLine())
		Else
			Form:C1466.jeLines:=Form:C1466.current_item.linesForPanel()
		End if
	End if
	Form:C1466.current_jeLine:=Null:C1517
	This:C1470._ensureBlankRow()
	This:C1470.updateTotals()

	// totals, problems and the Save button
Function updateTotals()
	var $debit; $credit; $difference : Real
	var $check; $type : Object
	var $canValidate : Boolean

	$debit:=Round:C94(Form:C1466.jeLines.sum("debit"); 2)
	$credit:=Round:C94(Form:C1466.jeLines.sum("credit"); 2)
	$difference:=Round:C94($debit-$credit; 2)
	Form:C1466.jeDebit:=$debit
	Form:C1466.jeCredit:=$credit
	Form:C1466.jeDifference:=$difference  // positive: more debits; negative: more credits; green at 0
	OBJECT SET RGB COLORS:C628(*; "je_difference"; Choose:C955($difference=0; 0x00007A00; 0x00C00000); Background color none:K23:10)

	Form:C1466.jeProblems:=""
	If (Form:C1466.current_item#Null:C1517)
		$type:=ds:C1482.JournalEntry.manualTypes().query("type = :1"; Form:C1466.current_item.type).first()
		Form:C1466.jeTypeHelp:=($type=Null:C1517) ? "" : $type.help
		If (This:C1470._editable())
			$check:=cs:C1710.ga_ledger.me.checkLines(Form:C1466.jeLines; Form:C1466.current_item.date)
			Form:C1466.jeProblems:=$check.errors.join("\r")
			$canValidate:=$check.success
			If (Bool:C1537(Form:C1466.canValidate)#$canValidate)
				Form:C1466.canValidate:=$canValidate
				Form:C1466.validationRulesPassedWithSuccess:=$canValidate
				Form:C1466.validationRulesMessages:=$check.errors
				Form:C1466.sfw.drawButtons()
			End if
		Else
			If (Not:C34(Form:C1466.current_item.isManual))
				Form:C1466.jeTypeHelp:="Written by a document: "+Form:C1466.current_item.sourceText
			End if
			If (Form:C1466.current_item.isVoid)
				Form:C1466.jeProblems:="This entry is void: its amounts no longer count."
			Else
				If (Form:C1466.current_item.entryStmp#0) && Not:C34(cs:C1710.ga_ledger.me.isOpen(Form:C1466.current_item.date))
					Form:C1466.jeProblems:="Dated on or before the closing date ("+String:C10(cs:C1710.ga_ledger.me.closingDate())+"): the entry is locked."
				End if
			End if
		End if
	End if
	// the ribbon's help: what this kind of entry is, and how to type lines while it can be changed
	Form:C1466.jeHelp:=String:C10(Form:C1466.jeTypeHelp)
	If (This:C1470._editable())
		Form:C1466.jeHelp:=Form:C1466.jeHelp+((Form:C1466.jeHelp="") ? "" : "\r\r")+Form:C1466.jeLinesHelp
	End if

Function lb_jeLines()
	var $column : Text
	var $line : Object
	var $account : cs:C1710.GLAccountEntity
	var $accounts : cs:C1710.GLAccountSelection

	$line:=Form:C1466.current_jeLine
	Case of
		: ($line=Null:C1517) || Not:C34(This:C1470._editable())
			return

		: (FORM Event:C1606.code=On Double Clicked:K2:5) && (FORM Event:C1606.columnName="Column_jeAccount")
			This:C1470._pickAccount($line)

		: (FORM Event:C1606.code=On Data Change:K2:15)
			$column:=FORM Event:C1606.columnName
			Case of
				: ($column="Column_jeGlac")
					$line.glac:=cs:C1710.sfw_string.me.trimSpace(String:C10($line.glac))
					$account:=cs:C1710.ga_ledger.me.accountByGlac($line.glac)
					If ($account=Null:C1517) && ($line.glac#"")
						// a name typed instead of a number: take it when one active account matches
						$accounts:=ds:C1482.GLAccount.query("removed = :1 AND description = :2"; False:C215; $line.glac+"@")
						If ($accounts.length=1)
							$account:=$accounts.first()
						End if
					End if
					If ($account=Null:C1517)
						If ($line.glac#"")
							cs:C1710.sfw_dialog.me.alert("No account numbered or named \""+$line.glac+"\".\rType the number (e.g. 1030-0), or use Actions > Pick the account...")
						End if
						$line.UUID_GLAccount:="0"*32
						$line.glac:=""
						$line.accountLabel:=""
					Else
						This:C1470._setAccount($line; $account)
					End if
				: ($column="Column_jeDebit")
					$line.debit:=Round:C94(Num:C11($line.debit); 2)
					If ($line.debit#0)
						$line.credit:=0
					End if
				: ($column="Column_jeCredit")
					$line.credit:=Round:C94(Num:C11($line.credit); 2)
					If ($line.credit#0)
						$line.debit:=0
					End if
			End case
			This:C1470._linesChanged()
	End case

Function bActionLines()
	var $menu; $choice : Text
	var $line : Object
	var $index : Integer
	var $difference : Real

	If (Not:C34(This:C1470._editable()))
		return
	End if
	$line:=Form:C1466.current_jeLine
	$index:=($line=Null:C1517) ? -1 : Form:C1466.jeLines.indexOf($line)
	$difference:=Round:C94(Form:C1466.jeLines.sum("debit")-Form:C1466.jeLines.sum("credit"); 2)

	$menu:=Create menu:C408
	APPEND MENU ITEM:C411($menu; "Pick the account..."; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--pick")
	If ($index=-1)
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	APPEND MENU ITEM:C411($menu; "Put the difference on this line"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--balance")
	If ($index=-1) || ($difference=0)
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	APPEND MENU ITEM:C411($menu; "-")
	APPEND MENU ITEM:C411($menu; "Add a line"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--add")
	APPEND MENU ITEM:C411($menu; "Remove the line"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--remove")
	If ($index=-1)
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)

	Case of
		: ($choice="--pick")
			This:C1470._pickAccount($line)
		: ($choice="--balance")
			// the line takes what makes debits = credits
			$difference:=Round:C94($difference-(Num:C11($line.debit)-Num:C11($line.credit)); 2)
			$line.debit:=($difference<0) ? -$difference : 0
			$line.credit:=($difference>0) ? $difference : 0
			This:C1470._linesChanged()
		: ($choice="--add")
			Form:C1466.jeLines.push(This:C1470._blankLine())
			This:C1470._linesChanged()
		: ($choice="--remove")
			Form:C1466.jeLines.remove($index)
			Form:C1466.current_jeLine:=Null:C1517
			This:C1470._linesChanged()
	End case

Function _pickAccount($line : Object)
	var $menu; $choice : Text
	var $account : cs:C1710.GLAccountEntity
	$menu:=ds:C1482.GLAccount.accountMenu(String:C10($line.UUID_GLAccount))
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	If ($choice#"")
		$account:=ds:C1482.GLAccount.get($choice)
		If ($account#Null:C1517)
			This:C1470._setAccount($line; $account)
			This:C1470._linesChanged()
		End if
	End if

Function _setAccount($line : Object; $account : cs:C1710.GLAccountEntity)
	$line.UUID_GLAccount:=$account.UUID
	$line.glac:=$account.glac
	$line.accountLabel:=$account.description+"  ("+$account.accountType+")"

Function _linesChanged()
	This:C1470._ensureBlankRow()
	Form:C1466.jeLines:=Form:C1466.jeLines
	This:C1470._activate_save_cancel_button()
	This:C1470.updateTotals()

	// in modification, there is always an empty row at the end to type the next line
Function _ensureBlankRow()
	If (This:C1470._editable())
		If (Form:C1466.jeLines.length=0) || Not:C34(cs:C1710.ga_ledger.me._isBlankLine(Form:C1466.jeLines[Form:C1466.jeLines.length-1]))
			Form:C1466.jeLines.push(This:C1470._blankLine())
		End if
	End if

Function _blankLine()->$line : Object
	$line:=New object:C1471("UUID_GLAccount"; "0"*32; "glac"; ""; "accountLabel"; ""; "debit"; 0; "credit"; 0; "memo"; ""; \
		"UUID_Division"; "0"*32; "UUID_Customer"; "0"*32; "UUID_Supplier"; "0"*32; "cleared"; False:C215)

Function _editable()->$editable : Boolean
	$editable:=(Form:C1466.current_item#Null:C1517) && Form:C1466.sfw.checkIsInModification() && Form:C1466.current_item.isManual && Not:C34(Form:C1466.current_item.isVoid)


	// MARK: - Header

Function entryField_date()
	If (FORM Event:C1606.code=On Data Change:K2:15)
		This:C1470.updateTotals()
	End if

	// the calendar next to the date (ga_datePicker); only while the entry can be changed
Function btnDatePickerDate()
	If (FORM Event:C1606.code=On Clicked:K2:4) && This:C1470._editable()
		If (cs:C1710.ga_datePicker.me.pickInto(Form:C1466.current_item; "date"; "entryField_date"))
			This:C1470._activate_save_cancel_button()
			This:C1470.updateTotals()
		End if
	End if

Function drawPup_type()
	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	Form:C1466.sfw.drawButtonPup("pup_type"; (Form:C1466.current_item.typeText="") ? " " : Form:C1466.current_item.typeText; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; False:C215)

Function pup_type()
	var $menu; $choice : Text
	var $type : Object
	If (Not:C34(This:C1470._editable()))
		return
	End if
	$menu:=Create menu:C408
	For each ($type; ds:C1482.JournalEntry.manualTypes())
		APPEND MENU ITEM:C411($menu; $type.label; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $type.type)
		If ($type.type=Form:C1466.current_item.type)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if
	End for each
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	If ($choice#"") && ($choice#Form:C1466.current_item.type)
		Form:C1466.current_item.type:=$choice
		This:C1470._activate_save_cancel_button()
		This:C1470.drawPup_type()
		This:C1470.updateTotals()
	End if

Function drawPup_division()
	var $division : cs:C1710.DivisionEntity
	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	$division:=Form:C1466.current_item.division
	Form:C1466.sfw.drawButtonPup("pup_division"; ($division=Null:C1517) ? "No division" : $division.name; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; False:C215)

	// the division of the entry, given to the lines that had none or had the old one
Function pup_division()
	var $menu; $choice; $old : Text
	var $division : cs:C1710.DivisionEntity
	var $line : Object
	If (Not:C34(This:C1470._editable()))
		return
	End if
	$menu:=Create menu:C408
	APPEND MENU ITEM:C411($menu; "No division"; *)
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
		$old:=Form:C1466.current_item.UUID_Division
		Form:C1466.current_item.UUID_Division:=$choice
		For each ($line; Form:C1466.jeLines)
			If (cs:C1710.sfw_string.me.isAnEmptyUUID(String:C10($line.UUID_Division))) || ($line.UUID_Division=$old)
				$line.UUID_Division:=$choice
			End if
		End for each
		This:C1470._activate_save_cancel_button()
		This:C1470.drawPup_division()
	End if
