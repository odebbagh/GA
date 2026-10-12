// search within the tools offered (Form.allTools): names containing the text typed
var $text : Text
	
Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		$text:=cs:C1710.sfw_string.me.trimSpace(String:C10(Form:C1466.words))
		If ($text="")
			Form:C1466.lb_items:=Form:C1466.allTools
		Else 
			Form:C1466.lb_items:=Form:C1466.allTools.query("name = :1"; "@"+$text+"@")
		End if 
End case 
