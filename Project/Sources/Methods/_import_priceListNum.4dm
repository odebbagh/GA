//%attributes = {}
// _import_priceListNum
// A number of the price list file (_import_priceList): a JSON number as it is, a text with a
// period as the decimal separator ("1,250.50" or "$1250.5" allowed). Empty: 0.
#DECLARE($value : Variant)->$number : Real

var $text : Text

Case of
	: (Value type:C1509($value)=Is real:K8:4) || (Value type:C1509($value)=Is longint:K8:6) || (Value type:C1509($value)=Is integer:K8:5)
		$number:=$value
	: (Value type:C1509($value)=Is text:K8:3)
		$text:=Replace string:C233(Replace string:C233(cs:C1710.sfw_string.me.trimSpace($value); "$"; ""); ","; "")
		$number:=Num:C11($text; ".")
End case
