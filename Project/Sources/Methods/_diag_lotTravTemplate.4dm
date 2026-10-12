//%attributes = {}
// _diag_lotTravTemplate
// Read only: the "Lot Traveller" print template as the database holds it - the template record
// (with its ordered line list) and every line it uses, with their objects (type, position, size,
// data, picture format, visibility) and tags - to fix the QA stamp, the serial numbers and the
// barcode boxes precisely. Writes Project/imports/lot_traveller_template.json. Changes nothing.
var $template; $line : 4D:C1709.Entity
var $out; $entry : Object
var $seen : Collection
	
$template:=ds:C1482.dfd_Template.query("name = :1"; "Lot Traveller").first()
If ($template=Null:C1517)
	ALERT:C41("Template not found: Lot Traveller")
	return 
End if 
$out:=New object:C1471("template"; $template.toObject(); "lines"; New collection:C1472)
$seen:=New collection:C1472
For each ($entry; $template.hierarchy.lines)
	If (String:C10($entry.UUID_entity)#"") && ($seen.indexOf(String:C10($entry.UUID_entity))<0)
		$seen.push(String:C10($entry.UUID_entity))
		$line:=ds:C1482.dfd_Line.get($entry.UUID_entity)
		If ($line#Null:C1517)
			$out.lines.push($line.toObject())
		End if 
	End if 
End for each 
Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("lot_traveller_template.json").setText(JSON Stringify:C1217($out; *))
ALERT:C41("Lot Traveller template written to Project/imports/lot_traveller_template.json ("+String:C10($out.lines.length)+" lines): send it to Claude.")
