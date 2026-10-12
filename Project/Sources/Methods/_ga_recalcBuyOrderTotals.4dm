//%attributes = {}

/*
Method Name : _ga_recalcBuyOrderTotals
Purpose     : Rolls every buy order's lines up onto the order - legacy BO_totalupd, run
              across the whole table.

              lineItemsTotal and salesTax are stored (they are list box columns, so they
              cannot be computed without summing the lines once per displayed row). The
              import brought them across as the legacy values, and 148 orders arrived
              with a zero total that does not match their lines.

Changes only the orders whose stored figures actually differ, so it is safe to re-run and
leaves everything else untouched.
*/

var $order : cs:C1710.BuyingOrderEntity
var $result : Object
var $checked; $fixed; $failed : Integer
var $before : Real
var $worst : Real
var $worstOrder : Integer

For each ($order; ds.BuyingOrder.all())
	$checked:=$checked+1
	$before:=Num($order.lineItemsTotal)

	If ($order.recalcTotals())
		$result:=$order.save()
		If ($result.success)
			$fixed:=$fixed+1
			If (Abs($order.lineItemsTotal-$before)>$worst)
				$worst:=Abs($order.lineItemsTotal-$before)
				$worstOrder:=Num($order.boNumber)
			End if
		Else
			$failed:=$failed+1
		End if
	End if
End for each

cs.sfw_dialog.me.info("Buy order totals recalculated."+Char(Carriage return)+Char(Carriage return)\
	+"orders checked : "+String($checked)+Char(Carriage return)\
	+"totals corrected: "+String($fixed)+Char(Carriage return)\
	+"failed          : "+String($failed)+Char(Carriage return)+Char(Carriage return)\
	+"largest correction: "+String($worst; "$###,###,##0.00")+" on BO "+String($worstOrder))