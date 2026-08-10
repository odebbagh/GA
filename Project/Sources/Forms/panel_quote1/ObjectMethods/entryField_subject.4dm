var $eLead : cs:C1710.LeadEntity
If (Form:C1466.sfw.checkIsInModification())
	$leads:=ds:C1482.Lead.all()  //.query("UUID_Customer == :1"; Form.current_item.UUID_Customer)
	$items:=$leads.extract("UUID"; "UUID"; "leadCode"; "value")
	
	$uuid:=cs:C1710.panel_quote.me.selectItem($items)
	If ($uuid#"")
		$eLead:=ds:C1482.Lead.get($uuid)
		If ($eLead#Null:C1517)
			$eLead.UUID_Quote:=Form:C1466.current_item.UUID
			$eLead.save()
			cs:C1710.panel_quote.me._activate_save_cancel_button()
		End if 
	End if 
End if 

