property ident : Text
property defaultTitle : Text
property filterByLinkedEntity : Boolean
property filterByIDInTable : Boolean
property filterByManyToManyEntity : Boolean
property filterByBooleanExpression : Boolean
property linkedDataclassName : Text
property attributeForLink : Text
property placeholderForLink : Text
property linkToFollowIfShift : Text
property attributeID : Text
property labelForTrue : Text
property labelForFalse : Text
property finalDataclassName : Text
property finalAttribute : Text
property pathManyToMany : Text
property attributeForSingleTitle : Text
property formatForMutipleTitles : Text
property orderForItems : Text
property labelForItem : Text
property expression : Text
property notOrphans : Boolean
property displayCount : Text
property UUIDs : Collection
property IDS : Collection
property selectedBooleanValue : Boolean
property queryString : Text
property queryParameters : Object

Class constructor($ident : Text)
	This:C1470.ident:=$ident
	
Function setDefaultTitle($title : Text)
	This:C1470.defaultTitle:=$title
	
Function setFilterByLinkedEntity($linkedDataclassName : Text; $attributeForLink : Text; $placeholderForLink : Text; $linkToFollowIfShift : Text;  ...  : Text)
	This:C1470.filterByLinkedEntity:=True:C214
	This:C1470.linkedDataclassName:=$linkedDataclassName
	This:C1470.attributeForLink:=$attributeForLink
	If (Count parameters:C259<3) || ($placeholderForLink="")
		This:C1470.placeholderForLink:=$attributeForLink
	Else 
		This:C1470.placeholderForLink:=$placeholderForLink
	End if 
	If (Count parameters:C259>3)
		This:C1470.linkToFollowIfShift:=$linkToFollowIfShift
	End if 
	For ($p; 5; Count parameters:C259)
		$params:=Split string:C1554(${$p}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="displayCount")
				This:C1470.displayCount:=$params.shift()
		End case 
	End for 
	
Function setFilterByIDInTable($linkedDataclassName : Text; $attributeID : Text; $attributeForLink : Text; $placeholderForLink : Text;  ...  : Text)
	This:C1470.filterByIDInTable:=True:C214
	This:C1470.attributeID:=$attributeID
	This:C1470.linkedDataclassName:=$linkedDataclassName
	This:C1470.attributeForLink:=$attributeForLink
	If (Count parameters:C259<3) || ($placeholderForLink="")
		This:C1470.placeholderForLink:=$attributeForLink
	Else 
		This:C1470.placeholderForLink:=$placeholderForLink
	End if 
	For ($p; 4; Count parameters:C259)
		$params:=Split string:C1554(${$p}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="displayCount")
				This:C1470.displayCount:=$params.shift()
		End case 
	End for 
	
Function setFilterByManyToManyEntity($finalDataclassName : Text; $finalAttribute : Text; $pathManyToMany : Text;  ...  : Text)
	This:C1470.filterByManyToManyEntity:=True:C214
	This:C1470.finalDataclassName:=$finalDataclassName
	This:C1470.finalAttribute:=$finalAttribute
	This:C1470.pathManyToMany:=$pathManyToMany
	
	For ($p; 4; Count parameters:C259)
		$params:=Split string:C1554(${$p}; ":")
		$selector:=$params.shift()
		Case of 
			: ($selector="notOrphans")
				This:C1470.notOrphans:=True:C214
			: ($selector="displayCount")
				This:C1470.displayCount:=$params.shift()
		End case 
	End for 
	
	
	
Function setFilterByBooleanExpression($expression : Text; $labelForTrue : Text; $labelForFalse : Text)
	This:C1470.filterByBooleanExpression:=True:C214
	This:C1470.expression:=$expression
	This:C1470.labelForTrue:=$labelForTrue
	This:C1470.labelForFalse:=$labelForFalse
	
Function setDynamicTitle($attributeForSingleTitle : Text; $formatForMutipleTitles : Text)
	This:C1470.attributeForSingleTitle:=$attributeForSingleTitle
	This:C1470.formatForMutipleTitles:=$formatForMutipleTitles
	
Function setOrderForItems($orderForItems : Text)
	This:C1470.orderForItems:=$orderForItems
	
	
Function setAttributeLabelForItem($labelForItem : Text)
	This:C1470.labelForItem:=$labelForItem