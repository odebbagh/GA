//%attributes = {}
// _import_priceListCsv
// The rows of a CSV text as objects named by the header row (_import_priceList): comma separated,
// fields in double quotes may hold commas, line breaks and doubled quotes (""). Header names are
// trimmed; empty lines are skipped.
#DECLARE($csv : Text)->$rows : Collection

var $records; $headers : Collection
var $record : Collection
var $field; $char : Text
var $i; $col : Integer
var $inQuotes : Boolean
var $row : Object

// split into records of fields, quotes aware
$records:=New collection:C1472
$record:=New collection:C1472
$field:=""
$inQuotes:=False:C215
$csv:=Replace string:C233($csv; "\r\n"; "\n")
$csv:=Replace string:C233($csv; "\r"; "\n")
For ($i; 1; Length:C16($csv))
	$char:=$csv[[$i]]
	Case of
		: ($inQuotes)
			If ($char="\"")
				If ($i<Length:C16($csv)) && ($csv[[$i+1]]="\"")
					$field+="\""
					$i+=1
				Else
					$inQuotes:=False:C215
				End if
			Else
				$field+=$char
			End if
		: ($char="\"")
			$inQuotes:=True:C214
		: ($char=",")
			$record.push($field)
			$field:=""
		: ($char="\n")
			$record.push($field)
			$records.push($record)
			$record:=New collection:C1472
			$field:=""
		Else
			$field+=$char
	End case
End for
If ($field#"") || ($record.length>0)
	$record.push($field)
	$records.push($record)
End if

// objects named by the header
$rows:=New collection:C1472
If ($records.length=0)
	return
End if
$headers:=New collection:C1472
For each ($field; $records[0])
	$headers.push(cs:C1710.sfw_string.me.trimSpace(Replace string:C233($field; Char:C90(65279); "")))  // without the UTF-8 BOM
End for each
For ($i; 1; $records.length-1)
	$record:=$records[$i]
	If ($record.join("")="")
		continue
	End if
	$row:=New object:C1471
	For ($col; 0; $headers.length-1)
		If ($headers[$col]#"")
			$row[$headers[$col]]:=($col<$record.length) ? cs:C1710.sfw_string.me.trimSpace($record[$col]) : ""
		End if
	End for
	$rows.push($row)
End for
