
Case of 
	: (FORM Event:C1606.code=On Data Change:K2:15)
		If (Form:C1466.words#"")
			$words:=Split string:C1554(Form:C1466.words; " "; sk ignore empty strings:K86:1+sk trim spaces:K86:2)
			If ($words.length=1)
				Form:C1466.lb_items:=ds:C1482.Tool.query("name == :1 and UUID_ToolType = :2"; "@"+$words[0]+"@"; Form:C1466.uuid_toolType)
			End if 
		End if 
End case 
