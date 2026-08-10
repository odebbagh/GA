property propertyPath : Text
property lb_items : Object
property picto : Text
property displayType : Text
property ident : Text
property label : Text
property subset : Object
property HLItems : Object
property HLEntries : Object
property RLDefinition : Object
property allowedProfiles : Collection

Class constructor($ident : Text; $label : Text;  ...  : Variant)
	var $view : cs:C1710.sfw_definitionView
	
	
	This:C1470.lb_items:=New object:C1471("columns"; New collection:C1472; "orderBy"; New collection:C1472; "counter"; New object:C1471)
	This:C1470.lb_items.counter.format:="###,###,##0 ^1;;"
	This:C1470.lb_items.counter.unit1:="item"
	This:C1470.lb_items.counter.unitN:="items"
	This:C1470.lb_items.metaExpression:=""
	This:C1470.picto:="/RESOURCES/sfw/image/picto/view-white.png"
	This:C1470.displayType:="listbox"
	
	For ($i; 3; Count parameters:C259)
		$params:=Split string:C1554(String:C10(${$i}); ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="derivedFrom")
				$i+=1
				$entry:=${$i}
				$view:=$entry.views.query("ident = :1"; $params[0]).first()
				If ($view#Null:C1517)
					For each ($attributeName; $view)
						Case of 
							: (Value type:C1509(This:C1470[$attributeName])=Is object:K8:27)
								This:C1470[$attributeName]:=OB Copy:C1225($view[$attributeName])
							: (Value type:C1509(This:C1470[$attributeName])=Is collection:K8:32)
								This:C1470[$attributeName]:=$view[$attributeName].copy()
							Else 
								This:C1470[$attributeName]:=$view[$attributeName]
						End case 
					End for each 
				End if 
		End case 
	End for 
	
	This:C1470.ident:=$ident
	This:C1470.label:=$label
	
Function setLBItemsColumn($attribute : Text; $label : Text;  ...  : Text)
	
	var $column : Object:=New object:C1471
	
	$column.attribute:=$attribute
	$column.label:=$label
	
	For ($i; 3; Count parameters:C259)
		$params:=Split string:C1554(${$i}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="type")
				$column.type:=$params[0]
			: ($selector="width")
				$column.width:=Num:C11($params.shift())
				If ($params.length>0)
					$val:=$params.shift()
					Case of 
						: ($val="fixed")
							$column.widthMin:=$column.width
							$column.widthMax:=$column.width
						Else 
							$column.widthMin:=Num:C11($val)
					End case 
				End if 
				If ($params.length>0)
					$val:=$params.shift()
					$column.widthMax:=Num:C11($val)
				End if 
			: ($selector="orderByFormula")
				$column.orderBy:=$column.orderBy || New object:C1471
				$column.orderBy.formula:=$params[0]
			: ($selector="xliff")
				$column.xliff:=$params[0]
			: ($selector="headerLeft")
				$column.header:=$column.header || New object:C1471
				$column.header.alignment:=Align left:K42:2
			: ($selector="headerRight")
				$column.header:=$column.header || New object:C1471
				$column.header.alignment:=Align right:K42:4
			: ($selector="headerCenter")
				$column.header:=$column.header || New object:C1471
				$column.header.alignment:=Align center:K42:3
			: ($selector="headerDefault")
				$column.header:=$column.header || New object:C1471
				$column.header.alignment:=Align default:K42:1
			: ($selector="headerStroke")
				$column.header:=$column.header || New object:C1471
				$column.header.stroke:=$params[0]
			: ($selector="group")
				$column.group:=$params[0]
			: ($selector="format")
				$column.format:=$params[0]
			: ($selector="left")
				$column.alignment:=Align left:K42:2
			: ($selector="right")
				$column.alignment:=Align right:K42:4
			: ($selector="center")
				$column.alignment:=Align center:K42:3
			: ($selector="default")
				$column.alignment:=Align default:K42:1
			: ($selector="columnName")
				$column.columnName:=$params[0]
			: ($selector="hidden")
				$column.hidden:=True:C214
			: ($selector="notExported")
				$column.notExported:=True:C214
		End case 
	End for 
	
	This:C1470.lb_items.columns.push($column)
	
Function setLBItemsOrderBy($propertyPath : Text; $descending : Boolean)
	var $order : Object:=New object:C1471
	
	$order.propertyPath:=$propertyPath
	$order.descending:=(Count parameters:C259>1) ? $descending : False:C215
	This:C1470.lb_items.orderBy.push($order)
	
	
Function setLBItemsMetaExpression($metaExpression : Text)
	This:C1470.lb_items.metaExpression:=$metaExpression
	
	
Function setLBItemsCounter($format : Text;  ...  : Text)
	
	This:C1470.lb_items.counter.format:=$format
	
	For ($i; 2; Count parameters:C259)
		$params:=Split string:C1554(${$i}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="unit1")
				This:C1470.lb_items.counter.unit1:=$params[0]
			: ($selector="unitN")
				This:C1470.lb_items.counter.unitN:=$params[0]
			: ($selector="unit1xliff")
				This:C1470.lb_items.counter.unit1xliff:=$params[0]
			: ($selector="unitNxliff")
				This:C1470.lb_items.counter.unitNxliff:=$params[0]
		End case 
	End for 
	
	
Function setSubset($functionName : Text;  ...  : Variant)
	
	This:C1470.subset:=New object:C1471("functionName"; $functionName)
	If (Count parameters:C259>1)
		This:C1470.subset.params:=New collection:C1472
		For ($p; 2; Count parameters:C259)
			This:C1470.subset.params.push(${$p})
		End for 
	End if 
	
	This:C1470.picto:="/RESOURCES/sfw/image/picto/view-white-subset.png"
	
	
Function setDisplayType($type : Text)
	
	$availableTypes:=Split string:C1554("listbox;hierarchical;hierarchicalEntries"; ";")
	If ($availableTypes.indexOf($type)#-1)
		This:C1470.displayType:=$type
	Else 
		cs:C1710.sfw_dialog.me.alert("This type \""+$type+"\" is unknow !")
	End if 
	
Function setPictoLabel($pictopath : Text)
	
	This:C1470.picto:=$pictopath
	
	
Function setHLItemsFirstLevelGroupBy($attribute : Text)
	
	This:C1470.HLItems:=This:C1470.HLItems || New object:C1471
	This:C1470.HLItems.firstLevelGroupBy:=New object:C1471("attribute"; $attribute)
	
	
Function setHLItemsLine($attribute : Text)
	This:C1470.HLItems:=This:C1470.HLItems || New object:C1471
	This:C1470.HLItems.line:=New object:C1471("attribute"; $attribute)
	
	
Function setAllowedProfiles( ...  : Text)
	var $p : Integer
	This:C1470.allowedProfiles:=This:C1470.allowedProfiles || New collection:C1472
	For ($p; 1; Count parameters:C259)
		This:C1470.allowedProfiles.push(${$p})
	End for 
	
Function addEntryMainLevel($attributeTodisplay : Text; $entryIdent : Text;  ...  : Text)
	This:C1470.HLEntries:=New object:C1471("levels"; New collection:C1472)
	$hierarchicalLevel:=New object:C1471
	$hierarchicalLevel.attributeTodisplay:=$attributeTodisplay
	$hierarchicalLevel.entryIdent:=$entryIdent
	$hierarchicalLevel.style:=0
	$hierarchicalLevel.color:=0
	This:C1470.HLEntries.levels.push($hierarchicalLevel)
	For ($p; 3; Count parameters:C259)
		$params:=Split string:C1554(${$p}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="displayOnlyIfChildren")
				$hierarchicalLevel.displayOnlyIfChildren:=True:C214
			: ($selector="displayCount")
				$hierarchicalLevel.displayCount:=True:C214
			: ($selector="style")
				For each ($param; $params)
					Case of 
						: ($param="bold")
							$hierarchicalLevel.style+=Bold:K14:2
						: ($param="italic")
							$hierarchicalLevel.style+=Italic:K14:3
						: ($param="underline")
							$hierarchicalLevel.style+=Underline:K14:4
					End case 
				End for each 
			: ($selector="color")
				$colorName:=$params.first()
				$hierarchicalLevel.color:=cs:C1710.sfw_htmlColor.me.colors.query("name = :1"; $colorName).first().rgb
			: ($selector="collapsed")
				$hierarchicalLevel.collapsed:=True:C214
			: ($selector="orderBy")
				$hierarchicalLevel.orderBy:=$params.join(":")
		End case 
	End for 
	
Function addEntryLevel($attributeTodisplay : Text; $entryIdent : Text;  ...  : Text)
	$hierarchicalLevel:=New object:C1471
	$hierarchicalLevel.attributeTodisplay:=$attributeTodisplay
	$hierarchicalLevel.entryIdent:=$entryIdent
	$hierarchicalLevel.style:=0
	$hierarchicalLevel.color:=0
	For ($p; 3; Count parameters:C259)
		$params:=Split string:C1554(${$p}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="linkToFollow")
				$hierarchicalLevel.linkToFollow:=$params[0]
			: ($selector="displayOnlyIfChildren")
				$hierarchicalLevel.displayOnlyIfChildren:=True:C214
			: ($selector="displayCount")
				$hierarchicalLevel.displayCount:=True:C214
			: ($selector="style")
				For each ($param; $params)
					Case of 
						: ($param="bold")
							$hierarchicalLevel.style+=Bold:K14:2
						: ($param="italic")
							$hierarchicalLevel.style+=Italic:K14:3
						: ($param="underline")
							$hierarchicalLevel.style+=Underline:K14:4
						: ($selector="color")
							$colorName:=$params.first()
							$hierarchicalLevel.color:=cs:C1710.sfw_htmlColor.me.colors.query("name = :1"; $colorName).first().rgb
					End case 
				End for each 
			: ($selector="collapsed")
				$hierarchicalLevel.collapsed:=True:C214
			: ($selector="orderBy")
				$hierarchicalLevel.orderBy:=$params.join(":")
		End case 
	End for 
	
	This:C1470.HLEntries.levels.push($hierarchicalLevel)
	
	
Function setRLDefinition($nameAttribute : Text; $recursiveAttribute : Text)
	This:C1470.displayType:="recursiveList"
	This:C1470.RLDefinition:=New object:C1471
	This:C1470.RLDefinition.nameAttribute:=$nameAttribute
	This:C1470.RLDefinition.recursiveAttribute:=$recursiveAttribute
	