// JournalEntryEntity: see JournalEntry and ga_ledger.
// Manual and opening entries are edited in panel_journalEntry: the panel keeps the lines in
// Form.jeLines and writes them after the save (afterSave / afterCreation), through ga_ledger.
Class extends Entity

local Function get date()->$date : Date
	$date:=(This:C1470.entryStmp=0) ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.entryStmp)

local Function set date($date : Date)
	This:C1470.entryStmp:=($date=!00-00-00!) ? 0 : cs:C1710.sfw_stmp.me.build($date; ?00:00:00?)

	// typed in the Journal Entries panel (manual or opening), not written by a document
local Function get isManual()->$isManual : Boolean
	$isManual:=(This:C1470.sourceDataclass="") || (This:C1470.sourceDataclass="JournalEntry")

	// can be changed now: typed by hand, not void, and dated after the closing date
local Function get isEditable()->$isEditable : Boolean
	$isEditable:=This:C1470.isManual && Not:C34(This:C1470.isVoid) && ((This:C1470.entryStmp=0) || cs:C1710.ga_ledger.me.isOpen(This:C1470.date))

local Function get canBeVoided()->$can : Boolean
	$can:=This:C1470.isManual && Not:C34(This:C1470.isVoid) && cs:C1710.ga_ledger.me.isOpen(This:C1470.date)

local Function get typeText()->$text : Text
	Case of
		: (This:C1470.type="Manual")
			$text:="Manual"
		: (This:C1470.type="Opening")
			$text:="Opening balance"
		Else
			$text:=This:C1470.type
	End case

local Function get statusText()->$text : Text
	$text:=This:C1470.isVoid ? "Void" : ""

	// where the entry comes from, for the panel
local Function get sourceText()->$text : Text
	If (This:C1470.isManual)
		$text:="Typed in this screen"
	Else
		$text:=This:C1470.sourceDataclass+" (written when the document is saved; change the document to change the entry)"
	End if

local Function get nameInWindowTitle()->$name : Text
	$name:="Journal entry "+((This:C1470.number=0) ? "(new)" : "#"+String:C10(This:C1470.number))

	// the lines as the panel edits them
Function linesForPanel()->$lines : Collection
	var $eLine : cs:C1710.JournalLineEntity
	$lines:=New collection:C1472
	For each ($eLine; This:C1470.lines.orderBy("lineNum asc"))
		$lines.push($eLine.rowForPanel())
	End for each


	// MARK: - sfw callbacks

local Function loadAfterCreation()
	This:C1470.number:=0  // given at the first save, so a cancelled entry leaves no hole
	This:C1470.type:="Manual"
	This:C1470.date:=Current date:C33
	This:C1470.sourceDataclass:="JournalEntry"
	This:C1470.UUID_Source:="0"*32
	This:C1470.UUID_Division:="0"*32
	This:C1470.UUID_User:=cs:C1710.ga_ledger.me._currentUserUUID()
	This:C1470.isVoid:=False:C215
	This:C1470.totalAmount:=0

local Function beforeSaveCreation()
	// always a new number (a duplicated entry arrives with the number of its original)
	This:C1470.number:=ds:C1482.sfw_Counter.getNextValue("JournalEntry")
	This:C1470.isVoid:=False:C215
	This:C1470.sourceDataclass:="JournalEntry"
	This:C1470.UUID_Source:=This:C1470.UUID

local Function afterCreation()
	This:C1470._writePanelLines()

local Function afterSave()
	If (Bool:C1537(Form:C1466.info.success))
		This:C1470._writePanelLines()
	End if

	// an entry is voided, never deleted (the numbering must have no hole)
local Function isDeletable()->$isDeletable : Boolean
	$isDeletable:=False:C215

local Function _writePanelLines()
	var $result : Object
	If (Not:C34(This:C1470.isManual)) || (Form:C1466.jeLines=Null:C1517)
		return
	End if
	$result:=cs:C1710.ga_ledger.me.writeLines(This:C1470; Form:C1466.jeLines)
	If (Not:C34($result.success))
		// the panel blocks Save while the lines have a problem, so this is a safety net only
		cs:C1710.sfw_dialog.me.alert("The lines were not saved:\r"+$result.errors.join("\r"))
	End if
