singleton Class constructor
	//It's a singleton class

Function _activate_save_cancel_button()
	//Touching the primary key marks the entity as touched so sfw enables Save/Cancel
	Form:C1466.current_item.UUID:=Form:C1466.current_item.UUID

Function formMethod()
	//This function manages the main logic for updating and refreshing the form
	Form:C1466.sfw.panelFormMethod()  //The main body of the form method and basic sfw functionalities
	If (Form:C1466.sfw.updateOfPanelNeeded())  //The current item is changed or reloaded, so it's necessary ti refresh
		This:C1470.loadBOTerms()
	End if
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())  //a page is displayed so it's time to load the sources of data to display
		Case of
			: (FORM Get current page:C276(*)=1)
				This:C1470.loadBOTerms()
		End case
	End if
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())  //It's time to resize the object or set visible
		This:C1470.redrawAndSetVisible()
	End if

Function redrawAndSetVisible()
	//Adjusts the layout and visibility of form elements based on the current page and modification state
	var $isInModification : Boolean
	var $widthSubform; $heightSubform; $g; $h; $d; $b; $offset : Integer

	$isInModification:=Form:C1466.sfw.checkIsInModification()

	//reordering is only offered while the model is being edited
	OBJECT SET ENABLED:C1123(*; "bTermUp"; $isInModification)
	OBJECT SET ENABLED:C1123(*; "bTermDown"; $isInModification)

	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$offset:=12

	Case of
		: (FORM Get current page:C276(*)=1)
			// the terms list keeps its width with its buttons pinned underneath,
			// the Write Pro zone takes all the remaining space
			OBJECT GET COORDINATES:C663(*; "bAction_boTerms"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "bAction_boTerms"; $g; $heightSubform-$offset-27; $d; $heightSubform-$offset-6)

			OBJECT GET COORDINATES:C663(*; "bTermUp"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "bTermUp"; $g; $heightSubform-$offset-27; $d; $heightSubform-$offset-6)

			OBJECT GET COORDINATES:C663(*; "bTermDown"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "bTermDown"; $g; $heightSubform-$offset-27; $d; $heightSubform-$offset-6)

			OBJECT GET COORDINATES:C663(*; "lb_boTerms"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "lb_boTerms"; $g; $h; $d; $heightSubform-$offset-33)

			OBJECT GET COORDINATES:C663(*; "WParea_model"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "WParea_model"; $g; $h; $widthSubform-$offset; $heightSubform-$offset)
	End case

	//Mark:-Stored list of terms

