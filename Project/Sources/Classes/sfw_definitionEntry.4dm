property ident : Text
property label : Text
property xliff : Text
property labelSingle : Text
property searchfields : Collection
property dataclass : Text
property searchbox : Object
property icon : Text
property iconAlternative : Text
property launchingExpression : Text
property event : Object
property addable : Object
property toolbarLabel : Text
property visions : Collection
property displayOrder : Integer
property panel : Object
property itemActions : Collection
property itemListActions : Collection
property itemListProjections : Collection
property itemListOutsides : Collection
property views : Collection
property allowFavorite : Boolean
property allowSubscription : Boolean
property allowAssignation : Boolean
property allowDocument : Object
property multiselection : Object
property allowedProfiles : Collection
property allowedProfilesForCreation : Collection
property allowedProfilesForDeletion : Collection
property allowedProfilesForModification : Collection
property toolBarGroup : Object
property linkedReferenceRecordsDataclasses : Collection
property panelAfterProjectionIfNoItemSelected : Text
property panelIfNoItemSelected : Text
property validationRules : Collection
property wizard : Object
property virtual : Text
property items : Collection
property comment : Object
property filters : Collection
property specificAddModes : Collection
property splitter : Object
property orderByDefault : Text
property transaction : Object
property searchPreferedTags : Collection


