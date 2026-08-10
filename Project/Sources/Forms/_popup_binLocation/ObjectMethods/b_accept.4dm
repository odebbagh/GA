Case of 
	: (Form event code:C388=On Clicked:K2:4)
		If (Form:C1466.choice#"")
			// An item was already selected via the listbox
			ACCEPT:C269
		Else 
			// No listbox click yet — check if a "finish" option is available (terminal node)
			var $opt : Object
			var $hasFinish : Boolean
			$hasFinish:=False:C215
			For each ($opt; Form:C1466.options)
				If ($opt.value="finish")
					$hasFinish:=True:C214
				End if 
			End for each 
			If ($hasFinish)
				Form:C1466.choice:="finish"
				ACCEPT:C269
			End if 
		End if 
End case 
