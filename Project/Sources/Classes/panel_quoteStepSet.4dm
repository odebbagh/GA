// panel_quoteStepSet: a standard step set of the quotes (QuoteStepSet). Its steps are listed in the
// order a quote line built from the set describes them; the Actions menu adds steps (the dialog of
// the quote lines, Quote_pickSteps, without prices), moves or removes them. The list is written to
// the set at once, inside the entry's transaction: Cancel puts it back.
singleton Class constructor
	// It's a singleton class


Function _activate_save_cancel_button()
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID


Function formMethod()
	If (Undefined:C82(Form:C1466.lb_setSteps)) || (Form:C1466.lb_setSteps=Null:C1517)
		Form:C1466.lb_setSteps:=New collection:C1472
	End if
	Form:C1466.sfw.panelFormMethod()
	If (Form:C1466.sfw.updateOfPanelNeeded())
		This:C1470.loadSteps()
	End if
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())
		This:C1470.loadSteps()
	End if
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if


Function redrawAndSetVisible()
	var $widthSubform; $heightSubform; $left; $top; $right; $bottom : Integer
	OBJECT SET VISIBLE:C603(*; "bActionSteps"; Form:C1466.sfw.checkIsInModification())
	This:C1470.drawPup_priceFlow()

	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	OBJECT GET COORDINATES:C663(*; "lb_setSteps"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "lb_setSteps"; $left; $top; $widthSubform-5; $heightSubform-36)
	OBJECT GET COORDINATES:C663(*; "bActionSteps"; $left; $top; $right; $bottom)
	OBJECT SET COORDINATES:C1248(*; "bActionSteps"; $left; $heightSubform-29; $right; $heightSubform-8)


Function loadSteps()
	If (Form:C1466.current_item=Null:C1517)
		Form:C1466.lb_setSteps:=New collection:C1472
	Else
		Form:C1466.lb_setSteps:=Form:C1466.current_item.stepRows()
	End if
	Form:C1466.current_setStep:=Null:C1517


Function bActionSteps()
	var $menu; $choice : Text
	var $UUIDs : Collection
	var $index : Integer

	If (Not:C34(Form:C1466.sfw.checkIsInModification()))
		return
	End if
	$UUIDs:=Form:C1466.current_item.stepUUIDs
	$index:=(Form:C1466.current_setStep=Null:C1517) ? -1 : $UUIDs.indexOf(Form:C1466.current_setStep.UUID)

	$menu:=Create menu:C408
	APPEND MENU ITEM:C411($menu; "Add steps..."; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--add")
	APPEND MENU ITEM:C411($menu; "-")
	APPEND MENU ITEM:C411($menu; "Move step up"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--up")
	If ($index<=0)
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	APPEND MENU ITEM:C411($menu; "Move step down"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--down")
	If ($index=-1) || ($index>=($UUIDs.length-1))
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	APPEND MENU ITEM:C411($menu; "-")
	APPEND MENU ITEM:C411($menu; "Remove the step"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "--remove")
	If ($index=-1)
		DISABLE MENU ITEM:C150($menu; -1)
	End if
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)

	Case of
		: ($choice="--add")
			This:C1470._addSteps()
		: ($choice="--up") || ($choice="--down")
			This:C1470._moveStep($index; ($choice="--up") ? -1 : 1)
		: ($choice="--remove")
			$UUIDs.remove($index)
			This:C1470._setSteps($UUIDs; -1)
	End case


	// Quote_pickSteps without prices: the set's steps come ticked; the steps still ticked keep their
	// place, the new ones go at the end in the order of the list
Function _addSteps()
	var $data : Object
	var $window : Integer
	var $UUIDs; $ticked : Collection
	var $UUID : Text

	$data:=cs:C1710.ga_quoteLinePricing.me.stepSetDialogData(Form:C1466.current_item.stepUUIDs)
	$window:=Open form window:C675("Quote_pickSteps"; Sheet form window:K39:12)
	DIALOG:C40("Quote_pickSteps"; $data)
	CLOSE WINDOW:C154($window)
	If (OK=1)
		$ticked:=$data.rows.query("selected = :1"; True:C214).extract("UUID")
		$UUIDs:=New collection:C1472
		For each ($UUID; Form:C1466.current_item.stepUUIDs)
			If ($ticked.indexOf($UUID)#-1)
				$UUIDs.push($UUID)
			End if
		End for each
		For each ($UUID; $ticked)
			If ($UUIDs.indexOf($UUID)=-1)
				$UUIDs.push($UUID)
			End if
		End for each
		This:C1470._setSteps($UUIDs; -1)
	End if


Function _moveStep($index : Integer; $delta : Integer)
	var $UUIDs : Collection
	var $UUID : Text
	$UUIDs:=Form:C1466.current_item.stepUUIDs
	$UUID:=$UUIDs[$index]
	$UUIDs[$index]:=$UUIDs[$index+$delta]
	$UUIDs[$index+$delta]:=$UUID
	This:C1470._setSteps($UUIDs; $index+$delta)


	// the new list onto the set, then the panel list again with the row $select (0-based) selected
Function _setSteps($UUIDs : Collection; $select : Integer)
	Form:C1466.current_item.setSteps($UUIDs)
	This:C1470._activate_save_cancel_button()
	This:C1470.loadSteps()
	If ($select>=0) && ($select<Form:C1466.lb_setSteps.length)
		Form:C1466.current_setStep:=Form:C1466.lb_setSteps[$select]
		LISTBOX SELECT ROW:C912(*; "lb_setSteps"; $select+1; lk replace selection:K53:1)
	End if


	// the flow the set usually goes with, offered on the quote when it has another one
Function pup_priceFlow()
	var $flow : cs:C1710.PriceFlowEntity
	var $menu; $choice : Text

	If (Form event code:C388#On Clicked:K2:4) || Not:C34(Form:C1466.sfw.checkIsInModification())
		return
	End if
	$menu:=Create menu:C408
	APPEND MENU ITEM:C411($menu; "None"; *)
	SET MENU ITEM PARAMETER:C1004($menu; -1; "0"*32)
	APPEND MENU ITEM:C411($menu; "-")
	For each ($flow; ds:C1482.PriceFlow.all().orderBy("levelID asc"))
		APPEND MENU ITEM:C411($menu; $flow.code+" - "+$flow.name; *)
		SET MENU ITEM PARAMETER:C1004($menu; -1; $flow.UUID)
		If ($flow.UUID=Form:C1466.current_item.UUID_PriceFlow)
			SET MENU ITEM MARK:C208($menu; -1; Char:C90(18))
		End if
	End for each
	$choice:=Dynamic pop up menu:C1006($menu)
	RELEASE MENU:C978($menu)
	If ($choice#"") && ($choice#Form:C1466.current_item.UUID_PriceFlow)
		Form:C1466.current_item.UUID_PriceFlow:=$choice
		This:C1470._activate_save_cancel_button()
		This:C1470.drawPup_priceFlow()
	End if

Function drawPup_priceFlow()
	If (Form:C1466.current_item=Null:C1517)
		return
	End if
	Form:C1466.sfw.drawButtonPup("pup_priceFlow"; (Form:C1466.current_item.priceFlowText="") ? "None" : Form:C1466.current_item.priceFlowText; "sfw/image/skin/rainbow/icon/spacer-1x24.png"; False:C215)

Function entryField_active()
	If (FORM Event:C1606.code=On Clicked:K2:4)
		This:C1470._activate_save_cancel_button()
	End if
