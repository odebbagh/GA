Class extends Entity

	// what Quote_revisionView and panel_quote.quoteDocument read: the frozen copy (a copy, so a
	// viewer can't change the record)
Function preview()->$preview : Object
	$preview:=OB Copy(This.snapshot || New object)
	$preview.quoteLines:=$preview.quoteLines || New collection
	$preview.assumptions:=$preview.assumptions || New collection
	$preview.conditions:=$preview.conditions || New collection

	// list columns of the Revisions tab
Function get label()->$label : Text
	$label:=String(This.snapshot.quoteRevision)
	If ($label="")
		$label:="(none)"
	End if

Function get dateText()->$text : Text
	$text:=String(cs.sfw_stmp.me.getDate(This.stmp))+" "+String(cs.sfw_stmp.me.getTime(This.stmp); HH MM)

Function get userName()->$name : Text
	If (This.user#Null)
		$name:=New collection(This.user.firstName; This.user.lastName).join(" "; ck ignore null or empty)
	End if

Function get totalText()->$text : Text
	$text:=_ga_usdText(Num(This.snapshot.total))

Function get noteFirstLine()->$line : Text
	$line:=Split string(Replace string(This.note; "\n"; "\r"); "\r").first() || ""
