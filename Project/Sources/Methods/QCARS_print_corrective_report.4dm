//%attributes = {}
var $check; $uncheked : Picture
var $context; $item; $lot; $customer; $car : Object
var $device; $customerName; $lotNumber; $poNumber; $leader : Text
$wpDoc:=WP New:C1317()

READ PICTURE FILE:C678(Folder:C1567(fk resources folder:K87:11).file(cs:C1710.sfw_definition.me.globalParameters.folders.projectResources+"/image/picto/checked.png").platformPath; $check)
READ PICTURE FILE:C678(Folder:C1567(fk resources folder:K87:11).file(cs:C1710.sfw_definition.me.globalParameters.folders.projectResources+"/image/picto/unchecked.png").platformPath; $uncheked)

$item:=Form:C1466.current_item
$lot:=$item.lot
$customer:=$item.customer
$car:=$item.correctiveActionReport
If ($car=Null:C1517)
	$car:=New object:C1471
End if 

$device:=String:C10($item.device)
If ($device="") && ($lot#Null:C1517)
	$device:=String:C10($lot.device)
End if 
$customerName:=($customer#Null:C1517) ? String:C10($customer.name) : ""
$lotNumber:=($lot#Null:C1517) ? String:C10($lot.lotNumber) : ""
$poNumber:=($lot#Null:C1517) ? String:C10($lot.poNumber) : ""
$leader:=$item.teamLeaderName()

$context:=New object:C1471(\
"dateOpen"; $item.openDate; \
"qcarNumber"; $item.qcarNumber; \
"customerName"; $customerName; \
"device"; $device; \
"lotNumber"; $lotNumber; \
"poNumber"; $poNumber; \
"initialResponse"; $item.initialResponse; \
"targetCloseDate"; String:C10($item.targetCloseDate; Internal date short:K1:7); \
"revisionDate"; String:C10($item.revisionDate; Internal date short:K1:7); \
"initiator8D"; $item.initiator8D; \
"actualCloseDate"; String:C10($item.actualCloseDate; Internal date short:K1:7); \
"verifiedBy"; $item.verifiedBy; \
"internal"; ($item.internal) ? $check : $uncheked; \
"external"; ($item.internal) ? $uncheked : $check; \
"teamLeaders"; $leader; \
"teamLearders"; $leader; \
"supervisor"; $car.supervisor; \
"teamMembers"; $car.teamMembers; \
"d2"; $car.d2; \
"d3"; $car.d3; \
"d3TargetDate"; String:C10($car.d3TargetDate; Internal date short:K1:7); \
"d3ActualDate"; String:C10($car.d3ActualDate; Internal date short:K1:7); \
"d4"; $car.d4; \
"d5"; $car.d5; \
"d6"; $car.d6; \
"d6TargetDate"; String:C10($car.d6TargetDate; Internal date short:K1:7); \
"d6ActualDate"; String:C10($car.d6ActualDate; Internal date short:K1:7); \
"d7"; $car.d7; \
"d7TargetDate"; String:C10($car.d7TargetDate; Internal date short:K1:7); \
"d7ActualDate"; String:C10($car.d7ActualDate; Internal date short:K1:7); \
"controlPlan"; (Bool:C1537($car.controlPlan)) ? $check : $uncheked; \
"training"; (Bool:C1537($car.training)) ? $check : $uncheked; \
"flowchart"; (Bool:C1537($car.flowchart)) ? $check : $uncheked; \
"procWork"; (Bool:C1537($car.procWork)) ? $check : $uncheked; \
"addToInternalAudit"; (Bool:C1537($car.addToInternalAudit)) ? $check : $uncheked; \
"others"; (Bool:C1537($car.others)) ? $check : $uncheked; \
"othersText"; (Bool:C1537($car.others)) ? String:C10($car.othersText) : ""\
)

$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/8d_corrective_action_report.4wp")
$wpDoc:=WP Import document:C1318($file.platformPath)

WP SET DATA CONTEXT:C1786($wpDoc; $context)

SET PRINT PREVIEW:C364(True:C214)

$path:=System folder:C487(Desktop:K41:16)+String:C10($item.qcarNumber)+".pdf"
WP EXPORT DOCUMENT:C1337($wpDoc; $path; wk pdf:K81:315)

OPEN URL:C673($path)

//OPEN URL("test.pdf")
