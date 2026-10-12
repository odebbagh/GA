//%attributes = {}
// LotHoldForm_ncmnApprovals
// NCMN form: the approvals belong to the disposition stage (Rexie, demo of 10 July 2026):
// raising the non-conformance shows the problem only; once a disposition is written, the four
// approvals appear, and all four are needed to take the lot off hold
// (LotHold_checkNcmnApprovals). An approval already signed always stays visible, so clearing
// the disposition never hides a signature.
// Called by the NCMN form method (On Load) and by field_disposition (as it is typed).
	
var $show : Boolean
var $name : Text
	
// while the disposition is being typed, its text is not in Form.disposition yet
If (FORM Event:C1606.code=On After Edit:K2:43) && (String:C10(FORM Event:C1606.objectName)="field_disposition")
	$show:=(cs:C1710.sfw_string.me.trimSpace(Get edited text:C655)#"")
Else 
	$show:=(cs:C1710.sfw_string.me.trimSpace(String:C10(Form:C1466.disposition))#"")
End if 
$show:=$show | Bool:C1537(Form:C1466.approvalCustomerService) | Bool:C1537(Form:C1466.approvalEngineering) | Bool:C1537(Form:C1466.approvalQAQC) | Bool:C1537(Form:C1466.approvalProduction)
	
For each ($name; New collection:C1472(\
	"section_approvals"; \
	"chk_@"; \
	"lbl_customer_service"; "lbl_engineering"; "lbl_qa_qc"; "lbl_production"; \
	"lbl_date_@"; \
	"date_@_label_bkgd"; \
	"originator_value_bkgd1"; "originator_value_bkgd2"; "originator_value_bkgd3"; "originator_value_bkgd4"; \
	"field_date_@"))
	OBJECT SET VISIBLE:C603(*; $name; $show)
End for each 
OBJECT SET VISIBLE:C603(*; "approvals_hint"; Not:C34($show))
