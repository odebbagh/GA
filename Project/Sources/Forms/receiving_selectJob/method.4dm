// receiving_selectJob: the job pop-up of Customer Received Material (panel_customerReceivedMaterial
// .selectJob). Form.allJobs: the jobs offered; Form.item: the one chosen (double-click).
Case of 
	: (Form event code:C388=On Load:K2:1)
		Form:C1466.lb_items:=Form:C1466.allJobs
		Form:C1466.words:=""
		GOTO OBJECT:C206(*; "word1")
End case 
