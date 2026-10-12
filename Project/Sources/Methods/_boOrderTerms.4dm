//%attributes = {}

// _boOrderTerms($order) -> Object
// The single quality-terms document to print after an order, reproducing legacy
// [BUY_ORDERS]Buy_policy_ - which was one document, never three.
//
// Legacy filled it on creation from <>Buy_policyWP (the [Formats] record named
// "BuyOrderTerms") and let the buyer replace it with the CriticalMaterials or
// CriticalService wording. GA imported that single field into three separate columns,
// so at most one of them is ever populated on a given order; whichever it is, that is
// the document legacy would have printed.
//
// Falls back to the BUY_ORDER_TERMS document model, which is the default wording and is
// what imported orders need since their policy documents were never brought across.
// Returns Null when there is nothing with any text, and the caller then prints no terms
// page at all - legacy did the same.

#DECLARE($order : cs:C1710.BuyingOrderEntity)->$document : Object

var $candidate : Object
var $model : cs:C1710.sfw_DocumentModelEntity

$document:=Null

For each ($candidate; New collection($order.terms; $order.termsCriticalMaterials; $order.termsCriticalService))
	//---the three terms fields are Object fields set to never-null: an order with no terms
	//   document holds {} rather than Null, and WP Get text refuses anything that is not a
	//   Write Pro document
	If ($candidate#Null) && (Not(OB Is empty($candidate)))
		If (WP Get text($candidate)#"")
			$document:=$candidate
			return
		End if
	End if
End for each

$model:=ds.sfw_DocumentModel.query("name = :1"; "BUY_ORDER_TERMS").first()
If ($model=Null) || ($model.area=Null) || (OB Is empty($model.area))
	return
End if

If (WP Get text($model.area)#"")
	$document:=$model.area
End if