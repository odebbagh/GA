// View specs: the specs recorded on this step (ga_stepDocuments.chooseStepSpec)
Case of 
	: (FORM Event:C1606.code=On Clicked:K2:4)
		cs:C1710.ga_stepDocuments.me.chooseStepSpec(Form:C1466.current_item; "field_specificationControl")
	: (FORM Event:C1606.code=On Mouse Move:K2:35)
		SET CURSOR:C469(9000)
End case 
