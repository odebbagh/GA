Class extends Entity

local Function get nameInWindowTitle()->$nameInWindowTitle : Text
	$nameInWindowTitle:=This:C1470.code+" - "+This:C1470.name

	// one default flow only: the others lose the mark (saved inside the sfw transaction of the panel)
local Function afterSave()
	This:C1470._uniqueDefault()

local Function afterCreation()
	This:C1470._uniqueDefault()

Function _uniqueDefault()
	var $other : cs:C1710.PriceFlowEntity
	If (This:C1470.isDefault)
		For each ($other; ds:C1482.PriceFlow.query("isDefault = :1 and UUID # :2"; True:C214; This:C1470.UUID))
			$other.isDefault:=False:C215
			$other.save()
		End for each
	End if

	// the aliases as one line for the panel ("MIL-STD-883, Class B_Q")
Function get aliasesText()->$text : Text
	If (This:C1470.moreData#Null:C1517) && (Value type:C1509(This:C1470.moreData.aliases)=Is collection:K8:32)
		$text:=This:C1470.moreData.aliases.join(", ")
	End if

Function set aliasesText($text : Text)
	var $moreData : Object
	var $aliases : Collection
	var $alias : Text

	$aliases:=New collection:C1472
	For each ($alias; Split string:C1554($text; ","; sk trim spaces:K86:2+sk ignore empty strings:K86:1))
		$aliases.push($alias)
	End for each
	$moreData:=(This:C1470.moreData=Null:C1517) ? New object:C1471 : OB Copy:C1225(This:C1470.moreData)
	$moreData.aliases:=$aliases
	This:C1470.moreData:=$moreData
