//%attributes = {}
QUERY:C277([Staff:135]; [Staff:135]UUID:1=Form:C1466.current_item.UUID)

If (Records in selection:C76([Staff:135])>0)
	FORM SET OUTPUT:C54([Staff:135]; "certification_badge")
	PRINT RECORD:C71([Staff:135])
End if 
