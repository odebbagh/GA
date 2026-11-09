// selectTool: the tool picker of Punch In / OUT. Form.lb_items arrives with the tools offered
// (calibration not past due); Form.allTools keeps that list so the search only filters inside it
// and never brings an expired tool back.
Case of 
	: (FORM Event:C1606.code=On Load:K2:1)
		var $form : Object
		$form:=FORM Convert to dynamic:C1570(Current form name:C1298)
		Form:C1466.allTools:=Form:C1466.lb_items
End case 
