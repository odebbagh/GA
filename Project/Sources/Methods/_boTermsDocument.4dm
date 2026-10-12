//%attributes = {}

// _boTermsDocument($own; $modelName) -> Object
// Picks which quality-terms document to print: the one held on the order when it has
// one, otherwise the document model of that name. Returns Null when neither has any
// text, so the caller simply prints nothing - legacy behaved the same way, appending
// BuyOrderTermsWP only when it had content.

#DECLARE($own : Object; $modelName : Text)->$document : Object

var $model : cs:C1710.sfw_DocumentModelEntity

$document:=Null

If ($own#Null)
	If (WP Get text($own)#"")
		$document:=$own
		return
	End if
End if

$model:=ds.sfw_DocumentModel.query("name = :1"; $modelName).first()
If ($model=Null) || ($model.area=Null)
	return
End if

If (WP Get text($model.area)#"")
	$document:=$model.area
End if