//%attributes = {"executedOnServer":true}
// _diag_buyLineJsonSrv -> Object
// READ-ONLY. The server half of _diag_buyLineJson (run that one). Nothing is saved.
// A Remote client fails on ds.BuyingOrderLine.all() with "JSON mal-formé ... ',' found":
// some buy line holds a value the server cannot write as JSON. Here, on the server, every
// line is checked:
//   - every stored number attribute: NaN or infinite
//   - the whole line, as toObject(): JSON Stringify, then JSON Parse of that text
// Writes Project/imports/buyLineJson_diag.txt and returns {checked; bad; byField; path}.
//
// Other actions, for _diag_buyLineClient:
//   "uuids"  -> {uuids: every buy line UUID}
//   "dump"   $param = UUIDs -> {lines: [{UUID; stored: toObject(); computed: {attr: value
//            or "ERROR: ..."}}]}: each computed attribute evaluated here, in Try()
//   "write"  $param = {name; text} -> written to Project/imports/<name> -> {path}

#DECLARE($action : Text; $param : Variant)->$result : Object

var $line : cs:C1710.BuyingOrderLineEntity
var $attr; $json; $text; $problem; $snippet; $uuid : Text
var $numberAttrs; $out; $problems; $errors : Collection
var $v : Real
var $parsed; $value : Variant
var $pos; $start : Integer
var $file : 4D:C1709.File
var $dump : Object

Case of
	: ($action="uuids")
		return {uuids: ds:C1482.BuyingOrderLine.all().distinct("UUID")}

	: ($action="dump")
		$result:={lines: []}
		For each ($uuid; $param)
			$line:=ds:C1482.BuyingOrderLine.get($uuid)
			If ($line=Null:C1517)
				$result.lines.push({UUID: $uuid; missing: True:C214})
				continue
			End if
			$dump:={UUID: $uuid; stored: $line.toObject(); computed: {}}
			For each ($attr; ds:C1482.BuyingOrderLine)
				If (ds:C1482.BuyingOrderLine[$attr].kind="calculated")
					$value:=Try($line[$attr])
					$errors:=Last errors:C1799
					If ($errors#Null:C1517) && ($errors.length>0)
						$dump.computed[$attr]:="ERROR: "+String:C10($errors[$errors.length-1].message)
					Else
						$dump.computed[$attr]:=$value
					End if
				End if
			End for each
			$result.lines.push($dump)
		End for each
		return $result

	: ($action="write")
		$file:=Folder:C1567(fk database folder:K87:14).folder("Project/imports").file(String:C10($param.name))
		$file.setText(String:C10($param.text))
		return {path: $file.platformPath}
End case

//---the stored number attributes of the dataclass
$numberAttrs:=[]
For each ($attr; ds:C1482.BuyingOrderLine)
	If (ds:C1482.BuyingOrderLine[$attr].kind="storage") && (ds:C1482.BuyingOrderLine[$attr].type="number")
		$numberAttrs.push($attr)
	End if
End for each

$result:={checked: 0; bad: 0; byField: {}}
$out:=[]

For each ($line; ds:C1482.BuyingOrderLine.all())
	$result.checked:=$result.checked+1
	$problems:=[]

	//---numbers
	For each ($attr; $numberAttrs)
		$v:=Num:C11($line[$attr])
		$text:=Uppercase:C13(String:C10($v))
		If ($v#$v) || (Abs:C99($v)>1E+300) || (Position:C15("NAN"; $text)>0) || (Position:C15("INF"; $text)>0)
			$problems.push($attr+" = "+String:C10($v))
			$result.byField[$attr]:=Num:C11($result.byField[$attr])+1
		End if
	End for each

	//---the line as JSON, the way it travels to a client
	$json:=String:C10(Try(JSON Stringify:C1217($line.toObject())))
	$parsed:=Try(JSON Parse:C1218($json))
	If ($json="") || (Value type:C1509($parsed)#Is object:K8:27)
		$errors:=Last errors:C1799
		$problem:="JSON does not parse back"
		If ($errors#Null:C1517) && ($errors.length>0)
			$problem+=": "+String:C10($errors[$errors.length-1].message)
		End if
		//---show the text around the first value that is missing (":," ":}" ":]")
		$pos:=Position:C15(":,"; $json)
		If ($pos=0)
			$pos:=Position:C15(":}"; $json)
		End if
		If ($pos=0)
			$pos:=Position:C15(":]"; $json)
		End if
		If ($pos>0)
			$start:=($pos>80) ? $pos-80 : 1
			$snippet:=Substring:C12($json; $start; 120)
			$problem+="\r      near: ..."+$snippet+"..."
		End if
		$problems.push($problem)
		$result.byField["(json)"]:=Num:C11($result.byField["(json)"])+1
	End if

	If ($problems.length>0)
		$result.bad:=$result.bad+1
		If ($result.bad<=200)
			$out.push("BO "+String:C10($line.boNumber)+"  line number "+String:C10($line.number)+\
				"  legacySeqNum "+String:C10($line.legacySeqNum)+"  UUID "+$line.UUID)
			$out.push("    "+$problems.join("\r    "))
		End if
	End if
End for each

$out.unshift("_diag_buyLineJson "+String:C10(Current date:C33; ISO date:K1:8)+" "+String:C10(Current time:C178); \
	"buy lines checked: "+String:C10($result.checked)+"   with a problem: "+String:C10($result.bad); \
	"by field: "+JSON Stringify:C1217($result.byField); \
	"number attributes checked: "+$numberAttrs.join(", "); \
	(($result.bad>200) ? "(only the first 200 lines are listed)" : ""); \
	"")

$file:=Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("buyLineJson_diag.txt")
$file.setText($out.join("\r\n"))
$result.path:=$file.platformPath
