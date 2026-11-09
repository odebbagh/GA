//%attributes = {}

// Item action on the Receiving > Buy Orders entry, and the "Back-order remaining
// quantity" button on its Receiving page: moves the quantity still outstanding on the
// current buy line onto a new child line.
//
// The split itself is BuyingOrderLineEntity.backorderRemaining - legacy
// create_backordered_buyitem. The same function runs when a partial receipt is saved
// and the receiver answers "Back-Order" (BuyingOrderLineEntity.beforeSave, legacy's
// CONFIRM on the Save button of NewRecvOrderedPart); this method is the manual way in.

var $line : cs:C1710.BuyingOrderLineEntity
var $result : Object

If (Form:C1466.current_item=Null:C1517)
	cs:C1710.sfw_dialog.me.alert("No buy item is selected.")
	return
End if

$line:=Form:C1466.current_item

If (Not:C34($line.canBackorder))
	cs:C1710.sfw_dialog.me.alert(($line.backorderBlockedReason#"") ? $line.backorderBlockedReason : "This line cannot be back-ordered.")
	return
End if

If (Not:C34(cs:C1710.sfw_dialog.me.confirm("Back-order the remaining "+String:C10($line.qtyRemaining)+" of item "+$line.displayNumber+"?"+"\r\r"+"Line "+$line.displayNumber+" will be closed at the "+String:C10($line.qtyReceivedDisplay)+" received, and the balance moved to a new line."; "Back-Order"; "CANCEL")))
	return
End if

$result:=$line.backorderRemaining()

If ($result.success)
	cs:C1710.sfw_dialog.me.alert("Item "+$line.displayNumber+" closed at "+String:C10($result.received)+" received."+"\r"+"Back-order line "+$result.child.displayNumber+" created for the remaining "+String:C10($result.remaining)+".")
Else
	cs:C1710.sfw_dialog.me.alert($result.message)
End if
