Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		Case of 
			: (FORM Event:C1606.objectName="qa_radio_accepted")
				cs:C1710.panel_punch_out.me.applyQASignoffDecision(False:C215)
			: (FORM Event:C1606.objectName="qa_radio_rejected")
				cs:C1710.panel_punch_out.me.applyQASignoffDecision(True:C214)
		End case 
End case 
