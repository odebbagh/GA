//%attributes = {}
// _boTax($line; $currency) -> Text
// The Tax column carried a three-part format on dollar orders:
//     "$###,###,###,###,##0.00;-$...;Non- <CR>Taxable"
// - the third part being what a ZERO prints as. So a non-taxable line showed the words
// "Non- Taxable" across two lines rather than $0.00.

#DECLARE($line : cs:C1710.BuyingOrderLineEntity; $currency : Text)->$text : Text

var $tax : Real

$tax:=Num:C11($line.tax)

If ($tax=0)
	If ($currency="US$") | ($currency="")
		$text:="Non- "+Char:C90(Carriage return:K15:38)+"Taxable"
		return
	End if
End if

$text:=_boMoney($tax; $currency)
