
var $search : Text

Case of 
	: (Form event code:C388=On Load:K2:1)
		If (Form:C1466.words=Null:C1517)
			Form:C1466.words:=""
		End if 
		
	: (Form event code:C388=On Before Keystroke:K2:6)
		$code:=Character code:C91(Keystroke:C390)
		If ($code=Carriage return:K15:38) | ($code=Line feed:K15:40) | ($code=3)
			FILTER KEYSTROKE:C213("")
		End if 
		return 
		
	: (Form event code:C388=On After Keystroke:K2:26) | (Form event code:C388=On After Edit:K2:43)
		// Form.words is not yet committed on keystroke — use the live edited text.
		$search:=Replace string:C233(Replace string:C233(Get edited text:C655; Char:C90(Carriage return:K15:38); ""); Char:C90(Line feed:K15:40); "")
		Form:C1466.words:=$search
		
	: (Form event code:C388=On Data Change:K2:15)
		$search:=Replace string:C233(Replace string:C233(String:C10(Form:C1466.words); Char:C90(Carriage return:K15:38); ""); Char:C90(Line feed:K15:40); "")
		Form:C1466.words:=$search
		
	Else 
		return 
End case 

If (Form event code:C388#On Load:K2:1)
	If ($search="")
		Form:C1466.lb_items:=Form:C1466.allData
	Else 
		$needle:=Lowercase:C14($search)
		Form:C1466.lb_items:=Form:C1466.allData.filter(Formula:C1597(\
			(Position:C15($needle; Lowercase:C14(String:C10($1.value.fullName)))>0) || \
			(Position:C15($needle; Lowercase:C14(String:C10($1.value.role)))>0)))
	End if 
End if 
