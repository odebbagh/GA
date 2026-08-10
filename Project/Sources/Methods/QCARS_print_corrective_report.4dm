//%attributes = {}
var $check; $uncheked : Picture
var $context_o : Object
$wpDoc:=WP New:C1317()

READ PICTURE FILE:C678(Folder:C1567(fk resources folder:K87:11).file(cs:C1710.sfw_definition.me.globalParameters.folders.projectResources+"/image/picto/checked.png").platformPath; $check)
READ PICTURE FILE:C678(Folder:C1567(fk resources folder:K87:11).file(cs:C1710.sfw_definition.me.globalParameters.folders.projectResources+"/image/picto/unchecked.png").platformPath; $uncheked)

$context:=New object:C1471(\
"dateOpen"; Form:C1466.current_item.dateOpen; \
"qcarNumber"; Form:C1466.current_item.qcarNumber; \
"customerName"; Form:C1466.current_item.customer.name; \
"device"; Form:C1466.current_item.device; \
"lotNumber"; Form:C1466.current_item.lot.lotNumber; \
"poNumber"; Form:C1466.current_item.lot.poNumber; \
"initialResponse"; Form:C1466.current_item.initialResponse; \
"targetCloseDate"; String:C10(Form:C1466.current_item.targetCloseDate; Internal date short:K1:7); \
"revisionDate"; String:C10(Form:C1466.current_item.revisionDate; Internal date short:K1:7); \
"initiator8D"; Form:C1466.current_item.initiator8D; \
"actualCloseDate"; String:C10(Form:C1466.current_item.actualCloseDate; Internal date short:K1:7); \
"verifiedBy"; Form:C1466.current_item.verifiedBy; \
"internal"; (Form:C1466.current_item.internal) ? $check : $uncheked; \
"external"; (Form:C1466.current_item.internal) ? $uncheked : $check; \
"teamLearders"; Form:C1466.current_item.correctiveActionReport.teamLearders; \
"supervisor"; Form:C1466.current_item.correctiveActionReport.supervisor; \
"teamMembers"; Form:C1466.current_item.correctiveActionReport.teamMembers; \
"d2"; Form:C1466.current_item.correctiveActionReport.d2; \
"d3"; Form:C1466.current_item.correctiveActionReport.d3; \
"d3TargetDate"; String:C10(Form:C1466.current_item.correctiveActionReport.d3TargetDate; Internal date short:K1:7); \
"d3ActualDate"; String:C10(Form:C1466.current_item.correctiveActionReport.d3ActualDate; Internal date short:K1:7); \
"d4"; Form:C1466.current_item.correctiveActionReport.d4; \
"d5"; Form:C1466.current_item.correctiveActionReport.d5; \
"d6"; Form:C1466.current_item.correctiveActionReport.d6; \
"d6TargetDate"; String:C10(Form:C1466.current_item.correctiveActionReport.d6TargetDate; Internal date short:K1:7); \
"d6ActualDate"; String:C10(Form:C1466.current_item.correctiveActionReport.d6ActualDate; Internal date short:K1:7); \
"d7"; Form:C1466.current_item.correctiveActionReport.d7; \
"d7TargetDate"; String:C10(Form:C1466.current_item.correctiveActionReport.d7TargetDate; Internal date short:K1:7); \
"d7ActualDate"; String:C10(Form:C1466.current_item.correctiveActionReport.d7ActualDate; Internal date short:K1:7); \
"controlPlan"; (Form:C1466.current_item.correctiveActionReport.controlPlan) ? $check : $uncheked; \
"training"; (Form:C1466.current_item.correctiveActionReport.training) ? $check : $uncheked; \
"flowchart"; (Form:C1466.current_item.correctiveActionReport.flowchart) ? $check : $uncheked; \
"procWork"; (Form:C1466.current_item.correctiveActionReport.procWork) ? $check : $uncheked; \
"addToInternalAudit"; (Form:C1466.current_item.correctiveActionReport.addToInternalAudit) ? $check : $uncheked; \
"others"; (Form:C1466.current_item.correctiveActionReport.others) ? $check : $uncheked; \
"othersText"; (Form:C1466.current_item.correctiveActionReport.others) ? Form:C1466.current_item.correctiveActionReport.othersText : ""\
)

$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/8d_corrective_action_report.4wp")
$wpDoc:=WP Import document:C1318($file.platformPath)

WP SET DATA CONTEXT:C1786($wpDoc; $context)

SET PRINT PREVIEW:C364(True:C214)

$path:=System folder:C487(Desktop:K41:16)+String:C10(Form:C1466.current_item.qcarNumber)+".pdf"
WP EXPORT DOCUMENT:C1337($wpDoc; $path; wk pdf:K81:315)

OPEN URL:C673($path)

//OPEN URL("test.pdf")