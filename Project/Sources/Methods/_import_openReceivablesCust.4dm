//%attributes = {}
// _import_openReceivablesCust (for _import_openReceivables): the customer of a legacy
// [Receivables] row - by exact name first (legacy custid is not the customer code), else by
// code. Null when none or several match.
#DECLARE($row : Object)->$customer : cs.CustomerEntity
var $found : cs.CustomerSelection
If (String($row.Customer)#"")
	$found:=ds.Customer.query("name = :1"; String($row.Customer))
	If ($found.length=1)
		$customer:=$found.first()
		return
	End if
End if
If (String($row.custid)#"")
	$found:=ds.Customer.query("code = :1"; String($row.custid))
	If ($found.length=1)
		$customer:=$found.first()
	End if
End if
