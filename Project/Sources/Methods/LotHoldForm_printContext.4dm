//%attributes = {}
// LotHoldForm_printContext($formFieldName; $form; $lot) -> the {{tokens}} of the GAF-1014 / GAF-1514
// models (LotHoldForm_print). A token added to a model in the editor needs a key here.
//
// Both forms
//   {{customer}} {{traveler}} {{device}} {{package}} {{lotQty}} {{originator}} {{date}} {{time}}
//   {{machine}} {{problemDetail}} {{disposition}}
// GAF-1014 (NCMN)
//   {{ncmnNumber}} {{qtyInspected}} {{qtyRejected}} {{qtyAccepted}}
//   {{boxOnHold}} {{onHoldAt}} {{boxWillHold}} {{willHoldAt}} {{boxInfo}}
//   {{boxYield}} {{boxCount}} {{boxMaterial}} {{boxOther}}
//   {{boxCarNo}} {{boxCarYes}} {{carNumber}}
//   {{boxCs}} {{boxEng}} {{boxQa}} {{boxProd}} (the box of each approval)
//   {{csName}} {{csDate}} {{engName}} {{engDate}} {{qaName}} {{qaDate}} {{prodName}} {{prodDate}}
// GAF-1514 (ISSNF)
//   {{location}} {{informTo}} {{approvalName}} {{approvalDate}}
// A box is "X" when ticked, empty when not (the form draws the box). Every value is text: _wpFill writes it as it is.
#DECLARE($formFieldName : Text; $form : Object; $lot : 4D:C1709.Entity)->$context : Object

var $customer : Text
var $lotQty : Text
var $location : Text
var $onHold : Boolean
var $willHold : Boolean
var $info : Boolean
var $value : Variant
var $date : Date

