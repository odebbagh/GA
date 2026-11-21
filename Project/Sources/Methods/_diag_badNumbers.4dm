//%attributes = {"executedOnServer":true}
// _diag_badNumbers($dataclasses) -> {bad: [{dataclass; UUID; attributes}]; checked; report}
// READ ONLY. Finds the records a 4D Remote client cannot load. When a client asks for records,
// the server sends them as JSON; a number field holding an impossible value (infinite, or
// "not a number", the result of a division by zero) is written as nothing ("field":,) and the
// client stops with error 550/551 "JSON mal-formé ... ',' found where a value was expected".
// This method does here, on the server, what the transport does: each record of the given
// dataclasses (default: the ones the accounting import reads) is turned into JSON and read
// back; a record that fails is listed with the attributes that fail on their own.
// Report: Project/imports/bad_numbers.txt. Fix: _fix_badNumbers.
#DECLARE($dataclasses : Collection)->$result : Object

var $dc; $attr; $text : Text
var $e : 4D.Entity
var $badAttrs; $lines : Collection
var $checked : Integer
var $parsed : Variant

If ($dataclasses=Null) || ($dataclasses.length=0)
	$dataclasses:=["BuyingOrderLine"; "BuyingOrder"; "GLAccount"; "Customer"; "PurchaseOrder"; "Job"; "JobInvoice"; "Asset"; "Supplier"]
End if
$result:={bad: []; checked: 0}
$lines:=[]

For each ($dc; $dataclasses)
	If (ds[$dc]=Null)
		continue
	End if
	For each ($e; ds[$dc].all())
		$checked+=1
		$text:=JSON Stringify($e.toObject())
		$parsed:=Try(JSON Parse($text))
		If (Value type($parsed)=Is object)
			continue
		End if
		// the record fails: which attributes fail on their own
		$badAttrs:=[]
		For each ($attr; ds[$dc])
			If (ds[$dc][$attr].kind#"storage")
				continue
			End if
			$parsed:=Try(JSON Parse(JSON Stringify({v: $e[$attr]})))
			If (Value type($parsed)#Is object)
				$badAttrs.push({name: $attr; type: ds[$dc][$attr].type; shown: String($e[$attr])})
			End if
		End for each
		$result.bad.push({dataclass: $dc; UUID: String($e.getKey()); attributes: $badAttrs})
		$lines.push($dc+"  "+String($e.getKey())+"  "+$badAttrs.extract("name").join(", ")+"  ("+$badAttrs.extract("shown").join(" | ")+")")
	End for each
End for each
$result.checked:=$checked

$lines.insert(0; "RECORDS A CLIENT CANNOT LOAD (impossible numbers) - "+String(Current date)+" "+String(Current time; HH MM))
$lines.insert(1; "Checked: "+String($checked)+" records of "+$dataclasses.join(", ")+" - failing: "+String($result.bad.length))
$lines.insert(2; ($result.bad.length=0) ? "None: every record loads." : "Fix: _fix_badNumbers (the impossible numbers become 0).")
$lines.insert(3; "")
$result.report:=$lines.join("\r\n")
Folder(fk database folder).folder("Project/imports").file("bad_numbers.txt").setText($result.report)
