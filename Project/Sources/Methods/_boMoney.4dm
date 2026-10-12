//%attributes = {}
// _boMoney($amount; $currency) -> Text
// PL_SetFormat used "|money" for US$ and "|moneyN" otherwise - a leading $ only on
// dollar orders. Same rule.

#DECLARE($amount : Real; $currency : Text)->$text : Text

If ($currency="US$") | ($currency="")
	$text:="$"+String:C10($amount; "###,###,###,###,##0.00")
Else
	$text:=String:C10($amount; "###,###,###,###,##0.00")
End if
