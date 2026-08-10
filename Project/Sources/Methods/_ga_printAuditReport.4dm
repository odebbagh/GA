//%attributes = {}

/*
Method Name : _ga_printAuditReport
Author : Medard /4D PS
Date : 11-August-2025
Purpose : This method print the selected audit report
*/



If (Form:C1466.current_item#Null:C1517)
	
	//If (Split string(WP Get text(Form.current_item.auditReport); ";"; sk ignore empty strings+sk trim spaces).join(";")="")
	//_ga_buildAuditReport()
	
	//End if 
	
	PRINT SETTINGS:C106(2)
	If (OK=1)
		WP PRINT:C1343(Form:C1466.current_item.auditReport)
	End if 
	
	
Else 
	//cs.sfw_dialog.me.info(ds.sfw_readXliff("Info"; "Please select an audit first"))
	
End if 