property lb_items : Variant
property searchbox : Text
property entry : cs:C1710.sfw_definitionEntry
property view : Object
property vision : Object  //the current vision
property lastRefItemInList : Integer
property multiselection : Object
property flags : Object
property allowedViews : Collection
property lb_items_dontPlayOnSelectionChange : Boolean
property searchHighlightParts : Collection
property HLEntries : Object
property currentItemRef : Integer
property rl_itemUUIDs : Collection

Class extends sfw_foundations

Class constructor()
	Super:C1705()
	
	This:C1470.lb_items:=Null:C1517
	This:C1470.searchbox:=""
	
Function initOnLoad()
	
	var $color : Text
	
	OBJECT SET VISIBLE:C603(*; "searchbox_@"; (This:C1470.entry.searchbox#Null:C1517))
	OBJECT SET BORDER STYLE:C1262(*; "searchbox_roundRectangle"; Border None:K42:27)
	
	$file:=Folder:C1567(fk resources folder:K87:11).file(This:C1470.entry.icon)
	READ PICTURE FILE:C678($file.platformPath; vIcon)
	vIcon:=vIcon*0.75
	OBJECT SET FORMAT:C236(*; "bIcon_entry"; This:C1470.entry.label+";vIcon;0;0;0;1;0;0;0;0;0;0;1")
	//OBJECT SET FORMAT(*; "bIcon_entry"; This.entry.label+";#"+This.entry.icon+";0;0;0;1;0;0;0;0;0;0;1")
	
	$color:=This:C1470.vision.toolbar.color
	
	This:C1470.changeTopBarColor($color)
	
	cs:C1710.sfw_window.me.setWindowTitle()
	
	This:C1470._resizeMainWindow()
	
	
Function lb_items_define()
	var $nil : Pointer
	var $table : Pointer
	var $current_panel : Text
	var $i : Integer
	var $column : Object
	
	If (This:C1470.view=Null:C1517) && (Form:C1466.view#Null:C1517)
		This:C1470.view:=Form:C1466.view
	End if 
	
	If (This:C1470.view=Null:C1517)
		This:C1470.allowedViews:=New collection:C1472
		$authorizedProfiles:=cs:C1710.sfw_userManager.me.authorizedProfiles
		For each ($view; This:C1470.entry.views)
			If ($view.allowedProfiles=Null:C1517)
				This:C1470.allowedViews.push($view)
			Else 
				$displayView:=False:C215
				For each ($authorizedProfile; $authorizedProfiles)
					$displayView:=$displayView || ($view.allowedProfiles.indexOf($authorizedProfile)#-1)
				End for each 
				If ($displayView)
					This:C1470.allowedViews.push($view)
				End if 
			End if 
		End for each 
		If (This:C1470.allowedViews.length>0)
			This:C1470.view:=This:C1470.allowedViews[0]
		Else 
			CANCEL:C270
			return 
		End if 
	End if 
	OBJECT SET VISIBLE:C603(*; "pupViews"; (This:C1470.allowedViews.length>1))
	This:C1470._displayPupViews()
	
	LISTBOX DELETE COLUMN:C830(*; "lb_items"; 1; 1000)  //1000 is enought !
	
	Form:C1466.itemListColumnGroups:=New collection:C1472
	$i:=0
	For each ($column; This:C1470.view.lb_items.columns)
		$i:=$i+1
		If (Not:C34(Bool:C1537($column.hidden)))
			If ($column.group#Null:C1517)
				$columnName:=$column.columnName || ("col_"+String:C10($i))
				$groups:=Form:C1466.itemListColumnGroups.query("group = :1"; $column.group)
				If ($groups.length#0)
					$group:=$groups[0]
					$group.countColumns+=1
					$i-=1
					continue
				Else 
					Form:C1466.itemListColumnGroups.push({group: $column.group; columnNum: $i; case: 1; columnName: $columnName; countColumns: 1})
				End if 
			End if 
		End if 
	End for each 
	Form:C1466.itemListColumnGroups:=Form:C1466.itemListColumnGroups.query("countColumns >1")
	Form:C1466.itemListColumnGroups2:=New collection:C1472
	$i:=0
	$firstDefaultColumnOrderBy:=Try(Form:C1466.sfw.entry.lb_items.orderBy[0].propertyPath) || ""
	For each ($column; This:C1470.view.lb_items.columns)
		$i:=$i+1
		If (Not:C34(Bool:C1537($column.hidden)))
			$columnName:=$column.columnName || ("col_"+String:C10($i))
			$headerName:="header_"+String:C10($i)
			$columnType:=Is text:K8:3
			$columnFormula:="Form:C1466.sfw._lb_items_highlight(This."+$column.attribute+")"
			Case of 
				: ($column.type=Null:C1517)
				: ($column.type="text")
					$columnType:=Is text:K8:3
					If ($column.formula=Null:C1517)
						$columnFormula:="Form:C1466.sfw._lb_items_highlight(This."+$column.attribute+")"
					Else 
						$columnFormula:="Form:C1466.sfw._lb_items_highlight("+$column.formula+")"
					End if 
					
				: ($column.type="picture")
					$columnType:=Is picture:K8:10
					If ($column.formula=Null:C1517)
						$columnFormula:="This."+$column.attribute
					Else 
						$columnFormula:=$column.formula
					End if 
					If ($column.format=Null:C1517)
						Use ($column)
							$column.format:=Char:C90(Truncated centered:K6:1)
						End use 
					End if 
					
				: ($column.type="num")
					$columnType:=Is real:K8:4
					If ($column.formula=Null:C1517)
						$columnFormula:="This."+$column.attribute
					Else 
						$columnFormula:=$column.formula
					End if 
					If ($column.format=Null:C1517)
						Use ($column)
							$column.format:="###,###,###,##0"
						End use 
					End if 
					
				: ($column.type="date")
					$columnType:=Is date:K8:7
					If ($column.format=Null:C1517)
						Use ($column)
							$column.formatDate:=System date short:K1:1
						End use 
					Else 
						Use ($column)
							$column.formatDate:=Num:C11($column.format)
						End use 
					End if 
					
					$columnFormula:="String:C10(This."+$column.attribute+";"+String:C10($column.formatDate+Blank if null date:K1:9)+")"
					
				: ($column.type="bool") || ($column.type="boolean")
					$columnType:=Is boolean:K8:9
					If ($column.formula=Null:C1517)
						$columnFormula:="Bool(This."+$column.attribute+")"
					Else 
						$columnFormula:=$column.formula
					End if 
					
				: ($column.type="flag")
					$columnType:=Is picture:K8:10
					Use ($column)
						$column.format:=Char:C90(Truncated centered:K6:1)
					End use 
					$columnFormula:="Form.sfw._lb_drawFlagInColumn(This."+$column.attribute+")"
					
			End case 
			Use ($column)
				$column.calculatedFormula:=$columnFormula
				$column.calculatedType:=$columnType
			End use 
			If ($column.group#Null:C1517)
				If (Form:C1466.itemListColumnGroups2.indices("group = :1"; $column.group).length#0)
					$i-=1
					continue
				Else 
					Form:C1466.itemListColumnGroups2.push({group: $column.group; columnNum: $i; case: 1; columnName: $columnName})
				End if 
			End if 
			
			LISTBOX INSERT COLUMN FORMULA:C970(*; "lb_items"; 1000; $columnName; $columnFormula; $columnType; $headerName; $nil)
			Case of 
				: ($columnType=Is text:K8:3)
					LISTBOX SET PROPERTY:C1440(*; $columnName; lk multi style:K53:71; lk yes:K53:69)
					LISTBOX SET PROPERTY:C1440(*; $columnName; lk truncate:K53:37; lk without ellipsis:K53:64)
				: ($columnType=Is boolean:K8:9)
					OBJECT SET FORMAT:C236(*; $columnName; " ")
			End case 
			OBJECT SET TITLE:C194(*; $headerName; ds:C1482.sfw_readXliff($column.xliff; $column.label))
			Case of 
				: ($column.width#Null:C1517) && ($column.widthMin#Null:C1517) && ($column.widthMax#Null:C1517)
					LISTBOX SET COLUMN WIDTH:C833(*; $columnName; Num:C11($column.width); Num:C11($column.widthMin); Num:C11($column.widthMax))
				: ($column.width#Null:C1517) && ($column.widthMin#Null:C1517)
					LISTBOX SET COLUMN WIDTH:C833(*; $columnName; Num:C11($column.width); Num:C11($column.widthMin))
				: ($column.width#Null:C1517)
					LISTBOX SET COLUMN WIDTH:C833(*; $columnName; Num:C11($column.width))
			End case 
			If ($column.header#Null:C1517)
				If ($column.header.alignment#Null:C1517)
					OBJECT SET HORIZONTAL ALIGNMENT:C706(*; $headerName; $column.header.alignment)
				End if 
				If ($column.header.stroke#Null:C1517)
					OBJECT SET RGB COLORS:C628(*; $headerName; $column.header.stroke)
				End if 
			End if 
			If ($column.group#Null:C1517) && (Form:C1466.itemListColumnGroups.query("group = :1"; $column.group).length>0)
				OBJECT SET FORMAT:C236(*; $headerName; "file:sfw/image/picto/control-skip-090-small.png;2")
			End if 
			If ($column.alignment#Null:C1517)
				OBJECT SET HORIZONTAL ALIGNMENT:C706(*; $columnName; $column.alignment)
			End if 
			Case of 
				: ($column.formatDate#Null:C1517)
					//OBJECT SET FORMAT(*; $columnName; Char(System date long))
					
				: ($column.format#Null:C1517)
					OBJECT SET FORMAT:C236(*; $columnName; $column.format)
					
				Else 
					OBJECT SET FORMAT:C236(*; $columnName; "")
			End case 
			$ptrHeader:=OBJECT Get pointer:C1124(Object named:K67:5; $headerName)
			If ($firstDefaultColumnOrderBy=$column.attribute)
				$ptrHeader->:=1
			Else 
				$ptrHeader->:=0
			End if 
		End if 
	End for each 
	//Form.itemListColumnGroups
	LISTBOX SET PROPERTY:C1440(*; "lb_items"; lk sortable:K53:45; lk no:K53:68)
	$selectionMode:=(This:C1470.entry.multiselection#Null:C1517) ? lk multiple:K53:59 : lk single:K53:58
	LISTBOX SET PROPERTY:C1440(*; "lb_items"; lk selection mode:K53:35; $selectionMode)
	If (This:C1470.view.lb_items.metaExpression#Null:C1517) && (This:C1470.view.lb_items.metaExpression#"")
		LISTBOX SET PROPERTY:C1440(*; "lb_items"; lk meta expression:K53:75; String:C10(This:C1470.view.lb_items.metaExpression))
	End if 
	
	//This.displayDefaultPanel()
	
Function displayDefaultPanel()
	var $table : Pointer
	var $current_panel : Text
	var $panel : Text
	
	OBJECT GET SUBFORM:C1139(*; "detail_panel"; $table; $current_panel)
	Case of 
		: (Form:C1466.sfw.entry.panelAfterProjectionIfNoItemSelected#Null:C1517) && (Form:C1466.filterByProjection) && (Form:C1466.lastPanelDisplayed#Form:C1466.sfw.entry.panelAfterProjectionIfNoItemSelected)
			Form:C1466.subForm:=New object:C1471
			Form:C1466.subForm.sfw:=Form:C1466.sfw
			$panel:=Form:C1466.sfw.entry.panelAfterProjectionIfNoItemSelected
			OBJECT SET SUBFORM:C1138(*; "detail_panel"; $panel)
			Form:C1466.lastPanelDisplayed:=String:C10($panel)
			
		: (Form:C1466.sfw.entry.panelIfNoItemSelected#Null:C1517) && (Form:C1466.filterByProjection=False:C215) && ((Form:C1466.current_lb_item_selected.length=0) || (Form:C1466.current_item=Null:C1517))
			
			If (Form:C1466.lastPanelDisplayed#Form:C1466.sfw.entry.panelIfNoItemSelected)
				Form:C1466.subForm.sfw:=Form:C1466.sfw
				$panel:=Form:C1466.sfw.entry.panelIfNoItemSelected
				OBJECT SET SUBFORM:C1138(*; "detail_panel"; $panel)
				Form:C1466.lastPanelDisplayed:=String:C10($panel)
			End if 
			
		: ($current_panel#"sfw_panel_default")
			OBJECT SET SUBFORM:C1138(*; "detail_panel"; "sfw_panel_default")
			Form:C1466.lastPanelDisplayed:=String:C10("sfw_panel_default")
			
	End case 
	
	
	
Function lb_items_search()
	
	Case of 
		: (This:C1470.view.subset#Null:C1517)
			Case of 
				: (This:C1470.view.subset.functionName#Null:C1517) && (This:C1470.searchbox="")
					$functionName:=This:C1470.view.subset.functionName
					If (This:C1470.view.subset.params=Null:C1517)
						This:C1470.lb_items:=ds:C1482[This:C1470.entry.dataclass][$functionName]().copy()
					Else 
						This:C1470.lb_items:=ds:C1482[This:C1470.entry.dataclass][$functionName].apply(ds:C1482[This:C1470.entry.dataclass]; This:C1470.view.subset.params).copy()
					End if 
					
				: (This:C1470.view.subset.functionName#Null:C1517)
					This:C1470._searchEngine()
				Else 
					This:C1470.lb_items:=ds:C1482[This:C1470.entry.dataclass].all().copy()
			End case 
			
		: (This:C1470.searchbox="")
			This:C1470.searchHighlightParts:=Null:C1517
			This:C1470.lb_items:=ds:C1482[This:C1470.entry.dataclass].all().copy()
		Else 
			This:C1470._searchEngine()
	End case 
	
	This:C1470._applyFilters()
	
	This:C1470.lb_items_sort()
	
	This:C1470.lb_items_counter_format()
	
	Case of 
		: (This:C1470.view.displayType="listbox")
			Form:C1466.current_item:=Null:C1517
			If (Form:C1466.subForm#Null:C1517)
				This:C1470.lb_items_selectionChange()
			End if 
			
		: (This:C1470.view.displayType="hierarchical")
			This:C1470._drawHierarchicalList()
			
		: (This:C1470.view.displayType="hierarchicalEntries")
			This:C1470._drawHierarchicalEntries()
			
		: (This:C1470.view.displayType="recursiveList")
			This:C1470._drawRecursiveList()
			
	End case 
	
Function lb_items_counter_format()
	If (This:C1470.view.lb_items.counter#Null:C1517)
		$counterFormat:=This:C1470.view.lb_items.counter.format
		If (This:C1470.lb_items.length=1)
			$counterFormat:=Replace string:C233($counterFormat; "^1"; ds:C1482.sfw_readXliff(String:C10(This:C1470.view.lb_items.counter.unit1xliff); This:C1470.view.lb_items.counter.unit1))
		Else 
			$counterFormat:=Replace string:C233($counterFormat; "^1"; ds:C1482.sfw_readXliff(String:C10(This:C1470.view.lb_items.counter.unitNxliff); This:C1470.view.lb_items.counter.unitN))
		End if 
	Else 
		$counterFormat:="###,###,##0;;"
	End if 
	OBJECT SET FORMAT:C236(*; "lb_items_counter"; $counterFormat)
	OBJECT SET HORIZONTAL ALIGNMENT:C706(*; "lb_items_counter"; Align right:K42:4)
	
	If (This:C1470.entry.multiselection#Null:C1517)
		If (This:C1470.entry.multiselection.counterSelected#Null:C1517)
			$counterFormat:=This:C1470.entry.multiselection.counterSelected.format
			If (Form:C1466.current_lb_item_selected.length=1)
				$counterFormat:=Replace string:C233($counterFormat; "^1"; ds:C1482.sfw_readXliff(String:C10(This:C1470.entry.multiselection.counterSelected.unit1xliff); This:C1470.entry.multiselection.counterSelected.unit1))
			Else 
				$counterFormat:=Replace string:C233($counterFormat; "^1"; ds:C1482.sfw_readXliff(String:C10(This:C1470.entry.multiselection.counterSelected.unitNxliff); This:C1470.entry.multiselection.counterSelected.unitN))
			End if 
		Else 
			$counterFormat:="###,###,##0;;"
		End if 
		OBJECT SET FORMAT:C236(*; "lb_items_counterSelected"; $counterFormat)
		OBJECT SET HORIZONTAL ALIGNMENT:C706(*; "lb_items_counterSelected"; Align right:K42:4)
		OBJECT SET VISIBLE:C603(*; "lb_items_counterSelected"; (This:C1470.entry.multiselection.counterSelected.nbMinimum<=Form:C1466.current_lb_item_selected.length))
	Else 
		OBJECT SET VISIBLE:C603(*; "lb_items_counterSelected"; False:C215)
	End if 
	
Function lb_items_sort()
	Case of 
		: (This:C1470.view.displayType="listbox")
			This:C1470.lb_items:=This:C1470.lb_items.orderBy(This:C1470.view.lb_items.orderBy)
	End case 
	
	
Function lb_items_selectionChange()
	Form:C1466.subForm.current_item:=Form:C1466.current_item
	Case of 
		: (Form:C1466.current_lb_item_selected#Null:C1517) & (Form:C1466.current_lb_item_selected.length>1)
			Form:C1466.current_item:=Null:C1517
			Form:C1466.subForm.current_item:=Form:C1466.current_item
			Form:C1466.current_clone:=Null:C1517
			This:C1470.displayDefaultPanel()
			cs:C1710.sfw_commentManager.me.hide()
			cs:C1710.sfw_eventManager.me.hide()
			
		: (Form:C1466.current_item#Null:C1517)
			Form:C1466.subForm.current_item:=Form:C1466.current_item
			Form:C1466.current_clone:=Form:C1466.current_item.clone()
			OBJECT GET SUBFORM:C1139(*; "detail_panel"; $table; $current_panel)
			If ($current_panel#This:C1470.entry.panel.name) && (Form:C1466.lastPanelDisplayed#This:C1470.entry.panel.name)
				This:C1470.callbackOnCurrentItem("panelUnload")
				This:C1470.callbackOnCurrentItem("itemLoad")
				This:C1470.displayItemPanel()
			Else 
				This:C1470.callbackOnCurrentItem("itemLoad")
				Form:C1466.subForm:=Form:C1466.subForm
			End if 
			If (This:C1470.entry.comment#Null:C1517)
				cs:C1710.sfw_commentManager.me.refresh(Form:C1466.current_item.UUID)
			Else 
				cs:C1710.sfw_commentManager.me.hide()
			End if 
			If (This:C1470.entry.event#Null:C1517)
				cs:C1710.sfw_eventManager.me.refresh(Form:C1466.current_item.UUID; This:C1470.entry)
			Else 
				cs:C1710.sfw_eventManager.me.hide()
			End if 
		Else 
			Form:C1466.current_clone:=Null:C1517
			This:C1470.displayDefaultPanel()
			cs:C1710.sfw_commentManager.me.hide()
			cs:C1710.sfw_eventManager.me.hide()
	End case 
	If (Form:C1466.situation.mode#"add") & (Form:C1466.situation.mode#"duplicate")
		This:C1470._change_bMode(Form:C1466.situation.mode)
	End if 
	cs:C1710.sfw_window.me.setWindowTitle()
	This:C1470._displayHeaderTabFavorite()
	This:C1470._displayHeaderTabSubscription()
	This:C1470._displayHeaderTabAssignation()
	This:C1470._displayHeaderTabComment()
	This:C1470._displayHeaderTabEvent()
	
	
	
Function lb_items_selectorManage()
	Case of 
		: (FORM Event:C1606.code=On Double Clicked:K2:5)
			Form:C1466.current_item:=Form:C1466.current_lb_item
			Form:C1466.selected:=True:C214
			ACCEPT:C269
			
		: (FORM Event:C1606.code=On Clicked:K2:4)
			This:C1470.lb_items_selectorChange()
			
			
		: (FORM Event:C1606.code=On Header Click:K2:40) & (Contextual click:C713 || Right click:C712)
			This:C1470.lb_items_doEventContextualHeaderClic()
			
		: (FORM Event:C1606.code=On Header Click:K2:40)
			This:C1470.lb_items_doEventHeaderClic()
			
	End case 
	
Function lb_items_selectorChange()
	
	
Function lb_items_doEvent()
	var $orderBy : Text
	var $orderByFormula : Object
	var $previousItem : 4D:C1709.Entity
	
	Case of 
		: (FORM Event:C1606.code=On Double Clicked:K2:5)
			If (Form:C1466.current_lb_item_pos#0) & (Not:C34(Bool:C1537(cs:C1710.sfw_definition.me.globalParameters.mainInterface.disableDoubleClickLbItems)))
				Form:C1466.sfw.openInANewWindow(Form:C1466.sfw.lb_items[Form:C1466.current_lb_item_pos-1]; Form:C1466.sfw.vision.ident; Form:C1466.sfw.entry.ident)
			End if 
			
		: (FORM Event:C1606.code=On Clicked:K2:4) & (Right click:C712) & (Not:C34(Bool:C1537(cs:C1710.sfw_definition.me.globalParameters.mainInterface.disableContectualMenuLbItems)))
			
			$refMenus:=New collection:C1472
			$refMenu:=Create menu:C408
			$refMenus.push($refMenu)
			APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("main.unselectedAll"; "Unselect all"); *)
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--unselectAll")
			SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/unselectAll-24x24.png")
			
			APPEND MENU ITEM:C411($refMenu; "-")
			APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("main.openNewWindow"; "Open in a new window..."); *)
			SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/openWindow-24x24.png")
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--open")
			If (Form:C1466.current_lb_item_pos=0)
				DISABLE MENU ITEM:C150($refMenu; -1)
			End if 
			
			$refMenuAction:=This:C1470._buildMenuAction($refMenus)
			If (Count menu items:C405($refMenuAction)>0)
				APPEND MENU ITEM:C411($refMenu; "-")
				APPEND MENU ITEM:C411($refMenu; "Actions"; $refMenuAction; *)
				SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/action-24x24.png")
			End if 
			
			$refMenuProjection:=This:C1470._buildMenuProjection($refMenus)
			If (Count menu items:C405($refMenuProjection)>0)
				APPEND MENU ITEM:C411($refMenu; "-")
				APPEND MENU ITEM:C411($refMenu; "Projection"; $refMenuProjection; *)
				SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/projection-24x24.png")
			End if 
			
			$choose:=Dynamic pop up menu:C1006($refMenu)
			For each ($refMenu; $refMenus)
				RELEASE MENU:C978($refMenu)
			End for each 
			
			This:C1470._executeMenuAction($choose)
			This:C1470._executeMenuProjection($choose)
			Case of 
				: ($choose="--unselectAll")
					Form:C1466.current_lb_item_pos:=0
					Form:C1466.current_item:=Null:C1517
					LISTBOX SELECT ROW:C912(*; "lb_items"; 0; lk remove from selection:K53:3)
					This:C1470.lb_items_selectionChange()
					
				: ($choose="--open")
					Form:C1466.sfw.openInANewWindow(Form:C1466.sfw.lb_items[Form:C1466.current_lb_item_pos-1]; Form:C1466.sfw.vision.ident; Form:C1466.sfw.entry.ident)
					
			End case 
			
			
		: (FORM Event:C1606.code=On Clicked:K2:4)
			If (This:C1470.nothingToSave())
				Form:C1466.previous_current_lb_item_pos:=Form:C1466.current_lb_item_pos
			Else 
				$pos:=Num:C11(Form:C1466.previous_current_lb_item_pos)
				LISTBOX SELECT ROW:C912(*; "lb_items"; $pos; lk replace selection:K53:1)
				This:C1470.lb_items_dontPlayOnSelectionChange:=True:C214
			End if 
			
		: (FORM Event:C1606.code=On Selection Change:K2:29) & (Bool:C1537(This:C1470.lb_items_dontPlayOnSelectionChange))
			This:C1470.lb_items_dontPlayOnSelectionChange:=False:C215
			
		: (FORM Event:C1606.code=On Selection Change:K2:29)
			$previousItem:=Form:C1466.current_item
			Form:C1466.current_item:=Form:C1466.current_lb_item
			If (Form:C1466.current_lb_item#Null:C1517)
				// current situation
				This:C1470.lb_items_selectionChange()
				
			Else 
				If ($previousItem#Null:C1517)
					This:C1470.callbackOnCurrentItem("panelUnload"; $previousItem)
				End if 
				// after a deletion in another process
				If (Form:C1466.current_lb_item_pos>0)
					This:C1470.lb_items:=This:C1470.lb_items.slice(0; Form:C1466.current_lb_item_pos-1).or(This:C1470.lb_items.slice(Form:C1466.current_lb_item_pos))
					This:C1470.lb_items_sort()
					LISTBOX SELECT ROW:C912(*; "lb_items"; 0; lk remove from selection:K53:3)
				End if 
				This:C1470.lb_items_selectionChange()
			End if 
			
			
		: (FORM Event:C1606.code=On Header Click:K2:40) & (Contextual click:C713 || Right click:C712)
			
			This:C1470.lb_items_doEventContextualHeaderClic()
			
		: (FORM Event:C1606.code=On Header Click:K2:40)
			This:C1470.lb_items_doEventHeaderClic()
			
			
			
	End case 
	
	This:C1470.lb_items_counter_format()
	
	
Function lb_items_doEventHeaderClic()
	
	$headerButton:=OBJECT Get pointer:C1124(Object named:K67:5; FORM Event:C1606.headerName)
	$columnNum:=Num:C11(Split string:C1554(FORM Event:C1606.headerName; "_").pop())
	$group:=Form:C1466.itemListColumnGroups.query("columnName = :1"; FORM Event:C1606.columnName).first()
	If ($group=Null:C1517)
		$column:=This:C1470.view.lb_items.columns.query("columnName = :1"; String:C10(FORM Event:C1606.columnName)).first()
		If ($column=Null:C1517)
			$column:=This:C1470.view.lb_items.columns[$columnNum-1]
		End if 
	Else 
		$column:=Form:C1466.sfw.view.lb_items.columns.query("group=:1"; $group.group)[$group.case-1]
	End if 
	$orderBy:=""
	If ($column.orderBy#Null:C1517)
		Case of 
			: ($column.orderBy.path#Null:C1517)
				$orderBy:=$column.orderBy.path
			: ($column.orderBy.formula#Null:C1517)
				$orderByFormula:=Formula from string:C1601($column.orderBy.formula)
		End case 
	Else 
		$orderBy:=$column.attribute
	End if 
	If ($orderByFormula=Null:C1517)
		Case of 
			: ($headerButton->=0) | ($headerButton->=2)
				$headerButton->:=1
				This:C1470.lb_items:=This:C1470.lb_items.orderBy($orderBy)
			: ($headerButton->=1)
				$orderBy:=$orderBy+" desc"
				$headerButton->:=2
				This:C1470.lb_items:=This:C1470.lb_items.orderBy($orderBy)
		End case 
	Else 
		Case of 
			: ($headerButton->=0) | ($headerButton->=2)
				$headerButton->:=1
				This:C1470.lb_items:=This:C1470.lb_items.orderByFormula($orderByFormula)
			: ($headerButton->=1)
				$headerButton->:=2
				This:C1470.lb_items:=This:C1470.lb_items.orderByFormula($orderByFormula; dk descending:K85:32)
		End case 
	End if 
	
Function lb_items_doEventContextualHeaderClic()
	
	var $orderBy : Text
	var $orderByFormula : Object
	var $previousItem : 4D:C1709.Entity
	
	$group:=Form:C1466.itemListColumnGroups.query("columnName = :1"; FORM Event:C1606.columnName).first()
	If ($group=Null:C1517)
		//ALERT("pas de group!")
		//continue
	Else 
		$groupName:=$group.group
		$groupCase:=$group.case
		$refMenu:=Create menu:C408
		$columns:=Form:C1466.sfw.view.lb_items.columns.query("group = :1"; $groupName)
		$i:=0
		For each ($column; $columns)
			Case of 
				: ($column.hidden)
				Else 
					$i+=1
					APPEND MENU ITEM:C411($refMenu; $column.label)
					SET MENU ITEM PARAMETER:C1004($refMenu; -1; "case:"+String:C10($i))
					If ($groupCase=$i)
						SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
					End if 
			End case 
		End for each 
		$choice:=Dynamic pop up menu:C1006($refMenu)
		RELEASE MENU:C978($refMenu)
		
		Case of 
			: ($choice="case:@")
				$numCase:=Num:C11(Substring:C12($choice; 6))
				If ($group.case#$numCase)
					$column:=$columns[$numCase-1]
					LISTBOX SET COLUMN FORMULA:C1203(*; FORM Event:C1606.columnName; $column.calculatedFormula; $column.calculatedType)
					OBJECT SET TITLE:C194(*; "Header_"+String:C10(FORM Event:C1606.column); $column.label)
					$group.case:=$numCase
					$headerButton:=OBJECT Get pointer:C1124(Object named:K67:5; FORM Event:C1606.headerName)
					If ($column.format#Null:C1517)
						OBJECT SET FORMAT:C236(*; FORM Event:C1606.columnName; $column.format)
					Else 
						OBJECT SET FORMAT:C236(*; FORM Event:C1606.columnName; "")
					End if 
					Case of 
						: ($column.width#Null:C1517) && ($column.widthMin#Null:C1517) && ($column.widthMax#Null:C1517)
							LISTBOX SET COLUMN WIDTH:C833(*; FORM Event:C1606.columnName; Num:C11($column.width); Num:C11($column.widthMin); Num:C11($column.widthMax))
						: ($column.width#Null:C1517) && ($column.widthMin#Null:C1517)
							LISTBOX SET COLUMN WIDTH:C833(*; FORM Event:C1606.columnName; Num:C11($column.width); Num:C11($column.widthMin))
						: ($column.width#Null:C1517)
							LISTBOX SET COLUMN WIDTH:C833(*; FORM Event:C1606.columnName; Num:C11($column.width))
					End case 
					$orderBy:=""
					If ($column.orderBy#Null:C1517)
						Case of 
							: ($column.orderBy.path#Null:C1517)
								$orderBy:=$column.orderBy.path
							: ($column.orderBy.formula#Null:C1517)
								$orderByFormula:=Formula from string:C1601($column.orderBy.formula)
						End case 
					Else 
						$orderBy:=$column.attribute
					End if 
					If ($orderByFormula=Null:C1517)
						Case of 
							: ($headerButton->=0)
							: ($headerButton->=1)
								This:C1470.lb_items:=This:C1470.lb_items.orderBy($orderBy)
							: ($headerButton->=2)
								$orderBy:=$orderBy+" desc"
								This:C1470.lb_items:=This:C1470.lb_items.orderBy($orderBy)
						End case 
					Else 
						Case of 
							: ($headerButton->=0)
							: ($headerButton->=1)
								This:C1470.lb_items:=This:C1470.lb_items.orderByFormula($orderByFormula)
							: ($headerButton->=2)
								This:C1470.lb_items:=This:C1470.lb_items.orderByFormula($orderByFormula; dk descending:K85:32)
						End case 
					End if 
				End if 
		End case 
		
	End if 
	
	
Function _displayHeaderTabFavorite()
	cs:C1710.sfw_favoriteManager.me._displayHeaderTabFavorite()
	
Function _displayHeaderTabSubscription()
	cs:C1710.sfw_subscriptionManager.me._displayHeaderTabSubscription()
	
Function _displayHeaderTabAssignation()
	cs:C1710.sfw_assignationManager.me._displayHeaderTabAssignation()
	
Function _displayHeaderTabComment()
	cs:C1710.sfw_commentManager.me._displayHeaderTabComment()
	
Function _displayHeaderTabEvent()
	cs:C1710.sfw_eventManager.me._displayHeaderTabEvent()
	
	
	
	
	
Function lb_items_manage()
	Case of 
		: (This:C1470.entry.dataclass#Null:C1517)
			This:C1470.lb_items_doEvent()
			
		: (String:C10(This:C1470.entry.virtual)="collection") & (Right click:C712)
			This:C1470.virtual_lb_items_doEvent_rightClick()
			
		: (String:C10(This:C1470.entry.virtual)="collection")
			This:C1470.virtual_lb_items_doEvent()
			
	End case 
	
	
Function _lb_items_highlight($value : Variant)->$result : Text
	
	var $text : Text
	var $search : Text
	var $position : Integer
	
	$text:=String:C10($value)
	$result:=$text
	If (This:C1470.searchHighlightParts#Null:C1517)
		$doReplace:=False:C215
		For each ($valueSearch; This:C1470.searchHighlightParts)
			$search:=$valueSearch
			If ("@"=$search[[1]])
				$search:=Substring:C12($search; 2)
			End if 
			If (Length:C16($search)>0)
				If ("@"=$search[[Length:C16($search)]])
					$search:=Substring:C12($search; 1; Length:C16($search)-1)
				End if 
				If (Length:C16($search)>0)
					If (Position:C15("@"; $search)>0)
						$resultParts:=Split string:C1554($result; " ")
						$newResultParts:=New collection:C1472
						For each ($resultPart; $resultParts)
							If ($resultPart=$search)
								$newResultParts.push((Char:C90(60001)*3)+$resultPart+(Char:C90(60002)*3))
								$doReplace:=True:C214
							Else 
								$newResultParts.push($resultPart)
							End if 
						End for each 
						$result:=$newResultParts.join(" ")
					Else 
						$position:=Position:C15($search; $result)
						If ($position>0)
							$result:=Substring:C12($result; 1; $position-1)+(Char:C90(60001)*3)+Substring:C12($result; $position; Length:C16($search))+(Char:C90(60002)*3)+Substring:C12($result; $position+Length:C16($search))
							$doReplace:=True:C214
						End if 
					End if 
				End if 
			End if 
		End for each 
		If ($doReplace)
			$result:=Replace string:C233($result; (Char:C90(60001)*3); "<SPAN STYLE=\"background-color:aqua\">")
			$result:=Replace string:C233($result; (Char:C90(60002)*3); "</SPAN>")
			
			$result:=Replace string:C233($result; "&"; "&amp;")
		End if 
	End if 
	
	
Function _lb_drawFlagInColumn($codeIso : Text)->$flag : Picture
	var $file : 4D:C1709.File
	var $pict : Picture
	This:C1470.flags:=This:C1470.flags || New object:C1471
	$codeIso:=$codeIso || "_United Nations"
	If (This:C1470.flags[$codeIso]=Null:C1517)
		$file:=Folder:C1567(fk resources folder:K87:11).file("sfw/flags/tiny/"+Uppercase:C13($codeIso)+".png")
		If ($file.exists)
			READ PICTURE FILE:C678($file.platformPath; $flag)
		Else 
			$file:=Folder:C1567(fk resources folder:K87:11).file("sfw/flags/tiny/_United Nations.png")
			If ($file.exists)
				READ PICTURE FILE:C678($file.platformPath; $flag)
			Else 
				$flag:=$pict
			End if 
		End if 
		This:C1470.flags[$codeIso]:=$flag
	Else 
		$flag:=This:C1470.flags[$codeIso]
	End if 
	
Function virtual_lb_items_define()
	
	var $nil : Pointer
	var $table : Pointer
	var $current_panel : Text
	
	$columnFormula:="This.name"
	$columnType:=Is text:K8:3
	LISTBOX INSERT COLUMN FORMULA:C970(*; "lb_items"; 1000; "col_1"; $columnFormula; $columnType; "header_1"; $nil)
	LISTBOX SET PROPERTY:C1440(*; "col_1"; lk multi style:K53:71; lk yes:K53:69)
	OBJECT SET TITLE:C194(*; "header_1"; ds:C1482.sfw_readXliff("healthdashboard.lb_items.hearder1"; "name"))
	
	LISTBOX SET PROPERTY:C1440(*; "lb_items"; lk sortable:K53:45; lk no:K53:68)
	This:C1470.displayDefaultPanel()
	
Function virtual_lb_items_fill()
	var $item : Object
	var $xliff : Text
	
	This:C1470.lb_items:=This:C1470.entry.items.copy()
	
	For each ($item; This:C1470.lb_items)
		$item.name:=ds:C1482.sfw_readXliff($item.xliff; $item.name)
	End for each 
	
Function virtual_lb_items_selChange()
	Form:C1466.subForm.current_item:=Form:C1466.current_item
	If (Form:C1466.current_item#Null:C1517)
		OBJECT GET SUBFORM:C1139(*; "detail_panel"; $table; $current_panel)
		If ($current_panel#Form:C1466.current_item.panel.name) && (Form:C1466.lastPanelDisplayed#Form:C1466.current_item.panel.name)
			OBJECT SET SUBFORM:C1138(*; "detail_panel"; String:C10(Form:C1466.current_item.panel.name))  // String is mandatory to help the compilator
			Form:C1466.lastPanelDisplayed:=String:C10(Form:C1466.current_item.panel.name)
		Else 
			Form:C1466.subForm:=Form:C1466.subForm
		End if 
		
	Else 
		This:C1470.displayDefaultPanel()
	End if 
	
	This:C1470.drawButtons_virtual()
	
Function virtual_lb_items_doEvent()
	
	Case of 
		: (FORM Event:C1606.code=On Clicked:K2:4)
			Form:C1466.previous_current_lb_item_pos:=Form:C1466.current_lb_item_pos
			
		: (FORM Event:C1606.code=On Selection Change:K2:29) & (Bool:C1537(This:C1470.lb_items_dontPlayOnSelectionChange))
			This:C1470.lb_items_dontPlayOnSelectionChange:=False:C215
			
		: (FORM Event:C1606.code=On Selection Change:K2:29)
			Form:C1466.current_item:=Form:C1466.current_lb_item
			This:C1470.virtual_lb_items_selChange()
			
			
	End case 
	
Function virtual_lb_items_doEvent_rightClick()
	
	$refMenu:=Create menu:C408()
	If (Not:C34(Is compiled mode:C492))
		APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("menu.editForm"; "edit form"))
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--editForm")
	End if 
	$choose:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	
	Case of 
		: ($choose="--editForm")
			FORM EDIT:C1749(String:C10(Form:C1466.current_lb_item.panel.name))
	End case 
	
	
Function vSplitter()
	Form:C1466.subForm:=Form:C1466.subForm
	
Function _resizeMainWindow()
	var $windowSize : Object
	var $toolbarHeight:=76
	
	$windowSize:=cs:C1710.sfw_definition.me.globalParameters.mainInterface.window
	If ($windowSize#Null:C1517)
		GET WINDOW RECT:C443($winLeft; $winTop; $winRight; $winBottom)
		$width:=$windowSize.width-($winRight-$winLeft)
		$height:=$windowSize.height-($winBottom-$winTop)
		RESIZE FORM WINDOW:C890($width; $height)
		
		GET WINDOW RECT:C443($winLeft; $winTop; $winRight; $winBottom)
		$winWidth:=$winRight-$winLeft
		$winHeight:=$winBottom-$winTop
		
		If ($windowSize.left#Null:C1517)
			SET WINDOW RECT:C444($windowSize.left; $windowSize.top; $windowSize.left+$winWidth; $windowSize.top+$winHeight)
			
		Else 
			SCREEN COORDINATES:C438($screenLeft; $screenTop; $screenRight; $screenBottom; Screen work area:K27:10)
			
			$screenWidth:=$screenRight-$screenLeft
			$screenHeight:=$screenBottom-$screenTop
			
			$newLeft:=($screenWidth-$winWidth)/2
			$newRight:=$newLeft+$winWidth
			$newTop:=($screenHeight-$winHeight)/2+$toolbarHeight
			$newBottom:=$newTop+$winHeight-$toolbarHeight
			SET WINDOW RECT:C444($newLeft; $newTop; $newRight; $newBottom)
		End if 
	End if 
	
	
	//mark:- PupViews management
Function _displayPupViews()
	OBJECT GET COORDINATES:C663(*; "bkgd_topBar"; $left; $top; $right; $bottom)
	$headerBarHeight:=$bottom-$top
	OBJECT GET COORDINATES:C663(*; "entry_label"; $left; $top; $right; $bottom)
	$entryLabelHeight:=$bottom-$top
	$entry_label:=" "+ds:C1482.sfw_readXliff(Form:C1466.sfw.entry.xliff; Form:C1466.sfw.entry.label)
	If (Form:C1466.projection) && (Form:C1466.filterByProjection)
		$entry_label+=" ("+Form:C1466.projection.label+")"
	End if 
	If (This:C1470.allowedViews.length>1)
		$topLabel:=($headerBarHeight-($entryLabelHeight*2))/3
		OBJECT SET COORDINATES:C1248(*; "entry_label"; $left; $topLabel; $right; $topLabel+$entryLabelHeight)
		
		OBJECT SET FORMAT:C236(*; "pupViews"; " "+This:C1470.view.label+";path:"+This:C1470.view.picto+";")
		OBJECT GET BEST SIZE:C717(*; "pupViews"; $bestWidth; $bestHeight; 350)
		$bestWidth+=5
		OBJECT GET COORDINATES:C663(*; "pupViews"; $left; $top; $right; $bottom)
		OBJECT SET COORDINATES:C1248(*; "pupViews"; $left; $topLabel+$entryLabelHeight+$topLabel; $left+$bestWidth; $topLabel+$entryLabelHeight+$topLabel+$entryLabelHeight)
		
		//If (Form.sfw.entry.allowFavorite)
		//If (Form.filterByFavorite)
		//OBJECT SET FORMAT(*; "entry_label"; $entry_label+";path:/RESOURCES/sfw/image/picto/star.png;;;;;;;;;1;")
		//Else 
		//OBJECT SET FORMAT(*; "entry_label"; $entry_label+";path:/RESOURCES/sfw/image/picto/book-brown.png;;;;;;;;;1;")
		//End if 
		//Else 
		//OBJECT SET FORMAT(*; "entry_label"; $entry_label+";path:/RESOURCES/sfw/image/picto/book-brown.png;;;;;;;;;0;")
		//End if 
		
		$popup:=(Form:C1466.sfw.entry.allowFavorite) || (Form:C1466.projection) ? "1" : "0"
		$picto:="book-white.png"
		Case of 
			: (Form:C1466.sfw.entry.allowFavorite) && (Form:C1466.filterByFavorite)
				$picto:="star.png"
			: (Form:C1466.filterByProjection)
				$picto:="projection.png"
		End case 
		
		OBJECT SET FORMAT:C236(*; "entry_label"; $entry_label+";path:/RESOURCES/sfw/image/picto/"+$picto+";;;;;;;;;"+$popup+";")
		
		
		OBJECT GET BEST SIZE:C717(*; "entry_label"; $bestWidth; $bestHeight; 150)
		$bestWidth+=5
		OBJECT GET COORDINATES:C663(*; "entry_label"; $left; $top; $right; $bottom)
		OBJECT SET COORDINATES:C1248(*; "entry_label"; $left; $top; $left+$bestWidth; $bottom)
		
	Else 
		$topLabel:=($headerBarHeight-$entryLabelHeight)/2
		OBJECT SET COORDINATES:C1248(*; "entry_label"; $left; $topLabel; $right; $topLabel+$entryLabelHeight)
		
		$popup:=(Form:C1466.sfw.entry.allowFavorite) || (Form:C1466.projection) ? "1" : "0"
		$picto:=($popup="1") ? "book-white.png" : ""
		Case of 
			: (Form:C1466.sfw.entry.allowFavorite) && (Form:C1466.filterByFavorite)
				$picto:="star.png"
			: (Form:C1466.filterByProjection)
				$picto:="projection.png"
		End case 
		OBJECT SET FORMAT:C236(*; "entry_label"; $entry_label+";path:/RESOURCES/sfw/image/picto/"+$picto+";;;;;;;;;"+$popup+";")
		
		OBJECT GET BEST SIZE:C717(*; "entry_label"; $bestWidth; $bestHeight; 150)
		OBJECT GET COORDINATES:C663(*; "entry_label"; $left; $top; $right; $bottom)
		OBJECT SET COORDINATES:C1248(*; "entry_label"; $left; $top; $left+$bestWidth; $bottom)
		
	End if 
	
	$availableDisplayWidgets:=Split string:C1554("lb_items;hl_items"; ";")
	Case of 
		: (This:C1470.view.displayType="listbox")
			$target:="lb_items"
		: (This:C1470.view.displayType="hierarchical")
			$target:="hl_items"
		: (This:C1470.view.displayType="hierarchicalEntries")
			$target:="hl_items"
		: (This:C1470.view.displayType="recursiveList")
			$target:="hl_items"
		Else 
			$target:="lb_items"
	End case 
	OBJECT SET VISIBLE:C603(*; $target; True:C214)
	For each ($displayWidget; $availableDisplayWidgets)
		If ($displayWidget#$target)
			OBJECT SET VISIBLE:C603(*; $displayWidget; False:C215)
		End if 
	End for each 
	
Function clicPupViews()
	var $view : cs:C1710.sfw_definitionView
	
	$refMenu:=Create menu:C408
	For each ($view; This:C1470.allowedViews)
		
		APPEND MENU ITEM:C411($refMenu; $view.label)
		If (This:C1470.view.ident=$view.ident)
			SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
		End if 
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "view:"+$view.ident)
		SET MENU ITEM ICON:C984($refMenu; -1; "path:"+$view.picto)
	End for each 
	
	$choice:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	
	Case of 
		: ($choice="")
		: ($choice="view:@")
			$ident:=Substring:C12($choice; 6)
			This:C1470.view:=This:C1470.allowedViews.query("ident = :1"; $ident).first()
			This:C1470._displayPupViews()
			This:C1470.lb_items_define()
			This:C1470.lb_items_search()
			
			cs:C1710.sfw_window.me.setWindowTitle()
	End case 
	
	
	
Function clicEntryLabel()
	If (Form:C1466.sfw.entry.allowFavorite) || (Form:C1466.projection#Null:C1517)
		
		$refMenu:=Create menu:C408
		APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("entry.noResctriction"; "No restriction"); *)
		If (Form:C1466.filterByFavorite=False:C215) && (Form:C1466.filterByProjection=False:C215)
			SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
		End if 
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--norestriction")
		SET MENU ITEM ICON:C984($refMenu; -1; "path:/RESOURCES/sfw/image/picto/book-brown.png")
		
		If (Form:C1466.sfw.entry.allowFavorite)
			APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("entry.onlyFavorites"; "Only my favorites"); *)
			If (Form:C1466.filterByFavorite)
				SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
			End if 
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--only")
			SET MENU ITEM ICON:C984($refMenu; -1; "path:/RESOURCES/sfw/image/picto/star.png")
		End if 
		
		If (Form:C1466.projection#Null:C1517)
			APPEND MENU ITEM:C411($refMenu; Form:C1466.sfw.entry.label+" ("+Form:C1466.projection.label+")"; *)
			If (Form:C1466.filterByProjection)
				SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
			End if 
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--projection")
			SET MENU ITEM ICON:C984($refMenu; -1; "path:/RESOURCES/sfw/image/picto/projection.png")
		End if 
		$choice:=Dynamic pop up menu:C1006($refMenu)
		RELEASE MENU:C978($refMenu)
		
		Case of 
			: ($choice="--norestriction")
				Form:C1466.filterByFavorite:=False:C215
				Form:C1466.filterByProjection:=False:C215
				Form:C1466.sfw.lb_items_search()
				This:C1470._displayPupViews()
				
			: ($choice="--only")
				Form:C1466.filterByFavorite:=True:C214
				Form:C1466.filterByProjection:=False:C215
				Form:C1466.sfw.lb_items_search()
				This:C1470._displayPupViews()
				
			: ($choice="--projection")
				Form:C1466.filterByFavorite:=False:C215
				Form:C1466.filterByProjection:=True:C214
				Form:C1466.sfw.lb_items_search()
				This:C1470._displayPupViews()
				
		End case 
		
	End if 
	
	//Mark:- Hierarchical list
	
Function clearHierarchicalList()
	If (Form:C1466.sfw#Null:C1517) && (Form:C1466.sfw.hl_items#Null:C1517)
		If (Is a list:C621(Form:C1466.sfw.hl_items))
			CLEAR LIST:C377(Form:C1466.sfw.hl_items; *)
		End if 
	End if 
	
Function _drawHierarchicalList()
	
	This:C1470.clearHierarchicalList()
	Form:C1466.sfw.hl_items:=New list:C375
	This:C1470.lastRefItemInList:=0
	$firstLevel:=This:C1470.view.HLItems.firstLevelGroupBy.attribute
	$lineLevel:=This:C1470.view.HLItems.line.attribute
	$firstLevelValues:=This:C1470.lb_items.distinct($firstLevel)
	
	For each ($firstLevelValue; $firstLevelValues)
		$items:=This:C1470.lb_items.query($firstLevel+" = :1"; $firstLevelValue)
		If ($items.length>0)
			$subList:=New list:C375
			For each ($item; $items)
				This:C1470.lastRefItemInList+=1
				APPEND TO LIST:C376($subList; $item[$lineLevel]; This:C1470.lastRefItemInList)
				SET LIST ITEM PARAMETER:C986($subList; This:C1470.lastRefItemInList; "UUID"; $item.UUID)
			End for each 
		Else 
			$subList:=0
		End if 
		This:C1470.lastRefItemInList+=1
		APPEND TO LIST:C376(Form:C1466.sfw.hl_items; $firstLevelValue; This:C1470.lastRefItemInList; $subList; True:C214)
		SET LIST ITEM PROPERTIES:C386(Form:C1466.sfw.hl_items; This:C1470.lastRefItemInList; False:C215; Bold:K14:2)
	End for each 
	
	
Function hl_items_manage()
	
	var $uuid : Text
	
	Case of 
		: (FORM Event:C1606.code=On Selection Change:K2:29)
			
			GET LIST ITEM PARAMETER:C985(Form:C1466.sfw.hl_items; *; "UUID"; $uuid)
			Form:C1466.current_item:=ds:C1482[This:C1470.entry.dataclass].get($uuid)
			This:C1470.lb_items_selectionChange()
			
	End case 
	
	//Mark:- Hierarchical entries
	
Function clearHierarchicalEntries()
	If (Form:C1466.sfw#Null:C1517) && (Form:C1466.sfw.hl_items#Null:C1517)
		If (Is a list:C621(Form:C1466.sfw.hl_items))
			CLEAR LIST:C377(Form:C1466.sfw.hl_items; *)
		End if 
	End if 
	
Function _drawHierarchicalEntries
	
	This:C1470.clearHierarchicalEntries()
	Form:C1466.sfw.hl_items:=New list:C375
	This:C1470.lastRefItemInList:=0
	If (Form:C1466.sfw.view.HLEntries#Null:C1517)
		
		This:C1470.HLEntries:=This:C1470.HLEntries || New object:C1471
		This:C1470.HLEntries.currentLevelInDrawing:=-1
		This:C1470.HLEntries.lastCount:=0
		Form:C1466.sfw.hl_items:=This:C1470._drawHierarchicalEntriesLevel()
	End if 
	
Function _drawHierarchicalEntriesLevel($parentItem : 4D:C1709.Entity)->$list : Integer
	
	
	This:C1470.HLEntries.currentLevelInDrawing+=1
	$hierarchicalLevels:=Form:C1466.sfw.view.HLEntries.levels
	$hierarchicalLevel:=$hierarchicalLevels[This:C1470.HLEntries.currentLevelInDrawing]
	$entryIdent:=$hierarchicalLevel.entryIdent
	$entryOfTheLevel:=cs:C1710.sfw_definition.me.getEntryByIdent($entryIdent)
	$dataclassOfTheLevel:=$entryOfTheLevel.dataclass
	$mainAttributeOfTheLevel:=$hierarchicalLevel.attributeTodisplay
	
	If (Count parameters:C259=0)
		$items:=ds:C1482[$dataclassOfTheLevel].all()
	Else 
		$items:=$parentItem[$hierarchicalLevel.linkToFollow]
	End if 
	
	If ($items.length=0)
		$list:=0
	Else 
		$list:=New list:C375
		If ($hierarchicalLevel.orderBy#Null:C1517)
			$items:=$items.orderBy($hierarchicalLevel.orderBy)
		End if 
		For each ($item; $items)
			If ((This:C1470.HLEntries.currentLevelInDrawing+1)<$hierarchicalLevels.length)
				$sublist:=This:C1470._drawHierarchicalEntriesLevel($item)
			Else 
				$subList:=0
			End if 
			$label:=$item[$mainAttributeOfTheLevel]
			$displayItem:=True:C214
			Case of 
				: ((This:C1470.HLEntries.currentLevelInDrawing+1)=$hierarchicalLevels.length)
				: ($subList#0)
				: ($subList=0) && (Not:C34(Bool:C1537($hierarchicalLevel.displayOnlyIfChildren)))
				Else 
					$displayItem:=False:C215
			End case 
			//
			If ($displayItem)
				This:C1470.lastRefItemInList+=1
				APPEND TO LIST:C376($list; $label; This:C1470.lastRefItemInList; $subList; Bool:C1537($hierarchicalLevel.collapsed))
				SET LIST ITEM PARAMETER:C986($list; This:C1470.lastRefItemInList; "UUID"; $item.getKey())
				If ($hierarchicalLevel.displayCount)
					SET LIST ITEM PARAMETER:C986($list; This:C1470.lastRefItemInList; Additional text:K28:7; String:C10(This:C1470.HLEntries.lastCount))
				End if 
				SET LIST ITEM PROPERTIES:C386($list; This:C1470.lastRefItemInList; False:C215; $hierarchicalLevel.style; ""; $hierarchicalLevel.color)
			End if 
		End for each 
	End if 
	This:C1470.HLEntries.lastCount:=$items.length
	This:C1470.HLEntries.currentLevelInDrawing-=1
	
	//mark:-RecursiveList
	
Function _drawRecursiveList()
	
	//This.view.RLDefinition
	This:C1470.rl_itemUUIDs:=This:C1470.lb_items.extract("UUID")
	If (This:C1470.searchbox#"")
		$UUIDs:=This:C1470.rl_itemUUIDs.copy()
		For each ($uuid; This:C1470.rl_itemUUIDs)
			$e:=ds:C1482[This:C1470.entry.dataclass].get($uuid)
			While ($e[This:C1470.view.RLDefinition.recursiveAttribute]#Null:C1517)
				$e:=$e[This:C1470.view.RLDefinition.recursiveAttribute]
				$UUIDs.push($e.getKey())
			End while 
		End for each 
		This:C1470.lb_items:=ds:C1482[This:C1470.entry.dataclass].query("UUID in :1"; $UUIDs)
	End if 
	This:C1470.clearHierarchicalEntries()
	This:C1470.lastRefItemInList:=0
	This:C1470.currentItemRef:=0
	Form:C1466.sfw.hl_items:=This:C1470._drawRecursiveListItem()
	If (Form:C1466.current_item#Null:C1517) && (This:C1470.currentItemRef#0)
		SELECT LIST ITEMS BY REFERENCE:C630(Form:C1466.sfw.hl_items; This:C1470.currentItemRef)
	End if 
	
Function _drawRecursiveListItem($parent_UUID : Text)->$refList : Integer
	
	If (Count parameters:C259=0)
		$queryString:=This:C1470.view.RLDefinition.recursiveAttribute+"= null order by "+This:C1470.view.RLDefinition.nameAttribute
		$es:=This:C1470.lb_items.query($queryString)
	Else 
		$queryString:=This:C1470.view.RLDefinition.recursiveAttribute+".UUID = :1 order by "+This:C1470.view.RLDefinition.nameAttribute
		$es:=This:C1470.lb_items.query($queryString; $parent_UUID)
	End if 
	
	If ($es.length=0)
		$refList:=0
	Else 
		$refList:=New list:C375
		For each ($e; $es)
			$key:=$e.getKey()
			$subList:=This:C1470._drawRecursiveListItem($key)
			$label:=$e[This:C1470.view.RLDefinition.nameAttribute]
			This:C1470.lastRefItemInList+=1
			If ($subList=0)
				APPEND TO LIST:C376($refList; $label; This:C1470.lastRefItemInList)
			Else 
				APPEND TO LIST:C376($refList; $label; This:C1470.lastRefItemInList; $subList; True:C214)
			End if 
			SET LIST ITEM PARAMETER:C986($refList; This:C1470.lastRefItemInList; "UUID"; $key)
			If (This:C1470.rl_itemUUIDs.indexOf($key)=-1)
				SET LIST ITEM PROPERTIES:C386($refList; This:C1470.lastRefItemInList; False:C215; Plain:K14:1; 0; 0x0CACAACA)
			End if 
			If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.UUID=$key)
				This:C1470.currentItemRef:=This:C1470.lastRefItemInList
			End if 
		End for each 
	End if 
	
	
	//mark:-Filters
	
Function displayFilter()
	var $filter : cs:C1710.sfw_definitionFilter
	If (This:C1470.entry.filters#Null:C1517)
		Form:C1466.filters:=This:C1470.entry.filters.copy()
	End if 
	
	If (Form:C1466.filters#Null:C1517)
		$verticalGap:=5
		If (Form:C1466.filters.length<4)
			OBJECT GET COORDINATES:C663(*; "pupFilter_1"; $gpf; $hpf; $dpf; $bpf)
		Else 
			OBJECT GET COORDINATES:C663(*; "pupFilter_4"; $gpf; $hpf; $dpf; $bpf)
		End if 
		OBJECT GET COORDINATES:C663(*; "lb_items"; $glb; $hlb; $dlb; $blb)
		OBJECT SET COORDINATES:C1248(*; "lb_items"; $glb; $bpf+$verticalGap; $dlb; $blb)
		OBJECT GET COORDINATES:C663(*; "hl_items"; $ghl; $hhl; $dhl; $bhl)
		OBJECT SET COORDINATES:C1248(*; "hl_items"; $ghl; $bpf+$verticalGap; $dhl; $bhl)
		$i:=0
		For each ($filter; This:C1470.entry.filters)
			$i+=1
			$objectName:="pupFilter_"+String:C10($i)
			OBJECT SET VISIBLE:C603(*; $objectName; True:C214)
			OBJECT SET TITLE:C194(*; $objectName; $filter.defaultTitle)
			OBJECT SET FONT STYLE:C166(*; $objectName; Plain:K14:1)
			OBJECT SET RGB COLORS:C628(*; $objectName; "grey")
		End for each 
	End if 
	
	
Function pupFilterClic()
	var $filter : cs:C1710.sfw_definitionFilter
	var $entity : 4D:C1709.Entity
	var $labelForItem : Text
	
	$objectName:=FORM Event:C1606.objectName
	$numFilter:=Num:C11(Substring:C12($objectName; 11))-1
	$filter:=Form:C1466.filters[$numFilter]
	Case of 
		: ($filter.filterByLinkedEntity)
			$refMenu:=Create menu:C408
			
			APPEND MENU ITEM:C411($refMenu; $filter.defaultTitle; *)
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "all")
			If ($filter.UUIDs=Null:C1517)
				SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
			End if 
			APPEND MENU ITEM:C411($refMenu; "-")
			
			$orderForItems:=$filter.orderForItems || "name"
			
			If ($filter.linkToFollowIfShift#Null:C1517) && (Shift down:C543)
				$pathParts:=Split string:C1554($filter.linkToFollowIfShift; ".")
				$sourceEntities:=This:C1470.lb_items
				For each ($pathPart; $pathParts)
					$sourceEntities:=$sourceEntities[$pathPart]
				End for each 
				$sourceEntities:=$sourceEntities.orderBy($orderForItems)
			Else 
				$sourceEntities:=ds:C1482[$filter.linkedDataclassName].all().orderBy($orderForItems)
			End if 
			
			If ($filter.displayCount#Null:C1517)
				$pathParts:=Split string:C1554($filter.displayCount; ".")
				$lastAttribute:=$pathParts.pop()
				$source:=This:C1470.lb_items
				For each ($part; $pathParts)
					$source:=$source[$part]
				End for each 
				$counts:=$source.distinct($lastAttribute; ck count values:K85:37)
			End if 
			
			For each ($entity; $sourceEntities)
				$uuid:=$entity["UUID"]  //.getKey(dk key as string)
				//$mark:=($filter.UUIDs#Null) && ($filter.UUIDs.indexOf($uuid)#-1)
				$labelForItem:=$filter.labelForItem || "name"
				$label:=$entity[$labelForItem]
				If ($filter.displayCount#Null:C1517)
					$indices:=$counts.indices("value = :1"; $uuid)
					If ($indices.length#0)
						$label+=" ["+String:C10($counts[$indices[0]].count)+"]"
					End if 
				End if 
				APPEND MENU ITEM:C411($refMenu; $label; *)
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "UUID:"+$uuid)
				If ($filter.UUIDs#Null:C1517) && ($filter.UUIDs.indexOf($uuid)#-1)
					SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
					SET MENU ITEM STYLE:C425($refMenu; -1; Bold:K14:2)
				End if 
				If ($entity.color#Null:C1517)
					$color:=cs:C1710.sfw_htmlColor.me.getName($entity.color)
					SET MENU ITEM ICON:C984($refMenu; -1; "path:/RESOURCES/sfw/colors/"+$color+".png")
				End if 
				
			End for each 
			
			$choice:=Dynamic pop up menu:C1006($refMenu)
			RELEASE MENU:C978($refMenu)
			
			For ($passe; 1; 2)
				Case of 
					: ($choice="all") & (Macintosh option down:C545 || Windows Alt down:C563)
						$choice:="UUID:all"
						continue
						
					: ($choice="all")
						If ($filter.queryString#Null:C1517)
							OB REMOVE:C1226($filter; "queryString")
							OB REMOVE:C1226($filter; "queryParameters")
							OB REMOVE:C1226($filter; "UUIDs")
						End if 
						OBJECT SET TITLE:C194(*; $objectName; $filter.defaultTitle)
						OBJECT SET FONT STYLE:C166(*; $objectName; Plain:K14:1)
						OBJECT SET RGB COLORS:C628(*; $objectName; "grey")
						Form:C1466.sfw.lb_items_search()
						break
						
					: ($choice="UUID:@")
						If ($choice="UUID:all")
							$filter.UUIDs:=$sourceEntities.UUID
						Else 
							$uuid:=Substring:C12($choice; 6)
							$filter.UUIDs:=$filter.UUIDs || New collection:C1472
							$index:=$filter.UUIDs.indexOf($uuid)
							If ($index#-1)
								$filter.UUIDs.remove($index)
							Else 
								$filter.UUIDs.push($uuid)
							End if 
						End if 
						If ($filter.UUIDs.length=0)
							$choice:="all"
							continue
						Else 
							$filter.queryString:=$filter.attributeForLink+" in :"+$filter.placeholderForLink
							$filter.queryParameters:=$filter.queryParameters || New object:C1471
							$filter.queryParameters[$filter.placeholderForLink]:=$filter.UUIDs
							If ($filter.UUIDs.length=1)
								$entity:=ds:C1482[$filter.linkedDataclassName].get($filter.UUIDs[0])
								$attributeForSingleTitle:=$filter.attributeForSingleTitle || "name"
								OBJECT SET TITLE:C194(*; $objectName; $entity[$attributeForSingleTitle])
							Else 
								If ($filter.formatForMutipleTitles#Null:C1517)
									OBJECT SET TITLE:C194(*; $objectName; String:C10($filter.UUIDs.length; $filter.formatForMutipleTitles))
								Else 
									OBJECT SET TITLE:C194(*; $objectName; String:C10($filter.UUIDs.length)+" items")
								End if 
							End if 
							OBJECT SET FONT STYLE:C166(*; $objectName; Bold:K14:2)
							OBJECT SET RGB COLORS:C628(*; $objectName; "red")
							Form:C1466.sfw.lb_items_search()
							break
						End if 
				End case 
			End for 
			
			
		: ($filter.filterByIDInTable)
			$refMenu:=Create menu:C408
			
			APPEND MENU ITEM:C411($refMenu; $filter.defaultTitle; *)
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "all")
			If ($filter.IDS=Null:C1517)
				SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
			End if 
			APPEND MENU ITEM:C411($refMenu; "-")
			
			$orderForItems:=$filter.orderForItems || "name"
			
			If (Shift down:C543)
				$ids:=This:C1470.lb_items.distinct($filter.attributeForLink)
				$sourceEntities:=ds:C1482[$filter.linkedDataclassName].query($filter.attributeID+" in :1 order by "+$orderForItems; $ids)
			Else 
				$sourceEntities:=ds:C1482[$filter.linkedDataclassName].all().orderBy($orderForItems)
			End if 
			If ($filter.displayCount#Null:C1517)
				$pathParts:=Split string:C1554($filter.displayCount; ".")
				$lastAttribute:=$pathParts.pop()
				$source:=This:C1470.lb_items
				For each ($part; $pathParts)
					$source:=$source[$part]
				End for each 
				$counts:=$source.distinct($lastAttribute; ck count values:K85:37)
			End if 
			For each ($entity; $sourceEntities)
				$id:=$entity[$filter.attributeID]
				$labelForItem:=$filter.labelForItem || "name"
				$label:=$entity[$labelForItem]
				If ($filter.displayCount#Null:C1517)
					$indices:=$counts.indices("value = :1"; $id)
					If ($indices.length#0)
						$label+=" ["+String:C10($counts[$indices[0]].count)+"]"
					End if 
				End if 
				APPEND MENU ITEM:C411($refMenu; $label; *)
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "ID:"+String:C10($id))
				If ($filter.IDS#Null:C1517) && ($filter.IDS.indexOf($id)#-1)
					SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
				End if 
				If ($entity.color#Null:C1517)
					$color:=cs:C1710.sfw_htmlColor.me.getName($entity.color)
					SET MENU ITEM ICON:C984($refMenu; -1; "path:/RESOURCES/sfw/colors/"+$color+".png")
				End if 
			End for each 
			
			$choice:=Dynamic pop up menu:C1006($refMenu)
			RELEASE MENU:C978($refMenu)
			
			For ($passe; 1; 2)
				Case of 
					: ($choice="all") & (Macintosh option down:C545 || Windows Alt down:C563)
						$choice:="ID:all"
						continue
						
					: ($choice="all")
						If ($filter.queryString#Null:C1517)
							OB REMOVE:C1226($filter; "queryString")
							OB REMOVE:C1226($filter; "queryParameters")
							OB REMOVE:C1226($filter; "IDS")
						End if 
						OBJECT SET TITLE:C194(*; $objectName; $filter.defaultTitle)
						OBJECT SET FONT STYLE:C166(*; $objectName; Plain:K14:1)
						OBJECT SET RGB COLORS:C628(*; $objectName; "grey")
						Form:C1466.sfw.lb_items_search()
						break
						
					: ($choice="ID:@")
						If ($choice="ID:all")
							$filter.IDS:=$sourceEntities[$filter.attributeID]
						Else 
							$id:=Num:C11(Substring:C12($choice; 4))
							$filter.IDS:=$filter.IDS || New collection:C1472
							$index:=$filter.IDS.indexOf($id)
							If ($index#-1)
								$filter.IDS.remove($index)
							Else 
								$filter.IDS.push($id)
							End if 
						End if 
						If ($filter.IDS.length=0)
							$choice:="all"
							continue
						Else 
							$filter.queryString:=$filter.attributeForLink+" in :"+$filter.placeholderForLink
							$filter.queryParameters:=$filter.queryParameters || New object:C1471
							$filter.queryParameters[$filter.placeholderForLink]:=$filter.IDS
							If ($filter.IDS.length=1)
								$entity:=ds:C1482[$filter.linkedDataclassName].query($filter.attributeID+" = :1"; $filter.IDS[0]).first()
								$attributeForSingleTitle:=$filter.attributeForSingleTitle || "name"
								OBJECT SET TITLE:C194(*; $objectName; $entity[$attributeForSingleTitle])
							Else 
								If ($filter.formatForMutipleTitles#Null:C1517)
									OBJECT SET TITLE:C194(*; $objectName; String:C10($filter.IDS.length; $filter.formatForMutipleTitles))
								Else 
									OBJECT SET TITLE:C194(*; $objectName; String:C10($filter.IDS.length)+" items")
								End if 
							End if 
							OBJECT SET FONT STYLE:C166(*; $objectName; Bold:K14:2)
							OBJECT SET RGB COLORS:C628(*; $objectName; "red")
							Form:C1466.sfw.lb_items_search()
							break
						End if 
				End case 
			End for 
			
		: ($filter.filterByManyToManyEntity)
			$refMenu:=Create menu:C408
			
			APPEND MENU ITEM:C411($refMenu; $filter.defaultTitle; *)
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "all")
			If ($filter.UUIDs=Null:C1517)
				SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
			End if 
			APPEND MENU ITEM:C411($refMenu; "-")
			
			$orderForItems:=$filter.orderForItems || "name"
			
			If (Shift down:C543) || ($filter.notOrphans)
				$pathParts:=Split string:C1554($filter.pathManyToMany; ".")
				$source:=This:C1470.lb_items
				For each ($part; $pathParts)
					$source:=$source[$part]
				End for each 
				$UUIDs:=$source.distinct("UUID")
				$sourceEntities:=ds:C1482[$filter.finalDataclassName].query("UUID in :1 order by "+$orderForItems; $UUIDs)
			Else 
				$sourceEntities:=ds:C1482[$filter.finalDataclassName].all().orderBy($orderForItems)
			End if 
			
			If ($filter.displayCount#Null:C1517)
				$pathParts:=Split string:C1554($filter.displayCount; ".")
				$lastAttribute:=$pathParts.pop()
				$source:=This:C1470.lb_items
				For each ($part; $pathParts)
					$source:=$source[$part]
				End for each 
				$counts:=$source.distinct($lastAttribute; ck count values:K85:37)
			End if 
			
			For each ($entity; $sourceEntities)
				$labelForItem:=$filter.labelForItem || "name"
				$label:=$entity[$labelForItem]
				If ($filter.displayCount#Null:C1517)
					$indices:=$counts.indices("value = :1"; $entity.getKey())
					If ($indices.length#0)
						$label+=" ["+String:C10($counts[$indices[0]].count)+"]"
					End if 
				End if 
				APPEND MENU ITEM:C411($refMenu; $label; *)
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "UUID:"+String:C10($entity.getKey()))
				If ($filter.UUIDs#Null:C1517) && ($filter.UUIDs.indexOf($entity.UUID)#-1)
					SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
				End if 
				If ($entity.color#Null:C1517)
					$color:=cs:C1710.sfw_htmlColor.me.getName($entity.color)
					SET MENU ITEM ICON:C984($refMenu; -1; "path:/RESOURCES/sfw/colors/"+$color+".png")
				End if 
			End for each 
			
			$choice:=Dynamic pop up menu:C1006($refMenu)
			RELEASE MENU:C978($refMenu)
			
			For ($passe; 1; 2)
				Case of 
					: ($choice="all") & (Macintosh option down:C545 || Windows Alt down:C563)
						$choice:="UUID:all"
						continue
						
					: ($choice="all")
						If ($filter.queryString#Null:C1517)
							OB REMOVE:C1226($filter; "queryString")
							OB REMOVE:C1226($filter; "queryParameters")
							OB REMOVE:C1226($filter; "UUIDs")
						End if 
						OBJECT SET TITLE:C194(*; $objectName; $filter.defaultTitle)
						OBJECT SET FONT STYLE:C166(*; $objectName; Plain:K14:1)
						OBJECT SET RGB COLORS:C628(*; $objectName; "grey")
						Form:C1466.sfw.lb_items_search()
						break
						
					: ($choice="UUID:@")
						If ($choice="UUID:all")
							$filter.UUIDs:=$sourceEntities.UUID
						Else 
							$uuid:=Substring:C12($choice; 6)
							$filter.UUIDs:=$filter.UUIDs || New collection:C1472
							$index:=$filter.UUIDs.indexOf($uuid)
							If ($index#-1)
								$filter.UUIDs.remove($index)
							Else 
								$filter.UUIDs.push($uuid)
							End if 
						End if 
						If ($filter.UUIDs.length=0)
							$choice:="all"
							continue
						Else 
							$filter.queryString:=$filter.pathManyToMany+".UUID in :UUIDs"
							$filter.queryParameters:=$filter.queryParameters || New object:C1471
							$filter.queryParameters.UUIDs:=$filter.UUIDs
							If ($filter.UUIDs.length=1)
								$entity:=ds:C1482[$filter.finalDataclassName].get($filter.UUIDs[0])
								$attributeForSingleTitle:=$filter.attributeForSingleTitle || "name"
								OBJECT SET TITLE:C194(*; $objectName; $entity[$attributeForSingleTitle])
							Else 
								If ($filter.formatForMutipleTitles#Null:C1517)
									OBJECT SET TITLE:C194(*; $objectName; String:C10($filter.UUIDs.length; $filter.formatForMutipleTitles))
								Else 
									OBJECT SET TITLE:C194(*; $objectName; String:C10($filter.UUIDs.length)+" items")
								End if 
							End if 
							OBJECT SET FONT STYLE:C166(*; $objectName; Bold:K14:2)
							OBJECT SET RGB COLORS:C628(*; $objectName; "red")
							Form:C1466.sfw.lb_items_search()
							break
						End if 
				End case 
			End for 
			
			
		: ($filter.filterByBooleanExpression)
			$refMenu:=Create menu:C408
			
			APPEND MENU ITEM:C411($refMenu; $filter.defaultTitle; *)
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "all")
			If ($filter.selectedBooleanValue=Null:C1517)
				SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
			End if 
			APPEND MENU ITEM:C411($refMenu; "-")
			APPEND MENU ITEM:C411($refMenu; $filter.labelForTrue; *)
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "true")
			If ($filter.selectedBooleanValue=True:C214)
				SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
			End if 
			APPEND MENU ITEM:C411($refMenu; $filter.labelForFalse; *)
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "false")
			If ($filter.selectedBooleanValue=False:C215)
				SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
			End if 
			
			$choice:=Dynamic pop up menu:C1006($refMenu)
			RELEASE MENU:C978($refMenu)
			
			Case of 
				: ($choice="all")
					OB REMOVE:C1226($filter; "selectedBooleanValue")
					OB REMOVE:C1226($filter; "queryString")
					OB REMOVE:C1226($filter; "queryParameters")
					OBJECT SET TITLE:C194(*; $objectName; $filter.defaultTitle)
					OBJECT SET FONT STYLE:C166(*; $objectName; Plain:K14:1)
					OBJECT SET RGB COLORS:C628(*; $objectName; "grey")
					Form:C1466.sfw.lb_items_search()
				: ($choice="true")
					$filter.selectedBooleanValue:=True:C214
					$filter.queryString:=Replace string:C233($filter.expression; ":1"; ":selectedBooleanValue")
					$filter.queryParameters:=$filter.queryParameters || New object:C1471
					$filter.queryParameters.selectedBooleanValue:=$filter.selectedBooleanValue
					OBJECT SET TITLE:C194(*; $objectName; $filter.labelForTrue)
					OBJECT SET FONT STYLE:C166(*; $objectName; Bold:K14:2)
					OBJECT SET RGB COLORS:C628(*; $objectName; "red")
					Form:C1466.sfw.lb_items_search()
				: ($choice="false")
					$filter.selectedBooleanValue:=False:C215
					$filter.queryString:=Replace string:C233($filter.expression; ":1"; ":selectedBooleanValue")
					$filter.queryParameters:=$filter.queryParameters || New object:C1471
					$filter.queryParameters.selectedBooleanValue:=$filter.selectedBooleanValue
					OBJECT SET TITLE:C194(*; $objectName; $filter.labelForFalse)
					OBJECT SET FONT STYLE:C166(*; $objectName; Bold:K14:2)
					OBJECT SET RGB COLORS:C628(*; $objectName; "red")
					Form:C1466.sfw.lb_items_search()
			End case 
			
			
	End case 
	
	
Function _applyFilters()
	$queryParts:=New collection:C1472
	$parameters:=New object:C1471
	
	If (Form:C1466.filters#Null:C1517)
		For each ($filter; Form:C1466.filters)
			If ($filter.queryString#Null:C1517)
				$queryParts.push($filter.queryString)
				For each ($placeholder; $filter.queryParameters)
					$parameters[$placeholder]:=$filter.queryParameters[$placeholder]
				End for each 
			End if 
		End for each 
	End if 
	If (Form:C1466.filterByFavorite)
		$queryParts.push("UUID in :favoriteUUIDs")
		$parameters.favoriteUUIDs:=cs:C1710.sfw_favoriteManager.me.getUUIDs()
	End if 
	If (Form:C1466.filterByProjection)
		Form:C1466.projection.UUIDs:=Form:C1466.projection.UUIDs || Form:C1466.projection.entitiesSelection.UUID
		$queryParts.push("UUID in :projectionUUIDs")
		$parameters.projectionUUIDs:=Form:C1466.projection.UUIDs
	End if 
	If ($queryParts.length>0)
		$queryString:=$queryParts.join(" and ")
		$querySettings:=New object:C1471("parameters"; $parameters)
		This:C1470.lb_items:=This:C1470.lb_items.query($queryString; $querySettings)
	End if 
	
	
	//Mark:-Search
	
	
Function searchBox($option : Integer)
	var $bestwidth; $bestheight : Integer
	
	OBJECT GET COORDINATES:C663(*; "searchbox_roundRectangle"; $groundRectangle; $hroundRectangle; $droundRectangle; $broundRectangle)
	OBJECT GET COORDINATES:C663(*; "searchbox_cross"; $gcross; $hcross; $dcross; $bcross)
	OBJECT GET COORDINATES:C663(*; "searchbox_variable"; $gvariable; $hvariable; $dvariable; $bvariable)
	OBJECT GET COORDINATES:C663(*; "vSplitter"; $gvSplitter; $hvSplitter; $dvSplitter; $bvSplitter)
	
	$textForCalculation:=Get edited text:C655
	
	Case of 
		: (FORM Event:C1606.code=On Data Change:K2:15) || (Count parameters:C259>0)
			Form:C1466.sfw.lb_items_search()
			
		: (FORM Event:C1606.code=On Getting Focus:K2:7)
			OBJECT SET BORDER STYLE:C1262(*; "searchbox_roundRectangle"; Border Plain:K42:28)
			$focusRingColor:="#60A9EF"
			If (Form:C1466.sfw.vision.toolbar.focusRing#Null:C1517)
				$focusRingColor:=String:C10(Form:C1466.sfw.vision.toolbar.focusRing)
			End if 
			OBJECT SET RGB COLORS:C628(*; "searchbox_roundRectangle"; $focusRingColor; "white")
			Form:C1466.searchInfullsize:=True:C214
			
			
		: (FORM Event:C1606.code=On Losing Focus:K2:8)
			OBJECT SET BORDER STYLE:C1262(*; "searchbox_roundRectangle"; Border None:K42:27)
			Form:C1466.searchInfullsize:=False:C215
			
		: (FORM Event:C1606.code=On After Edit:K2:43)
			$keystroke:=Keystroke:C390
			Case of 
				: ($keystroke="?") & (Form:C1466.sfw.entry.searchbox.specificSearches#Null:C1517)
					$g:=$gvariable
					$h:=$bvariable
					CONVERT COORDINATES:C1365($g; $h; XY Current form:K27:5; XY Screen:K27:7)
					$formData:=New object:C1471
					$formData.lb_tags:=Form:C1466.sfw.entry.searchbox.specificSearches.extract("tag"; "tag").orderBy("tag")
					$formData.tag:=""
					$refWindow:=Open form window:C675("sfw_searchHelper"; Pop up form window:K39:11; $g; $h)
					DIALOG:C40("sfw_searchHelper"; $formData)
					CLOSE WINDOW:C154($refWindow)
					GET HIGHLIGHT:C209(*; "searchbox_variable"; $startSel; $endSel)
					$search:=Get edited text:C655
					If (ok=1)
						$tag:=$formData.tag.tag
						Form:C1466.sfw.searchbox:=Substring:C12($search; 1; $startSel-1)+$tag+Substring:C12($search; $endSel)
						HIGHLIGHT TEXT:C210(*; "searchbox_variable"; $startSel+Length:C16($tag); $endSel+Length:C16($tag))
						Form:C1466.searchInfullsize:=True:C214
						$textForCalculation:=Form:C1466.sfw.searchbox
					Else 
						Form:C1466.sfw.searchbox:=Substring:C12($search; 1; $startSel-2)+Substring:C12($search; $endSel)
						HIGHLIGHT TEXT:C210(*; "searchbox_variable"; $startSel-1; $endSel-1)
					End if 
					
				: ($keystroke="?")
					BEEP:C151
					$search:=Get edited text:C655
					GET HIGHLIGHT:C209(*; "searchbox_variable"; $startSel; $endSel)
					Form:C1466.sfw.searchbox:=Substring:C12($search; 1; $startSel-2)+Substring:C12($search; $endSel)
					HIGHLIGHT TEXT:C210(*; "searchbox_variable"; $startSel-1; $endSel-1)
					
			End case 
			
	End case 
	
	If (Bool:C1537(Form:C1466.searchInfullsize))
		$variableDefaultSize:=142
		GET WINDOW RECT:C443($gwindow; $hwindow; $dwindow; $bwindow; Current form window:C827)
		$widthMax:=$dwindow-$gwindow-$gvariable-35
		OBJECT SET TITLE:C194(*; "TextWidthCalculator"; $textForCalculation)
		OBJECT GET BEST SIZE:C717(*; "TextWidthCalculator"; $bestwidth; $bestheight; 1000)
		$bestwidthplus30pc:=$bestwidth*1.15
		Case of 
			: ($bestwidthplus30pc<$variableDefaultSize)
				$right:=$gvSplitter-3
			: ($bestwidthplus30pc<$widthMax)
				$right:=$gvariable+$bestwidthplus30pc+29
			Else 
				$right:=$gvariable+$widthMax+29
		End case 
	Else 
		$right:=$gvSplitter-3
	End if 
	OBJECT SET COORDINATES:C1248(*; "searchbox_roundRectangle"; $groundRectangle; $hroundRectangle; $right; $broundRectangle)
	OBJECT SET COORDINATES:C1248(*; "searchbox_cross"; $right-26; $hcross; $right-9; $bcross)
	OBJECT SET COORDINATES:C1248(*; "searchbox_variable"; $gvariable; $hvariable; $right-29; $bvariable)
	
	
Function searchBox_cross()
	If (This:C1470.nothingToSave())
		Form:C1466.sfw.searchbox:=""
		Form:C1466.sfw.searchHighlightParts:=Null:C1517
		Form:C1466.sfw.lb_items_search()
		
		GOTO OBJECT:C206(*; "")
		
	End if 