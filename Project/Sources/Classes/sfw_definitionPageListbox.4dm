property filters : Collection
property actions : Collection
property ident : Text
property columns : Collection
property dataSource : Text
property orderBy : Text


Class constructor($ident : Text)
	
	This:C1470.ident:=$ident
	This:C1470.columns:=New collection:C1472
	This:C1470.actions:=New collection:C1472
	This:C1470.filters:=New collection:C1472
	
	//Mark:-dynamic page defintion functions
	
Function setDatasource($datasource : Text)
	
	This:C1470.dataSource:=$datasource
	
Function setOrderBy($orderBy : Text)
	
	This:C1470.orderBy:=$orderBy
	
Function addPredefinedAction($type : Text; $visionIdent : Text; $entryIdent : Text)
	
	$action:=New object:C1471
	$action.predefinedType:=$type
	$action.visionIdent:=$visionIdent
	$action.entryIdent:=$entryIdent
	This:C1470.actions.push($action)
	
Function addSpecificAction($ident : Text; $label : Text; $formulaToCall : 4D:C1709.Function; $formulaToActivate : 4D:C1709.Function;  ...  : Text)
	
	$action:=New object:C1471
	$action.specificAction:=True:C214
	$action.ident:=$ident
	$action.label:=$label
	$action.formulaToCall:=$formulaToCall
	$action.formulaToActivate:=$formulaToActivate || Null:C1517
	
	For ($p; 5; Count parameters:C259)
		$params:=Split string:C1554(${$p}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="needAnEntity")
				$action.needAnEntity:=True:C214
				
		End case 
	End for 
	This:C1470.actions.push($action)
	
	
Function addColumn($expression : Text;  ...  : Text)
	var $column : Object
	
	$column:=New object:C1471
	$column.expression:=$expression
	$column.dataSourceTypeHint:="text"
	
	For ($p; 2; Count parameters:C259)
		$params:=Split string:C1554(${$p}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="width")
				$column.width:=Num:C11($params[0])
			: ($selector="headerLabel")
				$column.headerLabel:=$params[0]
			: ($selector="formatNum") || ($selector="numberFormat")
				$column.numberFormat:=$params[0]
				$column.dataSourceTypeHint:="number"
			: ($selector="center")
				$column.textAlign:="center"
			: ($selector="right")
				$column.textAlign:="right"
			: ($selector="left")
				$column.textAlign:="left"
				
			: ($selector="DontDisplay")
				$column.dontDisplay:=True:C214
			: ($selector="DontExport")
				$column.dontExport:=True:C214
		End case 
	End for 
	
	This:C1470.columns.push($column)
	
	
	
Function addPredefinedFilter($type : Text;  ...  : Text)
	
	$filter:=New object:C1471
	Case of 
		: ($type="periods")
			$filter.ident:="periods"
			$filter.specific:="periods"
			$filter.defaultTitle:="All times"
			For ($p; 2; Count parameters:C259)
				$params:=Split string:C1554(${$p}; ":")
				$selector:=$params.shift()
				Case of 
					: ($selector="filterAttribute")
						$filter.queryElements:=New object:C1471()
						$filter.queryElements.attribute:=$params[0]
						$filter.queryElements.choose:="--all"
				End case 
			End for 
	End case 
	This:C1470.filters.push($filter)
	
	
Function addFilter($ident : Text;  ...  : Text)
	ALERT:C41("to do")
	$filter:=New object:C1471
	$filter.ident:=$ident
	
	This:C1470.filters.push($filter)
	
	
	//Mark:-dynamic page management functions
	
