// ga_trialBalanceDialog: the trial balance dialog (form ga_trialBalance), opened by
// _ga_trialBalance from Chart of Accounts or Journal Entries.
// A trial balance lists every account that has a balance on a date, in the debit or the credit
// column. The two totals must be equal: that is the proof the books balance. Profit and loss
// accounts count from the start of the fiscal year; earlier years' profit shows on retained
// earnings (ga_ledger.trialBalance).
singleton Class constructor


Function open()
	var $data : Object
	var $window : Integer
	$data:=New object:C1471("asOf"; Current date:C33; "divisionUUID"; "0"*32; "rows"; New collection:C1472)
	$window:=Open form window:C675("ga_trialBalance"; Movable form dialog box:K39:8; Horizontally centered:K39:1; Vertically centered:K39:4)
	DIALOG:C40("ga_trialBalance"; $data)
	CLOSE WINDOW:C154($window)

Function formMethod()
	If (FORM Event:C1606.code=On Load:K2:1)
		This:C1470.load()
		This:C1470.drawPup_division()
	End if

Function load()
	var $tb : Object
	$tb:=cs:C1710.ga_ledger.me.trialBalance(Form:C1466.asOf; Form:C1466.divisionUUID)
	Form:C1466.rows:=$tb.rows
	Form:C1466.headerText:="Trial balance at the end of "+String:C10(Form:C1466.asOf; System date long:K1:3)+\
		" - every account with a balance, in the debit or the credit column. The two totals must be equal."
	Form:C1466.totalText:="Totals:   debits "+String:C10($tb.totalDebit; "###,###,##0.00")+"   credits "+String:C10($tb.totalCredit; "###,###,##0.00")+\
		Choose:C955($tb.balanced; "   - balanced"; "   - NOT BALANCED by "+String:C10(Abs:C99($tb.totalDebit-$tb.totalCredit); "###,###,##0.00"))
	OBJECT SET RGB COLORS:C628(*; "txt_total"; Choose:C955($tb.balanced; 0x00007A00; 0x00C00000); Background color none:K23:10)
	Form:C1466.noteText:="Income and expense accounts count from "+String:C10($tb.fiscalYearStart)+" (start of the fiscal year)."+\
		Choose:C955($tb.priorYearsProfit=0; ""; " The profit of the earlier years ("+String:C10($tb.priorYearsProfit; "###,###,##0.00;-###,###,##0.00")+") is shown on retained earnings.")+\
		Choose:C955(Bool:C1537($tb.retainedEarningsMissing); " No account has the role Retained earnings: give it to one in Chart of Accounts."; "")+\
		Choose:C955(cs:C1710.ga_ledger.me.closingDate()=!00-00-00!; " The books were never closed."; " Books closed up to "+String:C10(cs:C1710.ga_ledger.me.closingDate())+".")
	Form:C1466.tb:=$tb

Function tb_asOf()
	If (FORM Event:C1606.code=On Data Change:K2:15)
		This:C1470.load()
	End if

	// the calendar next to "As of" (ga_datePicker)
Function btnDatePickerAsOf()
	If (FORM Event:C1606.code=On Clicked:K2:4)
		If (cs:C1710.ga_datePicker.me.pickInto(Form:C1466; "asOf"; "tb_asOf"))
			This:C1470.load()
		End if
	End if

Function drawPup_division()
	var $division : cs:C1710.DivisionEntity
	$division:=ds:C1482.Division.get(Form:C1466.divisionUUID)
	OBJECT SET TITLE:C194(*; "pup_division"; ($division=Null:C1517) ? "All divisions" : $division.name)

Function pup_division()
	var $menu; $choice : Text
	var $division : cs:C1710.DivisionEntity
	$menu:=Create menu:C408
	APPEND MENU ITEM:C411($menu; "All divisions"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "0"*32)
	APPEND MENU ITEM:C411($menu; "-")
	For each ($division; ds:C1482.Division.all().orderBy("levelID asc"))
		APPEND MENU ITEM:C411($menu; $division.name; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $division.UUID)
	End for each
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	If ($choice#"")
		Form:C1466.divisionUUID:=$choice
		This:C1470.drawPup_division()
		This:C1470.load()
	End if

	// the rows in an Excel file, with the existing export template (ExcelDataExporter)
Function bExport()
	var $mapping : Collection
	var $rows : Collection
	var $name : Text
	var $offscreen : Object
	If (Form:C1466.rows.length=0)
		cs:C1710.sfw_dialog.me.alert("Nothing to export: no account has a balance on this date.")
		return
	End if
	$rows:=Form:C1466.rows.copy()
	$rows.push(New object:C1471("family"; ""; "accountType"; ""; "glac"; ""; "description"; "TOTAL"; "debit"; Form:C1466.tb.totalDebit; "credit"; Form:C1466.tb.totalCredit))
	$mapping:=New collection:C1472(\
		New object:C1471("header"; "Family"; "field"; "family"; "footerOperation"; ""); \
		New object:C1471("header"; "Type"; "field"; "accountType"; "footerOperation"; ""); \
		New object:C1471("header"; "Number"; "field"; "glac"; "footerOperation"; ""); \
		New object:C1471("header"; "Account"; "field"; "description"; "footerOperation"; ""); \
		New object:C1471("header"; "Debit"; "field"; "debit"; "footerOperation"; ""); \
		New object:C1471("header"; "Credit"; "field"; "credit"; "footerOperation"; ""))
	$name:="TrialBalance_"+Replace string:C233(String:C10(Form:C1466.asOf; ISO date:K1:8); "-"; "_")
	$name:=Substring:C12($name; 1; 21)
	$offscreen:=cs:C1710.ExcelDataExporter.new(\
		Folder:C1567(fk resources folder:K87:11).file("excelTemplates/excelExportTemplate.xlsx").platformPath; \
		$mapping; $rows; $name; \
		Get 4D folder:C485(Current resources folder:K5:16)+"exportedData"+Folder separator:K24:12+"Accounting"; \
		"Trial balance at "+String:C10(Form:C1466.asOf); "Trial balance"; False:C215)
	VP Run offscreen area($offscreen)