Class constructor($ident : Text; $vision_ident : Variant; $labelPlurial : Text; $labelSingle : Text)
	
	This:C1470.ident:=$ident
	This:C1470.label:=$labelPlurial
	If ($labelSingle#"")
		This:C1470.labelSingle:=$labelSingle
	End if 
	This:C1470.toolbarLabel:=$labelPlurial
	This:C1470.visions:=New collection:C1472
	This:C1470.displayOrder:=0
	Case of 
		: (Value type:C1509($vision_ident)=Is text:K8:3)
			This:C1470.visions.push($vision_ident)
		: (Value type:C1509($vision_ident)=Is collection:K8:32)
			This:C1470.visions:=$vision_ident
	End case 
	This:C1470.xliff:=""
	This:C1470.searchbox:=New object:C1471("fields"; New collection:C1472; "specificSearches"; New collection:C1472)
	This:C1470.panel:=New object:C1471("name"; ""; "pages"; New collection:C1472)
	This:C1470.itemActions:=New collection:C1472
	This:C1470.itemListActions:=New collection:C1472
	This:C1470.itemListProjections:=New collection:C1472
	This:C1470.itemListOutsides:=New collection:C1472
	This:C1470.views:=New collection:C1472
	This:C1470.allowFavorite:=True:C214
	This:C1470.allowSubscription:=False:C215
	This:C1470.allowDocument:=Null:C1517
	This:C1470.multiselection:=Null:C1517
	This:C1470.allowedProfilesForCreation:=New collection:C1472
	This:C1470.allowedProfilesForDeletion:=New collection:C1472
	This:C1470.allowedProfilesForModification:=New collection:C1472
	This:C1470.searchPreferedTags:=New collection:C1472
	
Function setXliffLabel($xliff : Text)
	This:C1470.xliff:=$xliff
	
	
Function setDataclass($dataclass : Text)
	If (ds:C1482[$dataclass]=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("The dataclass "+$dataclass+" doesn't exist in the datastore.")
	Else 
		This:C1470.dataclass:=$dataclass
	End if 
	
	
Function setIcon($iconRelativePath : Text; $iconAlternativePath : Text)
	This:C1470.icon:=$iconRelativePath
	This:C1470.iconAlternative:=$iconAlternativePath
	
	
Function setToolBarGroup($ident : Text; $label : Text; $icon : Text; $displayOrder : Integer)
	If (This:C1470.toolBarGroup=Null:C1517)
		This:C1470.toolBarGroup:=New object:C1471
		This:C1470.toolBarGroup.ident:=$ident
		This:C1470.toolBarGroup.displayOrder:=0
	End if 
	If ($label#"")
		This:C1470.toolBarGroup.label:=$label
	End if 
	If ($icon#"")
		This:C1470.toolBarGroup.icon:=$icon
	End if 
	If ($displayOrder#0)
		This:C1470.displayOrder:=$displayOrder
	End if 
	
	
Function setToolbarLabel($label : Text)
	This:C1470.toolbarLabel:=$label
	
	
Function setDisplayOrder($order : Integer)
	This:C1470.displayOrder:=$order
	
	
	
	
Function setPanel($panelName : Text; $currentPage : Integer)
	ARRAY TEXT:C222($_names; 0)
	FORM GET NAMES:C1167($_names)
	If (Find in array:C230($_names; $panelName)=-1)
		cs:C1710.sfw_dialog.me.alert("The panel \""+$panelName+"\" doesn't exist in the form list.")
	Else 
		This:C1470.panel.name:=$panelName
	End if 
	If (Count parameters:C259>1)
		This:C1470.panel.currentPage:=$currentPage
	End if 
	
	
	
Function setPanelPage($pageNum : Integer; $pict : Text; $label : Text;  ...  : Text)
	var $page : Object:=New object:C1471
	
	$page.page:=$pageNum
	$page.pict:=$pict
	If (Count parameters:C259>2)
		$page.label:=$label
	End if 
	
	For ($p; 4; Count parameters:C259)
		$params:=Split string:C1554(${$p}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="allowedProfiles")
				$page.allowedProfiles:=$params
			: ($selector="condition")
				$page.condition:=$params.join(":")
			: ($selector="disabled")
				If ($params.length=0)
					$page.disabled:=True:C214
				Else 
					$page.disabled:=$params.join(":")
				End if 
			: ($selector="suffixLabel")
				$page.suffixLabel:=$params.join(":")
			: ($selector="countFormula")
				$page.countFormula:=$params.join(":")
		End case 
	End for 
	
	
	
	This:C1470.panel.pages.push($page)
	
	
Function setPanelDynamicPage($pageNum : Integer; $pict : Text; $label : Text; $dynamicSource : Object;  ...  : Text)
	var $page : Object:=New object:C1471
	
	This:C1470.panel.asDynamicSources:=True:C214
	$page.page:=$pageNum
	$page.pict:=$pict
	If (Count parameters:C259>2)
		$page.label:=$label
	End if 
	$page.dynamicSource:=$dynamicSource
	
	For ($p; 5; Count parameters:C259)
		$params:=Split string:C1554(${$p}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="allowedProfiles")
				$page.allowedProfiles:=$params
			: ($selector="condition")
				$page.condition:=$params.join(":")
			: ($selector="disabled")
				If ($params.length=0)
					$page.disabled:=True:C214
				Else 
					$page.disabled:=$params.join(":")
				End if 
			: ($selector="suffixLabel")
				$page.suffixLabel:=$params.join(":")
			: ($selector="countFormula")
				$page.countFormula:=$params.join(":")
		End case 
	End for 
	
	
	This:C1470.panel.pages.push($page)
	
Function setLBItemsColumn($attribute : Text; $label : Text;  ...  : Text)
	
	var $view : cs:C1710.sfw_definitionView
	$view:=This:C1470.views.query("ident = :1"; "main").first()
	If ($view=Null:C1517)
		$view:=cs:C1710.sfw_definitionView.new("main"; "Main view")
		This:C1470.setView($view)
	End if 
	
	$params:=New collection:C1472
	For ($i; 1; Count parameters:C259)
		$params.push(${$i})
	End for 
	$view.setLBItemsColumn.apply($view; $params)
	
	
Function setLBItemsOrderBy($propertyPath : Text; $descending : Boolean)
	
	var $view : cs:C1710.sfw_definitionView
	$view:=This:C1470.views.query("ident = :1"; "main").first()
	If ($view=Null:C1517)
		$view:=cs:C1710.sfw_definitionView.new("main"; "Main view")
		This:C1470.setView($view)
	End if 
	
	$params:=New collection:C1472
	For ($i; 1; Count parameters:C259)
		$params.push(${$i})
	End for 
	$view.setLBItemsOrderBy.apply($view; $params)
	
Function setLBItemsCounter($format : Text;  ...  : Text)
	
	var $view : cs:C1710.sfw_definitionView
	$view:=This:C1470.views.query("ident = :1"; "main").first()
	If ($view=Null:C1517)
		$view:=cs:C1710.sfw_definitionView.new("main"; "Main view")
		This:C1470.setView($view)
	End if 
	
	$params:=New collection:C1472
	For ($i; 1; Count parameters:C259)
		$params.push(${$i})
	End for 
	$view.setLBItemsCounter.apply($view; $params)
	
Function setLBAllowedProfiles( ...  : Text)
	var $view : cs:C1710.sfw_definitionView
	$view:=This:C1470.views.query("ident = :1"; "main").first()
	If ($view=Null:C1517)
		$view:=cs:C1710.sfw_definitionView.new("main"; "Main view")
		This:C1470.setView($view)
	End if 
	
	$params:=New collection:C1472
	For ($i; 1; Count parameters:C259)
		$params.push(${$i})
	End for 
	$view.setAllowedProfiles.apply($view; $params)
	
Function setLBItemsMetaExpression($metaExpression : Text)
	var $view : cs:C1710.sfw_definitionView
	$view:=This:C1470.views.query("ident = :1"; "main").first()
	If ($view=Null:C1517)
		$view:=cs:C1710.sfw_definitionView.new("main"; "Main view")
		This:C1470.setView($view)
	End if 
	$view.setLBItemsMetaExpression($metaExpression)
	
Function setRLDefinition($nameAttribute : Text; $recursiveAttribute : Text)
	var $view : cs:C1710.sfw_definitionView
	$view:=This:C1470.views.query("ident = :1"; "main").first()
	If ($view=Null:C1517)
		$view:=cs:C1710.sfw_definitionView.new("main"; "Main view")
		This:C1470.setView($view)
	End if 
	$view.setRLDefinition($nameAttribute; $recursiveAttribute)
	
Function setSubset($functionName : Text;  ...  : Variant)
	var $view : cs:C1710.sfw_definitionView
	$view:=This:C1470.views.query("ident = :1"; "main").first()
	If ($view=Null:C1517)
		$view:=cs:C1710.sfw_definitionView.new("main"; "Main view")
		This:C1470.setView($view)
	End if 
	
	$params:=New collection:C1472
	For ($i; 1; Count parameters:C259)
		$params.push(${$i})
	End for 
	$view.setSubset.apply($view; $params)
	
Function setAddable($addable : Variant)
	This:C1470.addable:=This:C1470.addable || New object:C1471
	Case of 
		: (Count parameters:C259=0)
			This:C1470.addable.activate:=True:C214
		: (Value type:C1509($addable)=Is boolean:K8:9)
			This:C1470.addable.activate:=$addable
		: (Value type:C1509($addable)=Is text:K8:3)
			Case of 
				: ($addable="hiddenLineInModeMenu")
					This:C1470.addable.activate:=True:C214
					This:C1470.addable.hiddenLineInModeMenu:=True:C214
			End case 
	End case 
	
Function setItemAction($label : Text; $method : Text;  ...  : Text)
	var $action : Object:=New object:C1471
	
	$action.label:=$label
	$action.method:=$method
	For ($i; 3; Count parameters:C259)
		$params:=Split string:C1554(${$i}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="xliff")
				$action.xliff:=$params[0]
			: ($selector="allowedProfiles")
				$action.allowedProfiles:=$params
			: ($selector="activateIf")
				$action.activateIf:=$params.join(":")
		End case 
	End for 
	This:C1470.itemActions.push($action)
	
	
Function setItemListAction($label : Text; $method : Text;  ...  : Text)
	var $action : Object:=New object:C1471
	
	$action.label:=$label
	$action.method:=$method
	For ($i; 3; Count parameters:C259)
		$params:=Split string:C1554(${$i}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="xliff")
				$action.xliff:=$params[0]
			: ($selector="allowedProfiles")
				$action.allowedProfiles:=$params
			: ($selector="pathIcon")
				$action.pathIcon:=$params[0]
			: ($selector="scope")
				$action.scope:=$params[0]
		End case 
	End for 
	This:C1470.itemListActions.push($action)
	
	
Function setLinkedReferenceRecordsDataclasses( ...  : Text)
	var $i : Integer
	If (This:C1470.linkedReferenceRecordsDataclasses=Null:C1517)
		This:C1470.linkedReferenceRecordsDataclasses:=New collection:C1472
	End if 
	For ($i; 1; Count parameters:C259)
		This:C1470.linkedReferenceRecordsDataclasses.push(${$i})
	End for 
	
Function setItemListPreconfigAction($actionIdent : Text;  ...  : Text)
	var $action : Object:=New object:C1471
	$action.preconfigAction:=$actionIdent
	
	For ($i; 2; Count parameters:C259)
		$params:=Split string:C1554(${$i}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="xliff")
				$action.xliff:=$params[0]
		End case 
	End for 
	
	Case of 
		: ($actionIdent="exportReferenceRecords") && (cs:C1710.sfw_userManager.me.canImportExportReferenceRecords())
			$action.label:=ds:C1482.sfw_readXliff("definitionEntry.preconfig.export")
			This:C1470.itemListActions.push($action)
			
		: ($actionIdent="importReferenceRecords") && (cs:C1710.sfw_userManager.me.canImportExportReferenceRecords())
			$action.label:=ds:C1482.sfw_readXliff("definitionEntry.preconfig.import")
			This:C1470.itemListActions.push($action)
			
		: ($actionIdent="copyItemsListToPasteboard") && (cs:C1710.sfw_userManager.me.canImportExportReferenceRecords())
			$action.label:=ds:C1482.sfw_readXliff("definitionEntry.preconfig.copy")
			This:C1470.itemListActions.push($action)
			
		: ($actionIdent="textToolCapitalize")
			For ($p; 2; Count parameters:C259)
				$params:=Split string:C1554(${$p}; ":")
				$selector:=$params.shift()
				Case of 
					: ($selector="attributeToCapitalize")
						$action.attributesToCapitalize:=$action.attributesToCapitalize || New collection:C1472
						$action.attributesToCapitalize.push($params.shift())
					: ($selector="label")
						$action.label:=$params.shift()
					: ($selector="pathIcon")
						$action.pathIcon:=$params.shift()
					: ($selector="allowedProfiles")
						$action.allowedProfiles:=$params
				End case 
			End for 
			$action.label:=$action.label || ds:C1482.sfw_readXliff("definitionEntry.preconfig.capitalize")  //"Capitalize the name"  //OKXLIFF
			$action.pathIcon:=$action.pathIcon || "sfw/image/skin/rainbow/icon/capitalize_24x24.png"
			$action.attributesToCapitalize:=$action.attributesToCapitalize || New collection:C1472("name")
			This:C1470.itemListActions.push($action)
			
		: ($actionIdent="textToolUppercase")
			For ($p; 2; Count parameters:C259)
				$params:=Split string:C1554(${$p}; ":")
				$selector:=$params.shift()
				Case of 
					: ($selector="attributeToUppercase")
						$action.attributesToUppercase:=$action.attributesToUppercase || New collection:C1472
						$action.attributesToUppercase.push($params.shift())
					: ($selector="label")
						$action.label:=$params.shift()
					: ($selector="pathIcon")
						$action.pathIcon:=$params.shift()
					: ($selector="allowedProfiles")
						$action.allowedProfiles:=$params
				End case 
			End for 
			$action.label:=$action.label || ds:C1482.sfw_readXliff("definitionEntry.preconfig.upper")  //"Uppercase the name"  //OKXLIFF
			$action.pathIcon:=$action.pathIcon || "sfw/image/skin/rainbow/icon/upperCase_24x24.png"
			$action.attributesToUppercase:=$action.attributesToUppercase || New collection:C1472("name")
			This:C1470.itemListActions.push($action)
			
	End case 
	
	
Function setItemListProjection($label : Text; $function : Text; $entryIdent : Text; $visionIdent : Text;  ...  : Text)
	var $projection : Object:=New object:C1471
	
	$projection.label:=$label
	$projection.function:=$function
	$projection.entryIdent:=$entryIdent
	$projection.visionIdent:=$visionIdent
	For ($i; 3; Count parameters:C259)
		$params:=Split string:C1554(${$i}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="xliff")
				$projection.xliff:=$params[0]
		End case 
	End for 
	This:C1470.itemListProjections.push($projection)
	
	
Function setPanelAfterProjection($panel : Text)
	This:C1470.panelAfterProjectionIfNoItemSelected:=$panel
	
Function setPanelIfNoItemSelected($panel : Text)
	This:C1470.panelIfNoItemSelected:=$panel
	
	
Function setItemListOutside($label : Text; $function : Text;  ...  : Text)
	var $action : Object:=New object:C1471
	
	$action.label:=$label
	$action.function:=$method
	For ($i; 3; Count parameters:C259)
		$params:=Split string:C1554(${$i}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="xliff")
				$action.xliff:=$params[0]
		End case 
	End for 
	This:C1470.itemListOutsides.push($action)
	
	
	
Function setValidationRule($field : Text; $widget : Text;  ...  : Text)
	var $rule : Object:=New object:C1471
	
	$rule.field:=$field
	$rule.widget:=$widget
	
	For ($i; 3; Count parameters:C259)
		$params:=Split string:C1554(${$i}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="mandatory")
				$rule.mandatory:=True:C214
			: ($selector="trimSpace")
				$rule.trimSpace:=True:C214
			: ($selector="capitalize")
				$rule.capitalize:=True:C214
			: ($selector="uppercase")
				$rule.uppercase:=True:C214
			: ($selector="unique")
				$rule.unique:=True:C214
			: ($selector="UUIDNotNull")
				$rule.UUIDNotNull:=True:C214
			: ($selector="notZero")
				$rule.notZero:=True:C214
			: ($selector="message")
				$rule.message:=$params.join(":")
		End case 
	End for 
	This:C1470.validationRules:=This:C1470.validationRules || New collection:C1472
	This:C1470.validationRules.push($rule)
	
Function setWizard($panel : Text;  ...  : Text)
	This:C1470.wizard:=This:C1470.wizard || New object:C1471
	This:C1470.wizard.panel:=$panel
	For ($i; 2; Count parameters:C259)
		$param:=${$i}
		Case of 
			: ($param="palette")
				This:C1470.wizard.palette:=True:C214
		End case 
	End for 
	
Function setVirtual($type : Text)
	This:C1470.virtual:=$type
	
	Case of 
		: ($type="collection")
			This:C1470.items:=New collection:C1472
			
	End case 
	
	
Function setVirtualItem($item : cs:C1710.sfw_definitionVirtualItem)
	
	This:C1470.items.push($item)
	
Function activateComment( ...  : Text)
	
	If (ds:C1482["sfw_Comment"]=Null:C1517)
		cs:C1710.sfw_dialog.me.alert("The table sfw_Comment is missing to use the comment managment feature.")
	End if 
	
	This:C1470.comment:=New object:C1471
	This:C1470.comment.unit0:="no comment"
	This:C1470.comment.unit1:="one comment"
	This:C1470.comment.unitN:="comments"
	
	For ($p; 1; Count parameters:C259)
		$params:=Split string:C1554(${$p}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="withComment") || ($selector="inComment") || ($selector="levelComment")
				This:C1470.setSearchField($selector)
			: ($selector="activateSearchTags")
				This:C1470.setSearchField("withComment")
				This:C1470.setSearchField("inComment")
				This:C1470.setSearchField("levelComment")
		End case 
	End for 
	
	
Function enableTransaction()
	
	This:C1470.transaction:=New object:C1471
	
	
	//mark:- Views
	
Function setView($view : cs:C1710.sfw_definitionView)
	
	This:C1470.views.push($view)
	
Function setMainViewLabel($label : Text)
	
	var $view : cs:C1710.sfw_definitionView
	$view:=This:C1470.views.query("ident = :1"; "main").first()
	If ($view#Null:C1517)
		$view.label:=$label
	End if 
	
	
	//mark:-Events
	
Function activateEvent($eventDataclass : Text; $linkedAttrribute : Text)
	This:C1470.event:=This:C1470.event || New object:C1471("attributesToTrackInModificationEvent"; New collection:C1472; "linksManyToOneToTrackInModificationEvent"; New collection:C1472; "attributeStmpToTrackInModificationEvent"; New collection:C1472)
	If (Count parameters:C259=0)
		This:C1470.event.dataclass:=This:C1470.dataclass+"Event"
		This:C1470.event.linkedAttribute:="UUID_"+This:C1470.dataclass
	Else 
		This:C1470.event.dataclass:=$eventDataclass
		This:C1470.event.linkedAttribute:=$linkedAttrribute
	End if 
	
	
Function setAttributesToTrackInModificationEvent( ...  : Text)
	For ($p; 1; Count parameters:C259)
		$param:=Split string:C1554(${$p}; " ").join(" "; ck ignore null or empty:K85:5)
		$params:=New collection:C1472
		Case of 
			: ($param="@ @")
				$part:=Split string:C1554($param; " ")
			: ($param="@,@")
				$part:=Split string:C1554($param; ",")
			: ($param="@;@")
				$part:=Split string:C1554($param; ";")
			Else 
				$params:=New collection:C1472($param)
		End case 
		For each ($param; $params)
			This:C1470.event.attributesToTrackInModificationEvent.push($param)
		End for each 
	End for 
	
Function setLinkManyToOneToTrackInModificationEvent($name : Text; $attributeForLink : Text; $linkToFollow : Text)
	$link:=New object:C1471
	$link.name:=$name
	$link.attributeForLink:=$attributeForLink
	$link.linkToFollow:=$linkToFollow
	This:C1470.event.linksManyToOneToTrackInModificationEvent.push($link)
	
Function setAttributeStmpToTrackInModificationEvent($name : Text; $attributeName : Text; $type : Integer)
	$attribute:=New object:C1471
	$attribute.name:=$name
	$attribute.attribute:=$attributeName
	$attribute.type:=$type || Is date:K8:7
	This:C1470.event.attributeStmpToTrackInModificationEvent.push($attribute)
	
Function setEventOptions( ...  : Text)
	
	For ($p; 1; Count parameters:C259)
		$param:=${$p}
		Case of 
			: ($param="dontCreateModifyEventIfNoTrackingAttribute")
				This:C1470.event.dontCreateModifyEventIfNoTrackingAttribute:=True:C214
		End case 
	End for 
	
	//mark:-Filters
Function addFilter($filter : cs:C1710.sfw_definitionFilter)
	
	This:C1470.filters:=This:C1470.filters || New collection:C1472
	This:C1470.filters.push($filter)
	
	
	//Mark:-
	
Function setSpecificAddMode($ident : Text; $label : Text; $iconpath : Text; $memberFunction : Text)
	
	This:C1470.specificAddModes:=This:C1470.specificAddModes || New collection:C1472
	
	$specificAddMode:=New object:C1471
	$specificAddMode.ident:=$ident
	$specificAddMode.label:=$label
	$specificAddMode.iconpath:=$iconpath
	$specificAddMode.memberFunction:=$memberFunction
	
	This:C1470.specificAddModes.push($specificAddMode)
	
	
	
Function activateFavorite($activate : Boolean)
	If (Count parameters:C259=0)
		This:C1470.allowFavorite:=True:C214
	Else 
		This:C1470.allowFavorite:=$activate
	End if 
	
Function activateSubscription($activate : Boolean)
	If (Count parameters:C259=0)
		This:C1470.allowSubscription:=cs:C1710.sfw_definition.me.globalParameters.notifications.activate
	Else 
		This:C1470.allowSubscription:=$activate && cs:C1710.sfw_definition.me.globalParameters.notifications.activate
	End if 
	
Function activateAssignation($activate : Boolean)
	If (Count parameters:C259=0)
		This:C1470.allowAssignation:=cs:C1710.sfw_definition.me.globalParameters.todoList.activate
	Else 
		This:C1470.allowAssignation:=$activate && cs:C1710.sfw_definition.me.globalParameters.todoList.activate
	End if 
	
	
Function activateDocument( ...  : Text)
	This:C1470.allowDocument:=New object:C1471
	
	For ($p; 1; Count parameters:C259)
		$params:=Split string:C1554(${$p}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="showCountInTab")
				This:C1470.allowDocument.showCountInTab:=True:C214
		End case 
	End for 
	
	$pageDocuments:=cs:C1710.sfw_definitionPageDocuments.new("pageDocument"; This:C1470.allowDocument)
	This:C1470.setPanelDynamicPage(This:C1470.panel.pages.length+1; ""; "Documents"; $pageDocuments)
	
	
Function allowMultiSelectionInLB( ...  : Variant)
	
	Case of 
		: (Count parameters:C259=0)
			This:C1470.multiselection:=New object:C1471
		: (Value type:C1509($1)=Is boolean:K8:9) && ($allow=False:C215)
			This:C1470.multiselection:=Null:C1517
		Else 
			This:C1470.multiselection:=New object:C1471
			This:C1470.multiselection.counterSelected:=New object:C1471
			This:C1470.multiselection.counterSelected.format:=$1
			For ($i; 2; Count parameters:C259)
				$params:=Split string:C1554(${$i}; ":")
				$selector:=$params.shift()
				Case of 
					: ($selector="unit1")
						This:C1470.multiselection.counterSelected.unit1:=$params[0]
					: ($selector="unitN")
						This:C1470.multiselection.counterSelected.unitN:=$params[0]
					: ($selector="unit1xliff")
						This:C1470.multiselection.counterSelected.unit1xliff:=$params[0]
					: ($selector="unitNxliff")
						This:C1470.multiselection.counterSelected.unitNxliff:=$params[0]
					: ($selector="nbMinimum")
						This:C1470.multiselection.counterSelected.nbMinimum:=Num:C11($params[0])
				End case 
			End for 
			
	End case 
	
	
Function setAllowedProfiles( ...  : Variant)
	This:C1470.allowedProfiles:=This:C1470.allowedProfiles || New collection:C1472
	var $p : Integer
	For ($p; 1; Count parameters:C259)
		Case of 
			: (Value type:C1509(${$p})=Is text:K8:3)
				This:C1470.allowedProfiles.push(${$p})
			: (Value type:C1509(${$p})=Is collection:K8:32)
				This:C1470.allowedProfiles:=This:C1470.allowedProfiles.concat(${$p})
			Else 
				// not possible at this time
		End case 
	End for 
	
Function setAllowedProfilesForCreation( ...  : Variant)
	var $p : Integer
	For ($p; 1; Count parameters:C259)
		Case of 
			: (Value type:C1509(${$p})=Is text:K8:3)
				This:C1470.allowedProfilesForCreation.push(${$p})
			: (Value type:C1509(${$p})=Is collection:K8:32)
				This:C1470.allowedProfilesForCreation:=This:C1470.allowedProfilesForCreation.concat(${$p})
			Else 
				// not possible at this time
		End case 
	End for 
	
	
Function setAllowedProfilesForDeletion( ...  : Variant)
	var $p : Integer
	For ($p; 1; Count parameters:C259)
		Case of 
			: (Value type:C1509(${$p})=Is text:K8:3)
				This:C1470.allowedProfilesForDeletion.push(${$p})
			: (Value type:C1509(${$p})=Is collection:K8:32)
				This:C1470.allowedProfilesForDeletion:=This:C1470.allowedProfilesForDeletion.concat(${$p})
			Else 
				// not possible at this time
		End case 
	End for 
	
	
Function setAllowedProfilesForModification( ...  : Variant)
	var $p : Integer
	For ($p; 1; Count parameters:C259)
		Case of 
			: (Value type:C1509(${$p})=Is text:K8:3)
				This:C1470.allowedProfilesForModification.push(${$p})
			: (Value type:C1509(${$p})=Is collection:K8:32)
				This:C1470.allowedProfilesForModification:=This:C1470.allowedProfilesForModification.concat(${$p})
			Else 
				// not possible at this time
		End case 
	End for 
	
	
	//mark:-Search 
	
Function setSearchboxField($attribute : Text;  ...  : Variant)
	var $field : Object:=New object:C1471
	
	$field.attribute:=$attribute
	
	For ($i; 2; Count parameters:C259)
		$params:=Split string:C1554(${$i}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="placeholder")
				$field.fieldPlaceHolder:=$params[0]
		End case 
	End for 
	
	This:C1470.searchbox.fields.push($field)
	
	
Function setSearchboxSpecific($tag : Text;  ...  : Variant)
	var $specific : Object:=New object:C1471
	
	$specific.tag:=$tag
	For ($i; 2; Count parameters:C259)
		$params:=Split string:C1554(${$i}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="queryString")
				$specific.queryString:=$params.join(":")
			: ($selector="formula")
				$specific.formula:=$params.join(":")
			: ($selector="collectionBuilder")
				$specific.collectionBuilder:=$params.join(":")
			: ($selector="inCollection")
				$specific.inCollection:=$params.join(":")
		End case 
	End for 
	This:C1470.searchbox.specificSearches.push($specific)
	
	
Function setSearchField( ...  : Text)
	var $searchfield : Object:=New object:C1471
	var $p : Integer
	
	This:C1470.searchfields:=This:C1470.searchfields || New collection:C1472
	
	For ($p; 1; Count parameters:C259)
		$param:=${$p}
		$parts:=Split string:C1554($param; ":")
		$selector:=$parts.shift()
		Case of 
			: ($selector="attribute")
				$searchfield.attribute:=$parts[0]
			: ($selector="path")
				$searchfield.path:=$parts[0]
			: ($selector="placeHolder")
				$searchfield.placeHolder:=$parts[0]
			: ($selector="tag") || ($selector="tags")
				If ($parts.length=1)
					$searchfield.tag:=$parts[0]
				Else 
					$searchfield.tags:=$parts
				End if 
			: ($selector="onlyWithTag")
				$searchfield.onlyWithTag:=True:C214
			: ($selector="time")
				$searchfield.type:=Is time:K8:8
			: ($selector="date")
				$searchfield.type:=Is date:K8:7
			: ($selector="boolean")
				$searchfield.type:=Is boolean:K8:9
				$searchfield.onlyWithTag:=True:C214
			: ($selector="integer")
				$searchfield.type:=Is integer:K8:5
			: ($selector="real")
				$searchfield.type:=Is real:K8:4
			: ($selector="withComment")
				$searchfield.withComment:=True:C214
				$searchfield.onlyWithTag:=True:C214
				$searchfield.tag:=(Get database localization:C1009(Current localization:K5:22)="fr") ? "avecCommentaire" : "withComment"
				$searchfield.type:=Is text:K8:3
				$searchfield.popupPart:="_comments"
			: ($selector="inComment")
				$searchfield.inComment:=True:C214
				$searchfield.onlyWithTag:=True:C214
				$searchfield.tag:=(Get database localization:C1009(Current localization:K5:22)="fr") ? "dansCommentaire" : "inComment"
				$searchfield.type:=Is text:K8:3
				$searchfield.popupPart:="_comments"
			: ($selector="levelComment")
				$searchfield.levelComment:=True:C214
				$searchfield.onlyWithTag:=True:C214
				$searchfield.tag:=(Get database localization:C1009(Current localization:K5:22)="fr") ? "niveauCommentaire" : "levelComment"
				$searchfield.type:=Is text:K8:3
				$searchfield.popupPart:="_comments"
			: ($selector="withDocument")
				$searchfield.withDocument:=True:C214
				$searchfield.onlyWithTag:=True:C214
				$searchfield.tag:=(Get database localization:C1009(Current localization:K5:22)="fr") ? "avecDocument" : "withDocument"
				$searchfield.type:=Is text:K8:3
				$searchfield.popupPart:="_documents"
			: ($selector="inDocumentName")
				$searchfield.inDocunentName:=True:C214
				$searchfield.onlyWithTag:=True:C214
				$searchfield.tag:=(Get database localization:C1009(Current localization:K5:22)="fr") ? "dansNomDocument" : "inDocumentName"
				$searchfield.type:=Is text:K8:3
				$searchfield.popupPart:="_documents"
			: ($selector="popupPart")
				$searchfield.popupPart:=$parts[0]
			: ($selector="popupDescription")
				$searchfield.popupDescription:=$parts.join(":")
				
		End case 
	End for 
	This:C1470.searchfields.push($searchfield)
	
	
Function setSearchPreferedTags( ...  : Text)
	For ($p; 1; Count parameters:C259)
		This:C1470.searchPreferedTags.push(${$p})
	End for 
	
	
	//Mark:-
Function setLaunchingExpression($expression : Text)
	
	This:C1470.launchingExpression:=$expression
	
	
Function setAsSplitter()
	This:C1470.splitter:=New object:C1471
	
	
	
Function isDisplayable()->$isDisplayable : Boolean
	var $esUserProfiles : cs:C1710.sfw_UserProfileSelection:=cs:C1710.sfw_userManager.me.userProfiles
	var $authorizedProfiles : Collection:=cs:C1710.sfw_userManager.me.authorizedProfiles
	
	If ($entry.allowedProfiles#Null:C1517) && ($entry.allowedProfiles.length>0)
		$isDisplayable:=False:C215
		For each ($authorizedProfile; $authorizedProfiles)
			$isDisplayable:=$isDisplayable || ($entry.allowedProfiles.indexOf($authorizedProfile)#-1)
			For each ($eUserProfile; $esUserProfiles) Until ($isDisplayable)
				$isDisplayable:=$isDisplayable || ($entry.allowedProfiles.indexOf($eUserProfile.ident)#-1)
			End for each 
		End for each 
	Else 
		$isDisplayable:=True:C214
	End if 
	If (Not:C34($isDisplayable))
		For each ($eUserProfile; $esUserProfiles) Until ($isDisplayable)
			If ($eUserProfile.moreData.allowedEntries#Null:C1517)
				$isDisplayable:=$isDisplayable || ($eUserProfile.moreData.allowedEntries.indexOf($entry.ident)#-1)
			End if 
		End for each 
	End if 
	If ($isDisplayable)
		For each ($eUserProfile; $esUserProfiles) While ($isDisplayable)
			If ($eUserProfile.moreData.restrictEntries#Null:C1517) && ($eUserProfile.moreData.restrictEntries.indexOf($entry.ident)#-1)
				$isDisplayable:=False:C215
			End if 
		End for each 
	End if 
	