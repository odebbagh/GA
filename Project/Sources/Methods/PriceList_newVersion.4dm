//%attributes = {}
// PriceList_newVersion
// "New version...": the item action of the Master Price List (PriceListItem.entryDefinition).
// A price in use is not edited: a copy starts on the date asked, the current row ends the day
// before. Quote lines keep the prices they were given. Both rows are saved here, so only outside
// Modify (sfw owns the transaction of Modify).
#DECLARE()

var $current; $next : cs:C1710.PriceListItemEntity
var $answer; $result : Object
var $date : Date
var $moreData : Object

If (Form:C1466.current_item=Null:C1517)
	return
End if
If (Form:C1466.sfw.checkIsInModification())
	cs:C1710.sfw_dialog.me.alert("Save or cancel the changes first.")
	return
End if
$current:=ds:C1482.PriceListItem.get(Form:C1466.current_item.UUID)  // as saved
If ($current=Null:C1517)
	return
End if

$answer:=cs:C1710.sfw_dialog.me.request("New version of "+$current.code+" valid from (date):"; String:C10(Current date:C33+1); "Create"; "Cancel"; "trimSpace"; "notEmpty")
If (Not:C34(Bool:C1537($answer.ok)))
	return
End if
$date:=_import_priceListDate($answer.answer)
Case of
	: ($date=!00-00-00!)
		cs:C1710.sfw_dialog.me.alert("\""+$answer.answer+"\" is not a date.")
		return
	: ($current.stmpEffectiveFrom#0) && ($date<=$current.effectiveFrom)
		cs:C1710.sfw_dialog.me.alert("The new version must start after "+String:C10($current.effectiveFrom)+".")
		return
	: ($current.stmpEffectiveTo#0) && ($date>($current.effectiveTo+1))
		cs:C1710.sfw_dialog.me.alert("This price already ends on "+String:C10($current.effectiveTo)+": start the new version on "+String:C10($current.effectiveTo+1)+" at the latest.")
		return
End case

$next:=ds:C1482.PriceListItem.new()
$next.fromObject($current.toObject("code, description, UUID_StepProcess, UUID_Customer, unit, unitPrice, unitCost, minLotCharge, flowPrices, currency, active, stmpEffectiveTo"))
$moreData:=New object:C1471("previousVersion"; $current.UUID)
$next.moreData:=$moreData
$next.effectiveFrom:=$date
$current.effectiveTo:=$date-1

START TRANSACTION:C239
$result:=$current.save()
If ($result.success)
	$result:=$next.save()
End if
If ($result.success)
	VALIDATE TRANSACTION:C240
Else
	CANCEL TRANSACTION:C241
	cs:C1710.sfw_dialog.me.alert("The new version could not be saved: "+String:C10($result.statusText))
	return
End if

// the list shows both rows; the new one is opened to change its prices
Form:C1466.current_item.reload()
Form:C1466.sfw.lb_items:=Form:C1466.sfw.lb_items.copy().add($next)
cs:C1710.sfw_eventManager.me.refresh($current.UUID; Form:C1466.sfw.entry)
Form:C1466.sfw.openInANewWindow($next; "administration"; "priceList")
