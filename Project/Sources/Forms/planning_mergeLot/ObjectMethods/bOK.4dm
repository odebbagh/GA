Case of 
	: (Form event code:C388=On Clicked:K2:4)
		Case of 
			: (Form:C1466.selected=Null:C1517)
				cs:C1710.sfw_dialog.me.alert("Select the lot to merge into this lot.")
			: (Not:C34(Bool:C1537(Form:C1466.selected.allowed)))
				cs:C1710.sfw_dialog.me.alert(String:C10(Form:C1466.selected.message))
			Else 
				If (cs:C1710.sfw_dialog.me.confirm("Merge lot "+String:C10(Form:C1466.selected.lotNumber)+" ("+String:C10(Form:C1466.selected.ourCount)+" item(s)) into this lot?"+Choose:C955(String:C10(Form:C1466.selected.message)=""; ""; "\r\r"+String:C10(Form:C1466.selected.message))+"\r\rLot "+String:C10(Form:C1466.selected.lotNumber)+" will be closed with nothing retained."; "Merge"; "Cancel"))
					ACCEPT:C269
				End if 
		End case 
End case 