Function _insertDynamicListbox($formDefinition : Object; $panelPage : Object; $offsetHorizontal : Integer; $offsetVertical : Integer)
	var $pageDefinition : Object
	$dynamicSource:=$panelPage.dynamicSource
	OBJECT GET COORDINATES:C663(*; "detail_panel"; $g; $h; $d; $b)
	$widthDetailPanel:=$d-$g
	$heightDetailPanel:=$b-$h
	
	$pageDefinition:=$formDefinition.pages[$panelPage.page]
	
	$gutter:=5
	$filterHeight:=18
	$marginTopForTheListbox:=0
	If ($dynamicSource.filters.length>0)
		$marginTopForTheListbox:=$gutter+$filterHeight+$gutter
		For each ($filter; $dynamicSource.filters)
			$bFilterproperties:=New object:C1471
			$bFilterproperties.type:="button"
			$bFilterproperties.text:=$filter.defaultTitle
			$bFilterproperties.top:=$offsetVertical+$gutter
			$bFilterproperties.left:=$offsetHorizontal+$gutter
			$bFilterproperties.width:=135
			$bFilterproperties.height:=$filterHeight
			$bFilterproperties.events:=["onClick"]
			$bFilterproperties.style:="custom"
			$bFilterproperties.popupPlacement:="linked"
			$bFilterproperties.fontSize:=9
			$bFilterproperties.icon:="/RESOURCES/sfw/image/picto/funnel-small.png"
			$bFilterproperties.textPlacement:="right"
			$bFilterproperties.focusable:=False:C215
			$bFilterproperties.method:="sfw_dynamicPage_pupFilter"
			$pageDefinition.objects["pupFilter_"+$dynamicSource.ident+"_"+$filter.ident]:=$bFilterproperties
		End for each 
	End if 
	
	
	$marginBottom:=0
	If ($dynamicSource.actions.length>0)
		$bActionproperties:=New object:C1471
		$bActionproperties.type:="button"
		$bActionproperties.text:="Actions"
		$bActionproperties.width:=80
		$bActionproperties.height:=21
		$bActionproperties.top:=$heightDetailPanel-$gutter-$bActionproperties.height
		$marginBottom:=$gutter+$bActionproperties.height+$gutter
		$bActionproperties.left:=$gutter+$offsetHorizontal
		$bActionproperties.events:=["onClick"]
		$bActionproperties.style:="custom"
		$bActionproperties.popupPlacement:="linked"
		$bActionproperties.icon:="/RESOURCES/sfw/image/picto/gear.png"
		$bActionproperties.textPlacement:="right"
		$bActionproperties.method:="sfw_dynamicPage_bAction"
		$bActionproperties.sizingY:="move"
		$pageDefinition.objects["bAction_"+$dynamicSource.ident]:=$bActionproperties
	End if 
	
	$listboxProperties:=New object:C1471()
	$listboxProperties.type:="listbox"
	$listboxProperties.listboxType:="collection"
	$listboxProperties.left:=$offsetHorizontal
	$listboxProperties.top:=$offsetVertical+$marginTopForTheListbox
	$listboxProperties.width:=$widthDetailPanel-$offsetHorizontal
	$listboxProperties.height:=$heightDetailPanel-$offsetVertical-$marginBottom-$marginTopForTheListbox
	$listboxProperties.sizingX:="grow"
	$listboxProperties.sizingY:="grow"
	$listboxProperties.resizingMode:="legacy"
	$listboxProperties.focusable:=False:C215
	$listboxProperties.scrollbarHorizontal:="hidden"
	$listboxProperties.horizontalLineStroke:="transparent"
	$listboxProperties.verticalLineStroke:="#FFFFFF"
	$listboxProperties.fill:="#FFFFFF"
	$listboxProperties.alternateFill:="#F7FBFF"  //alice blue
	$listboxProperties.dataSource:="Form."+$dynamicSource.ident
	$listboxProperties.currentItemSource:="Form.current_"+$dynamicSource.ident+"_item"
	$listboxProperties.currentItemPositionSource:="Form.current_"+$dynamicSource.ident+"_position"
	$listboxProperties.selectedItemsSource:="Form.selected_"+$dynamicSource.ident+"_items"
	$listboxProperties.events:=New collection:C1472
	$listboxProperties.columns:=New collection:C1472
	$c:=0
	For each ($columnDef; $dynamicSource.columns)
		If (Not:C34(Bool:C1537($columnDef.dontDisplay)))
			$c+=1
			$column:=New object:C1471
			$header:=New object:C1471
			$header.name:="header_"+$dynamicSource.ident+"_"+String:C10($c)
			$header.text:=$columnDef.headerLabel || Substring:C12($columnDef.expression; 6)
			$column.header:=$header
			$column.name:="col_"+$dynamicSource.ident+"_"+String:C10($c)
			$column.dataSource:=$columnDef.expression
			$column.width:=$columnDef.width || 100
			$column.dataSourceTypeHint:=$columnDef.dataSourceTypeHint
			If ($columnDef.numberFormat#Null:C1517)
				$column.numberFormat:=$columnDef.numberFormat
			End if 
			If ($columnDef.textAlign#Null:C1517)
				$column.textAlign:=$columnDef.textAlign
			End if 
			$listboxProperties.columns.push($column)
		End if 
	End for each 
	
	$pageDefinition.objects[$dynamicSource.ident]:=$listboxProperties
	This:C1470._setDataSourceForDynamicPage()
	
Function _bAction()
	
	$ident:=This:C1470.ident
	$actions:=This:C1470.actions
	If ($actions.length>0)
		
		$menu:=Create menu:C408
		
		For each ($action; $actions)
			Case of 
				: ($action.predefinedType="splitLine")
					APPEND MENU ITEM:C411($menu; "-")
					
				: ($action.predefinedType="openInWindow")
					APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("definitionPageLB.openSelectedItem"; "Open selected item in a new window..."); *)
					SET MENU ITEM PARAMETER:C1004($menu; -1; "--openInWindow")
					SET MENU ITEM ICON:C984($menu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/openWindow-24x24.png")
					If (Form:C1466["current_"+$ident+"_item"]=Null:C1517) || (Form:C1466["selected_"+$ident+"_items"].length>1)
						DISABLE MENU ITEM:C150($menu; -1)
					End if 
					
				: ($action.predefinedType="openAProjection")
					If (Form:C1466["selected_"+$ident+"_items"].length>0)
						APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("definitionPageLB.openProjectionSelectedItem"; "Open a projection with selected items..."); *)
					Else 
						APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("definitionPageLB.openProjectionAllItem"; "Open a projection with all items..."); *)
					End if 
					SET MENU ITEM ICON:C984($menu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/projection-24x24.png")
					SET MENU ITEM PARAMETER:C1004($menu; -1; "--openAProjection")
					
				: ($action.predefinedType="export")
					If (Form:C1466["selected_"+$ident+"_items"].length>0)
						APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("definitionPageLB.exportSelectedItem"; "Export the selected items..."); *)
					Else 
						APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("definitionPageLB.exportAll"; "Export all items..."); *)
					End if 
					SET MENU ITEM ICON:C984($menu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/outside-24x24.png")
					SET MENU ITEM PARAMETER:C1004($menu; -1; "--export")
					
				: ($action.predefinedType="selectAll")
					APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("pagelistbox.select.selectall"); *)
					SET MENU ITEM ICON:C984($menu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/action-24x24.png")
					SET MENU ITEM PARAMETER:C1004($menu; -1; "--selectAll")
					If (Form:C1466["selected_"+$ident+"_items"].length=Form:C1466[$ident].length)
						DISABLE MENU ITEM:C150($menu; -1)
					End if 
					
				: ($action.predefinedType="unselectAll")
					APPEND MENU ITEM:C411($menu; ds:C1482.sfw_readXliff("pagelistbox.select.unselectall"); *)
					SET MENU ITEM ICON:C984($menu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/action-24x24.png")
					SET MENU ITEM PARAMETER:C1004($menu; -1; "--unselectAll")
					If (Form:C1466["selected_"+$ident+"_items"].length=0)
						DISABLE MENU ITEM:C150($menu; -1)
					End if 
					
				: ($action.specificAction)
					APPEND MENU ITEM:C411($menu; $action.label; *)
					SET MENU ITEM ICON:C984($menu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/action-24x24.png")
					SET MENU ITEM PARAMETER:C1004($menu; -1; "--specific:"+$action.ident)
					Case of 
						: (Bool:C1537($action.needAnEntity)) && (Form:C1466["current_"+$ident+"_item"]=Null:C1517)
							DISABLE MENU ITEM:C150($menu; -1)
						Else 
							If ($action.formulaToActivate#Null:C1517)
								If ($action.formulaToActivate.call())
									DISABLE MENU ITEM:C150($menu; -1)
								End if 
							End if 
					End case 
			End case 
		End for each 
		$choose:=Dynamic pop up menu:C1006($menu)
		RELEASE MENU:C978($menu)
		
		Case of 
			: ($choose="--selectAll")
				Form:C1466["selected_"+$ident+"_items"]:=Form:C1466[$ident]
				LISTBOX SELECT ROW:C912(*; $ident; 0; lk replace selection:K53:1)
				
			: ($choose="--unselectAll")
				Form:C1466["selected_"+$ident+"_items"]:=Null:C1517
				LISTBOX SELECT ROW:C912(*; $ident; 0; lk remove from selection:K53:3)
				
			: ($choose="--openInWindow")
				$action:=$actions.query("predefinedType = :1"; "openInWindow").first()
				$item:=Form:C1466["current_"+$ident+"_item"]
				Form:C1466.sfw.openInANewWindow($item; $action.visionIdent; $action.entryIdent)
				
			: ($choose="--openAProjection")
				$action:=$actions.query("predefinedType = :1"; "openInWindow").first()
				$item:=Form:C1466["current_"+$ident+"_item"]
				$formData:=New object:C1471()
				$formData.sfw:=cs:C1710.sfw_main.new()
				$formData.sfw.vision:=cs:C1710.sfw_definition.me.getVisionByIdent($action.visionIdent)
				$formData.sfw.entry:=cs:C1710.sfw_definition.me.getEntryByIdent($action.entryIdent)
				$formData.projection:=New object:C1471
				$formData.projection.label:="<- "+Form:C1466.sfw.entry.label  // XLIFF
				If (Form:C1466["selected_"+$ident+"_items"].length>0)
					$formData.projection.entitiesSelection:=Form:C1466["selected_"+$ident+"_items"]
				Else 
					$formData.projection.entitiesSelection:=Formula from string:C1601(This:C1470.dataSource).call()
				End if 
				$formData.window:=New object:C1471
				GET WINDOW RECT:C443($left; $top; $right; $bottom)
				$formData.window.left:=$left+50
				$formData.window.top:=$top+50
				$formData.sfw.openForm($formData)
				
			: ($choose="--export")
				This:C1470._bAction_export($ident)
				
			: ($choose="--specific:@")
				$ident:=Split string:C1554($choose; ":").pop()
				$action:=$actions.query("ident = :1"; $ident).first()
				$action.formulaToCall.call()
				
		End case 
	End if 
	
	
Function _bAction_export($ident : Text)
	var $file : 4D:C1709.File
	
	$form:=New object:C1471
	$form.message:="Export the values"
	$form.bFile:=1
	$form.bPasteboard:=0
	$form.bTTR:=1
	$form.bCSV:=0
	$form.bXLS:=0
	$form.bOpen:=0
	$form.bShow:=0
	$form.bAddHeader:=1
	$form.folderToExport:=cs:C1710.sfw_dialog.me._getLastExportFolder()
	$form.fileName:="export"
	$form.lb_columsToExport:=New collection:C1472
	For each ($columnDef; This:C1470.columns)
		If (Not:C34(Bool:C1537($columnDef.dontExport)))
			$column:=OB Copy:C1225($columnDef)
			$column.__selected:=True:C214
			$column.name:=$columnDef.headerLabel || Substring:C12($columnDef.expression; 6)
			$form.lb_columsToExport.push($column)
		End if 
	End for each 
	
	If (Is Windows:C1573)
		$refWindow:=Open form window:C675("sfw_dial_export"; Modal form dialog box:K39:7)
	Else 
		$refWindow:=Open form window:C675("sfw_dial_export"; Sheet form window:K39:12)
	End if 
	DIALOG:C40("sfw_dial_export"; $form)
	CLOSE WINDOW:C154($refWindow)
	
	If (ok=1)
		If (Form:C1466["selected_"+$ident+"_items"].length>0)
			$sourceItems:=Form:C1466["selected_"+$ident+"_items"]
		Else 
			$sourceItems:=Form:C1466[This:C1470.ident]
		End if 
		
		Case of 
			: ($form.bTTR=1)
				$columnSeparator:="\t"
				$lineSeparator:="\r"
				$extension:=".txt"
			: ($form.bCSV=1)
				$columnSeparator:="\t"
				$lineSeparator:=";"
				$extension:=".csv"
		End case 
		$lines:=New collection:C1472
		
		If ($form.bAddHeader=1)
			$headerColumns:=New collection:C1472
			For each ($columnDef; This:C1470.columns)
				$headerColumns.push($columnDef.headerLabel || Substring:C12($columnDef.expression; 6))
			End for each 
			$lines.push($headerColumns.join($columnSeparator))
		End if 
		
		For each ($item; $sourceItems)
			$columns:=New collection:C1472
			For each ($columnDef; $form.lb_columsToExport)
				$expressionParts:=Split string:C1554($columnDef.expression; ".")
				If ($expressionParts[0]="This")
					$this:=$expressionParts.shift()
				End if 
				$lastAttribute:=$expressionParts.pop()
				$objectSource:=$item
				For each ($part; $expressionParts)
					$objectSource:=$objectSource[$part]
				End for each 
				$value:=$objectSource[$lastAttribute]
				$columns.push($value)
			End for each 
			$lines.push($columns.join($columnSeparator))
			
		End for each 
		
		Case of 
			: ($form.bPasteboard=1)
				SET TEXT TO PASTEBOARD:C523($lines.join($lineSeparator))
				
			: ($form.bTTR=1) || ($form.bCSV=1)
				$file:=$form.folderToExport.file($form.fileName+$extension)
				$contentText:=$lines.join($lineSeparator)
				$file.setText($contentText)
				If ($form.bShow=1)
					SHOW ON DISK:C922($file.platformPath)
				End if 
				If ($form.bOpen=1)
					OPEN URL:C673($file.platformPath)
				End if 
		End case 
		
	End if 
	
	
	
Function _pupFilter()
	$filter:=This:C1470.filters.query("defaultTitle = :1"; "All times").first()
	$lines:=New collection:C1472
	$lines.push({label: $filter.defaultTitle; parameter: "--all"})
	$lines.push({label: "-"})
	$lines.push({label: "Current month"; parameter: "--currentMonth"})
	$lines.push({label: "Previous month"; parameter: "--previousMonth"})
	$lines.push({label: "Current year"; parameter: "--currentYear"})
	$lines.push({label: "Previous year"; parameter: "--previousYear"})
	
	
	$refMenus:=New collection:C1472
	$refMenu:=Create menu:C408
	$refMenus.push($refMenu)
	For each ($line; $lines)
		If ($line.parameter=Null:C1517)
			APPEND MENU ITEM:C411($refMenu; "-")
		Else 
			APPEND MENU ITEM:C411($refMenu; $line.label; *)
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; $line.parameter)
			If ($filter.queryElements.choose=$line.parameter)
				SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
			End if 
		End if 
	End for each 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	For each ($refMenu; $refMenus)
		RELEASE MENU:C978($refMenu)
	End for each 
	
	Case of 
		: ($choose="--all")
			Use ($filter.queryElements)
				$filter.queryElements.dateFrom:=Null:C1517
				$filter.queryElements.dateTo:=Null:C1517
				$filter.queryElements.choose:=$choose
			End use 
			This:C1470._setDataSourceForDynamicPage()
			OBJECT SET TITLE:C194(*; FORM Event:C1606.objectName; $filter.defaultTitle)
			
			
		: ($choose="--currentMonth")
			Use ($filter.queryElements)
				$filter.queryElements.dateFrom:=Add to date:C393(!00-00-00!; Year of:C25(Current date:C33); Month of:C24(Current date:C33); 1)
				$filter.queryElements.dateTo:=Add to date:C393($filter.queryElements.dateFrom; 0; 1; -1)
				$filter.queryElements.choose:=$choose
			End use 
			This:C1470._setDataSourceForDynamicPage()
			OBJECT SET TITLE:C194(*; FORM Event:C1606.objectName; "Current month")
			
		: ($choose="--previousMonth")
			Use ($filter.queryElements)
				$filter.queryElements.dateFrom:=Add to date:C393(!00-00-00!; Year of:C25(Current date:C33); Month of:C24(Current date:C33)-1; 1)
				$filter.queryElements.dateTo:=Add to date:C393($filter.queryElements.dateFrom; 0; 1; -1)
				$filter.queryElements.choose:=$choose
			End use 
			This:C1470._setDataSourceForDynamicPage()
			OBJECT SET TITLE:C194(*; FORM Event:C1606.objectName; "Previous month")
			
		: ($choose="--currentYear")
			Use ($filter.queryElements)
				$filter.queryElements.dateFrom:=Add to date:C393(!00-00-00!; Year of:C25(Current date:C33); 1; 1)
				$filter.queryElements.dateTo:=Add to date:C393(!00-00-00!; Year of:C25(Current date:C33); 12; 31)
				$filter.queryElements.choose:=$choose
			End use 
			This:C1470._setDataSourceForDynamicPage()
			OBJECT SET TITLE:C194(*; FORM Event:C1606.objectName; "Current year")
			
		: ($choose="--previousYear")
			Use ($filter.queryElements)
				$filter.queryElements.dateFrom:=Add to date:C393(!00-00-00!; Year of:C25(Current date:C33)-1; 1; 1)
				$filter.queryElements.dateTo:=Add to date:C393(!00-00-00!; Year of:C25(Current date:C33)-1; 12; 31)
				$filter.queryElements.choose:=$choose
			End use 
			This:C1470._setDataSourceForDynamicPage()
			OBJECT SET TITLE:C194(*; FORM Event:C1606.objectName; "Previous year")
			
	End case 
	
	
	
Function _setDataSourceForDynamicPage()
	
	$queryParts:=New collection:C1472
	$querySettings:=New object:C1471("parameters"; New object:C1471)
	
	$f:=0
	For each ($filter; This:C1470.filters)
		$f+=1
		Case of 
			: ($filter.ident="periods")
				If ($filter.queryElements.dateFrom#Null:C1517)
					$queryParts.push($filter.queryElements.attribute+" >= :dateFrom_"+String:C10($f))
					$querySettings.parameters["dateFrom_"+String:C10($f)]:=$filter.queryElements.dateFrom
				End if 
				If ($filter.queryElements.dateTo#Null:C1517)
					$queryParts.push($filter.queryElements.attribute+" <= :dateTo_"+String:C10($f))
					$querySettings.parameters["dateTo_"+String:C10($f)]:=$filter.queryElements.dateTo
				End if 
		End case 
	End for each 
	
	$queryString:=$queryParts.join(" and ")
	If ($queryString#"")
		If (This:C1470.orderBy#Null:C1517)
			$queryString+=" order by "+This:C1470.orderBy
		End if 
		Form:C1466[This:C1470.ident]:=Formula from string:C1601(This:C1470.dataSource).call().query($queryString; $querySettings)
	Else 
		If (This:C1470.orderBy#Null:C1517)
			Form:C1466[This:C1470.ident]:=Formula from string:C1601(This:C1470.dataSource).call().orderBy(This:C1470.orderBy)
		Else 
			Form:C1466[This:C1470.ident]:=Formula from string:C1601(This:C1470.dataSource).call()
		End if 
	End if 
	