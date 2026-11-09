//%attributes = {}
// _import_quotesRun
// Runs the legacy quote import (__import_data_quote, on the server) after checking that the
// four JSON files are in the data folder's DataJson and asking first: the import replaces every
// quote, quote line and assumption. Run __import_quote_param before, so the quote statuses exist.

var $check : Object
var $result : Object

$check:=__import_data_quote("check")
If ($check.missing.length>0)
	cs.sfw_dialog.me.alert("Missing in the data folder's DataJson: "+$check.missing.join(", ")+".\rNothing was changed.")
	return
End if

If (ds.QuoteStatus.all().length=0)
	cs.sfw_dialog.me.alert("There are no quote statuses yet: run __import_quote_param first.\rNothing was changed.")
	return
End if

If (Not(cs.sfw_dialog.me.confirm("This replaces all "+String($check.nbQuotes)+" quotes, their lines and the assumptions with the legacy export.\rContinue?"; "Replace"; "Cancel")))
	return
End if

$result:=__import_data_quote("run")
If (Bool($result.success))
	cs.sfw_dialog.me.info($result.summary+"\r\rDetails in Project/imports/quote_import.txt")
Else
	cs.sfw_dialog.me.alert("The import did not run.")
End if
