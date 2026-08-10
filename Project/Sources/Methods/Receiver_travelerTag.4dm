//%attributes = {}
var $check; $uncheked : Picture
var $context_o : Object
var $parameters : Object:=New object:C1471
$wpDoc:=WP New:C1317()

$parameters.data:=Form:C1466.current_item.moreData.barcodeData
//$parameters.text:=Form.current_item.lotNumber
$barcode:=_ga_generateBarCode($parameters)  //Form.current_item.lotNumber)

$context:=New object:C1471(\
"travelerNumber"; Form:C1466.current_item.job.jobNumber; \
"jobNumber"; Form:C1466.current_item.job.jobNumber; \
"partNumber"; "partNumber"; \
"lotNumber"; Form:C1466.current_item.lotNumber; \
"customerNumber"; Form:C1466.current_item.job.purchaseOrder.customer.name; \
"customerPo"; Form:C1466.current_item.job.purchaseOrder.poNumber; \
"buildQty"; Form:C1466.current_item.job.qty; \
"process"; Form:C1466.current_item.job.process; \
"qualifier"; Form:C1466.current_item.prQualifier; \
"dpaRating"; "DX-A1"; \
"bin"; ""; \
"esdClass"; "0"; \
"barcode"; $barcode\
)

$file:=Folder:C1567(fk resources folder:K87:11).file("4DWriteProPrintTemplates/receiver_traveler_tag.4wp")
$wpDoc:=WP Import document:C1318($file.platformPath)

WP SET DATA CONTEXT:C1786($wpDoc; $context)

SET PRINT PREVIEW:C364(True:C214)

$path:=System folder:C487(Desktop:K41:16)+String:C10(Form:C1466.current_item.lotNumber)+".pdf"
WP EXPORT DOCUMENT:C1337($wpDoc; $path; wk pdf:K81:315)

OPEN URL:C673($path)