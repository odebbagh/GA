singleton Class constructor
	
	
	// Purpose: Panel controller for RejectCriteriaCategory administration entry.
	// Shows the category fields (page 1) and its items as an editable list (page 2).
	// created by 4D/PS [2026-may-19]
Function formMethod()
	
	Form:C1466.sfw.panelFormMethod()
	If (Form:C1466.sfw.updateOfPanelNeeded())
		
	End if 
	If (Form:C1466.sfw.recalculationOfPanelPageNeeded())
		Case of 
			: (FORM Get current page:C276(*)=1)
				This:C1470.loadItems()
			: (FORM Get current page:C276(*)=2)
				
		End case 
	End if 
	If (Form:C1466.sfw.redrawAndSetVisibleInPanelNeeded())
		This:C1470.redrawAndSetVisible()
	End if 
	
	
Function pup_color()
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.current_item.color:=cs:C1710.sfw_htmlColor.me.deployPup(Form:C1466.current_item.color).hex
	End if 
	
Function redrawAndSetVisible()
	If (Form:C1466.current_item#Null:C1517)
		$color:=cs:C1710.sfw_htmlColor.me.getName(Form:C1466.current_item.color) || ""
		If ($color#"")
			Form:C1466.sfw.drawButtonPup("pup_color"; $color; "sfw/colors/"+$color+"-circle.png"; (Form:C1466.current_item.color=Null:C1517))
		Else 
			Form:C1466.sfw.drawButtonPup("pup_color"; "choice color"; "sfw/colors/colors.png"; (Form:C1466.current_item.color=Null:C1517))
		End if 
	End if 
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($widthSubform; $heightSubform)
	$offset:=4
	Case of 
		: (FORM Get current page:C276(*)=1)
			
			OBJECT GET COORDINATES:C663(*; "lb_items"; $left_lb; $top_lb; $right_lb; $bottom_lb)
			
			OBJECT SET COORDINATES:C1248(*; "lb_items"; $left_lb; $top_lb; $widthSubform-$offset; $heightSubform-$offset-1)
			
			
	End case 
	
	// Purpose: Load all RejectCriteriaItem records belonging to the current category.
	// created by 4D/PS [2026-may-19]
Function loadItems()
	
	Form:C1466.lb_items:=New collection:C1472
	Form:C1466.selectedItem:=Null:C1517
	Form:C1466.selectedItemPos:=0
	
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.lb_items:=ds:C1482.RejectCriteriaItem.query("UUID_RejectCriteriaCategory = :1"; Form:C1466.current_item.UUID).toCollection("name, color").orderBy("levelID")
	End if 
	
/*
// Purpose: Handles listbox events for inline editing of items (onDataChange saves the field, onClick on color column opens color picker).
// created by 4D/PS [2026-may-19]
Function lb_itemsEvent()
	
Case of 
: (Form.sfw.checkIsInModification())
Case of 
: (FORM Event.code=On Clicked)
// Inline field change — persist to the database record immediately
$pos:=Form.selectedItemPos
If ($pos>0)
$row:=Form.lb_items[$pos-1]
$eItem:=ds.RejectCriteriaItem.query("UUID = :1"; $row.UUID).first()
If ($eItem#Null)
$eItem.levelID:=$row.levelID
$eItem.name:=$row.name
$eItem.color:=$row.color
$res:=$eItem.save()
End if 
End if 
	
: (FORM Event.code=On Load)
// Click on the color column opens the color picker for the selected row
$col:=LISTBOX GET CELL POSITION(*; "lb_items"; $c; $r)
If ($c=1)  // color column
$pos:=Form.selectedItemPos
If ($pos>0)
$row:=Form.lb_items[$pos-1]
$newColor:=cs.sfw_htmlColor.me.deployPup($row.color).hex
If ($newColor#"")
$row.color:=$newColor
Form.lb_items[$pos-1]:=$row
$eItem:=ds.RejectCriteriaItem.query("UUID = :1"; $row.UUID).first()
If ($eItem#Null)
$eItem.color:=$newColor
$res:=$eItem.save()
End if 
End if 
End if 
End if 
End case 
End case 
	
	
// Purpose: Action button for the items sub-list: Add / Delete.
// created by 4D/PS [2026-may-19]
Function bActionItems()
	
$refMenu:=Create menu
	
APPEND MENU ITEM($refMenu; "Add item")
SET MENU ITEM PARAMETER($refMenu; -1; "--add")
If (Not(Form.sfw.checkIsInModification()))
DISABLE MENU ITEM($refMenu; -1)
End if 
	
APPEND MENU ITEM($refMenu; "Delete item")
SET MENU ITEM PARAMETER($refMenu; -1; "--delete")
If (Not(Form.sfw.checkIsInModification())) || (Form.selectedItem=Null)
DISABLE MENU ITEM($refMenu; -1)
End if 
	
OBJECT GET COORDINATES(*; "bActionItems"; $left; $top; $right; $bottom)
CONVERT COORDINATES($left; $bottom; XY Current form; XY Current window)
$choose:=Dynamic pop up menu($refMenu; ""; $left; $bottom)
RELEASE MENU($refMenu)
	
Case of 
: ($choose="--add")
$nextLevelID:=Form.lb_items.length+1
$eItem:=ds.RejectCriteriaItem.new()
$eItem.UUID:=_4D IMPORT EXPLORER GROUPS()
$eItem.UUID_RejectCriteriaCategory:=Form.current_item.UUID
$eItem.levelID:=$nextLevelID
$eItem.name:=""
$eItem.color:=""
$res:=$eItem.save()
If ($res.success)
This.loadItems()
This._activate_save_cancel_button()
End if 
	
: ($choose="--delete")
$ok:=cs.sfw_dialog.me.confirm("Delete this item?")
If ($ok)
$eItem:=ds.RejectCriteriaItem.query("UUID = :1"; Form.selectedItem.UUID).first()
If ($eItem#Null)
$res:=$eItem.drop()
If ($res.success)
This.loadItems()
This._activate_save_cancel_button()
End if 
End if 
End if 
End case 
*/
	
	