//%attributes = {}
// _fix_badNumbers
// Repairs the records a 4D Remote client cannot load because a number field holds an impossible
// value (infinite / not a number, see _diag_badNumbers): Report only / Apply. Apply sets those
// number fields to 0 on the server (_fix_badNumbersSrv). An Object field that fails is only
// reported - it needs a look before anything is changed.
// Report: Project/imports/bad_numbers.txt.

var $diag; $done : Object
var $numbers : Integer
var $bad : Object

$diag:=_diag_badNumbers([])
For each ($bad; $diag.bad)
	$numbers+=$bad.attributes.query("type = :1"; "number").length
End for each
If ($diag.bad.length=0)
	cs.sfw_dialog.me.info("Every record loads: nothing to repair ("+String($diag.checked)+" records checked).")
	return
End if
If (Not(cs.sfw_dialog.me.confirm(String($diag.bad.length)+" record(s) cannot be loaded by a client; "+String($numbers)+" number field(s) hold an impossible value."+\
"\r\rApply sets those numbers to 0. Details: Project/imports/bad_numbers.txt"; "Apply"; "Report only")))
	return
End if
$done:=_fix_badNumbersSrv($diag.bad)
cs.sfw_dialog.me.info(String($done.fixed)+" number field(s) set to 0, "+String($done.failed)+" record(s) could not be saved."+\
Choose($done.objects=0; ""; "\r"+String($done.objects)+" Object field(s) left as they are: see bad_numbers.txt."))
