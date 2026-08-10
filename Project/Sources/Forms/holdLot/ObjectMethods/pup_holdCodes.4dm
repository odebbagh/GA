Case of
	: (Form event code:C388=On Clicked:K2:4)
		If (Form:C1466.holdAction="Hold OFF")
			return
		End if
		OBJECT GET COORDINATES:C663(*; "pup_holdCodes"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$form:=New object:C1471(\
			"colName"; "Code"; \
			"allData"; ds:C1482.HoldCode.all(); \
			"dataclass"; "HoldCode"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (ok=1)
			Form:C1466.holdLot:=New object:C1471("uuid"; $form.item.UUID; "code"; $form.item.Code)
		End if 
End case 

