//%attributes = {}
// _import_lotTraveller
// Restores the "Lot Traveller" print template (Planning > Print Lot Traveller), which was
// laid out by hand in the dfd editor of the previous data file and that no method rebuilds.
//
// Sources:
// - Project/imports/dfd_lotTraveller.json: the dfd_Template "Lot Traveller" and the 9
//   dfd_Line records it uses that are not in dfdLine.json, recovered from the data file of
//   10 July 2026 (Desktop/imports/GA MOVED FIles), UUIDs unchanged
// - Resources/ga/referenceRecords/dfdLine.json: the other lines it uses (the framework's
//   reference-records export of dfd_Line)
//
// Only creates what is missing: a line that already exists (same UUID) and a template that
// already exists (same name) are left as they are. Safe to run again.
	
var $bundle : Object
var $reference : Object
var $source : Object
var $uuid : Text
var $needed : Collection
var $created : Collection
var $existing : Integer
var $missing : Collection
var $res : Object
var $line : 4D:C1709.Entity
var $template : 4D:C1709.Entity
var $file : 4D:C1709.File
var $message : Text
	
$file:=Folder:C1567(fk database folder:K87:14).folder("Project/imports").file("dfd_lotTraveller.json")
If (Not:C34($file.exists))
	ALERT:C41("File not found: "+$file.platformPath)
	return
End if 
$bundle:=JSON Parse:C1218($file.getText())
	
$file:=Folder:C1567(fk resources folder:K87:11).folder("ga/referenceRecords").file("dfdLine.json")
If ($file.exists)
	$reference:=JSON Parse:C1218($file.getText())
Else 
	$reference:=New object:C1471("records"; New collection:C1472)
End if 
	
// every line the template places must exist, under the UUID the template refers to
$needed:=$bundle.template.hierarchy.lines.extract("UUID_entity").distinct()
$created:=New collection:C1472
$missing:=New collection:C1472
$existing:=0
	
For each ($uuid; $needed)
	If (ds:C1482.dfd_Line.get($uuid)#Null:C1517)
		$existing+=1
		continue
	End if 
	$source:=$bundle.lines.query("UUID = :1"; $uuid).first()
	If ($source=Null:C1517)
		$source:=$reference.records.query("UUID = :1"; $uuid).first()
	End if 
	If ($source=Null:C1517)
		$missing.push($uuid)
		continue
	End if 
	
	$line:=ds:C1482.dfd_Line.new()
	$line.UUID:=$source.UUID
	$line.name:=$source.name
	$line.calculs:=$source.calculs
	$line.objectsForm:=$source.objectsForm
	$line.variableItems:=$source.variableItems
	$line.moreData:=$source.moreData
	$res:=$line.save()
	If ($res.success)
		$created.push($source.name)
	Else 
		$missing.push($source.name+" (not saved: "+JSON Stringify:C1217($res)+")")
	End if 
End for each 
	
// the template itself
$template:=ds:C1482.dfd_Template.query("name = :1"; $bundle.template.name).first()
If ($template=Null:C1517)
	$template:=ds:C1482.dfd_Template.new()
	$template.UUID:=$bundle.template.UUID
	$template.name:=$bundle.template.name
	$template.hierarchy:=$bundle.template.hierarchy
	$template.calculs:=$bundle.template.calculs
	$template.moreData:=$bundle.template.moreData
	$res:=$template.save()
	If ($res.success)
		$message:="Template \""+$bundle.template.name+"\" created ("+String:C10($bundle.template.hierarchy.lines.length)+" lines placed)."
	Else 
		$message:="Template \""+$bundle.template.name+"\" NOT saved: "+JSON Stringify:C1217($res)
	End if 
Else 
	$message:="Template \""+$bundle.template.name+"\" already exists: left as it is."
End if 
	
$message+="\r\rLines it uses: "+String:C10($needed.length)
$message+="\r  created: "+String:C10($created.length)
$message+="\r  already there: "+String:C10($existing)
If ($missing.length>0)
	$message+="\r  MISSING: "+$missing.join(", ")
End if 
	
ALERT:C41($message)
