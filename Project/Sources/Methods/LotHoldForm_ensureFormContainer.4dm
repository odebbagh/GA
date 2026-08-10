//%attributes = {}
// Ensures lot.NCMN or lot.ISSNF uses {items: [...]} and migrates legacy single-object data.
#DECLARE($lot : 4D:C1709.Entity; $formFieldName : Text; $hold : Object)

var $container : Object
var $items : Collection
var $legacyItem : Object
var $historicalHold : Object

If ($lot=Null:C1517) || ($hold=Null:C1517)
	return 
End if 

Case of 
	: ($formFieldName="NCMN")
		$container:=$lot.NCMN
	: ($formFieldName="ISSNF")
		$container:=$lot.ISSNF
	Else 
		return 
End case 

If ($container=Null:C1517)
	Case of 
		: ($formFieldName="NCMN")
			$lot.NCMN:=New object:C1471("items"; New collection:C1472())
		: ($formFieldName="ISSNF")
			$lot.ISSNF:=New object:C1471("items"; New collection:C1472())
	End case 
	return 
End if 

If ($container.items#Null:C1517)
	return 
End if 

$items:=New collection:C1472()

If ($container.customer#Null:C1517) | ($container.lotNumber#Null:C1517) | ($container.originator#Null:C1517) | ($container.problemDetail#Null:C1517)
	$legacyItem:=LotHoldForm_cloneObject($container)
	$historicalHold:=Null:C1517
	
	If ($lot.lotHold#Null:C1517) && ($lot.lotHold.items#Null:C1517)
		$historicalHold:=$lot.lotHold.items.query("action = :1"; "on").orderBy("date asc; time asc").first()
		If ($historicalHold=Null:C1517)
			$historicalHold:=$lot.lotHold.items.query("holdAction = :1"; "Hold ON").orderBy("holdDate asc; holdTime asc").first()
		End if 
	End if 
	
	If ($historicalHold#Null:C1517)
		LotHoldForm_ensureHoldUUID($lot; $historicalHold)
		$legacyItem.hold_UUID:=$historicalHold.UUID
		If ($historicalHold.date#Null:C1517)
			$legacyItem.hold_date:=$historicalHold.date
			$legacyItem.hold_time:=$historicalHold.time
		Else 
			$legacyItem.hold_date:=$historicalHold.holdDate
			$legacyItem.hold_time:=$historicalHold.holdTime
		End if 
	End if 
	
	$items.push($legacyItem)
End if 

Case of 
	: ($formFieldName="NCMN")
		$lot.NCMN:=New object:C1471("items"; $items)
	: ($formFieldName="ISSNF")
		$lot.ISSNF:=New object:C1471("items"; $items)
End case 
