//%attributes = {}
// _import_paymentTerms($options)
// The usual payment terms (Due on receipt, Net 15, Net 30 = default, Net 45, Net 60, 2% 10 Net 30),
// created when missing (PaymentTerm.seed). Step of _import_accounting / _import_all, before
// _import_customerAR, which adds the "Net N" terms legacy customers use.
// $options (optional): {unattended: True} - the message goes to import_messages.txt.
#DECLARE($options : Object)
var $created : Integer
var $default : cs.PaymentTermEntity
$created:=ds.PaymentTerm.seed()
$default:=ds.PaymentTerm.defaultTerm()
_import_notify($options; "Payment terms: "+String($created)+" created, "+String(ds.PaymentTerm.getCount())+" in all. Default: "+(($default=Null) ? "none" : $default.label)+".")
