//%attributes = {}
var $current_rma : Object
$current_rma:=Null:C1517
If (Form:C1466.current_item.rmas#Null:C1517) && (Form:C1466.current_item.rmas.length>0)
	$current_rma:=Form:C1466.current_item.rmas[0]
End if 

If ($current_rma=Null:C1517)
	cs:C1710.sfw_dialog.me.alert("This CAR has no linked RMA to print.")
	return 
End if 

PRINT SETTINGS:C106()

OPEN PRINTING JOB:C995

SET PRINT OPTION:C733(Orientation option:K47:2; 1)

$form:=New object:C1471(\
	"dateReceived"; $current_rma.dateReceived; \
	"customer"; $current_rma.customer; \
	"customerPo"; $current_rma.customerPo; \
	"partNumber"; $current_rma.partNumber; \
	"rmaNumber"; $current_rma.rmaNumber; \
	"contact"; $current_rma.contact; \
	"lotNumber"; $current_rma.lotNumber; \
	"gaInvoiceNumber"; $current_rma.gaInvoiceNumber; \
	"authorizedBy"; $current_rma.authorizedBy; \
	"phone"; $current_rma.phone; \
	"status"; $current_rma.status; \
	"dateClose"; $current_rma.dateClose\
	)

Print form:C5([RMA:44]; "print_rma"; $form; Form header:K43:3)

$form:=New object:C1471(\
	"reasonForReturn"; $current_rma.reasonForReturn; \
	"description"; $current_rma.description; \
	"materialDisposition"; $current_rma.materialDisposition\
	)

Print form:C5([RMA:44]; "print_rma"; $form; Form detail:K43:1)

$form:=New object:C1471()
Print form:C5([RMA:44]; "print_rma"; $form; Form footer:K43:2)

CLOSE PRINTING JOB:C996
