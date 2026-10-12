// search as the user types: digits = job numbers starting with them, else the customer name
var $text : Text
var $number : Real
var $max : Real
var $low : Real
var $high : Real
var $found : 4D:C1709.EntitySelection
	
Case of 
	: (Form event code:C388=On After Edit:K2:43) | (Form event code:C388=On Data Change:K2:15)
		If (Form event code:C388=On After Edit:K2:43)
			$text:=Get edited text:C655
		Else 
			$text:=String:C10(Form:C1466.words)
		End if 
		$text:=cs:C1710.sfw_string.me.trimSpace($text)
		Case of 
			: ($text="")
				Form:C1466.lb_items:=Form:C1466.allJobs
			: (Match regex:C1019("^[0-9]+$"; $text; 1))
				// job numbers starting with these digits: "97" = 97, 970-979, 9700-9799... up to the
				// highest job number (number ranges: no formula, the index is used)
				$number:=Num:C11($text)
				$max:=Num:C11(Form:C1466.allJobs.max("jobNumber"))
				$found:=Form:C1466.allJobs.query("jobNumber = :1"; $number)
				$low:=$number
				$high:=$number
				While ($low>0) & (($low*10)<=$max)
					$low:=$low*10
					$high:=($high*10)+9
					$found:=$found.or(Form:C1466.allJobs.query("jobNumber >= :1 AND jobNumber <= :2"; $low; $high))
				End while 
				Form:C1466.lb_items:=$found.orderBy("jobNumber desc")
			Else 
				Form:C1466.lb_items:=Form:C1466.allJobs.query("customer.name = :1"; "@"+$text+"@")
		End case 
End case 
