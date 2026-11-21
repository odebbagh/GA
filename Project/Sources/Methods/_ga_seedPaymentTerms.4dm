//%attributes = {}
// _ga_seedPaymentTerms
// List action "Create the usual terms" of Payment terms (and safe to run by hand): creates the
// usual terms when missing - Due on receipt, Net 15, Net 30 (default), Net 45, Net 60, 2% 10 Net 30.
var $created : Integer
$created:=ds.PaymentTerm.seed()
cs.sfw_dialog.me.info(Choose($created=0; "The usual terms already exist."; String($created)+" term(s) created. Net 30 is the default when a customer has no term."))
If (Form#Null)
	If (Form.sfw#Null)
		Form.sfw.lb_items_search()
	End if 
End if 
