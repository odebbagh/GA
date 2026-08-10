

var $wpDoc : Object
var $context : Object

$context:=New object:C1471()
$wpDoc:=WP New:C1317()

$context.assignedID:=Form:C1466.current_item.assignedID
$context.startDate:=Storage:C1525.cache.startDate
$context.endDate:=Storage:C1525.cache.endDate
$context.today:=Current date:C33
$context.now:=String:C10(Current time:C178; HH MM AM PM:K7:5)
$context.currentUser:=String:C10(Current user:C182)

$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/equipmentUsageLog.4wp")
$wpDoc:=WP Import document:C1318($file.platformPath)

WP GET ATTRIBUTES:C1345($wpDoc; wk font bold:K81:68; $bold; wk font size:K81:66; $fontSize; wk font family:K81:65; $fontFamily)

WP INSERT DOCUMENT:C1411($wpDoc; Form:C1466.wp; wk append:K81:179)
WP SET DATA CONTEXT:C1786($wpDoc; $context)

PRINT SETTINGS:C106(2)
WP PRINT:C1343($wpDoc)
