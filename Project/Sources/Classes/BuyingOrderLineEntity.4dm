Class extends Entity


local Function get orderDate()->$date : Date
	$date:=This:C1470.orderStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.orderStmp; True:C214)
	
local Function set orderDate($date : Date)
	This:C1470.orderStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get requiredDate()->$date : Date
	$date:=This:C1470.requiredStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.requiredStmp; True:C214)
	
local Function set requiredDate($date : Date)
	This:C1470.requiredStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get paidDate()->$date : Date
	$date:=This:C1470.paidStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.paidStmp; True:C214)
	
local Function set paidDate($date : Date)
	This:C1470.paidStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get expectedDeliveryDate()->$date : Date
	$date:=This:C1470.expectedDeliveryStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.expectedDeliveryStmp; True:C214)
	
local Function set expectedDeliveryDate($date : Date)
	This:C1470.expectedDeliveryStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
local Function get actualDeliveryDate()->$date : Date
	$date:=This:C1470.actualDeliveryStmp=0 ? !00-00-00! : cs:C1710.sfw_stmp.me.getDate(This:C1470.actualDeliveryStmp; True:C214)
	
local Function set actualDeliveryDate($date : Date)
	This:C1470.actualDeliveryStmp:=$date=!00-00-00! ? 0 : cs:C1710.sfw_stmp.me.build($date)
	
	
Function get qtyDeliveredMajDelay()->$quantity : Real
	$param:=cs:C1710.goldenAltos_definition_globalParameters.new()
	If (This:C1470.actualDeliveryDate#Null:C1517) && (This:C1470.expectedDeliveryDate#!00-00-00!)
		$quantity:=(This:C1470.actualDeliveryDate>(This:C1470.expectedDeliveryDate+$param.constants.deleveryMinimunDelay)) ? This:C1470.qtyReceived : 0
	End if 
	
Function get qtyDeliveredMinDelay()->$quantity : Real
	If (This:C1470.actualDeliveryDate#Null:C1517) && (This:C1470.expectedDeliveryDate#!00-00-00!)
		$quantity:=(This:C1470.actualDeliveryDate<(This:C1470.expectedDeliveryDate+10)) && (This:C1470.actualDeliveryDate>This:C1470.expectedDeliveryDate) ? This:C1470.qtyReceived : 0
	End if

	// QTY Received shown on the panel. For inventory items it is derived from the
	// sum of the linked inventory lots' QTY In (created on the Inventories tab);
	// otherwise it is the value entered/imported on the line. The dataclass is
	// queried directly so freshly added lots are reflected right away.
Function get qtyReceivedDisplay()->$result : Real
	If (Bool:C1537(This:C1470.inventory))
		$result:=ds:C1482.Inventory.query("UUID_BuyingOrderLine = :1"; This:C1470.UUID).sum("qtyInStock")
	Else
		$result:=This:C1470.qtyReceived
	End if

Function set qtyReceivedDisplay($value : Real)
	// Only editable for non-inventory items; the inventory quantity is derived.
	If (Not:C34(Bool:C1537(This:C1470.inventory)))
		This:C1470.qtyReceived:=$value
	End if

	// Row meta for the Receiving - Buy Orders list: buy items that already have
	// a date in (received) are shown on a gray background.
local Function metaColor()->$meta : Object
	$meta:=New object:C1471()
	If (This:C1470.dateIn#!00-00-00!)
		$meta.fill:="#D3D3D3"
	End if

	// TEMP: canBeReceived filter disabled - see goldenAltos_definition (BuyOrders
	// entry). To re-enable, back it with a stored boolean field on the buy line
	// (the framework's boolean filter cannot resolve a computed date query).
	// A buy line can still be received while it has no date in yet.
	//Function get canBeReceived()->$result : Boolean
	//$result:=This.dateIn=!00-00-00!
	//
	//Function query canBeReceived($event : Object)->$result : cs.BuyingOrderLineSelection
	//Case of
	//: ($event.value=True) | (String($event.value)="true")
	//$result:=ds.BuyingOrderLine.query("dateIn = :1"; !00-00-00!)
	//Else
	//$result:=ds.BuyingOrderLine.query("dateIn # :1"; !00-00-00!)
	//End case
	
	
	
	