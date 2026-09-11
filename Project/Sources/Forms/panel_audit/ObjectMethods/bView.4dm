
Case of 
		
	: (Form event code:C388=On Clicked:K2:4)
		
		// Purpose: Delegate viewing to _ga_audit_openAttachment — resolves UUID_sfwDocument → DocumentData blob, or legacy embedded blob when present.
		// modified by 4D/PS [2026-may-26]
		_ga_audit_openAttachment(Form:C1466.current_item)
		
End case 
