$lines:=New collection:C1472
For each ($event; Form:C1466.lb_events)
	$columns:=New collection:C1472
	$columns.push(String:C10(Time:C179($event.time); HH MM SS:K7:1))
	$columns.push($event.message)
	$columns.push($event.from.code)
	$columns.push($event.from.line)
	$lines.push($columns.join("\t"))
End for each 
$textExport:=$lines.join("\r")
SET TEXT TO PASTEBOARD:C523($textExport)
