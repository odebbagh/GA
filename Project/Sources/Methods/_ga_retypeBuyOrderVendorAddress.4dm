//%attributes = {}

/*
Method Name : _ga_retypeBuyOrderVendorAddress
Purpose     : Renames the buy order's own vendor address from type "billing" to "vendor".

WHY
  A buy order carries four addresses and two of them were both called billing-ish:
      vendor   - the SUPPLIER's trading address   (legacy Vendor_add1..Country)
      remit    - the SUPPLIER's remit-to          (legacy Vendor_Radd1..RCountry)
      shipping - OUR delivery site                (legacy ShippingAddr, by division)
      bill to  - OUR billing address              (legacy <>GBilladd1/2, print only)
  The first was stored as "billing", which reads as if it were the fourth. It is now
  "vendor". This retypes the orders already imported; nothing else changes.

  Bill to is not stored on the order at all - it is read from the division at print time,
  which is why there is nothing to migrate for it.

Safe to re-run: an order already carrying "vendor" is skipped.
*/

var $orders : cs:C1710.BuyingOrderSelection
var $order : cs:C1710.BuyingOrderEntity
var $address : Object
var $touched; $skipped; $failed : Integer
var $result : Object
var $changed : Boolean

$orders:=ds.BuyingOrder.all()

For each ($order; $orders)
	If ($order.contactDetails=Null) || ($order.contactDetails.addresses=Null)
		$skipped:=$skipped+1
		continue
	End if

	$changed:=False
	For each ($address; $order.contactDetails.addresses)
		If (String($address.type)="billing")
			$address.type:="vendor"
			$changed:=True
		End if
	End for each

	If (Not($changed))
		$skipped:=$skipped+1
		continue
	End if

	//---reassign so ORDA registers the nested change
	$order.contactDetails:=$order.contactDetails
	$result:=$order.save()

	If ($result.success)
		$touched:=$touched+1
	Else
		$failed:=$failed+1
	End if
End for each

cs.sfw_dialog.me.info("Buy order vendor addresses retyped."+Char(Carriage return)+Char(Carriage return)\
	+"orders retyped : "+String($touched)+Char(Carriage return)\
	+"already correct: "+String($skipped)+Char(Carriage return)\
	+"failed         : "+String($failed))