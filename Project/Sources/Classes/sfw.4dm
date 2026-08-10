Class constructor
	
	
Function changeTopBarColor($color : Text)
	OBJECT SET RGB COLORS:C628(*; "bkgd_topBar"; $color; $color)
	
	
Function openForm($formData : Object)
	
	If ($formData.sameProcess)
		
		If ($formData.current_uuid#Null:C1517) && ($formData.current_item=Null:C1517)
			$formData.current_item:=ds:C1482[$formData.sfw.entry.dataclass].get($formData.current_uuid)
		End if 
		
		$formData.sfw._openFormInProcess($formData)
		
	Else 
		
		$processName:=$formData.sfw.entry.ident
		If ($formData.current_item#Null:C1517)
			$formData.current_uuid:=$formData.current_item.getKey()
		End if 
		$refProcess:=New process:C317("sfw_openForm"; 0; $processName; $formData)
		
	End if 
	
Function _openFormInProcess($formData : Object)
	
	$sfwclass:=OB Class:C1730($formData.sfw).name
	
	Case of 
		: ($formData.wizard#Null:C1517)
			$dialogName:=$formData.wizard.panel
		: ($formData.sfw.entry.wizard#Null:C1517)
			$dialogName:=$formData.sfw.entry.wizard.panel
		: (OB Class:C1730($formData.sfw).name="sfw_item")
			$dialogName:="sfw_item"
		Else 
			$dialogName:="sfw_main_new"  //"sfw_main"
	End case 
	$formData.dialogName:=$dialogName
	
	If ($formData.sfw.entry.wizard=Null:C1517)
		Case of 
			: ($formData.projection#Null:C1517)
				If (OB Class:C1730($formData.projection.entitiesSelection).superclass.name="EntitySelection")
					$formData.sfw.lb_items:=$formData.projection.entitiesSelection.copy()
				Else 
					$formData.sfw.lb_items:=ds:C1482[$formData.sfw.entry.dataclass].newSelection()
				End if 
			: ($formData.sfw.lb_items#Null:C1517)
				If (OB Class:C1730($formData.sfw.lb_items).superclass.name="EntitySelection")
					If (Not:C34($formData.sfw.lb_items.isAlterable()))
						$formData.sfw.lb_items:=$formData.sfw.lb_items.copy()
					End if 
				End if 
			Else 
				If ($formData.sfw.entry.dataclass#Null:C1517)
					$formData.sfw.lb_items:=ds:C1482[$formData.sfw.entry.dataclass].newSelection()
				Else 
					$formData.sfw.lb_items:=New collection:C1472
				End if 
		End case 
		$windowType:=($formData.sameProcess) ? Modal form dialog box:K39:7 : Plain form window:K39:10
	Else 
		$windowType:=($formData.sfw.entry.wizard.palette) ? Palette form window:K39:9 : Plain form window:K39:10
	End if 
	
	If ($formData.window=Null:C1517)
		$refWindow:=cs:C1710.sfw_window.me.openFormWindow($dialogName; $windowType)
	Else 
		$refWindow:=cs:C1710.sfw_window.me.openFormWindow($dialogName; $windowType; $formData.window.left; $formData.window.top)
	End if 
	DIALOG:C40($dialogName; $formData)
	GET WINDOW RECT:C443($left; $top; $right; $bottom)
	cs:C1710.sfw_window.me.closeWindow($refWindow)
	
	If ($formData.nextEntry=Null:C1517)
		$close:=True:C214
		
	Else 
		$ident:=$formData.nextEntry
		$entry:=cs:C1710.sfw_definition.me.getEntryByIdent($ident)
		$visionIdent:=$entry.visions.first()
		$formData:=New object:C1471()
		Case of 
			: ($entry.wizard#Null:C1517)
				$formData.sfw:=cs:C1710.sfw_wizard.new()
			Else 
				$formData.sfw:=cs:C1710.sfw_main.new()
		End case 
		$formData.sfw.vision:=cs:C1710.sfw_definition.me.getVisionByIdent($visionIdent)
		$formData.sfw.entry:=$entry
		$formData.nextEntry:=Null:C1517
		$formData.window:=New object:C1471
		$formData.window.left:=$left
		$formData.window.top:=$top
		$formData.sfw.openForm($formData)
		
	End if 
	
	
	
Function methodExist($nameToTest : Text)->$exist : Boolean
	
	ARRAY TEXT:C222($_names; 0)
	METHOD GET NAMES:C1166($_names; $nameToTest)
	
	$exist:=(Find in array:C230($_names; $nameToTest)>0)
	
	
Function shadesGetColors($index : Integer)->$color : Text
	
	$colors:=New collection:C1472
	
	$colors.push("#E67E22")
	$colors.push("#85C1E9")
	$colors.push("#C39BD3")
	$colors.push("#F5B7B1")
	$colors.push("#5499C7")
	$colors.push("#DC7633")
	$colors.push("#F1C40F")
	$colors.push("#618a9c")
	$colors.push("#ef5a78")
	$colors.push("#f89a1c")
	$colors.push("#c09e3d")
	$colors.push("#faef07")
	$colors.push("#9cd1bd")
	$colors.push("#dfd284")
	$colors.push("#4eb947")
	$colors.push("#b8a181")
	$colors.push("#ef2d36")
	$colors.push("#df9846")
	$colors.push("#b65671")
	$colors.push("#97839c")
	$colors.push("#d0b194")
	$colors.push("#817d74")
	$colors.push("#e3be25")
	$colors.push("#b8cbf6")
	$colors.push("#a0a48a")
	$colors.push("#4eb947")
	$colors.push("#df9e9c")
	$colors.push("#be2947")
	$colors.push("#f69b7f")
	$colors.push("#66aba6")
	$colors.push("#b6c46f")
	$colors.push("#e0844b")
	$colors.push("#da0c67")
	$colors.push("#28b44b")
	$colors.push("#f68a5c")
	
	$nbColors:=$colors.length
	Case of 
		: ($index=1)
			$color:="#E5E7E9"
		Else 
			$color:=$colors[$index%$nbColors]
	End case 
	
	
Function _searchEngine()
	
	If (This:C1470.entry.searchfields#Null:C1517) && (This:C1470.entry.searchfields.length>0)
		
		This:C1470._advancedSearchEngine()
		
	Else 
		
		$rawValue:=Split string:C1554(This:C1470.searchbox; " ").join(" "; ck ignore null or empty:K85:5)
		
		$searchParts:=This:C1470._searchString_analyze($rawValue)
		
		This:C1470.searchHighlightParts:=New collection:C1472
		
		$querystringParts:=New collection:C1472
		$querySettings:=New object:C1471
		$querySettings.parameters:=New object:C1471
		$querySettings.attributes:=New object:C1471
		$querySettings.queryPlan:=True:C214
		$querySettings.queryPath:=True:C214
		
		
		$querystringParts:=New collection:C1472
		$jumpNextOperator:=False:C215
		For each ($part; $searchParts)
			Case of 
				: ($part.type="value")
					
					This:C1470.searchHighlightParts.push($part.value)
					$valueSearch:="@"+$part.value+"@"
					$queryCriteras:=New collection:C1472
					For each ($field; This:C1470.entry.searchbox.fields)
						If ($field.fieldPlaceHolder#Null:C1517)
							$querySettings.parameters[$field.fieldPlaceHolder+String:C10($part.indice)]:=$valueSearch
							$queryCriteras.push($field.attribute+" = :"+$field.fieldPlaceHolder+String:C10($part.indice))
						Else 
							$querySettings.parameters[$field.attribute+String:C10($part.indice)]:=$valueSearch
							$queryCriteras.push($field.attribute+" = :"+$field.attribute+String:C10($part.indice))
						End if 
					End for each 
					$querystringParts.push("("+$queryCriteras.join(" OR ")+")")
					
				: ($part.type="specificSearch")
					$solved:=False:C215
					If (Form:C1466.sfw.entry.searchbox#Null:C1517)
						If (Form:C1466.sfw.entry.searchbox.specificSearches#Null:C1517)
							$indices:=Form:C1466.sfw.entry.searchbox.specificSearches.indices("tag = :1"; $part.value)
							If ($indices.length>0)
								$specificSearch:=Form:C1466.sfw.entry.searchbox.specificSearches[$indices[0]]
								Case of 
									: ($specificSearch.queryString#Null:C1517)
										$querystring:="("+$specificSearch.queryString+")"
										$querystringParts.push($querystring)
										$solved:=True:C214
									: ($specificSearch.formula#Null:C1517)
										$querySettings.attributes["formula"+String:C10($part.indice)]:=Formula from string:C1601($specificSearch.formula)
										$querystring:="(:formula"+String:C10($part.indice)+")"
										$querystringParts.push($querystring)
										$solved:=True:C214
									: ($specificSearch.inCollection#Null:C1517)
										$builderPart:=Split string:C1554($specificSearch.collectionBuilder; ":=")
										$coll:=Formula from string:C1601($builderPart[1]).call()
										$querySettings.parameters[$builderPart[0]]:=$coll
										$querystring:="("+$specificSearch.inCollection+")"
										$querystringParts.push($querystring)
								End case 
							End if 
						End if 
					End if 
					If ($solved=False:C215)
						$jumpNextOperator:=True:C214
					End if 
					
				: ($part.type="operator") & ($jumpNextOperator)
					$jumpNextOperator:=False:C215
					
				: ($part.type="operator")
					$querystringParts.push($part.value)
					
					
				: ($part.type="parenthesis") & ($jumpNextOperator)
					
				: ($part.type="parenthesis")
					$querystringParts.push($part.value)
					
			End case 
		End for each 
		
		$querystring:=$querystringParts.join(" ")
		
		Case of 
			: (This:C1470.view.subset#Null:C1517)
				Case of 
					: (This:C1470.view.subset.functionName#Null:C1517) & ($querystring#"")
						$functionName:=This:C1470.view.subset.functionName
						If (This:C1470.view.subset.params=Null:C1517)
							This:C1470.lb_items:=ds:C1482[This:C1470.entry.dataclass][$functionName]().query($querystring; $querySettings).copy()
						Else 
							This:C1470.lb_items:=ds:C1482[This:C1470.entry.dataclass][$functionName].apply(ds:C1482[This:C1470.entry.dataclass]; This:C1470.view.subset.params).query($querystring; $querySettings).copy()
						End if 
						
						
					: (This:C1470.view.subset.functionName#Null:C1517)
						$functionName:=This:C1470.view.subset.functionName
						If (This:C1470.view.subset.params=Null:C1517)
							This:C1470.lb_items:=ds:C1482[This:C1470.entry.dataclass][$functionName]().copy()
						Else 
							This:C1470.lb_items:=ds:C1482[This:C1470.entry.dataclass][$functionName].apply(ds:C1482[This:C1470.entry.dataclass]; This:C1470.view.subset.params).copy()
						End if 
				End case 
			Else 
				If ($querystring#"")
					This:C1470.lb_items:=ds:C1482[This:C1470.entry.dataclass].query($querystring; $querySettings).copy()
				Else 
					This:C1470.lb_items:=ds:C1482[This:C1470.entry.dataclass].all()
				End if 
		End case 
		
	End if 
	
Function _searchString_analyze($rawValue : Text)->$searchParts : Collection
	
	$searchParts:=New collection:C1472
	$currentValue:=""
	$inDoubleQuote:=False:C215
	
	If (Form:C1466.sfw.entry.searchbox#Null:C1517)
		If (Form:C1466.sfw.entry.searchbox.specificSearches#Null:C1517)
			This:C1470.specificSearchTags:=Form:C1466.sfw.entry.searchbox.specificSearches.distinct("tag")
		End if 
	End if 
	This:C1470.analyseIsInAQuestionMark:=False:C215
	
	While ($rawValue#"")
		$char:=$rawValue[[1]]
		$positionNext:=2
		Case of 
			: ($rawValue="OR @")
				If ($searchParts.length=0)
					This:C1470._searchString_analyzePushCurrentValue("or"; $searchParts)
					$currentValue:=""
				Else 
					$part:=New object:C1471
					$part.type:="operator"
					$part.value:="OR"
					$searchParts.push($part)
				End if 
				$positionNext:=4
				
			: ($rawValue="OR(@")
				If ($searchParts.length=0)
					This:C1470._searchString_analyzePushCurrentValue("or"; $searchParts)
					$currentValue:=""
				Else 
					$part:=New object:C1471
					$part.type:="operator"
					$part.value:="OR"
					$searchParts.push($part)
				End if 
				$positionNext:=3
				
			: ($rawValue="AND @")
				If ($searchParts.length=0)
					This:C1470._searchString_analyzePushCurrentValue("and"; $searchParts)
					$currentValue:=""
				Else 
					$part:=New object:C1471
					$part.type:="operator"
					$part.value:="AND"
					$searchParts.push($part)
				End if 
				$positionNext:=5
				
			: ($rawValue="AND(@")
				If ($searchParts.length=0)
					This:C1470._searchString_analyzePushCurrentValue("and"; $searchParts)
					$currentValue:=""
				Else 
					$part:=New object:C1471
					$part.type:="operator"
					$part.value:="AND"
					$searchParts.push($part)
				End if 
				$positionNext:=4
			: ($char="?")
				This:C1470.analyseIsInAQuestionMark:=True:C214
			: ($char=" ") & (Not:C34($inDoubleQuote))
				This:C1470._searchString_analyzePushCurrentValue($currentValue; $searchParts)
				$currentValue:=""
			: ($char="\"") & ($inDoubleQuote)
				$inDoubleQuote:=False:C215
				This:C1470._searchString_analyzePushCurrentValue($currentValue; $searchParts)
				$currentValue:=""
				
			: ($char="\"")
				This:C1470._searchString_analyzePushCurrentValue($currentValue; $searchParts)
				$currentValue:=""
				$inDoubleQuote:=True:C214
				
			: ($char="(") & (Not:C34($inDoubleQuote))
				This:C1470._searchString_analyzePushCurrentValue($currentValue; $searchParts)
				$currentValue:=""
				$part:=New object:C1471
				$part.type:="parenthesis"
				$part.value:="("
				$searchParts.push($part)
				
			: ($char=")") & (Not:C34($inDoubleQuote))
				This:C1470._searchString_analyzePushCurrentValue($currentValue; $searchParts)
				$currentValue:=""
				$part:=New object:C1471
				$part.type:="parenthesis"
				$part.value:=")"
				$searchParts.push($part)
				
			Else 
				$currentValue:=$currentValue+$char
				
		End case 
		$rawValue:=Substring:C12($rawValue; $positionNext)
		
	End while 
	
	This:C1470._searchString_analyzePushCurrentValue($currentValue; $searchParts)
	
	$searchParts:=This:C1470._searchString_completeOperator($searchParts)
	
	OB REMOVE:C1226(This:C1470; "analyseIsInAQuestionMark")
	
Function _searchString_analyzePushCurrentValue($currentValue : Text; $searchParts : Collection)
	
	Case of 
		: (This:C1470.analyseIsInAQuestionMark)
			If (Form:C1466.sfw.entry.searchbox#Null:C1517)
				If (Form:C1466.sfw.entry.searchbox.specificSearches#Null:C1517)
					If (This:C1470.specificSearchTags.indexOf($currentValue)#-1)
						$part:=New object:C1471
						$part.type:="specificSearch"
						$part.value:=$currentValue
						$searchParts.push($part)
					End if 
				End if 
			End if 
			This:C1470.analyseIsInAQuestionMark:=False:C215
			
		: ($currentValue#"")
			$part:=New object:C1471
			$part.type:="value"
			$part.value:=$currentValue
			$searchParts.push($part)
			
	End case 
	
Function _searchString_completeOperator($searchPartsIN : Collection)->$searchParts : Collection
	
	var $previousPart : Object
	
	$searchParts:=New collection:C1472
	$previousPart:=Null:C1517
	$iPart:=0
	$nbParenthesis:=0
	For each ($part; $searchPartsIN)
		
		Case of 
			: (Position:C15(String:C10($previousPart.type); "value;specificSearch;parenthesis")>0) & (($part.type="value") | ($part.type="specificSearch"))
				If ($previousPart.value#"(")
					$iPart:=$iPart+1
					$operatorPart:=New object:C1471
					$operatorPart.type:="operator"
					$operatorPart.value:="AND"
					$operatorPart.indice:=$iPart
					$searchParts.push($operatorPart)
				End if 
				$iPart:=$iPart+1
				$part.indice:=$iPart
				$searchParts.push($part)
				
			: ($part.type="parenthesis")
				
				If (String:C10($previousPart.type)="parenthesis")
					If ($previousPart.value=")") & ($part.value="(")
						$iPart:=$iPart+1
						$operatorPart:=New object:C1471
						$operatorPart.type:="operator"
						$operatorPart.value:="AND"
						$operatorPart.indice:=$iPart
						$searchParts.push($operatorPart)
					End if 
				End if 
				If ($part.value="(")
					$nbParenthesis:=$nbParenthesis+1
				Else 
					$nbParenthesis:=$nbParenthesis-1
				End if 
				$iPart:=$iPart+1
				$part.indice:=$iPart
				$searchParts.push($part)
				
			Else 
				$iPart:=$iPart+1
				$part.indice:=$iPart
				$searchParts.push($part)
				
		End case 
		$previousPart:=$part
	End for each 
	
	Case of 
		: ($nbParenthesis>0)
			For ($i; $nbParenthesis; 0; -1)
				$parenthesisPart:=New object:C1471
				$parenthesisPart.type:="parenthesis"
				$parenthesisPart.value:=")"
				$parenthesisPart.indice:=$i
				$searchParts.push($parenthesisPart)
			End for 
			
		: ($nbParenthesis<0)
			For ($i; $nbParenthesis; 0; -1)
				$parenthesisPart:=New object:C1471
				$parenthesisPart.type:="parenthesis"
				$parenthesisPart.value:="("
				$iPart:=$iPart+1
				$parenthesisPart.indice:=$iPart
				$searchParts.unshift($parenthesisPart)
			End for 
			
	End case 
	
	
	
Function _advancedSearchEngine()
	
	This:C1470.lb_items:=cs:C1710.sfw_searchEngine.me.perform(This:C1470.entry; This:C1470.searchbox)
	This:C1470.searchHighlightParts:=cs:C1710.sfw_searchEngine.me.searchHighlightParts
	
	Case of 
		: (This:C1470.view.subset=Null:C1517)
		: (This:C1470.view.subset.functionName#Null:C1517)
			$functionName:=This:C1470.view.subset.functionName
			If (This:C1470.view.subset.params=Null:C1517)
				This:C1470.lb_items:=This:C1470.lb_items.and(ds:C1482[This:C1470.entry.dataclass][$functionName]()).copy()
			Else 
				This:C1470.lb_items:=This:C1470.lb_items.and(ds:C1482[This:C1470.entry.dataclass][$functionName].apply(ds:C1482[This:C1470.entry.dataclass]; This:C1470.view.subset.params)).copy()
			End if 
	End case 
	
	
Function drawButtons()
	
	Case of 
		: (Form:C1466.current_item=Null:C1517)
			If (This:C1470.lb_items.length=0)
				Form:C1466.situation.mode:="none"
			Else 
				Form:C1466.situation.mode:="view"
			End if 
	End case 
	Form:C1466.situation.changeToSaveOrCancel:=""
	
	$visibleItemButtons:=New collection:C1472
	$enabletemButtons:=New collection:C1472
	$visibleItemListButtons:=New collection:C1472
	$enabletemListButtons:=New collection:C1472
	Case of 
		: (Form:C1466.situation.mode="none")
			$bModeFormat:=ds:C1482.sfw_readXliff("crud.mode.chooseAMode"; "Choose a mode")+";#sfw/image/skin/rainbow/btn4states/mode-32x32.png;;3;1;1;0;;;;1;;4"  //XLIFF OK
			If (Form:C1466.current_item#Null:C1517)
				$visibleItemButtons.push("bItemReload")
				$enabletemButtons.push("bItemReload")
			End if 
			
		: (Form:C1466.situation.mode="view")
			$bModeFormat:=ds:C1482.sfw_readXliff("crud.mode.visualization"; "Visualization")+";#sfw/image/skin/rainbow/btn4states/eye-32x32.png;;3;1;1;0;;;;1;;4"  //XLIFF OK
			If (Form:C1466.current_item#Null:C1517)
				$visibleItemButtons.push("bItemReload")
				$enabletemButtons.push("bItemReload")
			End if 
			
		: (Form:C1466.situation.mode="add")
			$bModeFormat:=ds:C1482.sfw_readXliff("crud.mode.creation"; "Creation")+";#sfw/image/skin/rainbow/btn4states/add-32x32.png;;3;1;1;0;;;;1;;4"  //XLIFF OK
			$visibleItemButtons.push("bItemRenounce")
			$visibleItemButtons.push("bItemCreate")
			$enabletemButtons.push("bItemRenounce")
			Form:C1466.situation.changeToSaveOrCancel:="add"
			If (Bool:C1537(Form:C1466.subForm.canValidate))
				$enabletemButtons.push("bItemCreate")
			End if 
			
		: (Form:C1466.situation.mode="duplicate")
			$bModeFormat:=ds:C1482.sfw_readXliff("crud.mode.creation"; "Creation")+";#sfw/image/skin/rainbow/btn4states/add-32x32.png;;3;1;1;0;;;;1;;4"  //XLIFF OK
			$visibleItemButtons.push("bItemRenounce")
			$visibleItemButtons.push("bItemCreate")
			$enabletemButtons.push("bItemRenounce")
			Form:C1466.situation.changeToSaveOrCancel:="duplicate"
			If (Bool:C1537(Form:C1466.subForm.canValidate))
				$enabletemButtons.push("bItemCreate")
			End if 
			
		: (Form:C1466.situation.mode="delete")
			$bModeFormat:=ds:C1482.sfw_readXliff("crud.mode.deletion"; "Deletion")+";#sfw/image/skin/rainbow/btn4states/trash-32x32.png;;3;1;1;0;;;;1;;4"  //XLIFF OK
			$visibleItemButtons.push("bItemDelete")
			$enabletemButtons.push("bItemDelete")
			
		Else 
			Form:C1466.situation.mode:="modify"
			$bModeFormat:=ds:C1482.sfw_readXliff("crud.mode.modification"; "Modification")+";#sfw/image/skin/rainbow/btn4states/edit-32x32.png;;3;1;1;0;;;;1;;4"  //XLIFF OK
			$visibleItemButtons.push("bItemCancel")
			$visibleItemButtons.push("bItemSave")
			$diffs:=New collection:C1472
			For each ($diff; Form:C1466.current_clone.diff(Form:C1466.current_item))
				Case of 
					: (ds:C1482[Form:C1466.sfw.entry.dataclass][$diff.attributeName].type="image") && (ds:C1482[Form:C1466.sfw.entry.dataclass][$diff.attributeName].kind="calculated")
					Else 
						$diffs.push($diff)
				End case 
			End for each 
			If (Form:C1466.current_item.touched()) && (($diffs.length#0) || (Form:C1466.current_item.touchedAttributes().indexOf("UUID")#-1))
				Form:C1466.situation.changeToSaveOrCancel:="modify"
				$enabletemButtons.push("bItemCancel")
				If (Bool:C1537(Form:C1466.subForm.canValidate))
					$enabletemButtons.push("bItemSave")
				End if 
			End if 
	End case 
	
	If (Form:C1466.current_item#Null:C1517) && (Form:C1466.sfw.entry.itemActions#Null:C1517) && (Form:C1466.sfw.entry.itemActions.length>0)
		$authorizedProfiles:=cs:C1710.sfw_userManager.me.authorizedProfiles
		$atLessOneActionAllowed:=False:C215
		For each ($action; Form:C1466.sfw.entry.itemActions)
			If ($action.allowedProfiles#Null:C1517) && ($action.allowedProfiles.length>0)
				For each ($authorizedProfile; $authorizedProfiles)
					$atLessOneActionAllowed:=$atLessOneActionAllowed || ($action.allowedProfiles.indexOf($authorizedProfile)#-1)
				End for each 
			Else 
				$atLessOneActionAllowed:=True:C214
			End if 
		End for each 
		If ($atLessOneActionAllowed)
			$visibleItemButtons.push("bItemAction")
			$enabletemButtons.push("bItemAction")
		End if 
	End if 
	If (Form:C1466.sfw.entry.itemListActions#Null:C1517) && (Form:C1466.sfw.entry.itemListActions.length>0)
		$authorizedProfiles:=cs:C1710.sfw_userManager.me.authorizedProfiles
		$atLessOneActionAllowed:=False:C215
		For each ($action; Form:C1466.sfw.entry.itemListActions)
			If ($action.allowedProfiles#Null:C1517) && ($action.allowedProfiles.length>0)
				For each ($authorizedProfile; $authorizedProfiles)
					$atLessOneActionAllowed:=$atLessOneActionAllowed || ($action.allowedProfiles.indexOf($authorizedProfile)#-1)
				End for each 
			Else 
				$atLessOneActionAllowed:=True:C214
			End if 
		End for each 
		If ($atLessOneActionAllowed)
			$visibleItemListButtons.push("bItemListAction")
			$enabletemListButtons.push("bItemListAction")
		End if 
	End if 
	If (Form:C1466.sfw.entry.itemListProjections#Null:C1517) && (Form:C1466.sfw.entry.itemListProjections.length>0)
		$visibleItemListButtons.push("bItemListProjection")
		$enabletemListButtons.push("bItemListProjection")
	End if 
	If (Form:C1466.sfw.entry.itemListOutsides#Null:C1517) && (Form:C1466.sfw.entry.itemListOutsides.length>0)
		$visibleItemListButtons.push("bItemListOutside")
		$enabletemListButtons.push("bItemListOutside")
	End if 
	
	
	OBJECT SET FORMAT:C236(*; "bMode"; $bModeFormat)
	
	OBJECT SET VISIBLE:C603(*; "bItem@"; False:C215)
	
	OBJECT GET COORDINATES:C663(*; "bMode"; $gbMode; $hbMode; $dbMode; $bbmode)
	OBJECT GET BEST SIZE:C717(*; "bMode"; $optimalWidth; $optimalHeight)
	$optimalWidth:=$optimalWidth+10  //for the popup indicator
	OBJECT SET COORDINATES:C1248(*; "bMode"; $gbMode; $hbMode; $gbMode+$optimalWidth; $bbmode)
	$gapBITem:=10
	$left:=$gbMode+$optimalWidth+$gapBITem
	For each ($button; $visibleItemButtons)
		OBJECT SET VISIBLE:C603(*; $button; True:C214)
		OBJECT GET BEST SIZE:C717(*; $button; $optimalWidth; $optimalHeight)
		OBJECT SET COORDINATES:C1248(*; $button; $left; $hbMode; $left+$optimalWidth; $bbmode)
		$left:=$left+$optimalWidth+$gapBITem
	End for each 
	
	OBJECT SET ENABLED:C1123(*; "bItem@"; False:C215)
	For each ($button; $enabletemButtons)
		OBJECT SET ENABLED:C1123(*; $button; True:C214)
	End for each 
	
	$sucessValidationRules:=(Form:C1466.subForm.validationRulesPassedWithSuccess=Null:C1517) || (Form:C1466.subForm.validationRulesPassedWithSuccess=True:C214)
	$iconPathForbItemSave:=$sucessValidationRules ? "#sfw/image/skin/rainbow/btn4states/save-32x32.png" : "#sfw/image/skin/rainbow/btn4states/saveError-32x32.png"
	OBJECT SET FORMAT:C236(*; "bItemSave"; ";"+$iconPathForbItemSave+";")
	OBJECT SET FORMAT:C236(*; "bItemCreate"; ";"+$iconPathForbItemSave+";")
	If (Not:C34($sucessValidationRules)) && (Form:C1466.subForm.validationRulesMessages#Null:C1517)
		OBJECT SET HELP TIP:C1181(*; "bItemSave"; Form:C1466.subForm.validationRulesMessages.join("\r"))
		OBJECT SET HELP TIP:C1181(*; "bItemCreate"; Form:C1466.subForm.validationRulesMessages.join("\r"))
	End if 
	
	OBJECT SET VISIBLE:C603(*; "bItemList@"; False:C215)
	$gapBITem:=10
	$left:=10
	For each ($button; $visibleItemListButtons)
		OBJECT SET VISIBLE:C603(*; $button; True:C214)
		OBJECT GET BEST SIZE:C717(*; $button; $optimalWidth; $optimalHeight)
		OBJECT SET COORDINATES:C1248(*; $button; $left; $hbMode; $left+$optimalWidth; $bbmode)
		$left:=$left+$optimalWidth+$gapBITem
	End for each 
	
	OBJECT SET ENABLED:C1123(*; "bItemList@"; False:C215)
	For each ($button; $enabletemListButtons)
		OBJECT SET ENABLED:C1123(*; $button; True:C214)
	End for each 
	
	$nothingToSaveOrCancel:=(String:C10(Form:C1466.situation.changeToSaveOrCancel)="")
	OBJECT SET ENABLED:C1123(*; "searchbox_cross"; $nothingToSaveOrCancel)
	OBJECT SET ENTERABLE:C238(*; "searchbox_variable"; $nothingToSaveOrCancel)
	OBJECT SET BORDER STYLE:C1262(*; "searchbox_roundRectangle"; Border None:K42:27)
	If ($nothingToSaveOrCancel)
		OBJECT SET RGB COLORS:C628(*; "searchbox_roundRectangle"; "lightgrey"; "white")
	Else 
		OBJECT SET RGB COLORS:C628(*; "searchbox_roundRectangle"; "lightgrey"; "#eaeaea")
	End if 
	
	This:C1470.displayTransactionLevel()
	
Function drawButtons_virtual()
	OBJECT SET VISIBLE:C603(*; "bItem@"; False:C215)
	OBJECT SET VISIBLE:C603(*; "bItemList@"; False:C215)
	
	$bModeFormat:=ds:C1482.sfw_readXliff("crud.mode.actions"; "Actions")+";#sfw/image/skin/rainbow/btn4states/action-32x32.png;;3;1;1;0;;;;1;;4"  //XLIFF OK
	OBJECT SET FORMAT:C236(*; "bMode"; $bModeFormat)
	$bModeVisible:=False:C215
	Case of 
		: (Form:C1466.current_item=Null:C1517)
		: (Form:C1466.current_item.itemActions=Null:C1517)
		Else 
			$bModeVisible:=True:C214
	End case 
	OBJECT SET VISIBLE:C603(*; "bMode"; $bModeVisible)
	
Function redrawButtons()
	CALL FORM:C1391(Current form window:C827; "sfw_main_draw_button")
	
	
Function nothingToSave()->$continue : Boolean
	
	$continue:=False:C215
	
	If (String:C10(Form:C1466.situation.changeToSaveOrCancel)#"")
		$formData:=New object:C1471("validationRulesPassedWithSuccess"; Form:C1466.subForm.validationRulesPassedWithSuccess)
		Case of 
			: (Form:C1466.situation.mode="modify")
				cs:C1710.sfw_dialog.me.saveCancelContinue($formData)
			: (Form:C1466.situation.mode="add") | (Form:C1466.situation.mode="duplicate")
				cs:C1710.sfw_dialog.me.createRenounceContinue($formData)
		End case 
		Case of 
			: ($formData.action="continue")
				$continue:=False:C215
				If ((Form:C1466.situation.mode="modify") | (Form:C1466.situation.mode="add") | (Form:C1466.situation.mode="duplicate"))
					//This.cancelTransaction()
				End if 
				
			: ($formData.action="cancel")
				Form:C1466.sfw.bItemCancel("DontRestartTransaction")
				$continue:=True:C214
				
			: ($formData.action="save")
				Form:C1466.sfw.bItemSave("DontRestartTransaction")
				$continue:=True:C214
				
			: ($formData.action="renounce")
				Form:C1466.sfw.bItemRenounce()
				$continue:=True:C214
				
			: ($formData.action="create")
				Form:C1466.sfw.bItemCreate()
				$continue:=True:C214
				
		End case 
		
	Else 
		$continue:=True:C214
		If ((Form:C1466.situation.mode="modify") | (Form:C1466.situation.mode="add") | (Form:C1466.situation.mode="duplicate"))
			This:C1470.cancelTransaction()
		End if 
		
	End if 
	
	
	
Function arrangeHeaderTabs()
	$tabsToArrange:=New collection:C1472
	If (OBJECT Get visible:C1075(*; "headerTabFavorite_title"))
		$tabsToArrange.unshift("headerTabFavorite")
	End if 
	If (OBJECT Get visible:C1075(*; "headerTabComment_title"))
		$tabsToArrange.unshift("headerTabComment")
	End if 
	If (OBJECT Get visible:C1075(*; "headerTabEvent_title"))
		$tabsToArrange.unshift("headerTabEvent")
	End if 
	
	OBJECT GET COORDINATES:C663(*; "bkgd_topBar"; $g_bkgd_topBar; $h_bkgd_topBar; $d_bkgd_topBar; $b_bkgd_topBar)
	$d_bkgd_topBar-=5
	$horizontalGap:=3
	
	$i:=-1
	For each ($tabToArrange; $tabsToArrange)
		$i+=1
		OBJECT GET COORDINATES:C663(*; $tabToArrange+"_bkgdtop"; $g; $h; $d; $b)
		OBJECT SET COORDINATES:C1248(*; $tabToArrange+"_bkgdtop"; $d_bkgd_topBar-($d-$g); $h; $d_bkgd_topBar; $b)
		OBJECT GET COORDINATES:C663(*; $tabToArrange+"_title"; $g; $h; $d; $b)
		OBJECT SET COORDINATES:C1248(*; $tabToArrange+"_title"; $d_bkgd_topBar-($d-$g)-9; $h; $d_bkgd_topBar-9; $b)
		OBJECT GET COORDINATES:C663(*; $tabToArrange+"_picto"; $g; $h; $d; $b)
		OBJECT SET COORDINATES:C1248(*; $tabToArrange+"_picto"; $d_bkgd_topBar-($d-$g)-119; $h; $d_bkgd_topBar-119; $b)
		OBJECT GET COORDINATES:C663(*; $tabToArrange+"_bkgdbottom"; $g; $h; $d; $b)
		OBJECT SET COORDINATES:C1248(*; $tabToArrange+"_bkgdbottom"; $d_bkgd_topBar-($d-$g); $h; $d_bkgd_topBar; $b)
		$d_bkgd_topBar:=$d_bkgd_topBar-($d-$g)-$horizontalGap
	End for each 
	
	
	//Mark:- Button execution
	
Function bItemCancel($option : Text)
	var $callbackBeforeCancel : Text
	
	$callbackBeforeCancel:=Form:C1466.sfw.entry.dataclass+"_beforeCancel"
	If (Form:C1466.sfw.methodExist($callbackBeforeCancel))
		EXECUTE METHOD:C1007($callbackBeforeCancel; *; Form:C1466.subForm)
	End if 
	
	If ($option="DontRestartTransaction")
		This:C1470.cancelTransaction()
	Else 
		This:C1470.cancelAndRestartTransaction()
	End if 
	Form:C1466.subForm.previousItemUUID:=""
	Form:C1466.current_item.reload()
	Form:C1466.current_clone:=Form:C1466.current_item.clone()
	This:C1470.callbackOnCurrentItem("itemReload")
	
	Form:C1466.subForm.calculation:=New object:C1471
	Form:C1466.subForm:=Form:C1466.subForm
	Form:C1466.sfw.lb_items:=Form:C1466.sfw.lb_items
	
Function bItemCreate()
	var $newEntity : Variant
	var $callbackBeforeSave : Text
	var $callbackSave : Text
	var $indexInEntitySelection : Integer
	
	If (Form:C1466.current_item.UUID=Null:C1517)
		Form:C1466.current_item.UUID:=Generate UUID:C1066
	End if 
	
	$callbackBeforeSave:=Form:C1466.sfw.entry.dataclass+"_beforeSave"
	If (Form:C1466.sfw.methodExist($callbackBeforeSave))
		EXECUTE METHOD:C1007($callbackBeforeSave; *; Form:C1466.subForm)
	End if 
	
	$callbackSave:=Form:C1466.sfw.entry.dataclass+"_create"
	If (Form:C1466.current_item.UUID="")
		Form:C1466.current_item.UUID:=Generate UUID:C1066
	End if 
	If (Form:C1466.sfw.methodExist($callbackSave))
		EXECUTE METHOD:C1007($callbackSave; $newEntity; OB Copy:C1225(Form:C1466.current_item))
	Else 
		//$newEntity:=ds[Form.sfw.entry.dataclass].new()
		//$newEntity.fromObject(Form.current_item)
		//$newEntity.save()
		This:C1470.callbackOnCurrentItem("beforeSaveCreation")
		$info:=Form:C1466.current_item.save()
	End if 
	$eventType:=(Form:C1466.situation.mode="duplicate") ? "duplicateRecord" : "createRecord"
	cs:C1710.sfw_eventManager.me.addEvent(Form:C1466.sfw.entry; $eventType; Form:C1466.current_item.UUID)
	This:C1470.callbackOnCurrentItem("afterCreation")
	This:C1470.validateTransaction()
	
	Form:C1466.subForm.calculation:=New object:C1471
	Form:C1466.subForm:=Form:C1466.subForm
	$newEntity:=ds:C1482[Form:C1466.sfw.entry.dataclass].get(Form:C1466.current_item.UUID)
	If (Form:C1466.sfw.lb_items#Null:C1517)
		Try
			Form:C1466.sfw.lb_items:=Form:C1466.sfw.lb_items.copy().add($newEntity)
			Form:C1466.sfw.lb_items_sort()
		Catch
			Form:C1466.sfw.lb_items_search()
		End try
		$indexInEntitySelection:=$newEntity.indexOf(Form:C1466.sfw.lb_items)
		Form:C1466.sfw.lb_items:=Form:C1466.sfw.lb_items
		LISTBOX SELECT ROW:C912(*; "lb_items"; $indexInEntitySelection+1; lk replace selection:K53:1)
		Form:C1466.current_item:=Form:C1466.sfw.lb_items[$indexInEntitySelection]
		Form:C1466.situation.mode:="Modify"  //when we save a new item, we continue with the modify mode
		Form:C1466.sfw.lb_items_selectionChange()
	End if 
	Form:C1466.situation.mode:="Modify"  //when we save a new item, we continue with the modify mode
	Form:C1466.sfw.drawButtons()
	
Function bItemDelete()
	$ok:=cs:C1710.sfw_dialog.me.confirm(\
		ds:C1482.sfw_readXliff("deletion.message"; "Do you really want to delete this item?"); \
		ds:C1482.sfw_readXliff("deletion.button.delete"; "Delete"); \
		ds:C1482.sfw_readXliff("deletion.button.keep"; "Keep"))
	
	If ($ok)
		//$indexInEntitySelection:=Form.current_item.indexOf(form.sfw.lb_items)
		
		
		Case of 
			: (OB Class:C1730(Form:C1466.sfw).name="sfw_item")
				$info:=Form:C1466.current_item.drop()
				Form:C1466.current_clone:=Null:C1517
				This:C1470.validateTransaction()
				ACCEPT:C269
			Else 
				This:C1470.callbackOnCurrentItem("beforeDelete")
				Form:C1466.sfw.lb_items:=Form:C1466.sfw.lb_items.minus(Form:C1466.current_item)
				$info:=Form:C1466.current_item.drop()
				This:C1470.validateTransaction()
				Form:C1466.situation.mode:="view"
				Form:C1466.current_item:=Null:C1517
				Form:C1466.current_clone:=Null:C1517
				Form:C1466.subForm.calculation:=New object:C1471
				Form:C1466.subForm:=Form:C1466.subForm
				Form:C1466.sfw.lb_items_sort()
				Form:C1466.sfw.lb_items_selectionChange()
				Form:C1466.sfw.drawButtons()
		End case 
	End if 
	
Function bItemReload()
	Form:C1466.subForm.calculation:=New object:C1471
	Form:C1466.subForm:=Form:C1466.subForm
	
	Form:C1466.info:=Form:C1466.current_item.reload()
	This:C1470.callbackOnCurrentItem("itemReload")
	
Function bItemRenounce()
	Form:C1466.situation.mode:="view"
	Form:C1466.current_item:=Null:C1517
	Form:C1466.current_clone:=Null:C1517
	Form:C1466.subForm.calculation:=New object:C1471
	Form:C1466.subForm:=Form:C1466.subForm
	This:C1470.cancelTransaction()
	Form:C1466.sfw.lb_items_selectionChange()
	
Function bItemSave($option : Text)
	var $callbackBeforeSave : Text
	
	$callbackBeforeSave:=Form:C1466.sfw.entry.dataclass+"_beforeSave"
	If (Form:C1466.sfw.methodExist($callbackBeforeSave))
		EXECUTE METHOD:C1007($callbackBeforeSave; *; Form:C1466.subForm)
	End if 
	This:C1470.callbackOnCurrentItem("beforeSave")
	Form:C1466.info:=Form:C1466.current_item.save()
	
	If (Form:C1466.sfw.entry.event#Null:C1517)
		$moreData:=New object:C1471
		If (Form:C1466.sfw.entry.event#Null:C1517) && (Form:C1466.sfw.entry.event.attributesToTrackInModificationEvent.length>0)
			$diffs:=Form:C1466.current_clone.diff(Form:C1466.current_item; Form:C1466.sfw.entry.event.attributesToTrackInModificationEvent)
			If ($diffs.length>0)
				$moreData.modifiedFields:=$moreData.modifiedFields || New object:C1471
				For each ($diff; $diffs)
					$moreData.modifiedFields[$diff.attributeName]:={old: $diff.value; new: $diff.otherValue}
				End for each 
			End if 
		End if 
		If (Form:C1466.sfw.entry.event#Null:C1517) && (Form:C1466.sfw.entry.event.attributeStmpToTrackInModificationEvent.length>0)
			$attributesToDiff:=Form:C1466.sfw.entry.event.attributeStmpToTrackInModificationEvent.extract("attribute")
			$diffs:=Form:C1466.current_clone.diff(Form:C1466.current_item; $attributesToDiff)
			If ($diffs.length>0)
				$moreData.modifiedFields:=$moreData.modifiedFields || New object:C1471
				For each ($diff; $diffs)
					$attributes:=Form:C1466.sfw.entry.event.attributeStmpToTrackInModificationEvent.query("attribute =:1"; $diff.attributeName)
					For each ($attribute; $attributes)
						Case of 
							: ($attribute.type=Is date:K8:7)
								$oldDate:=cs:C1710.sfw_stmp.me.getDate(Form:C1466.current_clone[$attribute.attribute])
								$newDate:=cs:C1710.sfw_stmp.me.getDate(Form:C1466.current_item[$attribute.attribute])
								If ($oldDate#$newDate)
									$moreData.modifiedFields[$attribute.name]:={old: $oldDate; new: $newDate}
								End if 
							: ($attribute.type=Is time:K8:8)
								$oldTime:=String:C10(cs:C1710.sfw_stmp.me.getTime(Form:C1466.current_clone[$attribute.attribute]); HH MM SS:K7:1)
								$newTime:=String:C10(cs:C1710.sfw_stmp.me.getTime(Form:C1466.current_item[$attribute.attribute]); HH MM SS:K7:1)
								If ($oldTime#$newTime)
									$moreData.modifiedFields[$attribute.name]:={old: $oldTime; new: $newTime}
								End if 
						End case 
					End for each 
				End for each 
			End if 
		End if 
		If (Form:C1466.sfw.entry.event#Null:C1517) && (Form:C1466.sfw.entry.event.linksManyToOneToTrackInModificationEvent.length>0)
			$attributesToDiff:=Form:C1466.sfw.entry.event.linksManyToOneToTrackInModificationEvent.extract("attributeForLink")
			$diffs:=Form:C1466.current_clone.diff(Form:C1466.current_item; $attributesToDiff)
			If ($diffs.length>0)
				$moreData.modifiedFields:=$moreData.modifiedFields || New object:C1471
				For each ($diff; $diffs)
					$link:=Form:C1466.sfw.entry.event.linksManyToOneToTrackInModificationEvent.query("attributeForLink =:1"; $diff.attributeName).first()
					$linkToFollowParts:=Split string:C1554($link.linkToFollow; ".")
					$finalAttribute:=$linkToFollowParts.pop()
					$source:=Form:C1466.current_clone
					For each ($part; $linkToFollowParts)
						$source:=$source[$part]
					End for each 
					$old:=$source[$finalAttribute]
					$source:=Form:C1466.current_item
					For each ($part; $linkToFollowParts)
						$source:=$source[$part]
					End for each 
					$new:=$source[$finalAttribute]
					$moreData.modifiedFields[$link.name]:={old: $old; new: $new}
				End for each 
			End if 
		End if 
		If (Bool:C1537(Form:C1466.sfw.entry.event.dontCreateModifyEventIfNoTrackingAttribute)) && ($moreData.modifiedFields=Null:C1517)
		Else 
			cs:C1710.sfw_eventManager.me.addEvent(Form:C1466.sfw.entry; "modifRecord"; Form:C1466.current_item.UUID; $moreData)
		End if 
		cs:C1710.sfw_eventManager.me._displayHeaderTabEvent()
		cs:C1710.sfw_eventManager.me.refresh(Form:C1466.current_item.UUID; Form:C1466.sfw.entry)
	Else 
		cs:C1710.sfw_eventManager.me.hide()
	End if 
	
	This:C1470.callbackOnCurrentItem("afterSave")
	If ($option="DontRestartTransaction")
		This:C1470.validateTransaction()
	Else 
		This:C1470.validateAndRestartTransaction()
	End if 
	Form:C1466.current_item.reload()  //necessary to refresh the related entities
	Form:C1466.current_clone:=Form:C1466.current_item.clone()
	This:C1470.callbackOnCurrentItem("itemReload")
	
	Form:C1466.sfw.drawButtons()
	cs:C1710.sfw_notificationManager.me.updateNodifications()
	
	Form:C1466.subForm.calculation:=New object:C1471
	Form:C1466.subForm:=Form:C1466.subForm
	
Function bItemAction()
	$authorizedProfiles:=cs:C1710.sfw_userManager.me.authorizedProfiles
	
	$refMenu:=Create menu:C408
	For each ($action; Form:C1466.sfw.entry.itemActions)
		If ($action.allowedProfiles#Null:C1517) && ($action.allowedProfiles.length>0)
			$actionAllowed:=False:C215
			For each ($authorizedProfile; $authorizedProfiles)
				$actionAllowed:=$actionAllowed || ($action.allowedProfiles.indexOf($authorizedProfile)#-1)
			End for each 
		Else 
			$actionAllowed:=True:C214
		End if 
		If ($actionAllowed)
			APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff($action.xliff; $action.label))
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; $action.method)
			If ($action.activateIf#Null:C1517)
				$result:=Formula from string:C1601($action.activateIf).call()
				If ($result=False:C215)
					DISABLE MENU ITEM:C150($refMenu; -1)
				End if 
			End if 
		End if 
	End for each 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	RELEASE MENU:C978($refMenu)
	
	
	If ($choose#"")
		If (ds:C1482[Form:C1466.sfw.entry.dataclass][$choose]#Null:C1517)
			ds:C1482[Form:C1466.sfw.entry.dataclass][$choose].call()
		Else 
			ARRAY TEXT:C222($_names; 0)
			METHOD GET NAMES:C1166($_names)
			If (Find in array:C230($_names; $choose)>0)
				EXECUTE METHOD:C1007($choose)
			End if 
		End if 
	End if 
	
Function bItemListAction()
	$authorizedProfiles:=cs:C1710.sfw_userManager.me.authorizedProfiles
	$refMenus:=New collection:C1472
	$refMenu:=This:C1470._buildMenuAction($refMenus)
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	For each ($refMenu; $refMenus)
		RELEASE MENU:C978($refMenu)
	End for each 
	
	This:C1470._executeMenuAction($choose)
	
	
Function _buildMenuAction($refMenus : Collection)->$refMenu : Text
	$authorizedProfiles:=cs:C1710.sfw_userManager.me.authorizedProfiles
	$refMenu:=Create menu:C408
	$refMenus.push($refMenu)
	$a:=-1
	For each ($action; Form:C1466.sfw.entry.itemListActions)
		$a+=1
		If ($action.allowedProfiles#Null:C1517) && ($action.allowedProfiles.length>0)
			$actionAllowed:=False:C215
			For each ($authorizedProfile; $authorizedProfiles)
				$actionAllowed:=$actionAllowed || ($action.allowedProfiles.indexOf($authorizedProfile)#-1)
			End for each 
		Else 
			$actionAllowed:=True:C214
		End if 
		If ($actionAllowed)
			APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff($action.xliff; $action.label))
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "action:"+String:C10($a))
			SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/action-24x24.png")
		End if 
	End for each 
	
Function _executeMenuAction($choose : Text)
	Case of 
		: ($choose="")
		: ($choose="action:@")
			$actionNum:=Num:C11(Substring:C12($choose; 8))
			$action:=Form:C1466.sfw.entry.itemListActions[$actionNum]
			Case of 
				: ($action.method#Null:C1517)
					ARRAY TEXT:C222($_names; 0)
					METHOD GET NAMES:C1166($_names)
					If (Find in array:C230($_names; $action.method)>0)
						EXECUTE METHOD:C1007($action.method)
					End if 
					
				: ($action.preconfigAction#Null:C1517)
					Case of 
						: ($action.preconfigAction="exportReferenceRecords")
							This:C1470._exportReferenceRecords()
							
						: ($action.preconfigAction="importReferenceRecords")
							This:C1470._importReferenceRecords()
							
						: ($action.preconfigAction="copyItemsListToPasteboard")
							This:C1470._copyItemsListToPasteboad()
							
					End case 
					
			End case 
	End case 
	
	
Function bItemListProjection()
	$refMenus:=New collection:C1472
	$refMenu:=This:C1470._buildMenuProjection($refMenus)
	
	
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	For each ($refMenu; $refMenus)
		RELEASE MENU:C978($refMenu)
	End for each 
	
	This:C1470._executeMenuProjection($choose)
	
Function _buildMenuProjection($refMenus : Collection)->$refMenu : Text
	var $esFavorites : cs:C1710.sfw_FavoriteSelection
	If (Form:C1466.sfw.entry.allowFavorite)
		$esFavorites:=cs:C1710.sfw_favoriteManager.me.getFavorites(Form:C1466.sfw.entry.ident)
	End if 
	$refMenu:=Create menu:C408
	$refMenus.push($refMenu)
	$a:=-1
	For each ($projection; Form:C1466.sfw.entry.itemListProjections)
		$a+=1
		$refSubMenu:=Create menu:C408
		$refMenus.push($refSubMenu)
		
		APPEND MENU ITEM:C411($refSubMenu; ds:C1482.sfw_readXliff("projection.fromTheList"; "From the list..."); *)  //XLIFF OK
		SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "projection:"+String:C10($a)+":all")
		
		If (LISTBOX Get property:C917(*; "lb_items"; lk selection mode:K53:35)=lk multiple:K53:59)
			If (Form:C1466.current_lb_item_selected.length=1)
				APPEND MENU ITEM:C411($refSubMenu; ds:C1482.sfw_readXliff("projection.fromSelectedList"; "From the selected item..."); *)  //XLIFF OK
			Else 
				APPEND MENU ITEM:C411($refSubMenu; ds:C1482.sfw_readXliff("projection.fromSelectedList"; "From the selected item..."); *)  //XLIFF OK
			End if 
		Else 
			APPEND MENU ITEM:C411($refSubMenu; ds:C1482.sfw_readXliff("projection.fromSelectedList"; "From the selected item..."); *)  //XLIFF OK
		End if 
		SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "projection:"+String:C10($a)+":selected")
		If (Form:C1466.current_lb_item_selected.length=0)
			DISABLE MENU ITEM:C150($refSubMenu; -1)
		End if 
		APPEND MENU ITEM:C411($refSubMenu; "-")
		If (Form:C1466.sfw.entry.allowFavorite)
			APPEND MENU ITEM:C411($refSubMenu; ds:C1482.sfw_readXliff("projection.fromMyFavorites"; "From my favorites..."); *)  //XLIFF OK
			SET MENU ITEM PARAMETER:C1004($refSubMenu; -1; "projection:"+String:C10($a)+":favorites")
			If ($esFavorites.length=0)
				DISABLE MENU ITEM:C150($refSubMenu; -1)
			End if 
		End if 
		APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff($projection.xliff; $projection.label); $refSubMenu)
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; "projection:"+String:C10($a))
		SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/projection-24x24.png")
	End for each 
	
Function _executeMenuProjection($choose : Text)
	var $esFavorites : cs:C1710.sfw_FavoriteSelection
	Case of 
		: ($choose="")
		: ($choose="projection:@")
			$params:=Split string:C1554($choose; ":")
			$projection:=$params.shift()
			$a:=$params.shift()
			$selector:=$params.shift()
			$projection:=Form:C1466.sfw.entry.itemListProjections[Num:C11($choose)]
			Case of 
				: ($selector="all")
					$projectedItems:=Form:C1466.sfw.lb_items[$projection.function]()
				: ($selector="selected")
					$projectedItems:=Form:C1466.current_lb_item_selected[$projection.function]()
				: ($selector="favorites")
					If (Form:C1466.sfw.entry.allowFavorite)
						$esFavorites:=cs:C1710.sfw_favoriteManager.me.getFavorites(Form:C1466.sfw.entry.ident)
					End if 
					$projectedItems:=$esFavorites[$projection.function]()
			End case 
			$formData:=New object:C1471()
			$formData.sfw:=cs:C1710.sfw_main.new()
			$formData.sfw.vision:=cs:C1710.sfw_definition.me.getVisionByIdent($projection.visionIdent)
			$formData.sfw.entry:=cs:C1710.sfw_definition.me.getEntryByIdent($projection.entryIdent)
			$formData.projection:=New object:C1471
			$formData.projection.label:="<- "+Form:C1466.sfw.entry.label  //XLIFF
			$formData.projection.entitiesSelection:=$projectedItems
			$formData.window:=New object:C1471
			GET WINDOW RECT:C443($left; $top; $right; $bottom)
			$formData.window.left:=$left+50
			$formData.window.top:=$top+50
			$formData.sfw.openForm($formData)
	End case 
	
Function bItemListOutside()
	$refMenus:=New collection:C1472
	$refMenu:=Create menu:C408
	$refMenus.push($refMenu)
	
	$a:=-1
	For each ($outside; Form:C1466.sfw.entry.itemListOutsides)
		$a+=1
		APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff($outside.xliff; $outside.label))
		SET MENU ITEM PARAMETER:C1004($refMenu; -1; String:C10($a))
		SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/outside-24x24.png")
		
	End for each 
	
	$choose:=Dynamic pop up menu:C1006($refMenu)
	For each ($refMenu; $refMenus)
		RELEASE MENU:C978($refMenu)
	End for each 
	Case of 
		: ($choose="")
		: ($choose#"")
			$outside:=Form:C1466.sfw.entry.itemListOutsides[Num:C11($choose)]
			
	End case 
	
Function bIcon_entry()
	var $form : Text
	var $eFavorite : cs:C1710.sfw_FavoriteEntity
	Case of 
		: (Right click:C712)
			$refMenus:=New collection:C1472
			$refMenu:=Create menu:C408
			$refMenus.push($refMenu)
			
			APPEND MENU ITEM:C411($refMenu; "entry ident : "+Form:C1466.sfw.entry.ident; *)
			DISABLE MENU ITEM:C150($refMenu; -1)
			APPEND MENU ITEM:C411($refMenu; "-")
			
			APPEND MENU ITEM:C411($refMenu; "entry definition in class ("+Form:C1466.sfw.entry.dataclass+")"; *)
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--openFunctionDefinition")
			SET MENU ITEM ICON:C984($refMenu; -1; "file:sfw/image/menu/puzzle.png")
			
			APPEND MENU ITEM:C411($refMenu; "entry panel ("+Form:C1466.sfw.entry.panel.name+")"; *)
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--openEntryPanel")
			SET MENU ITEM ICON:C984($refMenu; -1; "file:sfw/image/menu/panel.png")
			
			If (cs:C1710[Form:C1466.sfw.entry.panel.name]#Null:C1517)
				$className:=Form:C1466.sfw.entry.panel.name
				$submenuFunctions:=Create menu:C408
				$refMenus.push($submenuFunctions)
				$memberFunctions:=OB Keys:C1719(cs:C1710[$className].__prototype).sort()
				APPEND MENU ITEM:C411($submenuFunctions; $className; *)
				SET MENU ITEM PARAMETER:C1004($submenuFunctions; -1; "--class:"+$className)
				SET MENU ITEM ICON:C984($submenuFunctions; -1; "file:sfw/image/menu/class.png")
				APPEND MENU ITEM:C411($submenuFunctions; "-")
				For each ($memberFunction; $memberFunctions)
					APPEND MENU ITEM:C411($submenuFunctions; $memberFunction; *)
					SET MENU ITEM PARAMETER:C1004($submenuFunctions; -1; "--class:"+$className+"/"+$memberFunction)
					Case of 
						: ($memberFunction="get @")
							SET MENU ITEM ICON:C984($submenuFunctions; -1; "file:sfw/image/menu/database--arrow.png")
						: ($memberFunction="set @")
							SET MENU ITEM ICON:C984($submenuFunctions; -1; "file:sfw/image/menu/database-import.png")
						: ($memberFunction="query @")
							SET MENU ITEM ICON:C984($submenuFunctions; -1; "file:sfw/image/menu/magnifier.png")
						: ($memberFunction="orderBy @")
							SET MENU ITEM ICON:C984($submenuFunctions; -1; "file:sfw/image/menu/sort.png")
						Else 
							SET MENU ITEM ICON:C984($submenuFunctions; -1; "file:sfw/image/menu/function.png")
					End case 
				End for each 
				APPEND MENU ITEM:C411($refMenu; "class panel ("+Form:C1466.sfw.entry.panel.name+")"; $submenuFunctions; *)
				SET MENU ITEM ICON:C984($refMenu; -1; "file:sfw/image/menu/class.png")
			End if 
			
			APPEND MENU ITEM:C411($refMenu; "-")
			APPEND MENU ITEM:C411($refMenu; "Classes extending dataclass"; *)
			DISABLE MENU ITEM:C150($refMenu; -1)
			$suffixes:=[""; "Entity"; "Selection"]
			For each ($suffixe; $suffixes)
				$className:=Form:C1466.sfw.entry.dataclass+$suffixe
				$memberFunctions:=OB Keys:C1719(cs:C1710[$className].__prototype).sort()
				$submenuFunctions:=Create menu:C408
				$refMenus.push($submenuFunctions)
				Case of 
					: ($suffixe="Entity")
						$callbacks:=cs:C1710.sfw_documentationEntityCallback.me.callbacks
					Else 
						$callbacks:=New collection:C1472
				End case 
				If ($memberFunctions.length>0)
					APPEND MENU ITEM:C411($submenuFunctions; $className; *)
					SET MENU ITEM PARAMETER:C1004($submenuFunctions; -1; "--class:"+$className)
					SET MENU ITEM ICON:C984($submenuFunctions; -1; "file:sfw/image/menu/extendDataclass.png")
					APPEND MENU ITEM:C411($submenuFunctions; "-")
					For each ($memberFunction; $memberFunctions)
						If ($callbacks.indices("title = :1"; $memberFunction).length=0)
							APPEND MENU ITEM:C411($submenuFunctions; $memberFunction; *)
							SET MENU ITEM PARAMETER:C1004($submenuFunctions; -1; "--class:"+$className+"/"+$memberFunction)
							Case of 
								: ($memberFunction="get @")
									SET MENU ITEM ICON:C984($submenuFunctions; -1; "file:sfw/image/menu/database--arrow.png")
								: ($memberFunction="set @")
									SET MENU ITEM ICON:C984($submenuFunctions; -1; "file:sfw/image/menu/database-import.png")
								: ($memberFunction="query @")
									SET MENU ITEM ICON:C984($submenuFunctions; -1; "file:sfw/image/menu/magnifier.png")
								: ($memberFunction="orderBy @")
									SET MENU ITEM ICON:C984($submenuFunctions; -1; "file:sfw/image/menu/sort.png")
								Else 
									SET MENU ITEM ICON:C984($submenuFunctions; -1; "file:sfw/image/menu/function.png")
							End case 
						End if 
					End for each 
					APPEND MENU ITEM:C411($submenuFunctions; "-")
					APPEND MENU ITEM:C411($submenuFunctions; "(callbacks")
					For each ($memberFunction; $memberFunctions)
						If ($callbacks.indices("title = :1"; $memberFunction).length>0)
							APPEND MENU ITEM:C411($submenuFunctions; $memberFunction; *)
							SET MENU ITEM PARAMETER:C1004($submenuFunctions; -1; "--class:"+$className+"/"+$memberFunction)
							SET MENU ITEM ICON:C984($submenuFunctions; -1; "file:sfw/image/menu/callback.png")
						End if 
					End for each 
				End if 
				APPEND MENU ITEM:C411($refMenu; $className; $submenuFunctions; *)
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--class:"+$className)
				SET MENU ITEM ICON:C984($refMenu; -1; "file:sfw/image/menu/extendDataclass.png")
				If (cs:C1710[$className]=Null:C1517) || ($memberFunctions.length=0)
					DISABLE MENU ITEM:C150($refMenu; -1)
				End if 
			End for each 
			
			APPEND MENU ITEM:C411($refMenu; "-")
			APPEND MENU ITEM:C411($refMenu; "Request log client"; *)
			DISABLE MENU ITEM:C150($refMenu; -1)
			APPEND MENU ITEM:C411($refMenu; "Start"; *)
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--reqLogStart")
			SET MENU ITEM ICON:C984($refMenu; -1; "file:sfw/image/menu/control-record.png")
			APPEND MENU ITEM:C411($refMenu; "Stop"; *)
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--reqLogStop")
			SET MENU ITEM ICON:C984($refMenu; -1; "file:sfw/image/menu/control-stop-square.png")
			APPEND MENU ITEM:C411($refMenu; "Open log folder"; *)
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--reqLogOpen")
			SET MENU ITEM ICON:C984($refMenu; -1; "file:sfw/image/menu/folder-horizontal-open.png")
			
			$choose:=Dynamic pop up menu:C1006($refMenu)
			For each ($refMenu; $refMenus)
				RELEASE MENU:C978($refMenu)
			End for each 
			
			Case of 
				: ($choose="")
				: ($choose="--openFunctionDefinition")
					$path:=Form:C1466.sfw.entry.dataclass+"/entryDefinition"
					METHOD OPEN PATH:C1213("[class]/"+$path)
					
				: ($choose="--openEntryPanel")
					$form:=Form:C1466.sfw.entry.panel.name
					FORM EDIT:C1749($form)
					
				: ($choose="--class:@")
					$class:=Substring:C12($choose; 9)
					METHOD OPEN PATH:C1213("[class]/"+$class)
					
				: ($choose="--reqLogStart")
					SET DATABASE PARAMETER:C642(28; 1)
				: ($choose="--reqLogStop")
					SET DATABASE PARAMETER:C642(28; 0)
				: ($choose="--reqLogOpen")
					SHOW ON DISK:C922(Folder:C1567(fk logs folder:K87:17).platformPath)
			End case 
			
			
		: (Not:C34(Right click:C712)) && (OB Class:C1730(Form:C1466.sfw).name="sfw_main")
			
			
			$refMenus:=New collection:C1472
			$refMenu:=Create menu:C408
			$refMenus.push($refMenu)
			
			$identFavoriteEntries:=ds:C1482.sfw_Favorite.getIdentFavoriteEntries()
			If ($identFavoriteEntries.indexOf(Form:C1466.sfw.entry.ident)=-1)
				APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("favorite.setAsFavoriteEntry"; "Set as favorite entry"); *)  //XLIFF OK
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "++entry:"+Form:C1466.sfw.entry.ident)
			Else 
				APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("favorite.unsetAsFavoriteEntry"; "Unset as favorite entry"); *)  //XLIFF OK
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--entry:"+Form:C1466.sfw.entry.ident)
			End if 
			
			APPEND MENU ITEM:C411($refMenu; "-")
			For each ($ident; $identFavoriteEntries)
				$entry:=cs:C1710.sfw_definition.me.getEntryByIdent($ident)
				APPEND MENU ITEM:C411($refMenu; $entry.label; *)
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--changeEntry:"+$entry.ident)
				If ($ident=Form:C1466.sfw.entry.ident)
					DISABLE MENU ITEM:C150($refMenu; -1)
				End if 
			End for each 
			
			If (cs:C1710.sfw_userManager.me.info.UUID=("00"*16))
				$esFavorites:=ds:C1482.sfw_Favorite.query("entryIdent = :1 and UUID_target # null"; Form:C1466.sfw.entry.ident)
			Else 
				$esFavorites:=ds:C1482.sfw_Favorite.query("entryIdent = :1 and UUID_User = :2 and UUID_target # null"; Form:C1466.sfw.entry.ident; cs:C1710.sfw_userManager.me.info.UUID)
			End if 
			APPEND MENU ITEM:C411($refMenu; "-")
			$uuids:=Form:C1466.sfw.lb_items.distinct("UUID")
			For each ($eFavorite; $esFavorites)
				$favoritesItem:=ds:C1482[Form:C1466.sfw.entry.dataclass].get($eFavorite.UUID_target)
				$label:=$favoritesItem.fullName || $favoritesItem.name || $favoritesItem.label || $favoritesItem.title
				APPEND MENU ITEM:C411($refMenu; $label; *)
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "--target:"+String:C10($eFavorite.UUID_target))
				SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/picto/star.png")
				If ($uuids.indexOf($favoritesItem.UUID)=-1)
					DISABLE MENU ITEM:C150($refMenu; -1)
				End if 
			End for each 
			
			OBJECT GET COORDINATES:C663(*; "bIcon_entry"; $g; $h; $d; $b)
			$choose:=Dynamic pop up menu:C1006($refMenu; ""; $g; $b)
			For each ($refMenu; $refMenus)
				RELEASE MENU:C978($refMenu)
			End for each 
			
			Case of 
				: ($choose="++entry:@")
					$relaunchTransaction:=False:C215
					If (In transaction:C397)
						SUSPEND TRANSACTION:C1385
						$relaunchTransaction:=True:C214
					End if 
					$eFavorite:=ds:C1482.sfw_Favorite.new()
					$eFavorite.UUID:=Generate UUID:C1066
					$eFavorite.UUID_target:=Null:C1517
					$eFavorite.UUID_User:=cs:C1710.sfw_userManager.me.info.UUID
					$eFavorite.stmp:=cs:C1710.sfw_stmp.me.now()
					$eFavorite.entryIdent:=Form:C1466.sfw.entry.ident
					$info:=$eFavorite.save()
					If ($relaunchTransaction)
						RESUME TRANSACTION:C1386
					End if 
				: ($choose="--entry:@")
					If (cs:C1710.sfw_userManager.me.info.UUID=("00"*16))
						$eFavorite:=ds:C1482.sfw_Favorite.query("UUID_target = null and entryIdent = :1"; Form:C1466.sfw.entry.ident).first()
					Else 
						$eFavorite:=ds:C1482.sfw_Favorite.query("UUID_target = null and UUID_User = :1 and entryIdent = :2"; cs:C1710.sfw_userManager.me.info.UUID; Form:C1466.sfw.entry.ident).first()
					End if 
					$relaunchTransaction:=False:C215
					If (In transaction:C397)
						SUSPEND TRANSACTION:C1385
						$relaunchTransaction:=True:C214
					End if 
					$info:=$eFavorite.drop()
					If ($relaunchTransaction)
						RESUME TRANSACTION:C1386
					End if 
					
				: ($choose="--changeEntry:@")
					$ident:=Split string:C1554($choose; ":").pop()
					If (Form:C1466.sfw.nothingToSave())
						Form:C1466.nextEntry:=$ident
						CANCEL:C270
					End if 
					
				: ($choose="--target:@")
					$uuidTargeted:=Split string:C1554($choose; ":").pop()
					$uuids:=Form:C1466.sfw.lb_items.extract("UUID")
					$index:=$uuids.indexOf($uuidTargeted)
					If ($index#-1)
						LISTBOX SELECT ROW:C912(*; "lb_items"; $index+1; lk replace selection:K53:1)
						OBJECT SET SCROLL POSITION:C906(*; "lb_items"; $index+1)
						Form:C1466.current_item:=Form:C1466.sfw.lb_items[$index]
						Form:C1466.sfw.lb_items_selectionChange()
					End if 
			End case 
			
	End case 
	
	
Function drawButtonPup($objectName : Text; $title : Text; $pathIcon : Text; $error : Boolean)
	If (This:C1470.checkIsInModification())
		If ($error)
			OBJECT SET FORMAT:C236(*; $objectName; $title+";#"+$pathIcon+";#sfw/image/skin/rainbow/icon/redBackground.png;3;1;1;4;0;0;0;0;0;1")
		Else 
			OBJECT SET FORMAT:C236(*; $objectName; $title+";#"+$pathIcon+";0;3;1;1;8;0;0;0;1;0;1")
		End if 
	Else 
		OBJECT SET FORMAT:C236(*; $objectName; $title+";#"+$pathIcon+";0;3;1;1;0;0;0;0;0;0;1")
	End if 
	
	
Function checkIsInModification()->$isInModification : Boolean
	If (Form:C1466.situation#Null:C1517)
		$isInModification:=((String:C10(Form:C1466.situation.mode)="modify") | (String:C10(Form:C1466.situation.mode)="add") | (String:C10(Form:C1466.situation.mode)="duplicate")) & (Bool:C1537(Form:C1466.notEditable)=False:C215)
	Else 
		$isInModification:=False:C215
	End if 
	
	
	//Mark:-Callback launchers
Function callbackOnCurrentItem($callback : Text; $current_item : 4D:C1709.Entity)
	If (Count parameters:C259=1)
		$current_item:=Form:C1466.current_item
	End if 
	If ($current_item[$callback]#Null:C1517)
		cs:C1710.sfw_tracker.me.internal("Run callback "+$callback)
		$current_item[$callback]()
	End if 
	
Function functionCallbackOnCurrentItem($callback : Text; $current_item : 4D:C1709.Entity; $defaultValue : Variant)->$return : Variant
	If (Count parameters:C259=1) || ($current_item=Null:C1517)
		$current_item:=Form:C1466.current_item
	End if 
	If ($current_item[$callback]#Null:C1517)
		cs:C1710.sfw_tracker.me.internal("Run function callback "+$callback)
		$return:=$current_item[$callback]()
	Else 
		If (Count parameters:C259>2)
			$return:=$defaultValue
		End if 
	End if 
	
Function callbackOnEntry($callback : Text)
	
	If (Form:C1466.sfw.entry.dataclass#Null:C1517) && (ds:C1482[Form:C1466.sfw.entry.dataclass][$callback]#Null:C1517)
		cs:C1710.sfw_tracker.me.internal("Run callback "+$callback)
		ds:C1482[Form:C1466.sfw.entry.dataclass][$callback]()
	End if 
	
	
	//Mark:-bMode Management
Function bMode()
	$authorizedProfiles:=cs:C1710.sfw_userManager.me.authorizedProfiles
	
	Case of 
		: (Form:C1466.sfw.entry.dataclass#Null:C1517)
			
			
			$somethingToSaveOrCancel:=(String:C10(Form:C1466.situation.changeToSaveOrCancel)#"")
			
			$refMenu:=Create menu:C408
			
			APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("crud.mode.visualization"; "Visualization"); *)
			SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/eye-24x24.png")
			SET MENU ITEM PARAMETER:C1004($refMenu; -1; "view")
			If (Form:C1466.situation.mode="View")
				SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
			End if 
			If (Form:C1466.situation.mode="none") | (Num:C11(Form:C1466.sfw.lb_items.length)=0) | ($somethingToSaveOrCancel)
				DISABLE MENU ITEM:C150($refMenu; -1)
			End if 
			
			If (Form:C1466.sfw.entry.allowedProfilesForModification#Null:C1517) && (Form:C1466.sfw.entry.allowedProfilesForModification.length>0)
				$modificationAllowed:=False:C215
				For each ($authorizedProfile; $authorizedProfiles)
					$modificationAllowed:=$modificationAllowed || (Form:C1466.sfw.entry.allowedProfilesForModification.indexOf($authorizedProfile)#-1)
				End for each 
			Else 
				$modificationAllowed:=True:C214
			End if 
			If ($modificationAllowed)
				APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("crud.mode.modification"; "Modification"); *)
				SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/edit-24x24.png")
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "modify")
				If (Form:C1466.situation.mode="modify")
					SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
				End if 
				If (Form:C1466.current_item=Null:C1517) || (Form:C1466.situation.mode="add") || (Form:C1466.situation.mode="duplicate") || (Form:C1466.situation.mode="none") || ($somethingToSaveOrCancel) || (Form:C1466.sfw.entry.modifiable=False:C215)
					DISABLE MENU ITEM:C150($refMenu; -1)
				End if 
			End if 
			
			If (Form:C1466.dialogName#"sfw_item")
				If (Form:C1466.sfw.entry.allowedProfilesForCreation#Null:C1517) && (Form:C1466.sfw.entry.allowedProfilesForCreation.length>0)
					$addAllowed:=False:C215
					For each ($authorizedProfile; $authorizedProfiles)
						$addAllowed:=$addAllowed || (Form:C1466.sfw.entry.allowedProfilesForCreation.indexOf($authorizedProfile)#-1)
					End for each 
				Else 
					$addAllowed:=True:C214
				End if 
				If ($addAllowed)
					APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("crud.mode.creation"; "Creation"); *)
					SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/add-24x24.png")
					SET MENU ITEM PARAMETER:C1004($refMenu; -1; "add")
					If (Form:C1466.situation.mode="add")
						SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
					End if 
					If ($somethingToSaveOrCancel) || (Form:C1466.sfw.entry.addable=False:C215)
						DISABLE MENU ITEM:C150($refMenu; -1)
					End if 
					
					If (Form:C1466.sfw.entry.specificAddModes#Null:C1517)
						For each ($specificAddMode; Form:C1466.sfw.entry.specificAddModes)
							APPEND MENU ITEM:C411($refMenu; $specificAddMode.label; *)
							SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/"+$specificAddMode.iconpath)
							SET MENU ITEM PARAMETER:C1004($refMenu; -1; "specificAdd:"+$specificAddMode.ident)
							If ($somethingToSaveOrCancel) || (Form:C1466.sfw.entry.addable=False:C215)
								DISABLE MENU ITEM:C150($refMenu; -1)
							End if 
						End for each 
					End if 
					
					If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.duplicateRecord#Null:C1517)
						APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("crud.mode.duplicate"; "Duplication"); *)  //XLIFF OK
						SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/duplicate-24x24.png")
						SET MENU ITEM PARAMETER:C1004($refMenu; -1; "duplicate")
						If (Form:C1466.situation.mode="duplicate")
							SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
						End if 
						If ($somethingToSaveOrCancel)
							DISABLE MENU ITEM:C150($refMenu; -1)
						End if 
					End if 
				End if 
			End if 
			
			If (Form:C1466.sfw.entry.allowedProfilesForDeletion#Null:C1517) && (Form:C1466.sfw.entry.allowedProfilesForDeletion.length>0)
				$deleteAllowed:=False:C215
				For each ($authorizedProfile; $authorizedProfiles)
					$deleteAllowed:=$deleteAllowed || (Form:C1466.sfw.entry.allowedProfilesForDeletion.indexOf($authorizedProfile)#-1)
				End for each 
			Else 
				$deleteAllowed:=True:C214
			End if 
			If ($deleteAllowed)
				$isDeletable:=This:C1470.functionCallbackOnCurrentItem("isDeletable"; Form:C1466.current_item; True:C214)
				APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("crud.mode.deletion"; "Deletion"); *)
				SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/trash-24x24.png")
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "delete")
				If (Form:C1466.situation.mode="delete")
					SET MENU ITEM MARK:C208($refMenu; -1; Char:C90(18))
				End if 
				If (Form:C1466.current_item=Null:C1517) || (Form:C1466.situation.mode="add") || (Form:C1466.situation.mode="duplicate") || (Form:C1466.situation.mode="none") || ($somethingToSaveOrCancel) || (Form:C1466.sfw.entry.deletable=False:C215) || ($isDeletable=False:C215)
					DISABLE MENU ITEM:C150($refMenu; -1)
				End if 
			End if 
			
			If (Form:C1466.dialogName="sfw_main") || (Form:C1466.dialogName="sfw_main_new")
				APPEND MENU ITEM:C411($refMenu; "-")  //XLIFF OK
				APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("crud.mode.openNewWindow"; "Open in a new window"); *)  //XLIFF OK
				SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/openWindow-24x24.png")
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "openWindow")
				If (Form:C1466.current_item=Null:C1517)
					DISABLE MENU ITEM:C150($refMenu; -1)
				End if 
			End if 
			
			If (Macintosh option down:C545 || Windows Alt down:C563)
				APPEND MENU ITEM:C411($refMenu; "-")  //XLIFF OK
				APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff("crud.mode.openSpider"; "Show related records"); *)  //XLIFF OK
				SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/spider-24x24.png")
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; "spider")
				If (Form:C1466.current_item=Null:C1517)
					DISABLE MENU ITEM:C150($refMenu; -1)
				End if 
			End if 
			
			
			$choose:=Dynamic pop up menu:C1006($refMenu)
			RELEASE MENU:C978($refMenu)
			
			If ($choose#"")
				This:C1470._change_bMode($choose)
				cs:C1710.sfw_tracker.me.mark("new mode:"+$choose)
			End if 
			
			
			
		: (Form:C1466.sfw.entry.virtual="collection")
			$refMenu:=Create menu:C408
			
			For each ($action; Form:C1466.current_item.itemActions)
				APPEND MENU ITEM:C411($refMenu; ds:C1482.sfw_readXliff($action.xliff; $action.label))
				SET MENU ITEM ICON:C984($refMenu; -1; "Path:/RESOURCES/sfw/image/skin/rainbow/icon/action-24x24.png")
				SET MENU ITEM PARAMETER:C1004($refMenu; -1; $action.method)
				
			End for each 
			
			$choose:=Dynamic pop up menu:C1006($refMenu)
			RELEASE MENU:C978($refMenu)
			
			If ($choose#"")
				ARRAY TEXT:C222($_names; 0)
				METHOD GET NAMES:C1166($_names)
				If (Find in array:C230($_names; $choose)>0)
					EXECUTE METHOD:C1007($choose)
				End if 
			End if 
			
	End case 
	
	
Function _change_bMode($choose : Text)
	This:C1470._displayBannerLockedRecord(New object:C1471)
	
	Case of 
		: ($choose="openWindow")
			$formData:=New object:C1471()
			$formData.sfw:=cs:C1710.sfw_item.new()
			$formData.sfw.vision:=Form:C1466.sfw.vision
			$formData.sfw.entry:=Form:C1466.sfw.entry
			$formData.current_item:=Form:C1466.current_item
			$formData.window:=New object:C1471
			GET WINDOW RECT:C443($left; $top; $right; $bottom)
			$formData.window.left:=$left+50
			$formData.window.top:=$top+50
			$formData.sfw.openForm($formData)
			
			
		: ($choose="spider")
			$formData:=New object:C1471()
			$formData.sfw:=cs:C1710.sfw_item.new()
			$formData.sfw.vision:=Form:C1466.sfw.vision
			$formData.sfw.entry:=Form:C1466.sfw.entry
			$formData.current_item:=Form:C1466.current_item
			$formData.wizard:=New object:C1471("panel"; "sfw_spiderWizard")
			$formData.window:=New object:C1471
			GET WINDOW RECT:C443($left; $top; $right; $bottom)
			$formData.window.left:=$left+50
			$formData.window.top:=$top+50
			$formData.sfw.openForm($formData)
			
		: ($choose="specificAdd:@")
			$identSpecificAdd:=Substring:C12($choose; 13)
			$specificAdd:=Form:C1466.sfw.entry.specificAddModes.query("ident = :1"; $identSpecificAdd).first()
			If ($specificAdd#Null:C1517)
				This:C1470._execute_specificAddMode($specificAdd)
			End if 
			
		Else 
			$previousMode:=Form:C1466.situation.mode
			Form:C1466.situation.mode:=$choose
			Form:C1466.subForm:=Form:C1466.subForm
			
			Form:C1466.sfw.lb_items:=Form:C1466.sfw.lb_items
			
			$reload:=False:C215
			Case of 
				: (Form:C1466.situation.mode="view")
					//mark:view
					//This._lockUpdate("")
					$reload:=($previousMode#Form:C1466.situation.mode)
					If ($previousMode="add") | ($previousMode="duplicate")
						$reload:=False:C215
						Form:C1466.current_item:=Null:C1517
						Form:C1466.sfw.lb_items_selectionChange()
						
					End if 
					This:C1470.cancelTransaction()
					
				: (Form:C1466.situation.mode="add")
					//mark:add
					This:C1470.cancelAndRestartTransaction()
					LISTBOX SELECT ROW:C912(*; "lb_items"; 0; lk remove from selection:K53:3)
					This:C1470._createANewEntity()
					
					
					This:C1470.callbackOnCurrentItem("loadAfterCreation")
					Form:C1466.sfw.lb_items_selectionChange()
					
				: (Form:C1466.situation.mode="duplicate")
					//mark:duplicate
					This:C1470.cancelAndRestartTransaction()
					LISTBOX SELECT ROW:C912(*; "lb_items"; 0; lk remove from selection:K53:3)
					
					Form:C1466.original_item:=Form:C1466.current_item
					Form:C1466.current_item:=ds:C1482[Form:C1466.sfw.entry.dataclass].new()
					
					$dataclassObject:=ds:C1482[Form:C1466.sfw.entry.dataclass]
					For each ($attributeName; $dataclassObject)
						$attribute:=$dataclassObject[$attributeName]
						If ($attribute.kind="storage")
							Case of 
								: ($attributeName="UUID") & ($attribute.type="string")
									Form:C1466.current_item[$attributeName]:=Generate UUID:C1066
								Else 
									Form:C1466.current_item[$attributeName]:=Form:C1466.original_item[$attributeName]
							End case 
						End if 
					End for each 
					
					This:C1470.callbackOnCurrentItem("duplicateRecord")
					Form:C1466.sfw.lb_items_selectionChange()
					OB REMOVE:C1226(Form:C1466; "original_item")
					
				: (Form:C1466.current_item=Null:C1517)
					Form:C1466.situation.mode:="view"
					This:C1470.cancelTransaction()
					
				: (Form:C1466.situation.mode="delete")
					//mark:delete
					$info:=Form:C1466.current_item.lock(dk reload if stamp changed:K85:15)
					If ($info.success=False:C215)
						Form:C1466.situation.mode:="view"
						$reload:=($previousMode#Form:C1466.situation.mode)
						This:C1470.cancelTransaction()
						This:C1470._displayBannerLockedRecord($info)
					Else 
						This:C1470.cancelAndRestartTransaction()
					End if 
					
				Else 
					//mark:modify
					
					$info:=Form:C1466.current_item.lock(dk reload if stamp changed:K85:15)
					If ($info.success=False:C215)
						Form:C1466.situation.mode:="view"
						$reload:=($previousMode#Form:C1466.situation.mode)
						This:C1470.cancelTransaction()
						This:C1470._displayBannerLockedRecord($info)
					Else 
						This:C1470.startTransaction()
					End if 
					
			End case 
			
			If ($reload)
				If (Form:C1466.current_item#Null:C1517)
					Form:C1466.current_item.reload()
					This:C1470.callbackOnCurrentItem("itemReload")
				End if 
			End if 
			Form:C1466.subForm.situation:=Form:C1466.situation
			Form:C1466.subForm:=Form:C1466.subForm
			Form:C1466.sfw.drawButtons()
	End case 
	
Function _displayBannerLockedRecord($info : Object)
	var $pict : Picture
	
	If ($info.lockInfo#Null:C1517)
		OBJECT SET VISIBLE:C603(*; "banner_lockedRecord"; True:C214)
		$bannerMessage:="Record locked by "+($info.lockInfo.user4d_alias || $info.lockInfo.user_name)
		
		$svg:=SVG_New(285; 184)
		$group:=SVG_New_group($svg; "locked")
		$rect:=SVG_New_rect($group; 0; 0; 500; 30; 0; 0; "black:50"; "orangered:50"; 1)
		$text:=SVG_New_text($group; $bannerMessage; 175; 7; "helvetica"; 10; Bold:K14:2; 3)
		SVG_SET_TRANSFORM_ROTATE($group; -30; 250; 20)
		SVG_SET_TRANSFORM_TRANSLATE($group; -50; 50)
		SVG EXPORT TO PICTURE:C1017($svg; $pict)
		SVG_CLEAR($svg)
	Else 
		OBJECT SET VISIBLE:C603(*; "banner_lockedRecord"; False:C215)
	End if 
	Form:C1466.bannerLockedRecord:=$pict
	
Function _createANewEntity()
	Form:C1466.current_item:=ds:C1482[Form:C1466.sfw.entry.dataclass].new()
	
	$dataclassObject:=ds:C1482[Form:C1466.sfw.entry.dataclass]
	For each ($attributeName; $dataclassObject)
		$attribute:=$dataclassObject[$attributeName]
		If ($attribute.kind="storage")
			Case of 
				: ($attributeName="UUID") & ($attribute.type="string")
					Form:C1466.current_item[$attributeName]:=Generate UUID:C1066
				: ($attribute.type="string")
					Form:C1466.current_item[$attributeName]:=""
				: ($attribute.type="object")
					Form:C1466.current_item[$attributeName]:=New object:C1471
				: ($attribute.type="number")
					Form:C1466.current_item[$attributeName]:=0
				: ($attribute.type="date")
					Form:C1466.current_item[$attributeName]:=!00-00-00!
				: ($attribute.type="time")
					Form:C1466.current_item[$attributeName]:=?00:00:00?
			End case 
		End if 
	End for each 
	
	
Function _execute_specificAddMode($specificAdd : Object)
	
	If (ds:C1482[Form:C1466.sfw.entry.dataclass][$specificAdd.memberFunction]#Null:C1517)
		Form:C1466.situation.mode:="add"
		This:C1470._lockUpdate("")
		This:C1470.cancelAndRestartTransaction()
		LISTBOX SELECT ROW:C912(*; "lb_items"; 0; lk remove from selection:K53:3)
		
		This:C1470._createANewEntity()
		
		$ok:=ds:C1482[Form:C1466.sfw.entry.dataclass][$specificAdd.memberFunction]()
		
		If ($ok)
			This:C1470.callbackOnCurrentItem("loadAfterCreation")
			Form:C1466.sfw.lb_items_selectionChange()
		Else 
			Form:C1466.current_item:=Null:C1517
			Form:C1466.situation.mode:="view"
			This:C1470.cancelTransaction()
		End if 
	End if 
	
	
	
	//Mark:-Locking
	
Function _lockByOther($uuid_param : Text)->$lockByOther : Boolean
	
	$process:=Current process:C322
	
	ARRAY LONGINT:C221($_refWindow; 0)
	WINDOW LIST:C442($_refWindow)
	$refWindows:=New collection:C1472()
	For ($i; 1; Size of array:C274($_refWindow))
		If (Window process:C446($_refWindow{$i})=$process)
			$refWindows.push($_refWindow{$i})
		End if 
	End for 
	
	
	If (Storage:C1525.lockByMyOwnWindow=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.lockByMyOwnWindow:=New shared object:C1526
		End use 
	End if 
	
	$lockByOther:=False:C215
	For each ($refWindow; $refWindows) Until ($lockByOther)
		$stringRefWindow:=String:C10($refWindow)
		$lockByOther:=(String:C10(Storage:C1525.lockByMyOwnWindow[$stringRefWindow])=$uuid_param)
	End for each 
	
Function _lockUpdate($uuid_param : Text)
	
	If (Storage:C1525.lockByMyOwnWindow=Null:C1517)
		Use (Storage:C1525)
			Storage:C1525.lockByMyOwnWindow:=New shared object:C1526
		End use 
	End if 
	
	$stringRefWindow:=String:C10(Current form window:C827)
	Use (Storage:C1525.lockByMyOwnWindow)
		Case of 
			: (Count parameters:C259=0)
				OB REMOVE:C1226(Storage:C1525.lockByMyOwnWindow; $stringRefWindow)
			: ($uuid_param="")
				OB REMOVE:C1226(Storage:C1525.lockByMyOwnWindow; $stringRefWindow)
			Else 
				Storage:C1525.lockByMyOwnWindow[$stringRefWindow]:=$uuid_param
		End case 
		
	End use 
	
	//mark:-Transactions Management
Function displayTransactionLevel()
	
	Form:C1466.transactionLevel:=Transaction level:C961
	$visible:=(This:C1470.entry.transaction#Null:C1517) && (Form:C1466.transactionLevel#0) && (cs:C1710.sfw_userManager.me.isDeveloper)
	OBJECT SET VISIBLE:C603(*; "transactionLevel@"; $visible)
	If ($visible)
		$fill:=(String:C10(Form:C1466.situation.changeToSaveOrCancel)#"") ? "red" : "lightgreen"
		//$fill:="red"
		OBJECT SET RGB COLORS:C628(*; "transactionLevel_bkgd@"; $fill; $fill)
		$help:=(Form:C1466.transactionStartStmp=0) ? "" : "Started:"+cs:C1710.sfw_stmp.me.getFullRelative(Form:C1466.transactionStartStmp)
		OBJECT SET HELP TIP:C1181(*; "transactionLevel"; $help)
	End if 
	
Function startTransaction()
	
	If (This:C1470.entry.transaction#Null:C1517)
		Form:C1466.transactionStartStmp:=cs:C1710.sfw_stmp.me.now()
		ds:C1482.startTransaction()
		This:C1470.displayTransactionLevel()
		cs:C1710.sfw_tracker.me.internal("Start transaction")
	End if 
	
	
Function validateTransaction()
	
	If (This:C1470.entry.transaction#Null:C1517) & (Transaction level:C961#0)
		ds:C1482.validateTransaction()
		Form:C1466.transactionStartStmp:=0
		This:C1470.displayTransactionLevel()
		cs:C1710.sfw_tracker.me.internal("Validate transaction")
	End if 
	
	
Function cancelTransaction()
	
	If (This:C1470.entry.transaction#Null:C1517) & (Transaction level:C961>0)
		ds:C1482.cancelTransaction()
		Form:C1466.transactionStartStmp:=0
		This:C1470.displayTransactionLevel()
		cs:C1710.sfw_tracker.me.internal("Cancel transaction")
	End if 
	
	
Function validateAndRestartTransaction()
	
	This:C1470.validateTransaction()
	This:C1470.startTransaction()
	
Function cancelAndRestartTransaction()
	This:C1470.cancelTransaction()
	This:C1470.startTransaction()
	
	
	//Mark:-preconfigActions
	
Function _exportReferenceRecords()
	var $eSetting : cs:C1710.sfw_SettingEntity
	var $identEntry : Text:=Form:C1466.sfw.entry.ident
	var $entity : 4D:C1709.Entity
	var $file : 4D:C1709.File
	var $info : Object
	var $wpBlob : 4D:C1709.Blob
	var $wpEncodedBlob : Text
	
	SUSPEND TRANSACTION:C1385
	$eSetting:=This:C1470._getSettingVersionReferenceRecords($identEntry)
	
	$file:=Folder:C1567(fk resources folder:K87:11).file(cs:C1710.sfw_definition.me.globalParameters.folders.projectResources+"/referenceRecords/"+$identEntry+".json")
	If ($file.exists)
		$previousExport:=JSON Parse:C1218($file.getText())
		$previousVersion:=$previousExport.version
		$currentVersion:=$eSetting.data.value
		Case of 
			: ($previousVersion<=$currentVersion)
				$eSetting.data.value+=1
				$eSetting.stmpLastModif:=cs:C1710.sfw_stmp.me.now()
				$info:=$eSetting.save()
			: ($previousVersion>$currentVersion)
				$eSetting.data.value:=$previousVersion+1
				$eSetting.stmpLastModif:=cs:C1710.sfw_stmp.me.now()
				$info:=$eSetting.save()
		End case 
	Else 
		$eSetting.data.value+=1
		$info:=$eSetting.save()
		
	End if 
	
	$export:=New object:C1471
	$export.ident:=$eSetting.ident
	$export.version:=$eSetting.data.value
	$export.stmp:=$eSetting.stmpLastModif
	$export.date:=Current date:C33
	$export.records:=New collection:C1472
	
	$dataclass:=Form:C1466.sfw.entry.dataclass
	For each ($entity; ds:C1482[$dataclass].all())
		$oEntity:=New object:C1471
		For each ($attribute; ds:C1482[$dataclass])
			If (ds:C1482[$dataclass][$attribute].fieldType=Is object:K8:27) && ($entity[$attribute]#Null:C1517) && (String:C10($entity[$attribute].title)="4D Write Pro New Document")
				WP EXPORT VARIABLE:C1319($entity[$attribute]; $wpBlob; wk 4wp:K81:4)
				BASE64 ENCODE:C895($wpBlob; $wpEncodedBlob)
				$oEntity[$attribute]:=$wpEncodedBlob
			Else 
				$oEntity[$attribute]:=$entity[$attribute]
			End if 
			
		End for each 
		$export.records.push($oEntity)
		
	End for each 
	
	If (Form:C1466.sfw.entry.linkedReferenceRecordsDataclasses#Null:C1517)
		For each ($link; Form:C1466.sfw.entry.linkedReferenceRecordsDataclasses)
			$entitiesSelection:=ds:C1482[Form:C1466.sfw.entry.dataclass].all()
			$segments:=Split string:C1554($link; ".")
			For each ($segment; $segments)
				$entitiesSelection:=$entitiesSelection[$segment]
			End for each 
			$dataclass:=$entitiesSelection.getDataClass().getInfo().name
			$export[$dataclass]:=New collection:C1472
			For each ($entity; $entitiesSelection)
				//$export[$dataclass].push($entity.toObject())
				$oEntity:=New object:C1471
				For each ($attribute; ds:C1482[$dataclass])
					If (ds:C1482[$dataclass][$attribute].fieldType=Is object:K8:27) && ($entity[$attribute]#Null:C1517) && (String:C10($entity[$attribute].title)="4D Write Pro New Document")
						WP EXPORT VARIABLE:C1319($entity[$attribute]; $wpBlob; wk 4wp:K81:4)
						BASE64 ENCODE:C895($wpBlob; $wpEncodedBlob)
						$oEntity[$attribute]:=$wpEncodedBlob
					Else 
						$oEntity[$attribute]:=$entity[$attribute]
					End if 
					
				End for each 
				$export[$dataclass].push($oEntity)
				
			End for each 
		End for each 
	End if 
	
	$json:=JSON Stringify:C1217($export; *)
	$file.setText($json)
	RESUME TRANSACTION:C1386
	cs:C1710.sfw_dialog.me.info(ds:C1482.sfw_readXliff("export.done"; "The export is done"))  //XLIFF OK
	SHOW ON DISK:C922($file.platformPath)
	
	
Function _importReferenceRecords()
	var $eSetting : cs:C1710.sfw_SettingEntity
	var $identEntry : Text:=Form:C1466.sfw.entry.ident
	var $file : 4D:C1709.File
	var $info : Object
	var $entity : 4D:C1709.Entity
	var $esToDrop : 4D:C1709.EntitySelection
	var $importedDataclasses : Collection:=New collection:C1472
	var $wpBlob : 4D:C1709.Blob
	var $wpEncodedBlob : Text
	
	SUSPEND TRANSACTION:C1385
	$eSetting:=This:C1470._getSettingVersionReferenceRecords($identEntry)
	
	$file:=Folder:C1567(fk resources folder:K87:11).file(cs:C1710.sfw_definition.me.globalParameters.folders.projectResources+"/referenceRecords/"+$identEntry+".json")
	If ($file.exists)
		$Import:=JSON Parse:C1218($file.getText())
		$importVersion:=$Import.version
		$currentVersion:=$eSetting.data.value
		$importToDo:=True:C214
		Case of 
			: ($importVersion<$currentVersion)
				$importToDo:=cs:C1710.sfw_dialog.me.confirm(ds:C1482.sfw_readXliff("import.bellowCurrentVersion"; "The version in the referenceRecords file is bellow the current version in this datafile"); ds:C1482.sfw_readXliff("import.buttonImport"; "Import"); ds:C1482.sfw_readXliff("import.buttonCancel"; "Cancel"))  //XLIFF OK
			: ($importVersion=$currentVersion)
				$importToDo:=cs:C1710.sfw_dialog.me.confirm(ds:C1482.sfw_readXliff("import.sameCurrentVersion"; "The version in the referenceRecords file seems the same than the current version in this datafile"); ds:C1482.sfw_readXliff("import.buttonImport"; "Import"); ds:C1482.sfw_readXliff("import.buttonCancel"; "Cancel"))  //XLIFF OK
		End case 
		
		If ($importToDo)
			$eSetting.data.value:=$importVersion
			$eSetting.stmpLastModif:=cs:C1710.sfw_stmp.me.now()
			$info:=$eSetting.save()
			
			$importedDataclasses.push(Form:C1466.sfw.entry.dataclass)
			
			$uuids:=New collection:C1472()
			For each ($item; $import.records)
				$UUID:=$item.UUID
				$entity:=ds:C1482[Form:C1466.sfw.entry.dataclass].get($UUID)
				If ($entity=Null:C1517)
					$entity:=ds:C1482[Form:C1466.sfw.entry.dataclass].new()
					$entity.UUID:=$UUID
				End if 
				For each ($attribut; ds:C1482[Form:C1466.sfw.entry.dataclass])
					If (ds:C1482[Form:C1466.sfw.entry.dataclass][$attribut].kind="storage")
						If ($item[$attribut]#Null:C1517)
							If (ds:C1482[Form:C1466.sfw.entry.dataclass][$attribut].fieldType=Is object:K8:27) && ($attribut="@WP") && (Value type:C1509($item[$attribut])=Is text:K8:3)
								BASE64 DECODE:C896($item[$attribut]; $wpBlob)
								$entity[$attribut]:=WP New:C1317($wpBlob)
							Else 
								$entity[$attribut]:=$item[$attribut]
							End if 
						End if 
					End if 
				End for each 
				$info:=$entity.save()
				$uuids.push($UUID)
			End for each 
			
			If (Form:C1466.sfw.entry.linkedReferenceRecordsDataclasses#Null:C1517)
				
				
				For each ($link; Form:C1466.sfw.entry.linkedReferenceRecordsDataclasses)
					$entitySelection:=ds:C1482[Form:C1466.sfw.entry.dataclass].query("UUID in :1"; $uuids)
					
					$segments:=Split string:C1554($link; ".")
					For each ($segment; $segments)
						$entitySelection:=$entitySelection[$segment]
					End for each 
					
					$dataclass:=$entitySelection.getDataClass().getInfo().name
					
					For each ($item; $import[$dataclass])
						$UUID:=$item.UUID
						$entity:=ds:C1482[$dataclass].get($UUID)
						If ($entity=Null:C1517)
							$entity:=ds:C1482[$dataclass].new()
							$entity.UUID:=$UUID
						End if 
						For each ($attribut; ds:C1482[$dataclass])
							If (ds:C1482[$dataclass][$attribut].kind="storage")
								If (ds:C1482[$dataclass][$attribut].fieldType=Is object:K8:27) && ($attribut="@WP")
									BASE64 DECODE:C896($item[$attribut]; $wpBlob)
									$entity[$attribut]:=WP New:C1317($wpBlob)
								Else 
									$entity[$attribut]:=$item[$attribut]
								End if 
							End if 
						End for each 
						$info:=$entity.save()
						//$uuids.push($UUID)
						
					End for each 
					
					$importedDataclasses.push($dataclass)
					
					
				End for each 
				
			End if 
			
			$confirmAnswered:=False:C215
			$drop:=False:C215
			
			$esToDrop:=ds:C1482[Form:C1466.sfw.entry.dataclass].query("not(UUID in :1)"; $uuids)
			Case of 
				: ($confirmAnswered) && (Not:C34($drop))
					
				: ($confirmAnswered) && ($drop)
					
				: ($confirmAnswered=False:C215) && ($esToDrop.length>0)
					$confirmAnswered:=True:C214
					cs:C1710.sfw_dialog.me.confirm(ds:C1482.sfw_readXliff("import.notPresent"; "Some records present in the datafile aren't present in the reference import file. What do you want to do?"); ds:C1482.sfw_readXliff("import.buttonKeep"; "Keep"); ds:C1482.sfw_readXliff("import.buttonDrop"; "Drop"))  //XLIFF OK
					$drop:=(ok=0)
					
				Else 
					
			End case 
			
			If ($drop)
				For each ($eToDrop; $esToDrop)
					This:C1470.callbackOnCurrentItem("beforeDelete"; $eToDrop)
					$info:=$eToDrop.drop()
				End for each 
			End if 
			
			cs:C1710.sfw_dialog.me.info(ds:C1482.sfw_readXliff("import.done"; "The import is done"))  //XLIFF OK
			Form:C1466.sfw.lb_items_search()
			
		End if 
		
	Else 
		cs:C1710.sfw_dialog.me.alert(ds:C1482.sfw_readXliff("import.fileNotExist"; "The referenceRecords file doesn't exist in the folder")+" "+Folder:C1567(fk resources folder:K87:11).folder(cs:C1710.sfw_definition.me.globalParameters.folders.projectResources+"/referenceRecords/").path)  //XLIFF OK
	End if 
	RESUME TRANSACTION:C1386
	
Function _copyItemsListToPasteboad()
	var $text : Text
	var $lines : Collection:=New collection:C1472
	var $eToDrop : 4D:C1709.Entity
	
	$text:=Form:C1466.sfw.view.lb_items.columns.extract("label").join("\t")
	$text+="\r"
	
	For each ($item; Form:C1466.sfw.lb_items)
		
		$itemCols:=New collection:C1472
		For each ($column; Form:C1466.sfw.view.lb_items.columns)
			Case of 
				: ($column.attribute="color@") && (Value type:C1509($item[$column.attribute])=Is picture:K8:10)
					$itemCols.push($item.color)
					
				: (Value type:C1509($item[$column.attribute])#Is picture:K8:10)
					$itemCols.push($item[$column.attribute])
					
			End case 
		End for each 
		$text+=$itemCols.join("\t")+"\r"
	End for each 
	SET TEXT TO PASTEBOARD:C523($text)
	
Function _getSettingVersionReferenceRecords($identEntry : Text)->$eSetting : cs:C1710.sfw_SettingEntity
	var $ident : Text
	var $info : Object
	
	$ident:="versionReferenceRecords_"+$identEntry
	$eSetting:=ds:C1482.sfw_Setting.query("ident = :1"; $ident).first()
	If ($eSetting=Null:C1517)
		$eSetting:=ds:C1482.sfw_Setting.new()
		$eSetting.ident:=$ident
		$eSetting.name:="version of reference records for "+Form:C1466.sfw.entry.dataclass
		$eSetting.data:=New object:C1471("type"; "versionReferenceRecords"; "hidden"; True:C214; "value"; 0)
		$eSetting.stmpLastModif:=cs:C1710.sfw_stmp.me.now()
		$info:=$eSetting.save()
	End if 
	
Function openInANewWindow($entity : 4D:C1709.Entity; $visionIdent : Text; $entryIdent : Text)
	If ($entity#Null:C1517)
		$formData:=New object:C1471()
		$formData.sfw:=cs:C1710.sfw_item.new()
		$formData.window:=New object:C1471
		GET WINDOW RECT:C443($left; $top; $right; $bottom)
		$formData.window.left:=$left+50
		$formData.window.top:=$top+50
		$formData.sfw.vision:=cs:C1710.sfw_definition.me.visions.query("ident = :1"; $visionIdent).first()
		$formData.sfw.entry:=cs:C1710.sfw_definition.me.entries.query("ident = :1"; $entryIdent).first()
		$formData.current_item:=$entity
		$formData.sfw.openForm($formData)
	End if 
	
	
	//Mark:-Function xxxPanelNeeded 
	
Function panelFormMethod()
	var $resetWidgetDesign : Boolean
	var $runValidationRules : Boolean
	
	$resetWidgetDesign:=False:C215
	$runValidationRules:=False:C215
	Case of 
		: (FORM Event:C1606.code=On Load:K2:1)
			$resetWidgetDesign:=True:C214
			$runValidationRules:=This:C1470.checkIsInModification()
			Form:C1466.canValidate:=True:C214
			Form:C1466.validationRulesPassedWithSuccess:=True:C214
			Form:C1466.validationRulesMessages:=New collection:C1472
			
			FORM GET OBJECTS:C898($_objectNames)
			Form:C1466.useAddressSubSubForm:=(Find in array:C230($_objectNames; "address_subsubform")>0)
			Form:C1466.useCommunicationSubSubForm:=(Find in array:C230($_objectNames; "communication_subform")>0)
			Form:C1466.usePageTab:=(Find in array:C230($_objectNames; "page_tab")>0)
			Form:C1466.useHTab:=(Find in array:C230($_objectNames; "hTabBar")>0)
			Form:C1466.useHeaderBkgd:=(Find in array:C230($_objectNames; "header_bkgd")>0)
			Form:C1466.useTabBar:=(Find in array:C230($_objectNames; "vTabBar_subform")>0)
			
			For each ($page; Form:C1466.sfw.entry.panel.pages)
				OBJECT SET TITLE:C194(*; "TextWidthCalculator"; $page.label)
				OBJECT GET BEST SIZE:C717(*; "TextWidthCalculator"; $bestWidth; $bestHeight)
				Use ($page)
					$page.width:=$bestWidth
				End use 
			End for each 
			If (Form:C1466.sfw.entry.panel.currentPage#Null:C1517)
				FORM GOTO PAGE:C247(Form:C1466.sfw.entry.panel.currentPage; *)
			End if 
			
			If (Form:C1466.useTabBar)
				If (Form:C1466.vTabBar=Null:C1517)
					Form:C1466.vTabBar:=New object:C1471
				End if 
				Form:C1466.vTabBar.buttons:=Form:C1466.sfw.entry.panel.pages
				Form:C1466.vTabBar.currentPage:=Form:C1466.sfw.entry.panel.currentPage
			End if 
			
			If (Form:C1466.calculation=Null:C1517)
				Form:C1466.calculation:=New object:C1471
			End if 
			
			If (Form:C1466.useHTab)
				Form:C1466.useHTab_current_page:=0
			End if 
			
		: (FORM Event:C1606.code=On Bound Variable Change:K2:52)
			$resetWidgetDesign:=True:C214
			$runValidationRules:=True:C214
			Form:C1466.canValidate:=True:C214
			Form:C1466.validationRulesPassedWithSuccess:=True:C214
			Form:C1466.validationRulesMessages:=New collection:C1472
			
		: (FORM Event:C1606.code=On Data Change:K2:15)
			$runValidationRules:=True:C214
			Form:C1466.canValidate:=True:C214
			Form:C1466.validationRulesPassedWithSuccess:=True:C214
			
		: (FORM Event:C1606.code=On Clicked:K2:4)
			$runValidationRules:=This:C1470.checkIsInModification()
			
		: (FORM Event:C1606.code=On Mouse Enter:K2:33)
			OBJECT SET VISIBLE:C603(*; "bEye_@"; False:C215)
			Case of 
				: (FORM Event:C1606.objectName="label_@")
					OBJECT SET VISIBLE:C603(*; "bEye_"+Substring:C12(FORM Event:C1606.objectName; 7); True:C214)
				: (FORM Event:C1606.objectName="bEye_@")
					OBJECT SET VISIBLE:C603(*; FORM Event:C1606.objectName; True:C214)
			End case 
		: (FORM Event:C1606.code=On Mouse Leave:K2:34) && (FORM Event:C1606.objectName#"bEye_@")
			OBJECT SET VISIBLE:C603(*; "bEye_@"; False:C215)
			
	End case 
	
	
	If ($resetWidgetDesign)
		$isInModification:=This:C1470.checkIsInModification()
		OBJECT SET ENTERABLE:C238(*; "@entryField@"; $isInModification)
		If ($isInModification)
			$runValidationRules:=True:C214
			OBJECT SET RGB COLORS:C628(*; "@entryField@"; "black"; Background color:K23:2)
			OBJECT SET BORDER STYLE:C1262(*; "@entryField@"; Border System:K42:33)
		Else 
			$runValidationRules:=False:C215
			OBJECT SET RGB COLORS:C628(*; "@entryField@"; 0x00333333; Background color none:K23:10)
			OBJECT SET BORDER STYLE:C1262(*; "@entryField@"; Border None:K42:27)
		End if 
	End if 
	
	
	If ($runValidationRules) & (Form:C1466.current_item#Null:C1517)
		If (Form:C1466.sfw.entry.validationRules#Null:C1517)
			Form:C1466.canValidate:=True:C214
			Form:C1466.validationRulesPassedWithSuccess:=True:C214
			Form:C1466.validationRulesMessages:=New collection:C1472
			OBJECT SET RGB COLORS:C628(*; "@entryField@"; "black"; Background color:K23:2)
			For each ($rule; Form:C1466.sfw.entry.validationRules)
				$success:=True:C214
				Case of 
					: ($rule.widget="") && ($rule.field="UUID_@")
						If ($rule.UUIDNotNull)
							Case of 
								: (Form:C1466.current_item[$rule.field]=Null:C1517)
									$success:=False:C215
								: (Form:C1466.current_item[$rule.field]="")
									$success:=False:C215
								: (Form:C1466.current_item[$rule.field]=("00"*16))
									$success:=False:C215
								: (Form:C1466.current_item[$rule.field]=("20"*16))
									$success:=False:C215
							End case 
						End if 
						
					Else 
						$type:=OB Get type:C1230(Form:C1466.current_item; $rule.field)
						If (Bool:C1537($rule.uppercase)) & ($type=Is text:K8:3) & (FORM Event:C1606.code=On Data Change:K2:15)
							If (Position:C15(Uppercase:C13(Form:C1466.current_item[$rule.field]); Form:C1466.current_item[$rule.field]; *)=0)
								Form:C1466.current_item[$rule.field]:=Uppercase:C13(Form:C1466.current_item[$rule.field])
							End if 
						End if 
						If (Bool:C1537($rule.lowercase)) & ($type=Is text:K8:3) & (FORM Event:C1606.code=On Data Change:K2:15)
							If (Position:C15(Lowercase:C14(Form:C1466.current_item[$rule.field]); Form:C1466.current_item[$rule.field]; *)=0)
								Form:C1466.current_item[$rule.field]:=Lowercase:C14(Form:C1466.current_item[$rule.field])
							End if 
						End if 
						If (Bool:C1537($rule.capitalize)) & ($type=Is text:K8:3) & (FORM Event:C1606.code=On Data Change:K2:15)
							If (Position:C15(cs:C1710.sfw_string.me.stringCapitalize(Form:C1466.current_item[$rule.field]); Form:C1466.current_item[$rule.field]; *)=0)
								Form:C1466.current_item[$rule.field]:=cs:C1710.sfw_string.me.stringCapitalize(Form:C1466.current_item[$rule.field])
							End if 
						End if 
						If (Bool:C1537($rule.trimSpace)) & ($type=Is text:K8:3) & (FORM Event:C1606.code=On Data Change:K2:15)
							If (Position:C15(cs:C1710.sfw_string.me.trimSpace(Form:C1466.current_item[$rule.field]); Form:C1466.current_item[$rule.field]; *)=0)
								Form:C1466.current_item[$rule.field]:=cs:C1710.sfw_string.me.trimSpace(Form:C1466.current_item[$rule.field])
							End if 
						End if 
						If (Bool:C1537($rule.mandatory))
							Case of 
								: ($type=Is text:K8:3)
									If (Form:C1466.current_item[$rule.field]="")
										$widget:=String:C10($rule.widget)
										OBJECT SET RGB COLORS:C628(*; $widget; "black"; 0x00FAA9AB)
										$success:=False:C215
									End if 
								: ($type=Is date:K8:7)
									If (Form:C1466.current_item[$rule.field]=!00-00-00!)
										$widget:=String:C10($rule.widget)
										OBJECT SET RGB COLORS:C628(*; $widget; "black"; 0x00FAA9AB)
										$success:=False:C215
									End if 
							End case 
						End if 
						
						If (Bool:C1537($rule.unique))
							// Form.current_item[$rule.field]
							$isUnique:=ds:C1482.sfw_checkValidationRuleUnique(Form:C1466.sfw.entry.dataclass; $rule.field; Form:C1466.current_item[$rule.field]; Form:C1466.current_item.UUID)
							If ($isUnique=False:C215)
								$widget:=String:C10($rule.widget)
								OBJECT SET RGB COLORS:C628(*; $widget; "black"; 0x00FAA9AB)
								$success:=False:C215
							End if 
						End if 
				End case 
				Form:C1466.canValidate:=Form:C1466.canValidate && $success
				Form:C1466.validationRulesPassedWithSuccess:=Form:C1466.validationRulesPassedWithSuccess && $success
				If (Not:C34($success)) && ($rule.message#Null:C1517)
					Form:C1466.validationRulesMessages.push($rule.message)
				End if 
			End for each 
		End if 
	End if 
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($width_subform; $height_subform)
	
	If (Bool:C1537(Form:C1466.useAddressSubSubForm))
		If (FORM Event:C1606.code=On Load:K2:1) | (FORM Event:C1606.code=On Bound Variable Change:K2:52)
			If (Form:C1466.addressSubForm=Null:C1517)
				Form:C1466.addressSubForm:=New object:C1471
			End if 
			If (Form:C1466.current_item#Null:C1517)
				If (Form:C1466.current_item.contactDetails#Null:C1517)
					Form:C1466.addressSubForm.contactDetails:=Form:C1466.current_item.contactDetails
				End if 
			End if 
			Form:C1466.addressSubForm.situation:=Form:C1466.situation
			Form:C1466.addressSubForm:=Form:C1466.addressSubForm
			OBJECT GET COORDINATES:C663(*; "address_subsubform"; $g; $h; $d; $b)
			OBJECT SET COORDINATES:C1248(*; "address_subsubform"; 5+(50*Num:C11(Bool:C1537(Form:C1466.useTabBar))); $h; $width_subform-5; $h+180)
		End if 
	End if 
	
	If (Form:C1466.useCommunicationSubSubForm)
		OBJECT GET COORDINATES:C663(*; "communication_subform"; $g; $h; $d; $b)
		OBJECT SET COORDINATES:C1248(*; "communication_subform"; 5+(50*Num:C11(Bool:C1537(Form:C1466.useTabBar))); $h; $width_subform-5; $height_subform-5)
	End if 
	
	If (Bool:C1537(Form:C1466.usePageTab))
		OBJECT GET COORDINATES:C663(*; "page_tab"; $g; $h; $d; $b)
		OBJECT SET COORDINATES:C1248(*; "page_tab"; 0; $h; $width_subform; $b)
		OBJECT SET COORDINATES:C1248(*; "line_tab"; 0; ($b+$h)/2; $width_subform; ($b+$h)/2)
	End if 
	
	If (Bool:C1537(Form:C1466.useHeaderBkgd))
		OBJECT GET COORDINATES:C663(*; "header_bkgd"; $g; $h; $d; $b)
		OBJECT SET COORDINATES:C1248(*; "header_bkgd"; 0; 0; $width_subform; $b)
	End if 
	
	If (Bool:C1537(Form:C1466.useTabBar))
		OBJECT GET COORDINATES:C663(*; "vTabBar_subform"; $g; $h; $d; $b)
		OBJECT SET COORDINATES:C1248(*; "vTabBar_subform"; 0; $h; $d; $height_subform)
	End if 
	
	If (Bool:C1537(Form:C1466.useHTab)) && (FORM Get current page:C276(*)#Form:C1466.useHTab_current_page)
		Form:C1466.useHTab_current_page:=FORM Get current page:C276(*)
		Form:C1466.sfw.drawHTab()
	End if 
	
	Form:C1466.sfw.redrawButtons()
	
	
Function updateOfPanelNeeded()->$updateNeeded : Boolean
	If (Form:C1466.current_item#Null:C1517)
		Form:C1466.previousItemUUID:=Form:C1466.previousItemUUID || ""
		If (Form:C1466.previousItemUUID#Form:C1466.current_item.UUID)
			Form:C1466.previousItemUUID:=Form:C1466.current_item.UUID
			$updateNeeded:=True:C214
		End if 
	End if 
	If ($updateNeeded)
		cs:C1710.sfw_tracker.me.internal("updateOfPanelNeeded")
	End if 
	
Function redrawAndSetVisibleInPanelNeeded()->$redrawNeeded : Boolean
	$redrawNeeded:=False:C215
	Case of 
		: (FORM Event:C1606.code=On Mouse Enter:K2:33)
		: (FORM Event:C1606.code=On Mouse Move:K2:35)
		: (FORM Event:C1606.code=On Mouse Leave:K2:34)
		Else 
			$redrawNeeded:=True:C214
	End case 
	
	If ($redrawNeeded)
		cs:C1710.sfw_tracker.me.internal("redrawAndSetVisibleInPanelNeeded")
	End if 
	
Function recalculationOfPanelPageNeeded()->$calcNeeded : Boolean
	
	Case of 
		: (Form:C1466.current_item=Null:C1517)
			
		: (FORM Event:C1606.code=On Load:K2:1)
			$calcNeeded:=True:C214
			
		: (FORM Event:C1606.code=On Display Detail:K2:22)
			
		: (FORM Event:C1606.code=On Bound Variable Change:K2:52)
			$calcNeeded:=True:C214
			
		: (FORM Event:C1606.code=On Page Change:K2:54)
			$calcNeeded:=True:C214
			
	End case 
	If ($calcNeeded)
		$continue:=True:C214
		For each ($panelPage; This:C1470.entry.panel.pages) While ($continue)
			If ($panelPage.page=FORM Get current page:C276(*)) && ($panelPage.dynamicSource#Null:C1517) && ($panelPage.dynamicSource._setDataSourceForDynamicPage#Null:C1517)
				$panelPage.dynamicSource._setDataSourceForDynamicPage()
			End if 
		End for each 
		
		cs:C1710.sfw_tracker.me.internal("recalculationOfPanelPageNeeded")
	End if 
	
	
Function displayItemPanel()
	var $folderForm : 4D:C1709.Folder
	var $formDefinition : Object
	var $file : 4D:C1709.File
	var $cacheFile : 4D:C1709.File
	var $blob : Blob
	var $key : Blob
	
	If (This:C1470.entry.panel.asDynamicSources)
		$folderForm:=Folder:C1567(fk database folder:K87:14).folder("Project/Sources/Forms/"+This:C1470.entry.panel.name)
		$file:=$folderForm.file("form.4DForm")
		$cacheFile:=Folder:C1567(fk resources folder:K87:11).file("DynamicForm/"+This:C1470.entry.panel.name+"form.4XForm")
		If ($file.exists)
			$formDefinition:=JSON Parse:C1218($file.getText())
			$formDefinition.method:=$folderForm.path+$formDefinition.method
			TEXT TO BLOB:C554(JSON Stringify:C1217($formDefinition); $blob; UTF8 text without length:K22:17)
			COMPRESS BLOB:C534($blob; Fast compression mode:K22:13)
			$cacheFile.setContent($blob)
		Else 
			$blob:=$cacheFile.getContent()
			EXPAND BLOB:C535($blob)
			$json:=BLOB to text:C555($blob; UTF8 text without length:K22:17)
			$formDefinition:=JSON Parse:C1218($json)
		End if 
		//refresh for object method paths
		If (123#123)
			//For each ($page; $formDefinition.pages)
			//$page:=$page || New object
			//$page.objects:=$page.objects || New object
			//For each ($objectName; $page.objects)
			//If ($page.objects[$objectName].method#Null) && ($page.objects[$objectName].method="ObjectMethods@")
			//$page.objects[$objectName].method:=$folderForm.path+$page.objects[$objectName].method
			//End if 
			//End for each 
			//End for each 
		End if 
		If (123=123)
			$offsetHorizontal:=0
			$offsetVertical:=0
			$definitions:=New collection:C1472($formDefinition)
			If ($formDefinition.inheritedForm#Null:C1517)
				$folderForm:=Folder:C1567(fk database folder:K87:14).folder("Project/Sources/Forms/"+$formDefinition.inheritedForm)
				$file:=$folderForm.file("form.4DForm")
				$cacheFile:=Folder:C1567(fk resources folder:K87:11).file("DynamicForm/"+$formDefinition.inheritedForm+"form.4XForm")
				If ($file.exists)
					$file:=$folderForm.file("form.4DForm")
					$definition:=JSON Parse:C1218($file.getText())
					$definitions.push($definition)
					TEXT TO BLOB:C554(JSON Stringify:C1217($definition); $blob; UTF8 text without length:K22:17)
					COMPRESS BLOB:C534($blob; Fast compression mode:K22:13)
					$cacheFile.setContent($blob)
				Else 
					$blob:=$cacheFile.getContent()
					EXPAND BLOB:C535($blob)
					$json:=BLOB to text:C555($blob; UTF8 text without length:K22:17)
					$definition:=JSON Parse:C1218($json)
					$definitions.push($definition)
				End if 
			End if 
			For each ($definition; $definitions)
				For each ($page; $definition.pages)
					$page:=$page || New object:C1471
					$page.objects:=$page.objects || New object:C1471
					For each ($objectName; $page.objects)
						$object:=$page.objects[$objectName]
						Case of 
							: ($objectName="header_bkgd")
								$offsetVertical:=$object.top+$object.height
							: ($objectName="vTabBar_subform")
								$offsetHorizontal:=$object.left+$object.width
						End case 
						Case of 
							: ($object.type="listbox")
								If ($object.method="ObjectMethods@")
									$object.method:="sfw_dynamicForm_script"
								End if 
								For each ($column; $page.objects[$objectName].columns)
									If ($column.method="ObjectMethods@")
										$column.method:="sfw_dynamicForm_script"
									End if 
								End for each 
							: ($object.method#Null:C1517)
								$object.method:="sfw_dynamicForm_script"
						End case 
						
					End for each 
				End for each 
			End for each 
		End if 
		
		For each ($panelPage; This:C1470.entry.panel.pages)
			If ($panelPage.dynamicSource#Null:C1517)
				If (123=123)
					If ($panelPage.page<$formDefinition.pages.length)
						$pageDefinition:=$formDefinition.pages[$panelPage.page]
						If ($pageDefinition=Null:C1517)
							$pageDefinition:=New object:C1471("objects"; New object:C1471)
							$formDefinition.pages[$panelPage.page]:=$pageDefinition
						End if 
					Else 
						$pageDefinition:=New object:C1471("objects"; New object:C1471)
						$formDefinition.pages[$panelPage.page]:=$pageDefinition
					End if 
				End if 
				
				$dynamicClass:=OB Class:C1730($panelPage.dynamicSource).name
				Case of 
					: ($dynamicClass="sfw_definitionPageListbox")
						$panelPage.dynamicSource._insertDynamicListbox($formDefinition; $panelPage; $offsetHorizontal; $offsetVertical)
						
					: ($dynamicClass="sfw_definitionPageDocuments")
						$panelPage.dynamicSource._insertDynamicDocumentsPage($formDefinition; $panelPage; $offsetHorizontal; $offsetVertical)
						
				End case 
			End if 
		End for each 
		
		$formDefinition.method:="sfw_dynamicForm_method"
		
		OBJECT SET SUBFORM:C1138(*; "detail_panel"; $formDefinition)
	Else 
		OBJECT SET SUBFORM:C1138(*; "detail_panel"; String:C10(This:C1470.entry.panel.name))
	End if 
	Form:C1466.lastPanelDisplayed:=String:C10(This:C1470.entry.panel.name)
	
	
	
	
	
Function dynamicPage_bAction()
	
	$bActionName:=FORM Event:C1606.objectName
	$ident:=Substring:C12($bActionName; 9)
	
	For each ($panelPage; This:C1470.entry.panel.pages)
		If ($panelPage.dynamicSource#Null:C1517)
			If ($panelPage.dynamicSource.ident=$ident)
				break
			End if 
		End if 
	End for each 
	
	If ($panelPage.dynamicSource._bAction#Null:C1517)
		$panelPage.dynamicSource._bAction()
	End if 
	
	
Function dynamicPage_hl_document()
	
	$hlName:=FORM Event:C1606.objectName
	$ident:=Substring:C12($hlName; 4)
	
	For each ($panelPage; This:C1470.entry.panel.pages)
		If ($panelPage.dynamicSource#Null:C1517)
			If ($panelPage.dynamicSource.ident=$ident)
				break
			End if 
		End if 
	End for each 
	
	If ($panelPage.dynamicSource._bAction#Null:C1517)
		$panelPage.dynamicSource._hl_document()
	End if 
	
	
Function dynamicPage_pupFilter()
	
	$pupFilterName:=FORM Event:C1606.objectName
	//$pageDefinition.objects["pupFilter_"+$dynamicSource.ident+"_"+$filter.ident]:=$bFilterproperties
	$pupFilterName:=Substring:C12($pupFilterName; 11)
	
	$continue:=True:C214
	For each ($panelPage; This:C1470.entry.panel.pages) While ($continue)
		If ($panelPage.dynamicSource#Null:C1517)
			If ($pupFilterName=($panelPage.dynamicSource.ident+"_@"))
				For each ($filter; $panelPage.dynamicSource.filters) While ($continue)
					If ($pupFilterName=($panelPage.dynamicSource.ident+"_"+$filter.ident))
						$panelPageToCall:=$panelPage
						$continue:=False:C215
					End if 
				End for each 
			End if 
		End if 
	End for each 
	
	$panelPageToCall.dynamicSource._pupFilter()
	
	
	
Function drawHTab()
	
	var $pict : Picture
	var $fonFamily : Text
	
	$svg:=SVG_New()
	If (Is macOS:C1572)
		$fonFamily:="Helvetica"
	Else 
		$fonFamily:="Calibri"
	End if 
	
	$authorizedProfiles:=cs:C1710.sfw_userManager.me.authorizedProfiles
	$hGutter:=2
	$hOffset:=$hGutter*2
	For each ($tab; Form:C1466.sfw.entry.panel.pages)
		If ($tab.allowedProfiles#Null:C1517) && ($tab.allowedProfiles.length>0)
			$tabAllowed:=False:C215
			For each ($authorizedProfile; $authorizedProfiles)
				$tabAllowed:=$tabAllowed || ($tab.allowedProfiles.indexOf($authorizedProfile)#-1)
			End for each 
		Else 
			$tabAllowed:=True:C214
		End if 
		If ($tabAllowed)
			//$button.page
			//$button.label
			If (FORM Get current page:C276(*)=$tab.page)
				$fill:="#458DE8"
				$stroke:="none"
				$top:=0
				$style:=Bold:K14:2
				$strokeText:="white"
				$hText:=5
			Else 
				$fill:="#B9D9FF"
				$stroke:="none"
				$top:=4
				$style:=Normal:K14:15
				$strokeText:="222222"
				$hText:=7
			End if 
			$withTab:=$tab.width+25  //20
			$rect:=SVG_New_rect($svg; $hOffset; $top; $withTab; 27; 5; 5; $stroke; $fill; 1)
			SVG_SET_ID($rect; "page:"+String:C10($tab.page))
			$text:=SVG_New_text($svg; $tab.label; $hOffset+($withTab/2); $hText; $fonFamily; 12; $style; Align center:K42:3; $strokeText)
			$hOffset+=$hGutter+$withTab
		End if 
	End for each 
	
	SVG EXPORT TO PICTURE:C1017($svg; $pict)
	SVG_CLEAR($svg)
	Form:C1466.hTabBar:=$pict
	
	
Function clicHTab()
	$id:=SVG Find element ID by coordinates:C1054(*; FORM Event:C1606.objectName; mouseX; mouseY)
	If ($id="page:@")
		FORM GOTO PAGE:C247(Num:C11(Substring:C12($id; 6)); *)
		//Form.sfw.drawHTab()
	End if 
	
	
	
	//MARK: - formObject functions
	
Function formObjectResizeGG( ...  : Variant)
	
	//C_VARIANT(${1})  //following object
	var $form_width; $form_height; $width_instruction; $height_instruction : Integer
	
	If (Value type:C1509($1)=Is collection:K8:32)
		$form_objects:=$1.copy()
		$reference_object:=$form_objects.shift()
	Else 
		$form_objects:=New collection:C1472
		$reference_object:=$1
	End if 
	For ($o; 2; Count parameters:C259; 1)
		If (Value type:C1509(${$o})=Is collection:K8:32)
			$form_objects:=$form_objects.concat(${$o})
		Else 
			$form_objects.push(${$o})
		End if 
	End for 
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($form_width; $form_height)
	
	ARRAY LONGINT:C221($_m; 0)
	$gap:=5
	$ppm:=Position:C15("#["; $reference_object; *)
	If ($ppm>0)
		$gap:=0
		$ppmf:=Position:C15("]"; $reference_object; $ppm+2; *)
		If ($ppmf>0)
			$instruction_pm:=Substring:C12($reference_object; $ppm+2; $ppmf-$ppm-2)
			$reference_object:=Delete string:C232($reference_object; $ppm; $ppmf-$ppm+1)
			Repeat 
				$pv:=Position:C15(","; $instruction_pm)
				If ($pv>0)
					APPEND TO ARRAY:C911($_m; Num:C11(Substring:C12($instruction_pm; 1; $pv-1)))
					$instruction_pm:=Substring:C12($instruction_pm; $pv+1)
				Else 
					APPEND TO ARRAY:C911($_m; Num:C11($instruction_pm))
				End if 
			Until ($pv=0)
			Case of 
				: (Size of array:C274($_m)=1)
					APPEND TO ARRAY:C911($_m; $_m{1})
					APPEND TO ARRAY:C911($_m; $_m{1})
					APPEND TO ARRAY:C911($_m; $_m{1})
				: (Size of array:C274($_m)=2)
					APPEND TO ARRAY:C911($_m; $_m{1})
					APPEND TO ARRAY:C911($_m; $_m{2})
				: (Size of array:C274($_m)=3)
					APPEND TO ARRAY:C911($_m; 0)
			End case 
		End if 
	End if 
	
	$ppc:=Position:C15("%["; $reference_object)
	Case of 
		: ($ppc>0)
			$ppcf:=Position:C15("]"; $reference_object; $ppc+2)
			If ($ppcf>0)
				$instruction_pc:=Substring:C12($reference_object; $ppc+2; $ppcf-$ppc-2)
				$reference_object:=Delete string:C232($reference_object; $ppc; $ppcf-$ppc+1)
				$pv:=Position:C15(","; $instruction_pc)
				If ($pv>0)
					$instruction_pch:=Substring:C12($instruction_pc; 1; $pv-1)
					$instruction_pcv:=Substring:C12($instruction_pc; $pv+1)
				Else 
					$instruction_pch:=$instruction_pc
					$instruction_pcv:=$instruction_pc
				End if 
				$pt:=Position:C15("-"; $instruction_pch)
				Case of 
					: ($pt=0)
						$width_instruction:=Num:C11($instruction_pch)
					: ($pt=1) & (Length:C16($instruction_pch)=1)
						$width_instruction:=100
					: ($pt=1)
						$left_instruction_pc:=0
						$right_instruction_pc:=Num:C11(Substring:C12($instruction_pch; 2))
						$width_instruction:=-1
					: ($pt=Length:C16($instruction_pch))
						$left_instruction_pc:=Num:C11(Substring:C12($instruction_pch; 1; $pt-1))
						$right_instruction_pc:=100
						$width_instruction:=-1
					Else 
						$left_instruction_pc:=Num:C11(Substring:C12($instruction_pch; 1; $pt-1))
						$right_instruction_pc:=Num:C11(Substring:C12($instruction_pch; $pt+1))
						$width_instruction:=-1
				End case 
				$pt:=Position:C15("-"; $instruction_pcv)
				Case of 
					: ($pt=0)
						$height_instruction:=Num:C11($instruction_pcv)
					: ($pt=1) & (Length:C16($instruction_pcv)=1)
						$height_instruction:=100
					: ($pt=1)
						$top_instruction_pc:=0
						$bottom_instruction_pc:=Num:C11(Substring:C12($instruction_pcv; 2))
						$height_instruction:=-1
					: ($pt=Length:C16($instruction_pcv))
						$top_instruction_pc:=Num:C11(Substring:C12($instruction_pcv; 1; $pt-1))
						$bottom_instruction_pc:=100
						$height_instruction:=-1
					Else 
						$top_instruction_pc:=Num:C11(Substring:C12($instruction_pcv; 1; $pt-1))
						$bottom_instruction_pc:=Num:C11(Substring:C12($instruction_pcv; $pt+1))
						$height_instruction:=-1
				End case 
			End if 
			OBJECT GET COORDINATES:C663(*; $reference_object; $g_ref; $h_ref; $d_ref; $b_ref)
			$g_ref_init:=$g_ref
			$h_ref_init:=$h_ref
			$d_ref_init:=$d_ref
			$b_ref_init:=$b_ref
			
			Case of 
				: ($width_instruction>0)
					$g_ref_new:=0
					$d_ref_new:=$form_width*$width_instruction/100
				: ($width_instruction=-1)
					$g_ref_new:=$form_width*$left_instruction_pc/100
					$d_ref_new:=$form_width*$right_instruction_pc/100
			End case 
			Case of 
				: ($height_instruction>0)
					$h_ref_new:=0
					$b_ref_new:=$form_height*$height_instruction/100
				: ($height_instruction=-1)
					$h_ref_new:=$form_height*$top_instruction_pc/100
					$b_ref_new:=$form_height*$bottom_instruction_pc/100
			End case 
			
			
		Else 
			OBJECT GET COORDINATES:C663(*; $reference_object; $g_ref; $h_ref; $d_ref; $b_ref)
			$g_ref_init:=$g_ref
			$h_ref_init:=$h_ref
			$d_ref_init:=$d_ref
			$b_ref_init:=$b_ref
			
			$g_ref_new:=$g_ref
			$h_ref_new:=$h_ref
			$d_ref_new:=$form_width-$gap
			$b_ref_new:=$form_height-$gap
	End case 
	
	If (Size of array:C274($_m)>0)
		$g_ref_new:=$g_ref_new+$_m{1}
		$h_ref_new:=$h_ref_new+$_m{2}
		$d_ref_new:=$d_ref_new-$_m{3}
		$b_ref_new:=$b_ref_new-$_m{4}
	End if 
	
	OBJECT SET COORDINATES:C1248(*; $reference_object; $g_ref_new; $h_ref_new; $d_ref_new; $b_ref_new)
	
	For each ($form_object; $form_objects)
		Case of 
			: ($form_object="M:@")
				$action:="move-move"
				$form_object:=Substring:C12($form_object; 3)
			: ($form_object="MM:@")
				$action:="move-move"
				$form_object:=Substring:C12($form_object; 4)
			: ($form_object="MG:@")
				$action:="move-grow"
				$form_object:=Substring:C12($form_object; 4)
			: ($form_object="GM:@")
				$action:="grow-move"
				$form_object:=Substring:C12($form_object; 4)
			: ($form_object="NG:@")
				$action:="none-grow"
				$form_object:=Substring:C12($form_object; 4)
			: ($form_object="GN:@")
				$action:="grow-none"
				$form_object:=Substring:C12($form_object; 4)
			: ($form_object="NM:@")
				$action:="none-move"
				$form_object:=Substring:C12($form_object; 4)
			: ($form_object="MN:@")
				$action:="move-none"
				$form_object:=Substring:C12($form_object; 4)
			: ($form_object="GG:@")
				$action:="grow-grow"
				$form_object:=Substring:C12($form_object; 4)
			: ($form_object="NN:@")
				$action:="none-none"
				$form_object:=Substring:C12($form_object; 4)
				
			Else 
				$action:="grow-grow"
		End case 
		
		OBJECT GET COORDINATES:C663(*; $form_object; $g2; $h2; $d2; $b2)
		
		Case of 
			: ($action="grow-@")
				$g2_new:=$g_ref_new+($g2-$g_ref_init)
				$d2_new:=$d_ref_new+($d2-$d_ref_init)
			: ($action="move-@")
				$g2_new:=$d_ref_new-($d_ref_init-$g2)
				$d2_new:=$d_ref_new-($d_ref_init-$d2)
			: ($action="none-@")
				$g2_new:=$g_ref_new+($g2-$g_ref_init)
				$d2_new:=$g_ref_new+($d2-$g_ref_init)
			Else 
				$g2_new:=$g2
				$d2_new:=$d2
		End case 
		Case of 
			: ($action="@-grow")
				$h2_new:=$h_ref_new+($h2-$h_ref_init)
				$b2_new:=$b_ref_new+($b2-$b_ref_init)
			: ($action="@-move")
				$h2_new:=$b_ref_new-($b_ref_init-$h2)
				$b2_new:=$b_ref_new-($b_ref_init-$b2)
			: ($action="@-none")
				$h2_new:=$h_ref_new+($h2-$h_ref_init)
				$b2_new:=$h_ref_new+($b2-$h_ref_init)
			Else 
				$h2_new:=$h2
				$b2_new:=$b2
		End case 
		
		If ($g2_new>$d2_new)
			$swap:=$d2_new
			$d2_new:=$g2_new
			$g2_new:=$swap
		End if 
		If ($h2_new>$b2_new)
			$swap:=$b2_new
			$b2_new:=$h2_new
			$h2_new:=$swap
		End if 
		
		OBJECT SET COORDINATES:C1248(*; $form_object; \
			$g2_new; \
			$h2_new; \
			$d2_new; \
			$b2_new)
		
	End for each 
	
Function formObjectResizeGN( ...  : Variant)
	//C_VARIANT(${1})  //following object
	
	var $form_width; $form_height; $width_instruction; $height_instruction : Integer
	
	If (Value type:C1509($1)=Is collection:K8:32)
		$form_objects:=$1.copy()
		$reference_object:=$form_objects.shift()
	Else 
		$form_objects:=New collection:C1472
		$reference_object:=$1
	End if 
	For ($o; 2; Count parameters:C259; 1)
		If (Value type:C1509(${$o})=Is collection:K8:32)
			$form_objects:=$form_objects.concat(${$o})
		Else 
			$form_objects.push(${$o})
		End if 
	End for 
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($form_width; $form_height)
	
	ARRAY LONGINT:C221($_m; 0)
	$gap:=5
	$ppm:=Position:C15("#["; $reference_object)
	If ($ppm>0)
		$gap:=0
		$ppmf:=Position:C15("]"; $reference_object; $ppm+2)
		If ($ppmf>0)
			$instruction_pm:=Substring:C12($reference_object; $ppm+2; $ppmf-$ppm-2)
			$reference_object:=Delete string:C232($reference_object; $ppm; $ppmf-$ppm+1)
			Repeat 
				$pv:=Position:C15(","; $instruction_pm)
				If ($pv>0)
					APPEND TO ARRAY:C911($_m; Num:C11(Substring:C12($instruction_pm; 1; $pv-1)))
					$instruction_pm:=Substring:C12($instruction_pm; $pv+1)
				Else 
					APPEND TO ARRAY:C911($_m; Num:C11($instruction_pm))
				End if 
			Until ($pv=0)
			Case of 
				: (Size of array:C274($_m)=1)
					APPEND TO ARRAY:C911($_m; $_m{1})
			End case 
		End if 
	End if 
	
	$ppc:=Position:C15("%["; $reference_object)
	Case of 
		: ($ppc>0)
			$ppcf:=Position:C15("]"; $reference_object; $ppc+2)
			If ($ppcf>0)
				$instruction_pc:=Substring:C12($reference_object; $ppc+2; $ppcf-$ppc-2)
				$reference_object:=Delete string:C232($reference_object; $ppc; $ppcf-$ppc+1)
				$instruction_pch:=$instruction_pc
				
				$pt:=Position:C15("-"; $instruction_pch)
				Case of 
					: ($pt=0)
						$width_instruction:=Num:C11($instruction_pch)
					: ($pt=1) & (Length:C16($instruction_pch)=1)
						$width_instruction:=100
					: ($pt=1)
						$left_instruction_pc:=0
						$right_instruction_pc:=Num:C11(Substring:C12($instruction_pch; 2))
						$width_instruction:=-1
					: ($pt=Length:C16($instruction_pch))
						$left_instruction_pc:=Num:C11(Substring:C12($instruction_pch; 1; $pt-1))
						$right_instruction_pc:=100
						$width_instruction:=-1
					Else 
						$left_instruction_pc:=Num:C11(Substring:C12($instruction_pch; 1; $pt-1))
						$right_instruction_pc:=Num:C11(Substring:C12($instruction_pch; $pt+1))
						$width_instruction:=-1
				End case 
				
			End if 
			OBJECT GET COORDINATES:C663(*; $reference_object; $g_ref; $h_ref; $d_ref; $b_ref)
			$g_ref_init:=$g_ref
			$h_ref_init:=$h_ref
			$d_ref_init:=$d_ref
			$b_ref_init:=$b_ref
			
			Case of 
				: ($width_instruction>0)
					$g_ref_new:=0
					$d_ref_new:=$form_width*$width_instruction/100
				: ($width_instruction=-1)
					$g_ref_new:=$form_width*$left_instruction_pc/100
					$d_ref_new:=$form_width*$right_instruction_pc/100
			End case 
			
			$h_ref_new:=$h_ref
			$b_ref_new:=$b_ref
			
		Else 
			OBJECT GET COORDINATES:C663(*; $reference_object; $g_ref; $h_ref; $d_ref; $b_ref)
			$g_ref_init:=$g_ref
			$h_ref_init:=$h_ref
			$d_ref_init:=$d_ref
			$b_ref_init:=$b_ref
			
			$g_ref_new:=$g_ref
			$h_ref_new:=$h_ref
			$d_ref_new:=$form_width-$gap
			$b_ref_new:=$b_ref
	End case 
	
	If (Size of array:C274($_m)>0)
		$g_ref_new:=$g_ref_new+$_m{1}
		$d_ref_new:=$d_ref_new-$_m{2}
	End if 
	
	OBJECT SET COORDINATES:C1248(*; $reference_object; $g_ref_new; $h_ref_new; $d_ref_new; $b_ref_new)
	
	For each ($form_object; $form_objects)
		Case of 
			: ($form_object="M:@")
				$action:="move"
				$form_object:=Substring:C12($form_object; 3)
			: ($form_object="MN:@")
				$action:="move"
				$form_object:=Substring:C12($form_object; 4)
			: ($form_object="G:@")
				$action:="grow"
				$form_object:=Substring:C12($form_object; 3)
			: ($form_object="GN:@")
				$action:="grow"
				$form_object:=Substring:C12($form_object; 4)
			: ($form_object="N:@")
				$action:="none"
				$form_object:=Substring:C12($form_object; 3)
			: ($form_object="NN:@")
				$action:="none"
				$form_object:=Substring:C12($form_object; 4)
			Else 
				$action:="grow"
		End case 
		
		OBJECT GET COORDINATES:C663(*; $form_object; $g2; $h2; $d2; $b2)
		
		Case of 
			: ($action="grow")
				$g2_new:=$g_ref_new+($g2-$g_ref_init)
				$d2_new:=$d_ref_new+($d2-$d_ref_init)
			: ($action="move")
				$g2_new:=$d_ref_new-($d_ref_init-$g2)
				$d2_new:=$d_ref_new-($d_ref_init-$d2)
			: ($action="none-@")
				$g2_new:=$g_ref_new+($g2-$g_ref_init)
				$d2_new:=$g_ref_new+($d2-$g_ref_init)
		End case 
		
		If ($g2_new>$d2_new)
			$swap:=$d2_new
			$d2_new:=$g2_new
			$g2_new:=$swap
		End if 
		
		$h2_new:=$h2
		$b2_new:=$b2
		
		OBJECT SET COORDINATES:C1248(*; $form_object; \
			$g2_new; \
			$h2_new; \
			$d2_new; \
			$b2_new)
		
	End for each 
	
Function formObjectResizeNG( ...  : Variant)
	//C_VARIANT(${1})  //following object
	
	var $form_width; $form_height; $width_instruction; $height_instruction : Integer
	
	If (Value type:C1509($1)=Is collection:K8:32)
		$form_objects:=$1.copy()
		$reference_object:=$form_objects.shift()
	Else 
		$form_objects:=New collection:C1472
		$reference_object:=$1
	End if 
	For ($o; 2; Count parameters:C259; 1)
		If (Value type:C1509(${$o})=Is collection:K8:32)
			$form_objects:=$form_objects.concat(${$o})
		Else 
			$form_objects.push(${$o})
		End if 
	End for 
	
	OBJECT GET SUBFORM CONTAINER SIZE:C1148($form_width; $form_height)
	
	ARRAY LONGINT:C221($_m; 0)
	$gap:=5
	$ppm:=Position:C15("#["; $reference_object)
	If ($ppm>0)
		$gap:=0
		$ppmf:=Position:C15("]"; $reference_object; $ppm+2)
		If ($ppmf>0)
			$instruction_pm:=Substring:C12($reference_object; $ppm+2; $ppmf-$ppm-2)
			$reference_object:=Delete string:C232($reference_object; $ppm; $ppmf-$ppm+1)
			Repeat 
				$pv:=Position:C15(","; $instruction_pm)
				If ($pv>0)
					APPEND TO ARRAY:C911($_m; Num:C11(Substring:C12($instruction_pm; 1; $pv-1)))
					$instruction_pm:=Substring:C12($instruction_pm; $pv+1)
				Else 
					APPEND TO ARRAY:C911($_m; Num:C11($instruction_pm))
				End if 
			Until ($pv=0)
			Case of 
				: (Size of array:C274($_m)=1)
					APPEND TO ARRAY:C911($_m; $_m{1})
			End case 
		End if 
	End if 
	
	$ppc:=Position:C15("%["; $reference_object)
	Case of 
		: ($ppc>0)
			$ppcf:=Position:C15("]"; $reference_object; $ppc+2)
			If ($ppcf>0)
				$instruction_pc:=Substring:C12($reference_object; $ppc+2; $ppcf-$ppc-2)
				$reference_object:=Delete string:C232($reference_object; $ppc; $ppcf-$ppc+1)
				$instruction_pcv:=$instruction_pc
				
				$pt:=Position:C15("-"; $instruction_pcv)
				Case of 
					: ($pt=0)
						$height_instruction:=Num:C11($instruction_pcv)
					: ($pt=1) & (Length:C16($instruction_pcv)=1)
						$height_instruction:=100
					: ($pt=1)
						$top_instruction_pc:=0
						$bottom_instruction_pc:=Num:C11(Substring:C12($instruction_pcv; 2))
						$height_instruction:=-1
					: ($pt=Length:C16($instruction_pcv))
						$top_instruction_pc:=Num:C11(Substring:C12($instruction_pcv; 1; $pt-1))
						$bottom_instruction_pc:=100
						$height_instruction:=-1
					Else 
						$top_instruction_pc:=Num:C11(Substring:C12($instruction_pcv; 1; $pt-1))
						$bottom_instruction_pc:=Num:C11(Substring:C12($instruction_pcv; $pt+1))
						$height_instruction:=-1
				End case 
			End if 
			OBJECT GET COORDINATES:C663(*; $reference_object; $g_ref; $h_ref; $d_ref; $b_ref)
			$g_ref_init:=$g_ref
			$h_ref_init:=$h_ref
			$d_ref_init:=$d_ref
			$b_ref_init:=$b_ref
			
			$g_ref_new:=$g_ref
			$d_ref_new:=$d_ref
			
			Case of 
				: ($height_instruction>0)
					$h_ref_new:=0
					$b_ref_new:=$form_height*$height_instruction/100
				: ($height_instruction=-1)
					$h_ref_new:=$form_height*$top_instruction_pc/100
					$b_ref_new:=$form_height*$bottom_instruction_pc/100
			End case 
			
			
		Else 
			OBJECT GET COORDINATES:C663(*; $reference_object; $g_ref; $h_ref; $d_ref; $b_ref)
			$g_ref_init:=$g_ref
			$h_ref_init:=$h_ref
			$d_ref_init:=$d_ref
			$b_ref_init:=$b_ref
			
			$g_ref_new:=$g_ref
			$h_ref_new:=$h_ref
			$d_ref_new:=$d_ref
			$b_ref_new:=$form_height-$gap
	End case 
	
	If (Size of array:C274($_m)>0)
		$h_ref_new:=$h_ref_new+$_m{1}
		$b_ref_new:=$b_ref_new-$_m{2}
	End if 
	
	OBJECT SET COORDINATES:C1248(*; $reference_object; $g_ref_new; $h_ref_new; $d_ref_new; $b_ref_new)
	
	For each ($form_object; $form_objects)
		Case of 
			: ($form_object="M:@")
				$action:="move"
				$form_object:=Substring:C12($form_object; 3)
			: ($form_object="NM:@")
				$action:="move"
				$form_object:=Substring:C12($form_object; 4)
			: ($form_object="G:@")
				$action:="grow"
				$form_object:=Substring:C12($form_object; 3)
			: ($form_object="NG:@")
				$action:="grow"
				$form_object:=Substring:C12($form_object; 4)
			: ($form_object="N:@")
				$action:="none"
				$form_object:=Substring:C12($form_object; 3)
			: ($form_object="NN:@")
				$action:="none"
				$form_object:=Substring:C12($form_object; 4)
			Else 
				$action:="grow"
		End case 
		
		OBJECT GET COORDINATES:C663(*; $form_object; $g2; $h2; $d2; $b2)
		
		
		Case of 
			: ($action="grow")
				$h2_new:=$h_ref_new+($h2-$h_ref_init)
				$b2_new:=$b_ref_new+($b2-$b_ref_init)
			: ($action="move")
				$h2_new:=$b_ref_new-($b_ref_init-$h2)
				$b2_new:=$b_ref_new-($b_ref_init-$b2)
			: ($action="@-none")
				$h2_new:=$h_ref_new+($h2-$h_ref_init)
				$b2_new:=$h_ref_new+($b2-$h_ref_init)
		End case 
		
		If ($h2_new>$b2_new)
			$swap:=$b2_new
			$b2_new:=$h2_new
			$h2_new:=$swap
		End if 
		
		$g2_new:=$g2
		$d2_new:=$d2
		
		OBJECT SET COORDINATES:C1248(*; $form_object; \
			$g2_new; \
			$h2_new; \
			$d2_new; \
			$b2_new)
		
	End for each 
	