Function _items()->$items : Collection
	//Read-only access to current_item.boTerms.items.
	//It must never write into current_item: merely opening a record would then
	//touch the entity and light up Save/Cancel with nothing actually changed.
	$items:=New collection:C1472
	If (Form:C1466.current_item#Null:C1517)
		If (Form:C1466.current_item.boTerms#Null:C1517)
			If (Form:C1466.current_item.boTerms.items#Null:C1517)
				$items:=Form:C1466.current_item.boTerms.items
			End if
		End if
	End if

Function loadBOTerms()
	//Rebuilds the displayed list from the stored {UUID; order} pairs, in order
	var $items : Collection
	var $item : Object
	var $eTerms : cs:C1710.BOTermSelection
	var $eTerm : cs:C1710.BOTermEntity

	Form:C1466.lb_boTerms:=New collection:C1472

	//a stored item with no UUID would blow up the query placeholder, so drop those
	$items:=This:C1470._items().query("UUID # null and UUID # :1"; "").orderBy("order")
	If ($items.length=0)
		return
	End if

	$eTerms:=ds:C1482.BOTerm.query("UUID in :1"; $items.extract("UUID"))
	For each ($item; $items)
		$eTerm:=$eTerms.query("UUID = :1"; $item.UUID).first()
		If ($eTerm#Null:C1517)
			Form:C1466.lb_boTerms.push(New object:C1471(\
				"UUID"; $eTerm.UUID; \
				"code"; $eTerm.code; \
				"order"; $item.order))
		End if
	End for each

Function _renumber()
	//Rewrites order 1..n following the current list order and stores it back in boTerms
	var $i : Integer
	var $items : Collection

	$items:=New collection:C1472
	For ($i; 0; Form:C1466.lb_boTerms.length-1)
		Form:C1466.lb_boTerms[$i].order:=$i+1
		$items.push(New object:C1471("UUID"; Form:C1466.lb_boTerms[$i].UUID; "order"; $i+1))
	End for
	Form:C1466.current_item.boTerms:=New object:C1471("items"; $items)

	//Mark:-Assembled document

Function buildModel()
	//Assembles current_item.model by appending each term's own Write Pro content,
	//in list order, so the bold code / normal text formatting is preserved
	var $wp : Object
	var $range : Object
	var $item : Object
	var $eTerms : cs:C1710.BOTermSelection
	var $eTerm : cs:C1710.BOTermEntity
	var $isFirst : Boolean

	$wp:=WP New:C1317()
	$isFirst:=True:C214

	If (Form:C1466.lb_boTerms.length>0)
		$eTerms:=ds:C1482.BOTerm.query("UUID in :1"; Form:C1466.lb_boTerms.extract("UUID"))
		For each ($item; Form:C1466.lb_boTerms)
			$eTerm:=$eTerms.query("UUID = :1"; $item.UUID).first()
			If ($eTerm#Null:C1517) && ($eTerm.content#Null:C1517)
				If (Not:C34($isFirst))
					//blank paragraph between two terms
					$range:=WP Text range:C1341($wp; wk end text:K81:164; wk end text:K81:164)
					WP SET TEXT:C1574($range; Char:C90(Carriage return:K15:38); wk append:K81:179)
				End if
				WP INSERT DOCUMENT:C1411($wp; $eTerm.content; wk append:K81:179)
				$isFirst:=False:C215
			End if
		End for each
	End if

	Form:C1466.current_item.model:=$wp

	//Mark:-Actions

Function bAction_boTerms()
	//Gear menu of the terms list: add, remove, rebuild
	var $mainMenu : Text
	var $choose : Text
	var $isInModification : Boolean
	var $hasSelection : Boolean
	var $plurial : Boolean

	$isInModification:=Form:C1466.sfw.checkIsInModification()
	$hasSelection:=False:C215
	If (Form:C1466.selected_boTerms#Null:C1517)
		$hasSelection:=Form:C1466.selected_boTerms.length>0
	End if
	$plurial:=$hasSelection && (Form:C1466.selected_boTerms.length>1)

	$mainMenu:=Create menu:C408

	APPEND MENU ITEM:C411($mainMenu; "Add terms..."; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--addBOTerms")
	If (Not:C34($isInModification))
		DISABLE MENU ITEM:C150($mainMenu; -1)
	End if

	APPEND MENU ITEM:C411($mainMenu; "Remove the term"+($plurial ? "s" : "")+"..."; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--removeBOTerms")
	If (Not:C34($isInModification)) || (Not:C34($hasSelection))
		DISABLE MENU ITEM:C150($mainMenu; -1)
	End if

	APPEND MENU ITEM:C411($mainMenu; "-")

	APPEND MENU ITEM:C411($mainMenu; "Rebuild the document"; *)
	SET MENU ITEM PARAMETER:C1004($mainMenu; -1; "--rebuildModel")
	If (Not:C34($isInModification))
		DISABLE MENU ITEM:C150($mainMenu; -1)
	End if

	$choose:=Dynamic pop up menu:C1006($mainMenu)
	RELEASE MENU:C978($mainMenu)

	Case of
		: ($choose="--addBOTerms")
			This:C1470._addBOTerms()

		: ($choose="--removeBOTerms")
			This:C1470._removeBOTerms()

		: ($choose="--rebuildModel")
			This:C1470.buildModel()
			This:C1470._activate_save_cancel_button()

	End case

Function _addBOTerms()
	//Picks among the terms that are not in the model yet and appends them at the end
	var $form : Object
	var $ref : Integer
	var $eTerm : cs:C1710.BOTermEntity
	var $term : Object

	$form:=New object:C1471
	$form.lb_terms:=New collection:C1472

	For each ($eTerm; ds:C1482.BOTerm.query("not(UUID in :1)"; This:C1470._items().extract("UUID")).orderBy("code"))
		$form.lb_terms.push(New object:C1471(\
			"UUID"; $eTerm.UUID; \
			"code"; $eTerm.code; \
			"selected"; False:C215))
	End for each

	If ($form.lb_terms.length=0)
		cs:C1710.sfw_dialog.me.alert("Every BO term is already part of this model.")
		return
	End if

	$ref:=Open form window:C675("BOTermsModel_chooseTerms"; Sheet form window:K39:12)
	DIALOG:C40("BOTermsModel_chooseTerms"; $form)
	CLOSE WINDOW:C154($ref)

	If (ok=1)
		For each ($term; $form.lb_terms)
			If ($term.selected)
				Form:C1466.lb_boTerms.push(New object:C1471(\
					"UUID"; $term.UUID; \
					"code"; $term.code; \
					"order"; 0))
			End if
		End for each
		This:C1470._renumber()
		This:C1470.buildModel()
		This:C1470._activate_save_cancel_button()
	End if

Function _removeBOTerms()
	//Drops the selected terms from the model
	var $ok : Boolean
	var $plurial : Boolean

	$plurial:=Form:C1466.selected_boTerms.length>1
	$ok:=cs:C1710.sfw_dialog.me.confirm("Do you really want to remove the term"+($plurial ? "s" : "")+" from the model? "; "Delete"; "CANCEL")

	If ($ok)
		Form:C1466.lb_boTerms:=Form:C1466.lb_boTerms.query("not(UUID in :1)"; Form:C1466.selected_boTerms.extract("UUID"))
		This:C1470._renumber()
		This:C1470.buildModel()
		This:C1470._activate_save_cancel_button()
	End if

	//Mark:-Ordering

Function bTermUp()
	This:C1470._move(-1)

Function bTermDown()
	This:C1470._move(1)

Function _move($direction : Integer)
	//Moves the current term one step up or down and renumbers the whole list
	var $i : Integer
	var $index : Integer
	var $newIndex : Integer
	var $item : Object

	If (Not:C34(Form:C1466.sfw.checkIsInModification())) || (Form:C1466.selectedBOTerm=Null:C1517)
		return
	End if

	$index:=-1
	For ($i; 0; Form:C1466.lb_boTerms.length-1)
		If (Form:C1466.lb_boTerms[$i].UUID=Form:C1466.selectedBOTerm.UUID)
			$index:=$i
		End if
	End for

	$newIndex:=$index+$direction
	If ($index=-1) || ($newIndex<0) || ($newIndex>=Form:C1466.lb_boTerms.length)
		return
	End if

	$item:=Form:C1466.lb_boTerms[$index]
	Form:C1466.lb_boTerms.remove($index)
	Form:C1466.lb_boTerms.insert($newIndex; $item)

	This:C1470._renumber()
	This:C1470.buildModel()
	This:C1470._activate_save_cancel_button()
