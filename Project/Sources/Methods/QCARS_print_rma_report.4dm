//%attributes = {}
// Purpose: Print the RMA form from the RMA entry, or the first linked RMA from a CAR.
// modified by 4D/PS [2026-october-05]
var $rma : Object
var $customerName : Text
var $form : Object

$rma:=Null:C1517
If (Form:C1466.sfw#Null:C1517) && (Form:C1466.sfw.entry#Null:C1517)
	Case of 
		: (Form:C1466.sfw.entry.dataclass="RMA")
			$rma:=Form:C1466.current_item
		: (Form:C1466.sfw.entry.dataclass="Qcar")
			If (Form:C1466.current_item#Null:C1517) && (Form:C1466.current_item.rmas#Null:C1517) && (Form:C1466.current_item.rmas.length>0)
				$rma:=Form:C1466.current_item.rmas[0]
			End if 
	End case 
End if 

If ($rma=Null:C1517)
	If (Form:C1466.sfw#Null:C1517) && (Form:C1466.sfw.entry#Null:C1517) && (Form:C1466.sfw.entry.dataclass="Qcar")
		cs:C1710.sfw_dialog.me.alert("This CAR has no linked RMA to print.")
	Else 
		cs:C1710.sfw_dialog.me.alert("There is no RMA to print.")
	End if 
	return 
End if 

$customerName:=""
If ($rma.qcar#Null:C1517) && ($rma.qcar.customer#Null:C1517)
	$customerName:=String:C10($rma.qcar.customer.name)
End if 

PRINT SETTINGS:C106()
If (OK=0)
	return 
End if

OPEN PRINTING JOB:C995

SET PRINT OPTION:C733(Orientation option:K47:2; 1)

$form:=New object:C1471(\
	"dateReceived"; $rma.dateReceived; \
	"customer"; $customerName; \
	"customerPo"; $rma.customerPo; \
	"partNumber"; $rma.partNumber; \
	"rmaNumber"; $rma.rmaNumber; \
	"contact"; $rma.contact; \
	"travelerNumber"; $rma.travelerNumber; \
	"invoiceNumber"; $rma.invoiceNumber; \
	"authorizedBy"; $rma.authorizedBy; \
	"phone"; $rma.phone; \
	"status"; $rma.status; \
	"dateClose"; $rma.dateClose\
	)

Print form:C5([RMA:44]; "print_rma"; $form; Form header:K43:3)

$form:=New object:C1471(\
	"reasonForReturn"; $rma.reasonForReturn; \
	"description"; $rma.description; \
	"materialDisposition"; $rma.materialDisposition\
	)

Print form:C5([RMA:44]; "print_rma"; $form; Form detail:K43:1)

$form:=New object:C1471(\
	"qaQc"; $rma.qaQc; \
	"customerSvc"; $rma.customerSvc; \
	"currentDate"; Current date:C33; \
	"phone"; $rma.phone\
	)
Print form:C5([RMA:44]; "print_rma"; $form; Form footer:K43:2)

CLOSE PRINTING JOB:C996