$customer:=String:C10($form.customer)
If ($customer="") && ($lot.job#Null:C1517) && ($lot.job.customer#Null:C1517)
	$customer:=String:C10($lot.job.customer.name)
End if
If ($customer="")
	$customer:=String:C10($lot.customer)
End if

$lotQty:=String:C10($form.lotQuantity)
If ($lotQty="") || ($lotQty="0")
	$lotQty:=String:C10($lot.ourCount)
End if

$context:=New object:C1471(\
"customer"; $customer; \
"traveler"; $lot.displayNumber; \
"device"; String:C10($lot.device); \
"package"; String:C10($lot.packageType); \
"lotQty"; $lotQty; \
"originator"; String:C10($form.originator); \
"date"; ""; \
"time"; ""; \
"machine"; String:C10($form.machine); \
"problemDetail"; String:C10($form.problemDetail); \
"disposition"; String:C10($form.disposition)\
)

// the date: a Date from the calendar, or its text once the form went through JSON (saved)
$value:=$form.problemDate
Case of
	: (Value type:C1509($value)=Is date:K8:7)
		$date:=$value
	: (Value type:C1509($value)=Is text:K8:3) && (Match regex:C1019("^\\d{4}-\\d{2}-\\d{2}"; $value; 1))
		$date:=Date:C102(Substring:C12($value; 1; 10))
	Else
		$date:=!00-00-00!
End case
Case of
	: ($date#!00-00-00!)
		$context.date:=String:C10($date; Internal date short:K1:7)
	: (Value type:C1509($value)=Is text:K8:3)
		$context.date:=$value
End case

// the time: typed text, or a time stored as seconds
$value:=$form.problemTime
Case of
	: (Value type:C1509($value)=Is real:K8:4) || (Value type:C1509($value)=Is longint:K8:6)
		$context.time:=($value=0) ? "" : String:C10(Time:C179($value); HH MM:K7:2)
	: ($value#Null:C1517)
		$context.time:=String:C10($value)
End case

$location:=String:C10($form.statusLocation)
If ($formFieldName="ISSNF")
	$location:=String:C10($form.location)
End if
If ($location="")
	$location:=LotHoldForm_holdLocation($lot)
End if

Case of
	: ($formFieldName="NCMN")
		$context.ncmnNumber:=String:C10($form.ncmnNumber)
		$context.qtyInspected:=String:C10($form.quantityInspected)
		$context.qtyRejected:=String:C10($form.quantityRejected)
		$context.qtyAccepted:=String:C10($form.quantityAccepted)

		// status: a form saved before these fields existed prints as "on hold at"
		$onHold:=Bool:C1537($form.statusOnHold)
		$willHold:=Bool:C1537($form.statusWillHold)
		$info:=Bool:C1537($form.statusInfo)
		If (Not:C34($onHold)) && (Not:C34($willHold)) && (Not:C34($info))
			$onHold:=True:C214
		End if
		$context.boxOnHold:=LotHoldForm_printBox($onHold)
		$context.onHoldAt:=$onHold ? $location : ""
		$context.boxWillHold:=LotHoldForm_printBox($willHold)
		$context.willHoldAt:=$willHold ? $location : ""
		$context.boxInfo:=LotHoldForm_printBox($info)

		$context.boxYield:=LotHoldForm_printBox(Bool:C1537($form.reasonYield))
		$context.boxCount:=LotHoldForm_printBox(Bool:C1537($form.reasonCount))
		$context.boxMaterial:=LotHoldForm_printBox(Bool:C1537($form.reasonMaterial))
		$context.boxOther:=LotHoldForm_printBox(Bool:C1537($form.reasonOther))

		$context.boxCarYes:=LotHoldForm_printBox(Bool:C1537($form.carIssued))
		$context.boxCarNo:=LotHoldForm_printBox(Not:C34(Bool:C1537($form.carIssued)))
		$context.carNumber:=String:C10($form.carNumber)

		// approvals: ticked, who signed (the code scanned at the tick, with the name) and when
		$context.boxCs:=LotHoldForm_printBox(Bool:C1537($form.approvalCustomerService))
		$context.boxEng:=LotHoldForm_printBox(Bool:C1537($form.approvalEngineering))
		$context.boxQa:=LotHoldForm_printBox(Bool:C1537($form.approvalQAQC))
		$context.boxProd:=LotHoldForm_printBox(Bool:C1537($form.approvalProduction))
		$context.csName:=Bool:C1537($form.approvalCustomerService) ? cs:C1710.ga_operator.me.label(String:C10($form.approvalCustomerServiceBy)) : ""
		$context.csDate:=Bool:C1537($form.approvalCustomerService) ? String:C10($form.dateCustomerService) : ""
		$context.engName:=Bool:C1537($form.approvalEngineering) ? cs:C1710.ga_operator.me.label(String:C10($form.approvalEngineeringBy)) : ""
		$context.engDate:=Bool:C1537($form.approvalEngineering) ? String:C10($form.dateEngineering) : ""
		$context.qaName:=Bool:C1537($form.approvalQAQC) ? cs:C1710.ga_operator.me.label(String:C10($form.approvalQAQCBy)) : ""
		$context.qaDate:=Bool:C1537($form.approvalQAQC) ? String:C10($form.dateQAQC) : ""
		$context.prodName:=Bool:C1537($form.approvalProduction) ? cs:C1710.ga_operator.me.label(String:C10($form.approvalProductionBy)) : ""
		$context.prodDate:=Bool:C1537($form.approvalProduction) ? String:C10($form.dateProduction) : ""

	: ($formFieldName="ISSNF")
		$context.location:=$location
		$context.informTo:=String:C10($form.informTo)
		$context.approvalName:=Bool:C1537($form.approvalCustomerService) ? cs:C1710.ga_operator.me.label(String:C10($form.approvalCustomerServiceBy)) : ""
		$context.approvalDate:=Bool:C1537($form.approvalCustomerService) ? String:C10($form.dateCustomerService) : ""
End case
