//%attributes = {}
// _import_customerAR_find (for _import_customerAR): the customer of a legacy [Customer_Log] row,
// by code (Cust_Code = Customer.code), else by exact name. Null when none or several match.
#DECLARE($record : Object)->$customer : cs.CustomerEntity
var $found : cs.CustomerSelection
If (String($record.Cust_Code)#"")
	$found:=ds.Customer.query("code = :1"; String($record.Cust_Code))
	If ($found.length=1)
		$customer:=$found.first()
		return 
	End if 
End if 
If (String($record.Customer)#"")
	$found:=ds.Customer.query("name = :1"; String($record.Customer))
	If ($found.length=1)
		$customer:=$found.first()
	End if 
End if 
