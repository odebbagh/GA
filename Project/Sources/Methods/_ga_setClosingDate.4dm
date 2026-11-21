//%attributes = {}
// _ga_setClosingDate
// List action "Closing date..." of Chart of Accounts and Journal Entries.
// The closing date locks the books: no journal entry dated on or before it can be written,
// changed or voided (ga_ledger.isOpen). It is set once a month has been checked and reported,
// usually to the last day of that month. Moving it back reopens the months after it.
var $current; $new : Date
var $answer : Object
var $text; $message : Text
var $result : Object

$current:=cs.ga_ledger.me.closingDate()
$message:="The books are locked up to and including this date: nothing dated on or before it can be written, changed or voided."+Char(Carriage return)+Char(Carriage return)
If ($current=!00-00-00!)
	$message+="The books were never closed."
Else 
	$message+="Closed up to "+String($current; System date long)+"."
End if 
$message+=Char(Carriage return)+"New closing date (empty = never closed):"
$answer:=cs.sfw_dialog.me.request($message; ($current=!00-00-00!) ? "" : String($current); "Set"; "Cancel"; "trimSpace")
If (Not(Bool($answer.ok)))
	return 
End if 
$text:=String($answer.answer)
If ($text="")
	$new:=!00-00-00!
Else 
	$new:=Date($text)
	If ($new=!00-00-00!)
		cs.sfw_dialog.me.alert("\""+$text+"\" is not a date.")
		return 
	End if 
	If ($new>Current date)
		cs.sfw_dialog.me.alert("The closing date cannot be in the future.")
		return 
	End if 
End if 
If ($new=$current)
	return 
End if 
If ($new<$current)
	If (Not(cs.sfw_dialog.me.confirm("This REOPENS the books after "+Choose($new=!00-00-00!; "the start"; String($new))+": entries up to "+String($current)+" can be changed again."+Char(Carriage return)+Char(Carriage return)+"Reopen?"; "Reopen"; "Cancel")))
		return 
	End if 
End if 
$result:=cs.ga_ledger.me.setClosingDate($new)
If (Not(Bool($result.success)))
	cs.sfw_dialog.me.alert("The closing date could not be saved: "+String($result.statusText))
	return 
End if 
cs.sfw_dialog.me.info(Choose($new=!00-00-00!; "The books are open: no closing date."; "The books are closed up to "+String($new; System date long)+"."))
