Case of 
	: (FORM Event:C1606.code=On Getting Focus:K2:7) | (FORM Event:C1606.code=On Clicked:K2:4)
		
		OBJECT GET COORDINATES:C663(*; "field_engineer"; $l; $t; $r; $b)
		CONVERT COORDINATES:C1365($l; $b; XY Current form:K27:5; XY Main window:K27:8)
		
		$engProfile:=ds:C1482.sfw_UserProfile.query("ident = :1"; "Eng").first()
		If ($engProfile#Null:C1517)
			$engUserUUIDs:=ds:C1482.sfw_UserInscription.query("UUID_UserProfile = :1"; $engProfile.UUID).user.UUID
			$engStaff:=ds:C1482.sfw_User.query("UUID IN :1"; $engUserUUIDs)
		Else
			$engStaff:=ds:C1482.sfw_User.all()
		End if
		$form:=New object:C1471(\
			"colName"; "login"; \
			"allData"; $engStaff; \
			"dataclass"; "sfw_User"\
			)
		
		$winRef:=Open form window:C675("selectNto1"; Pop up form window:K39:11; $l; $b-20)
		DIALOG:C40("selectNto1"; $form)
		CLOSE WINDOW:C154($winRef)
		
		If (ok=1)
			Form:C1466.engineer:=$form.item.login
		End if 
	: (FORM Event:C1606.code=On Mouse Move:K2:35)
		SET CURSOR:C469(9000)
End case 
